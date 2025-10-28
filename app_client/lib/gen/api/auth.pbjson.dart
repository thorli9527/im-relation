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

@$core.Deprecated('Use userSearchTypeDescriptor instead')
const UserSearchType$json = {
  '1': 'UserSearchType',
  '2': [
    {'1': 'USER_SEARCH_UNKNOWN', '2': 0},
    {'1': 'USER_SEARCH_USER_ID', '2': 1},
    {'1': 'USER_SEARCH_USERNAME', '2': 2},
    {'1': 'USER_SEARCH_EMAIL', '2': 3},
    {'1': 'USER_SEARCH_PHONE', '2': 4},
  ],
};

/// Descriptor for `UserSearchType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userSearchTypeDescriptor = $convert.base64Decode(
    'Cg5Vc2VyU2VhcmNoVHlwZRIXChNVU0VSX1NFQVJDSF9VTktOT1dOEAASFwoTVVNFUl9TRUFSQ0'
    'hfVVNFUl9JRBABEhgKFFVTRVJfU0VBUkNIX1VTRVJOQU1FEAISFQoRVVNFUl9TRUFSQ0hfRU1B'
    'SUwQAxIVChFVU0VSX1NFQVJDSF9QSE9ORRAE');

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

@$core.Deprecated('Use buildRegisterCodeRequestDescriptor instead')
const BuildRegisterCodeRequest$json = {
  '1': 'BuildRegisterCodeRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'reg_type', '3': 3, '4': 1, '5': 5, '10': 'regType'},
    {'1': 'target', '3': 4, '4': 1, '5': 9, '10': 'target'},
  ],
};

/// Descriptor for `BuildRegisterCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildRegisterCodeRequestDescriptor = $convert.base64Decode(
    'ChhCdWlsZFJlZ2lzdGVyQ29kZVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIaCghwYXNzd2'
    '9yZBgCIAEoCVIIcGFzc3dvcmQSGQoIcmVnX3R5cGUYAyABKAVSB3JlZ1R5cGUSFgoGdGFyZ2V0'
    'GAQgASgJUgZ0YXJnZXQ=');

@$core.Deprecated('Use buildRegisterCodeResponseDescriptor instead')
const BuildRegisterCodeResponse$json = {
  '1': 'BuildRegisterCodeResponse',
  '2': [
    {'1': 'reg_id', '3': 1, '4': 1, '5': 9, '10': 'regId'},
    {'1': 'uid', '3': 2, '4': 1, '5': 3, '10': 'uid'},
  ],
};

/// Descriptor for `BuildRegisterCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildRegisterCodeResponseDescriptor = $convert.base64Decode(
    'ChlCdWlsZFJlZ2lzdGVyQ29kZVJlc3BvbnNlEhUKBnJlZ19pZBgBIAEoCVIFcmVnSWQSEAoDdW'
    'lkGAIgASgDUgN1aWQ=');

@$core.Deprecated('Use verifyRegisterCodeRequestDescriptor instead')
const VerifyRegisterCodeRequest$json = {
  '1': 'VerifyRegisterCodeRequest',
  '2': [
    {'1': 'reg_id', '3': 1, '4': 1, '5': 9, '10': 'regId'},
    {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `VerifyRegisterCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyRegisterCodeRequestDescriptor = $convert.base64Decode(
    'ChlWZXJpZnlSZWdpc3RlckNvZGVSZXF1ZXN0EhUKBnJlZ19pZBgBIAEoCVIFcmVnSWQSEgoEY2'
    '9kZRgCIAEoCVIEY29kZQ==');

@$core.Deprecated('Use verifyRegisterCodeResponseDescriptor instead')
const VerifyRegisterCodeResponse$json = {
  '1': 'VerifyRegisterCodeResponse',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
  ],
};

/// Descriptor for `VerifyRegisterCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyRegisterCodeResponseDescriptor = $convert.base64Decode(
    'ChpWZXJpZnlSZWdpc3RlckNvZGVSZXNwb25zZRIOCgJvaxgBIAEoCFICb2s=');

@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = {
  '1': 'LoginRequest',
  '2': [
    {'1': 'login_type', '3': 1, '4': 1, '5': 5, '10': 'loginType'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'target', '3': 3, '4': 1, '5': 9, '10': 'target'},
    {'1': 'device_type', '3': 4, '4': 1, '5': 5, '10': 'deviceType'},
    {'1': 'device_id', '3': 5, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSHQoKbG9naW5fdHlwZRgBIAEoBVIJbG9naW5UeXBlEhoKCHBhc3N3b3'
    'JkGAIgASgJUghwYXNzd29yZBIWCgZ0YXJnZXQYAyABKAlSBnRhcmdldBIfCgtkZXZpY2VfdHlw'
    'ZRgEIAEoBVIKZGV2aWNlVHlwZRIbCglkZXZpY2VfaWQYBSABKAlSCGRldmljZUlk');

@$core.Deprecated('Use loginResponseDescriptor instead')
const LoginResponse$json = {
  '1': 'LoginResponse',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {'1': 'expires_at', '3': 2, '4': 1, '5': 4, '10': 'expiresAt'},
    {'1': 'socket_addr', '3': 3, '4': 1, '5': 9, '10': 'socketAddr'},
  ],
};

/// Descriptor for `LoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginResponseDescriptor = $convert.base64Decode(
    'Cg1Mb2dpblJlc3BvbnNlEhQKBXRva2VuGAEgASgJUgV0b2tlbhIdCgpleHBpcmVzX2F0GAIgAS'
    'gEUglleHBpcmVzQXQSHwoLc29ja2V0X2FkZHIYAyABKAlSCnNvY2tldEFkZHI=');

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
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'expires_at', '3': 3, '4': 1, '5': 4, '10': 'expiresAt'},
    {'1': 'token', '3': 4, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `ValidateSessionTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateSessionTokenResponseDescriptor = $convert.base64Decode(
    'ChxWYWxpZGF0ZVNlc3Npb25Ub2tlblJlc3BvbnNlEg4KAm9rGAEgASgIUgJvaxIXCgd1c2VyX2'
    'lkGAIgASgDUgZ1c2VySWQSHQoKZXhwaXJlc19hdBgDIAEoBFIJZXhwaXJlc0F0EhQKBXRva2Vu'
    'GAQgASgJUgV0b2tlbg==');

@$core.Deprecated('Use changePasswordRequestDescriptor instead')
const ChangePasswordRequest$json = {
  '1': 'ChangePasswordRequest',
  '2': [
    {'1': 'session_token', '3': 1, '4': 1, '5': 9, '10': 'sessionToken'},
    {'1': 'old_password', '3': 2, '4': 1, '5': 9, '10': 'oldPassword'},
    {'1': 'new_password', '3': 3, '4': 1, '5': 9, '10': 'newPassword'},
  ],
};

/// Descriptor for `ChangePasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePasswordRequestDescriptor = $convert.base64Decode(
    'ChVDaGFuZ2VQYXNzd29yZFJlcXVlc3QSIwoNc2Vzc2lvbl90b2tlbhgBIAEoCVIMc2Vzc2lvbl'
    'Rva2VuEiEKDG9sZF9wYXNzd29yZBgCIAEoCVILb2xkUGFzc3dvcmQSIQoMbmV3X3Bhc3N3b3Jk'
    'GAMgASgJUgtuZXdQYXNzd29yZA==');

@$core.Deprecated('Use changePasswordResponseDescriptor instead')
const ChangePasswordResponse$json = {
  '1': 'ChangePasswordResponse',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
  ],
};

/// Descriptor for `ChangePasswordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePasswordResponseDescriptor = $convert.base64Decode(
    'ChZDaGFuZ2VQYXNzd29yZFJlc3BvbnNlEg4KAm9rGAEgASgIUgJvaw==');

@$core.Deprecated('Use changePhoneRequestDescriptor instead')
const ChangePhoneRequest$json = {
  '1': 'ChangePhoneRequest',
  '2': [
    {'1': 'session_token', '3': 1, '4': 1, '5': 9, '10': 'sessionToken'},
    {'1': 'new_phone', '3': 2, '4': 1, '5': 9, '10': 'newPhone'},
    {'1': 'old_phone_code', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'oldPhoneCode', '17': true},
    {'1': 'new_phone_code', '3': 4, '4': 1, '5': 9, '10': 'newPhoneCode'},
  ],
  '8': [
    {'1': '_old_phone_code'},
  ],
};

/// Descriptor for `ChangePhoneRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePhoneRequestDescriptor = $convert.base64Decode(
    'ChJDaGFuZ2VQaG9uZVJlcXVlc3QSIwoNc2Vzc2lvbl90b2tlbhgBIAEoCVIMc2Vzc2lvblRva2'
    'VuEhsKCW5ld19waG9uZRgCIAEoCVIIbmV3UGhvbmUSKQoOb2xkX3Bob25lX2NvZGUYAyABKAlI'
    'AFIMb2xkUGhvbmVDb2RliAEBEiQKDm5ld19waG9uZV9jb2RlGAQgASgJUgxuZXdQaG9uZUNvZG'
    'VCEQoPX29sZF9waG9uZV9jb2Rl');

@$core.Deprecated('Use changePhoneResponseDescriptor instead')
const ChangePhoneResponse$json = {
  '1': 'ChangePhoneResponse',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'phone', '3': 2, '4': 1, '5': 9, '10': 'phone'},
  ],
};

/// Descriptor for `ChangePhoneResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePhoneResponseDescriptor = $convert.base64Decode(
    'ChNDaGFuZ2VQaG9uZVJlc3BvbnNlEg4KAm9rGAEgASgIUgJvaxIUCgVwaG9uZRgCIAEoCVIFcG'
    'hvbmU=');

@$core.Deprecated('Use changeEmailRequestDescriptor instead')
const ChangeEmailRequest$json = {
  '1': 'ChangeEmailRequest',
  '2': [
    {'1': 'session_token', '3': 1, '4': 1, '5': 9, '10': 'sessionToken'},
    {'1': 'new_email', '3': 2, '4': 1, '5': 9, '10': 'newEmail'},
    {'1': 'old_email_code', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'oldEmailCode', '17': true},
    {'1': 'new_email_code', '3': 4, '4': 1, '5': 9, '10': 'newEmailCode'},
  ],
  '8': [
    {'1': '_old_email_code'},
  ],
};

/// Descriptor for `ChangeEmailRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeEmailRequestDescriptor = $convert.base64Decode(
    'ChJDaGFuZ2VFbWFpbFJlcXVlc3QSIwoNc2Vzc2lvbl90b2tlbhgBIAEoCVIMc2Vzc2lvblRva2'
    'VuEhsKCW5ld19lbWFpbBgCIAEoCVIIbmV3RW1haWwSKQoOb2xkX2VtYWlsX2NvZGUYAyABKAlI'
    'AFIMb2xkRW1haWxDb2RliAEBEiQKDm5ld19lbWFpbF9jb2RlGAQgASgJUgxuZXdFbWFpbENvZG'
    'VCEQoPX29sZF9lbWFpbF9jb2Rl');

@$core.Deprecated('Use changeEmailResponseDescriptor instead')
const ChangeEmailResponse$json = {
  '1': 'ChangeEmailResponse',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '10': 'email'},
  ],
};

/// Descriptor for `ChangeEmailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeEmailResponseDescriptor = $convert.base64Decode(
    'ChNDaGFuZ2VFbWFpbFJlc3BvbnNlEg4KAm9rGAEgASgIUgJvaxIUCgVlbWFpbBgCIAEoCVIFZW'
    '1haWw=');

@$core.Deprecated('Use updateProfileRequestDescriptor instead')
const UpdateProfileRequest$json = {
  '1': 'UpdateProfileRequest',
  '2': [
    {'1': 'session_token', '3': 1, '4': 1, '5': 9, '10': 'sessionToken'},
    {'1': 'avatar', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'avatar', '17': true},
    {'1': 'gender', '3': 3, '4': 1, '5': 5, '9': 1, '10': 'gender', '17': true},
  ],
  '8': [
    {'1': '_avatar'},
    {'1': '_gender'},
  ],
};

/// Descriptor for `UpdateProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProfileRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVQcm9maWxlUmVxdWVzdBIjCg1zZXNzaW9uX3Rva2VuGAEgASgJUgxzZXNzaW9uVG'
    '9rZW4SGwoGYXZhdGFyGAIgASgJSABSBmF2YXRhcogBARIbCgZnZW5kZXIYAyABKAVIAVIGZ2Vu'
    'ZGVyiAEBQgkKB19hdmF0YXJCCQoHX2dlbmRlcg==');

@$core.Deprecated('Use updateProfileResponseDescriptor instead')
const UpdateProfileResponse$json = {
  '1': 'UpdateProfileResponse',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
  ],
};

/// Descriptor for `UpdateProfileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProfileResponseDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVQcm9maWxlUmVzcG9uc2USDgoCb2sYASABKAhSAm9r');

@$core.Deprecated('Use searchUserRequestDescriptor instead')
const SearchUserRequest$json = {
  '1': 'SearchUserRequest',
  '2': [
    {'1': 'search_type', '3': 1, '4': 1, '5': 14, '6': '.api.UserSearchType', '10': 'searchType'},
    {'1': 'query', '3': 2, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `SearchUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUserRequestDescriptor = $convert.base64Decode(
    'ChFTZWFyY2hVc2VyUmVxdWVzdBI0CgtzZWFyY2hfdHlwZRgBIAEoDjITLmFwaS5Vc2VyU2Vhcm'
    'NoVHlwZVIKc2VhcmNoVHlwZRIUCgVxdWVyeRgCIAEoCVIFcXVlcnk=');

@$core.Deprecated('Use userProfileDescriptor instead')
const UserProfile$json = {
  '1': 'UserProfile',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'email', '17': true},
    {'1': 'phone', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'phone', '17': true},
    {'1': 'signature', '3': 6, '4': 1, '5': 9, '9': 2, '10': 'signature', '17': true},
    {'1': 'region', '3': 7, '4': 1, '5': 9, '9': 3, '10': 'region', '17': true},
    {'1': 'add_friend_policy', '3': 8, '4': 1, '5': 14, '6': '.api.AddFriendPolicy', '10': 'addFriendPolicy'},
  ],
  '8': [
    {'1': '_email'},
    {'1': '_phone'},
    {'1': '_signature'},
    {'1': '_region'},
  ],
};

/// Descriptor for `UserProfile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userProfileDescriptor = $convert.base64Decode(
    'CgtVc2VyUHJvZmlsZRIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySWQSGgoIdXNlcm5hbWUYAiABKA'
    'lSCHVzZXJuYW1lEhYKBmF2YXRhchgDIAEoCVIGYXZhdGFyEhkKBWVtYWlsGAQgASgJSABSBWVt'
    'YWlsiAEBEhkKBXBob25lGAUgASgJSAFSBXBob25liAEBEiEKCXNpZ25hdHVyZRgGIAEoCUgCUg'
    'lzaWduYXR1cmWIAQESGwoGcmVnaW9uGAcgASgJSANSBnJlZ2lvbogBARJAChFhZGRfZnJpZW5k'
    'X3BvbGljeRgIIAEoDjIULmFwaS5BZGRGcmllbmRQb2xpY3lSD2FkZEZyaWVuZFBvbGljeUIICg'
    'ZfZW1haWxCCAoGX3Bob25lQgwKCl9zaWduYXR1cmVCCQoHX3JlZ2lvbg==');

@$core.Deprecated('Use searchUserResponseDescriptor instead')
const SearchUserResponse$json = {
  '1': 'SearchUserResponse',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.api.UserProfile', '9': 0, '10': 'user', '17': true},
  ],
  '8': [
    {'1': '_user'},
  ],
};

/// Descriptor for `SearchUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUserResponseDescriptor = $convert.base64Decode(
    'ChJTZWFyY2hVc2VyUmVzcG9uc2USKQoEdXNlchgBIAEoCzIQLmFwaS5Vc2VyUHJvZmlsZUgAUg'
    'R1c2VyiAEBQgcKBV91c2Vy');

@$core.Deprecated('Use friendSummaryDescriptor instead')
const FriendSummary$json = {
  '1': 'FriendSummary',
  '2': [
    {'1': 'friend_id', '3': 1, '4': 1, '5': 3, '10': 'friendId'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'remark', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'remark', '17': true},
  ],
  '8': [
    {'1': '_remark'},
  ],
};

/// Descriptor for `FriendSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendSummaryDescriptor = $convert.base64Decode(
    'Cg1GcmllbmRTdW1tYXJ5EhsKCWZyaWVuZF9pZBgBIAEoA1IIZnJpZW5kSWQSGgoIbmlja25hbW'
    'UYAiABKAlSCG5pY2tuYW1lEhYKBmF2YXRhchgDIAEoCVIGYXZhdGFyEhsKBnJlbWFyaxgEIAEo'
    'CUgAUgZyZW1hcmuIAQFCCQoHX3JlbWFyaw==');

@$core.Deprecated('Use getFriendListRequestDescriptor instead')
const GetFriendListRequest$json = {
  '1': 'GetFriendListRequest',
  '2': [
    {'1': 'session_token', '3': 1, '4': 1, '5': 9, '10': 'sessionToken'},
    {'1': 'page', '3': 2, '4': 1, '5': 13, '10': 'page'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 13, '10': 'pageSize'},
  ],
};

/// Descriptor for `GetFriendListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFriendListRequestDescriptor = $convert.base64Decode(
    'ChRHZXRGcmllbmRMaXN0UmVxdWVzdBIjCg1zZXNzaW9uX3Rva2VuGAEgASgJUgxzZXNzaW9uVG'
    '9rZW4SEgoEcGFnZRgCIAEoDVIEcGFnZRIbCglwYWdlX3NpemUYAyABKA1SCHBhZ2VTaXpl');

@$core.Deprecated('Use getFriendListResponseDescriptor instead')
const GetFriendListResponse$json = {
  '1': 'GetFriendListResponse',
  '2': [
    {'1': 'friends', '3': 1, '4': 3, '5': 11, '6': '.api.FriendSummary', '10': 'friends'},
    {'1': 'page', '3': 2, '4': 1, '5': 13, '10': 'page'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 13, '10': 'pageSize'},
    {'1': 'has_more', '3': 4, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `GetFriendListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFriendListResponseDescriptor = $convert.base64Decode(
    'ChVHZXRGcmllbmRMaXN0UmVzcG9uc2USLAoHZnJpZW5kcxgBIAMoCzISLmFwaS5GcmllbmRTdW'
    '1tYXJ5UgdmcmllbmRzEhIKBHBhZ2UYAiABKA1SBHBhZ2USGwoJcGFnZV9zaXplGAMgASgNUghw'
    'YWdlU2l6ZRIZCghoYXNfbW9yZRgEIAEoCFIHaGFzTW9yZQ==');

@$core.Deprecated('Use groupMemberSummaryDescriptor instead')
const GroupMemberSummary$json = {
  '1': 'GroupMemberSummary',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'member_id', '3': 2, '4': 1, '5': 3, '10': 'memberId'},
    {'1': 'nickname', '3': 3, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar', '3': 4, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'role', '3': 5, '4': 1, '5': 5, '10': 'role'},
  ],
};

/// Descriptor for `GroupMemberSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupMemberSummaryDescriptor = $convert.base64Decode(
    'ChJHcm91cE1lbWJlclN1bW1hcnkSGQoIZ3JvdXBfaWQYASABKANSB2dyb3VwSWQSGwoJbWVtYm'
    'VyX2lkGAIgASgDUghtZW1iZXJJZBIaCghuaWNrbmFtZRgDIAEoCVIIbmlja25hbWUSFgoGYXZh'
    'dGFyGAQgASgJUgZhdmF0YXISEgoEcm9sZRgFIAEoBVIEcm9sZQ==');

@$core.Deprecated('Use getGroupMembersRequestDescriptor instead')
const GetGroupMembersRequest$json = {
  '1': 'GetGroupMembersRequest',
  '2': [
    {'1': 'session_token', '3': 1, '4': 1, '5': 9, '10': 'sessionToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'page', '3': 3, '4': 1, '5': 13, '10': 'page'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 13, '10': 'pageSize'},
  ],
};

/// Descriptor for `GetGroupMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupMembersRequestDescriptor = $convert.base64Decode(
    'ChZHZXRHcm91cE1lbWJlcnNSZXF1ZXN0EiMKDXNlc3Npb25fdG9rZW4YASABKAlSDHNlc3Npb2'
    '5Ub2tlbhIZCghncm91cF9pZBgCIAEoA1IHZ3JvdXBJZBISCgRwYWdlGAMgASgNUgRwYWdlEhsK'
    'CXBhZ2Vfc2l6ZRgEIAEoDVIIcGFnZVNpemU=');

@$core.Deprecated('Use getGroupMembersResponseDescriptor instead')
const GetGroupMembersResponse$json = {
  '1': 'GetGroupMembersResponse',
  '2': [
    {'1': 'members', '3': 1, '4': 3, '5': 11, '6': '.api.GroupMemberSummary', '10': 'members'},
    {'1': 'page', '3': 2, '4': 1, '5': 13, '10': 'page'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 13, '10': 'pageSize'},
    {'1': 'has_more', '3': 4, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `GetGroupMembersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupMembersResponseDescriptor = $convert.base64Decode(
    'ChdHZXRHcm91cE1lbWJlcnNSZXNwb25zZRIxCgdtZW1iZXJzGAEgAygLMhcuYXBpLkdyb3VwTW'
    'VtYmVyU3VtbWFyeVIHbWVtYmVycxISCgRwYWdlGAIgASgNUgRwYWdlEhsKCXBhZ2Vfc2l6ZRgD'
    'IAEoDVIIcGFnZVNpemUSGQoIaGFzX21vcmUYBCABKAhSB2hhc01vcmU=');

@$core.Deprecated('Use getGroupMemberDetailRequestDescriptor instead')
const GetGroupMemberDetailRequest$json = {
  '1': 'GetGroupMemberDetailRequest',
  '2': [
    {'1': 'session_token', '3': 1, '4': 1, '5': 9, '10': 'sessionToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'member_id', '3': 3, '4': 1, '5': 3, '10': 'memberId'},
  ],
};

/// Descriptor for `GetGroupMemberDetailRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupMemberDetailRequestDescriptor = $convert.base64Decode(
    'ChtHZXRHcm91cE1lbWJlckRldGFpbFJlcXVlc3QSIwoNc2Vzc2lvbl90b2tlbhgBIAEoCVIMc2'
    'Vzc2lvblRva2VuEhkKCGdyb3VwX2lkGAIgASgDUgdncm91cElkEhsKCW1lbWJlcl9pZBgDIAEo'
    'A1IIbWVtYmVySWQ=');

@$core.Deprecated('Use getGroupMemberDetailResponseDescriptor instead')
const GetGroupMemberDetailResponse$json = {
  '1': 'GetGroupMemberDetailResponse',
  '2': [
    {'1': 'member', '3': 1, '4': 1, '5': 11, '6': '.api.GroupMemberSummary', '10': 'member'},
    {'1': 'is_friend', '3': 2, '4': 1, '5': 8, '10': 'isFriend'},
  ],
};

/// Descriptor for `GetGroupMemberDetailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupMemberDetailResponseDescriptor = $convert.base64Decode(
    'ChxHZXRHcm91cE1lbWJlckRldGFpbFJlc3BvbnNlEi8KBm1lbWJlchgBIAEoCzIXLmFwaS5Hcm'
    '91cE1lbWJlclN1bW1hcnlSBm1lbWJlchIbCglpc19mcmllbmQYAiABKAhSCGlzRnJpZW5k');

