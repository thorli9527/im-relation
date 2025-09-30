// This is a generated file - do not edit.
//
// Generated from friend.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use friendEventTypeDescriptor instead')
const FriendEventType$json = {
  '1': 'FriendEventType',
  '2': [
    {'1': 'FRIEND_EVENT_UNKNOWN', '2': 0},
    {'1': 'FRIEND_REQUEST', '2': 1},
    {'1': 'FRIEND_ACCEPT', '2': 2},
    {'1': 'FRIEND_REJECT', '2': 3},
    {'1': 'FRIEND_REMOVE', '2': 4},
    {'1': 'FRIEND_BLOCK', '2': 5},
    {'1': 'FRIEND_UNBLOCK', '2': 6},
    {'1': 'FRIEND_UPDATE_REMARK', '2': 7},
    {'1': 'FRIEND_ADD_FORCE', '2': 8},
  ],
};

/// Descriptor for `FriendEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List friendEventTypeDescriptor = $convert.base64Decode(
    'Cg9GcmllbmRFdmVudFR5cGUSGAoURlJJRU5EX0VWRU5UX1VOS05PV04QABISCg5GUklFTkRfUk'
    'VRVUVTVBABEhEKDUZSSUVORF9BQ0NFUFQQAhIRCg1GUklFTkRfUkVKRUNUEAMSEQoNRlJJRU5E'
    'X1JFTU9WRRAEEhAKDEZSSUVORF9CTE9DSxAFEhIKDkZSSUVORF9VTkJMT0NLEAYSGAoURlJJRU'
    '5EX1VQREFURV9SRU1BUksQBxIUChBGUklFTkRfQUREX0ZPUkNFEAg=');

@$core.Deprecated('Use friendSourceTypeDescriptor instead')
const FriendSourceType$json = {
  '1': 'FriendSourceType',
  '2': [
    {'1': 'FRIEND_SOURCE_UNKNOWN', '2': 0},
    {'1': 'FRIEND_SOURCE_SEARCH', '2': 1},
    {'1': 'FRIEND_SOURCE_QRCODE', '2': 2},
    {'1': 'FRIEND_SOURCE_PHONE', '2': 3},
    {'1': 'FRIEND_SOURCE_GROUP', '2': 4},
    {'1': 'FRIEND_SOURCE_SYSTEM', '2': 5},
  ],
};

/// Descriptor for `FriendSourceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List friendSourceTypeDescriptor = $convert.base64Decode(
    'ChBGcmllbmRTb3VyY2VUeXBlEhkKFUZSSUVORF9TT1VSQ0VfVU5LTk9XThAAEhgKFEZSSUVORF'
    '9TT1VSQ0VfU0VBUkNIEAESGAoURlJJRU5EX1NPVVJDRV9RUkNPREUQAhIXChNGUklFTkRfU09V'
    'UkNFX1BIT05FEAMSFwoTRlJJRU5EX1NPVVJDRV9HUk9VUBAEEhgKFEZSSUVORF9TT1VSQ0VfU1'
    'lTVEVNEAU=');

@$core.Deprecated('Use eventStatusDescriptor instead')
const EventStatus$json = {
  '1': 'EventStatus',
  '2': [
    {'1': 'PENDING', '2': 0},
    {'1': 'DONE', '2': 1},
    {'1': 'REVOKED', '2': 2},
  ],
};

/// Descriptor for `EventStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List eventStatusDescriptor = $convert.base64Decode(
    'CgtFdmVudFN0YXR1cxILCgdQRU5ESU5HEAASCAoERE9ORRABEgsKB1JFVk9LRUQQAg==');

@$core.Deprecated('Use friendEventMsgDescriptor instead')
const FriendEventMsg$json = {
  '1': 'FriendEventMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
    {'1': 'from_uid', '3': 2, '4': 1, '5': 9, '10': 'fromUid'},
    {'1': 'to_uid', '3': 3, '4': 1, '5': 9, '10': 'toUid'},
    {'1': 'event_type', '3': 4, '4': 1, '5': 14, '6': '.protocol.friend.FriendEventType', '10': 'eventType'},
    {'1': 'message', '3': 5, '4': 1, '5': 9, '10': 'message'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.protocol.friend.EventStatus', '10': 'status'},
    {'1': 'created_at', '3': 7, '4': 1, '5': 4, '10': 'createdAt'},
    {'1': 'updated_at', '3': 8, '4': 1, '5': 4, '10': 'updatedAt'},
    {'1': 'source_type', '3': 9, '4': 1, '5': 14, '6': '.protocol.friend.FriendSourceType', '10': 'sourceType'},
    {'1': 'from_a_name', '3': 10, '4': 1, '5': 9, '10': 'fromAName'},
    {'1': 'to_a_name', '3': 11, '4': 1, '5': 9, '10': 'toAName'},
    {'1': 'from_remark', '3': 12, '4': 1, '5': 9, '9': 0, '10': 'fromRemark', '17': true},
    {'1': 'to_remark', '3': 13, '4': 1, '5': 9, '9': 1, '10': 'toRemark', '17': true},
  ],
  '8': [
    {'1': '_from_remark'},
    {'1': '_to_remark'},
  ],
};

/// Descriptor for `FriendEventMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendEventMsgDescriptor = $convert.base64Decode(
    'Cg5GcmllbmRFdmVudE1zZxIdCgptZXNzYWdlX2lkGAEgASgEUgltZXNzYWdlSWQSGQoIZnJvbV'
    '91aWQYAiABKAlSB2Zyb21VaWQSFQoGdG9fdWlkGAMgASgJUgV0b1VpZBI/CgpldmVudF90eXBl'
    'GAQgASgOMiAucHJvdG9jb2wuZnJpZW5kLkZyaWVuZEV2ZW50VHlwZVIJZXZlbnRUeXBlEhgKB2'
    '1lc3NhZ2UYBSABKAlSB21lc3NhZ2USNAoGc3RhdHVzGAYgASgOMhwucHJvdG9jb2wuZnJpZW5k'
    'LkV2ZW50U3RhdHVzUgZzdGF0dXMSHQoKY3JlYXRlZF9hdBgHIAEoBFIJY3JlYXRlZEF0Eh0KCn'
    'VwZGF0ZWRfYXQYCCABKARSCXVwZGF0ZWRBdBJCCgtzb3VyY2VfdHlwZRgJIAEoDjIhLnByb3Rv'
    'Y29sLmZyaWVuZC5GcmllbmRTb3VyY2VUeXBlUgpzb3VyY2VUeXBlEh4KC2Zyb21fYV9uYW1lGA'
    'ogASgJUglmcm9tQU5hbWUSGgoJdG9fYV9uYW1lGAsgASgJUgd0b0FOYW1lEiQKC2Zyb21fcmVt'
    'YXJrGAwgASgJSABSCmZyb21SZW1hcmuIAQESIAoJdG9fcmVtYXJrGA0gASgJSAFSCHRvUmVtYX'
    'JriAEBQg4KDF9mcm9tX3JlbWFya0IMCgpfdG9fcmVtYXJr');

