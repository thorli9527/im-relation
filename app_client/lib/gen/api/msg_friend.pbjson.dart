// This is a generated file - do not edit.
//
// Generated from msg_friend.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use friendRequestSourceDescriptor instead')
const FriendRequestSource$json = {
  '1': 'FriendRequestSource',
  '2': [
    {'1': 'FRS_UNKNOWN', '2': 0},
    {'1': 'FRS_QR_CODE', '2': 1},
    {'1': 'FRS_PHONE_CONTACTS', '2': 2},
    {'1': 'FRS_USER_ID', '2': 3},
    {'1': 'FRS_GROUP_MEMBER', '2': 4},
  ],
};

/// Descriptor for `FriendRequestSource`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List friendRequestSourceDescriptor = $convert.base64Decode(
    'ChNGcmllbmRSZXF1ZXN0U291cmNlEg8KC0ZSU19VTktOT1dOEAASDwoLRlJTX1FSX0NPREUQAR'
    'IWChJGUlNfUEhPTkVfQ09OVEFDVFMQAhIPCgtGUlNfVVNFUl9JRBADEhQKEEZSU19HUk9VUF9N'
    'RU1CRVIQBA==');

@$core.Deprecated('Use friendRequestDescriptor instead')
const FriendRequest$json = {
  '1': 'FriendRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'from_user_id', '3': 2, '4': 1, '5': 3, '10': 'fromUserId'},
    {'1': 'to_user_id', '3': 3, '4': 1, '5': 3, '10': 'toUserId'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'source', '3': 5, '4': 1, '5': 14, '6': '.msg_friend_service.FriendRequestSource', '10': 'source'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'remark', '3': 7, '4': 1, '5': 9, '9': 0, '10': 'remark', '17': true},
  ],
  '8': [
    {'1': '_remark'},
  ],
};

/// Descriptor for `FriendRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendRequestDescriptor = $convert.base64Decode(
    'Cg1GcmllbmRSZXF1ZXN0Eg4KAmlkGAEgASgDUgJpZBIgCgxmcm9tX3VzZXJfaWQYAiABKANSCm'
    'Zyb21Vc2VySWQSHAoKdG9fdXNlcl9pZBgDIAEoA1IIdG9Vc2VySWQSFgoGcmVhc29uGAQgASgJ'
    'UgZyZWFzb24SPwoGc291cmNlGAUgASgOMicubXNnX2ZyaWVuZF9zZXJ2aWNlLkZyaWVuZFJlcX'
    'Vlc3RTb3VyY2VSBnNvdXJjZRIdCgpjcmVhdGVkX2F0GAYgASgDUgljcmVhdGVkQXQSGwoGcmVt'
    'YXJrGAcgASgJSABSBnJlbWFya4gBAUIJCgdfcmVtYXJr');

@$core.Deprecated('Use friendRequestDecisionDescriptor instead')
const FriendRequestDecision$json = {
  '1': 'FriendRequestDecision',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 3, '10': 'requestId'},
    {'1': 'accept', '3': 2, '4': 1, '5': 8, '10': 'accept'},
    {'1': 'remark', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'remark', '17': true},
    {'1': 'decided_at', '3': 4, '4': 1, '5': 3, '10': 'decidedAt'},
  ],
  '8': [
    {'1': '_remark'},
  ],
};

/// Descriptor for `FriendRequestDecision`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendRequestDecisionDescriptor = $convert.base64Decode(
    'ChVGcmllbmRSZXF1ZXN0RGVjaXNpb24SHQoKcmVxdWVzdF9pZBgBIAEoA1IJcmVxdWVzdElkEh'
    'YKBmFjY2VwdBgCIAEoCFIGYWNjZXB0EhsKBnJlbWFyaxgDIAEoCUgAUgZyZW1hcmuIAQESHQoK'
    'ZGVjaWRlZF9hdBgEIAEoA1IJZGVjaWRlZEF0QgkKB19yZW1hcms=');

@$core.Deprecated('Use friendDeleteDescriptor instead')
const FriendDelete$json = {
  '1': 'FriendDelete',
  '2': [
    {'1': 'operator_user_id', '3': 1, '4': 1, '5': 3, '10': 'operatorUserId'},
    {'1': 'friend_user_id', '3': 2, '4': 1, '5': 3, '10': 'friendUserId'},
    {'1': 'at', '3': 3, '4': 1, '5': 3, '10': 'at'},
  ],
};

/// Descriptor for `FriendDelete`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendDeleteDescriptor = $convert.base64Decode(
    'CgxGcmllbmREZWxldGUSKAoQb3BlcmF0b3JfdXNlcl9pZBgBIAEoA1IOb3BlcmF0b3JVc2VySW'
    'QSJAoOZnJpZW5kX3VzZXJfaWQYAiABKANSDGZyaWVuZFVzZXJJZBIOCgJhdBgDIAEoA1ICYXQ=');

@$core.Deprecated('Use friendUpdateRemarkDescriptor instead')
const FriendUpdateRemark$json = {
  '1': 'FriendUpdateRemark',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'friend_user_id', '3': 2, '4': 1, '5': 3, '10': 'friendUserId'},
    {'1': 'remark', '3': 3, '4': 1, '5': 9, '10': 'remark'},
    {'1': 'updated_at', '3': 4, '4': 1, '5': 3, '10': 'updatedAt'},
  ],
};

/// Descriptor for `FriendUpdateRemark`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendUpdateRemarkDescriptor = $convert.base64Decode(
    'ChJGcmllbmRVcGRhdGVSZW1hcmsSFwoHdXNlcl9pZBgBIAEoA1IGdXNlcklkEiQKDmZyaWVuZF'
    '91c2VyX2lkGAIgASgDUgxmcmllbmRVc2VySWQSFgoGcmVtYXJrGAMgASgJUgZyZW1hcmsSHQoK'
    'dXBkYXRlZF9hdBgEIAEoA1IJdXBkYXRlZEF0');

@$core.Deprecated('Use identityKeyDescriptor instead')
const IdentityKey$json = {
  '1': 'IdentityKey',
  '2': [
    {'1': 'curve', '3': 1, '4': 1, '5': 9, '10': 'curve'},
    {'1': 'pub_key', '3': 2, '4': 1, '5': 12, '10': 'pubKey'},
  ],
};

/// Descriptor for `IdentityKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List identityKeyDescriptor = $convert.base64Decode(
    'CgtJZGVudGl0eUtleRIUCgVjdXJ2ZRgBIAEoCVIFY3VydmUSFwoHcHViX2tleRgCIAEoDFIGcH'
    'ViS2V5');

@$core.Deprecated('Use signedPreKeyDescriptor instead')
const SignedPreKey$json = {
  '1': 'SignedPreKey',
  '2': [
    {'1': 'key_id', '3': 1, '4': 1, '5': 13, '10': 'keyId'},
    {'1': 'pub_key', '3': 2, '4': 1, '5': 12, '10': 'pubKey'},
    {'1': 'signature', '3': 3, '4': 1, '5': 12, '10': 'signature'},
  ],
};

/// Descriptor for `SignedPreKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signedPreKeyDescriptor = $convert.base64Decode(
    'CgxTaWduZWRQcmVLZXkSFQoGa2V5X2lkGAEgASgNUgVrZXlJZBIXCgdwdWJfa2V5GAIgASgMUg'
    'ZwdWJLZXkSHAoJc2lnbmF0dXJlGAMgASgMUglzaWduYXR1cmU=');

@$core.Deprecated('Use oneTimePreKeyDescriptor instead')
const OneTimePreKey$json = {
  '1': 'OneTimePreKey',
  '2': [
    {'1': 'key_id', '3': 1, '4': 1, '5': 13, '10': 'keyId'},
    {'1': 'pub_key', '3': 2, '4': 1, '5': 12, '10': 'pubKey'},
  ],
};

/// Descriptor for `OneTimePreKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List oneTimePreKeyDescriptor = $convert.base64Decode(
    'Cg1PbmVUaW1lUHJlS2V5EhUKBmtleV9pZBgBIAEoDVIFa2V5SWQSFwoHcHViX2tleRgCIAEoDF'
    'IGcHViS2V5');

@$core.Deprecated('Use uploadDeviceKeysRequestDescriptor instead')
const UploadDeviceKeysRequest$json = {
  '1': 'UploadDeviceKeysRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'identity_key', '3': 3, '4': 1, '5': 11, '6': '.msg_friend_service.IdentityKey', '10': 'identityKey'},
    {'1': 'signed_pre_key', '3': 4, '4': 1, '5': 11, '6': '.msg_friend_service.SignedPreKey', '10': 'signedPreKey'},
    {'1': 'one_time_pre_keys', '3': 5, '4': 3, '5': 11, '6': '.msg_friend_service.OneTimePreKey', '10': 'oneTimePreKeys'},
  ],
};

/// Descriptor for `UploadDeviceKeysRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadDeviceKeysRequestDescriptor = $convert.base64Decode(
    'ChdVcGxvYWREZXZpY2VLZXlzUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySWQSGwoJZG'
    'V2aWNlX2lkGAIgASgJUghkZXZpY2VJZBJCCgxpZGVudGl0eV9rZXkYAyABKAsyHy5tc2dfZnJp'
    'ZW5kX3NlcnZpY2UuSWRlbnRpdHlLZXlSC2lkZW50aXR5S2V5EkYKDnNpZ25lZF9wcmVfa2V5GA'
    'QgASgLMiAubXNnX2ZyaWVuZF9zZXJ2aWNlLlNpZ25lZFByZUtleVIMc2lnbmVkUHJlS2V5EkwK'
    'EW9uZV90aW1lX3ByZV9rZXlzGAUgAygLMiEubXNnX2ZyaWVuZF9zZXJ2aWNlLk9uZVRpbWVQcm'
    'VLZXlSDm9uZVRpbWVQcmVLZXlz');

@$core.Deprecated('Use uploadDeviceKeysResponseDescriptor instead')
const UploadDeviceKeysResponse$json = {
  '1': 'UploadDeviceKeysResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `UploadDeviceKeysResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadDeviceKeysResponseDescriptor = $convert.base64Decode(
    'ChhVcGxvYWREZXZpY2VLZXlzUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use fetchDeviceKeysRequestDescriptor instead')
const FetchDeviceKeysRequest$json = {
  '1': 'FetchDeviceKeysRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
  ],
};

/// Descriptor for `FetchDeviceKeysRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchDeviceKeysRequestDescriptor = $convert.base64Decode(
    'ChZGZXRjaERldmljZUtleXNSZXF1ZXN0EhcKB3VzZXJfaWQYASABKANSBnVzZXJJZA==');

@$core.Deprecated('Use deviceKeyBundleDescriptor instead')
const DeviceKeyBundle$json = {
  '1': 'DeviceKeyBundle',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'identity_key', '3': 3, '4': 1, '5': 11, '6': '.msg_friend_service.IdentityKey', '10': 'identityKey'},
    {'1': 'signed_pre_key', '3': 4, '4': 1, '5': 11, '6': '.msg_friend_service.SignedPreKey', '10': 'signedPreKey'},
    {'1': 'one_time_pre_keys', '3': 5, '4': 3, '5': 11, '6': '.msg_friend_service.OneTimePreKey', '10': 'oneTimePreKeys'},
  ],
};

/// Descriptor for `DeviceKeyBundle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceKeyBundleDescriptor = $convert.base64Decode(
    'Cg9EZXZpY2VLZXlCdW5kbGUSFwoHdXNlcl9pZBgBIAEoA1IGdXNlcklkEhsKCWRldmljZV9pZB'
    'gCIAEoCVIIZGV2aWNlSWQSQgoMaWRlbnRpdHlfa2V5GAMgASgLMh8ubXNnX2ZyaWVuZF9zZXJ2'
    'aWNlLklkZW50aXR5S2V5UgtpZGVudGl0eUtleRJGCg5zaWduZWRfcHJlX2tleRgEIAEoCzIgLm'
    '1zZ19mcmllbmRfc2VydmljZS5TaWduZWRQcmVLZXlSDHNpZ25lZFByZUtleRJMChFvbmVfdGlt'
    'ZV9wcmVfa2V5cxgFIAMoCzIhLm1zZ19mcmllbmRfc2VydmljZS5PbmVUaW1lUHJlS2V5Ug5vbm'
    'VUaW1lUHJlS2V5cw==');

@$core.Deprecated('Use fetchDeviceKeysResponseDescriptor instead')
const FetchDeviceKeysResponse$json = {
  '1': 'FetchDeviceKeysResponse',
  '2': [
    {'1': 'bundles', '3': 1, '4': 3, '5': 11, '6': '.msg_friend_service.DeviceKeyBundle', '10': 'bundles'},
  ],
};

/// Descriptor for `FetchDeviceKeysResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchDeviceKeysResponseDescriptor = $convert.base64Decode(
    'ChdGZXRjaERldmljZUtleXNSZXNwb25zZRI9CgdidW5kbGVzGAEgAygLMiMubXNnX2ZyaWVuZF'
    '9zZXJ2aWNlLkRldmljZUtleUJ1bmRsZVIHYnVuZGxlcw==');

@$core.Deprecated('Use listUserFriendMessagesRequestDescriptor instead')
const ListUserFriendMessagesRequest$json = {
  '1': 'ListUserFriendMessagesRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'since_timestamp', '3': 2, '4': 1, '5': 3, '10': 'sinceTimestamp'},
    {'1': 'limit', '3': 3, '4': 1, '5': 13, '10': 'limit'},
  ],
};

/// Descriptor for `ListUserFriendMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUserFriendMessagesRequestDescriptor = $convert.base64Decode(
    'Ch1MaXN0VXNlckZyaWVuZE1lc3NhZ2VzUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySW'
    'QSJwoPc2luY2VfdGltZXN0YW1wGAIgASgDUg5zaW5jZVRpbWVzdGFtcBIUCgVsaW1pdBgDIAEo'
    'DVIFbGltaXQ=');

