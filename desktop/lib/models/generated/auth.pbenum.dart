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

/// ================================
/// 📦 设备类型枚举
/// ================================
/// 用于标识客户端的来源类型，有助于服务端区分平台特性、限流策略等
class DeviceType extends $pb.ProtobufEnum {
  static const DeviceType DEVICE_UNKNOWN = DeviceType._(0, _omitEnumNames ? '' : 'DEVICE_UNKNOWN');
  static const DeviceType MOBILE = DeviceType._(1, _omitEnumNames ? '' : 'MOBILE');
  static const DeviceType DESKTOP = DeviceType._(2, _omitEnumNames ? '' : 'DESKTOP');
  static const DeviceType WEB = DeviceType._(3, _omitEnumNames ? '' : 'WEB');
  static const DeviceType ALL = DeviceType._(100, _omitEnumNames ? '' : 'ALL');

  static const $core.List<DeviceType> values = <DeviceType> [
    DEVICE_UNKNOWN,
    MOBILE,
    DESKTOP,
    WEB,
    ALL,
  ];

  static final $core.Map<$core.int, DeviceType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DeviceType? valueOf($core.int value) => _byValue[value];

  const DeviceType._(super.value, super.name);
}

class AuthType extends $pb.ProtobufEnum {
  static const AuthType AUTH_TYPE_UNKNOWN = AuthType._(0, _omitEnumNames ? '' : 'AUTH_TYPE_UNKNOWN');
  static const AuthType AUTH_TYPE_EMAIL = AuthType._(1, _omitEnumNames ? '' : 'AUTH_TYPE_EMAIL');
  static const AuthType AUTH_TYPE_PHONE = AuthType._(2, _omitEnumNames ? '' : 'AUTH_TYPE_PHONE');

  static const $core.List<AuthType> values = <AuthType> [
    AUTH_TYPE_UNKNOWN,
    AUTH_TYPE_EMAIL,
    AUTH_TYPE_PHONE,
  ];

  static final $core.List<AuthType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static AuthType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AuthType._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
