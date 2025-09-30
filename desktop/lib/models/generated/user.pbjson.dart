// This is a generated file - do not edit.
//
// Generated from user.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use userFlushMsgDescriptor instead')
const UserFlushMsg$json = {
  '1': 'UserFlushMsg',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'operator_id', '3': 2, '4': 1, '5': 9, '10': 'operatorId'},
    {'1': 'fields', '3': 3, '4': 3, '5': 11, '6': '.protocol.user.UserFlushMsg.FieldsEntry', '10': 'fields'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
  '3': [UserFlushMsg_FieldsEntry$json],
};

@$core.Deprecated('Use userFlushMsgDescriptor instead')
const UserFlushMsg_FieldsEntry$json = {
  '1': 'FieldsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `UserFlushMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userFlushMsgDescriptor = $convert.base64Decode(
    'CgxVc2VyRmx1c2hNc2cSEAoDdWlkGAEgASgJUgN1aWQSHwoLb3BlcmF0b3JfaWQYAiABKAlSCm'
    '9wZXJhdG9ySWQSPwoGZmllbGRzGAMgAygLMicucHJvdG9jb2wudXNlci5Vc2VyRmx1c2hNc2cu'
    'RmllbGRzRW50cnlSBmZpZWxkcxIcCgl0aW1lc3RhbXAYBCABKANSCXRpbWVzdGFtcBo5CgtGaW'
    'VsZHNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

