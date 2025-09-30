// This is a generated file - do not edit.
//
// Generated from system.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use systemNotificationMsgDescriptor instead')
const SystemNotificationMsg$json = {
  '1': 'SystemNotificationMsg',
  '2': [
    {'1': 'notification_type', '3': 1, '4': 1, '5': 9, '10': 'notificationType'},
    {'1': 'sender', '3': 2, '4': 1, '5': 9, '10': 'sender'},
    {'1': 'target', '3': 3, '4': 1, '5': 9, '10': 'target'},
    {'1': 'content', '3': 4, '4': 1, '5': 9, '10': 'content'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'meta', '3': 6, '4': 3, '5': 11, '6': '.protocol.system.SystemNotificationMsg.MetaEntry', '10': 'meta'},
  ],
  '3': [SystemNotificationMsg_MetaEntry$json],
};

@$core.Deprecated('Use systemNotificationMsgDescriptor instead')
const SystemNotificationMsg_MetaEntry$json = {
  '1': 'MetaEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SystemNotificationMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemNotificationMsgDescriptor = $convert.base64Decode(
    'ChVTeXN0ZW1Ob3RpZmljYXRpb25Nc2cSKwoRbm90aWZpY2F0aW9uX3R5cGUYASABKAlSEG5vdG'
    'lmaWNhdGlvblR5cGUSFgoGc2VuZGVyGAIgASgJUgZzZW5kZXISFgoGdGFyZ2V0GAMgASgJUgZ0'
    'YXJnZXQSGAoHY29udGVudBgEIAEoCVIHY29udGVudBIcCgl0aW1lc3RhbXAYBSABKANSCXRpbW'
    'VzdGFtcBJECgRtZXRhGAYgAygLMjAucHJvdG9jb2wuc3lzdGVtLlN5c3RlbU5vdGlmaWNhdGlv'
    'bk1zZy5NZXRhRW50cnlSBG1ldGEaNwoJTWV0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBX'
    'ZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use systemEventMsgDescriptor instead')
const SystemEventMsg$json = {
  '1': 'SystemEventMsg',
  '2': [
    {'1': 'event_type', '3': 1, '4': 1, '5': 9, '10': 'eventType'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'details', '3': 3, '4': 3, '5': 11, '6': '.protocol.system.SystemEventMsg.DetailsEntry', '10': 'details'},
  ],
  '3': [SystemEventMsg_DetailsEntry$json],
};

@$core.Deprecated('Use systemEventMsgDescriptor instead')
const SystemEventMsg_DetailsEntry$json = {
  '1': 'DetailsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SystemEventMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemEventMsgDescriptor = $convert.base64Decode(
    'Cg5TeXN0ZW1FdmVudE1zZxIdCgpldmVudF90eXBlGAEgASgJUglldmVudFR5cGUSIAoLZGVzY3'
    'JpcHRpb24YAiABKAlSC2Rlc2NyaXB0aW9uEkYKB2RldGFpbHMYAyADKAsyLC5wcm90b2NvbC5z'
    'eXN0ZW0uU3lzdGVtRXZlbnRNc2cuRGV0YWlsc0VudHJ5UgdkZXRhaWxzGjoKDERldGFpbHNFbn'
    'RyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

