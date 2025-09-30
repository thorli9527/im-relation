// This is a generated file - do not edit.
//
// Generated from friend.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// ================================
/// 🤝 好友事件类型枚举
/// ================================
/// 表示好友关系变更的操作类型，通常用于请求加好友、拉黑、解除等社交关系变动。
class FriendEventType extends $pb.ProtobufEnum {
  static const FriendEventType FRIEND_EVENT_UNKNOWN = FriendEventType._(0, _omitEnumNames ? '' : 'FRIEND_EVENT_UNKNOWN');
  static const FriendEventType FRIEND_REQUEST = FriendEventType._(1, _omitEnumNames ? '' : 'FRIEND_REQUEST');
  static const FriendEventType FRIEND_ACCEPT = FriendEventType._(2, _omitEnumNames ? '' : 'FRIEND_ACCEPT');
  static const FriendEventType FRIEND_REJECT = FriendEventType._(3, _omitEnumNames ? '' : 'FRIEND_REJECT');
  static const FriendEventType FRIEND_REMOVE = FriendEventType._(4, _omitEnumNames ? '' : 'FRIEND_REMOVE');
  static const FriendEventType FRIEND_BLOCK = FriendEventType._(5, _omitEnumNames ? '' : 'FRIEND_BLOCK');
  static const FriendEventType FRIEND_UNBLOCK = FriendEventType._(6, _omitEnumNames ? '' : 'FRIEND_UNBLOCK');
  static const FriendEventType FRIEND_UPDATE_REMARK = FriendEventType._(7, _omitEnumNames ? '' : 'FRIEND_UPDATE_REMARK');
  static const FriendEventType FRIEND_ADD_FORCE = FriendEventType._(8, _omitEnumNames ? '' : 'FRIEND_ADD_FORCE');

  static const $core.List<FriendEventType> values = <FriendEventType> [
    FRIEND_EVENT_UNKNOWN,
    FRIEND_REQUEST,
    FRIEND_ACCEPT,
    FRIEND_REJECT,
    FRIEND_REMOVE,
    FRIEND_BLOCK,
    FRIEND_UNBLOCK,
    FRIEND_UPDATE_REMARK,
    FRIEND_ADD_FORCE,
  ];

  static final $core.List<FriendEventType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 8);
  static FriendEventType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FriendEventType._(super.value, super.name);
}

/// ================================
/// 📥 好友添加来源类型
/// ================================
/// 表示用户是通过何种方式添加好友的，用于统计分析和风控判断
class FriendSourceType extends $pb.ProtobufEnum {
  static const FriendSourceType FRIEND_SOURCE_UNKNOWN = FriendSourceType._(0, _omitEnumNames ? '' : 'FRIEND_SOURCE_UNKNOWN');
  static const FriendSourceType FRIEND_SOURCE_SEARCH = FriendSourceType._(1, _omitEnumNames ? '' : 'FRIEND_SOURCE_SEARCH');
  static const FriendSourceType FRIEND_SOURCE_QRCODE = FriendSourceType._(2, _omitEnumNames ? '' : 'FRIEND_SOURCE_QRCODE');
  static const FriendSourceType FRIEND_SOURCE_PHONE = FriendSourceType._(3, _omitEnumNames ? '' : 'FRIEND_SOURCE_PHONE');
  static const FriendSourceType FRIEND_SOURCE_GROUP = FriendSourceType._(4, _omitEnumNames ? '' : 'FRIEND_SOURCE_GROUP');
  static const FriendSourceType FRIEND_SOURCE_SYSTEM = FriendSourceType._(5, _omitEnumNames ? '' : 'FRIEND_SOURCE_SYSTEM');

  static const $core.List<FriendSourceType> values = <FriendSourceType> [
    FRIEND_SOURCE_UNKNOWN,
    FRIEND_SOURCE_SEARCH,
    FRIEND_SOURCE_QRCODE,
    FRIEND_SOURCE_PHONE,
    FRIEND_SOURCE_GROUP,
    FRIEND_SOURCE_SYSTEM,
  ];

  static final $core.List<FriendSourceType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 5);
  static FriendSourceType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FriendSourceType._(super.value, super.name);
}

/// ================================
/// 📌 好友事件状态枚举
/// ================================
/// 每个好友事件都具有生命周期状态，用于判断是否被处理
class EventStatus extends $pb.ProtobufEnum {
  static const EventStatus PENDING = EventStatus._(0, _omitEnumNames ? '' : 'PENDING');
  static const EventStatus DONE = EventStatus._(1, _omitEnumNames ? '' : 'DONE');
  static const EventStatus REVOKED = EventStatus._(2, _omitEnumNames ? '' : 'REVOKED');

  static const $core.List<EventStatus> values = <EventStatus> [
    PENDING,
    DONE,
    REVOKED,
  ];

  static final $core.List<EventStatus?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static EventStatus? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EventStatus._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
