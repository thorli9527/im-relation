// This is a generated file - do not edit.
//
// Generated from status.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use readReceiptMsgDescriptor instead')
const ReadReceiptMsg$json = {
  '1': 'ReadReceiptMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
    {'1': 'reader_ids', '3': 2, '4': 3, '5': 9, '10': 'readerIds'},
    {'1': 'read_time', '3': 3, '4': 1, '5': 3, '10': 'readTime'},
  ],
};

/// Descriptor for `ReadReceiptMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readReceiptMsgDescriptor = $convert.base64Decode(
    'Cg5SZWFkUmVjZWlwdE1zZxIdCgptZXNzYWdlX2lkGAEgASgEUgltZXNzYWdlSWQSHQoKcmVhZG'
    'VyX2lkcxgCIAMoCVIJcmVhZGVySWRzEhsKCXJlYWRfdGltZRgDIAEoA1IIcmVhZFRpbWU=');

@$core.Deprecated('Use typingNoticeMsgDescriptor instead')
const TypingNoticeMsg$json = {
  '1': 'TypingNoticeMsg',
  '2': [
    {'1': 'from_uid', '3': 1, '4': 1, '5': 9, '10': 'fromUid'},
    {'1': 'to_uid', '3': 2, '4': 1, '5': 9, '10': 'toUid'},
    {'1': 'is_typing', '3': 3, '4': 1, '5': 8, '10': 'isTyping'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `TypingNoticeMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingNoticeMsgDescriptor = $convert.base64Decode(
    'Cg9UeXBpbmdOb3RpY2VNc2cSGQoIZnJvbV91aWQYASABKAlSB2Zyb21VaWQSFQoGdG9fdWlkGA'
    'IgASgJUgV0b1VpZBIbCglpc190eXBpbmcYAyABKAhSCGlzVHlwaW5nEhwKCXRpbWVzdGFtcBgE'
    'IAEoA1IJdGltZXN0YW1w');

@$core.Deprecated('Use heartbeatMsgDescriptor instead')
const HeartbeatMsg$json = {
  '1': 'HeartbeatMsg',
};

/// Descriptor for `HeartbeatMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatMsgDescriptor = $convert.base64Decode(
    'CgxIZWFydGJlYXRNc2c=');

@$core.Deprecated('Use ackMsgDescriptor instead')
const AckMsg$json = {
  '1': 'AckMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
    {'1': 'ack_type', '3': 2, '4': 1, '5': 14, '6': '.common.ByteMessageType', '10': 'ackType'},
    {'1': 'success', '3': 3, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_code', '3': 5, '4': 1, '5': 5, '10': 'errorCode'},
  ],
};

/// Descriptor for `AckMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ackMsgDescriptor = $convert.base64Decode(
    'CgZBY2tNc2cSHQoKbWVzc2FnZV9pZBgBIAEoBFIJbWVzc2FnZUlkEjIKCGFja190eXBlGAIgAS'
    'gOMhcuY29tbW9uLkJ5dGVNZXNzYWdlVHlwZVIHYWNrVHlwZRIYCgdzdWNjZXNzGAMgASgIUgdz'
    'dWNjZXNzEh0KCmVycm9yX2NvZGUYBSABKAVSCWVycm9yQ29kZQ==');

@$core.Deprecated('Use reConnectMsgDescriptor instead')
const ReConnectMsg$json = {
  '1': 'ReConnectMsg',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '10': 'messageId'},
    {'1': 'socket_addr', '3': 2, '4': 1, '5': 9, '10': 'socketAddr'},
  ],
};

/// Descriptor for `ReConnectMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reConnectMsgDescriptor = $convert.base64Decode(
    'CgxSZUNvbm5lY3RNc2cSHQoKbWVzc2FnZV9pZBgBIAEoBFIJbWVzc2FnZUlkEh8KC3NvY2tldF'
    '9hZGRyGAIgASgJUgpzb2NrZXRBZGRy');

