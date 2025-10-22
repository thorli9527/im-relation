// This is a generated file - do not edit.
//
// Generated from socket.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

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

@$core.Deprecated('Use msgKindDescriptor instead')
const MsgKind$json = {
  '1': 'MsgKind',
  '2': [
    {'1': 'MK_UNKNOWN', '2': 0},
    {'1': 'MK_FRIEND', '2': 100},
    {'1': 'MK_FRIEND_MSG_READ_ACK', '2': 101},
    {'1': 'MK_FRIEND_MSG_RECALL', '2': 102},
    {'1': 'MK_FRIEND_MSG_DELIVERED_ACK', '2': 103},
    {'1': 'MK_FRIEND_MSG_READ', '2': 104},
    {'1': 'MK_FRIEND_MSG_DELIVERED', '2': 105},
    {'1': 'MK_FRIEND_MSG_FORWARD', '2': 106},
    {'1': 'MK_FRIEND_MSG_EDIT', '2': 107},
    {'1': 'MK_FRIEND_MSG_REACTION', '2': 108},
    {'1': 'MK_FRIEND_TYPING', '2': 109},
    {'1': 'MK_FRIEND_CALL_INVITE', '2': 150},
    {'1': 'MK_FRIEND_CALL_CANCEL', '2': 151},
    {'1': 'MK_FRIEND_CALL_REJECT', '2': 152},
    {'1': 'MK_FRIEND_CALL_ACCEPT', '2': 153},
    {'1': 'MK_FRIEND_CALL_HANGUP', '2': 154},
    {'1': 'MK_FRIEND_CALL_MODIFY', '2': 155},
    {'1': 'MK_FRIEND_CALL_DTMF', '2': 156},
    {'1': 'MK_FRIEND_REQUEST', '2': 201},
    {'1': 'MK_FRIEND_REQUEST_ACK', '2': 202},
    {'1': 'MK_FRIEND_REQUEST_REJECT', '2': 203},
    {'1': 'MK_FRIEND_DELETE', '2': 204},
    {'1': 'MK_FRIEND_UPDATE_REMARK', '2': 205},
    {'1': 'MK_GROUP', '2': 300},
    {'1': 'MK_GROUP_MSG_READ_ACK', '2': 301},
    {'1': 'MK_GROUP_MSG_RECALL', '2': 302},
    {'1': 'MK_GROUP_AT_ALL', '2': 303},
    {'1': 'MK_GROUP_AT_USER', '2': 304},
    {'1': 'MK_GROUP_MSG_EDIT', '2': 305},
    {'1': 'MK_GROUP_MSG_REACTION', '2': 306},
    {'1': 'MK_GROUP_MSG_DELIVERED', '2': 307},
    {'1': 'MK_GROUP_MSG_DELIVERED_ACK', '2': 308},
    {'1': 'MK_GROUP_MSG_READ', '2': 309},
    {'1': 'MK_GROUP_TYPING', '2': 312},
    {'1': 'MK_GROUP_JOIN_REQUEST', '2': 401},
    {'1': 'MK_GROUP_JOIN_REQUEST_ACK', '2': 402},
    {'1': 'MK_GROUP_UPDATE_NAME', '2': 403},
    {'1': 'MK_GROUP_UPDATE_ANNOUNCEMENT', '2': 404},
    {'1': 'MK_GROUP_UPDATE_AVATAR', '2': 405},
    {'1': 'MK_GROUP_MEMBER_ADD', '2': 406},
    {'1': 'MK_GROUP_MEMBER_DELETE', '2': 407},
    {'1': 'MK_GROUP_MEMBER_QUIT', '2': 408},
    {'1': 'MK_GROUP_MEMBER_UPDATE', '2': 409},
    {'1': 'MK_GROUP_DISMISS', '2': 410},
    {'1': 'MK_GROUP_TRANSFER', '2': 411},
    {'1': 'MK_SYS_NOTICE', '2': 900},
    {'1': 'MK_USER_PRESENCE', '2': 901},
    {'1': 'MK_USER_PROFILE_UPDATE', '2': 902},
    {'1': 'MK_USER_PRIVACY_UPDATE', '2': 903},
    {'1': 'MK_USER_ACCOUNT_DATA', '2': 904},
    {'1': 'MK_MSG_RECALL', '2': 905},
    {'1': 'MK_ACK', '2': 906},
  ],
};

/// Descriptor for `MsgKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List msgKindDescriptor = $convert.base64Decode(
    'CgdNc2dLaW5kEg4KCk1LX1VOS05PV04QABINCglNS19GUklFTkQQZBIaChZNS19GUklFTkRfTV'
    'NHX1JFQURfQUNLEGUSGAoUTUtfRlJJRU5EX01TR19SRUNBTEwQZhIfChtNS19GUklFTkRfTVNH'
    'X0RFTElWRVJFRF9BQ0sQZxIWChJNS19GUklFTkRfTVNHX1JFQUQQaBIbChdNS19GUklFTkRfTV'
    'NHX0RFTElWRVJFRBBpEhkKFU1LX0ZSSUVORF9NU0dfRk9SV0FSRBBqEhYKEk1LX0ZSSUVORF9N'
    'U0dfRURJVBBrEhoKFk1LX0ZSSUVORF9NU0dfUkVBQ1RJT04QbBIUChBNS19GUklFTkRfVFlQSU'
    '5HEG0SGgoVTUtfRlJJRU5EX0NBTExfSU5WSVRFEJYBEhoKFU1LX0ZSSUVORF9DQUxMX0NBTkNF'
    'TBCXARIaChVNS19GUklFTkRfQ0FMTF9SRUpFQ1QQmAESGgoVTUtfRlJJRU5EX0NBTExfQUNDRV'
    'BUEJkBEhoKFU1LX0ZSSUVORF9DQUxMX0hBTkdVUBCaARIaChVNS19GUklFTkRfQ0FMTF9NT0RJ'
    'RlkQmwESGAoTTUtfRlJJRU5EX0NBTExfRFRNRhCcARIWChFNS19GUklFTkRfUkVRVUVTVBDJAR'
    'IaChVNS19GUklFTkRfUkVRVUVTVF9BQ0sQygESHQoYTUtfRlJJRU5EX1JFUVVFU1RfUkVKRUNU'
    'EMsBEhUKEE1LX0ZSSUVORF9ERUxFVEUQzAESHAoXTUtfRlJJRU5EX1VQREFURV9SRU1BUksQzQ'
    'ESDQoITUtfR1JPVVAQrAISGgoVTUtfR1JPVVBfTVNHX1JFQURfQUNLEK0CEhgKE01LX0dST1VQ'
    'X01TR19SRUNBTEwQrgISFAoPTUtfR1JPVVBfQVRfQUxMEK8CEhUKEE1LX0dST1VQX0FUX1VTRV'
    'IQsAISFgoRTUtfR1JPVVBfTVNHX0VESVQQsQISGgoVTUtfR1JPVVBfTVNHX1JFQUNUSU9OELIC'
    'EhsKFk1LX0dST1VQX01TR19ERUxJVkVSRUQQswISHwoaTUtfR1JPVVBfTVNHX0RFTElWRVJFRF'
    '9BQ0sQtAISFgoRTUtfR1JPVVBfTVNHX1JFQUQQtQISFAoPTUtfR1JPVVBfVFlQSU5HELgCEhoK'
    'FU1LX0dST1VQX0pPSU5fUkVRVUVTVBCRAxIeChlNS19HUk9VUF9KT0lOX1JFUVVFU1RfQUNLEJ'
    'IDEhkKFE1LX0dST1VQX1VQREFURV9OQU1FEJMDEiEKHE1LX0dST1VQX1VQREFURV9BTk5PVU5D'
    'RU1FTlQQlAMSGwoWTUtfR1JPVVBfVVBEQVRFX0FWQVRBUhCVAxIYChNNS19HUk9VUF9NRU1CRV'
    'JfQUREEJYDEhsKFk1LX0dST1VQX01FTUJFUl9ERUxFVEUQlwMSGQoUTUtfR1JPVVBfTUVNQkVS'
    'X1FVSVQQmAMSGwoWTUtfR1JPVVBfTUVNQkVSX1VQREFURRCZAxIVChBNS19HUk9VUF9ESVNNSV'
    'NTEJoDEhYKEU1LX0dST1VQX1RSQU5TRkVSEJsDEhIKDU1LX1NZU19OT1RJQ0UQhAcSFQoQTUtf'
    'VVNFUl9QUkVTRU5DRRCFBxIbChZNS19VU0VSX1BST0ZJTEVfVVBEQVRFEIYHEhsKFk1LX1VTRV'
    'JfUFJJVkFDWV9VUERBVEUQhwcSGQoUTUtfVVNFUl9BQ0NPVU5UX0RBVEEQiAcSEgoNTUtfTVNH'
    'X1JFQ0FMTBCJBxILCgZNS19BQ0sQigc=');

@$core.Deprecated('Use authMsgDescriptor instead')
const AuthMsg$json = {
  '1': 'AuthMsg',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_type', '3': 2, '4': 1, '5': 14, '6': '.socket.DeviceType', '10': 'deviceType'},
    {'1': 'device_id', '3': 3, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'token', '3': 4, '4': 1, '5': 9, '10': 'token'},
    {'1': 'ts_ms', '3': 5, '4': 1, '5': 3, '10': 'tsMs'},
    {'1': 'nonce', '3': 6, '4': 1, '5': 12, '10': 'nonce'},
    {'1': 'signature', '3': 7, '4': 1, '5': 12, '10': 'signature'},
    {'1': 'resume', '3': 8, '4': 1, '5': 8, '10': 'resume'},
    {'1': 'last_ack_id', '3': 9, '4': 1, '5': 3, '10': 'lastAckId'},
    {'1': 'supports_encryption', '3': 10, '4': 1, '5': 8, '10': 'supportsEncryption'},
    {'1': 'encryption_schemes', '3': 11, '4': 3, '5': 9, '10': 'encryptionSchemes'},
  ],
};

/// Descriptor for `AuthMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authMsgDescriptor = $convert.base64Decode(
    'CgdBdXRoTXNnEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBIzCgtkZXZpY2VfdHlwZRgCIAEoDj'
    'ISLnNvY2tldC5EZXZpY2VUeXBlUgpkZXZpY2VUeXBlEhsKCWRldmljZV9pZBgDIAEoCVIIZGV2'
    'aWNlSWQSFAoFdG9rZW4YBCABKAlSBXRva2VuEhMKBXRzX21zGAUgASgDUgR0c01zEhQKBW5vbm'
    'NlGAYgASgMUgVub25jZRIcCglzaWduYXR1cmUYByABKAxSCXNpZ25hdHVyZRIWCgZyZXN1bWUY'
    'CCABKAhSBnJlc3VtZRIeCgtsYXN0X2Fja19pZBgJIAEoA1IJbGFzdEFja0lkEi8KE3N1cHBvcn'
    'RzX2VuY3J5cHRpb24YCiABKAhSEnN1cHBvcnRzRW5jcnlwdGlvbhItChJlbmNyeXB0aW9uX3Nj'
    'aGVtZXMYCyADKAlSEWVuY3J5cHRpb25TY2hlbWVz');

@$core.Deprecated('Use clientMsgDescriptor instead')
const ClientMsg$json = {
  '1': 'ClientMsg',
  '2': [
    {'1': 'ack', '3': 1, '4': 1, '5': 3, '9': 0, '10': 'ack', '17': true},
    {'1': 'kind', '3': 2, '4': 1, '5': 14, '6': '.socket.MsgKind', '10': 'kind'},
    {'1': 'payload', '3': 3, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'client_id', '3': 5, '4': 1, '5': 3, '9': 1, '10': 'clientId', '17': true},
  ],
  '8': [
    {'1': '_ack'},
    {'1': '_client_id'},
  ],
};

/// Descriptor for `ClientMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientMsgDescriptor = $convert.base64Decode(
    'CglDbGllbnRNc2cSFQoDYWNrGAEgASgDSABSA2Fja4gBARIjCgRraW5kGAIgASgOMg8uc29ja2'
    'V0Lk1zZ0tpbmRSBGtpbmQSGAoHcGF5bG9hZBgDIAEoDFIHcGF5bG9hZBIgCgljbGllbnRfaWQY'
    'BSABKANIAVIIY2xpZW50SWSIAQFCBgoEX2Fja0IMCgpfY2xpZW50X2lk');

@$core.Deprecated('Use serverMsgDescriptor instead')
const ServerMsg$json = {
  '1': 'ServerMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'kind', '3': 2, '4': 1, '5': 14, '6': '.socket.MsgKind', '10': 'kind'},
    {'1': 'payload', '3': 3, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'ts_ms', '3': 4, '4': 1, '5': 3, '10': 'tsMs'},
  ],
};

/// Descriptor for `ServerMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverMsgDescriptor = $convert.base64Decode(
    'CglTZXJ2ZXJNc2cSDgoCaWQYASABKANSAmlkEiMKBGtpbmQYAiABKA4yDy5zb2NrZXQuTXNnS2'
    'luZFIEa2luZBIYCgdwYXlsb2FkGAMgASgMUgdwYXlsb2FkEhMKBXRzX21zGAQgASgDUgR0c01z');

@$core.Deprecated('Use kafkaMsgDescriptor instead')
const KafkaMsg$json = {
  '1': 'KafkaMsg',
  '2': [
    {'1': 'to', '3': 1, '4': 1, '5': 3, '10': 'to'},
    {'1': 'id', '3': 2, '4': 1, '5': 3, '9': 0, '10': 'id', '17': true},
    {'1': 'kind', '3': 3, '4': 1, '5': 14, '6': '.socket.MsgKind', '10': 'kind'},
    {'1': 'payload', '3': 4, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'require_ack', '3': 5, '4': 1, '5': 8, '9': 1, '10': 'requireAck', '17': true},
    {'1': 'expire_ms', '3': 6, '4': 1, '5': 4, '9': 2, '10': 'expireMs', '17': true},
    {'1': 'max_retry', '3': 7, '4': 1, '5': 13, '9': 3, '10': 'maxRetry', '17': true},
    {'1': 'ts_ms', '3': 8, '4': 1, '5': 3, '9': 4, '10': 'tsMs', '17': true},
  ],
  '8': [
    {'1': '_id'},
    {'1': '_require_ack'},
    {'1': '_expire_ms'},
    {'1': '_max_retry'},
    {'1': '_ts_ms'},
  ],
};

/// Descriptor for `KafkaMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List kafkaMsgDescriptor = $convert.base64Decode(
    'CghLYWZrYU1zZxIOCgJ0bxgBIAEoA1ICdG8SEwoCaWQYAiABKANIAFICaWSIAQESIwoEa2luZB'
    'gDIAEoDjIPLnNvY2tldC5Nc2dLaW5kUgRraW5kEhgKB3BheWxvYWQYBCABKAxSB3BheWxvYWQS'
    'JAoLcmVxdWlyZV9hY2sYBSABKAhIAVIKcmVxdWlyZUFja4gBARIgCglleHBpcmVfbXMYBiABKA'
    'RIAlIIZXhwaXJlTXOIAQESIAoJbWF4X3JldHJ5GAcgASgNSANSCG1heFJldHJ5iAEBEhgKBXRz'
    'X21zGAggASgDSARSBHRzTXOIAQFCBQoDX2lkQg4KDF9yZXF1aXJlX2Fja0IMCgpfZXhwaXJlX2'
    '1zQgwKCl9tYXhfcmV0cnlCCAoGX3RzX21z');

