// 文件路径: lib/services/database_service.dart

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:riverpod/riverpod.dart';

import '../models/system/system_config.dart';
import '../models/message/ack_message.dart'; // 确保导入 AckMessage
import '../utils/log_util.dart';

/// 使用 Riverpod 实现的数据库服务
class DatabaseService {
  late Isar isar;

  Future<DatabaseService> init() async {
    // 获取应用支持目录
    final dir = await getApplicationSupportDirectory();
    final dbDir = Directory('${dir.path}/isar');

    // 创建数据库目录（如果不存在）
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    } else {
      LogUtil.info('DatabaseService', '⚙️ 数据库路径: ${dbDir.path}');
    }

    // 打开 Isar 数据库，添加 AckMessageSchema
    isar = await Isar.open(
      [SystemConfigSchema, AckMessageSchema], // 添加 AckMessageSchema
      directory: dbDir.path,
      name: 'im_client',
    );

    return this;
  }

  /// 获取数据库实例
  Isar get db => isar;
}

/// Riverpod 提供者
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('请使用 databaseServiceAsyncProvider 初始化数据库');
});

/// 异步初始化的 Riverpod 提供者
final databaseServiceAsyncProvider = FutureProvider<DatabaseService>((ref) async {
  final service = DatabaseService();
  await service.init();
  ref.onDispose(() {
    service.db.close();
  });
  return service;
});
