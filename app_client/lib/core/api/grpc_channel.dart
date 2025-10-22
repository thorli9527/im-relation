import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';

import 'package:im_client/core/api/logging_interceptor.dart';

class GrpcConfig {
  const GrpcConfig({
    required this.host,
    required this.port,
    this.useTls = false,
    this.connectionTimeout = const Duration(seconds: 5),
    this.idleTimeout = const Duration(minutes: 5),
  });

  final String host;
  final int port;
  final bool useTls;
  final Duration connectionTimeout;
  final Duration idleTimeout;

  GrpcConfig copyWith({
    String? host,
    int? port,
    bool? useTls,
    Duration? connectionTimeout,
    Duration? idleTimeout,
  }) {
    return GrpcConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      useTls: useTls ?? this.useTls,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      idleTimeout: idleTimeout ?? this.idleTimeout,
    );
  }
}

class GrpcChannelManager {
  GrpcChannelManager({
    GrpcConfig config = const GrpcConfig(host: '127.0.0.1', port: 50051),
    Logger? logger,
    List<ClientInterceptor> extraInterceptors = const [],
  })  : _config = config,
        _logger = logger ?? Logger() {
    _interceptors = <ClientInterceptor>[
      GrpcLoggingInterceptor(_logger),
      ...extraInterceptors,
    ];
  }

  final GrpcConfig _config;
  final Logger _logger;
  ClientChannel? _channel;
  late final List<ClientInterceptor> _interceptors;

  ClientChannel get channel {
    final existing = _channel;
    if (existing != null) {
      return existing;
    }
    final credentials =
        _config.useTls ? const ChannelCredentials.secure() : const ChannelCredentials.insecure();
    final channel = ClientChannel(
      _config.host,
      port: _config.port,
      options: ChannelOptions(
        credentials: credentials,
        connectionTimeout: _config.connectionTimeout,
        idleTimeout: _config.idleTimeout,
      ),
    );
    _logger.i('gRPC channel initialized: ${_config.host}:${_config.port}');
    _channel = channel;
    return channel;
  }

  Iterable<ClientInterceptor> get interceptors =>
      List<ClientInterceptor>.unmodifiable(_interceptors);

  Future<void> shutdown() async {
    final channel = _channel;
    if (channel != null) {
      try {
        await channel.shutdown();
        _logger.i('gRPC channel shut down');
      } finally {
        _channel = null;
      }
    }
  }
}
