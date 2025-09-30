// This is a generated file - do not edit.
//
// Generated from hot_online.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SessionTokenStatus extends $pb.ProtobufEnum {
  static const SessionTokenStatus STS_UNKNOWN = SessionTokenStatus._(0, _omitEnumNames ? '' : 'STS_UNKNOWN');
  static const SessionTokenStatus STS_ACTIVE = SessionTokenStatus._(1, _omitEnumNames ? '' : 'STS_ACTIVE');
  static const SessionTokenStatus STS_REVOKED = SessionTokenStatus._(2, _omitEnumNames ? '' : 'STS_REVOKED');
  static const SessionTokenStatus STS_EXPIRED = SessionTokenStatus._(3, _omitEnumNames ? '' : 'STS_EXPIRED');

  static const $core.List<SessionTokenStatus> values = <SessionTokenStatus> [
    STS_UNKNOWN,
    STS_ACTIVE,
    STS_REVOKED,
    STS_EXPIRED,
  ];

  static final $core.List<SessionTokenStatus?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SessionTokenStatus? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SessionTokenStatus._(super.value, super.name);
}

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

class AuthType extends $pb.ProtobufEnum {
  static const AuthType AUTH_TYPE_UNKNOWN = AuthType._(0, _omitEnumNames ? '' : 'AUTH_TYPE_UNKNOWN');
  static const AuthType AUTH_TYPE_EMAIL = AuthType._(1, _omitEnumNames ? '' : 'AUTH_TYPE_EMAIL');
  static const AuthType AUTH_TYPE_PHONE = AuthType._(2, _omitEnumNames ? '' : 'AUTH_TYPE_PHONE');
  static const AuthType AUTH_TYPE_USERNAME = AuthType._(3, _omitEnumNames ? '' : 'AUTH_TYPE_USERNAME');

  static const $core.List<AuthType> values = <AuthType> [
    AUTH_TYPE_UNKNOWN,
    AUTH_TYPE_EMAIL,
    AUTH_TYPE_PHONE,
    AUTH_TYPE_USERNAME,
  ];

  static final $core.List<AuthType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static AuthType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AuthType._(super.value, super.name);
}

class AddFriendPolicy extends $pb.ProtobufEnum {
  static const AddFriendPolicy ADD_FRIEND_UNSPECIFIED = AddFriendPolicy._(0, _omitEnumNames ? '' : 'ADD_FRIEND_UNSPECIFIED');
  static const AddFriendPolicy ANYONE = AddFriendPolicy._(1, _omitEnumNames ? '' : 'ANYONE');
  static const AddFriendPolicy REQUIRE_VERIFY = AddFriendPolicy._(2, _omitEnumNames ? '' : 'REQUIRE_VERIFY');
  static const AddFriendPolicy PHONE_ONLY = AddFriendPolicy._(3, _omitEnumNames ? '' : 'PHONE_ONLY');

  static const $core.List<AddFriendPolicy> values = <AddFriendPolicy> [
    ADD_FRIEND_UNSPECIFIED,
    ANYONE,
    REQUIRE_VERIFY,
    PHONE_ONLY,
  ];

  static final $core.List<AddFriendPolicy?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static AddFriendPolicy? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AddFriendPolicy._(super.value, super.name);
}

class Gender extends $pb.ProtobufEnum {
  static const Gender GENDER_UNSPECIFIED = Gender._(0, _omitEnumNames ? '' : 'GENDER_UNSPECIFIED');
  static const Gender MALE = Gender._(1, _omitEnumNames ? '' : 'MALE');
  static const Gender FEMALE = Gender._(2, _omitEnumNames ? '' : 'FEMALE');
  static const Gender SECRET = Gender._(9, _omitEnumNames ? '' : 'SECRET');

  static const $core.List<Gender> values = <Gender> [
    GENDER_UNSPECIFIED,
    MALE,
    FEMALE,
    SECRET,
  ];

  static final $core.Map<$core.int, Gender> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Gender? valueOf($core.int value) => _byValue[value];

  const Gender._(super.value, super.name);
}

class UserType extends $pb.ProtobufEnum {
  static const UserType USER_TYPE_UNSPECIFIED = UserType._(0, _omitEnumNames ? '' : 'USER_TYPE_UNSPECIFIED');
  static const UserType NORMAL = UserType._(1, _omitEnumNames ? '' : 'NORMAL');
  static const UserType TEST = UserType._(2, _omitEnumNames ? '' : 'TEST');
  static const UserType BOT = UserType._(3, _omitEnumNames ? '' : 'BOT');

  static const $core.List<UserType> values = <UserType> [
    USER_TYPE_UNSPECIFIED,
    NORMAL,
    TEST,
    BOT,
  ];

  static final $core.List<UserType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static UserType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UserType._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
