// This is a generated file - do not edit.
//
// Generated from msg_group.proto.

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
import 'msg_group.pb.dart' as $0;

export 'msg_group.pb.dart';

/// -----------------------------------------------------------------------------
/// 群业务编排服务（Biz）
/// - 所有写操作需鉴权与权限校验；返回 Empty 表示仅代表“受理成功”或“无返回体”的成功；
/// - 失败返回标准 gRPC 错误码（如 INVALID_ARGUMENT / PERMISSION_DENIED / NOT_FOUND / ALREADY_EXISTS）；
/// -----------------------------------------------------------------------------
@$pb.GrpcServiceName('msg_group_service.GroupBizService')
class GroupBizServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  GroupBizServiceClient(super.channel, {super.options, super.interceptors});

  /// 创建群（幂等：可用 creator_id+name+时间窗 去重）
  $grpc.ResponseFuture<$0.CreateGroupResp> createGroup($0.CreateGroupReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$createGroup, request, options: options);
  }

  /// 更新群资料（需 OWNER/ADMIN 权限）
  $grpc.ResponseFuture<$1.Empty> updateGroupProfile($0.UpdateGroupProfileReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$updateGroupProfile, request, options: options);
  }

  /// 解散群（仅群主；解散后不可恢复）
  $grpc.ResponseFuture<$1.Empty> dismissGroup($0.DismissGroupReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$dismissGroup, request, options: options);
  }

  /// 申请/邀请入群（根据 JoinPermission 与 inviter_* 分支处理）
  $grpc.ResponseFuture<$1.Empty> joinGroup($0.JoinGroupReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$joinGroup, request, options: options);
  }

  /// 主动退群（群主需先转让）
  $grpc.ResponseFuture<$1.Empty> leaveGroup($0.LeaveGroupReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$leaveGroup, request, options: options);
  }

  /// 审批入群（OWNER/ADMIN）
  $grpc.ResponseFuture<$1.Empty> approveJoin($0.ApproveJoinReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$approveJoin, request, options: options);
  }

  /// 邀请成员（OWNER/ADMIN，或成员在 INVITE_ONLY 策略下具备的邀请权）
  $grpc.ResponseFuture<$1.Empty> inviteMembers($0.InviteMembersReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$inviteMembers, request, options: options);
  }

  /// 踢出成员（OWNER/ADMIN）
  $grpc.ResponseFuture<$1.Empty> kickMember($0.KickMemberReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$kickMember, request, options: options);
  }

  /// 更新群内别名（自改或管理员改）
  $grpc.ResponseFuture<$1.Empty> updateMemberAlias($0.UpdateMemberAliasReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$updateMemberAlias, request, options: options);
  }

  /// 调整角色（仅群主；升级/降级）
  $grpc.ResponseFuture<$1.Empty> changeMemberRole($0.ChangeMemberRoleReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$changeMemberRole, request, options: options);
  }

  /// 查询群资料（含成员数、权限等）
  $grpc.ResponseFuture<$0.GroupInfo> getGroup($0.GetGroupReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$getGroup, request, options: options);
  }

  /// 分页查询群成员（轻量列表）
  $grpc.ResponseFuture<$0.GetMembersResp> getMembers($0.GetMembersReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$getMembers, request, options: options);
  }

  /// 成员数量统计（强一致/准实时，取决于实现）
  $grpc.ResponseFuture<$0.CountMembersResp> countMembers($0.CountMembersReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$countMembers, request, options: options);
  }

  /// 查询用户参与的群 ID 列表
  $grpc.ResponseFuture<$0.UserGroupsResp> userGroups($0.UserGroupsReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$userGroups, request, options: options);
  }

    // method descriptors

  static final _$createGroup = $grpc.ClientMethod<$0.CreateGroupReq, $0.CreateGroupResp>(
      '/msg_group_service.GroupBizService/CreateGroup',
      ($0.CreateGroupReq value) => value.writeToBuffer(),
      $0.CreateGroupResp.fromBuffer);
  static final _$updateGroupProfile = $grpc.ClientMethod<$0.UpdateGroupProfileReq, $1.Empty>(
      '/msg_group_service.GroupBizService/UpdateGroupProfile',
      ($0.UpdateGroupProfileReq value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$dismissGroup = $grpc.ClientMethod<$0.DismissGroupReq, $1.Empty>(
      '/msg_group_service.GroupBizService/DismissGroup',
      ($0.DismissGroupReq value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$joinGroup = $grpc.ClientMethod<$0.JoinGroupReq, $1.Empty>(
      '/msg_group_service.GroupBizService/JoinGroup',
      ($0.JoinGroupReq value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$leaveGroup = $grpc.ClientMethod<$0.LeaveGroupReq, $1.Empty>(
      '/msg_group_service.GroupBizService/LeaveGroup',
      ($0.LeaveGroupReq value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$approveJoin = $grpc.ClientMethod<$0.ApproveJoinReq, $1.Empty>(
      '/msg_group_service.GroupBizService/ApproveJoin',
      ($0.ApproveJoinReq value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$inviteMembers = $grpc.ClientMethod<$0.InviteMembersReq, $1.Empty>(
      '/msg_group_service.GroupBizService/InviteMembers',
      ($0.InviteMembersReq value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$kickMember = $grpc.ClientMethod<$0.KickMemberReq, $1.Empty>(
      '/msg_group_service.GroupBizService/KickMember',
      ($0.KickMemberReq value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$updateMemberAlias = $grpc.ClientMethod<$0.UpdateMemberAliasReq, $1.Empty>(
      '/msg_group_service.GroupBizService/UpdateMemberAlias',
      ($0.UpdateMemberAliasReq value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$changeMemberRole = $grpc.ClientMethod<$0.ChangeMemberRoleReq, $1.Empty>(
      '/msg_group_service.GroupBizService/ChangeMemberRole',
      ($0.ChangeMemberRoleReq value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$getGroup = $grpc.ClientMethod<$0.GetGroupReq, $0.GroupInfo>(
      '/msg_group_service.GroupBizService/GetGroup',
      ($0.GetGroupReq value) => value.writeToBuffer(),
      $0.GroupInfo.fromBuffer);
  static final _$getMembers = $grpc.ClientMethod<$0.GetMembersReq, $0.GetMembersResp>(
      '/msg_group_service.GroupBizService/GetMembers',
      ($0.GetMembersReq value) => value.writeToBuffer(),
      $0.GetMembersResp.fromBuffer);
  static final _$countMembers = $grpc.ClientMethod<$0.CountMembersReq, $0.CountMembersResp>(
      '/msg_group_service.GroupBizService/CountMembers',
      ($0.CountMembersReq value) => value.writeToBuffer(),
      $0.CountMembersResp.fromBuffer);
  static final _$userGroups = $grpc.ClientMethod<$0.UserGroupsReq, $0.UserGroupsResp>(
      '/msg_group_service.GroupBizService/UserGroups',
      ($0.UserGroupsReq value) => value.writeToBuffer(),
      $0.UserGroupsResp.fromBuffer);
}

@$pb.GrpcServiceName('msg_group_service.GroupBizService')
abstract class GroupBizServiceBase extends $grpc.Service {
  $core.String get $name => 'msg_group_service.GroupBizService';

  GroupBizServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateGroupReq, $0.CreateGroupResp>(
        'CreateGroup',
        createGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateGroupReq.fromBuffer(value),
        ($0.CreateGroupResp value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateGroupProfileReq, $1.Empty>(
        'UpdateGroupProfile',
        updateGroupProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateGroupProfileReq.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DismissGroupReq, $1.Empty>(
        'DismissGroup',
        dismissGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DismissGroupReq.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.JoinGroupReq, $1.Empty>(
        'JoinGroup',
        joinGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.JoinGroupReq.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LeaveGroupReq, $1.Empty>(
        'LeaveGroup',
        leaveGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LeaveGroupReq.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ApproveJoinReq, $1.Empty>(
        'ApproveJoin',
        approveJoin_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ApproveJoinReq.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.InviteMembersReq, $1.Empty>(
        'InviteMembers',
        inviteMembers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.InviteMembersReq.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.KickMemberReq, $1.Empty>(
        'KickMember',
        kickMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.KickMemberReq.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateMemberAliasReq, $1.Empty>(
        'UpdateMemberAlias',
        updateMemberAlias_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateMemberAliasReq.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeMemberRoleReq, $1.Empty>(
        'ChangeMemberRole',
        changeMemberRole_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChangeMemberRoleReq.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGroupReq, $0.GroupInfo>(
        'GetGroup',
        getGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetGroupReq.fromBuffer(value),
        ($0.GroupInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetMembersReq, $0.GetMembersResp>(
        'GetMembers',
        getMembers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetMembersReq.fromBuffer(value),
        ($0.GetMembersResp value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CountMembersReq, $0.CountMembersResp>(
        'CountMembers',
        countMembers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CountMembersReq.fromBuffer(value),
        ($0.CountMembersResp value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UserGroupsReq, $0.UserGroupsResp>(
        'UserGroups',
        userGroups_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UserGroupsReq.fromBuffer(value),
        ($0.UserGroupsResp value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateGroupResp> createGroup_Pre($grpc.ServiceCall $call, $async.Future<$0.CreateGroupReq> $request) async {
    return createGroup($call, await $request);
  }

  $async.Future<$0.CreateGroupResp> createGroup($grpc.ServiceCall call, $0.CreateGroupReq request);

  $async.Future<$1.Empty> updateGroupProfile_Pre($grpc.ServiceCall $call, $async.Future<$0.UpdateGroupProfileReq> $request) async {
    return updateGroupProfile($call, await $request);
  }

  $async.Future<$1.Empty> updateGroupProfile($grpc.ServiceCall call, $0.UpdateGroupProfileReq request);

  $async.Future<$1.Empty> dismissGroup_Pre($grpc.ServiceCall $call, $async.Future<$0.DismissGroupReq> $request) async {
    return dismissGroup($call, await $request);
  }

  $async.Future<$1.Empty> dismissGroup($grpc.ServiceCall call, $0.DismissGroupReq request);

  $async.Future<$1.Empty> joinGroup_Pre($grpc.ServiceCall $call, $async.Future<$0.JoinGroupReq> $request) async {
    return joinGroup($call, await $request);
  }

  $async.Future<$1.Empty> joinGroup($grpc.ServiceCall call, $0.JoinGroupReq request);

  $async.Future<$1.Empty> leaveGroup_Pre($grpc.ServiceCall $call, $async.Future<$0.LeaveGroupReq> $request) async {
    return leaveGroup($call, await $request);
  }

  $async.Future<$1.Empty> leaveGroup($grpc.ServiceCall call, $0.LeaveGroupReq request);

  $async.Future<$1.Empty> approveJoin_Pre($grpc.ServiceCall $call, $async.Future<$0.ApproveJoinReq> $request) async {
    return approveJoin($call, await $request);
  }

  $async.Future<$1.Empty> approveJoin($grpc.ServiceCall call, $0.ApproveJoinReq request);

  $async.Future<$1.Empty> inviteMembers_Pre($grpc.ServiceCall $call, $async.Future<$0.InviteMembersReq> $request) async {
    return inviteMembers($call, await $request);
  }

  $async.Future<$1.Empty> inviteMembers($grpc.ServiceCall call, $0.InviteMembersReq request);

  $async.Future<$1.Empty> kickMember_Pre($grpc.ServiceCall $call, $async.Future<$0.KickMemberReq> $request) async {
    return kickMember($call, await $request);
  }

  $async.Future<$1.Empty> kickMember($grpc.ServiceCall call, $0.KickMemberReq request);

  $async.Future<$1.Empty> updateMemberAlias_Pre($grpc.ServiceCall $call, $async.Future<$0.UpdateMemberAliasReq> $request) async {
    return updateMemberAlias($call, await $request);
  }

  $async.Future<$1.Empty> updateMemberAlias($grpc.ServiceCall call, $0.UpdateMemberAliasReq request);

  $async.Future<$1.Empty> changeMemberRole_Pre($grpc.ServiceCall $call, $async.Future<$0.ChangeMemberRoleReq> $request) async {
    return changeMemberRole($call, await $request);
  }

  $async.Future<$1.Empty> changeMemberRole($grpc.ServiceCall call, $0.ChangeMemberRoleReq request);

  $async.Future<$0.GroupInfo> getGroup_Pre($grpc.ServiceCall $call, $async.Future<$0.GetGroupReq> $request) async {
    return getGroup($call, await $request);
  }

  $async.Future<$0.GroupInfo> getGroup($grpc.ServiceCall call, $0.GetGroupReq request);

  $async.Future<$0.GetMembersResp> getMembers_Pre($grpc.ServiceCall $call, $async.Future<$0.GetMembersReq> $request) async {
    return getMembers($call, await $request);
  }

  $async.Future<$0.GetMembersResp> getMembers($grpc.ServiceCall call, $0.GetMembersReq request);

  $async.Future<$0.CountMembersResp> countMembers_Pre($grpc.ServiceCall $call, $async.Future<$0.CountMembersReq> $request) async {
    return countMembers($call, await $request);
  }

  $async.Future<$0.CountMembersResp> countMembers($grpc.ServiceCall call, $0.CountMembersReq request);

  $async.Future<$0.UserGroupsResp> userGroups_Pre($grpc.ServiceCall $call, $async.Future<$0.UserGroupsReq> $request) async {
    return userGroups($call, await $request);
  }

  $async.Future<$0.UserGroupsResp> userGroups($grpc.ServiceCall call, $0.UserGroupsReq request);

}
/// -----------------------------------------------------------------------------
/// 群消息服务（Msg）
/// - SendMessage 仅负责写入/透传 socket；服务端应追加服务端时间与顺序号；
/// - 回执接口用于可靠送达/已读链路，便于状态回放与多端同步；
/// -----------------------------------------------------------------------------
@$pb.GrpcServiceName('msg_group_service.GroupMsgService')
class GroupMsgServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  GroupMsgServiceClient(super.channel, {super.options, super.interceptors});

  /// 发送群消息（幂等：建议按 sender_id + client_msg_id/message_id 去重）
  $grpc.ResponseFuture<$1.Empty> sendMessage($2.Content request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$sendMessage, request, options: options);
  }

  /// 上报已读（用户读到某消息，服务端可折叠成“读到 N”）
  $grpc.ResponseFuture<$1.Empty> reportMsgRead($2.MsgRead request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$reportMsgRead, request, options: options);
  }

  /// 已送达回执（网络层/客户端确认）
  $grpc.ResponseFuture<$1.Empty> ackMsgDelivered($2.MsgDeliveredAck request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$ackMsgDelivered, request, options: options);
  }

  /// 已读回执确认（对已读的二次确认，用于多端同步）
  $grpc.ResponseFuture<$1.Empty> ackMsgRead($2.MsgReadAck request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$ackMsgRead, request, options: options);
  }

  /// 撤回消息（权限校验）
  $grpc.ResponseFuture<$1.Empty> recallMsg($2.MsgRecall request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$recallMsg, request, options: options);
  }

  /// 转发消息（可能跨会话/跨群）
  $grpc.ResponseFuture<$1.Empty> forwardMsg($2.MsgForward request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$forwardMsg, request, options: options);
  }

  /// 分页查询群聊历史消息
  $grpc.ResponseFuture<$2.QueryMessagesResponse> listGroupMessages($2.QueryGroupMessagesRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$listGroupMessages, request, options: options);
  }

    // method descriptors

  static final _$sendMessage = $grpc.ClientMethod<$2.Content, $1.Empty>(
      '/msg_group_service.GroupMsgService/SendMessage',
      ($2.Content value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$reportMsgRead = $grpc.ClientMethod<$2.MsgRead, $1.Empty>(
      '/msg_group_service.GroupMsgService/ReportMsgRead',
      ($2.MsgRead value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$ackMsgDelivered = $grpc.ClientMethod<$2.MsgDeliveredAck, $1.Empty>(
      '/msg_group_service.GroupMsgService/AckMsgDelivered',
      ($2.MsgDeliveredAck value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$ackMsgRead = $grpc.ClientMethod<$2.MsgReadAck, $1.Empty>(
      '/msg_group_service.GroupMsgService/AckMsgRead',
      ($2.MsgReadAck value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$recallMsg = $grpc.ClientMethod<$2.MsgRecall, $1.Empty>(
      '/msg_group_service.GroupMsgService/RecallMsg',
      ($2.MsgRecall value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$forwardMsg = $grpc.ClientMethod<$2.MsgForward, $1.Empty>(
      '/msg_group_service.GroupMsgService/ForwardMsg',
      ($2.MsgForward value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$listGroupMessages = $grpc.ClientMethod<$2.QueryGroupMessagesRequest, $2.QueryMessagesResponse>(
      '/msg_group_service.GroupMsgService/ListGroupMessages',
      ($2.QueryGroupMessagesRequest value) => value.writeToBuffer(),
      $2.QueryMessagesResponse.fromBuffer);
}

@$pb.GrpcServiceName('msg_group_service.GroupMsgService')
abstract class GroupMsgServiceBase extends $grpc.Service {
  $core.String get $name => 'msg_group_service.GroupMsgService';

  GroupMsgServiceBase() {
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
    $addMethod($grpc.ServiceMethod<$2.QueryGroupMessagesRequest, $2.QueryMessagesResponse>(
        'ListGroupMessages',
        listGroupMessages_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.QueryGroupMessagesRequest.fromBuffer(value),
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

  $async.Future<$2.QueryMessagesResponse> listGroupMessages_Pre($grpc.ServiceCall $call, $async.Future<$2.QueryGroupMessagesRequest> $request) async {
    return listGroupMessages($call, await $request);
  }

  $async.Future<$2.QueryMessagesResponse> listGroupMessages($grpc.ServiceCall call, $2.QueryGroupMessagesRequest request);

}
