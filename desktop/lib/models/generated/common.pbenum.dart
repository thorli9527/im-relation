// This is a generated file - do not edit.
//
// Generated from common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// *
///  群成员角色类型
class GroupRoleType extends $pb.ProtobufEnum {
  static const GroupRoleType OWNER = GroupRoleType._(0, _omitEnumNames ? '' : 'OWNER');
  static const GroupRoleType ADMIN = GroupRoleType._(1, _omitEnumNames ? '' : 'ADMIN');
  static const GroupRoleType MEMBER = GroupRoleType._(2, _omitEnumNames ? '' : 'MEMBER');

  static const $core.List<GroupRoleType> values = <GroupRoleType> [
    OWNER,
    ADMIN,
    MEMBER,
  ];

  static final $core.List<GroupRoleType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static GroupRoleType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GroupRoleType._(super.value, super.name);
}

/// *
///  加群权限控制类型
class JoinPermission extends $pb.ProtobufEnum {
  static const JoinPermission ANYONE = JoinPermission._(0, _omitEnumNames ? '' : 'ANYONE');
  static const JoinPermission NEED_APPROVAL = JoinPermission._(1, _omitEnumNames ? '' : 'NEED_APPROVAL');
  static const JoinPermission INVITE_ONLY = JoinPermission._(2, _omitEnumNames ? '' : 'INVITE_ONLY');
  static const JoinPermission CLOSED = JoinPermission._(3, _omitEnumNames ? '' : 'CLOSED');

  static const $core.List<JoinPermission> values = <JoinPermission> [
    ANYONE,
    NEED_APPROVAL,
    INVITE_ONLY,
    CLOSED,
  ];

  static final $core.List<JoinPermission?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static JoinPermission? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const JoinPermission._(super.value, super.name);
}

/// *
///  加群验证类型
class JoinQuestionType extends $pb.ProtobufEnum {
  static const JoinQuestionType NONE = JoinQuestionType._(0, _omitEnumNames ? '' : 'NONE');
  static const JoinQuestionType QUESTION = JoinQuestionType._(1, _omitEnumNames ? '' : 'QUESTION');
  static const JoinQuestionType CAPTCHA = JoinQuestionType._(2, _omitEnumNames ? '' : 'CAPTCHA');
  static const JoinQuestionType INVITE_CODE = JoinQuestionType._(3, _omitEnumNames ? '' : 'INVITE_CODE');

  static const $core.List<JoinQuestionType> values = <JoinQuestionType> [
    NONE,
    QUESTION,
    CAPTCHA,
    INVITE_CODE,
  ];

  static final $core.List<JoinQuestionType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static JoinQuestionType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const JoinQuestionType._(super.value, super.name);
}

/// ======================================
/// 💬 消息类型枚举（用于标记主消息类型）
/// ======================================
/// 每条消息将根据其主内容赋予一个主类型，便于前端渲染和后端分类处理。
/// 注意：具体内容仍以 MessageContent 的 oneof 实体为准，ContentType 仅为索引分类用途。
class ContentType extends $pb.ProtobufEnum {
  static const ContentType UNKNOWN = ContentType._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const ContentType TEXT = ContentType._(1, _omitEnumNames ? '' : 'TEXT');
  static const ContentType IMAGE = ContentType._(2, _omitEnumNames ? '' : 'IMAGE');
  static const ContentType AUDIO = ContentType._(3, _omitEnumNames ? '' : 'AUDIO');
  static const ContentType VIDEO = ContentType._(4, _omitEnumNames ? '' : 'VIDEO');
  static const ContentType HTML = ContentType._(5, _omitEnumNames ? '' : 'HTML');
  static const ContentType LOCATION = ContentType._(6, _omitEnumNames ? '' : 'LOCATION');
  static const ContentType FILE = ContentType._(7, _omitEnumNames ? '' : 'FILE');
  static const ContentType EMOJI = ContentType._(8, _omitEnumNames ? '' : 'EMOJI');
  static const ContentType QUOTE = ContentType._(9, _omitEnumNames ? '' : 'QUOTE');
  static const ContentType AV_CALL = ContentType._(10, _omitEnumNames ? '' : 'AV_CALL');
  static const ContentType VOIP = ContentType._(11, _omitEnumNames ? '' : 'VOIP');
  static const ContentType NOTIFICATION = ContentType._(12, _omitEnumNames ? '' : 'NOTIFICATION');
  static const ContentType SYSTEM = ContentType._(13, _omitEnumNames ? '' : 'SYSTEM');
  static const ContentType REMINDER = ContentType._(14, _omitEnumNames ? '' : 'REMINDER');
  static const ContentType FRIEND_EVENT = ContentType._(15, _omitEnumNames ? '' : 'FRIEND_EVENT');
  static const ContentType GROUP_EVENT = ContentType._(16, _omitEnumNames ? '' : 'GROUP_EVENT');
  static const ContentType REVOKE = ContentType._(17, _omitEnumNames ? '' : 'REVOKE');
  static const ContentType FORWARD = ContentType._(18, _omitEnumNames ? '' : 'FORWARD');
  /// 可选扩展类型（根据业务需要添加）
  static const ContentType CONTACT_CARD = ContentType._(19, _omitEnumNames ? '' : 'CONTACT_CARD');
  static const ContentType VOTE = ContentType._(20, _omitEnumNames ? '' : 'VOTE');
  static const ContentType RED_ENVELOPE = ContentType._(21, _omitEnumNames ? '' : 'RED_ENVELOPE');
  static const ContentType CUSTOM = ContentType._(100, _omitEnumNames ? '' : 'CUSTOM');

  static const $core.List<ContentType> values = <ContentType> [
    UNKNOWN,
    TEXT,
    IMAGE,
    AUDIO,
    VIDEO,
    HTML,
    LOCATION,
    FILE,
    EMOJI,
    QUOTE,
    AV_CALL,
    VOIP,
    NOTIFICATION,
    SYSTEM,
    REMINDER,
    FRIEND_EVENT,
    GROUP_EVENT,
    REVOKE,
    FORWARD,
    CONTACT_CARD,
    VOTE,
    RED_ENVELOPE,
    CUSTOM,
  ];

  static final $core.Map<$core.int, ContentType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ContentType? valueOf($core.int value) => _byValue[value];

  const ContentType._(super.value, super.name);
}

/// ======================================
/// 🎯 聊天目标类型枚举
/// ======================================
/// 用于标识消息的接收目标类型，帮助客户端和服务端进行不同的处理逻辑
class ChatTargetType extends $pb.ProtobufEnum {
  static const ChatTargetType UN_KNOWN = ChatTargetType._(0, _omitEnumNames ? '' : 'UN_KNOWN');
  static const ChatTargetType GROUP = ChatTargetType._(1, _omitEnumNames ? '' : 'GROUP');
  static const ChatTargetType SINGLE = ChatTargetType._(2, _omitEnumNames ? '' : 'SINGLE');

  static const $core.List<ChatTargetType> values = <ChatTargetType> [
    UN_KNOWN,
    GROUP,
    SINGLE,
  ];

  static final $core.List<ChatTargetType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ChatTargetType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ChatTargetType._(super.value, super.name);
}

class GroupType extends $pb.ProtobufEnum {
  static const GroupType UNKNOWN_GROUP_TYPE = GroupType._(0, _omitEnumNames ? '' : 'UNKNOWN_GROUP_TYPE');
  static const GroupType NORMAL_GROUP = GroupType._(1, _omitEnumNames ? '' : 'NORMAL_GROUP');
  static const GroupType SUPER_GROUP = GroupType._(2, _omitEnumNames ? '' : 'SUPER_GROUP');
  static const GroupType SYSTEM_GROUP = GroupType._(3, _omitEnumNames ? '' : 'SYSTEM_GROUP');

  static const $core.List<GroupType> values = <GroupType> [
    UNKNOWN_GROUP_TYPE,
    NORMAL_GROUP,
    SUPER_GROUP,
    SYSTEM_GROUP,
  ];

  static final $core.List<GroupType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static GroupType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GroupType._(super.value, super.name);
}

/// ======================================
/// 📦 字节消息类型枚举
/// ======================================
/// 用于标识通过 WebSocket 传输的二进制消息类型
/// 这些类型用于消息路由和分发，确保消息被正确处理
/// 消息类型枚举：用于标识通信协议中的消息分类
class ByteMessageType extends $pb.ProtobufEnum {
  static const ByteMessageType UNKNOWN_BYTE_MESSAGE_TYPE = ByteMessageType._(0, _omitEnumNames ? '' : 'UNKNOWN_BYTE_MESSAGE_TYPE');
  /// 系统基础通信（1~9）
  static const ByteMessageType HeartbeatMsgType = ByteMessageType._(1, _omitEnumNames ? '' : 'HeartbeatMsgType');
  static const ByteMessageType LoginReqMsgType = ByteMessageType._(2, _omitEnumNames ? '' : 'LoginReqMsgType');
  static const ByteMessageType LoginRespMsgType = ByteMessageType._(3, _omitEnumNames ? '' : 'LoginRespMsgType');
  static const ByteMessageType LogoutReqMsgType = ByteMessageType._(4, _omitEnumNames ? '' : 'LogoutReqMsgType');
  static const ByteMessageType LogoutRespMsgType = ByteMessageType._(5, _omitEnumNames ? '' : 'LogoutRespMsgType');
  static const ByteMessageType SendVerificationCodeReqMsgType = ByteMessageType._(6, _omitEnumNames ? '' : 'SendVerificationCodeReqMsgType');
  static const ByteMessageType SendVerificationCodeRepMsgType = ByteMessageType._(7, _omitEnumNames ? '' : 'SendVerificationCodeRepMsgType');
  static const ByteMessageType SystemNotificationMsgType = ByteMessageType._(8, _omitEnumNames ? '' : 'SystemNotificationMsgType');
  static const ByteMessageType UserFlushMsgType = ByteMessageType._(9, _omitEnumNames ? '' : 'UserFlushMsgType');
  /// 用户在线状态（10~19）
  static const ByteMessageType OnlineStatusMsgType = ByteMessageType._(10, _omitEnumNames ? '' : 'OnlineStatusMsgType');
  static const ByteMessageType OfflineStatusMsgType = ByteMessageType._(11, _omitEnumNames ? '' : 'OfflineStatusMsgType');
  /// 聊天消息（20~29）
  static const ByteMessageType UserMsgType = ByteMessageType._(20, _omitEnumNames ? '' : 'UserMsgType');
  static const ByteMessageType GroupMsgType = ByteMessageType._(21, _omitEnumNames ? '' : 'GroupMsgType');
  /// 好友 / 群组事件（30~39）
  static const ByteMessageType FriendEventMsgType = ByteMessageType._(30, _omitEnumNames ? '' : 'FriendEventMsgType');
  static const ByteMessageType GroupCreateMsgType = ByteMessageType._(31, _omitEnumNames ? '' : 'GroupCreateMsgType');
  static const ByteMessageType GroupDismissMsgType = ByteMessageType._(32, _omitEnumNames ? '' : 'GroupDismissMsgType');
  static const ByteMessageType ReConnectMsgType = ByteMessageType._(99, _omitEnumNames ? '' : 'ReConnectMsgType');
  static const ByteMessageType ACKMsgType = ByteMessageType._(200, _omitEnumNames ? '' : 'ACKMsgType');

  static const $core.List<ByteMessageType> values = <ByteMessageType> [
    UNKNOWN_BYTE_MESSAGE_TYPE,
    HeartbeatMsgType,
    LoginReqMsgType,
    LoginRespMsgType,
    LogoutReqMsgType,
    LogoutRespMsgType,
    SendVerificationCodeReqMsgType,
    SendVerificationCodeRepMsgType,
    SystemNotificationMsgType,
    UserFlushMsgType,
    OnlineStatusMsgType,
    OfflineStatusMsgType,
    UserMsgType,
    GroupMsgType,
    FriendEventMsgType,
    GroupCreateMsgType,
    GroupDismissMsgType,
    ReConnectMsgType,
    ACKMsgType,
  ];

  static final $core.Map<$core.int, ByteMessageType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ByteMessageType? valueOf($core.int value) => _byValue[value];

  const ByteMessageType._(super.value, super.name);
}

class Gender extends $pb.ProtobufEnum {
  static const Gender Unknown = Gender._(0, _omitEnumNames ? '' : 'Unknown');
  static const Gender Male = Gender._(1, _omitEnumNames ? '' : 'Male');
  static const Gender Female = Gender._(2, _omitEnumNames ? '' : 'Female');

  static const $core.List<Gender> values = <Gender> [
    Unknown,
    Male,
    Female,
  ];

  static final $core.List<Gender?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Gender? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Gender._(super.value, super.name);
}

/// ==========================
/// 🚦 加好友策略（枚举定义）
/// ==========================
class FriendPolicy extends $pb.ProtobufEnum {
  static const FriendPolicy ALLOW_ANY = FriendPolicy._(0, _omitEnumNames ? '' : 'ALLOW_ANY');
  static const FriendPolicy NEED_CONFIRM = FriendPolicy._(1, _omitEnumNames ? '' : 'NEED_CONFIRM');
  static const FriendPolicy DENY_ANY = FriendPolicy._(2, _omitEnumNames ? '' : 'DENY_ANY');

  static const $core.List<FriendPolicy> values = <FriendPolicy> [
    ALLOW_ANY,
    NEED_CONFIRM,
    DENY_ANY,
  ];

  static final $core.List<FriendPolicy?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static FriendPolicy? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FriendPolicy._(super.value, super.name);
}

/// 客户端用户类型
class ClientUserType extends $pb.ProtobufEnum {
  /// 未知
  static const ClientUserType USER_TYPE_UNKNOWN = ClientUserType._(0, _omitEnumNames ? '' : 'USER_TYPE_UNKNOWN');
  /// 普通用户
  static const ClientUserType USER_TYPE_NORMAL = ClientUserType._(1, _omitEnumNames ? '' : 'USER_TYPE_NORMAL');
  /// 机器人
  static const ClientUserType USER_TYPE_ROBOT = ClientUserType._(2, _omitEnumNames ? '' : 'USER_TYPE_ROBOT');

  static const $core.List<ClientUserType> values = <ClientUserType> [
    USER_TYPE_UNKNOWN,
    USER_TYPE_NORMAL,
    USER_TYPE_ROBOT,
  ];

  static final $core.List<ClientUserType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ClientUserType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ClientUserType._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
