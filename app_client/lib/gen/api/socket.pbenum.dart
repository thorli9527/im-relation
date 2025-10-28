// This is a generated file - do not edit.
//
// Generated from socket.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 设备类型：用于多端登录策略控制
class DeviceType extends $pb.ProtobufEnum {
  static const DeviceType UNKNOWN = DeviceType._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const DeviceType MOBILE = DeviceType._(1, _omitEnumNames ? '' : 'MOBILE');
  static const DeviceType WEB = DeviceType._(3, _omitEnumNames ? '' : 'WEB');
  static const DeviceType PC = DeviceType._(4, _omitEnumNames ? '' : 'PC');

  static const $core.List<DeviceType> values = <DeviceType> [
    UNKNOWN,
    MOBILE,
    WEB,
    PC,
  ];

  static final $core.List<DeviceType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static DeviceType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DeviceType._(super.value, super.name);
}

/// 业务种类：与历史 kind 字符串一一对应
/// - 建议所有生产者/消费者/客户端统一使用该枚举
class MsgKind extends $pb.ProtobufEnum {
  /// 原 "unknown"
  static const MsgKind MK_UNKNOWN = MsgKind._(0, _omitEnumNames ? '' : 'MK_UNKNOWN');
  /// 好友消息
  ///  原 "chat.new"
  static const MsgKind MK_FRIEND = MsgKind._(100, _omitEnumNames ? '' : 'MK_FRIEND');
  /// 好友消息已读回执
  ///  原 "chat.msg_read_ack"
  static const MsgKind MK_FRIEND_MSG_READ_ACK = MsgKind._(101, _omitEnumNames ? '' : 'MK_FRIEND_MSG_READ_ACK');
  /// 好友消息撤回
  ///  原 "chat.msg_recall"
  static const MsgKind MK_FRIEND_MSG_RECALL = MsgKind._(102, _omitEnumNames ? '' : 'MK_FRIEND_MSG_RECALL');
  /// 好友消息已送达回执
  ///  原 "chat.msg_delivered_ack"
  static const MsgKind MK_FRIEND_MSG_DELIVERED_ACK = MsgKind._(103, _omitEnumNames ? '' : 'MK_FRIEND_MSG_DELIVERED_ACK');
  /// 好友消息已读回执
  ///  原 "chat.msg_read"
  static const MsgKind MK_FRIEND_MSG_READ = MsgKind._(104, _omitEnumNames ? '' : 'MK_FRIEND_MSG_READ');
  /// 好友消息已送达回执
  ///  原 "chat.msg_delivered
  static const MsgKind MK_FRIEND_MSG_DELIVERED = MsgKind._(105, _omitEnumNames ? '' : 'MK_FRIEND_MSG_DELIVERED');
  /// 好友消息转发
  ///  原 "chat.msg_forward"
  static const MsgKind MK_FRIEND_MSG_FORWARD = MsgKind._(106, _omitEnumNames ? '' : 'MK_FRIEND_MSG_FORWARD');
  /// 好友消息修改
  ///  原 "chat.msg_edit"
  static const MsgKind MK_FRIEND_MSG_EDIT = MsgKind._(107, _omitEnumNames ? '' : 'MK_FRIEND_MSG_EDIT');
  /// 好友消息撤回
  ///  原 "chat.msg_reaction"
  static const MsgKind MK_FRIEND_MSG_REACTION = MsgKind._(108, _omitEnumNames ? '' : 'MK_FRIEND_MSG_REACTION');
  /// 好友正在输入
  ///  原 "chat.typing"
  static const MsgKind MK_FRIEND_TYPING = MsgKind._(109, _omitEnumNames ? '' : 'MK_FRIEND_TYPING');
  /// 好友发启语音/视频通话
  ///  原 "call.invite"
  static const MsgKind MK_FRIEND_CALL_INVITE = MsgKind._(150, _omitEnumNames ? '' : 'MK_FRIEND_CALL_INVITE');
  /// 好友取消语音/视频通话
  ///  原 "call.cancel"
  static const MsgKind MK_FRIEND_CALL_CANCEL = MsgKind._(151, _omitEnumNames ? '' : 'MK_FRIEND_CALL_CANCEL');
  /// 好友拒绝语音/视频通话
  ///  原 "call.reject"
  static const MsgKind MK_FRIEND_CALL_REJECT = MsgKind._(152, _omitEnumNames ? '' : 'MK_FRIEND_CALL_REJECT');
  /// 好友接听语音/视频通话
  ///  原 "call.accept"
  static const MsgKind MK_FRIEND_CALL_ACCEPT = MsgKind._(153, _omitEnumNames ? '' : 'MK_FRIEND_CALL_ACCEPT');
  /// 好友结束语音/视频通话
  ///  原 "call.hangup"
  static const MsgKind MK_FRIEND_CALL_HANGUP = MsgKind._(154, _omitEnumNames ? '' : 'MK_FRIEND_CALL_HANGUP');
  /// 好友通话中更新
  ///  原 "call.modify"
  static const MsgKind MK_FRIEND_CALL_MODIFY = MsgKind._(155, _omitEnumNames ? '' : 'MK_FRIEND_CALL_MODIFY');
  /// 好友通话中DTMF
  ///  原 "call.dtmf"
  static const MsgKind MK_FRIEND_CALL_DTMF = MsgKind._(156, _omitEnumNames ? '' : 'MK_FRIEND_CALL_DTMF');
  /// 好友申请
  ///  原 "chat.request"
  static const MsgKind MK_FRIEND_REQUEST = MsgKind._(201, _omitEnumNames ? '' : 'MK_FRIEND_REQUEST');
  /// 好友申请受理
  ///  原 "chat.request_ack"
  static const MsgKind MK_FRIEND_REQUEST_ACK = MsgKind._(202, _omitEnumNames ? '' : 'MK_FRIEND_REQUEST_ACK');
  /// 好友申请拒绝
  ///  原 "chat.request_reject"
  static const MsgKind MK_FRIEND_REQUEST_REJECT = MsgKind._(203, _omitEnumNames ? '' : 'MK_FRIEND_REQUEST_REJECT');
  /// 好友删除
  ///  原 "chat.delete"
  static const MsgKind MK_FRIEND_DELETE = MsgKind._(204, _omitEnumNames ? '' : 'MK_FRIEND_DELETE');
  /// 更新好友名称
  ///  原 "chat.update_remark"
  static const MsgKind MK_FRIEND_UPDATE_REMARK = MsgKind._(205, _omitEnumNames ? '' : 'MK_FRIEND_UPDATE_REMARK');
  /// 群消息
  ///  原 "group.new"
  static const MsgKind MK_GROUP = MsgKind._(300, _omitEnumNames ? '' : 'MK_GROUP');
  /// 群消息已读回执
  ///  原 "group.msg_read_ack"
  static const MsgKind MK_GROUP_MSG_READ_ACK = MsgKind._(301, _omitEnumNames ? '' : 'MK_GROUP_MSG_READ_ACK');
  /// 群消息撤回
  ///  原 "group.msg_recall"
  static const MsgKind MK_GROUP_MSG_RECALL = MsgKind._(302, _omitEnumNames ? '' : 'MK_GROUP_MSG_RECALL');
  /// 群消息已读回执
  ///  原 "group.at_all"
  static const MsgKind MK_GROUP_AT_ALL = MsgKind._(303, _omitEnumNames ? '' : 'MK_GROUP_AT_ALL');
  /// 群消息@用户
  ///  原 "group.at_user"
  static const MsgKind MK_GROUP_AT_USER = MsgKind._(304, _omitEnumNames ? '' : 'MK_GROUP_AT_USER');
  /// 群消息修改
  ///  原 "group.msg_edit"
  static const MsgKind MK_GROUP_MSG_EDIT = MsgKind._(305, _omitEnumNames ? '' : 'MK_GROUP_MSG_EDIT');
  /// 群消息撤回
  ///  原 "group.msg_reaction"
  static const MsgKind MK_GROUP_MSG_REACTION = MsgKind._(306, _omitEnumNames ? '' : 'MK_GROUP_MSG_REACTION');
  /// 群消息已送达回执
  ///  原 "group.msg_delivered"
  static const MsgKind MK_GROUP_MSG_DELIVERED = MsgKind._(307, _omitEnumNames ? '' : 'MK_GROUP_MSG_DELIVERED');
  /// 群消息已送达回执
  ///  原 "group.msg_delivered_ack"
  static const MsgKind MK_GROUP_MSG_DELIVERED_ACK = MsgKind._(308, _omitEnumNames ? '' : 'MK_GROUP_MSG_DELIVERED_ACK');
  /// 群消息已读回执
  ///  原 "group.msg_read"
  static const MsgKind MK_GROUP_MSG_READ = MsgKind._(309, _omitEnumNames ? '' : 'MK_GROUP_MSG_READ');
  /// 群正在输入
  static const MsgKind MK_GROUP_TYPING = MsgKind._(312, _omitEnumNames ? '' : 'MK_GROUP_TYPING');
  /// 申请加群
  ///  原 "group.join_request"
  static const MsgKind MK_GROUP_JOIN_REQUEST = MsgKind._(401, _omitEnumNames ? '' : 'MK_GROUP_JOIN_REQUEST');
  /// 加群申请受理
  ///  原 "group.join_request_ack"
  static const MsgKind MK_GROUP_JOIN_REQUEST_ACK = MsgKind._(402, _omitEnumNames ? '' : 'MK_GROUP_JOIN_REQUEST_ACK');
  /// 群更新名称
  ///  原 "group.update_name"
  static const MsgKind MK_GROUP_UPDATE_NAME = MsgKind._(403, _omitEnumNames ? '' : 'MK_GROUP_UPDATE_NAME');
  /// 群更新公告
  ///  原 "group.update_announcement"
  static const MsgKind MK_GROUP_UPDATE_ANNOUNCEMENT = MsgKind._(404, _omitEnumNames ? '' : 'MK_GROUP_UPDATE_ANNOUNCEMENT');
  /// 群更新头像
  ///  原 "group.update_avatar"
  static const MsgKind MK_GROUP_UPDATE_AVATAR = MsgKind._(405, _omitEnumNames ? '' : 'MK_GROUP_UPDATE_AVATAR');
  /// 群成员增加
  ///  原 "group.member_add"
  static const MsgKind MK_GROUP_MEMBER_ADD = MsgKind._(406, _omitEnumNames ? '' : 'MK_GROUP_MEMBER_ADD');
  /// 群成员删除
  ///  原 "group.member_delete"
  static const MsgKind MK_GROUP_MEMBER_DELETE = MsgKind._(407, _omitEnumNames ? '' : 'MK_GROUP_MEMBER_DELETE');
  /// 群成员退出
  ///  原 "group.member_quit"
  static const MsgKind MK_GROUP_MEMBER_QUIT = MsgKind._(408, _omitEnumNames ? '' : 'MK_GROUP_MEMBER_QUIT');
  /// 群成员更新
  ///  原 "group.member_update"
  static const MsgKind MK_GROUP_MEMBER_UPDATE = MsgKind._(409, _omitEnumNames ? '' : 'MK_GROUP_MEMBER_UPDATE');
  /// 解散群
  ///  原 "group.dismiss"
  static const MsgKind MK_GROUP_DISMISS = MsgKind._(410, _omitEnumNames ? '' : 'MK_GROUP_DISMISS');
  /// 转让群主
  ///  原 "group.transfer"
  static const MsgKind MK_GROUP_TRANSFER = MsgKind._(411, _omitEnumNames ? '' : 'MK_GROUP_TRANSFER');
  /// 系统通知
  ///  原 "sys.notice"
  static const MsgKind MK_SYS_NOTICE = MsgKind._(900, _omitEnumNames ? '' : 'MK_SYS_NOTICE');
  /// 用户在线状态变更
  ///  原 "user.presence"
  static const MsgKind MK_USER_PRESENCE = MsgKind._(901, _omitEnumNames ? '' : 'MK_USER_PRESENCE');
  /// 用户资料更新
  ///  原 "user.profile_update"
  static const MsgKind MK_USER_PROFILE_UPDATE = MsgKind._(902, _omitEnumNames ? '' : 'MK_USER_PROFILE_UPDATE');
  /// 用户隐私设置更新
  ///  原 "user.privacy_update"
  static const MsgKind MK_USER_PRIVACY_UPDATE = MsgKind._(903, _omitEnumNames ? '' : 'MK_USER_PRIVACY_UPDATE');
  /// 用户账号数据变更
  ///  原 "user.account_data"
  static const MsgKind MK_USER_ACCOUNT_DATA = MsgKind._(904, _omitEnumNames ? '' : 'MK_USER_ACCOUNT_DATA');
  /// 消息撤回
  ///  原 "msg.recall"
  static const MsgKind MK_MSG_RECALL = MsgKind._(905, _omitEnumNames ? '' : 'MK_MSG_RECALL');
  /// 通用业务ACK
  ///  原 "sys.ack"
  static const MsgKind MK_ACK = MsgKind._(906, _omitEnumNames ? '' : 'MK_ACK');
  /// 心跳保活
  static const MsgKind MK_HEARTBEAT = MsgKind._(907, _omitEnumNames ? '' : 'MK_HEARTBEAT');

  static const $core.List<MsgKind> values = <MsgKind> [
    MK_UNKNOWN,
    MK_FRIEND,
    MK_FRIEND_MSG_READ_ACK,
    MK_FRIEND_MSG_RECALL,
    MK_FRIEND_MSG_DELIVERED_ACK,
    MK_FRIEND_MSG_READ,
    MK_FRIEND_MSG_DELIVERED,
    MK_FRIEND_MSG_FORWARD,
    MK_FRIEND_MSG_EDIT,
    MK_FRIEND_MSG_REACTION,
    MK_FRIEND_TYPING,
    MK_FRIEND_CALL_INVITE,
    MK_FRIEND_CALL_CANCEL,
    MK_FRIEND_CALL_REJECT,
    MK_FRIEND_CALL_ACCEPT,
    MK_FRIEND_CALL_HANGUP,
    MK_FRIEND_CALL_MODIFY,
    MK_FRIEND_CALL_DTMF,
    MK_FRIEND_REQUEST,
    MK_FRIEND_REQUEST_ACK,
    MK_FRIEND_REQUEST_REJECT,
    MK_FRIEND_DELETE,
    MK_FRIEND_UPDATE_REMARK,
    MK_GROUP,
    MK_GROUP_MSG_READ_ACK,
    MK_GROUP_MSG_RECALL,
    MK_GROUP_AT_ALL,
    MK_GROUP_AT_USER,
    MK_GROUP_MSG_EDIT,
    MK_GROUP_MSG_REACTION,
    MK_GROUP_MSG_DELIVERED,
    MK_GROUP_MSG_DELIVERED_ACK,
    MK_GROUP_MSG_READ,
    MK_GROUP_TYPING,
    MK_GROUP_JOIN_REQUEST,
    MK_GROUP_JOIN_REQUEST_ACK,
    MK_GROUP_UPDATE_NAME,
    MK_GROUP_UPDATE_ANNOUNCEMENT,
    MK_GROUP_UPDATE_AVATAR,
    MK_GROUP_MEMBER_ADD,
    MK_GROUP_MEMBER_DELETE,
    MK_GROUP_MEMBER_QUIT,
    MK_GROUP_MEMBER_UPDATE,
    MK_GROUP_DISMISS,
    MK_GROUP_TRANSFER,
    MK_SYS_NOTICE,
    MK_USER_PRESENCE,
    MK_USER_PROFILE_UPDATE,
    MK_USER_PRIVACY_UPDATE,
    MK_USER_ACCOUNT_DATA,
    MK_MSG_RECALL,
    MK_ACK,
    MK_HEARTBEAT,
  ];

  static final $core.Map<$core.int, MsgKind> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MsgKind? valueOf($core.int value) => _byValue[value];

  const MsgKind._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
