// This is a generated file - do not edit.
//
// Generated from group.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// *
///  群组节点支持的消息类型枚举（用于 MQ 路由 / 类型标识）
class GroupNodeMsgType extends $pb.ProtobufEnum {
  static const GroupNodeMsgType UNKNOWN_MSG_TYPE = GroupNodeMsgType._(0, _omitEnumNames ? '' : 'UNKNOWN_MSG_TYPE');
  static const GroupNodeMsgType CREATE_GROUP_MSG_TYPE = GroupNodeMsgType._(1, _omitEnumNames ? '' : 'CREATE_GROUP_MSG_TYPE');
  static const GroupNodeMsgType CHANGE_GROUP_MSG_TYPE = GroupNodeMsgType._(2, _omitEnumNames ? '' : 'CHANGE_GROUP_MSG_TYPE');
  static const GroupNodeMsgType DESTROY_GROUP_MSG_TYPE = GroupNodeMsgType._(3, _omitEnumNames ? '' : 'DESTROY_GROUP_MSG_TYPE');
  static const GroupNodeMsgType MEMBER_ONLINE_MSG_TYPE = GroupNodeMsgType._(4, _omitEnumNames ? '' : 'MEMBER_ONLINE_MSG_TYPE');
  static const GroupNodeMsgType MEMBER_OFFLINE_MSG_TYPE = GroupNodeMsgType._(5, _omitEnumNames ? '' : 'MEMBER_OFFLINE_MSG_TYPE');
  static const GroupNodeMsgType REQUEST_JOIN_GROUP_MSG_TYPE = GroupNodeMsgType._(6, _omitEnumNames ? '' : 'REQUEST_JOIN_GROUP_MSG_TYPE');
  static const GroupNodeMsgType HANDLE_JOIN_REQUEST_MSG_TYPE = GroupNodeMsgType._(7, _omitEnumNames ? '' : 'HANDLE_JOIN_REQUEST_MSG_TYPE');
  static const GroupNodeMsgType INVITE_MEMBERS_MSG_TYPE = GroupNodeMsgType._(8, _omitEnumNames ? '' : 'INVITE_MEMBERS_MSG_TYPE');
  static const GroupNodeMsgType REMOVE_MEMBERS_MSG_TYPE = GroupNodeMsgType._(9, _omitEnumNames ? '' : 'REMOVE_MEMBERS_MSG_TYPE');
  static const GroupNodeMsgType EXIT_GROUP_MSG_TYPE = GroupNodeMsgType._(10, _omitEnumNames ? '' : 'EXIT_GROUP_MSG_TYPE');
  static const GroupNodeMsgType CHANGE_MEMBER_ROLE_MSG_TYPE = GroupNodeMsgType._(11, _omitEnumNames ? '' : 'CHANGE_MEMBER_ROLE_MSG_TYPE');
  static const GroupNodeMsgType MUTE_MEMBER_MSG_TYPE = GroupNodeMsgType._(12, _omitEnumNames ? '' : 'MUTE_MEMBER_MSG_TYPE');
  static const GroupNodeMsgType UPDATE_MEMBER_PROFILE_MSG_TYPE = GroupNodeMsgType._(13, _omitEnumNames ? '' : 'UPDATE_MEMBER_PROFILE_MSG_TYPE');
  static const GroupNodeMsgType TRANSFER_OWNERSHIP_MSG_TYPE = GroupNodeMsgType._(14, _omitEnumNames ? '' : 'TRANSFER_OWNERSHIP_MSG_TYPE');
  static const GroupNodeMsgType HANDLE_INVITE_MSG_TYPE = GroupNodeMsgType._(15, _omitEnumNames ? '' : 'HANDLE_INVITE_MSG_TYPE');

  static const $core.List<GroupNodeMsgType> values = <GroupNodeMsgType> [
    UNKNOWN_MSG_TYPE,
    CREATE_GROUP_MSG_TYPE,
    CHANGE_GROUP_MSG_TYPE,
    DESTROY_GROUP_MSG_TYPE,
    MEMBER_ONLINE_MSG_TYPE,
    MEMBER_OFFLINE_MSG_TYPE,
    REQUEST_JOIN_GROUP_MSG_TYPE,
    HANDLE_JOIN_REQUEST_MSG_TYPE,
    INVITE_MEMBERS_MSG_TYPE,
    REMOVE_MEMBERS_MSG_TYPE,
    EXIT_GROUP_MSG_TYPE,
    CHANGE_MEMBER_ROLE_MSG_TYPE,
    MUTE_MEMBER_MSG_TYPE,
    UPDATE_MEMBER_PROFILE_MSG_TYPE,
    TRANSFER_OWNERSHIP_MSG_TYPE,
    HANDLE_INVITE_MSG_TYPE,
  ];

  static final $core.List<GroupNodeMsgType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 15);
  static GroupNodeMsgType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GroupNodeMsgType._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
