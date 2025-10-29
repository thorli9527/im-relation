/// 基于 Isar 的本地持久层，负责缓存登录会话、好友、消息等数据。
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'auth_session.dart';
import 'device_profile.dart';
import 'friend_entity.dart';
import 'messages/friend_biz_entity.dart';
import 'messages/friend_message_entity.dart';
import 'messages/group_biz_entity.dart';
import 'messages/group_message_entity.dart';
import 'messages/outbox_message_entity.dart';
import 'messages/system_message_entity.dart';
import 'messages/voice_message_entity.dart';
import 'group_entity.dart';

const int kDefaultDeviceType = 4; // 对应后端 DeviceType::Pc。

const String _workspaceIdFromDartDefine = String.fromEnvironment(
  'IM_CLIENT_WORKSPACE',
  defaultValue: '',
);

/// 读取环境变量或编译常量获取工作空间前缀，便于多账户隔离。
String _resolveWorkspaceId() {
  final env = Platform.environment['IM_CLIENT_WORKSPACE'];
  if (env != null && env.trim().isNotEmpty) {
    return env.trim();
  }
  if (_workspaceIdFromDartDefine.isNotEmpty) {
    return _workspaceIdFromDartDefine;
  }
  return 'default';
}

/// 封装 Isar 数据库的打开、初始化与常用读写方法。
class LocalStore {
  LocalStore._(this._isar);

  final Isar _isar;

  /// 打开本地持久化实例，不存在时自动创建目录并初始化基础数据。
  static Future<LocalStore> open() async {
    final supportDir = await getApplicationSupportDirectory();
    final workspaceId = _resolveWorkspaceId();
    final dbDir = Directory(p.join(supportDir.path, 'isar', workspaceId));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    final isar = await Isar.open(
      [
        DeviceProfileSchema,
        AuthSessionSchema,
        FriendEntitySchema,
        GroupEntitySchema,
        FriendMessageEntitySchema,
        FriendBizEntitySchema,
        GroupMessageEntitySchema,
        GroupBizEntitySchema,
        OutboxMessageEntitySchema,
        SystemMessageEntitySchema,
        VoiceMessageEntitySchema,
      ],
      directory: dbDir.path,
      name: 'im_client_$workspaceId',
      inspector: kDebugMode,
    );
    final store = LocalStore._(isar);
    await store._initialize();
    return store;
  }

  /// 提供内存版数据库，主要用于测试或临时环境。
  static Future<LocalStore> inMemory() async {
    final tempDir = await Directory.systemTemp.createTemp('isar_test');
    final isar = await Isar.open(
      [
        DeviceProfileSchema,
        AuthSessionSchema,
        FriendEntitySchema,
        GroupEntitySchema,
        FriendMessageEntitySchema,
        FriendBizEntitySchema,
        GroupMessageEntitySchema,
        GroupBizEntitySchema,
        OutboxMessageEntitySchema,
        SystemMessageEntitySchema,
        VoiceMessageEntitySchema,
      ],
      directory: tempDir.path,
      inspector: false,
    );
    final store = LocalStore._(isar);
    await store._initialize();
    return store;
  }

  Isar get isar => _isar;

  /// 确保关键表存在默认记录（设备信息 & 会话信息）。
  Future<void> _initialize() async {
    await ensureDeviceProfile();
    await ensureAuthSession();
  }

  /// 获取设备信息，若不存在则自动生成一条默认记录。
  Future<DeviceProfile> ensureDeviceProfile() async {
    final existing = await _isar.deviceProfiles.get(0);
    if (existing != null) {
      return existing;
    }
    final now = DateTime.now();
    final profile = DeviceProfile()
      ..id = 0
      ..deviceId = _generateDeviceId()
      ..deviceType = kDefaultDeviceType
      ..createdAt = now
      ..updatedAt = now;
    await _isar.writeTxn(() async {
      await _isar.deviceProfiles.put(profile);
    });
    return profile;
  }

  /// 获取登录会话记录，若为空则创建初始状态。
  Future<AuthSession> ensureAuthSession() async {
    final existing = await _isar.authSessions.get(0);
    if (existing != null) {
      return existing;
    }
    final session = AuthSession()
      ..id = 0
      ..isLoggedIn = false
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.authSessions.put(session);
    });
    return session;
  }

  /// 直接返回设备信息，内部确保记录已存在。
  Future<DeviceProfile> getDeviceProfile() async {
    final profile = await ensureDeviceProfile();
    return profile;
  }

  /// 直接返回会话信息，内部确保记录已存在。
  Future<AuthSession> getAuthSession() async {
    final session = await ensureAuthSession();
    return session;
  }

  /// 标记用户已退出登录，并清理敏感字段。
  Future<void> markLoggedOut() async {
    final session = await ensureAuthSession();
    session
      ..isLoggedIn = false
      ..userId = null
      ..token = null
      ..expiresAt = null
      ..socketAddr = null
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.authSessions.put(session);
    });
  }

  /// 在登录成功后落地会话与设备信息，供后续自动登录使用。
  Future<void> persistLoginSuccess({
    required int userId,
    required int loginType,
    required String account,
    required String password,
    required int deviceType,
    required String deviceId,
    required String token,
    required int expiresAt,
    required String socketAddr,
  }) async {
    final session = await ensureAuthSession();
    session
      ..isLoggedIn = true
      ..userId = userId
      ..loginType = loginType
      ..account = account
      ..password = password
      ..deviceType = deviceType
      ..token = token
      ..expiresAt = expiresAt
      ..socketAddr = socketAddr
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.authSessions.put(session);
    });

    final profile = await ensureDeviceProfile();
    profile
      ..deviceId = deviceId
      ..deviceType = deviceType
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.deviceProfiles.put(profile);
    });
  }

  /// 刷新已登录用户的会话 token，保持本地数据有效。
  Future<void> refreshToken({
    required String token,
    required int expiresAt,
    int? userId,
  }) async {
    final session = await ensureAuthSession();
    session
      ..token = token
      ..expiresAt = expiresAt
      ..isLoggedIn = true
      ..userId = userId ?? session.userId
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.authSessions.put(session);
    });
  }

  /// 生成近似随机的设备 ID，兼顾可读性与唯一性。
  String _generateDeviceId() {
    final uuid = const Uuid().v4().replaceAll('-', '');
    final random = Random.secure().nextInt(9999).toString().padLeft(4, '0');
    return 'dev-$random${uuid.substring(0, 12)}';
  }
}
