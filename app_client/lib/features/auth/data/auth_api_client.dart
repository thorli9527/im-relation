import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:im_client/core/api/grpc_channel.dart';
import 'package:im_client/features/auth/models/login_payload.dart';
import 'package:im_client/gen/api/auth.pbgrpc.dart';

class AuthApiClient {
  AuthApiClient({
    required GrpcChannelManager channelManager,
  }) : _channelManager = channelManager;

  final GrpcChannelManager _channelManager;
  ApiServiceClient? _client;

  ApiServiceClient get _apiClient {
    final existing = _client;
    if (existing != null) {
      return existing;
    }
    final client = ApiServiceClient(_channelManager.channel);
    _client = client;
    return client;
  }

  Future<LoginResponse> login(LoginRequestPayload payload, {CallOptions? options}) {
    final request = payload.toProto();
    return _apiClient.login(request, options: options);
  }

  Future<void> dispose() => _channelManager.shutdown();
}
