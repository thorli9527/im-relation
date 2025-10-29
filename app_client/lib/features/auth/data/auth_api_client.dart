/// Auth gRPC 客户端封装，负责复用 channel 并提供便捷方法。
import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:im_client/core/api/grpc_channel.dart';
import 'package:im_client/features/auth/models/login_payload.dart';
import 'package:im_client/gen/api/auth.pbgrpc.dart';

/// 统一封装登录相关的 gRPC 调用，自动注入拦截器。
class AuthApiClient {
  AuthApiClient({required GrpcChannelManager channelManager})
    : _channelManager = channelManager;

  final GrpcChannelManager _channelManager;
  ApiServiceClient? _client;

  /// 延迟创建底层 gRPC 客户端，复用现有 channel。
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

  /// 发起登录请求，将自定义 payload 转换成 proto。
  Future<LoginResponse> login(
    LoginRequestPayload payload, {
    CallOptions? options,
  }) {
    final request = payload.toProto();
    return _apiClient.login(request, options: options);
  }

  /// 校验会话 token 是否仍然有效，可选获取刷新后的 token。
  Future<ValidateSessionTokenResponse> validateToken(
    String sessionToken, {
    CallOptions? options,
  }) {
    final request = ValidateSessionTokenRequest()..sessionToken = sessionToken;
    return _apiClient.validateSessionToken(request, options: options);
  }

  /// 搜索用户资料，支持多种检索类型。
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

  /// 主动关闭 channel，通常在应用退出时调用。
  Future<void> dispose() => _channelManager.shutdown();
}
