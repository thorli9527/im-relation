// This is a generated file - do not edit.
//
// Generated from msg_friend.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 好友申请来源
class FriendRequestSource extends $pb.ProtobufEnum {
  /// 未知来源
  static const FriendRequestSource FRS_UNKNOWN = FriendRequestSource._(0, _omitEnumNames ? '' : 'FRS_UNKNOWN');
  /// 二维码添加
  static const FriendRequestSource FRS_QR_CODE = FriendRequestSource._(1, _omitEnumNames ? '' : 'FRS_QR_CODE');
  /// 手机联系人
  static const FriendRequestSource FRS_PHONE_CONTACTS = FriendRequestSource._(2, _omitEnumNames ? '' : 'FRS_PHONE_CONTACTS');
  /// 用户ID添加
  static const FriendRequestSource FRS_USER_ID = FriendRequestSource._(3, _omitEnumNames ? '' : 'FRS_USER_ID');
  /// 群成员添加
  static const FriendRequestSource FRS_GROUP_MEMBER = FriendRequestSource._(4, _omitEnumNames ? '' : 'FRS_GROUP_MEMBER');

  static const $core.List<FriendRequestSource> values = <FriendRequestSource> [
    FRS_UNKNOWN,
    FRS_QR_CODE,
    FRS_PHONE_CONTACTS,
    FRS_USER_ID,
    FRS_GROUP_MEMBER,
  ];

  static final $core.List<FriendRequestSource?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static FriendRequestSource? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FriendRequestSource._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
