// This is a generated file - do not edit.
//
// Generated from hot_online.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use sessionTokenStatusDescriptor instead')
const SessionTokenStatus$json = {
  '1': 'SessionTokenStatus',
  '2': [
    {'1': 'STS_UNKNOWN', '2': 0},
    {'1': 'STS_ACTIVE', '2': 1},
    {'1': 'STS_REVOKED', '2': 2},
    {'1': 'STS_EXPIRED', '2': 3},
  ],
};

/// Descriptor for `SessionTokenStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sessionTokenStatusDescriptor = $convert.base64Decode(
    'ChJTZXNzaW9uVG9rZW5TdGF0dXMSDwoLU1RTX1VOS05PV04QABIOCgpTVFNfQUNUSVZFEAESDw'
    'oLU1RTX1JFVk9LRUQQAhIPCgtTVFNfRVhQSVJFRBAD');

@$core.Deprecated('Use deviceTypeDescriptor instead')
const DeviceType$json = {
  '1': 'DeviceType',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'MOBILE', '2': 1},
    {'1': 'WEB', '2': 3},
    {'1': 'PC', '2': 4},
  ],
};

/// Descriptor for `DeviceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deviceTypeDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VUeXBlEgsKB1VOS05PV04QABIKCgZNT0JJTEUQARIHCgNXRUIQAxIGCgJQQxAE');

@$core.Deprecated('Use authTypeDescriptor instead')
const AuthType$json = {
  '1': 'AuthType',
  '2': [
    {'1': 'AUTH_TYPE_UNKNOWN', '2': 0},
    {'1': 'AUTH_TYPE_EMAIL', '2': 1},
    {'1': 'AUTH_TYPE_PHONE', '2': 2},
    {'1': 'AUTH_TYPE_USERNAME', '2': 3},
  ],
};

/// Descriptor for `AuthType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List authTypeDescriptor = $convert.base64Decode(
    'CghBdXRoVHlwZRIVChFBVVRIX1RZUEVfVU5LTk9XThAAEhMKD0FVVEhfVFlQRV9FTUFJTBABEh'
    'MKD0FVVEhfVFlQRV9QSE9ORRACEhYKEkFVVEhfVFlQRV9VU0VSTkFNRRAD');

@$core.Deprecated('Use addFriendPolicyDescriptor instead')
const AddFriendPolicy$json = {
  '1': 'AddFriendPolicy',
  '2': [
    {'1': 'ADD_FRIEND_UNSPECIFIED', '2': 0},
    {'1': 'ANYONE', '2': 1},
    {'1': 'REQUIRE_VERIFY', '2': 2},
    {'1': 'PHONE_ONLY', '2': 3},
  ],
};

/// Descriptor for `AddFriendPolicy`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List addFriendPolicyDescriptor = $convert.base64Decode(
    'Cg9BZGRGcmllbmRQb2xpY3kSGgoWQUREX0ZSSUVORF9VTlNQRUNJRklFRBAAEgoKBkFOWU9ORR'
    'ABEhIKDlJFUVVJUkVfVkVSSUZZEAISDgoKUEhPTkVfT05MWRAD');

@$core.Deprecated('Use genderDescriptor instead')
const Gender$json = {
  '1': 'Gender',
  '2': [
    {'1': 'GENDER_UNSPECIFIED', '2': 0},
    {'1': 'MALE', '2': 1},
    {'1': 'FEMALE', '2': 2},
    {'1': 'SECRET', '2': 9},
  ],
};

/// Descriptor for `Gender`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List genderDescriptor = $convert.base64Decode(
    'CgZHZW5kZXISFgoSR0VOREVSX1VOU1BFQ0lGSUVEEAASCAoETUFMRRABEgoKBkZFTUFMRRACEg'
    'oKBlNFQ1JFVBAJ');

@$core.Deprecated('Use userTypeDescriptor instead')
const UserType$json = {
  '1': 'UserType',
  '2': [
    {'1': 'USER_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'NORMAL', '2': 1},
    {'1': 'TEST', '2': 2},
    {'1': 'BOT', '2': 3},
  ],
};

/// Descriptor for `UserType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userTypeDescriptor = $convert.base64Decode(
    'CghVc2VyVHlwZRIZChVVU0VSX1RZUEVfVU5TUEVDSUZJRUQQABIKCgZOT1JNQUwQARIICgRURV'
    'NUEAISBwoDQk9UEAM=');

@$core.Deprecated('Use setOnlineRequestDescriptor instead')
const SetOnlineRequest$json = {
  '1': 'SetOnlineRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'online', '3': 2, '4': 1, '5': 8, '10': 'online'},
  ],
};

/// Descriptor for `SetOnlineRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setOnlineRequestDescriptor = $convert.base64Decode(
    'ChBTZXRPbmxpbmVSZXF1ZXN0EhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBIWCgZvbmxpbmUYAi'
    'ABKAhSBm9ubGluZQ==');

@$core.Deprecated('Use setOnlineResponseDescriptor instead')
const SetOnlineResponse$json = {
  '1': 'SetOnlineResponse',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
  ],
};

/// Descriptor for `SetOnlineResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setOnlineResponseDescriptor = $convert.base64Decode(
    'ChFTZXRPbmxpbmVSZXNwb25zZRIOCgJvaxgBIAEoCFICb2s=');

@$core.Deprecated('Use checkOnlineRequestDescriptor instead')
const CheckOnlineRequest$json = {
  '1': 'CheckOnlineRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
  ],
};

/// Descriptor for `CheckOnlineRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkOnlineRequestDescriptor = $convert.base64Decode(
    'ChJDaGVja09ubGluZVJlcXVlc3QSFwoHdXNlcl9pZBgBIAEoA1IGdXNlcklk');

@$core.Deprecated('Use checkOnlineResponseDescriptor instead')
const CheckOnlineResponse$json = {
  '1': 'CheckOnlineResponse',
  '2': [
    {'1': 'online', '3': 1, '4': 1, '5': 8, '10': 'online'},
  ],
};

/// Descriptor for `CheckOnlineResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkOnlineResponseDescriptor = $convert.base64Decode(
    'ChNDaGVja09ubGluZVJlc3BvbnNlEhYKBm9ubGluZRgBIAEoCFIGb25saW5l');

@$core.Deprecated('Use checkOnlineBatchRequestDescriptor instead')
const CheckOnlineBatchRequest$json = {
  '1': 'CheckOnlineBatchRequest',
  '2': [
    {'1': 'user_ids', '3': 1, '4': 3, '5': 3, '10': 'userIds'},
  ],
};

/// Descriptor for `CheckOnlineBatchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkOnlineBatchRequestDescriptor = $convert.base64Decode(
    'ChdDaGVja09ubGluZUJhdGNoUmVxdWVzdBIZCgh1c2VyX2lkcxgBIAMoA1IHdXNlcklkcw==');

@$core.Deprecated('Use checkOnlineBatchResponseDescriptor instead')
const CheckOnlineBatchResponse$json = {
  '1': 'CheckOnlineBatchResponse',
  '2': [
    {'1': 'results', '3': 1, '4': 3, '5': 8, '10': 'results'},
  ],
};

/// Descriptor for `CheckOnlineBatchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkOnlineBatchResponseDescriptor = $convert.base64Decode(
    'ChhDaGVja09ubGluZUJhdGNoUmVzcG9uc2USGAoHcmVzdWx0cxgBIAMoCFIHcmVzdWx0cw==');

@$core.Deprecated('Use getStatsRequestDescriptor instead')
const GetStatsRequest$json = {
  '1': 'GetStatsRequest',
};

/// Descriptor for `GetStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatsRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRTdGF0c1JlcXVlc3Q=');

@$core.Deprecated('Use getStatsResponseDescriptor instead')
const GetStatsResponse$json = {
  '1': 'GetStatsResponse',
  '2': [
    {'1': 'total', '3': 1, '4': 1, '5': 4, '10': 'total'},
    {'1': 'per_shard', '3': 2, '4': 3, '5': 4, '10': 'perShard'},
    {'1': 'max_shard_idx', '3': 3, '4': 1, '5': 13, '10': 'maxShardIdx'},
    {'1': 'max_shard_count', '3': 4, '4': 1, '5': 4, '10': 'maxShardCount'},
  ],
};

/// Descriptor for `GetStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatsResponseDescriptor = $convert.base64Decode(
    'ChBHZXRTdGF0c1Jlc3BvbnNlEhQKBXRvdGFsGAEgASgEUgV0b3RhbBIbCglwZXJfc2hhcmQYAi'
    'ADKARSCHBlclNoYXJkEiIKDW1heF9zaGFyZF9pZHgYAyABKA1SC21heFNoYXJkSWR4EiYKD21h'
    'eF9zaGFyZF9jb3VudBgEIAEoBFINbWF4U2hhcmRDb3VudA==');

@$core.Deprecated('Use upsertSessionTokenRequestDescriptor instead')
const UpsertSessionTokenRequest$json = {
  '1': 'UpsertSessionTokenRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_type', '3': 2, '4': 1, '5': 14, '6': '.online_service.DeviceType', '10': 'deviceType'},
    {'1': 'device_id', '3': 3, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'login_ip', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'loginIp', '17': true},
    {'1': 'user_agent', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'userAgent', '17': true},
  ],
  '8': [
    {'1': '_login_ip'},
    {'1': '_user_agent'},
  ],
};

/// Descriptor for `UpsertSessionTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List upsertSessionTokenRequestDescriptor = $convert.base64Decode(
    'ChlVcHNlcnRTZXNzaW9uVG9rZW5SZXF1ZXN0EhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBI7Cg'
    'tkZXZpY2VfdHlwZRgCIAEoDjIaLm9ubGluZV9zZXJ2aWNlLkRldmljZVR5cGVSCmRldmljZVR5'
    'cGUSGwoJZGV2aWNlX2lkGAMgASgJUghkZXZpY2VJZBIeCghsb2dpbl9pcBgEIAEoCUgAUgdsb2'
    'dpbklwiAEBEiIKCnVzZXJfYWdlbnQYBSABKAlIAVIJdXNlckFnZW50iAEBQgsKCV9sb2dpbl9p'
    'cEINCgtfdXNlcl9hZ2VudA==');

@$core.Deprecated('Use upsertSessionTokenResponseDescriptor instead')
const UpsertSessionTokenResponse$json = {
  '1': 'UpsertSessionTokenResponse',
  '2': [
    {'1': 'session_token', '3': 1, '4': 1, '5': 9, '10': 'sessionToken'},
    {'1': 'expires_at', '3': 2, '4': 1, '5': 4, '10': 'expiresAt'},
    {'1': 'previous_token', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'previousToken', '17': true},
  ],
  '8': [
    {'1': '_previous_token'},
  ],
};

/// Descriptor for `UpsertSessionTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List upsertSessionTokenResponseDescriptor = $convert.base64Decode(
    'ChpVcHNlcnRTZXNzaW9uVG9rZW5SZXNwb25zZRIjCg1zZXNzaW9uX3Rva2VuGAEgASgJUgxzZX'
    'NzaW9uVG9rZW4SHQoKZXhwaXJlc19hdBgCIAEoBFIJZXhwaXJlc0F0EioKDnByZXZpb3VzX3Rv'
    'a2VuGAMgASgJSABSDXByZXZpb3VzVG9rZW6IAQFCEQoPX3ByZXZpb3VzX3Rva2Vu');

@$core.Deprecated('Use validateSessionTokenRequestDescriptor instead')
const ValidateSessionTokenRequest$json = {
  '1': 'ValidateSessionTokenRequest',
  '2': [
    {'1': 'session_token', '3': 1, '4': 1, '5': 9, '10': 'sessionToken'},
  ],
};

/// Descriptor for `ValidateSessionTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateSessionTokenRequestDescriptor = $convert.base64Decode(
    'ChtWYWxpZGF0ZVNlc3Npb25Ub2tlblJlcXVlc3QSIwoNc2Vzc2lvbl90b2tlbhgBIAEoCVIMc2'
    'Vzc2lvblRva2Vu');

@$core.Deprecated('Use validateSessionTokenResponseDescriptor instead')
const ValidateSessionTokenResponse$json = {
  '1': 'ValidateSessionTokenResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 14, '6': '.online_service.SessionTokenStatus', '10': 'status'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 14, '6': '.online_service.DeviceType', '10': 'deviceType'},
    {'1': 'device_id', '3': 4, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'expires_at', '3': 5, '4': 1, '5': 4, '10': 'expiresAt'},
  ],
};

/// Descriptor for `ValidateSessionTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateSessionTokenResponseDescriptor = $convert.base64Decode(
    'ChxWYWxpZGF0ZVNlc3Npb25Ub2tlblJlc3BvbnNlEjoKBnN0YXR1cxgBIAEoDjIiLm9ubGluZV'
    '9zZXJ2aWNlLlNlc3Npb25Ub2tlblN0YXR1c1IGc3RhdHVzEhcKB3VzZXJfaWQYAiABKANSBnVz'
    'ZXJJZBI7CgtkZXZpY2VfdHlwZRgDIAEoDjIaLm9ubGluZV9zZXJ2aWNlLkRldmljZVR5cGVSCm'
    'RldmljZVR5cGUSGwoJZGV2aWNlX2lkGAQgASgJUghkZXZpY2VJZBIdCgpleHBpcmVzX2F0GAUg'
    'ASgEUglleHBpcmVzQXQ=');

@$core.Deprecated('Use tokenDeviceRefDescriptor instead')
const TokenDeviceRef$json = {
  '1': 'TokenDeviceRef',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_type', '3': 2, '4': 1, '5': 14, '6': '.online_service.DeviceType', '10': 'deviceType'},
    {'1': 'device_id', '3': 3, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `TokenDeviceRef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenDeviceRefDescriptor = $convert.base64Decode(
    'Cg5Ub2tlbkRldmljZVJlZhIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySWQSOwoLZGV2aWNlX3R5cG'
    'UYAiABKA4yGi5vbmxpbmVfc2VydmljZS5EZXZpY2VUeXBlUgpkZXZpY2VUeXBlEhsKCWRldmlj'
    'ZV9pZBgDIAEoCVIIZGV2aWNlSWQ=');

@$core.Deprecated('Use revokeSessionTokenRequestDescriptor instead')
const RevokeSessionTokenRequest$json = {
  '1': 'RevokeSessionTokenRequest',
  '2': [
    {'1': 'session_token', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'sessionToken'},
    {'1': 'device', '3': 2, '4': 1, '5': 11, '6': '.online_service.TokenDeviceRef', '9': 0, '10': 'device'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'reason', '17': true},
  ],
  '8': [
    {'1': 'target'},
    {'1': '_reason'},
  ],
};

/// Descriptor for `RevokeSessionTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeSessionTokenRequestDescriptor = $convert.base64Decode(
    'ChlSZXZva2VTZXNzaW9uVG9rZW5SZXF1ZXN0EiUKDXNlc3Npb25fdG9rZW4YASABKAlIAFIMc2'
    'Vzc2lvblRva2VuEjgKBmRldmljZRgCIAEoCzIeLm9ubGluZV9zZXJ2aWNlLlRva2VuRGV2aWNl'
    'UmVmSABSBmRldmljZRIbCgZyZWFzb24YAyABKAlIAVIGcmVhc29uiAEBQggKBnRhcmdldEIJCg'
    'dfcmVhc29u');

@$core.Deprecated('Use revokeSessionTokenResponseDescriptor instead')
const RevokeSessionTokenResponse$json = {
  '1': 'RevokeSessionTokenResponse',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'revoked_token', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'revokedToken', '17': true},
  ],
  '8': [
    {'1': '_revoked_token'},
  ],
};

/// Descriptor for `RevokeSessionTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeSessionTokenResponseDescriptor = $convert.base64Decode(
    'ChpSZXZva2VTZXNzaW9uVG9rZW5SZXNwb25zZRIOCgJvaxgBIAEoCFICb2sSKAoNcmV2b2tlZF'
    '90b2tlbhgCIAEoCUgAUgxyZXZva2VkVG9rZW6IAQFCEAoOX3Jldm9rZWRfdG9rZW4=');

@$core.Deprecated('Use touchSessionTokenRequestDescriptor instead')
const TouchSessionTokenRequest$json = {
  '1': 'TouchSessionTokenRequest',
  '2': [
    {'1': 'session_tokens', '3': 1, '4': 3, '5': 9, '10': 'sessionTokens'},
  ],
};

/// Descriptor for `TouchSessionTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List touchSessionTokenRequestDescriptor = $convert.base64Decode(
    'ChhUb3VjaFNlc3Npb25Ub2tlblJlcXVlc3QSJQoOc2Vzc2lvbl90b2tlbnMYASADKAlSDXNlc3'
    'Npb25Ub2tlbnM=');

@$core.Deprecated('Use touchSessionTokenResponseDescriptor instead')
const TouchSessionTokenResponse$json = {
  '1': 'TouchSessionTokenResponse',
  '2': [
    {'1': 'touched', '3': 1, '4': 1, '5': 13, '10': 'touched'},
  ],
};

/// Descriptor for `TouchSessionTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List touchSessionTokenResponseDescriptor = $convert.base64Decode(
    'ChlUb3VjaFNlc3Npb25Ub2tlblJlc3BvbnNlEhgKB3RvdWNoZWQYASABKA1SB3RvdWNoZWQ=');

@$core.Deprecated('Use loginReqMsgDescriptor instead')
const LoginReqMsg$json = {
  '1': 'LoginReqMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'auth_type', '3': 2, '4': 1, '5': 14, '6': '.online_service.AuthType', '10': 'authType'},
    {'1': 'auth_content', '3': 3, '4': 1, '5': 9, '10': 'authContent'},
    {'1': 'password', '3': 4, '4': 1, '5': 9, '10': 'password'},
    {'1': 'device_type', '3': 5, '4': 1, '5': 14, '6': '.online_service.DeviceType', '10': 'deviceType'},
  ],
};

/// Descriptor for `LoginReqMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginReqMsgDescriptor = $convert.base64Decode(
    'CgtMb2dpblJlcU1zZxIOCgJpZBgBIAEoA1ICaWQSNQoJYXV0aF90eXBlGAIgASgOMhgub25saW'
    '5lX3NlcnZpY2UuQXV0aFR5cGVSCGF1dGhUeXBlEiEKDGF1dGhfY29udGVudBgDIAEoCVILYXV0'
    'aENvbnRlbnQSGgoIcGFzc3dvcmQYBCABKAlSCHBhc3N3b3JkEjsKC2RldmljZV90eXBlGAUgAS'
    'gOMhoub25saW5lX3NlcnZpY2UuRGV2aWNlVHlwZVIKZGV2aWNlVHlwZQ==');

@$core.Deprecated('Use loginRespMsgDescriptor instead')
const LoginRespMsg$json = {
  '1': 'LoginRespMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    {'1': 'expires_at', '3': 3, '4': 1, '5': 4, '10': 'expiresAt'},
    {'1': 'success', '3': 4, '4': 1, '5': 8, '10': 'success'},
    {'1': 'msg', '3': 5, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'uid', '3': 6, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'nickname', '3': 7, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar', '3': 8, '4': 1, '5': 9, '10': 'avatar'},
  ],
};

/// Descriptor for `LoginRespMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRespMsgDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlc3BNc2cSDgoCaWQYASABKANSAmlkEhQKBXRva2VuGAIgASgJUgV0b2tlbhIdCg'
    'pleHBpcmVzX2F0GAMgASgEUglleHBpcmVzQXQSGAoHc3VjY2VzcxgEIAEoCFIHc3VjY2VzcxIQ'
    'CgNtc2cYBSABKAlSA21zZxIQCgN1aWQYBiABKANSA3VpZBIaCghuaWNrbmFtZRgHIAEoCVIIbm'
    'lja25hbWUSFgoGYXZhdGFyGAggASgJUgZhdmF0YXI=');

@$core.Deprecated('Use logoutReqMsgDescriptor instead')
const LogoutReqMsg$json = {
  '1': 'LogoutReqMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `LogoutReqMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logoutReqMsgDescriptor = $convert.base64Decode(
    'CgxMb2dvdXRSZXFNc2cSDgoCaWQYASABKANSAmlk');

@$core.Deprecated('Use logoutRespMsgDescriptor instead')
const LogoutRespMsg$json = {
  '1': 'LogoutRespMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `LogoutRespMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logoutRespMsgDescriptor = $convert.base64Decode(
    'Cg1Mb2dvdXRSZXNwTXNnEg4KAmlkGAEgASgDUgJpZA==');

@$core.Deprecated('Use sendVerificationCodeReqMsgDescriptor instead')
const SendVerificationCodeReqMsg$json = {
  '1': 'SendVerificationCodeReqMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'receiver', '3': 2, '4': 1, '5': 9, '10': 'receiver'},
    {'1': 'channel', '3': 3, '4': 1, '5': 9, '10': 'channel'},
    {'1': 'scene', '3': 4, '4': 1, '5': 9, '10': 'scene'},
    {'1': 'uid', '3': 5, '4': 1, '5': 3, '10': 'uid'},
  ],
};

/// Descriptor for `SendVerificationCodeReqMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendVerificationCodeReqMsgDescriptor = $convert.base64Decode(
    'ChpTZW5kVmVyaWZpY2F0aW9uQ29kZVJlcU1zZxIOCgJpZBgBIAEoA1ICaWQSGgoIcmVjZWl2ZX'
    'IYAiABKAlSCHJlY2VpdmVyEhgKB2NoYW5uZWwYAyABKAlSB2NoYW5uZWwSFAoFc2NlbmUYBCAB'
    'KAlSBXNjZW5lEhAKA3VpZBgFIAEoA1IDdWlk');

@$core.Deprecated('Use sendVerificationCodeRepMsgDescriptor instead')
const SendVerificationCodeRepMsg$json = {
  '1': 'SendVerificationCodeRepMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'success', '3': 2, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'expired_in', '3': 4, '4': 1, '5': 3, '10': 'expiredIn'},
  ],
};

/// Descriptor for `SendVerificationCodeRepMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendVerificationCodeRepMsgDescriptor = $convert.base64Decode(
    'ChpTZW5kVmVyaWZpY2F0aW9uQ29kZVJlcE1zZxIOCgJpZBgBIAEoA1ICaWQSGAoHc3VjY2Vzcx'
    'gCIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAMgASgJUgdtZXNzYWdlEh0KCmV4cGlyZWRfaW4Y'
    'BCABKANSCWV4cGlyZWRJbg==');

@$core.Deprecated('Use onlineStatusMsgDescriptor instead')
const OnlineStatusMsg$json = {
  '1': 'OnlineStatusMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'uid', '3': 2, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 14, '6': '.online_service.DeviceType', '10': 'deviceType'},
    {'1': 'client_id', '3': 4, '4': 1, '5': 3, '10': 'clientId'},
    {'1': 'login_time', '3': 5, '4': 1, '5': 3, '10': 'loginTime'},
  ],
};

/// Descriptor for `OnlineStatusMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onlineStatusMsgDescriptor = $convert.base64Decode(
    'Cg9PbmxpbmVTdGF0dXNNc2cSDgoCaWQYASABKANSAmlkEhAKA3VpZBgCIAEoA1IDdWlkEjsKC2'
    'RldmljZV90eXBlGAMgASgOMhoub25saW5lX3NlcnZpY2UuRGV2aWNlVHlwZVIKZGV2aWNlVHlw'
    'ZRIbCgljbGllbnRfaWQYBCABKANSCGNsaWVudElkEh0KCmxvZ2luX3RpbWUYBSABKANSCWxvZ2'
    'luVGltZQ==');

@$core.Deprecated('Use offlineStatueMsgDescriptor instead')
const OfflineStatueMsg$json = {
  '1': 'OfflineStatueMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'uid', '3': 2, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 14, '6': '.online_service.DeviceType', '10': 'deviceType'},
    {'1': 'client_id', '3': 4, '4': 1, '5': 3, '10': 'clientId'},
    {'1': 'logout_time', '3': 5, '4': 1, '5': 3, '10': 'logoutTime'},
    {'1': 'reason', '3': 6, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `OfflineStatueMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List offlineStatueMsgDescriptor = $convert.base64Decode(
    'ChBPZmZsaW5lU3RhdHVlTXNnEg4KAmlkGAEgASgDUgJpZBIQCgN1aWQYAiABKAlSA3VpZBI7Cg'
    'tkZXZpY2VfdHlwZRgDIAEoDjIaLm9ubGluZV9zZXJ2aWNlLkRldmljZVR5cGVSCmRldmljZVR5'
    'cGUSGwoJY2xpZW50X2lkGAQgASgDUghjbGllbnRJZBIfCgtsb2dvdXRfdGltZRgFIAEoA1IKbG'
    '9nb3V0VGltZRIWCgZyZWFzb24YBiABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use clientEntityDescriptor instead')
const ClientEntity$json = {
  '1': 'ClientEntity',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'email', '17': true},
    {'1': 'phone', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'phone', '17': true},
    {'1': 'language', '3': 6, '4': 1, '5': 9, '9': 2, '10': 'language', '17': true},
    {'1': 'avatar', '3': 7, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'allow_add_friend', '3': 8, '4': 1, '5': 14, '6': '.online_service.AddFriendPolicy', '10': 'allowAddFriend'},
    {'1': 'gender', '3': 9, '4': 1, '5': 14, '6': '.online_service.Gender', '10': 'gender'},
    {'1': 'user_type', '3': 10, '4': 1, '5': 14, '6': '.online_service.UserType', '10': 'userType'},
    {'1': 'profile_fields', '3': 11, '4': 3, '5': 11, '6': '.online_service.ClientEntity.ProfileFieldsEntry', '10': 'profileFields'},
    {'1': 'create_time', '3': 12, '4': 1, '5': 3, '10': 'createTime'},
    {'1': 'update_time', '3': 13, '4': 1, '5': 3, '10': 'updateTime'},
    {'1': 'version', '3': 14, '4': 1, '5': 5, '10': 'version'},
  ],
  '3': [ClientEntity_ProfileFieldsEntry$json],
  '8': [
    {'1': '_email'},
    {'1': '_phone'},
    {'1': '_language'},
  ],
  '9': [
    {'1': 100, '2': 120},
  ],
};

@$core.Deprecated('Use clientEntityDescriptor instead')
const ClientEntity_ProfileFieldsEntry$json = {
  '1': 'ProfileFieldsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ClientEntity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientEntityDescriptor = $convert.base64Decode(
    'CgxDbGllbnRFbnRpdHkSDgoCaWQYASABKANSAmlkEhoKCHBhc3N3b3JkGAIgASgJUghwYXNzd2'
    '9yZBISCgRuYW1lGAMgASgJUgRuYW1lEhkKBWVtYWlsGAQgASgJSABSBWVtYWlsiAEBEhkKBXBo'
    'b25lGAUgASgJSAFSBXBob25liAEBEh8KCGxhbmd1YWdlGAYgASgJSAJSCGxhbmd1YWdliAEBEh'
    'YKBmF2YXRhchgHIAEoCVIGYXZhdGFyEkkKEGFsbG93X2FkZF9mcmllbmQYCCABKA4yHy5vbmxp'
    'bmVfc2VydmljZS5BZGRGcmllbmRQb2xpY3lSDmFsbG93QWRkRnJpZW5kEi4KBmdlbmRlchgJIA'
    'EoDjIWLm9ubGluZV9zZXJ2aWNlLkdlbmRlclIGZ2VuZGVyEjUKCXVzZXJfdHlwZRgKIAEoDjIY'
    'Lm9ubGluZV9zZXJ2aWNlLlVzZXJUeXBlUgh1c2VyVHlwZRJWCg5wcm9maWxlX2ZpZWxkcxgLIA'
    'MoCzIvLm9ubGluZV9zZXJ2aWNlLkNsaWVudEVudGl0eS5Qcm9maWxlRmllbGRzRW50cnlSDXBy'
    'b2ZpbGVGaWVsZHMSHwoLY3JlYXRlX3RpbWUYDCABKANSCmNyZWF0ZVRpbWUSHwoLdXBkYXRlX3'
    'RpbWUYDSABKANSCnVwZGF0ZVRpbWUSGAoHdmVyc2lvbhgOIAEoBVIHdmVyc2lvbhpAChJQcm9m'
    'aWxlRmllbGRzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOg'
    'I4AUIICgZfZW1haWxCCAoGX3Bob25lQgsKCV9sYW5ndWFnZUoECGQQeA==');

@$core.Deprecated('Use findClientDtoDescriptor instead')
const FindClientDto$json = {
  '1': 'FindClientDto',
  '2': [
    {'1': 'client', '3': 1, '4': 1, '5': 11, '6': '.online_service.ClientEntity', '9': 0, '10': 'client', '17': true},
  ],
  '8': [
    {'1': '_client'},
  ],
};

/// Descriptor for `FindClientDto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List findClientDtoDescriptor = $convert.base64Decode(
    'Cg1GaW5kQ2xpZW50RHRvEjkKBmNsaWVudBgBIAEoCzIcLm9ubGluZV9zZXJ2aWNlLkNsaWVudE'
    'VudGl0eUgAUgZjbGllbnSIAQFCCQoHX2NsaWVudA==');

@$core.Deprecated('Use registerUserReqDescriptor instead')
const RegisterUserReq$json = {
  '1': 'RegisterUserReq',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'email', '17': true},
    {'1': 'phone', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'phone', '17': true},
    {'1': 'language', '3': 6, '4': 1, '5': 9, '9': 2, '10': 'language', '17': true},
    {'1': 'avatar', '3': 7, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'allow_add_friend', '3': 8, '4': 1, '5': 14, '6': '.online_service.AddFriendPolicy', '10': 'allowAddFriend'},
    {'1': 'gender', '3': 9, '4': 1, '5': 14, '6': '.online_service.Gender', '10': 'gender'},
    {'1': 'user_type', '3': 10, '4': 1, '5': 14, '6': '.online_service.UserType', '10': 'userType'},
    {'1': 'profile_fields', '3': 11, '4': 3, '5': 11, '6': '.online_service.RegisterUserReq.ProfileFieldsEntry', '10': 'profileFields'},
  ],
  '3': [RegisterUserReq_ProfileFieldsEntry$json],
  '8': [
    {'1': '_email'},
    {'1': '_phone'},
    {'1': '_language'},
  ],
};

@$core.Deprecated('Use registerUserReqDescriptor instead')
const RegisterUserReq_ProfileFieldsEntry$json = {
  '1': 'ProfileFieldsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `RegisterUserReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerUserReqDescriptor = $convert.base64Decode(
    'Cg9SZWdpc3RlclVzZXJSZXESEgoEbmFtZRgBIAEoCVIEbmFtZRIaCghwYXNzd29yZBgCIAEoCV'
    'IIcGFzc3dvcmQSGQoFZW1haWwYBCABKAlIAFIFZW1haWyIAQESGQoFcGhvbmUYBSABKAlIAVIF'
    'cGhvbmWIAQESHwoIbGFuZ3VhZ2UYBiABKAlIAlIIbGFuZ3VhZ2WIAQESFgoGYXZhdGFyGAcgAS'
    'gJUgZhdmF0YXISSQoQYWxsb3dfYWRkX2ZyaWVuZBgIIAEoDjIfLm9ubGluZV9zZXJ2aWNlLkFk'
    'ZEZyaWVuZFBvbGljeVIOYWxsb3dBZGRGcmllbmQSLgoGZ2VuZGVyGAkgASgOMhYub25saW5lX3'
    'NlcnZpY2UuR2VuZGVyUgZnZW5kZXISNQoJdXNlcl90eXBlGAogASgOMhgub25saW5lX3NlcnZp'
    'Y2UuVXNlclR5cGVSCHVzZXJUeXBlElkKDnByb2ZpbGVfZmllbGRzGAsgAygLMjIub25saW5lX3'
    'NlcnZpY2UuUmVnaXN0ZXJVc2VyUmVxLlByb2ZpbGVGaWVsZHNFbnRyeVINcHJvZmlsZUZpZWxk'
    'cxpAChJQcm9maWxlRmllbGRzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKA'
    'lSBXZhbHVlOgI4AUIICgZfZW1haWxCCAoGX3Bob25lQgsKCV9sYW5ndWFnZQ==');

@$core.Deprecated('Use changePasswordReqDescriptor instead')
const ChangePasswordReq$json = {
  '1': 'ChangePasswordReq',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'old_password', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'oldPassword', '17': true},
    {'1': 'new_password', '3': 3, '4': 1, '5': 9, '10': 'newPassword'},
    {'1': 'verify_token', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'verifyToken', '17': true},
  ],
  '8': [
    {'1': '_old_password'},
    {'1': '_verify_token'},
  ],
};

/// Descriptor for `ChangePasswordReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePasswordReqDescriptor = $convert.base64Decode(
    'ChFDaGFuZ2VQYXNzd29yZFJlcRIOCgJpZBgBIAEoA1ICaWQSJgoMb2xkX3Bhc3N3b3JkGAIgAS'
    'gJSABSC29sZFBhc3N3b3JkiAEBEiEKDG5ld19wYXNzd29yZBgDIAEoCVILbmV3UGFzc3dvcmQS'
    'JgoMdmVyaWZ5X3Rva2VuGAQgASgJSAFSC3ZlcmlmeVRva2VuiAEBQg8KDV9vbGRfcGFzc3dvcm'
    'RCDwoNX3ZlcmlmeV90b2tlbg==');

@$core.Deprecated('Use changePhoneReqDescriptor instead')
const ChangePhoneReq$json = {
  '1': 'ChangePhoneReq',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'new_phone', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'newPhone', '17': true},
    {'1': 'verify_token', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'verifyToken', '17': true},
  ],
  '8': [
    {'1': '_new_phone'},
    {'1': '_verify_token'},
  ],
};

/// Descriptor for `ChangePhoneReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePhoneReqDescriptor = $convert.base64Decode(
    'Cg5DaGFuZ2VQaG9uZVJlcRIOCgJpZBgBIAEoA1ICaWQSIAoJbmV3X3Bob25lGAIgASgJSABSCG'
    '5ld1Bob25liAEBEiYKDHZlcmlmeV90b2tlbhgDIAEoCUgBUgt2ZXJpZnlUb2tlbogBAUIMCgpf'
    'bmV3X3Bob25lQg8KDV92ZXJpZnlfdG9rZW4=');

@$core.Deprecated('Use changeEmailReqDescriptor instead')
const ChangeEmailReq$json = {
  '1': 'ChangeEmailReq',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'new_email', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'newEmail', '17': true},
    {'1': 'verify_token', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'verifyToken', '17': true},
  ],
  '8': [
    {'1': '_new_email'},
    {'1': '_verify_token'},
  ],
};

/// Descriptor for `ChangeEmailReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeEmailReqDescriptor = $convert.base64Decode(
    'Cg5DaGFuZ2VFbWFpbFJlcRIOCgJpZBgBIAEoA1ICaWQSIAoJbmV3X2VtYWlsGAIgASgJSABSCG'
    '5ld0VtYWlsiAEBEiYKDHZlcmlmeV90b2tlbhgDIAEoCUgBUgt2ZXJpZnlUb2tlbogBAUIMCgpf'
    'bmV3X2VtYWlsQg8KDV92ZXJpZnlfdG9rZW4=');

@$core.Deprecated('Use updateClientReqDescriptor instead')
const UpdateClientReq$json = {
  '1': 'UpdateClientReq',
  '2': [
    {'1': 'patch', '3': 1, '4': 1, '5': 11, '6': '.online_service.ClientEntity', '10': 'patch'},
    {'1': 'update_mask', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.FieldMask', '10': 'updateMask'},
  ],
};

/// Descriptor for `UpdateClientReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateClientReqDescriptor = $convert.base64Decode(
    'Cg9VcGRhdGVDbGllbnRSZXESMgoFcGF0Y2gYASABKAsyHC5vbmxpbmVfc2VydmljZS5DbGllbn'
    'RFbnRpdHlSBXBhdGNoEjsKC3VwZGF0ZV9tYXNrGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLkZp'
    'ZWxkTWFza1IKdXBkYXRlTWFzaw==');

@$core.Deprecated('Use getClientReqDescriptor instead')
const GetClientReq$json = {
  '1': 'GetClientReq',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `GetClientReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getClientReqDescriptor = $convert.base64Decode(
    'CgxHZXRDbGllbnRSZXESDgoCaWQYASABKANSAmlk');

@$core.Deprecated('Use changeResponseDescriptor instead')
const ChangeResponse$json = {
  '1': 'ChangeResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `ChangeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeResponseDescriptor = $convert.base64Decode(
    'Cg5DaGFuZ2VSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNz');

@$core.Deprecated('Use findByContentReqDescriptor instead')
const FindByContentReq$json = {
  '1': 'FindByContentReq',
  '2': [
    {'1': 'content', '3': 1, '4': 1, '5': 9, '10': 'content'},
  ],
};

/// Descriptor for `FindByContentReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List findByContentReqDescriptor = $convert.base64Decode(
    'ChBGaW5kQnlDb250ZW50UmVxEhgKB2NvbnRlbnQYASABKAlSB2NvbnRlbnQ=');

