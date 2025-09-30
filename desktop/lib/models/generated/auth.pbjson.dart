// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use deviceTypeDescriptor instead')
const DeviceType$json = {
  '1': 'DeviceType',
  '2': [
    {'1': 'DEVICE_UNKNOWN', '2': 0},
    {'1': 'MOBILE', '2': 1},
    {'1': 'DESKTOP', '2': 2},
    {'1': 'WEB', '2': 3},
    {'1': 'ALL', '2': 100},
  ],
};

/// Descriptor for `DeviceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deviceTypeDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VUeXBlEhIKDkRFVklDRV9VTktOT1dOEAASCgoGTU9CSUxFEAESCwoHREVTS1RPUB'
    'ACEgcKA1dFQhADEgcKA0FMTBBk');

@$core.Deprecated('Use authTypeDescriptor instead')
const AuthType$json = {
  '1': 'AuthType',
  '2': [
    {'1': 'AUTH_TYPE_UNKNOWN', '2': 0},
    {'1': 'AUTH_TYPE_EMAIL', '2': 1},
    {'1': 'AUTH_TYPE_PHONE', '2': 2},
  ],
};

/// Descriptor for `AuthType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List authTypeDescriptor = $convert.base64Decode(
    'CghBdXRoVHlwZRIVChFBVVRIX1RZUEVfVU5LTk9XThAAEhMKD0FVVEhfVFlQRV9FTUFJTBABEh'
    'MKD0FVVEhfVFlQRV9QSE9ORRAC');

@$core.Deprecated('Use loginReqMsgDescriptor instead')
const LoginReqMsg$json = {
  '1': 'LoginReqMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
    {'1': 'auth_type', '3': 2, '4': 1, '5': 14, '6': '.protocol.auth.AuthType', '10': 'authType'},
    {'1': 'auth_content', '3': 3, '4': 1, '5': 9, '10': 'authContent'},
    {'1': 'password', '3': 4, '4': 1, '5': 9, '10': 'password'},
    {'1': 'device_type', '3': 5, '4': 1, '5': 14, '6': '.protocol.auth.DeviceType', '10': 'deviceType'},
  ],
};

/// Descriptor for `LoginReqMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginReqMsgDescriptor = $convert.base64Decode(
    'CgtMb2dpblJlcU1zZxIdCgptZXNzYWdlX2lkGAEgASgEUgltZXNzYWdlSWQSNAoJYXV0aF90eX'
    'BlGAIgASgOMhcucHJvdG9jb2wuYXV0aC5BdXRoVHlwZVIIYXV0aFR5cGUSIQoMYXV0aF9jb250'
    'ZW50GAMgASgJUgthdXRoQ29udGVudBIaCghwYXNzd29yZBgEIAEoCVIIcGFzc3dvcmQSOgoLZG'
    'V2aWNlX3R5cGUYBSABKA4yGS5wcm90b2NvbC5hdXRoLkRldmljZVR5cGVSCmRldmljZVR5cGU=');

@$core.Deprecated('Use loginRespMsgDescriptor instead')
const LoginRespMsg$json = {
  '1': 'LoginRespMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    {'1': 'expires_at', '3': 3, '4': 1, '5': 4, '10': 'expiresAt'},
    {'1': 'success', '3': 4, '4': 1, '5': 8, '10': 'success'},
    {'1': 'msg', '3': 5, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'uid', '3': 6, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'nickname', '3': 7, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar', '3': 8, '4': 1, '5': 9, '10': 'avatar'},
  ],
};

/// Descriptor for `LoginRespMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRespMsgDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlc3BNc2cSHQoKbWVzc2FnZV9pZBgBIAEoBFIJbWVzc2FnZUlkEhQKBXRva2VuGA'
    'IgASgJUgV0b2tlbhIdCgpleHBpcmVzX2F0GAMgASgEUglleHBpcmVzQXQSGAoHc3VjY2VzcxgE'
    'IAEoCFIHc3VjY2VzcxIQCgNtc2cYBSABKAlSA21zZxIQCgN1aWQYBiABKAlSA3VpZBIaCghuaW'
    'NrbmFtZRgHIAEoCVIIbmlja25hbWUSFgoGYXZhdGFyGAggASgJUgZhdmF0YXI=');

@$core.Deprecated('Use logoutReqMsgDescriptor instead')
const LogoutReqMsg$json = {
  '1': 'LogoutReqMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
  ],
};

/// Descriptor for `LogoutReqMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logoutReqMsgDescriptor = $convert.base64Decode(
    'CgxMb2dvdXRSZXFNc2cSHQoKbWVzc2FnZV9pZBgBIAEoBFIJbWVzc2FnZUlk');

@$core.Deprecated('Use logoutRespMsgDescriptor instead')
const LogoutRespMsg$json = {
  '1': 'LogoutRespMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
  ],
};

/// Descriptor for `LogoutRespMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logoutRespMsgDescriptor = $convert.base64Decode(
    'Cg1Mb2dvdXRSZXNwTXNnEh0KCm1lc3NhZ2VfaWQYASABKARSCW1lc3NhZ2VJZA==');

@$core.Deprecated('Use sendVerificationCodeReqMsgDescriptor instead')
const SendVerificationCodeReqMsg$json = {
  '1': 'SendVerificationCodeReqMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
    {'1': 'receiver', '3': 2, '4': 1, '5': 9, '10': 'receiver'},
    {'1': 'channel', '3': 3, '4': 1, '5': 9, '10': 'channel'},
    {'1': 'scene', '3': 4, '4': 1, '5': 9, '10': 'scene'},
    {'1': 'uid', '3': 5, '4': 1, '5': 9, '10': 'uid'},
  ],
};

/// Descriptor for `SendVerificationCodeReqMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendVerificationCodeReqMsgDescriptor = $convert.base64Decode(
    'ChpTZW5kVmVyaWZpY2F0aW9uQ29kZVJlcU1zZxIdCgptZXNzYWdlX2lkGAEgASgEUgltZXNzYW'
    'dlSWQSGgoIcmVjZWl2ZXIYAiABKAlSCHJlY2VpdmVyEhgKB2NoYW5uZWwYAyABKAlSB2NoYW5u'
    'ZWwSFAoFc2NlbmUYBCABKAlSBXNjZW5lEhAKA3VpZBgFIAEoCVIDdWlk');

@$core.Deprecated('Use sendVerificationCodeRepMsgDescriptor instead')
const SendVerificationCodeRepMsg$json = {
  '1': 'SendVerificationCodeRepMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
    {'1': 'success', '3': 2, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'expired_in', '3': 4, '4': 1, '5': 3, '10': 'expiredIn'},
  ],
};

/// Descriptor for `SendVerificationCodeRepMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendVerificationCodeRepMsgDescriptor = $convert.base64Decode(
    'ChpTZW5kVmVyaWZpY2F0aW9uQ29kZVJlcE1zZxIdCgptZXNzYWdlX2lkGAEgASgEUgltZXNzYW'
    'dlSWQSGAoHc3VjY2VzcxgCIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAMgASgJUgdtZXNzYWdl'
    'Eh0KCmV4cGlyZWRfaW4YBCABKANSCWV4cGlyZWRJbg==');

@$core.Deprecated('Use onlineStatusMsgDescriptor instead')
const OnlineStatusMsg$json = {
  '1': 'OnlineStatusMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
    {'1': 'uid', '3': 2, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 14, '6': '.protocol.auth.DeviceType', '10': 'deviceType'},
    {'1': 'client_id', '3': 4, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'login_time', '3': 5, '4': 1, '5': 3, '10': 'loginTime'},
  ],
};

/// Descriptor for `OnlineStatusMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onlineStatusMsgDescriptor = $convert.base64Decode(
    'Cg9PbmxpbmVTdGF0dXNNc2cSHQoKbWVzc2FnZV9pZBgBIAEoBFIJbWVzc2FnZUlkEhAKA3VpZB'
    'gCIAEoCVIDdWlkEjoKC2RldmljZV90eXBlGAMgASgOMhkucHJvdG9jb2wuYXV0aC5EZXZpY2VU'
    'eXBlUgpkZXZpY2VUeXBlEhsKCWNsaWVudF9pZBgEIAEoCVIIY2xpZW50SWQSHQoKbG9naW5fdG'
    'ltZRgFIAEoA1IJbG9naW5UaW1l');

@$core.Deprecated('Use offlineStatueMsgDescriptor instead')
const OfflineStatueMsg$json = {
  '1': 'OfflineStatueMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
    {'1': 'uid', '3': 2, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 14, '6': '.protocol.auth.DeviceType', '10': 'deviceType'},
    {'1': 'client_id', '3': 4, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'logout_time', '3': 5, '4': 1, '5': 3, '10': 'logoutTime'},
    {'1': 'reason', '3': 6, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `OfflineStatueMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List offlineStatueMsgDescriptor = $convert.base64Decode(
    'ChBPZmZsaW5lU3RhdHVlTXNnEh0KCm1lc3NhZ2VfaWQYASABKARSCW1lc3NhZ2VJZBIQCgN1aW'
    'QYAiABKAlSA3VpZBI6CgtkZXZpY2VfdHlwZRgDIAEoDjIZLnByb3RvY29sLmF1dGguRGV2aWNl'
    'VHlwZVIKZGV2aWNlVHlwZRIbCgljbGllbnRfaWQYBCABKAlSCGNsaWVudElkEh8KC2xvZ291dF'
    '90aW1lGAUgASgDUgpsb2dvdXRUaW1lEhYKBnJlYXNvbhgGIAEoCVIGcmVhc29u');

