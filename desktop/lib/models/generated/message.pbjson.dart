// This is a generated file - do not edit.
//
// Generated from message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use chatSceneDescriptor instead')
const ChatScene$json = {
  '1': 'ChatScene',
  '2': [
    {'1': 'CHAT_UNKNOWN', '2': 0},
    {'1': 'SINGLE', '2': 1},
    {'1': 'GROUP', '2': 2},
  ],
};

/// Descriptor for `ChatScene`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List chatSceneDescriptor = $convert.base64Decode(
    'CglDaGF0U2NlbmUSEAoMQ0hBVF9VTktOT1dOEAASCgoGU0lOR0xFEAESCQoFR1JPVVAQAg==');

@$core.Deprecated('Use emojiTypeDescriptor instead')
const EmojiType$json = {
  '1': 'EmojiType',
  '2': [
    {'1': 'EMOJI_UNKNOWN', '2': 0},
    {'1': 'SMILE', '2': 1},
    {'1': 'GRIN', '2': 2},
    {'1': 'TEARS', '2': 3},
    {'1': 'STUCK_OUT_TONGUE', '2': 4},
    {'1': 'CLAP', '2': 25},
    {'1': 'POOP', '2': 28},
    {'1': 'HEART', '2': 21},
    {'1': 'CUSTOM_EMOJI', '2': 1000},
  ],
};

/// Descriptor for `EmojiType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List emojiTypeDescriptor = $convert.base64Decode(
    'CglFbW9qaVR5cGUSEQoNRU1PSklfVU5LTk9XThAAEgkKBVNNSUxFEAESCAoER1JJThACEgkKBV'
    'RFQVJTEAMSFAoQU1RVQ0tfT1VUX1RPTkdVRRAEEggKBENMQVAQGRIICgRQT09QEBwSCQoFSEVB'
    'UlQQFRIRCgxDVVNUT01fRU1PSkkQ6Ac=');

@$core.Deprecated('Use messageContentDescriptor instead')
const MessageContent$json = {
  '1': 'MessageContent',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 11, '6': '.protocol.message.TextContent', '9': 0, '10': 'text'},
    {'1': 'image', '3': 2, '4': 1, '5': 11, '6': '.protocol.message.ImageContent', '9': 0, '10': 'image'},
    {'1': 'audio', '3': 3, '4': 1, '5': 11, '6': '.protocol.message.AudioContent', '9': 0, '10': 'audio'},
    {'1': 'video', '3': 4, '4': 1, '5': 11, '6': '.protocol.message.VideoContent', '9': 0, '10': 'video'},
    {'1': 'location', '3': 5, '4': 1, '5': 11, '6': '.protocol.message.LocationContent', '9': 0, '10': 'location'},
    {'1': 'file', '3': 6, '4': 1, '5': 11, '6': '.protocol.message.FileContent', '9': 0, '10': 'file'},
    {'1': 'av_call', '3': 7, '4': 1, '5': 11, '6': '.protocol.message.AVCallContent', '9': 0, '10': 'avCall'},
    {'1': 'custom', '3': 8, '4': 1, '5': 11, '6': '.protocol.message.CustomContent', '9': 0, '10': 'custom'},
    {'1': 'emoji', '3': 9, '4': 1, '5': 11, '6': '.protocol.message.EmojiContent', '9': 0, '10': 'emoji'},
    {'1': 'revoke', '3': 10, '4': 1, '5': 11, '6': '.protocol.message.RevokeContent', '9': 0, '10': 'revoke'},
    {'1': 'forward', '3': 11, '4': 1, '5': 11, '6': '.protocol.message.ForwardContent', '9': 0, '10': 'forward'},
    {'1': 'quote', '3': 12, '4': 1, '5': 11, '6': '.protocol.message.QuoteContent', '9': 0, '10': 'quote'},
    {'1': 'html', '3': 13, '4': 1, '5': 11, '6': '.protocol.message.HtmlContent', '9': 0, '10': 'html'},
    {'1': 'voip', '3': 14, '4': 1, '5': 11, '6': '.protocol.message.VoipContent', '9': 0, '10': 'voip'},
    {'1': 'notification', '3': 15, '4': 1, '5': 11, '6': '.protocol.message.NotificationContent', '9': 0, '10': 'notification'},
    {'1': 'system', '3': 16, '4': 1, '5': 11, '6': '.protocol.message.SystemContent', '9': 0, '10': 'system'},
    {'1': 'reminder', '3': 17, '4': 1, '5': 11, '6': '.protocol.message.ReminderContent', '9': 0, '10': 'reminder'},
    {'1': 'group_event', '3': 18, '4': 1, '5': 11, '6': '.protocol.message.GroupEventContent', '9': 0, '10': 'groupEvent'},
    {'1': 'contact_card', '3': 19, '4': 1, '5': 11, '6': '.protocol.message.ContactCardContent', '9': 0, '10': 'contactCard'},
    {'1': 'vote', '3': 20, '4': 1, '5': 11, '6': '.protocol.message.VoteContent', '9': 0, '10': 'vote'},
    {'1': 'red_envelope', '3': 21, '4': 1, '5': 11, '6': '.protocol.message.RedEnvelopeContent', '9': 0, '10': 'redEnvelope'},
  ],
  '8': [
    {'1': 'content'},
  ],
};

/// Descriptor for `MessageContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageContentDescriptor = $convert.base64Decode(
    'Cg5NZXNzYWdlQ29udGVudBIzCgR0ZXh0GAEgASgLMh0ucHJvdG9jb2wubWVzc2FnZS5UZXh0Q2'
    '9udGVudEgAUgR0ZXh0EjYKBWltYWdlGAIgASgLMh4ucHJvdG9jb2wubWVzc2FnZS5JbWFnZUNv'
    'bnRlbnRIAFIFaW1hZ2USNgoFYXVkaW8YAyABKAsyHi5wcm90b2NvbC5tZXNzYWdlLkF1ZGlvQ2'
    '9udGVudEgAUgVhdWRpbxI2CgV2aWRlbxgEIAEoCzIeLnByb3RvY29sLm1lc3NhZ2UuVmlkZW9D'
    'b250ZW50SABSBXZpZGVvEj8KCGxvY2F0aW9uGAUgASgLMiEucHJvdG9jb2wubWVzc2FnZS5Mb2'
    'NhdGlvbkNvbnRlbnRIAFIIbG9jYXRpb24SMwoEZmlsZRgGIAEoCzIdLnByb3RvY29sLm1lc3Nh'
    'Z2UuRmlsZUNvbnRlbnRIAFIEZmlsZRI6Cgdhdl9jYWxsGAcgASgLMh8ucHJvdG9jb2wubWVzc2'
    'FnZS5BVkNhbGxDb250ZW50SABSBmF2Q2FsbBI5CgZjdXN0b20YCCABKAsyHy5wcm90b2NvbC5t'
    'ZXNzYWdlLkN1c3RvbUNvbnRlbnRIAFIGY3VzdG9tEjYKBWVtb2ppGAkgASgLMh4ucHJvdG9jb2'
    'wubWVzc2FnZS5FbW9qaUNvbnRlbnRIAFIFZW1vamkSOQoGcmV2b2tlGAogASgLMh8ucHJvdG9j'
    'b2wubWVzc2FnZS5SZXZva2VDb250ZW50SABSBnJldm9rZRI8Cgdmb3J3YXJkGAsgASgLMiAucH'
    'JvdG9jb2wubWVzc2FnZS5Gb3J3YXJkQ29udGVudEgAUgdmb3J3YXJkEjYKBXF1b3RlGAwgASgL'
    'Mh4ucHJvdG9jb2wubWVzc2FnZS5RdW90ZUNvbnRlbnRIAFIFcXVvdGUSMwoEaHRtbBgNIAEoCz'
    'IdLnByb3RvY29sLm1lc3NhZ2UuSHRtbENvbnRlbnRIAFIEaHRtbBIzCgR2b2lwGA4gASgLMh0u'
    'cHJvdG9jb2wubWVzc2FnZS5Wb2lwQ29udGVudEgAUgR2b2lwEksKDG5vdGlmaWNhdGlvbhgPIA'
    'EoCzIlLnByb3RvY29sLm1lc3NhZ2UuTm90aWZpY2F0aW9uQ29udGVudEgAUgxub3RpZmljYXRp'
    'b24SOQoGc3lzdGVtGBAgASgLMh8ucHJvdG9jb2wubWVzc2FnZS5TeXN0ZW1Db250ZW50SABSBn'
    'N5c3RlbRI/CghyZW1pbmRlchgRIAEoCzIhLnByb3RvY29sLm1lc3NhZ2UuUmVtaW5kZXJDb250'
    'ZW50SABSCHJlbWluZGVyEkYKC2dyb3VwX2V2ZW50GBIgASgLMiMucHJvdG9jb2wubWVzc2FnZS'
    '5Hcm91cEV2ZW50Q29udGVudEgAUgpncm91cEV2ZW50EkkKDGNvbnRhY3RfY2FyZBgTIAEoCzIk'
    'LnByb3RvY29sLm1lc3NhZ2UuQ29udGFjdENhcmRDb250ZW50SABSC2NvbnRhY3RDYXJkEjMKBH'
    'ZvdGUYFCABKAsyHS5wcm90b2NvbC5tZXNzYWdlLlZvdGVDb250ZW50SABSBHZvdGUSSQoMcmVk'
    'X2VudmVsb3BlGBUgASgLMiQucHJvdG9jb2wubWVzc2FnZS5SZWRFbnZlbG9wZUNvbnRlbnRIAF'
    'ILcmVkRW52ZWxvcGVCCQoHY29udGVudA==');

@$core.Deprecated('Use textContentDescriptor instead')
const TextContent$json = {
  '1': 'TextContent',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'entities', '3': 2, '4': 3, '5': 11, '6': '.protocol.message.InlineEntity', '10': 'entities'},
  ],
};

/// Descriptor for `TextContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textContentDescriptor = $convert.base64Decode(
    'CgtUZXh0Q29udGVudBISCgR0ZXh0GAEgASgJUgR0ZXh0EjoKCGVudGl0aWVzGAIgAygLMh4ucH'
    'JvdG9jb2wubWVzc2FnZS5JbmxpbmVFbnRpdHlSCGVudGl0aWVz');

@$core.Deprecated('Use inlineEntityDescriptor instead')
const InlineEntity$json = {
  '1': 'InlineEntity',
  '2': [
    {'1': 'start', '3': 1, '4': 1, '5': 5, '10': 'start'},
    {'1': 'end', '3': 2, '4': 1, '5': 5, '10': 'end'},
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
    {'1': 'value', '3': 4, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `InlineEntity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inlineEntityDescriptor = $convert.base64Decode(
    'CgxJbmxpbmVFbnRpdHkSFAoFc3RhcnQYASABKAVSBXN0YXJ0EhAKA2VuZBgCIAEoBVIDZW5kEh'
    'IKBHR5cGUYAyABKAlSBHR5cGUSFAoFdmFsdWUYBCABKAlSBXZhbHVl');

@$core.Deprecated('Use imageContentDescriptor instead')
const ImageContent$json = {
  '1': 'ImageContent',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'thumbnail_url', '3': 2, '4': 1, '5': 9, '10': 'thumbnailUrl'},
    {'1': 'width', '3': 3, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 4, '4': 1, '5': 5, '10': 'height'},
    {'1': 'format', '3': 5, '4': 1, '5': 9, '10': 'format'},
    {'1': 'size', '3': 6, '4': 1, '5': 3, '10': 'size'},
  ],
};

/// Descriptor for `ImageContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageContentDescriptor = $convert.base64Decode(
    'CgxJbWFnZUNvbnRlbnQSEAoDdXJsGAEgASgJUgN1cmwSIwoNdGh1bWJuYWlsX3VybBgCIAEoCV'
    'IMdGh1bWJuYWlsVXJsEhQKBXdpZHRoGAMgASgFUgV3aWR0aBIWCgZoZWlnaHQYBCABKAVSBmhl'
    'aWdodBIWCgZmb3JtYXQYBSABKAlSBmZvcm1hdBISCgRzaXplGAYgASgDUgRzaXpl');

@$core.Deprecated('Use audioContentDescriptor instead')
const AudioContent$json = {
  '1': 'AudioContent',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'duration', '3': 2, '4': 1, '5': 5, '10': 'duration'},
    {'1': 'format', '3': 3, '4': 1, '5': 9, '10': 'format'},
    {'1': 'size', '3': 4, '4': 1, '5': 3, '10': 'size'},
    {'1': 'is_voice', '3': 5, '4': 1, '5': 8, '10': 'isVoice'},
  ],
};

/// Descriptor for `AudioContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List audioContentDescriptor = $convert.base64Decode(
    'CgxBdWRpb0NvbnRlbnQSEAoDdXJsGAEgASgJUgN1cmwSGgoIZHVyYXRpb24YAiABKAVSCGR1cm'
    'F0aW9uEhYKBmZvcm1hdBgDIAEoCVIGZm9ybWF0EhIKBHNpemUYBCABKANSBHNpemUSGQoIaXNf'
    'dm9pY2UYBSABKAhSB2lzVm9pY2U=');

@$core.Deprecated('Use videoContentDescriptor instead')
const VideoContent$json = {
  '1': 'VideoContent',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'duration', '3': 2, '4': 1, '5': 5, '10': 'duration'},
    {'1': 'cover_url', '3': 3, '4': 1, '5': 9, '10': 'coverUrl'},
    {'1': 'width', '3': 4, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 5, '4': 1, '5': 5, '10': 'height'},
    {'1': 'format', '3': 6, '4': 1, '5': 9, '10': 'format'},
    {'1': 'size', '3': 7, '4': 1, '5': 3, '10': 'size'},
  ],
};

/// Descriptor for `VideoContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List videoContentDescriptor = $convert.base64Decode(
    'CgxWaWRlb0NvbnRlbnQSEAoDdXJsGAEgASgJUgN1cmwSGgoIZHVyYXRpb24YAiABKAVSCGR1cm'
    'F0aW9uEhsKCWNvdmVyX3VybBgDIAEoCVIIY292ZXJVcmwSFAoFd2lkdGgYBCABKAVSBXdpZHRo'
    'EhYKBmhlaWdodBgFIAEoBVIGaGVpZ2h0EhYKBmZvcm1hdBgGIAEoCVIGZm9ybWF0EhIKBHNpem'
    'UYByABKANSBHNpemU=');

@$core.Deprecated('Use locationContentDescriptor instead')
const LocationContent$json = {
  '1': 'LocationContent',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'poi_name', '3': 4, '4': 1, '5': 9, '10': 'poiName'},
    {'1': 'thumbnail_url', '3': 5, '4': 1, '5': 9, '10': 'thumbnailUrl'},
  ],
};

/// Descriptor for `LocationContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationContentDescriptor = $convert.base64Decode(
    'Cg9Mb2NhdGlvbkNvbnRlbnQSGgoIbGF0aXR1ZGUYASABKAFSCGxhdGl0dWRlEhwKCWxvbmdpdH'
    'VkZRgCIAEoAVIJbG9uZ2l0dWRlEhgKB2FkZHJlc3MYAyABKAlSB2FkZHJlc3MSGQoIcG9pX25h'
    'bWUYBCABKAlSB3BvaU5hbWUSIwoNdGh1bWJuYWlsX3VybBgFIAEoCVIMdGh1bWJuYWlsVXJs');

@$core.Deprecated('Use fileContentDescriptor instead')
const FileContent$json = {
  '1': 'FileContent',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'size', '3': 3, '4': 1, '5': 3, '10': 'size'},
    {'1': 'file_type', '3': 4, '4': 1, '5': 9, '10': 'fileType'},
    {'1': 'icon_url', '3': 5, '4': 1, '5': 9, '10': 'iconUrl'},
  ],
};

/// Descriptor for `FileContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileContentDescriptor = $convert.base64Decode(
    'CgtGaWxlQ29udGVudBIQCgN1cmwYASABKAlSA3VybBISCgRuYW1lGAIgASgJUgRuYW1lEhIKBH'
    'NpemUYAyABKANSBHNpemUSGwoJZmlsZV90eXBlGAQgASgJUghmaWxlVHlwZRIZCghpY29uX3Vy'
    'bBgFIAEoCVIHaWNvblVybA==');

@$core.Deprecated('Use aVCallContentDescriptor instead')
const AVCallContent$json = {
  '1': 'AVCallContent',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'initiator_id', '3': 2, '4': 1, '5': 9, '10': 'initiatorId'},
    {'1': 'participant_ids', '3': 3, '4': 3, '5': 9, '10': 'participantIds'},
    {'1': 'action', '3': 4, '4': 1, '5': 14, '6': '.protocol.message.AVCallContent.CallAction', '10': 'action'},
    {'1': 'type', '3': 5, '4': 1, '5': 14, '6': '.protocol.message.AVCallContent.CallType', '10': 'type'},
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'duration', '3': 7, '4': 1, '5': 5, '10': 'duration'},
  ],
  '4': [AVCallContent_CallAction$json, AVCallContent_CallType$json],
};

@$core.Deprecated('Use aVCallContentDescriptor instead')
const AVCallContent_CallAction$json = {
  '1': 'CallAction',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'INVITE', '2': 1},
    {'1': 'ACCEPT', '2': 2},
    {'1': 'REJECT', '2': 3},
    {'1': 'CANCEL', '2': 4},
    {'1': 'END', '2': 5},
    {'1': 'TIMEOUT', '2': 6},
  ],
};

@$core.Deprecated('Use aVCallContentDescriptor instead')
const AVCallContent_CallType$json = {
  '1': 'CallType',
  '2': [
    {'1': 'AUDIO', '2': 0},
    {'1': 'VIDEO', '2': 1},
  ],
};

/// Descriptor for `AVCallContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aVCallContentDescriptor = $convert.base64Decode(
    'Cg1BVkNhbGxDb250ZW50EhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBIhCgxpbml0aWF0b3JfaW'
    'QYAiABKAlSC2luaXRpYXRvcklkEicKD3BhcnRpY2lwYW50X2lkcxgDIAMoCVIOcGFydGljaXBh'
    'bnRJZHMSQgoGYWN0aW9uGAQgASgOMioucHJvdG9jb2wubWVzc2FnZS5BVkNhbGxDb250ZW50Lk'
    'NhbGxBY3Rpb25SBmFjdGlvbhI8CgR0eXBlGAUgASgOMigucHJvdG9jb2wubWVzc2FnZS5BVkNh'
    'bGxDb250ZW50LkNhbGxUeXBlUgR0eXBlEhwKCXRpbWVzdGFtcBgGIAEoA1IJdGltZXN0YW1wEh'
    'oKCGR1cmF0aW9uGAcgASgFUghkdXJhdGlvbiJfCgpDYWxsQWN0aW9uEgsKB1VOS05PV04QABIK'
    'CgZJTlZJVEUQARIKCgZBQ0NFUFQQAhIKCgZSRUpFQ1QQAxIKCgZDQU5DRUwQBBIHCgNFTkQQBR'
    'ILCgdUSU1FT1VUEAYiIAoIQ2FsbFR5cGUSCQoFQVVESU8QABIJCgVWSURFTxAB');

@$core.Deprecated('Use customContentDescriptor instead')
const CustomContent$json = {
  '1': 'CustomContent',
  '2': [
    {'1': 'custom_type', '3': 1, '4': 1, '5': 9, '10': 'customType'},
    {'1': 'json_payload', '3': 2, '4': 1, '5': 9, '10': 'jsonPayload'},
  ],
};

/// Descriptor for `CustomContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customContentDescriptor = $convert.base64Decode(
    'Cg1DdXN0b21Db250ZW50Eh8KC2N1c3RvbV90eXBlGAEgASgJUgpjdXN0b21UeXBlEiEKDGpzb2'
    '5fcGF5bG9hZBgCIAEoCVILanNvblBheWxvYWQ=');

@$core.Deprecated('Use emojiContentDescriptor instead')
const EmojiContent$json = {
  '1': 'EmojiContent',
  '2': [
    {'1': 'emoji', '3': 1, '4': 1, '5': 14, '6': '.protocol.message.EmojiType', '10': 'emoji'},
    {'1': 'custom_emoji_url', '3': 2, '4': 1, '5': 9, '10': 'customEmojiUrl'},
  ],
};

/// Descriptor for `EmojiContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emojiContentDescriptor = $convert.base64Decode(
    'CgxFbW9qaUNvbnRlbnQSMQoFZW1vamkYASABKA4yGy5wcm90b2NvbC5tZXNzYWdlLkVtb2ppVH'
    'lwZVIFZW1vamkSKAoQY3VzdG9tX2Vtb2ppX3VybBgCIAEoCVIOY3VzdG9tRW1vamlVcmw=');

@$core.Deprecated('Use revokeContentDescriptor instead')
const RevokeContent$json = {
  '1': 'RevokeContent',
  '2': [
    {'1': 'target_message_id', '3': 1, '4': 1, '5': 4, '10': 'targetMessageId'},
    {'1': 'operator_id', '3': 2, '4': 1, '5': 9, '10': 'operatorId'},
    {'1': 'revoke_time', '3': 3, '4': 1, '5': 3, '10': 'revokeTime'},
  ],
};

/// Descriptor for `RevokeContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeContentDescriptor = $convert.base64Decode(
    'Cg1SZXZva2VDb250ZW50EioKEXRhcmdldF9tZXNzYWdlX2lkGAEgASgEUg90YXJnZXRNZXNzYW'
    'dlSWQSHwoLb3BlcmF0b3JfaWQYAiABKAlSCm9wZXJhdG9ySWQSHwoLcmV2b2tlX3RpbWUYAyAB'
    'KANSCnJldm9rZVRpbWU=');

@$core.Deprecated('Use forwardContentDescriptor instead')
const ForwardContent$json = {
  '1': 'ForwardContent',
  '2': [
    {'1': 'original_message_id', '3': 1, '4': 1, '5': 4, '10': 'originalMessageId'},
    {'1': 'original_sender_id', '3': 2, '4': 1, '5': 9, '10': 'originalSenderId'},
    {'1': 'original_type', '3': 3, '4': 1, '5': 14, '6': '.common.ContentType', '10': 'originalType'},
    {'1': 'summary', '3': 4, '4': 1, '5': 9, '10': 'summary'},
  ],
};

/// Descriptor for `ForwardContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forwardContentDescriptor = $convert.base64Decode(
    'Cg5Gb3J3YXJkQ29udGVudBIuChNvcmlnaW5hbF9tZXNzYWdlX2lkGAEgASgEUhFvcmlnaW5hbE'
    '1lc3NhZ2VJZBIsChJvcmlnaW5hbF9zZW5kZXJfaWQYAiABKAlSEG9yaWdpbmFsU2VuZGVySWQS'
    'OAoNb3JpZ2luYWxfdHlwZRgDIAEoDjITLmNvbW1vbi5Db250ZW50VHlwZVIMb3JpZ2luYWxUeX'
    'BlEhgKB3N1bW1hcnkYBCABKAlSB3N1bW1hcnk=');

@$core.Deprecated('Use quoteContentDescriptor instead')
const QuoteContent$json = {
  '1': 'QuoteContent',
  '2': [
    {'1': 'quoted_message_id', '3': 1, '4': 1, '5': 4, '10': 'quotedMessageId'},
    {'1': 'quoted_content_preview', '3': 2, '4': 1, '5': 9, '10': 'quotedContentPreview'},
    {'1': 'quote_text', '3': 3, '4': 1, '5': 9, '10': 'quoteText'},
  ],
};

/// Descriptor for `QuoteContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quoteContentDescriptor = $convert.base64Decode(
    'CgxRdW90ZUNvbnRlbnQSKgoRcXVvdGVkX21lc3NhZ2VfaWQYASABKARSD3F1b3RlZE1lc3NhZ2'
    'VJZBI0ChZxdW90ZWRfY29udGVudF9wcmV2aWV3GAIgASgJUhRxdW90ZWRDb250ZW50UHJldmll'
    'dxIdCgpxdW90ZV90ZXh0GAMgASgJUglxdW90ZVRleHQ=');

@$core.Deprecated('Use htmlContentDescriptor instead')
const HtmlContent$json = {
  '1': 'HtmlContent',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'preview', '3': 3, '4': 1, '5': 9, '10': 'preview'},
  ],
};

/// Descriptor for `HtmlContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List htmlContentDescriptor = $convert.base64Decode(
    'CgtIdG1sQ29udGVudBIUCgV0aXRsZRgBIAEoCVIFdGl0bGUSEAoDdXJsGAIgASgJUgN1cmwSGA'
    'oHcHJldmlldxgDIAEoCVIHcHJldmlldw==');

@$core.Deprecated('Use voipContentDescriptor instead')
const VoipContent$json = {
  '1': 'VoipContent',
  '2': [
    {'1': 'caller_id', '3': 1, '4': 1, '5': 9, '10': 'callerId'},
    {'1': 'callee_id', '3': 2, '4': 1, '5': 9, '10': 'calleeId'},
    {'1': 'duration', '3': 3, '4': 1, '5': 3, '10': 'duration'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `VoipContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voipContentDescriptor = $convert.base64Decode(
    'CgtWb2lwQ29udGVudBIbCgljYWxsZXJfaWQYASABKAlSCGNhbGxlcklkEhsKCWNhbGxlZV9pZB'
    'gCIAEoCVIIY2FsbGVlSWQSGgoIZHVyYXRpb24YAyABKANSCGR1cmF0aW9uEhYKBnN0YXR1cxgE'
    'IAEoCVIGc3RhdHVz');

@$core.Deprecated('Use notificationContentDescriptor instead')
const NotificationContent$json = {
  '1': 'NotificationContent',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'body', '3': 2, '4': 1, '5': 9, '10': 'body'},
    {'1': 'metadata', '3': 3, '4': 3, '5': 11, '6': '.protocol.message.NotificationContent.MetadataEntry', '10': 'metadata'},
  ],
  '3': [NotificationContent_MetadataEntry$json],
};

@$core.Deprecated('Use notificationContentDescriptor instead')
const NotificationContent_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `NotificationContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationContentDescriptor = $convert.base64Decode(
    'ChNOb3RpZmljYXRpb25Db250ZW50EhQKBXRpdGxlGAEgASgJUgV0aXRsZRISCgRib2R5GAIgAS'
    'gJUgRib2R5Ek8KCG1ldGFkYXRhGAMgAygLMjMucHJvdG9jb2wubWVzc2FnZS5Ob3RpZmljYXRp'
    'b25Db250ZW50Lk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhGjsKDU1ldGFkYXRhRW50cnkSEAoDa2'
    'V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use systemContentDescriptor instead')
const SystemContent$json = {
  '1': 'SystemContent',
  '2': [
    {'1': 'content', '3': 1, '4': 1, '5': 9, '10': 'content'},
    {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `SystemContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemContentDescriptor = $convert.base64Decode(
    'Cg1TeXN0ZW1Db250ZW50EhgKB2NvbnRlbnQYASABKAlSB2NvbnRlbnQSEgoEY29kZRgCIAEoCV'
    'IEY29kZQ==');

@$core.Deprecated('Use reminderContentDescriptor instead')
const ReminderContent$json = {
  '1': 'ReminderContent',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'remind_at', '3': 2, '4': 1, '5': 3, '10': 'remindAt'},
  ],
};

/// Descriptor for `ReminderContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reminderContentDescriptor = $convert.base64Decode(
    'Cg9SZW1pbmRlckNvbnRlbnQSEgoEdGV4dBgBIAEoCVIEdGV4dBIbCglyZW1pbmRfYXQYAiABKA'
    'NSCHJlbWluZEF0');

@$core.Deprecated('Use groupEventContentDescriptor instead')
const GroupEventContent$json = {
  '1': 'GroupEventContent',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'event', '3': 2, '4': 1, '5': 9, '10': 'event'},
    {'1': 'operator_id', '3': 3, '4': 1, '5': 9, '10': 'operatorId'},
  ],
};

/// Descriptor for `GroupEventContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupEventContentDescriptor = $convert.base64Decode(
    'ChFHcm91cEV2ZW50Q29udGVudBIZCghncm91cF9pZBgBIAEoCVIHZ3JvdXBJZBIUCgVldmVudB'
    'gCIAEoCVIFZXZlbnQSHwoLb3BlcmF0b3JfaWQYAyABKAlSCm9wZXJhdG9ySWQ=');

@$core.Deprecated('Use contactCardContentDescriptor instead')
const ContactCardContent$json = {
  '1': 'ContactCardContent',
  '2': [
    {'1': 'target_id', '3': 1, '4': 1, '5': 9, '10': 'targetId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'card_type', '3': 4, '4': 1, '5': 9, '10': 'cardType'},
  ],
};

/// Descriptor for `ContactCardContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactCardContentDescriptor = $convert.base64Decode(
    'ChJDb250YWN0Q2FyZENvbnRlbnQSGwoJdGFyZ2V0X2lkGAEgASgJUgh0YXJnZXRJZBIhCgxkaX'
    'NwbGF5X25hbWUYAiABKAlSC2Rpc3BsYXlOYW1lEh0KCmF2YXRhcl91cmwYAyABKAlSCWF2YXRh'
    'clVybBIbCgljYXJkX3R5cGUYBCABKAlSCGNhcmRUeXBl');

@$core.Deprecated('Use voteContentDescriptor instead')
const VoteContent$json = {
  '1': 'VoteContent',
  '2': [
    {'1': 'topic', '3': 1, '4': 1, '5': 9, '10': 'topic'},
    {'1': 'options', '3': 2, '4': 3, '5': 9, '10': 'options'},
    {'1': 'result', '3': 3, '4': 3, '5': 11, '6': '.protocol.message.VoteContent.ResultEntry', '10': 'result'},
    {'1': 'multi_choice', '3': 4, '4': 1, '5': 8, '10': 'multiChoice'},
  ],
  '3': [VoteContent_ResultEntry$json],
};

@$core.Deprecated('Use voteContentDescriptor instead')
const VoteContent_ResultEntry$json = {
  '1': 'ResultEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `VoteContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteContentDescriptor = $convert.base64Decode(
    'CgtWb3RlQ29udGVudBIUCgV0b3BpYxgBIAEoCVIFdG9waWMSGAoHb3B0aW9ucxgCIAMoCVIHb3'
    'B0aW9ucxJBCgZyZXN1bHQYAyADKAsyKS5wcm90b2NvbC5tZXNzYWdlLlZvdGVDb250ZW50LlJl'
    'c3VsdEVudHJ5UgZyZXN1bHQSIQoMbXVsdGlfY2hvaWNlGAQgASgIUgttdWx0aUNob2ljZRo5Cg'
    'tSZXN1bHRFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgB');

@$core.Deprecated('Use redEnvelopeContentDescriptor instead')
const RedEnvelopeContent$json = {
  '1': 'RedEnvelopeContent',
  '2': [
    {'1': 'sender_id', '3': 1, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'amount', '3': 2, '4': 1, '5': 5, '10': 'amount'},
    {'1': 'blessing', '3': 3, '4': 1, '5': 9, '10': 'blessing'},
    {'1': 'claimed', '3': 4, '4': 1, '5': 8, '10': 'claimed'},
  ],
};

/// Descriptor for `RedEnvelopeContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List redEnvelopeContentDescriptor = $convert.base64Decode(
    'ChJSZWRFbnZlbG9wZUNvbnRlbnQSGwoJc2VuZGVyX2lkGAEgASgJUghzZW5kZXJJZBIWCgZhbW'
    '91bnQYAiABKAVSBmFtb3VudBIaCghibGVzc2luZxgDIAEoCVIIYmxlc3NpbmcSGAoHY2xhaW1l'
    'ZBgEIAEoCFIHY2xhaW1lZA==');

@$core.Deprecated('Use segmentDescriptor instead')
const Segment$json = {
  '1': 'Segment',
  '2': [
    {'1': 'body', '3': 1, '4': 1, '5': 11, '6': '.protocol.message.MessageContent', '10': 'body'},
    {'1': 'segment_id', '3': 2, '4': 1, '5': 9, '10': 'segmentId'},
    {'1': 'seq_in_msg', '3': 3, '4': 1, '5': 4, '10': 'seqInMsg'},
    {'1': 'edited', '3': 4, '4': 1, '5': 8, '10': 'edited'},
    {'1': 'visible', '3': 5, '4': 1, '5': 8, '10': 'visible'},
    {'1': 'metadata', '3': 6, '4': 3, '5': 11, '6': '.protocol.message.Segment.MetadataEntry', '10': 'metadata'},
  ],
  '3': [Segment_MetadataEntry$json],
};

@$core.Deprecated('Use segmentDescriptor instead')
const Segment_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Segment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List segmentDescriptor = $convert.base64Decode(
    'CgdTZWdtZW50EjQKBGJvZHkYASABKAsyIC5wcm90b2NvbC5tZXNzYWdlLk1lc3NhZ2VDb250ZW'
    '50UgRib2R5Eh0KCnNlZ21lbnRfaWQYAiABKAlSCXNlZ21lbnRJZBIcCgpzZXFfaW5fbXNnGAMg'
    'ASgEUghzZXFJbk1zZxIWCgZlZGl0ZWQYBCABKAhSBmVkaXRlZBIYCgd2aXNpYmxlGAUgASgIUg'
    'd2aXNpYmxlEkMKCG1ldGFkYXRhGAYgAygLMicucHJvdG9jb2wubWVzc2FnZS5TZWdtZW50Lk1l'
    'dGFkYXRhRW50cnlSCG1ldGFkYXRhGjsKDU1ldGFkYXRhRW50cnkSEAoDa2V5GAEgASgJUgNrZX'
    'kSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use contentDescriptor instead')
const Content$json = {
  '1': 'Content',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '9': 0, '10': 'messageId', '17': true},
    {'1': 'sender_id', '3': 2, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'receiver_id', '3': 3, '4': 1, '5': 9, '10': 'receiverId'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'message_type', '3': 5, '4': 1, '5': 14, '6': '.common.ContentType', '10': 'messageType'},
    {'1': 'scene', '3': 6, '4': 1, '5': 14, '6': '.protocol.message.ChatScene', '10': 'scene'},
    {'1': 'contents', '3': 10, '4': 3, '5': 11, '6': '.protocol.message.MessageContent', '10': 'contents'},
  ],
  '8': [
    {'1': '_message_id'},
  ],
};

/// Descriptor for `Content`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contentDescriptor = $convert.base64Decode(
    'CgdDb250ZW50EiIKCm1lc3NhZ2VfaWQYASABKARIAFIJbWVzc2FnZUlkiAEBEhsKCXNlbmRlcl'
    '9pZBgCIAEoCVIIc2VuZGVySWQSHwoLcmVjZWl2ZXJfaWQYAyABKAlSCnJlY2VpdmVySWQSHAoJ'
    'dGltZXN0YW1wGAQgASgDUgl0aW1lc3RhbXASNgoMbWVzc2FnZV90eXBlGAUgASgOMhMuY29tbW'
    '9uLkNvbnRlbnRUeXBlUgttZXNzYWdlVHlwZRIxCgVzY2VuZRgGIAEoDjIbLnByb3RvY29sLm1l'
    'c3NhZ2UuQ2hhdFNjZW5lUgVzY2VuZRI8Cghjb250ZW50cxgKIAMoCzIgLnByb3RvY29sLm1lc3'
    'NhZ2UuTWVzc2FnZUNvbnRlbnRSCGNvbnRlbnRzQg0KC19tZXNzYWdlX2lk');

