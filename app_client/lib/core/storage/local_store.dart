import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'auth_session.dart';
import 'device_profile.dart';
import 'messages/friend_biz_entity.dart';
import 'messages/friend_message_entity.dart';
import 'messages/group_biz_entity.dart';
import 'messages/group_message_entity.dart';
import 'messages/outbox_message_entity.dart';
import 'messages/system_message_entity.dart';

const int kDefaultDeviceType = 4; // 对应后端 DeviceType::Pc。

class LocalStore {
  LocalStore._(this._isar);

  final Isar _isar;

  static Future<LocalStore> open() async {
    final supportDir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(supportDir.path, 'isar'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    final isar = await Isar.open(
      [
        DeviceProfileSchema,
        AuthSessionSchema,
        FriendMessageEntitySchema,
        FriendBizEntitySchema,
        GroupMessageEntitySchema,
        GroupBizEntitySchema,
        OutboxMessageEntitySchema,
        SystemMessageEntitySchema,
      ],
      directory: dbDir.path,
      inspector: kDebugMode,
    );
    final store = LocalStore._(isar);
    await store._initialize();
    return store;
  }

  static Future<LocalStore> inMemory() async {
    final tempDir = await Directory.systemTemp.createTemp('isar_test');
    final isar = await Isar.open(
      [
        DeviceProfileSchema,
        AuthSessionSchema,
        FriendMessageEntitySchema,
        FriendBizEntitySchema,
        GroupMessageEntitySchema,
        GroupBizEntitySchema,
        OutboxMessageEntitySchema,
        SystemMessageEntitySchema,
      ],
      directory: tempDir.path,
      inspector: false,
    );
    final store = LocalStore._(isar);
    await store._initialize();
    return store;
  }

  Isar get isar => _isar;

  Future<void> _initialize() async {
    await ensureDeviceProfile();
    await ensureAuthSession();
  }

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

  Future<DeviceProfile> getDeviceProfile() async {
    final profile = await ensureDeviceProfile();
    return profile;
  }

  Future<AuthSession> getAuthSession() async {
    final session = await ensureAuthSession();
    return session;
  }

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

  String _generateDeviceId() {
    final uuid = const Uuid().v4().replaceAll('-', '');
    final random = Random.secure().nextInt(9999).toString().padLeft(4, '0');
    return 'dev-$random${uuid.substring(0, 12)}';
  }
}
