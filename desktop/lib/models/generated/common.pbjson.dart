// This is a generated file - do not edit.
//
// Generated from common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use groupRoleTypeDescriptor instead')
const GroupRoleType$json = {
  '1': 'GroupRoleType',
  '2': [
    {'1': 'OWNER', '2': 0},
    {'1': 'ADMIN', '2': 1},
    {'1': 'MEMBER', '2': 2},
  ],
};

/// Descriptor for `GroupRoleType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List groupRoleTypeDescriptor = $convert.base64Decode(
    'Cg1Hcm91cFJvbGVUeXBlEgkKBU9XTkVSEAASCQoFQURNSU4QARIKCgZNRU1CRVIQAg==');

@$core.Deprecated('Use joinPermissionDescriptor instead')
const JoinPermission$json = {
  '1': 'JoinPermission',
  '2': [
    {'1': 'ANYONE', '2': 0},
    {'1': 'NEED_APPROVAL', '2': 1},
    {'1': 'INVITE_ONLY', '2': 2},
    {'1': 'CLOSED', '2': 3},
  ],
};

/// Descriptor for `JoinPermission`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List joinPermissionDescriptor = $convert.base64Decode(
    'Cg5Kb2luUGVybWlzc2lvbhIKCgZBTllPTkUQABIRCg1ORUVEX0FQUFJPVkFMEAESDwoLSU5WSV'
    'RFX09OTFkQAhIKCgZDTE9TRUQQAw==');

@$core.Deprecated('Use joinQuestionTypeDescriptor instead')
const JoinQuestionType$json = {
  '1': 'JoinQuestionType',
  '2': [
    {'1': 'NONE', '2': 0},
    {'1': 'QUESTION', '2': 1},
    {'1': 'CAPTCHA', '2': 2},
    {'1': 'INVITE_CODE', '2': 3},
  ],
};

/// Descriptor for `JoinQuestionType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List joinQuestionTypeDescriptor = $convert.base64Decode(
    'ChBKb2luUXVlc3Rpb25UeXBlEggKBE5PTkUQABIMCghRVUVTVElPThABEgsKB0NBUFRDSEEQAh'
    'IPCgtJTlZJVEVfQ09ERRAD');

@$core.Deprecated('Use contentTypeDescriptor instead')
const ContentType$json = {
  '1': 'ContentType',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'TEXT', '2': 1},
    {'1': 'IMAGE', '2': 2},
    {'1': 'AUDIO', '2': 3},
    {'1': 'VIDEO', '2': 4},
    {'1': 'HTML', '2': 5},
    {'1': 'LOCATION', '2': 6},
    {'1': 'FILE', '2': 7},
    {'1': 'EMOJI', '2': 8},
    {'1': 'QUOTE', '2': 9},
    {'1': 'AV_CALL', '2': 10},
    {'1': 'VOIP', '2': 11},
    {'1': 'NOTIFICATION', '2': 12},
    {'1': 'SYSTEM', '2': 13},
    {'1': 'REMINDER', '2': 14},
    {'1': 'FRIEND_EVENT', '2': 15},
    {'1': 'GROUP_EVENT', '2': 16},
    {'1': 'REVOKE', '2': 17},
    {'1': 'FORWARD', '2': 18},
    {'1': 'CONTACT_CARD', '2': 19},
    {'1': 'VOTE', '2': 20},
    {'1': 'RED_ENVELOPE', '2': 21},
    {'1': 'CUSTOM', '2': 100},
  ],
};

/// Descriptor for `ContentType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List contentTypeDescriptor = $convert.base64Decode(
    'CgtDb250ZW50VHlwZRILCgdVTktOT1dOEAASCAoEVEVYVBABEgkKBUlNQUdFEAISCQoFQVVESU'
    '8QAxIJCgVWSURFTxAEEggKBEhUTUwQBRIMCghMT0NBVElPThAGEggKBEZJTEUQBxIJCgVFTU9K'
    'SRAIEgkKBVFVT1RFEAkSCwoHQVZfQ0FMTBAKEggKBFZPSVAQCxIQCgxOT1RJRklDQVRJT04QDB'
    'IKCgZTWVNURU0QDRIMCghSRU1JTkRFUhAOEhAKDEZSSUVORF9FVkVOVBAPEg8KC0dST1VQX0VW'
    'RU5UEBASCgoGUkVWT0tFEBESCwoHRk9SV0FSRBASEhAKDENPTlRBQ1RfQ0FSRBATEggKBFZPVE'
    'UQFBIQCgxSRURfRU5WRUxPUEUQFRIKCgZDVVNUT00QZA==');

@$core.Deprecated('Use chatTargetTypeDescriptor instead')
const ChatTargetType$json = {
  '1': 'ChatTargetType',
  '2': [
    {'1': 'UN_KNOWN', '2': 0},
    {'1': 'GROUP', '2': 1},
    {'1': 'SINGLE', '2': 2},
  ],
};

/// Descriptor for `ChatTargetType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List chatTargetTypeDescriptor = $convert.base64Decode(
    'Cg5DaGF0VGFyZ2V0VHlwZRIMCghVTl9LTk9XThAAEgkKBUdST1VQEAESCgoGU0lOR0xFEAI=');

@$core.Deprecated('Use groupTypeDescriptor instead')
const GroupType$json = {
  '1': 'GroupType',
  '2': [
    {'1': 'UNKNOWN_GROUP_TYPE', '2': 0},
    {'1': 'NORMAL_GROUP', '2': 1},
    {'1': 'SUPER_GROUP', '2': 2},
    {'1': 'SYSTEM_GROUP', '2': 3},
  ],
};

/// Descriptor for `GroupType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List groupTypeDescriptor = $convert.base64Decode(
    'CglHcm91cFR5cGUSFgoSVU5LTk9XTl9HUk9VUF9UWVBFEAASEAoMTk9STUFMX0dST1VQEAESDw'
    'oLU1VQRVJfR1JPVVAQAhIQCgxTWVNURU1fR1JPVVAQAw==');

@$core.Deprecated('Use byteMessageTypeDescriptor instead')
const ByteMessageType$json = {
  '1': 'ByteMessageType',
  '2': [
    {'1': 'UNKNOWN_BYTE_MESSAGE_TYPE', '2': 0},
    {'1': 'HeartbeatMsgType', '2': 1},
    {'1': 'LoginReqMsgType', '2': 2},
    {'1': 'LoginRespMsgType', '2': 3},
    {'1': 'LogoutReqMsgType', '2': 4},
    {'1': 'LogoutRespMsgType', '2': 5},
    {'1': 'SendVerificationCodeReqMsgType', '2': 6},
    {'1': 'SendVerificationCodeRepMsgType', '2': 7},
    {'1': 'SystemNotificationMsgType', '2': 8},
    {'1': 'UserFlushMsgType', '2': 9},
    {'1': 'OnlineStatusMsgType', '2': 10},
    {'1': 'OfflineStatusMsgType', '2': 11},
    {'1': 'UserMsgType', '2': 20},
    {'1': 'GroupMsgType', '2': 21},
    {'1': 'FriendEventMsgType', '2': 30},
    {'1': 'GroupCreateMsgType', '2': 31},
    {'1': 'GroupDismissMsgType', '2': 32},
    {'1': 'ReConnectMsgType', '2': 99},
    {'1': 'ACKMsgType', '2': 200},
  ],
};

/// Descriptor for `ByteMessageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List byteMessageTypeDescriptor = $convert.base64Decode(
    'Cg9CeXRlTWVzc2FnZVR5cGUSHQoZVU5LTk9XTl9CWVRFX01FU1NBR0VfVFlQRRAAEhQKEEhlYX'
    'J0YmVhdE1zZ1R5cGUQARITCg9Mb2dpblJlcU1zZ1R5cGUQAhIUChBMb2dpblJlc3BNc2dUeXBl'
    'EAMSFAoQTG9nb3V0UmVxTXNnVHlwZRAEEhUKEUxvZ291dFJlc3BNc2dUeXBlEAUSIgoeU2VuZF'
    'ZlcmlmaWNhdGlvbkNvZGVSZXFNc2dUeXBlEAYSIgoeU2VuZFZlcmlmaWNhdGlvbkNvZGVSZXBN'
    'c2dUeXBlEAcSHQoZU3lzdGVtTm90aWZpY2F0aW9uTXNnVHlwZRAIEhQKEFVzZXJGbHVzaE1zZ1'
    'R5cGUQCRIXChNPbmxpbmVTdGF0dXNNc2dUeXBlEAoSGAoUT2ZmbGluZVN0YXR1c01zZ1R5cGUQ'
    'CxIPCgtVc2VyTXNnVHlwZRAUEhAKDEdyb3VwTXNnVHlwZRAVEhYKEkZyaWVuZEV2ZW50TXNnVH'
    'lwZRAeEhYKEkdyb3VwQ3JlYXRlTXNnVHlwZRAfEhcKE0dyb3VwRGlzbWlzc01zZ1R5cGUQIBIU'
    'ChBSZUNvbm5lY3RNc2dUeXBlEGMSDwoKQUNLTXNnVHlwZRDIAQ==');

@$core.Deprecated('Use genderDescriptor instead')
const Gender$json = {
  '1': 'Gender',
  '2': [
    {'1': 'Unknown', '2': 0},
    {'1': 'Male', '2': 1},
    {'1': 'Female', '2': 2},
  ],
};

/// Descriptor for `Gender`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List genderDescriptor = $convert.base64Decode(
    'CgZHZW5kZXISCwoHVW5rbm93bhAAEggKBE1hbGUQARIKCgZGZW1hbGUQAg==');

@$core.Deprecated('Use friendPolicyDescriptor instead')
const FriendPolicy$json = {
  '1': 'FriendPolicy',
  '2': [
    {'1': 'ALLOW_ANY', '2': 0},
    {'1': 'NEED_CONFIRM', '2': 1},
    {'1': 'DENY_ANY', '2': 2},
  ],
};

/// Descriptor for `FriendPolicy`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List friendPolicyDescriptor = $convert.base64Decode(
    'CgxGcmllbmRQb2xpY3kSDQoJQUxMT1dfQU5ZEAASEAoMTkVFRF9DT05GSVJNEAESDAoIREVOWV'
    '9BTlkQAg==');

@$core.Deprecated('Use clientUserTypeDescriptor instead')
const ClientUserType$json = {
  '1': 'ClientUserType',
  '2': [
    {'1': 'USER_TYPE_UNKNOWN', '2': 0},
    {'1': 'USER_TYPE_NORMAL', '2': 1},
    {'1': 'USER_TYPE_ROBOT', '2': 2},
  ],
};

/// Descriptor for `ClientUserType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List clientUserTypeDescriptor = $convert.base64Decode(
    'Cg5DbGllbnRVc2VyVHlwZRIVChFVU0VSX1RZUEVfVU5LTk9XThAAEhQKEFVTRVJfVFlQRV9OT1'
    'JNQUwQARITCg9VU0VSX1RZUEVfUk9CT1QQAg==');

@$core.Deprecated('Use commonRespDescriptor instead')
const CommonResp$json = {
  '1': 'CommonResp',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `CommonResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commonRespDescriptor = $convert.base64Decode(
    'CgpDb21tb25SZXNwEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2FnZRgCIAEoCV'
    'IHbWVzc2FnZQ==');

@$core.Deprecated('Use tagInfoDescriptor instead')
const TagInfo$json = {
  '1': 'TagInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'color', '3': 4, '4': 1, '5': 9, '10': 'color'},
  ],
};

/// Descriptor for `TagInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tagInfoDescriptor = $convert.base64Decode(
    'CgdUYWdJbmZvEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaX'
    'B0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIUCgVjb2xvchgEIAEoCVIFY29sb3I=');

@$core.Deprecated('Use groupEntityDescriptor instead')
const GroupEntity$json = {
  '1': 'GroupEntity',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'notice', '3': 5, '4': 1, '5': 9, '10': 'notice'},
    {'1': 'join_permission', '3': 6, '4': 1, '5': 14, '6': '.common.JoinPermission', '10': 'joinPermission'},
    {'1': 'owner_id', '3': 7, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'group_type', '3': 8, '4': 1, '5': 14, '6': '.common.GroupType', '10': 'groupType'},
    {'1': 'allow_search', '3': 9, '4': 1, '5': 8, '10': 'allowSearch'},
    {'1': 'enable', '3': 10, '4': 1, '5': 8, '10': 'enable'},
    {'1': 'create_time', '3': 11, '4': 1, '5': 4, '10': 'createTime'},
    {'1': 'update_time', '3': 12, '4': 1, '5': 4, '10': 'updateTime'},
  ],
};

/// Descriptor for `GroupEntity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupEntityDescriptor = $convert.base64Decode(
    'CgtHcm91cEVudGl0eRIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIWCgZhdm'
    'F0YXIYAyABKAlSBmF2YXRhchIgCgtkZXNjcmlwdGlvbhgEIAEoCVILZGVzY3JpcHRpb24SFgoG'
    'bm90aWNlGAUgASgJUgZub3RpY2USPwoPam9pbl9wZXJtaXNzaW9uGAYgASgOMhYuY29tbW9uLk'
    'pvaW5QZXJtaXNzaW9uUg5qb2luUGVybWlzc2lvbhIZCghvd25lcl9pZBgHIAEoCVIHb3duZXJJ'
    'ZBIwCgpncm91cF90eXBlGAggASgOMhEuY29tbW9uLkdyb3VwVHlwZVIJZ3JvdXBUeXBlEiEKDG'
    'FsbG93X3NlYXJjaBgJIAEoCFILYWxsb3dTZWFyY2gSFgoGZW5hYmxlGAogASgIUgZlbmFibGUS'
    'HwoLY3JlYXRlX3RpbWUYCyABKARSCmNyZWF0ZVRpbWUSHwoLdXBkYXRlX3RpbWUYDCABKARSCn'
    'VwZGF0ZVRpbWU=');

@$core.Deprecated('Use groupMemberEntityDescriptor instead')
const GroupMemberEntity$json = {
  '1': 'GroupMemberEntity',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uid', '3': 3, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'alias', '3': 4, '4': 1, '5': 9, '10': 'alias'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.common.GroupRoleType', '10': 'role'},
    {'1': 'is_muted', '3': 6, '4': 1, '5': 8, '10': 'isMuted'},
    {'1': 'avatar', '3': 7, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'create_time', '3': 8, '4': 1, '5': 4, '10': 'createTime'},
    {'1': 'update_time', '3': 9, '4': 1, '5': 4, '10': 'updateTime'},
  ],
};

/// Descriptor for `GroupMemberEntity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupMemberEntityDescriptor = $convert.base64Decode(
    'ChFHcm91cE1lbWJlckVudGl0eRIOCgJpZBgBIAEoCVICaWQSGQoIZ3JvdXBfaWQYAiABKAlSB2'
    'dyb3VwSWQSEAoDdWlkGAMgASgJUgN1aWQSFAoFYWxpYXMYBCABKAlSBWFsaWFzEikKBHJvbGUY'
    'BSABKA4yFS5jb21tb24uR3JvdXBSb2xlVHlwZVIEcm9sZRIZCghpc19tdXRlZBgGIAEoCFIHaX'
    'NNdXRlZBIWCgZhdmF0YXIYByABKAlSBmF2YXRhchIfCgtjcmVhdGVfdGltZRgIIAEoBFIKY3Jl'
    'YXRlVGltZRIfCgt1cGRhdGVfdGltZRgJIAEoBFIKdXBkYXRlVGltZQ==');

