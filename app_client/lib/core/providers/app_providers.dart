/// 全局的 Riverpod provider 声明，统一管理核心依赖的创建与销毁。
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:im_client/core/api/grpc_channel.dart';
import 'package:im_client/core/config/app_config.dart';
import 'package:im_client/core/config/app_config_controller.dart';
import 'package:im_client/core/logging/debug_log_buffer.dart';
import 'package:im_client/core/session/session_event.dart';
import 'package:im_client/core/socket/socket_manager.dart';
import 'package:im_client/core/storage/local_store.dart';
import 'package:im_client/features/auth/data/auth_api_client.dart';
import 'package:im_client/features/chat/data/message_repository.dart';

/// Global provider exposing the mutable app configuration.
final appConfigNotifierProvider =
    StateNotifierProvider<AppConfigNotifier, AppConfigData>((ref) {
      throw UnimplementedError(
        'App configuration must be overridden at app bootstrap',
      );
    });

/// 全局本地存储（Isar）访问入口。
final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('Local store must be overridden at app bootstrap');
});

/// 调试日志缓冲区（用于 UI 展示最近日志）。
final debugLogBufferProvider = ChangeNotifierProvider<DebugLogBuffer>(
  (ref) => DebugLogBuffer(),
);

/// Provides a logger instance aligned with the current log level setting.
final loggerProvider = Provider<Logger>((ref) {
  final config = ref.watch(appConfigNotifierProvider);
  final buffer = ref.read(debugLogBufferProvider);
  return Logger(
    level: config.logLevel.loggerLevel,
    printer: PrettyPrinter(
      colors: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      noBoxingByDefault: true,
    ),
    output: MultiOutput([ConsoleOutput(), buffer]),
  );
});

/// Resolves the active gRPC endpoint based on the current configuration.
final grpcConfigProvider = Provider<GrpcConfig>((ref) {
  final config = ref.watch(appConfigNotifierProvider);
  final endpoint = config.activeServer;
  return GrpcConfig(
    host: endpoint.grpcHost,
    port: endpoint.grpcPort,
    useTls: endpoint.useTls,
  );
});

/// Manages the lifecycle of the gRPC channel.
final grpcChannelManagerProvider = Provider<GrpcChannelManager>((ref) {
  final logger = ref.watch(loggerProvider);
  final grpcConfig = ref.watch(grpcConfigProvider);
  final manager = GrpcChannelManager(config: grpcConfig, logger: logger);
  ref.onDispose(() {
    unawaited(manager.shutdown());
  });
  return manager;
});

/// Authentication API client bound to the configured gRPC channel.
final authApiClientProvider = Provider<AuthApiClient>((ref) {
  final manager = ref.watch(grpcChannelManagerProvider);
  final client = AuthApiClient(channelManager: manager);
  ref.onDispose(() {
    unawaited(client.dispose());
  });
  return client;
});

/// 管理与 app_socket 的 TCP 连接。
final socketManagerProvider = Provider<SocketManager>((ref) {
  final logger = ref.watch(loggerProvider);
  final manager = SocketManager(logger: logger);
  ref.onDispose(() {
    unawaited(manager.dispose());
  });
  return manager;
});

/// 消息仓库：负责解析 socket 下行并落地到 Isar。
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final store = ref.watch(localStoreProvider);
  final socketManager = ref.watch(socketManagerProvider);
  final logger = ref.watch(loggerProvider);
  final sessionEvents = ref.watch(sessionEventProvider.notifier);
  final repository = MessageRepository(
    store: store,
    socketManager: socketManager,
    logger: logger,
    sessionEvents: sessionEvents,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// 会话事件（被踢下线等）。
final sessionEventProvider =
    StateNotifierProvider<SessionEventNotifier, SessionEvent?>(
      (ref) => SessionEventNotifier(),
    );
