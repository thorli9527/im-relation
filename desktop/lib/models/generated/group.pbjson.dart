// This is a generated file - do not edit.
//
// Generated from group.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use groupNodeMsgTypeDescriptor instead')
const GroupNodeMsgType$json = {
  '1': 'GroupNodeMsgType',
  '2': [
    {'1': 'UNKNOWN_MSG_TYPE', '2': 0},
    {'1': 'CREATE_GROUP_MSG_TYPE', '2': 1},
    {'1': 'CHANGE_GROUP_MSG_TYPE', '2': 2},
    {'1': 'DESTROY_GROUP_MSG_TYPE', '2': 3},
    {'1': 'MEMBER_ONLINE_MSG_TYPE', '2': 4},
    {'1': 'MEMBER_OFFLINE_MSG_TYPE', '2': 5},
    {'1': 'REQUEST_JOIN_GROUP_MSG_TYPE', '2': 6},
    {'1': 'HANDLE_JOIN_REQUEST_MSG_TYPE', '2': 7},
    {'1': 'INVITE_MEMBERS_MSG_TYPE', '2': 8},
    {'1': 'REMOVE_MEMBERS_MSG_TYPE', '2': 9},
    {'1': 'EXIT_GROUP_MSG_TYPE', '2': 10},
    {'1': 'CHANGE_MEMBER_ROLE_MSG_TYPE', '2': 11},
    {'1': 'MUTE_MEMBER_MSG_TYPE', '2': 12},
    {'1': 'UPDATE_MEMBER_PROFILE_MSG_TYPE', '2': 13},
    {'1': 'TRANSFER_OWNERSHIP_MSG_TYPE', '2': 14},
    {'1': 'HANDLE_INVITE_MSG_TYPE', '2': 15},
  ],
};

/// Descriptor for `GroupNodeMsgType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List groupNodeMsgTypeDescriptor = $convert.base64Decode(
    'ChBHcm91cE5vZGVNc2dUeXBlEhQKEFVOS05PV05fTVNHX1RZUEUQABIZChVDUkVBVEVfR1JPVV'
    'BfTVNHX1RZUEUQARIZChVDSEFOR0VfR1JPVVBfTVNHX1RZUEUQAhIaChZERVNUUk9ZX0dST1VQ'
    'X01TR19UWVBFEAMSGgoWTUVNQkVSX09OTElORV9NU0dfVFlQRRAEEhsKF01FTUJFUl9PRkZMSU'
    '5FX01TR19UWVBFEAUSHwobUkVRVUVTVF9KT0lOX0dST1VQX01TR19UWVBFEAYSIAocSEFORExF'
    'X0pPSU5fUkVRVUVTVF9NU0dfVFlQRRAHEhsKF0lOVklURV9NRU1CRVJTX01TR19UWVBFEAgSGw'
    'oXUkVNT1ZFX01FTUJFUlNfTVNHX1RZUEUQCRIXChNFWElUX0dST1VQX01TR19UWVBFEAoSHwob'
    'Q0hBTkdFX01FTUJFUl9ST0xFX01TR19UWVBFEAsSGAoUTVVURV9NRU1CRVJfTVNHX1RZUEUQDB'
    'IiCh5VUERBVEVfTUVNQkVSX1BST0ZJTEVfTVNHX1RZUEUQDRIfChtUUkFOU0ZFUl9PV05FUlNI'
    'SVBfTVNHX1RZUEUQDhIaChZIQU5ETEVfSU5WSVRFX01TR19UWVBFEA8=');

@$core.Deprecated('Use createGroupMsgDescriptor instead')
const CreateGroupMsg$json = {
  '1': 'CreateGroupMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uids', '3': 3, '4': 3, '5': 9, '10': 'uids'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 5, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'creator_id', '3': 6, '4': 1, '5': 9, '10': 'creatorId'},
  ],
};

/// Descriptor for `CreateGroupMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupMsgDescriptor = $convert.base64Decode(
    'Cg5DcmVhdGVHcm91cE1zZxIOCgJpZBgBIAEoCVICaWQSGQoIZ3JvdXBfaWQYAiABKAlSB2dyb3'
    'VwSWQSEgoEdWlkcxgDIAMoCVIEdWlkcxISCgRuYW1lGAQgASgJUgRuYW1lEhYKBmF2YXRhchgF'
    'IAEoCVIGYXZhdGFyEh0KCmNyZWF0b3JfaWQYBiABKAlSCWNyZWF0b3JJZA==');

@$core.Deprecated('Use destroyGroupMsgDescriptor instead')
const DestroyGroupMsg$json = {
  '1': 'DestroyGroupMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'operator_id', '3': 3, '4': 1, '5': 9, '10': 'operatorId'},
  ],
};

/// Descriptor for `DestroyGroupMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List destroyGroupMsgDescriptor = $convert.base64Decode(
    'Cg9EZXN0cm95R3JvdXBNc2cSDgoCaWQYASABKAlSAmlkEhkKCGdyb3VwX2lkGAIgASgJUgdncm'
    '91cElkEh8KC29wZXJhdG9yX2lkGAMgASgJUgpvcGVyYXRvcklk');

@$core.Deprecated('Use changeGroupMsgDescriptor instead')
const ChangeGroupMsg$json = {
  '1': 'ChangeGroupMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 4, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'notice', '3': 6, '4': 1, '5': 9, '10': 'notice'},
    {'1': 'tags', '3': 7, '4': 1, '5': 9, '10': 'tags'},
    {'1': 'operator_id', '3': 8, '4': 1, '5': 9, '10': 'operatorId'},
  ],
};

/// Descriptor for `ChangeGroupMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeGroupMsgDescriptor = $convert.base64Decode(
    'Cg5DaGFuZ2VHcm91cE1zZxIOCgJpZBgBIAEoBFICaWQSGQoIZ3JvdXBfaWQYAiABKAlSB2dyb3'
    'VwSWQSEgoEbmFtZRgDIAEoCVIEbmFtZRIWCgZhdmF0YXIYBCABKAlSBmF2YXRhchIgCgtkZXNj'
    'cmlwdGlvbhgFIAEoCVILZGVzY3JpcHRpb24SFgoGbm90aWNlGAYgASgJUgZub3RpY2USEgoEdG'
    'FncxgHIAEoCVIEdGFncxIfCgtvcGVyYXRvcl9pZBgIIAEoCVIKb3BlcmF0b3JJZA==');

@$core.Deprecated('Use requestJoinGroupMsgDescriptor instead')
const RequestJoinGroupMsg$json = {
  '1': 'RequestJoinGroupMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uids', '3': 3, '4': 3, '5': 9, '10': 'uids'},
  ],
};

/// Descriptor for `RequestJoinGroupMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestJoinGroupMsgDescriptor = $convert.base64Decode(
    'ChNSZXF1ZXN0Sm9pbkdyb3VwTXNnEg4KAmlkGAEgASgEUgJpZBIZCghncm91cF9pZBgCIAEoCV'
    'IHZ3JvdXBJZBISCgR1aWRzGAMgAygJUgR1aWRz');

@$core.Deprecated('Use handleJoinRequestMsgDescriptor instead')
const HandleJoinRequestMsg$json = {
  '1': 'HandleJoinRequestMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uid', '3': 3, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'accept', '3': 4, '4': 1, '5': 8, '10': 'accept'},
    {'1': 'reason', '3': 5, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'operator_id', '3': 6, '4': 1, '5': 9, '10': 'operatorId'},
  ],
};

/// Descriptor for `HandleJoinRequestMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List handleJoinRequestMsgDescriptor = $convert.base64Decode(
    'ChRIYW5kbGVKb2luUmVxdWVzdE1zZxIOCgJpZBgBIAEoBFICaWQSGQoIZ3JvdXBfaWQYAiABKA'
    'lSB2dyb3VwSWQSEAoDdWlkGAMgASgJUgN1aWQSFgoGYWNjZXB0GAQgASgIUgZhY2NlcHQSFgoG'
    'cmVhc29uGAUgASgJUgZyZWFzb24SHwoLb3BlcmF0b3JfaWQYBiABKAlSCm9wZXJhdG9ySWQ=');

@$core.Deprecated('Use inviteMembersMsgDescriptor instead')
const InviteMembersMsg$json = {
  '1': 'InviteMembersMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uids', '3': 3, '4': 3, '5': 9, '10': 'uids'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'inviter_id', '3': 5, '4': 1, '5': 9, '10': 'inviterId'},
  ],
};

/// Descriptor for `InviteMembersMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteMembersMsgDescriptor = $convert.base64Decode(
    'ChBJbnZpdGVNZW1iZXJzTXNnEg4KAmlkGAEgASgEUgJpZBIZCghncm91cF9pZBgCIAEoCVIHZ3'
    'JvdXBJZBISCgR1aWRzGAMgAygJUgR1aWRzEhYKBnJlYXNvbhgEIAEoCVIGcmVhc29uEh0KCmlu'
    'dml0ZXJfaWQYBSABKAlSCWludml0ZXJJZA==');

@$core.Deprecated('Use handleInviteMsgDescriptor instead')
const HandleInviteMsg$json = {
  '1': 'HandleInviteMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uid', '3': 3, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'accept', '3': 4, '4': 1, '5': 8, '10': 'accept'},
    {'1': 'reason', '3': 5, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `HandleInviteMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List handleInviteMsgDescriptor = $convert.base64Decode(
    'Cg9IYW5kbGVJbnZpdGVNc2cSDgoCaWQYASABKARSAmlkEhkKCGdyb3VwX2lkGAIgASgJUgdncm'
    '91cElkEhAKA3VpZBgDIAEoCVIDdWlkEhYKBmFjY2VwdBgEIAEoCFIGYWNjZXB0EhYKBnJlYXNv'
    'bhgFIAEoCVIGcmVhc29u');

@$core.Deprecated('Use removeMembersMsgDescriptor instead')
const RemoveMembersMsg$json = {
  '1': 'RemoveMembersMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uids', '3': 3, '4': 3, '5': 9, '10': 'uids'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'operator_id', '3': 5, '4': 1, '5': 9, '10': 'operatorId'},
  ],
};

/// Descriptor for `RemoveMembersMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeMembersMsgDescriptor = $convert.base64Decode(
    'ChBSZW1vdmVNZW1iZXJzTXNnEg4KAmlkGAEgASgEUgJpZBIZCghncm91cF9pZBgCIAEoCVIHZ3'
    'JvdXBJZBISCgR1aWRzGAMgAygJUgR1aWRzEhYKBnJlYXNvbhgEIAEoCVIGcmVhc29uEh8KC29w'
    'ZXJhdG9yX2lkGAUgASgJUgpvcGVyYXRvcklk');

@$core.Deprecated('Use exitGroupMsgDescriptor instead')
const ExitGroupMsg$json = {
  '1': 'ExitGroupMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uid', '3': 3, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `ExitGroupMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exitGroupMsgDescriptor = $convert.base64Decode(
    'CgxFeGl0R3JvdXBNc2cSDgoCaWQYASABKARSAmlkEhkKCGdyb3VwX2lkGAIgASgJUgdncm91cE'
    'lkEhAKA3VpZBgDIAEoCVIDdWlkEhYKBnJlYXNvbhgEIAEoCVIGcmVhc29u');

@$core.Deprecated('Use changeMemberRoleMsgDescriptor instead')
const ChangeMemberRoleMsg$json = {
  '1': 'ChangeMemberRoleMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uid', '3': 3, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.common.GroupRoleType', '10': 'role'},
    {'1': 'operator_id', '3': 5, '4': 1, '5': 9, '10': 'operatorId'},
    {'1': 'reason', '3': 6, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `ChangeMemberRoleMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeMemberRoleMsgDescriptor = $convert.base64Decode(
    'ChNDaGFuZ2VNZW1iZXJSb2xlTXNnEg4KAmlkGAEgASgEUgJpZBIZCghncm91cF9pZBgCIAEoCV'
    'IHZ3JvdXBJZBIQCgN1aWQYAyABKAlSA3VpZBIpCgRyb2xlGAQgASgOMhUuY29tbW9uLkdyb3Vw'
    'Um9sZVR5cGVSBHJvbGUSHwoLb3BlcmF0b3JfaWQYBSABKAlSCm9wZXJhdG9ySWQSFgoGcmVhc2'
    '9uGAYgASgJUgZyZWFzb24=');

@$core.Deprecated('Use muteMemberMsgDescriptor instead')
const MuteMemberMsg$json = {
  '1': 'MuteMemberMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uids', '3': 3, '4': 3, '5': 9, '10': 'uids'},
    {'1': 'mute', '3': 4, '4': 1, '5': 8, '10': 'mute'},
    {'1': 'reason', '3': 5, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'operator_id', '3': 6, '4': 1, '5': 9, '10': 'operatorId'},
  ],
};

/// Descriptor for `MuteMemberMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List muteMemberMsgDescriptor = $convert.base64Decode(
    'Cg1NdXRlTWVtYmVyTXNnEg4KAmlkGAEgASgEUgJpZBIZCghncm91cF9pZBgCIAEoCVIHZ3JvdX'
    'BJZBISCgR1aWRzGAMgAygJUgR1aWRzEhIKBG11dGUYBCABKAhSBG11dGUSFgoGcmVhc29uGAUg'
    'ASgJUgZyZWFzb24SHwoLb3BlcmF0b3JfaWQYBiABKAlSCm9wZXJhdG9ySWQ=');

@$core.Deprecated('Use updateMemberProfileMsgDescriptor instead')
const UpdateMemberProfileMsg$json = {
  '1': 'UpdateMemberProfileMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uid', '3': 3, '4': 1, '5': 9, '10': 'uid'},
    {'1': 'alias', '3': 4, '4': 1, '5': 9, '10': 'alias'},
    {'1': 'avatar', '3': 5, '4': 1, '5': 9, '10': 'avatar'},
  ],
};

/// Descriptor for `UpdateMemberProfileMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateMemberProfileMsgDescriptor = $convert.base64Decode(
    'ChZVcGRhdGVNZW1iZXJQcm9maWxlTXNnEg4KAmlkGAEgASgEUgJpZBIZCghncm91cF9pZBgCIA'
    'EoCVIHZ3JvdXBJZBIQCgN1aWQYAyABKAlSA3VpZBIUCgVhbGlhcxgEIAEoCVIFYWxpYXMSFgoG'
    'YXZhdGFyGAUgASgJUgZhdmF0YXI=');

@$core.Deprecated('Use transferOwnershipMsgDescriptor instead')
const TransferOwnershipMsg$json = {
  '1': 'TransferOwnershipMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'new_owner_id', '3': 3, '4': 1, '5': 9, '10': 'newOwnerId'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'operator_id', '3': 5, '4': 1, '5': 9, '10': 'operatorId'},
  ],
};

/// Descriptor for `TransferOwnershipMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOwnershipMsgDescriptor = $convert.base64Decode(
    'ChRUcmFuc2Zlck93bmVyc2hpcE1zZxIOCgJpZBgBIAEoBFICaWQSGQoIZ3JvdXBfaWQYAiABKA'
    'lSB2dyb3VwSWQSIAoMbmV3X293bmVyX2lkGAMgASgJUgpuZXdPd25lcklkEhYKBnJlYXNvbhgE'
    'IAEoCVIGcmVhc29uEh8KC29wZXJhdG9yX2lkGAUgASgJUgpvcGVyYXRvcklk');

@$core.Deprecated('Use memberOnlineMsgDescriptor instead')
const MemberOnlineMsg$json = {
  '1': 'MemberOnlineMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uid', '3': 3, '4': 1, '5': 9, '10': 'uid'},
  ],
};

/// Descriptor for `MemberOnlineMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberOnlineMsgDescriptor = $convert.base64Decode(
    'Cg9NZW1iZXJPbmxpbmVNc2cSDgoCaWQYASABKARSAmlkEhkKCGdyb3VwX2lkGAIgASgJUgdncm'
    '91cElkEhAKA3VpZBgDIAEoCVIDdWlk');

@$core.Deprecated('Use memberOfflineMsgDescriptor instead')
const MemberOfflineMsg$json = {
  '1': 'MemberOfflineMsg',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'uid', '3': 3, '4': 1, '5': 9, '10': 'uid'},
  ],
};

/// Descriptor for `MemberOfflineMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberOfflineMsgDescriptor = $convert.base64Decode(
    'ChBNZW1iZXJPZmZsaW5lTXNnEg4KAmlkGAEgASgEUgJpZBIZCghncm91cF9pZBgCIAEoCVIHZ3'
    'JvdXBJZBIQCgN1aWQYAyABKAlSA3VpZA==');

