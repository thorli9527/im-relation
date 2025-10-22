import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

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

class AppConfigData {
  AppConfigData({
    required this.servers,
    required this.activeServerId,
    required this.logLevel,
  });

  final List<ServerConfig> servers;
  final String activeServerId;
  final LogLevelSetting logLevel;

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

class AppConfigLoader {
  static const String defaultAssetPath = 'assets/config/app_config.json';

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
