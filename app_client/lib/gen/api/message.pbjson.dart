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

@$core.Deprecated('Use callMediaTypeDescriptor instead')
const CallMediaType$json = {
  '1': 'CallMediaType',
  '2': [
    {'1': 'CALL_AUDIO', '2': 0},
    {'1': 'CALL_VIDEO', '2': 1},
  ],
};

/// Descriptor for `CallMediaType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List callMediaTypeDescriptor = $convert.base64Decode(
    'Cg1DYWxsTWVkaWFUeXBlEg4KCkNBTExfQVVESU8QABIOCgpDQUxMX1ZJREVPEAE=');

@$core.Deprecated('Use callEndReasonDescriptor instead')
const CallEndReason$json = {
  '1': 'CallEndReason',
  '2': [
    {'1': 'CER_UNSPECIFIED', '2': 0},
    {'1': 'CER_CANCELLED', '2': 1},
    {'1': 'CER_REJECTED', '2': 2},
    {'1': 'CER_BUSY', '2': 3},
    {'1': 'CER_TIMEOUT', '2': 4},
    {'1': 'CER_HANGUP', '2': 5},
    {'1': 'CER_FAILED', '2': 6},
  ],
};

/// Descriptor for `CallEndReason`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List callEndReasonDescriptor = $convert.base64Decode(
    'Cg1DYWxsRW5kUmVhc29uEhMKD0NFUl9VTlNQRUNJRklFRBAAEhEKDUNFUl9DQU5DRUxMRUQQAR'
    'IQCgxDRVJfUkVKRUNURUQQAhIMCghDRVJfQlVTWRADEg8KC0NFUl9USU1FT1VUEAQSDgoKQ0VS'
    'X0hBTkdVUBAFEg4KCkNFUl9GQUlMRUQQBg==');

@$core.Deprecated('Use callModifyTypeDescriptor instead')
const CallModifyType$json = {
  '1': 'CallModifyType',
  '2': [
    {'1': 'CMT_UNSPECIFIED', '2': 0},
    {'1': 'CMT_MUTE', '2': 1},
    {'1': 'CMT_CAMERA', '2': 2},
    {'1': 'CMT_HOLD', '2': 3},
    {'1': 'CMT_SWITCH_CAMERA', '2': 4},
  ],
};

/// Descriptor for `CallModifyType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List callModifyTypeDescriptor = $convert.base64Decode(
    'Cg5DYWxsTW9kaWZ5VHlwZRITCg9DTVRfVU5TUEVDSUZJRUQQABIMCghDTVRfTVVURRABEg4KCk'
    'NNVF9DQU1FUkEQAhIMCghDTVRfSE9MRBADEhUKEUNNVF9TV0lUQ0hfQ0FNRVJBEAQ=');

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

@$core.Deprecated('Use reactionActionDescriptor instead')
const ReactionAction$json = {
  '1': 'ReactionAction',
  '2': [
    {'1': 'RA_UNKNOWN', '2': 0},
    {'1': 'RA_ADD', '2': 1},
    {'1': 'RA_REMOVE', '2': 2},
  ],
};

/// Descriptor for `ReactionAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List reactionActionDescriptor = $convert.base64Decode(
    'Cg5SZWFjdGlvbkFjdGlvbhIOCgpSQV9VTktOT1dOEAASCgoGUkFfQUREEAESDQoJUkFfUkVNT1'
    'ZFEAI=');

@$core.Deprecated('Use typingStateDescriptor instead')
const TypingState$json = {
  '1': 'TypingState',
  '2': [
    {'1': 'TYPING_NONE', '2': 0},
    {'1': 'TYPING_TEXT', '2': 1},
    {'1': 'TYPING_VOICE', '2': 2},
    {'1': 'TYPING_UPLOAD', '2': 3},
  ],
};

/// Descriptor for `TypingState`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List typingStateDescriptor = $convert.base64Decode(
    'CgtUeXBpbmdTdGF0ZRIPCgtUWVBJTkdfTk9ORRAAEg8KC1RZUElOR19URVhUEAESEAoMVFlQSU'
    '5HX1ZPSUNFEAISEQoNVFlQSU5HX1VQTE9BRBAD');

@$core.Deprecated('Use messageContentDescriptor instead')
const MessageContent$json = {
  '1': 'MessageContent',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 11, '6': '.message.TextContent', '9': 0, '10': 'text'},
    {'1': 'image', '3': 2, '4': 1, '5': 11, '6': '.message.ImageContent', '9': 0, '10': 'image'},
    {'1': 'audio', '3': 3, '4': 1, '5': 11, '6': '.message.AudioContent', '9': 0, '10': 'audio'},
    {'1': 'video', '3': 4, '4': 1, '5': 11, '6': '.message.VideoContent', '9': 0, '10': 'video'},
    {'1': 'location', '3': 5, '4': 1, '5': 11, '6': '.message.LocationContent', '9': 0, '10': 'location'},
    {'1': 'file', '3': 6, '4': 1, '5': 11, '6': '.message.FileContent', '9': 0, '10': 'file'},
    {'1': 'av_call', '3': 7, '4': 1, '5': 11, '6': '.message.AVCallContent', '9': 0, '10': 'avCall'},
    {'1': 'custom', '3': 8, '4': 1, '5': 11, '6': '.message.CustomContent', '9': 0, '10': 'custom'},
    {'1': 'emoji', '3': 9, '4': 1, '5': 11, '6': '.message.EmojiContent', '9': 0, '10': 'emoji'},
    {'1': 'revoke', '3': 10, '4': 1, '5': 11, '6': '.message.RevokeContent', '9': 0, '10': 'revoke'},
    {'1': 'forward', '3': 11, '4': 1, '5': 11, '6': '.message.ForwardContent', '9': 0, '10': 'forward'},
    {'1': 'quote', '3': 12, '4': 1, '5': 11, '6': '.message.QuoteContent', '9': 0, '10': 'quote'},
    {'1': 'html', '3': 13, '4': 1, '5': 11, '6': '.message.HtmlContent', '9': 0, '10': 'html'},
    {'1': 'voip', '3': 14, '4': 1, '5': 11, '6': '.message.VoipContent', '9': 0, '10': 'voip'},
    {'1': 'notification', '3': 15, '4': 1, '5': 11, '6': '.message.NotificationContent', '9': 0, '10': 'notification'},
    {'1': 'system', '3': 16, '4': 1, '5': 11, '6': '.message.SystemContent', '9': 0, '10': 'system'},
    {'1': 'reminder', '3': 17, '4': 1, '5': 11, '6': '.message.ReminderContent', '9': 0, '10': 'reminder'},
    {'1': 'group_event', '3': 18, '4': 1, '5': 11, '6': '.message.GroupEventContent', '9': 0, '10': 'groupEvent'},
    {'1': 'contact_card', '3': 19, '4': 1, '5': 11, '6': '.message.ContactCardContent', '9': 0, '10': 'contactCard'},
    {'1': 'vote', '3': 20, '4': 1, '5': 11, '6': '.message.VoteContent', '9': 0, '10': 'vote'},
    {'1': 'red_envelope', '3': 21, '4': 1, '5': 11, '6': '.message.RedEnvelopeContent', '9': 0, '10': 'redEnvelope'},
    {'1': 'encrypted', '3': 22, '4': 1, '5': 11, '6': '.message.EncryptedContent', '9': 0, '10': 'encrypted'},
    {'1': 'ack', '3': 23, '4': 1, '5': 11, '6': '.message.AckContent', '9': 0, '10': 'ack'},
  ],
  '8': [
    {'1': 'content'},
  ],
};

/// Descriptor for `MessageContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageContentDescriptor = $convert.base64Decode(
    'Cg5NZXNzYWdlQ29udGVudBIqCgR0ZXh0GAEgASgLMhQubWVzc2FnZS5UZXh0Q29udGVudEgAUg'
    'R0ZXh0Ei0KBWltYWdlGAIgASgLMhUubWVzc2FnZS5JbWFnZUNvbnRlbnRIAFIFaW1hZ2USLQoF'
    'YXVkaW8YAyABKAsyFS5tZXNzYWdlLkF1ZGlvQ29udGVudEgAUgVhdWRpbxItCgV2aWRlbxgEIA'
    'EoCzIVLm1lc3NhZ2UuVmlkZW9Db250ZW50SABSBXZpZGVvEjYKCGxvY2F0aW9uGAUgASgLMhgu'
    'bWVzc2FnZS5Mb2NhdGlvbkNvbnRlbnRIAFIIbG9jYXRpb24SKgoEZmlsZRgGIAEoCzIULm1lc3'
    'NhZ2UuRmlsZUNvbnRlbnRIAFIEZmlsZRIxCgdhdl9jYWxsGAcgASgLMhYubWVzc2FnZS5BVkNh'
    'bGxDb250ZW50SABSBmF2Q2FsbBIwCgZjdXN0b20YCCABKAsyFi5tZXNzYWdlLkN1c3RvbUNvbn'
    'RlbnRIAFIGY3VzdG9tEi0KBWVtb2ppGAkgASgLMhUubWVzc2FnZS5FbW9qaUNvbnRlbnRIAFIF'
    'ZW1vamkSMAoGcmV2b2tlGAogASgLMhYubWVzc2FnZS5SZXZva2VDb250ZW50SABSBnJldm9rZR'
    'IzCgdmb3J3YXJkGAsgASgLMhcubWVzc2FnZS5Gb3J3YXJkQ29udGVudEgAUgdmb3J3YXJkEi0K'
    'BXF1b3RlGAwgASgLMhUubWVzc2FnZS5RdW90ZUNvbnRlbnRIAFIFcXVvdGUSKgoEaHRtbBgNIA'
    'EoCzIULm1lc3NhZ2UuSHRtbENvbnRlbnRIAFIEaHRtbBIqCgR2b2lwGA4gASgLMhQubWVzc2Fn'
    'ZS5Wb2lwQ29udGVudEgAUgR2b2lwEkIKDG5vdGlmaWNhdGlvbhgPIAEoCzIcLm1lc3NhZ2UuTm'
    '90aWZpY2F0aW9uQ29udGVudEgAUgxub3RpZmljYXRpb24SMAoGc3lzdGVtGBAgASgLMhYubWVz'
    'c2FnZS5TeXN0ZW1Db250ZW50SABSBnN5c3RlbRI2CghyZW1pbmRlchgRIAEoCzIYLm1lc3NhZ2'
    'UuUmVtaW5kZXJDb250ZW50SABSCHJlbWluZGVyEj0KC2dyb3VwX2V2ZW50GBIgASgLMhoubWVz'
    'c2FnZS5Hcm91cEV2ZW50Q29udGVudEgAUgpncm91cEV2ZW50EkAKDGNvbnRhY3RfY2FyZBgTIA'
    'EoCzIbLm1lc3NhZ2UuQ29udGFjdENhcmRDb250ZW50SABSC2NvbnRhY3RDYXJkEioKBHZvdGUY'
    'FCABKAsyFC5tZXNzYWdlLlZvdGVDb250ZW50SABSBHZvdGUSQAoMcmVkX2VudmVsb3BlGBUgAS'
    'gLMhsubWVzc2FnZS5SZWRFbnZlbG9wZUNvbnRlbnRIAFILcmVkRW52ZWxvcGUSOQoJZW5jcnlw'
    'dGVkGBYgASgLMhkubWVzc2FnZS5FbmNyeXB0ZWRDb250ZW50SABSCWVuY3J5cHRlZBInCgNhY2'
    'sYFyABKAsyEy5tZXNzYWdlLkFja0NvbnRlbnRIAFIDYWNrQgkKB2NvbnRlbnQ=');

@$core.Deprecated('Use ackContentDescriptor instead')
const AckContent$json = {
  '1': 'AckContent',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'code', '3': 2, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'request_kind', '3': 4, '4': 1, '5': 5, '10': 'requestKind'},
    {'1': 'ref_message_id', '3': 5, '4': 1, '5': 4, '9': 0, '10': 'refMessageId', '17': true},
    {'1': 'extra', '3': 6, '4': 1, '5': 12, '10': 'extra'},
  ],
  '8': [
    {'1': '_ref_message_id'},
  ],
};

/// Descriptor for `AckContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ackContentDescriptor = $convert.base64Decode(
    'CgpBY2tDb250ZW50Eg4KAm9rGAEgASgIUgJvaxISCgRjb2RlGAIgASgFUgRjb2RlEhgKB21lc3'
    'NhZ2UYAyABKAlSB21lc3NhZ2USIQoMcmVxdWVzdF9raW5kGAQgASgFUgtyZXF1ZXN0S2luZBIp'
    'Cg5yZWZfbWVzc2FnZV9pZBgFIAEoBEgAUgxyZWZNZXNzYWdlSWSIAQESFAoFZXh0cmEYBiABKA'
    'xSBWV4dHJhQhEKD19yZWZfbWVzc2FnZV9pZA==');

@$core.Deprecated('Use textContentDescriptor instead')
const TextContent$json = {
  '1': 'TextContent',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'entities', '3': 2, '4': 3, '5': 11, '6': '.message.InlineEntity', '10': 'entities'},
  ],
};

/// Descriptor for `TextContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textContentDescriptor = $convert.base64Decode(
    'CgtUZXh0Q29udGVudBISCgR0ZXh0GAEgASgJUgR0ZXh0EjEKCGVudGl0aWVzGAIgAygLMhUubW'
    'Vzc2FnZS5JbmxpbmVFbnRpdHlSCGVudGl0aWVz');

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
    {'1': 'initiator_uid', '3': 2, '4': 1, '5': 3, '10': 'initiatorUid'},
    {'1': 'participant_ids', '3': 3, '4': 3, '5': 3, '10': 'participantIds'},
    {'1': 'action', '3': 4, '4': 1, '5': 14, '6': '.message.AVCallContent.CallAction', '10': 'action'},
    {'1': 'type', '3': 5, '4': 1, '5': 14, '6': '.message.AVCallContent.CallType', '10': 'type'},
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
    'Cg1BVkNhbGxDb250ZW50EhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBIjCg1pbml0aWF0b3JfdW'
    'lkGAIgASgDUgxpbml0aWF0b3JVaWQSJwoPcGFydGljaXBhbnRfaWRzGAMgAygDUg5wYXJ0aWNp'
    'cGFudElkcxI5CgZhY3Rpb24YBCABKA4yIS5tZXNzYWdlLkFWQ2FsbENvbnRlbnQuQ2FsbEFjdG'
    'lvblIGYWN0aW9uEjMKBHR5cGUYBSABKA4yHy5tZXNzYWdlLkFWQ2FsbENvbnRlbnQuQ2FsbFR5'
    'cGVSBHR5cGUSHAoJdGltZXN0YW1wGAYgASgDUgl0aW1lc3RhbXASGgoIZHVyYXRpb24YByABKA'
    'VSCGR1cmF0aW9uIl8KCkNhbGxBY3Rpb24SCwoHVU5LTk9XThAAEgoKBklOVklURRABEgoKBkFD'
    'Q0VQVBACEgoKBlJFSkVDVBADEgoKBkNBTkNFTBAEEgcKA0VORBAFEgsKB1RJTUVPVVQQBiIgCg'
    'hDYWxsVHlwZRIJCgVBVURJTxAAEgkKBVZJREVPEAE=');

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
    {'1': 'emoji', '3': 1, '4': 1, '5': 14, '6': '.message.EmojiType', '10': 'emoji'},
    {'1': 'custom_emoji_url', '3': 2, '4': 1, '5': 9, '10': 'customEmojiUrl'},
  ],
};

/// Descriptor for `EmojiContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emojiContentDescriptor = $convert.base64Decode(
    'CgxFbW9qaUNvbnRlbnQSKAoFZW1vamkYASABKA4yEi5tZXNzYWdlLkVtb2ppVHlwZVIFZW1vam'
    'kSKAoQY3VzdG9tX2Vtb2ppX3VybBgCIAEoCVIOY3VzdG9tRW1vamlVcmw=');

@$core.Deprecated('Use revokeContentDescriptor instead')
const RevokeContent$json = {
  '1': 'RevokeContent',
  '2': [
    {'1': 'target_message_id', '3': 1, '4': 1, '5': 3, '10': 'targetMessageId'},
    {'1': 'operator_id', '3': 2, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'revoke_time', '3': 3, '4': 1, '5': 3, '10': 'revokeTime'},
  ],
};

/// Descriptor for `RevokeContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeContentDescriptor = $convert.base64Decode(
    'Cg1SZXZva2VDb250ZW50EioKEXRhcmdldF9tZXNzYWdlX2lkGAEgASgDUg90YXJnZXRNZXNzYW'
    'dlSWQSHwoLb3BlcmF0b3JfaWQYAiABKANSCm9wZXJhdG9ySWQSHwoLcmV2b2tlX3RpbWUYAyAB'
    'KANSCnJldm9rZVRpbWU=');

@$core.Deprecated('Use forwardContentDescriptor instead')
const ForwardContent$json = {
  '1': 'ForwardContent',
  '2': [
    {'1': 'original_message_id', '3': 1, '4': 1, '5': 4, '10': 'originalMessageId'},
    {'1': 'original_sender_id', '3': 2, '4': 1, '5': 9, '10': 'originalSenderId'},
    {'1': 'original_kind', '3': 3, '4': 1, '5': 14, '6': '.socket.MsgKind', '10': 'originalKind'},
    {'1': 'summary', '3': 4, '4': 1, '5': 9, '10': 'summary'},
  ],
};

/// Descriptor for `ForwardContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forwardContentDescriptor = $convert.base64Decode(
    'Cg5Gb3J3YXJkQ29udGVudBIuChNvcmlnaW5hbF9tZXNzYWdlX2lkGAEgASgEUhFvcmlnaW5hbE'
    '1lc3NhZ2VJZBIsChJvcmlnaW5hbF9zZW5kZXJfaWQYAiABKAlSEG9yaWdpbmFsU2VuZGVySWQS'
    'NAoNb3JpZ2luYWxfa2luZBgDIAEoDjIPLnNvY2tldC5Nc2dLaW5kUgxvcmlnaW5hbEtpbmQSGA'
    'oHc3VtbWFyeRgEIAEoCVIHc3VtbWFyeQ==');

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
    {'1': 'metadata', '3': 3, '4': 3, '5': 11, '6': '.message.NotificationContent.MetadataEntry', '10': 'metadata'},
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
    'gJUgRib2R5EkYKCG1ldGFkYXRhGAMgAygLMioubWVzc2FnZS5Ob3RpZmljYXRpb25Db250ZW50'
    'Lk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhGjsKDU1ldGFkYXRhRW50cnkSEAoDa2V5GAEgASgJUg'
    'NrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

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
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'event', '3': 2, '4': 1, '5': 9, '10': 'event'},
    {'1': 'operator_id', '3': 3, '4': 1, '5': 3, '10': 'operatorId'},
  ],
};

/// Descriptor for `GroupEventContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupEventContentDescriptor = $convert.base64Decode(
    'ChFHcm91cEV2ZW50Q29udGVudBIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZBIUCgVldmVudB'
    'gCIAEoCVIFZXZlbnQSHwoLb3BlcmF0b3JfaWQYAyABKANSCm9wZXJhdG9ySWQ=');

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
    {'1': 'result', '3': 3, '4': 3, '5': 11, '6': '.message.VoteContent.ResultEntry', '10': 'result'},
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
    'B0aW9ucxI4CgZyZXN1bHQYAyADKAsyIC5tZXNzYWdlLlZvdGVDb250ZW50LlJlc3VsdEVudHJ5'
    'UgZyZXN1bHQSIQoMbXVsdGlfY2hvaWNlGAQgASgIUgttdWx0aUNob2ljZRo5CgtSZXN1bHRFbn'
    'RyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgB');

@$core.Deprecated('Use redEnvelopeContentDescriptor instead')
const RedEnvelopeContent$json = {
  '1': 'RedEnvelopeContent',
  '2': [
    {'1': 'sender_id', '3': 1, '4': 1, '5': 3, '10': 'senderId'},
    {'1': 'amount', '3': 2, '4': 1, '5': 5, '10': 'amount'},
    {'1': 'blessing', '3': 3, '4': 1, '5': 9, '10': 'blessing'},
    {'1': 'claimed', '3': 4, '4': 1, '5': 8, '10': 'claimed'},
  ],
};

/// Descriptor for `RedEnvelopeContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List redEnvelopeContentDescriptor = $convert.base64Decode(
    'ChJSZWRFbnZlbG9wZUNvbnRlbnQSGwoJc2VuZGVyX2lkGAEgASgDUghzZW5kZXJJZBIWCgZhbW'
    '91bnQYAiABKAVSBmFtb3VudBIaCghibGVzc2luZxgDIAEoCVIIYmxlc3NpbmcSGAoHY2xhaW1l'
    'ZBgEIAEoCFIHY2xhaW1lZA==');

@$core.Deprecated('Use segmentDescriptor instead')
const Segment$json = {
  '1': 'Segment',
  '2': [
    {'1': 'body', '3': 1, '4': 1, '5': 11, '6': '.message.MessageContent', '10': 'body'},
    {'1': 'seq_in_msg', '3': 2, '4': 1, '5': 4, '10': 'seqInMsg'},
    {'1': 'metadata', '3': 3, '4': 3, '5': 11, '6': '.message.Segment.MetadataEntry', '10': 'metadata'},
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
    'CgdTZWdtZW50EisKBGJvZHkYASABKAsyFy5tZXNzYWdlLk1lc3NhZ2VDb250ZW50UgRib2R5Eh'
    'wKCnNlcV9pbl9tc2cYAiABKARSCHNlcUluTXNnEjoKCG1ldGFkYXRhGAMgAygLMh4ubWVzc2Fn'
    'ZS5TZWdtZW50Lk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhGjsKDU1ldGFkYXRhRW50cnkSEAoDa2'
    'V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use contentDescriptor instead')
const Content$json = {
  '1': 'Content',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 4, '9': 0, '10': 'messageId', '17': true},
    {'1': 'sender_id', '3': 2, '4': 1, '5': 3, '10': 'senderId'},
    {'1': 'receiver_id', '3': 3, '4': 1, '5': 3, '10': 'receiverId'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'msg_kind', '3': 5, '4': 1, '5': 14, '6': '.socket.MsgKind', '10': 'msgKind'},
    {'1': 'scene', '3': 6, '4': 1, '5': 14, '6': '.message.ChatScene', '10': 'scene'},
    {'1': 'contents', '3': 10, '4': 3, '5': 11, '6': '.message.MessageContent', '10': 'contents'},
  ],
  '8': [
    {'1': '_message_id'},
  ],
};

/// Descriptor for `Content`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contentDescriptor = $convert.base64Decode(
    'CgdDb250ZW50EiIKCm1lc3NhZ2VfaWQYASABKARIAFIJbWVzc2FnZUlkiAEBEhsKCXNlbmRlcl'
    '9pZBgCIAEoA1IIc2VuZGVySWQSHwoLcmVjZWl2ZXJfaWQYAyABKANSCnJlY2VpdmVySWQSHAoJ'
    'dGltZXN0YW1wGAQgASgDUgl0aW1lc3RhbXASKgoIbXNnX2tpbmQYBSABKA4yDy5zb2NrZXQuTX'
    'NnS2luZFIHbXNnS2luZBIoCgVzY2VuZRgGIAEoDjISLm1lc3NhZ2UuQ2hhdFNjZW5lUgVzY2Vu'
    'ZRIzCghjb250ZW50cxgKIAMoCzIXLm1lc3NhZ2UuTWVzc2FnZUNvbnRlbnRSCGNvbnRlbnRzQg'
    '0KC19tZXNzYWdlX2lk');

@$core.Deprecated('Use callInviteDescriptor instead')
const CallInvite$json = {
  '1': 'CallInvite',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'from_user_id', '3': 2, '4': 1, '5': 3, '10': 'fromUserId'},
    {'1': 'to_user_id', '3': 3, '4': 1, '5': 3, '10': 'toUserId'},
    {'1': 'media_type', '3': 4, '4': 1, '5': 14, '6': '.message.CallMediaType', '10': 'mediaType'},
    {'1': 'sdp_offer', '3': 5, '4': 1, '5': 9, '10': 'sdpOffer'},
    {'1': 'ext', '3': 6, '4': 1, '5': 9, '9': 0, '10': 'ext', '17': true},
    {'1': 'created_at', '3': 7, '4': 1, '5': 4, '10': 'createdAt'},
  ],
  '8': [
    {'1': '_ext'},
  ],
};

/// Descriptor for `CallInvite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callInviteDescriptor = $convert.base64Decode(
    'CgpDYWxsSW52aXRlEhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBIgCgxmcm9tX3VzZXJfaWQYAi'
    'ABKANSCmZyb21Vc2VySWQSHAoKdG9fdXNlcl9pZBgDIAEoA1IIdG9Vc2VySWQSNQoKbWVkaWFf'
    'dHlwZRgEIAEoDjIWLm1lc3NhZ2UuQ2FsbE1lZGlhVHlwZVIJbWVkaWFUeXBlEhsKCXNkcF9vZm'
    'ZlchgFIAEoCVIIc2RwT2ZmZXISFQoDZXh0GAYgASgJSABSA2V4dIgBARIdCgpjcmVhdGVkX2F0'
    'GAcgASgEUgljcmVhdGVkQXRCBgoEX2V4dA==');

@$core.Deprecated('Use callCancelDescriptor instead')
const CallCancel$json = {
  '1': 'CallCancel',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'operator_user_id', '3': 2, '4': 1, '5': 3, '10': 'operatorUserId'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'reason', '17': true},
    {'1': 'at', '3': 4, '4': 1, '5': 4, '10': 'at'},
  ],
  '8': [
    {'1': '_reason'},
  ],
};

/// Descriptor for `CallCancel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callCancelDescriptor = $convert.base64Decode(
    'CgpDYWxsQ2FuY2VsEhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBIoChBvcGVyYXRvcl91c2VyX2'
    'lkGAIgASgDUg5vcGVyYXRvclVzZXJJZBIbCgZyZWFzb24YAyABKAlIAFIGcmVhc29uiAEBEg4K'
    'AmF0GAQgASgEUgJhdEIJCgdfcmVhc29u');

@$core.Deprecated('Use callRejectDescriptor instead')
const CallReject$json = {
  '1': 'CallReject',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'reject_user_id', '3': 2, '4': 1, '5': 3, '10': 'rejectUserId'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'reason', '17': true},
    {'1': 'at', '3': 4, '4': 1, '5': 4, '10': 'at'},
  ],
  '8': [
    {'1': '_reason'},
  ],
};

/// Descriptor for `CallReject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callRejectDescriptor = $convert.base64Decode(
    'CgpDYWxsUmVqZWN0EhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBIkCg5yZWplY3RfdXNlcl9pZB'
    'gCIAEoA1IMcmVqZWN0VXNlcklkEhsKBnJlYXNvbhgDIAEoCUgAUgZyZWFzb26IAQESDgoCYXQY'
    'BCABKARSAmF0QgkKB19yZWFzb24=');

@$core.Deprecated('Use callAcceptDescriptor instead')
const CallAccept$json = {
  '1': 'CallAccept',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'accept_user_id', '3': 2, '4': 1, '5': 3, '10': 'acceptUserId'},
    {'1': 'sdp_answer', '3': 3, '4': 1, '5': 9, '10': 'sdpAnswer'},
    {'1': 'at', '3': 4, '4': 1, '5': 4, '10': 'at'},
  ],
};

/// Descriptor for `CallAccept`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callAcceptDescriptor = $convert.base64Decode(
    'CgpDYWxsQWNjZXB0EhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBIkCg5hY2NlcHRfdXNlcl9pZB'
    'gCIAEoA1IMYWNjZXB0VXNlcklkEh0KCnNkcF9hbnN3ZXIYAyABKAlSCXNkcEFuc3dlchIOCgJh'
    'dBgEIAEoBFICYXQ=');

@$core.Deprecated('Use callHangupDescriptor instead')
const CallHangup$json = {
  '1': 'CallHangup',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'operator_user_id', '3': 2, '4': 1, '5': 3, '10': 'operatorUserId'},
    {'1': 'reason', '3': 3, '4': 1, '5': 14, '6': '.message.CallEndReason', '10': 'reason'},
    {'1': 'duration_ms', '3': 4, '4': 1, '5': 4, '9': 0, '10': 'durationMs', '17': true},
    {'1': 'at', '3': 5, '4': 1, '5': 4, '10': 'at'},
  ],
  '8': [
    {'1': '_duration_ms'},
  ],
};

/// Descriptor for `CallHangup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callHangupDescriptor = $convert.base64Decode(
    'CgpDYWxsSGFuZ3VwEhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBIoChBvcGVyYXRvcl91c2VyX2'
    'lkGAIgASgDUg5vcGVyYXRvclVzZXJJZBIuCgZyZWFzb24YAyABKA4yFi5tZXNzYWdlLkNhbGxF'
    'bmRSZWFzb25SBnJlYXNvbhIkCgtkdXJhdGlvbl9tcxgEIAEoBEgAUgpkdXJhdGlvbk1ziAEBEg'
    '4KAmF0GAUgASgEUgJhdEIOCgxfZHVyYXRpb25fbXM=');

@$core.Deprecated('Use callModifyDescriptor instead')
const CallModify$json = {
  '1': 'CallModify',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'operator_user_id', '3': 2, '4': 1, '5': 3, '10': 'operatorUserId'},
    {'1': 'modify', '3': 3, '4': 1, '5': 14, '6': '.message.CallModifyType', '10': 'modify'},
    {'1': 'on', '3': 4, '4': 1, '5': 8, '10': 'on'},
    {'1': 'at', '3': 5, '4': 1, '5': 4, '10': 'at'},
  ],
};

/// Descriptor for `CallModify`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callModifyDescriptor = $convert.base64Decode(
    'CgpDYWxsTW9kaWZ5EhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBIoChBvcGVyYXRvcl91c2VyX2'
    'lkGAIgASgDUg5vcGVyYXRvclVzZXJJZBIvCgZtb2RpZnkYAyABKA4yFy5tZXNzYWdlLkNhbGxN'
    'b2RpZnlUeXBlUgZtb2RpZnkSDgoCb24YBCABKAhSAm9uEg4KAmF0GAUgASgEUgJhdA==');

@$core.Deprecated('Use callDtmfDescriptor instead')
const CallDtmf$json = {
  '1': 'CallDtmf',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'from_user_id', '3': 2, '4': 1, '5': 3, '10': 'fromUserId'},
    {'1': 'digits', '3': 3, '4': 1, '5': 9, '10': 'digits'},
    {'1': 'at', '3': 4, '4': 1, '5': 4, '10': 'at'},
  ],
};

/// Descriptor for `CallDtmf`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callDtmfDescriptor = $convert.base64Decode(
    'CghDYWxsRHRtZhIXCgdjYWxsX2lkGAEgASgJUgZjYWxsSWQSIAoMZnJvbV91c2VyX2lkGAIgAS'
    'gDUgpmcm9tVXNlcklkEhYKBmRpZ2l0cxgDIAEoCVIGZGlnaXRzEg4KAmF0GAQgASgEUgJhdA==');

@$core.Deprecated('Use msgDeliveredAckDescriptor instead')
const MsgDeliveredAck$json = {
  '1': 'MsgDeliveredAck',
  '2': [
    {'1': 'msg_id', '3': 1, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'ack_user_id', '3': 2, '4': 1, '5': 3, '10': 'ackUserId'},
    {'1': 'ack_at', '3': 3, '4': 1, '5': 3, '10': 'ackAt'},
  ],
};

/// Descriptor for `MsgDeliveredAck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgDeliveredAckDescriptor = $convert.base64Decode(
    'Cg9Nc2dEZWxpdmVyZWRBY2sSFQoGbXNnX2lkGAEgASgDUgVtc2dJZBIeCgthY2tfdXNlcl9pZB'
    'gCIAEoA1IJYWNrVXNlcklkEhUKBmFja19hdBgDIAEoA1IFYWNrQXQ=');

@$core.Deprecated('Use msgReadDescriptor instead')
const MsgRead$json = {
  '1': 'MsgRead',
  '2': [
    {'1': 'msg_id', '3': 1, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'chat_id', '3': 3, '4': 1, '5': 3, '10': 'chatId'},
    {'1': 'read_at', '3': 4, '4': 1, '5': 3, '10': 'readAt'},
  ],
};

/// Descriptor for `MsgRead`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgReadDescriptor = $convert.base64Decode(
    'CgdNc2dSZWFkEhUKBm1zZ19pZBgBIAEoA1IFbXNnSWQSFwoHdXNlcl9pZBgCIAEoA1IGdXNlck'
    'lkEhcKB2NoYXRfaWQYAyABKANSBmNoYXRJZBIXCgdyZWFkX2F0GAQgASgDUgZyZWFkQXQ=');

@$core.Deprecated('Use msgReadAckDescriptor instead')
const MsgReadAck$json = {
  '1': 'MsgReadAck',
  '2': [
    {'1': 'msg_id', '3': 1, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'ack_user_id', '3': 2, '4': 1, '5': 3, '10': 'ackUserId'},
    {'1': 'ack_at', '3': 3, '4': 1, '5': 3, '10': 'ackAt'},
  ],
};

/// Descriptor for `MsgReadAck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgReadAckDescriptor = $convert.base64Decode(
    'CgpNc2dSZWFkQWNrEhUKBm1zZ19pZBgBIAEoA1IFbXNnSWQSHgoLYWNrX3VzZXJfaWQYAiABKA'
    'NSCWFja1VzZXJJZBIVCgZhY2tfYXQYAyABKANSBWFja0F0');

@$core.Deprecated('Use msgRecallDescriptor instead')
const MsgRecall$json = {
  '1': 'MsgRecall',
  '2': [
    {'1': 'msg_id', '3': 1, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'operator_user_id', '3': 2, '4': 1, '5': 3, '10': 'operatorUserId'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'reason', '17': true},
    {'1': 'recalled_at', '3': 4, '4': 1, '5': 3, '10': 'recalledAt'},
  ],
  '8': [
    {'1': '_reason'},
  ],
};

/// Descriptor for `MsgRecall`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgRecallDescriptor = $convert.base64Decode(
    'CglNc2dSZWNhbGwSFQoGbXNnX2lkGAEgASgDUgVtc2dJZBIoChBvcGVyYXRvcl91c2VyX2lkGA'
    'IgASgDUg5vcGVyYXRvclVzZXJJZBIbCgZyZWFzb24YAyABKAlIAFIGcmVhc29uiAEBEh8KC3Jl'
    'Y2FsbGVkX2F0GAQgASgDUgpyZWNhbGxlZEF0QgkKB19yZWFzb24=');

@$core.Deprecated('Use msgForwardDescriptor instead')
const MsgForward$json = {
  '1': 'MsgForward',
  '2': [
    {'1': 'src_msg_id', '3': 1, '4': 1, '5': 3, '10': 'srcMsgId'},
    {'1': 'new_msg_id', '3': 2, '4': 1, '5': 3, '9': 0, '10': 'newMsgId', '17': true},
    {'1': 'from_user_id', '3': 3, '4': 1, '5': 3, '10': 'fromUserId'},
    {'1': 'to_user_id', '3': 4, '4': 1, '5': 3, '10': 'toUserId'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 3, '10': 'createdAt'},
  ],
  '8': [
    {'1': '_new_msg_id'},
  ],
};

/// Descriptor for `MsgForward`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgForwardDescriptor = $convert.base64Decode(
    'CgpNc2dGb3J3YXJkEhwKCnNyY19tc2dfaWQYASABKANSCHNyY01zZ0lkEiEKCm5ld19tc2dfaW'
    'QYAiABKANIAFIIbmV3TXNnSWSIAQESIAoMZnJvbV91c2VyX2lkGAMgASgDUgpmcm9tVXNlcklk'
    'EhwKCnRvX3VzZXJfaWQYBCABKANSCHRvVXNlcklkEh0KCmNyZWF0ZWRfYXQYBSABKANSCWNyZW'
    'F0ZWRBdEINCgtfbmV3X21zZ19pZA==');

@$core.Deprecated('Use msgReactionDescriptor instead')
const MsgReaction$json = {
  '1': 'MsgReaction',
  '2': [
    {'1': 'msg_id', '3': 1, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'action', '3': 3, '4': 1, '5': 14, '6': '.message.ReactionAction', '10': 'action'},
    {'1': 'emoji', '3': 4, '4': 1, '5': 9, '10': 'emoji'},
    {'1': 'at', '3': 5, '4': 1, '5': 3, '10': 'at'},
  ],
};

/// Descriptor for `MsgReaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgReactionDescriptor = $convert.base64Decode(
    'CgtNc2dSZWFjdGlvbhIVCgZtc2dfaWQYASABKANSBW1zZ0lkEhcKB3VzZXJfaWQYAiABKANSBn'
    'VzZXJJZBIvCgZhY3Rpb24YAyABKA4yFy5tZXNzYWdlLlJlYWN0aW9uQWN0aW9uUgZhY3Rpb24S'
    'FAoFZW1vamkYBCABKAlSBWVtb2ppEg4KAmF0GAUgASgDUgJhdA==');

@$core.Deprecated('Use typingDescriptor instead')
const Typing$json = {
  '1': 'Typing',
  '2': [
    {'1': 'from_user_id', '3': 1, '4': 1, '5': 3, '10': 'fromUserId'},
    {'1': 'state', '3': 3, '4': 1, '5': 14, '6': '.message.TypingState', '10': 'state'},
    {'1': 'at', '3': 4, '4': 1, '5': 3, '10': 'at'},
    {'1': 'to_user_id', '3': 2, '4': 1, '5': 3, '9': 0, '10': 'toUserId'},
    {'1': 'group_id', '3': 5, '4': 1, '5': 3, '9': 0, '10': 'groupId'},
    {'1': 'notify_user_ids', '3': 6, '4': 3, '5': 3, '10': 'notifyUserIds'},
  ],
  '8': [
    {'1': 'target'},
  ],
};

/// Descriptor for `Typing`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingDescriptor = $convert.base64Decode(
    'CgZUeXBpbmcSIAoMZnJvbV91c2VyX2lkGAEgASgDUgpmcm9tVXNlcklkEioKBXN0YXRlGAMgAS'
    'gOMhQubWVzc2FnZS5UeXBpbmdTdGF0ZVIFc3RhdGUSDgoCYXQYBCABKANSAmF0Eh4KCnRvX3Vz'
    'ZXJfaWQYAiABKANIAFIIdG9Vc2VySWQSGwoIZ3JvdXBfaWQYBSABKANIAFIHZ3JvdXBJZBImCg'
    '9ub3RpZnlfdXNlcl9pZHMYBiADKANSDW5vdGlmeVVzZXJJZHNCCAoGdGFyZ2V0');

@$core.Deprecated('Use queryFriendMessagesRequestDescriptor instead')
const QueryFriendMessagesRequest$json = {
  '1': 'QueryFriendMessagesRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'friend_id', '3': 2, '4': 1, '5': 3, '10': 'friendId'},
    {'1': 'before_message_id', '3': 3, '4': 1, '5': 4, '9': 0, '10': 'beforeMessageId', '17': true},
    {'1': 'before_timestamp', '3': 4, '4': 1, '5': 3, '9': 1, '10': 'beforeTimestamp', '17': true},
    {'1': 'limit', '3': 5, '4': 1, '5': 13, '10': 'limit'},
  ],
  '8': [
    {'1': '_before_message_id'},
    {'1': '_before_timestamp'},
  ],
};

/// Descriptor for `QueryFriendMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryFriendMessagesRequestDescriptor = $convert.base64Decode(
    'ChpRdWVyeUZyaWVuZE1lc3NhZ2VzUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySWQSGw'
    'oJZnJpZW5kX2lkGAIgASgDUghmcmllbmRJZBIvChFiZWZvcmVfbWVzc2FnZV9pZBgDIAEoBEgA'
    'Ug9iZWZvcmVNZXNzYWdlSWSIAQESLgoQYmVmb3JlX3RpbWVzdGFtcBgEIAEoA0gBUg9iZWZvcm'
    'VUaW1lc3RhbXCIAQESFAoFbGltaXQYBSABKA1SBWxpbWl0QhQKEl9iZWZvcmVfbWVzc2FnZV9p'
    'ZEITChFfYmVmb3JlX3RpbWVzdGFtcA==');

@$core.Deprecated('Use queryGroupMessagesRequestDescriptor instead')
const QueryGroupMessagesRequest$json = {
  '1': 'QueryGroupMessagesRequest',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'before_message_id', '3': 2, '4': 1, '5': 4, '9': 0, '10': 'beforeMessageId', '17': true},
    {'1': 'before_timestamp', '3': 3, '4': 1, '5': 3, '9': 1, '10': 'beforeTimestamp', '17': true},
    {'1': 'limit', '3': 4, '4': 1, '5': 13, '10': 'limit'},
  ],
  '8': [
    {'1': '_before_message_id'},
    {'1': '_before_timestamp'},
  ],
};

/// Descriptor for `QueryGroupMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryGroupMessagesRequestDescriptor = $convert.base64Decode(
    'ChlRdWVyeUdyb3VwTWVzc2FnZXNSZXF1ZXN0EhkKCGdyb3VwX2lkGAEgASgDUgdncm91cElkEi'
    '8KEWJlZm9yZV9tZXNzYWdlX2lkGAIgASgESABSD2JlZm9yZU1lc3NhZ2VJZIgBARIuChBiZWZv'
    'cmVfdGltZXN0YW1wGAMgASgDSAFSD2JlZm9yZVRpbWVzdGFtcIgBARIUCgVsaW1pdBgEIAEoDV'
    'IFbGltaXRCFAoSX2JlZm9yZV9tZXNzYWdlX2lkQhMKEV9iZWZvcmVfdGltZXN0YW1w');

@$core.Deprecated('Use queryMessagesResponseDescriptor instead')
const QueryMessagesResponse$json = {
  '1': 'QueryMessagesResponse',
  '2': [
    {'1': 'messages', '3': 1, '4': 3, '5': 11, '6': '.message.Content', '10': 'messages'},
    {'1': 'has_more', '3': 2, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `QueryMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryMessagesResponseDescriptor = $convert.base64Decode(
    'ChVRdWVyeU1lc3NhZ2VzUmVzcG9uc2USLAoIbWVzc2FnZXMYASADKAsyEC5tZXNzYWdlLkNvbn'
    'RlbnRSCG1lc3NhZ2VzEhkKCGhhc19tb3JlGAIgASgIUgdoYXNNb3Jl');

@$core.Deprecated('Use encryptedContentDescriptor instead')
const EncryptedContent$json = {
  '1': 'EncryptedContent',
  '2': [
    {'1': 'scheme', '3': 1, '4': 1, '5': 9, '10': 'scheme'},
    {'1': 'sender_pub', '3': 2, '4': 1, '5': 12, '10': 'senderPub'},
    {'1': 'key_id', '3': 3, '4': 1, '5': 9, '10': 'keyId'},
    {'1': 'nonce', '3': 4, '4': 1, '5': 12, '10': 'nonce'},
    {'1': 'ciphertext', '3': 5, '4': 1, '5': 12, '10': 'ciphertext'},
    {'1': 'aad', '3': 6, '4': 1, '5': 12, '10': 'aad'},
    {'1': 'msg_no', '3': 7, '4': 1, '5': 4, '10': 'msgNo'},
  ],
};

/// Descriptor for `EncryptedContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptedContentDescriptor = $convert.base64Decode(
    'ChBFbmNyeXB0ZWRDb250ZW50EhYKBnNjaGVtZRgBIAEoCVIGc2NoZW1lEh0KCnNlbmRlcl9wdW'
    'IYAiABKAxSCXNlbmRlclB1YhIVCgZrZXlfaWQYAyABKAlSBWtleUlkEhQKBW5vbmNlGAQgASgM'
    'UgVub25jZRIeCgpjaXBoZXJ0ZXh0GAUgASgMUgpjaXBoZXJ0ZXh0EhAKA2FhZBgGIAEoDFIDYW'
    'FkEhUKBm1zZ19ubxgHIAEoBFIFbXNnTm8=');

