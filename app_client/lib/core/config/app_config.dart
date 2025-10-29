/// 应用配置模型与加载工具，负责描述 gRPC 服务节点以及日志等级等基础设置。
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// 单个后端服务节点的配置，描述 gRPC 地址、端口以及 TLS 选项。
class ServerConfig {
  const ServerConfig({
    required this.id,
    required this.name,
    required this.grpcHost,
    required this.grpcPort,
    this.useTls = false,
  });

  final String id;
  final String name;
  final String grpcHost;
  final int grpcPort;
  final bool useTls;

  /// 从配置文件解析一个服务节点，自动回退缺失的名称。
  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String)
          : (json['id'] as String),
      grpcHost: json['grpcHost'] as String,
      grpcPort: (json['grpcPort'] as num).toInt(),
      useTls: json['useTls'] as bool? ?? false,
    );
  }
}

/// UI 侧可选的日志等级，额外封装了展示标签与 `logger` 库的等级映射。
enum LogLevelSetting {
  trace,
  debug,
  info,
  warn,
  error,
}

extension LogLevelSettingX on LogLevelSetting {
  String get label {
    switch (this) {
      case LogLevelSetting.trace:
        return 'Trace';
      case LogLevelSetting.debug:
        return 'Debug';
      case LogLevelSetting.info:
        return 'Info';
      case LogLevelSetting.warn:
        return 'Warn';
      case LogLevelSetting.error:
        return 'Error';
    }
  }

  Level get loggerLevel {
    switch (this) {
      case LogLevelSetting.trace:
        return Level.trace;
      case LogLevelSetting.debug:
        return Level.debug;
      case LogLevelSetting.info:
        return Level.info;
      case LogLevelSetting.warn:
        return Level.warning;
      case LogLevelSetting.error:
        return Level.error;
    }
  }

  /// 从字符串配置解析日志等级，无法识别时回退为 `info`。
  static LogLevelSetting parse(String? value) {
    switch (value?.toLowerCase()) {
      case 'trace':
        return LogLevelSetting.trace;
      case 'debug':
        return LogLevelSetting.debug;
      case 'warn':
      case 'warning':
        return LogLevelSetting.warn;
      case 'error':
        return LogLevelSetting.error;
      case 'info':
      default:
        return LogLevelSetting.info;
    }
  }
}

/// 全量应用配置数据结构，包含服务列表、激活节点以及日志等级。
class AppConfigData {
  AppConfigData({
    required this.servers,
    required this.activeServerId,
    required this.logLevel,
  });

  final List<ServerConfig> servers;
  final String activeServerId;
  final LogLevelSetting logLevel;

  /// 根据当前激活的服务 ID 找到对应配置，若列表为空则返回内置的本地节点。
  ServerConfig get activeServer {
    if (servers.isEmpty) {
      return ServerConfig(
        id: 'fallback',
        name: 'Localhost',
        grpcHost: '127.0.0.1',
        grpcPort: 50051,
        useTls: false,
      );
    }
    return servers.firstWhere(
      (server) => server.id == activeServerId,
      orElse: () => servers.first,
    );
  }

  /// 构造一个带部分字段替换的新配置，保持激活节点与列表一致性。
  AppConfigData copyWith({
    List<ServerConfig>? servers,
    String? activeServerId,
    LogLevelSetting? logLevel,
  }) {
    final updatedServers = servers ?? this.servers;
    final updatedActiveServerId = activeServerId ??
        (updatedServers.isNotEmpty ? updatedServers.first.id : this.activeServerId);
    return AppConfigData(
      servers: updatedServers,
      activeServerId: updatedActiveServerId,
      logLevel: logLevel ?? this.logLevel,
    );
  }

  /// 从 JSON 数据构造配置，自动填充缺失的服务器或激活 ID。
  factory AppConfigData.fromJson(Map<String, dynamic> json) {
    final serversJson = json['servers'] as List<dynamic>? ?? const [];
    final servers = serversJson
        .map((entry) => ServerConfig.fromJson(entry as Map<String, dynamic>))
        .toList();
    final activeServerId = json['activeServer'] as String?;
    final logLevel = LogLevelSettingX.parse(json['logLevel'] as String?);
    return AppConfigData(
      servers: servers.isEmpty ? _fallback().servers : servers,
      activeServerId: activeServerId ?? (servers.isNotEmpty ? servers.first.id : _fallback().activeServerId),
      logLevel: logLevel,
    );
  }

  /// 提供公开的兜底配置，用于初始化失败时快速恢复本地节点。
  static AppConfigData fallback() => _fallback();

  static AppConfigData _fallback() => AppConfigData(
        servers: const [
          ServerConfig(
            id: 'local',
            name: '本地开发环境',
            grpcHost: '127.0.0.1',
            grpcPort: 50051,
            useTls: false,
          ),
        ],
        activeServerId: 'local',
        logLevel: LogLevelSetting.info,
      );
}

/// 负责从资源包读取配置文件，并将其转换为运行时模型。
class AppConfigLoader {
  static const String defaultAssetPath = 'assets/config/app_config.json';

  /// 尝试读取配置文件，读取失败时返回兜底配置并打印日志。
  static Future<AppConfigData> load({String? assetPath}) async {
    final path = assetPath ?? defaultAssetPath;
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return AppConfigData.fromJson(decoded);
    } catch (error) {
      debugPrint('Failed to load app config ($path). Using fallback. Error: $error');
      return AppConfigData.fallback();
    }
  }
}
