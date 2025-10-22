// This is a generated file - do not edit.
//
// Generated from msg_group.proto.

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
    {'1': 'GROUP_ROLE_UNSPECIFIED', '2': 0},
    {'1': 'OWNER', '2': 1},
    {'1': 'ADMIN', '2': 2},
    {'1': 'MEMBER', '2': 3},
  ],
};

/// Descriptor for `GroupRoleType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List groupRoleTypeDescriptor = $convert.base64Decode(
    'Cg1Hcm91cFJvbGVUeXBlEhoKFkdST1VQX1JPTEVfVU5TUEVDSUZJRUQQABIJCgVPV05FUhABEg'
    'kKBUFETUlOEAISCgoGTUVNQkVSEAM=');

@$core.Deprecated('Use joinPermissionDescriptor instead')
const JoinPermission$json = {
  '1': 'JoinPermission',
  '2': [
    {'1': 'JOIN_PERMISSION_UNSPECIFIED', '2': 0},
    {'1': 'ANYONE', '2': 1},
    {'1': 'NEED_APPROVAL', '2': 2},
    {'1': 'INVITE_ONLY', '2': 3},
    {'1': 'CLOSED', '2': 4},
  ],
};

/// Descriptor for `JoinPermission`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List joinPermissionDescriptor = $convert.base64Decode(
    'Cg5Kb2luUGVybWlzc2lvbhIfChtKT0lOX1BFUk1JU1NJT05fVU5TUEVDSUZJRUQQABIKCgZBTl'
    'lPTkUQARIRCg1ORUVEX0FQUFJPVkFMEAISDwoLSU5WSVRFX09OTFkQAxIKCgZDTE9TRUQQBA==');

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

@$core.Deprecated('Use memberRefDescriptor instead')
const MemberRef$json = {
  '1': 'MemberRef',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'alias', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'alias', '17': true},
    {'1': 'role', '3': 3, '4': 1, '5': 14, '6': '.msg_group_service.GroupRoleType', '10': 'role'},
  ],
  '8': [
    {'1': '_alias'},
  ],
};

/// Descriptor for `MemberRef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberRefDescriptor = $convert.base64Decode(
    'CglNZW1iZXJSZWYSDgoCaWQYASABKANSAmlkEhkKBWFsaWFzGAIgASgJSABSBWFsaWFziAEBEj'
    'QKBHJvbGUYAyABKA4yIC5tc2dfZ3JvdXBfc2VydmljZS5Hcm91cFJvbGVUeXBlUgRyb2xlQggK'
    'Bl9hbGlhcw==');

@$core.Deprecated('Use groupInfoDescriptor instead')
const GroupInfo$json = {
  '1': 'GroupInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'notice', '3': 5, '4': 1, '5': 9, '10': 'notice'},
    {'1': 'join_permission', '3': 6, '4': 1, '5': 14, '6': '.msg_group_service.JoinPermission', '10': 'joinPermission'},
    {'1': 'owner_id', '3': 7, '4': 1, '5': 3, '10': 'ownerId'},
    {'1': 'group_type', '3': 8, '4': 1, '5': 14, '6': '.msg_group_service.GroupType', '10': 'groupType'},
    {'1': 'allow_search', '3': 9, '4': 1, '5': 8, '10': 'allowSearch'},
    {'1': 'enable', '3': 10, '4': 1, '5': 8, '10': 'enable'},
    {'1': 'create_time', '3': 11, '4': 1, '5': 4, '10': 'createTime'},
    {'1': 'update_time', '3': 12, '4': 1, '5': 4, '10': 'updateTime'},
    {'1': 'member_cnt', '3': 13, '4': 1, '5': 13, '10': 'memberCnt'},
  ],
};

/// Descriptor for `GroupInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupInfoDescriptor = $convert.base64Decode(
    'CglHcm91cEluZm8SDgoCaWQYASABKANSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSFgoGYXZhdG'
    'FyGAMgASgJUgZhdmF0YXISIAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEhYKBm5v'
    'dGljZRgFIAEoCVIGbm90aWNlEkoKD2pvaW5fcGVybWlzc2lvbhgGIAEoDjIhLm1zZ19ncm91cF'
    '9zZXJ2aWNlLkpvaW5QZXJtaXNzaW9uUg5qb2luUGVybWlzc2lvbhIZCghvd25lcl9pZBgHIAEo'
    'A1IHb3duZXJJZBI7Cgpncm91cF90eXBlGAggASgOMhwubXNnX2dyb3VwX3NlcnZpY2UuR3JvdX'
    'BUeXBlUglncm91cFR5cGUSIQoMYWxsb3dfc2VhcmNoGAkgASgIUgthbGxvd1NlYXJjaBIWCgZl'
    'bmFibGUYCiABKAhSBmVuYWJsZRIfCgtjcmVhdGVfdGltZRgLIAEoBFIKY3JlYXRlVGltZRIfCg'
    't1cGRhdGVfdGltZRgMIAEoBFIKdXBkYXRlVGltZRIdCgptZW1iZXJfY250GA0gASgNUgltZW1i'
    'ZXJDbnQ=');

@$core.Deprecated('Use createGroupReqDescriptor instead')
const CreateGroupReq$json = {
  '1': 'CreateGroupReq',
  '2': [
    {'1': 'creator_id', '3': 1, '4': 1, '5': 3, '10': 'creatorId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'members', '3': 3, '4': 3, '5': 3, '10': 'members'},
    {'1': 'avatar', '3': 4, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'intro', '3': 5, '4': 1, '5': 9, '10': 'intro'},
  ],
};

/// Descriptor for `CreateGroupReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupReqDescriptor = $convert.base64Decode(
    'Cg5DcmVhdGVHcm91cFJlcRIdCgpjcmVhdG9yX2lkGAEgASgDUgljcmVhdG9ySWQSEgoEbmFtZR'
    'gCIAEoCVIEbmFtZRIYCgdtZW1iZXJzGAMgAygDUgdtZW1iZXJzEhYKBmF2YXRhchgEIAEoCVIG'
    'YXZhdGFyEhQKBWludHJvGAUgASgJUgVpbnRybw==');

@$core.Deprecated('Use createGroupRespDescriptor instead')
const CreateGroupResp$json = {
  '1': 'CreateGroupResp',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
  ],
};

/// Descriptor for `CreateGroupResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupRespDescriptor = $convert.base64Decode(
    'Cg9DcmVhdGVHcm91cFJlc3ASGQoIZ3JvdXBfaWQYASABKANSB2dyb3VwSWQ=');

@$core.Deprecated('Use updateGroupProfileReqDescriptor instead')
const UpdateGroupProfileReq$json = {
  '1': 'UpdateGroupProfileReq',
  '2': [
    {'1': 'operator_id', '3': 1, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 4, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'intro', '3': 5, '4': 1, '5': 9, '10': 'intro'},
  ],
};

/// Descriptor for `UpdateGroupProfileReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupProfileReqDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVHcm91cFByb2ZpbGVSZXESHwoLb3BlcmF0b3JfaWQYASABKANSCm9wZXJhdG9ySW'
    'QSGQoIZ3JvdXBfaWQYAiABKANSB2dyb3VwSWQSEgoEbmFtZRgDIAEoCVIEbmFtZRIWCgZhdmF0'
    'YXIYBCABKAlSBmF2YXRhchIUCgVpbnRybxgFIAEoCVIFaW50cm8=');

@$core.Deprecated('Use dismissGroupReqDescriptor instead')
const DismissGroupReq$json = {
  '1': 'DismissGroupReq',
  '2': [
    {'1': 'operator_id', '3': 1, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 3, '10': 'groupId'},
  ],
};

/// Descriptor for `DismissGroupReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dismissGroupReqDescriptor = $convert.base64Decode(
    'Cg9EaXNtaXNzR3JvdXBSZXESHwoLb3BlcmF0b3JfaWQYASABKANSCm9wZXJhdG9ySWQSGQoIZ3'
    'JvdXBfaWQYAiABKANSB2dyb3VwSWQ=');

@$core.Deprecated('Use joinGroupReqDescriptor instead')
const JoinGroupReq$json = {
  '1': 'JoinGroupReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'extra', '3': 3, '4': 1, '5': 9, '10': 'extra'},
    {'1': 'join_source', '3': 4, '4': 1, '5': 9, '10': 'joinSource'},
    {'1': 'inviter_id', '3': 5, '4': 1, '5': 3, '10': 'inviterId'},
    {'1': 'inviter_extra', '3': 6, '4': 1, '5': 9, '10': 'inviterExtra'},
    {'1': 'inviter_join_source', '3': 7, '4': 1, '5': 9, '10': 'inviterJoinSource'},
    {'1': 'join_time_ms', '3': 8, '4': 1, '5': 3, '10': 'joinTimeMs'},
  ],
};

/// Descriptor for `JoinGroupReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinGroupReqDescriptor = $convert.base64Decode(
    'CgxKb2luR3JvdXBSZXESGQoIZ3JvdXBfaWQYASABKANSB2dyb3VwSWQSFwoHdXNlcl9pZBgCIA'
    'EoA1IGdXNlcklkEhQKBWV4dHJhGAMgASgJUgVleHRyYRIfCgtqb2luX3NvdXJjZRgEIAEoCVIK'
    'am9pblNvdXJjZRIdCgppbnZpdGVyX2lkGAUgASgDUglpbnZpdGVySWQSIwoNaW52aXRlcl9leH'
    'RyYRgGIAEoCVIMaW52aXRlckV4dHJhEi4KE2ludml0ZXJfam9pbl9zb3VyY2UYByABKAlSEWlu'
    'dml0ZXJKb2luU291cmNlEiAKDGpvaW5fdGltZV9tcxgIIAEoA1IKam9pblRpbWVNcw==');

@$core.Deprecated('Use leaveGroupReqDescriptor instead')
const LeaveGroupReq$json = {
  '1': 'LeaveGroupReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `LeaveGroupReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveGroupReqDescriptor = $convert.base64Decode(
    'Cg1MZWF2ZUdyb3VwUmVxEhkKCGdyb3VwX2lkGAEgASgDUgdncm91cElkEhcKB3VzZXJfaWQYAi'
    'ABKANSBnVzZXJJZBIWCgZyZWFzb24YAyABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use approveJoinReqDescriptor instead')
const ApproveJoinReq$json = {
  '1': 'ApproveJoinReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'operator_id', '3': 2, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'applicant_id', '3': 3, '4': 1, '5': 3, '10': 'applicantId'},
    {'1': 'accept', '3': 4, '4': 1, '5': 8, '10': 'accept'},
    {'1': 'remark', '3': 5, '4': 1, '5': 9, '10': 'remark'},
  ],
};

/// Descriptor for `ApproveJoinReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approveJoinReqDescriptor = $convert.base64Decode(
    'Cg5BcHByb3ZlSm9pblJlcRIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZBIfCgtvcGVyYXRvcl'
    '9pZBgCIAEoA1IKb3BlcmF0b3JJZBIhCgxhcHBsaWNhbnRfaWQYAyABKANSC2FwcGxpY2FudElk'
    'EhYKBmFjY2VwdBgEIAEoCFIGYWNjZXB0EhYKBnJlbWFyaxgFIAEoCVIGcmVtYXJr');

@$core.Deprecated('Use inviteMembersReqDescriptor instead')
const InviteMembersReq$json = {
  '1': 'InviteMembersReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'operator_id', '3': 2, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'invitee_ids', '3': 3, '4': 3, '5': 3, '10': 'inviteeIds'},
    {'1': 'extra', '3': 4, '4': 1, '5': 9, '10': 'extra'},
  ],
};

/// Descriptor for `InviteMembersReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteMembersReqDescriptor = $convert.base64Decode(
    'ChBJbnZpdGVNZW1iZXJzUmVxEhkKCGdyb3VwX2lkGAEgASgDUgdncm91cElkEh8KC29wZXJhdG'
    '9yX2lkGAIgASgDUgpvcGVyYXRvcklkEh8KC2ludml0ZWVfaWRzGAMgAygDUgppbnZpdGVlSWRz'
    'EhQKBWV4dHJhGAQgASgJUgVleHRyYQ==');

@$core.Deprecated('Use kickMemberReqDescriptor instead')
const KickMemberReq$json = {
  '1': 'KickMemberReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'operator_id', '3': 2, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'target_id', '3': 3, '4': 1, '5': 3, '10': 'targetId'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `KickMemberReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List kickMemberReqDescriptor = $convert.base64Decode(
    'Cg1LaWNrTWVtYmVyUmVxEhkKCGdyb3VwX2lkGAEgASgDUgdncm91cElkEh8KC29wZXJhdG9yX2'
    'lkGAIgASgDUgpvcGVyYXRvcklkEhsKCXRhcmdldF9pZBgDIAEoA1IIdGFyZ2V0SWQSFgoGcmVh'
    'c29uGAQgASgJUgZyZWFzb24=');

@$core.Deprecated('Use updateMemberAliasReqDescriptor instead')
const UpdateMemberAliasReq$json = {
  '1': 'UpdateMemberAliasReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'operator_id', '3': 2, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'target_id', '3': 3, '4': 1, '5': 3, '10': 'targetId'},
    {'1': 'alias', '3': 4, '4': 1, '5': 9, '10': 'alias'},
  ],
};

/// Descriptor for `UpdateMemberAliasReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateMemberAliasReqDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVNZW1iZXJBbGlhc1JlcRIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZBIfCgtvcG'
    'VyYXRvcl9pZBgCIAEoA1IKb3BlcmF0b3JJZBIbCgl0YXJnZXRfaWQYAyABKANSCHRhcmdldElk'
    'EhQKBWFsaWFzGAQgASgJUgVhbGlhcw==');

@$core.Deprecated('Use changeMemberRoleReqDescriptor instead')
const ChangeMemberRoleReq$json = {
  '1': 'ChangeMemberRoleReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'operator_id', '3': 2, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'target_id', '3': 3, '4': 1, '5': 3, '10': 'targetId'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.msg_group_service.GroupRoleType', '10': 'role'},
  ],
};

/// Descriptor for `ChangeMemberRoleReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeMemberRoleReqDescriptor = $convert.base64Decode(
    'ChNDaGFuZ2VNZW1iZXJSb2xlUmVxEhkKCGdyb3VwX2lkGAEgASgDUgdncm91cElkEh8KC29wZX'
    'JhdG9yX2lkGAIgASgDUgpvcGVyYXRvcklkEhsKCXRhcmdldF9pZBgDIAEoA1IIdGFyZ2V0SWQS'
    'NAoEcm9sZRgEIAEoDjIgLm1zZ19ncm91cF9zZXJ2aWNlLkdyb3VwUm9sZVR5cGVSBHJvbGU=');

@$core.Deprecated('Use getGroupReqDescriptor instead')
const GetGroupReq$json = {
  '1': 'GetGroupReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
  ],
};

/// Descriptor for `GetGroupReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupReqDescriptor = $convert.base64Decode(
    'CgtHZXRHcm91cFJlcRIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZA==');

@$core.Deprecated('Use getMembersReqDescriptor instead')
const GetMembersReq$json = {
  '1': 'GetMembersReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'page', '3': 2, '4': 1, '5': 13, '10': 'page'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 13, '10': 'pageSize'},
  ],
};

/// Descriptor for `GetMembersReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMembersReqDescriptor = $convert.base64Decode(
    'Cg1HZXRNZW1iZXJzUmVxEhkKCGdyb3VwX2lkGAEgASgDUgdncm91cElkEhIKBHBhZ2UYAiABKA'
    '1SBHBhZ2USGwoJcGFnZV9zaXplGAMgASgNUghwYWdlU2l6ZQ==');

@$core.Deprecated('Use getMembersRespDescriptor instead')
const GetMembersResp$json = {
  '1': 'GetMembersResp',
  '2': [
    {'1': 'members', '3': 1, '4': 3, '5': 11, '6': '.msg_group_service.MemberRef', '10': 'members'},
    {'1': 'total', '3': 2, '4': 1, '5': 4, '10': 'total'},
  ],
};

/// Descriptor for `GetMembersResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMembersRespDescriptor = $convert.base64Decode(
    'Cg5HZXRNZW1iZXJzUmVzcBI2CgdtZW1iZXJzGAEgAygLMhwubXNnX2dyb3VwX3NlcnZpY2UuTW'
    'VtYmVyUmVmUgdtZW1iZXJzEhQKBXRvdGFsGAIgASgEUgV0b3RhbA==');

@$core.Deprecated('Use countMembersReqDescriptor instead')
const CountMembersReq$json = {
  '1': 'CountMembersReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
  ],
};

/// Descriptor for `CountMembersReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List countMembersReqDescriptor = $convert.base64Decode(
    'Cg9Db3VudE1lbWJlcnNSZXESGQoIZ3JvdXBfaWQYASABKANSB2dyb3VwSWQ=');

@$core.Deprecated('Use countMembersRespDescriptor instead')
const CountMembersResp$json = {
  '1': 'CountMembersResp',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 4, '10': 'count'},
  ],
};

/// Descriptor for `CountMembersResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List countMembersRespDescriptor = $convert.base64Decode(
    'ChBDb3VudE1lbWJlcnNSZXNwEhQKBWNvdW50GAEgASgEUgVjb3VudA==');

@$core.Deprecated('Use userGroupsReqDescriptor instead')
const UserGroupsReq$json = {
  '1': 'UserGroupsReq',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
  ],
};

/// Descriptor for `UserGroupsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userGroupsReqDescriptor = $convert.base64Decode(
    'Cg1Vc2VyR3JvdXBzUmVxEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZA==');

@$core.Deprecated('Use userGroupsRespDescriptor instead')
const UserGroupsResp$json = {
  '1': 'UserGroupsResp',
  '2': [
    {'1': 'group_ids', '3': 1, '4': 3, '5': 3, '10': 'groupIds'},
  ],
};

/// Descriptor for `UserGroupsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userGroupsRespDescriptor = $convert.base64Decode(
    'Cg5Vc2VyR3JvdXBzUmVzcBIbCglncm91cF9pZHMYASADKANSCGdyb3VwSWRz');

@$core.Deprecated('Use joinRequestNoticeDescriptor instead')
const JoinRequestNotice$json = {
  '1': 'JoinRequestNotice',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'group_name', '3': 2, '4': 1, '5': 9, '10': 'groupName'},
    {'1': 'applicant_id', '3': 3, '4': 1, '5': 3, '10': 'applicantId'},
    {'1': 'extra', '3': 4, '4': 1, '5': 9, '10': 'extra'},
    {'1': 'join_source', '3': 5, '4': 1, '5': 9, '10': 'joinSource'},
    {'1': 'inviter_id', '3': 6, '4': 1, '5': 3, '10': 'inviterId'},
    {'1': 'inviter_extra', '3': 7, '4': 1, '5': 9, '10': 'inviterExtra'},
    {'1': 'request_time', '3': 8, '4': 1, '5': 3, '10': 'requestTime'},
  ],
};

/// Descriptor for `JoinRequestNotice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestNoticeDescriptor = $convert.base64Decode(
    'ChFKb2luUmVxdWVzdE5vdGljZRIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZBIdCgpncm91cF'
    '9uYW1lGAIgASgJUglncm91cE5hbWUSIQoMYXBwbGljYW50X2lkGAMgASgDUgthcHBsaWNhbnRJ'
    'ZBIUCgVleHRyYRgEIAEoCVIFZXh0cmESHwoLam9pbl9zb3VyY2UYBSABKAlSCmpvaW5Tb3VyY2'
    'USHQoKaW52aXRlcl9pZBgGIAEoA1IJaW52aXRlcklkEiMKDWludml0ZXJfZXh0cmEYByABKAlS'
    'DGludml0ZXJFeHRyYRIhCgxyZXF1ZXN0X3RpbWUYCCABKANSC3JlcXVlc3RUaW1l');

@$core.Deprecated('Use joinRequestHandledNoticeDescriptor instead')
const JoinRequestHandledNotice$json = {
  '1': 'JoinRequestHandledNotice',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'applicant_id', '3': 2, '4': 1, '5': 3, '10': 'applicantId'},
    {'1': 'operator_id', '3': 3, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'accepted', '3': 4, '4': 1, '5': 8, '10': 'accepted'},
    {'1': 'remark', '3': 5, '4': 1, '5': 9, '10': 'remark'},
    {'1': 'handled_at', '3': 6, '4': 1, '5': 3, '10': 'handledAt'},
  ],
};

/// Descriptor for `JoinRequestHandledNotice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestHandledNoticeDescriptor = $convert.base64Decode(
    'ChhKb2luUmVxdWVzdEhhbmRsZWROb3RpY2USGQoIZ3JvdXBfaWQYASABKANSB2dyb3VwSWQSIQ'
    'oMYXBwbGljYW50X2lkGAIgASgDUgthcHBsaWNhbnRJZBIfCgtvcGVyYXRvcl9pZBgDIAEoA1IK'
    'b3BlcmF0b3JJZBIaCghhY2NlcHRlZBgEIAEoCFIIYWNjZXB0ZWQSFgoGcmVtYXJrGAUgASgJUg'
    'ZyZW1hcmsSHQoKaGFuZGxlZF9hdBgGIAEoA1IJaGFuZGxlZEF0');

@$core.Deprecated('Use groupMemberChangeNoticeDescriptor instead')
const GroupMemberChangeNotice$json = {
  '1': 'GroupMemberChangeNotice',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'operator_id', '3': 2, '4': 1, '5': 3, '10': 'operatorId'},
    {'1': 'member', '3': 3, '4': 1, '5': 11, '6': '.msg_group_service.MemberRef', '10': 'member'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'event_time', '3': 5, '4': 1, '5': 3, '10': 'eventTime'},
  ],
};

/// Descriptor for `GroupMemberChangeNotice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupMemberChangeNoticeDescriptor = $convert.base64Decode(
    'ChdHcm91cE1lbWJlckNoYW5nZU5vdGljZRIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZBIfCg'
    'tvcGVyYXRvcl9pZBgCIAEoA1IKb3BlcmF0b3JJZBI0CgZtZW1iZXIYAyABKAsyHC5tc2dfZ3Jv'
    'dXBfc2VydmljZS5NZW1iZXJSZWZSBm1lbWJlchIWCgZyZWFzb24YBCABKAlSBnJlYXNvbhIdCg'
    'pldmVudF90aW1lGAUgASgDUglldmVudFRpbWU=');

