// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class UserSearchType extends $pb.ProtobufEnum {
  static const UserSearchType USER_SEARCH_UNKNOWN = UserSearchType._(0, _omitEnumNames ? '' : 'USER_SEARCH_UNKNOWN');
  static const UserSearchType USER_SEARCH_USER_ID = UserSearchType._(1, _omitEnumNames ? '' : 'USER_SEARCH_USER_ID');
  static const UserSearchType USER_SEARCH_USERNAME = UserSearchType._(2, _omitEnumNames ? '' : 'USER_SEARCH_USERNAME');
  static const UserSearchType USER_SEARCH_EMAIL = UserSearchType._(3, _omitEnumNames ? '' : 'USER_SEARCH_EMAIL');
  static const UserSearchType USER_SEARCH_PHONE = UserSearchType._(4, _omitEnumNames ? '' : 'USER_SEARCH_PHONE');

  static const $core.List<UserSearchType> values = <UserSearchType> [
    USER_SEARCH_UNKNOWN,
    USER_SEARCH_USER_ID,
    USER_SEARCH_USERNAME,
    USER_SEARCH_EMAIL,
    USER_SEARCH_PHONE,
  ];

  static final $core.List<UserSearchType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static UserSearchType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UserSearchType._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
