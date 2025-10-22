// This is a generated file - do not edit.
//
// Generated from msg_friend.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/empty.pb.dart' as $1;
import 'message.pb.dart' as $2;
import 'msg_friend.pb.dart' as $0;

export 'msg_friend.pb.dart';

@$pb.GrpcServiceName('msg_friend_service.FriendBizService')
class FriendBizServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  FriendBizServiceClient(super.channel, {super.options, super.interceptors});

  /// 发送好友申请
  $grpc.ResponseFuture<$1.Empty> sendFriendRequest($0.FriendRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$sendFriendRequest, request, options: options);
  }

  /// 处理好友申请
  $grpc.ResponseFuture<$1.Empty> handleFriendRequest($0.FriendRequestDecision request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$handleFriendRequest, request, options: options);
  }

  /// 删除好友
  $grpc.ResponseFuture<$1.Empty> deleteFriend($0.FriendDelete request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$deleteFriend, request, options: options);
  }

  /// 更新好友备注
  $grpc.ResponseFuture<$1.Empty> updateFriendRemark($0.FriendUpdateRemark request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$updateFriendRemark, request, options: options);
  }

    // method descriptors

  static final _$sendFriendRequest = $grpc.ClientMethod<$0.FriendRequest, $1.Empty>(
      '/msg_friend_service.FriendBizService/SendFriendRequest',
      ($0.FriendRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$handleFriendRequest = $grpc.ClientMethod<$0.FriendRequestDecision, $1.Empty>(
      '/msg_friend_service.FriendBizService/HandleFriendRequest',
      ($0.FriendRequestDecision value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$deleteFriend = $grpc.ClientMethod<$0.FriendDelete, $1.Empty>(
      '/msg_friend_service.FriendBizService/DeleteFriend',
      ($0.FriendDelete value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$updateFriendRemark = $grpc.ClientMethod<$0.FriendUpdateRemark, $1.Empty>(
      '/msg_friend_service.FriendBizService/UpdateFriendRemark',
      ($0.FriendUpdateRemark value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
}

@$pb.GrpcServiceName('msg_friend_service.FriendBizService')
abstract class FriendBizServiceBase extends $grpc.Service {
  $core.String get $name => 'msg_friend_service.FriendBizService';

  FriendBizServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.FriendRequest, $1.Empty>(
        'SendFriendRequest',
        sendFriendRequest_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FriendRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FriendRequestDecision, $1.Empty>(
        'HandleFriendRequest',
        handleFriendRequest_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FriendRequestDecision.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FriendDelete, $1.Empty>(
        'DeleteFriend',
        deleteFriend_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FriendDelete.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FriendUpdateRemark, $1.Empty>(
        'UpdateFriendRemark',
        updateFriendRemark_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FriendUpdateRemark.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$1.Empty> sendFriendRequest_Pre($grpc.ServiceCall $call, $async.Future<$0.FriendRequest> $request) async {
    return sendFriendRequest($call, await $request);
  }

  $async.Future<$1.Empty> sendFriendRequest($grpc.ServiceCall call, $0.FriendRequest request);

  $async.Future<$1.Empty> handleFriendRequest_Pre($grpc.ServiceCall $call, $async.Future<$0.FriendRequestDecision> $request) async {
    return handleFriendRequest($call, await $request);
  }

  $async.Future<$1.Empty> handleFriendRequest($grpc.ServiceCall call, $0.FriendRequestDecision request);

  $async.Future<$1.Empty> deleteFriend_Pre($grpc.ServiceCall $call, $async.Future<$0.FriendDelete> $request) async {
    return deleteFriend($call, await $request);
  }

  $async.Future<$1.Empty> deleteFriend($grpc.ServiceCall call, $0.FriendDelete request);

  $async.Future<$1.Empty> updateFriendRemark_Pre($grpc.ServiceCall $call, $async.Future<$0.FriendUpdateRemark> $request) async {
    return updateFriendRemark($call, await $request);
  }

  $async.Future<$1.Empty> updateFriendRemark($grpc.ServiceCall call, $0.FriendUpdateRemark request);

}
/// 好友消息服务（非群聊）
@$pb.GrpcServiceName('msg_friend_service.FriendMsgService')
class FriendMsgServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  FriendMsgServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$1.Empty> sendMessage($2.Content request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$sendMessage, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> reportMsgRead($2.MsgRead request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$reportMsgRead, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> ackMsgDelivered($2.MsgDeliveredAck request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$ackMsgDelivered, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> ackMsgRead($2.MsgReadAck request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$ackMsgRead, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> recallMsg($2.MsgRecall request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$recallMsg, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> forwardMsg($2.MsgForward request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$forwardMsg, request, options: options);
  }

  /// 分页查询好友间的历史消息
  $grpc.ResponseFuture<$2.QueryMessagesResponse> listFriendMessages($2.QueryFriendMessagesRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$listFriendMessages, request, options: options);
  }

  /// 聚合查询用户的好友消息
  $grpc.ResponseFuture<$2.QueryMessagesResponse> listUserFriendMessages($0.ListUserFriendMessagesRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$listUserFriendMessages, request, options: options);
  }

    // method descriptors

  static final _$sendMessage = $grpc.ClientMethod<$2.Content, $1.Empty>(
      '/msg_friend_service.FriendMsgService/SendMessage',
      ($2.Content value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$reportMsgRead = $grpc.ClientMethod<$2.MsgRead, $1.Empty>(
      '/msg_friend_service.FriendMsgService/ReportMsgRead',
      ($2.MsgRead value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$ackMsgDelivered = $grpc.ClientMethod<$2.MsgDeliveredAck, $1.Empty>(
      '/msg_friend_service.FriendMsgService/AckMsgDelivered',
      ($2.MsgDeliveredAck value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$ackMsgRead = $grpc.ClientMethod<$2.MsgReadAck, $1.Empty>(
      '/msg_friend_service.FriendMsgService/AckMsgRead',
      ($2.MsgReadAck value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$recallMsg = $grpc.ClientMethod<$2.MsgRecall, $1.Empty>(
      '/msg_friend_service.FriendMsgService/RecallMsg',
      ($2.MsgRecall value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$forwardMsg = $grpc.ClientMethod<$2.MsgForward, $1.Empty>(
      '/msg_friend_service.FriendMsgService/ForwardMsg',
      ($2.MsgForward value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$listFriendMessages = $grpc.ClientMethod<$2.QueryFriendMessagesRequest, $2.QueryMessagesResponse>(
      '/msg_friend_service.FriendMsgService/ListFriendMessages',
      ($2.QueryFriendMessagesRequest value) => value.writeToBuffer(),
      $2.QueryMessagesResponse.fromBuffer);
  static final _$listUserFriendMessages = $grpc.ClientMethod<$0.ListUserFriendMessagesRequest, $2.QueryMessagesResponse>(
      '/msg_friend_service.FriendMsgService/ListUserFriendMessages',
      ($0.ListUserFriendMessagesRequest value) => value.writeToBuffer(),
      $2.QueryMessagesResponse.fromBuffer);
}

@$pb.GrpcServiceName('msg_friend_service.FriendMsgService')
abstract class FriendMsgServiceBase extends $grpc.Service {
  $core.String get $name => 'msg_friend_service.FriendMsgService';

  FriendMsgServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.Content, $1.Empty>(
        'SendMessage',
        sendMessage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Content.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.MsgRead, $1.Empty>(
        'ReportMsgRead',
        reportMsgRead_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.MsgRead.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.MsgDeliveredAck, $1.Empty>(
        'AckMsgDelivered',
        ackMsgDelivered_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.MsgDeliveredAck.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.MsgReadAck, $1.Empty>(
        'AckMsgRead',
        ackMsgRead_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.MsgReadAck.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.MsgRecall, $1.Empty>(
        'RecallMsg',
        recallMsg_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.MsgRecall.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.MsgForward, $1.Empty>(
        'ForwardMsg',
        forwardMsg_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.MsgForward.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.QueryFriendMessagesRequest, $2.QueryMessagesResponse>(
        'ListFriendMessages',
        listFriendMessages_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.QueryFriendMessagesRequest.fromBuffer(value),
        ($2.QueryMessagesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListUserFriendMessagesRequest, $2.QueryMessagesResponse>(
        'ListUserFriendMessages',
        listUserFriendMessages_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListUserFriendMessagesRequest.fromBuffer(value),
        ($2.QueryMessagesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.Empty> sendMessage_Pre($grpc.ServiceCall $call, $async.Future<$2.Content> $request) async {
    return sendMessage($call, await $request);
  }

  $async.Future<$1.Empty> sendMessage($grpc.ServiceCall call, $2.Content request);

  $async.Future<$1.Empty> reportMsgRead_Pre($grpc.ServiceCall $call, $async.Future<$2.MsgRead> $request) async {
    return reportMsgRead($call, await $request);
  }

  $async.Future<$1.Empty> reportMsgRead($grpc.ServiceCall call, $2.MsgRead request);

  $async.Future<$1.Empty> ackMsgDelivered_Pre($grpc.ServiceCall $call, $async.Future<$2.MsgDeliveredAck> $request) async {
    return ackMsgDelivered($call, await $request);
  }

  $async.Future<$1.Empty> ackMsgDelivered($grpc.ServiceCall call, $2.MsgDeliveredAck request);

  $async.Future<$1.Empty> ackMsgRead_Pre($grpc.ServiceCall $call, $async.Future<$2.MsgReadAck> $request) async {
    return ackMsgRead($call, await $request);
  }

  $async.Future<$1.Empty> ackMsgRead($grpc.ServiceCall call, $2.MsgReadAck request);

  $async.Future<$1.Empty> recallMsg_Pre($grpc.ServiceCall $call, $async.Future<$2.MsgRecall> $request) async {
    return recallMsg($call, await $request);
  }

  $async.Future<$1.Empty> recallMsg($grpc.ServiceCall call, $2.MsgRecall request);

  $async.Future<$1.Empty> forwardMsg_Pre($grpc.ServiceCall $call, $async.Future<$2.MsgForward> $request) async {
    return forwardMsg($call, await $request);
  }

  $async.Future<$1.Empty> forwardMsg($grpc.ServiceCall call, $2.MsgForward request);

  $async.Future<$2.QueryMessagesResponse> listFriendMessages_Pre($grpc.ServiceCall $call, $async.Future<$2.QueryFriendMessagesRequest> $request) async {
    return listFriendMessages($call, await $request);
  }

  $async.Future<$2.QueryMessagesResponse> listFriendMessages($grpc.ServiceCall call, $2.QueryFriendMessagesRequest request);

  $async.Future<$2.QueryMessagesResponse> listUserFriendMessages_Pre($grpc.ServiceCall $call, $async.Future<$0.ListUserFriendMessagesRequest> $request) async {
    return listUserFriendMessages($call, await $request);
  }

  $async.Future<$2.QueryMessagesResponse> listUserFriendMessages($grpc.ServiceCall call, $0.ListUserFriendMessagesRequest request);

}
/// 设备密钥服务
@$pb.GrpcServiceName('msg_friend_service.KeyService')
class KeyServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  KeyServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.UploadDeviceKeysResponse> uploadDeviceKeys($0.UploadDeviceKeysRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$uploadDeviceKeys, request, options: options);
  }

  $grpc.ResponseFuture<$0.FetchDeviceKeysResponse> fetchDeviceKeys($0.FetchDeviceKeysRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$fetchDeviceKeys, request, options: options);
  }

    // method descriptors

  static final _$uploadDeviceKeys = $grpc.ClientMethod<$0.UploadDeviceKeysRequest, $0.UploadDeviceKeysResponse>(
      '/msg_friend_service.KeyService/UploadDeviceKeys',
      ($0.UploadDeviceKeysRequest value) => value.writeToBuffer(),
      $0.UploadDeviceKeysResponse.fromBuffer);
  static final _$fetchDeviceKeys = $grpc.ClientMethod<$0.FetchDeviceKeysRequest, $0.FetchDeviceKeysResponse>(
      '/msg_friend_service.KeyService/FetchDeviceKeys',
      ($0.FetchDeviceKeysRequest value) => value.writeToBuffer(),
      $0.FetchDeviceKeysResponse.fromBuffer);
}

@$pb.GrpcServiceName('msg_friend_service.KeyService')
abstract class KeyServiceBase extends $grpc.Service {
  $core.String get $name => 'msg_friend_service.KeyService';

  KeyServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.UploadDeviceKeysRequest, $0.UploadDeviceKeysResponse>(
        'UploadDeviceKeys',
        uploadDeviceKeys_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UploadDeviceKeysRequest.fromBuffer(value),
        ($0.UploadDeviceKeysResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FetchDeviceKeysRequest, $0.FetchDeviceKeysResponse>(
        'FetchDeviceKeys',
        fetchDeviceKeys_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FetchDeviceKeysRequest.fromBuffer(value),
        ($0.FetchDeviceKeysResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.UploadDeviceKeysResponse> uploadDeviceKeys_Pre($grpc.ServiceCall $call, $async.Future<$0.UploadDeviceKeysRequest> $request) async {
    return uploadDeviceKeys($call, await $request);
  }

  $async.Future<$0.UploadDeviceKeysResponse> uploadDeviceKeys($grpc.ServiceCall call, $0.UploadDeviceKeysRequest request);

  $async.Future<$0.FetchDeviceKeysResponse> fetchDeviceKeys_Pre($grpc.ServiceCall $call, $async.Future<$0.FetchDeviceKeysRequest> $request) async {
    return fetchDeviceKeys($call, await $request);
  }

  $async.Future<$0.FetchDeviceKeysResponse> fetchDeviceKeys($grpc.ServiceCall call, $0.FetchDeviceKeysRequest request);

}
