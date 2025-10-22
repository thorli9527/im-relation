import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:im_client/core/api/grpc_channel.dart';
import 'package:im_client/features/auth/models/login_payload.dart';
import 'package:im_client/gen/api/auth.pbgrpc.dart';

class AuthApiClient {
  AuthApiClient({required GrpcChannelManager channelManager})
    : _channelManager = channelManager;

  final GrpcChannelManager _channelManager;
  ApiServiceClient? _client;

  ApiServiceClient get _apiClient {
    final existing = _client;
    if (existing != null) {
      return existing;
    }
    final client = ApiServiceClient(
      _channelManager.channel,
      interceptors: _channelManager.interceptors,
    );
    _client = client;
    return client;
  }

  Future<LoginResponse> login(
    LoginRequestPayload payload, {
    CallOptions? options,
  }) {
    final request = payload.toProto();
    return _apiClient.login(request, options: options);
  }

  Future<ValidateSessionTokenResponse> validateToken(
    String sessionToken, {
    CallOptions? options,
  }) {
    final request = ValidateSessionTokenRequest()..sessionToken = sessionToken;
    return _apiClient.validateSessionToken(request, options: options);
  }

  Future<SearchUserResponse> searchUser(
    UserSearchType type,
    String query, {
    CallOptions? options,
  }) {
    final request = SearchUserRequest()
      ..searchType = type
      ..query = query;
    return _apiClient.searchUser(request, options: options);
  }

  Future<void> dispose() => _channelManager.shutdown();
}
