import 'dart:async';

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:grpc/grpc.dart';

import '../generated/api/auth.pbgrpc.dart';
import '../generated/api/recent_conversations_manual.dart' as recent;
import 'grpc_channel.dart';
import 'login_payload.dart';

class AuthApiClient {
  AuthApiClient({required GrpcChannelManager channelManager})
    : _channelManager = channelManager;

  final GrpcChannelManager _channelManager;
  ApiServiceClient? _client;

  static final ClientMethod<
    recent.GetRecentConversationsRequest,
    recent.GetRecentConversationsResponse
  >
  _getRecentConversations =
      ClientMethod<
        recent.GetRecentConversationsRequest,
        recent.GetRecentConversationsResponse
      >(
        '/api.ApiService/GetRecentConversations',
        (recent.GetRecentConversationsRequest value) => value.writeToBuffer(),
        (List<int> value) =>
            recent.GetRecentConversationsResponse.fromBuffer(value),
      );

  ApiServiceClient get _api {
    final existing = _client;
    if (existing != null) {
      return existing;
    }
    final created = ApiServiceClient(
      _channelManager.channel,
      interceptors: _channelManager.interceptors,
    );
    _client = created;
    return created;
  }

  Future<LoginResponse> login(
    LoginRequestPayload payload, {
    CallOptions? options,
  }) {
    final request = payload.toProto();
    return _api.login(request, options: options);
  }

  Future<ValidateSessionTokenResponse> validateToken(
    String sessionToken, {
    CallOptions? options,
  }) {
    final request = ValidateSessionTokenRequest()..sessionToken = sessionToken;
    return _api.validateSessionToken(request, options: options);
  }

  Future<SearchUserResponse> searchUser(
    UserSearchType searchType,
    String query, {
    CallOptions? options,
  }) {
    final request = SearchUserRequest()
      ..searchType = searchType
      ..query = query;
    return _api.searchUser(request, options: options);
  }

  Future<GetFriendListResponse> getFriendList({
    required String sessionToken,
    int page = 1,
    int pageSize = 100,
    CallOptions? options,
  }) {
    final request = GetFriendListRequest()
      ..sessionToken = sessionToken
      ..page = page
      ..pageSize = pageSize;
    return _api.getFriendList(request, options: options);
  }

  Future<recent.GetRecentConversationsResponse> getRecentConversations({
    required String sessionToken,
    int limit = 100,
    $fixnum.Int64? beforeUpdatedAt,
    recent.ConversationScene? beforeScene,
    $fixnum.Int64? beforeConversationId,
    CallOptions? options,
  }) {
    final request = recent.GetRecentConversationsRequest()
      ..sessionToken = sessionToken
      ..limit = limit;
    if (beforeUpdatedAt != null) {
      request.beforeUpdatedAt = beforeUpdatedAt;
    }
    if (beforeScene != null) {
      request.beforeScene = beforeScene;
    }
    if (beforeConversationId != null) {
      request.beforeConversationId = beforeConversationId;
    }
    return _api.$createUnaryCall(
      _getRecentConversations,
      request,
      options: options,
    );
  }

  Future<void> dispose() => _channelManager.shutdown();
}
