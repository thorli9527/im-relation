// This is a generated file - do not edit.
//
// Generated from group.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pbenum.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'group.pbenum.dart';

/// *
///  创建群组请求
class CreateGroupMsg extends $pb.GeneratedMessage {
  factory CreateGroupMsg({
    $core.String? id,
    $core.String? groupId,
    $core.Iterable<$core.String>? uids,
    $core.String? name,
    $core.String? avatar,
    $core.String? creatorId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uids != null) result.uids.addAll(uids);
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (creatorId != null) result.creatorId = creatorId;
    return result;
  }

  CreateGroupMsg._();

  factory CreateGroupMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CreateGroupMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateGroupMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..pPS(3, _omitFieldNames ? '' : 'uids')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'avatar')
    ..aOS(6, _omitFieldNames ? '' : 'creatorId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupMsg clone() => CreateGroupMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupMsg copyWith(void Function(CreateGroupMsg) updates) => super.copyWith((message) => updates(message as CreateGroupMsg)) as CreateGroupMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupMsg create() => CreateGroupMsg._();
  @$core.override
  CreateGroupMsg createEmptyInstance() => create();
  static $pb.PbList<CreateGroupMsg> createRepeated() => $pb.PbList<CreateGroupMsg>();
  @$core.pragma('dart2js:noInline')
  static CreateGroupMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateGroupMsg>(create);
  static CreateGroupMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get uids => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get avatar => $_getSZ(4);
  @$pb.TagNumber(5)
  set avatar($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAvatar() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvatar() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get creatorId => $_getSZ(5);
  @$pb.TagNumber(6)
  set creatorId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatorId() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatorId() => $_clearField(6);
}

/// *
///  解散群组请求
class DestroyGroupMsg extends $pb.GeneratedMessage {
  factory DestroyGroupMsg({
    $core.String? id,
    $core.String? groupId,
    $core.String? operatorId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (operatorId != null) result.operatorId = operatorId;
    return result;
  }

  DestroyGroupMsg._();

  factory DestroyGroupMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DestroyGroupMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DestroyGroupMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'operatorId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DestroyGroupMsg clone() => DestroyGroupMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DestroyGroupMsg copyWith(void Function(DestroyGroupMsg) updates) => super.copyWith((message) => updates(message as DestroyGroupMsg)) as DestroyGroupMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DestroyGroupMsg create() => DestroyGroupMsg._();
  @$core.override
  DestroyGroupMsg createEmptyInstance() => create();
  static $pb.PbList<DestroyGroupMsg> createRepeated() => $pb.PbList<DestroyGroupMsg>();
  @$core.pragma('dart2js:noInline')
  static DestroyGroupMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DestroyGroupMsg>(create);
  static DestroyGroupMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get operatorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set operatorId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOperatorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOperatorId() => $_clearField(3);
}

/// *
///  修改群组信息（可用于名称、头像、公告等更新）
class ChangeGroupMsg extends $pb.GeneratedMessage {
  factory ChangeGroupMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.String? name,
    $core.String? avatar,
    $core.String? description,
    $core.String? notice,
    $core.String? tags,
    $core.String? operatorId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (description != null) result.description = description;
    if (notice != null) result.notice = notice;
    if (tags != null) result.tags = tags;
    if (operatorId != null) result.operatorId = operatorId;
    return result;
  }

  ChangeGroupMsg._();

  factory ChangeGroupMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangeGroupMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangeGroupMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'avatar')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOS(6, _omitFieldNames ? '' : 'notice')
    ..aOS(7, _omitFieldNames ? '' : 'tags')
    ..aOS(8, _omitFieldNames ? '' : 'operatorId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeGroupMsg clone() => ChangeGroupMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeGroupMsg copyWith(void Function(ChangeGroupMsg) updates) => super.copyWith((message) => updates(message as ChangeGroupMsg)) as ChangeGroupMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeGroupMsg create() => ChangeGroupMsg._();
  @$core.override
  ChangeGroupMsg createEmptyInstance() => create();
  static $pb.PbList<ChangeGroupMsg> createRepeated() => $pb.PbList<ChangeGroupMsg>();
  @$core.pragma('dart2js:noInline')
  static ChangeGroupMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangeGroupMsg>(create);
  static ChangeGroupMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatar($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatar() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get notice => $_getSZ(5);
  @$pb.TagNumber(6)
  set notice($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNotice() => $_has(5);
  @$pb.TagNumber(6)
  void clearNotice() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get tags => $_getSZ(6);
  @$pb.TagNumber(7)
  set tags($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTags() => $_has(6);
  @$pb.TagNumber(7)
  void clearTags() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get operatorId => $_getSZ(7);
  @$pb.TagNumber(8)
  set operatorId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOperatorId() => $_has(7);
  @$pb.TagNumber(8)
  void clearOperatorId() => $_clearField(8);
}

/// *
///  用户申请加入群组（通常由客户端发起）
class RequestJoinGroupMsg extends $pb.GeneratedMessage {
  factory RequestJoinGroupMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.Iterable<$core.String>? uids,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uids != null) result.uids.addAll(uids);
    return result;
  }

  RequestJoinGroupMsg._();

  factory RequestJoinGroupMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RequestJoinGroupMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RequestJoinGroupMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..pPS(3, _omitFieldNames ? '' : 'uids')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestJoinGroupMsg clone() => RequestJoinGroupMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestJoinGroupMsg copyWith(void Function(RequestJoinGroupMsg) updates) => super.copyWith((message) => updates(message as RequestJoinGroupMsg)) as RequestJoinGroupMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestJoinGroupMsg create() => RequestJoinGroupMsg._();
  @$core.override
  RequestJoinGroupMsg createEmptyInstance() => create();
  static $pb.PbList<RequestJoinGroupMsg> createRepeated() => $pb.PbList<RequestJoinGroupMsg>();
  @$core.pragma('dart2js:noInline')
  static RequestJoinGroupMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RequestJoinGroupMsg>(create);
  static RequestJoinGroupMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get uids => $_getList(2);
}

/// *
///  管理员处理入群申请
class HandleJoinRequestMsg extends $pb.GeneratedMessage {
  factory HandleJoinRequestMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.String? uid,
    $core.bool? accept,
    $core.String? reason,
    $core.String? operatorId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uid != null) result.uid = uid;
    if (accept != null) result.accept = accept;
    if (reason != null) result.reason = reason;
    if (operatorId != null) result.operatorId = operatorId;
    return result;
  }

  HandleJoinRequestMsg._();

  factory HandleJoinRequestMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory HandleJoinRequestMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HandleJoinRequestMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'uid')
    ..aOB(4, _omitFieldNames ? '' : 'accept')
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..aOS(6, _omitFieldNames ? '' : 'operatorId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HandleJoinRequestMsg clone() => HandleJoinRequestMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HandleJoinRequestMsg copyWith(void Function(HandleJoinRequestMsg) updates) => super.copyWith((message) => updates(message as HandleJoinRequestMsg)) as HandleJoinRequestMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HandleJoinRequestMsg create() => HandleJoinRequestMsg._();
  @$core.override
  HandleJoinRequestMsg createEmptyInstance() => create();
  static $pb.PbList<HandleJoinRequestMsg> createRepeated() => $pb.PbList<HandleJoinRequestMsg>();
  @$core.pragma('dart2js:noInline')
  static HandleJoinRequestMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HandleJoinRequestMsg>(create);
  static HandleJoinRequestMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get uid => $_getSZ(2);
  @$pb.TagNumber(3)
  set uid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearUid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get accept => $_getBF(3);
  @$pb.TagNumber(4)
  set accept($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAccept() => $_has(3);
  @$pb.TagNumber(4)
  void clearAccept() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get operatorId => $_getSZ(5);
  @$pb.TagNumber(6)
  set operatorId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOperatorId() => $_has(5);
  @$pb.TagNumber(6)
  void clearOperatorId() => $_clearField(6);
}

/// *
///  邀请成员加入群组（管理员或群主）
class InviteMembersMsg extends $pb.GeneratedMessage {
  factory InviteMembersMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.Iterable<$core.String>? uids,
    $core.String? reason,
    $core.String? inviterId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uids != null) result.uids.addAll(uids);
    if (reason != null) result.reason = reason;
    if (inviterId != null) result.inviterId = inviterId;
    return result;
  }

  InviteMembersMsg._();

  factory InviteMembersMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory InviteMembersMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InviteMembersMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..pPS(3, _omitFieldNames ? '' : 'uids')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..aOS(5, _omitFieldNames ? '' : 'inviterId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMembersMsg clone() => InviteMembersMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMembersMsg copyWith(void Function(InviteMembersMsg) updates) => super.copyWith((message) => updates(message as InviteMembersMsg)) as InviteMembersMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteMembersMsg create() => InviteMembersMsg._();
  @$core.override
  InviteMembersMsg createEmptyInstance() => create();
  static $pb.PbList<InviteMembersMsg> createRepeated() => $pb.PbList<InviteMembersMsg>();
  @$core.pragma('dart2js:noInline')
  static InviteMembersMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InviteMembersMsg>(create);
  static InviteMembersMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get uids => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get inviterId => $_getSZ(4);
  @$pb.TagNumber(5)
  set inviterId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasInviterId() => $_has(4);
  @$pb.TagNumber(5)
  void clearInviterId() => $_clearField(5);
}

/// *
///  被邀请成员处理邀请
class HandleInviteMsg extends $pb.GeneratedMessage {
  factory HandleInviteMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.String? uid,
    $core.bool? accept,
    $core.String? reason,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uid != null) result.uid = uid;
    if (accept != null) result.accept = accept;
    if (reason != null) result.reason = reason;
    return result;
  }

  HandleInviteMsg._();

  factory HandleInviteMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory HandleInviteMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HandleInviteMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'uid')
    ..aOB(4, _omitFieldNames ? '' : 'accept')
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HandleInviteMsg clone() => HandleInviteMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HandleInviteMsg copyWith(void Function(HandleInviteMsg) updates) => super.copyWith((message) => updates(message as HandleInviteMsg)) as HandleInviteMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HandleInviteMsg create() => HandleInviteMsg._();
  @$core.override
  HandleInviteMsg createEmptyInstance() => create();
  static $pb.PbList<HandleInviteMsg> createRepeated() => $pb.PbList<HandleInviteMsg>();
  @$core.pragma('dart2js:noInline')
  static HandleInviteMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HandleInviteMsg>(create);
  static HandleInviteMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get uid => $_getSZ(2);
  @$pb.TagNumber(3)
  set uid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearUid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get accept => $_getBF(3);
  @$pb.TagNumber(4)
  set accept($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAccept() => $_has(3);
  @$pb.TagNumber(4)
  void clearAccept() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => $_clearField(5);
}

/// *
///  移除成员（管理员操作）
class RemoveMembersMsg extends $pb.GeneratedMessage {
  factory RemoveMembersMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.Iterable<$core.String>? uids,
    $core.String? reason,
    $core.String? operatorId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uids != null) result.uids.addAll(uids);
    if (reason != null) result.reason = reason;
    if (operatorId != null) result.operatorId = operatorId;
    return result;
  }

  RemoveMembersMsg._();

  factory RemoveMembersMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RemoveMembersMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveMembersMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..pPS(3, _omitFieldNames ? '' : 'uids')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..aOS(5, _omitFieldNames ? '' : 'operatorId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveMembersMsg clone() => RemoveMembersMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveMembersMsg copyWith(void Function(RemoveMembersMsg) updates) => super.copyWith((message) => updates(message as RemoveMembersMsg)) as RemoveMembersMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveMembersMsg create() => RemoveMembersMsg._();
  @$core.override
  RemoveMembersMsg createEmptyInstance() => create();
  static $pb.PbList<RemoveMembersMsg> createRepeated() => $pb.PbList<RemoveMembersMsg>();
  @$core.pragma('dart2js:noInline')
  static RemoveMembersMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoveMembersMsg>(create);
  static RemoveMembersMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get uids => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get operatorId => $_getSZ(4);
  @$pb.TagNumber(5)
  set operatorId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOperatorId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOperatorId() => $_clearField(5);
}

/// *
///  成员主动退出群组
class ExitGroupMsg extends $pb.GeneratedMessage {
  factory ExitGroupMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.String? uid,
    $core.String? reason,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uid != null) result.uid = uid;
    if (reason != null) result.reason = reason;
    return result;
  }

  ExitGroupMsg._();

  factory ExitGroupMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ExitGroupMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExitGroupMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'uid')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExitGroupMsg clone() => ExitGroupMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExitGroupMsg copyWith(void Function(ExitGroupMsg) updates) => super.copyWith((message) => updates(message as ExitGroupMsg)) as ExitGroupMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExitGroupMsg create() => ExitGroupMsg._();
  @$core.override
  ExitGroupMsg createEmptyInstance() => create();
  static $pb.PbList<ExitGroupMsg> createRepeated() => $pb.PbList<ExitGroupMsg>();
  @$core.pragma('dart2js:noInline')
  static ExitGroupMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExitGroupMsg>(create);
  static ExitGroupMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get uid => $_getSZ(2);
  @$pb.TagNumber(3)
  set uid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearUid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);
}

/// *
///  修改成员角色（设为管理员、降权等）
class ChangeMemberRoleMsg extends $pb.GeneratedMessage {
  factory ChangeMemberRoleMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.String? uid,
    $0.GroupRoleType? role,
    $core.String? operatorId,
    $core.String? reason,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uid != null) result.uid = uid;
    if (role != null) result.role = role;
    if (operatorId != null) result.operatorId = operatorId;
    if (reason != null) result.reason = reason;
    return result;
  }

  ChangeMemberRoleMsg._();

  factory ChangeMemberRoleMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangeMemberRoleMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangeMemberRoleMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'uid')
    ..e<$0.GroupRoleType>(4, _omitFieldNames ? '' : 'role', $pb.PbFieldType.OE, defaultOrMaker: $0.GroupRoleType.OWNER, valueOf: $0.GroupRoleType.valueOf, enumValues: $0.GroupRoleType.values)
    ..aOS(5, _omitFieldNames ? '' : 'operatorId')
    ..aOS(6, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeMemberRoleMsg clone() => ChangeMemberRoleMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeMemberRoleMsg copyWith(void Function(ChangeMemberRoleMsg) updates) => super.copyWith((message) => updates(message as ChangeMemberRoleMsg)) as ChangeMemberRoleMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeMemberRoleMsg create() => ChangeMemberRoleMsg._();
  @$core.override
  ChangeMemberRoleMsg createEmptyInstance() => create();
  static $pb.PbList<ChangeMemberRoleMsg> createRepeated() => $pb.PbList<ChangeMemberRoleMsg>();
  @$core.pragma('dart2js:noInline')
  static ChangeMemberRoleMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangeMemberRoleMsg>(create);
  static ChangeMemberRoleMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get uid => $_getSZ(2);
  @$pb.TagNumber(3)
  set uid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearUid() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.GroupRoleType get role => $_getN(3);
  @$pb.TagNumber(4)
  set role($0.GroupRoleType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRole() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get operatorId => $_getSZ(4);
  @$pb.TagNumber(5)
  set operatorId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOperatorId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOperatorId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get reason => $_getSZ(5);
  @$pb.TagNumber(6)
  set reason($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearReason() => $_clearField(6);
}

/// *
///  设置或取消成员禁言
class MuteMemberMsg extends $pb.GeneratedMessage {
  factory MuteMemberMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.Iterable<$core.String>? uids,
    $core.bool? mute,
    $core.String? reason,
    $core.String? operatorId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uids != null) result.uids.addAll(uids);
    if (mute != null) result.mute = mute;
    if (reason != null) result.reason = reason;
    if (operatorId != null) result.operatorId = operatorId;
    return result;
  }

  MuteMemberMsg._();

  factory MuteMemberMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MuteMemberMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MuteMemberMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..pPS(3, _omitFieldNames ? '' : 'uids')
    ..aOB(4, _omitFieldNames ? '' : 'mute')
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..aOS(6, _omitFieldNames ? '' : 'operatorId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteMemberMsg clone() => MuteMemberMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteMemberMsg copyWith(void Function(MuteMemberMsg) updates) => super.copyWith((message) => updates(message as MuteMemberMsg)) as MuteMemberMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MuteMemberMsg create() => MuteMemberMsg._();
  @$core.override
  MuteMemberMsg createEmptyInstance() => create();
  static $pb.PbList<MuteMemberMsg> createRepeated() => $pb.PbList<MuteMemberMsg>();
  @$core.pragma('dart2js:noInline')
  static MuteMemberMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MuteMemberMsg>(create);
  static MuteMemberMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get uids => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get mute => $_getBF(3);
  @$pb.TagNumber(4)
  set mute($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMute() => $_has(3);
  @$pb.TagNumber(4)
  void clearMute() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get operatorId => $_getSZ(5);
  @$pb.TagNumber(6)
  set operatorId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOperatorId() => $_has(5);
  @$pb.TagNumber(6)
  void clearOperatorId() => $_clearField(6);
}

/// *
///  修改成员资料（如群昵称、头像等）
class UpdateMemberProfileMsg extends $pb.GeneratedMessage {
  factory UpdateMemberProfileMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.String? uid,
    $core.String? alias,
    $core.String? avatar,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uid != null) result.uid = uid;
    if (alias != null) result.alias = alias;
    if (avatar != null) result.avatar = avatar;
    return result;
  }

  UpdateMemberProfileMsg._();

  factory UpdateMemberProfileMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UpdateMemberProfileMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateMemberProfileMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'uid')
    ..aOS(4, _omitFieldNames ? '' : 'alias')
    ..aOS(5, _omitFieldNames ? '' : 'avatar')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateMemberProfileMsg clone() => UpdateMemberProfileMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateMemberProfileMsg copyWith(void Function(UpdateMemberProfileMsg) updates) => super.copyWith((message) => updates(message as UpdateMemberProfileMsg)) as UpdateMemberProfileMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateMemberProfileMsg create() => UpdateMemberProfileMsg._();
  @$core.override
  UpdateMemberProfileMsg createEmptyInstance() => create();
  static $pb.PbList<UpdateMemberProfileMsg> createRepeated() => $pb.PbList<UpdateMemberProfileMsg>();
  @$core.pragma('dart2js:noInline')
  static UpdateMemberProfileMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateMemberProfileMsg>(create);
  static UpdateMemberProfileMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get uid => $_getSZ(2);
  @$pb.TagNumber(3)
  set uid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearUid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get alias => $_getSZ(3);
  @$pb.TagNumber(4)
  set alias($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAlias() => $_has(3);
  @$pb.TagNumber(4)
  void clearAlias() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get avatar => $_getSZ(4);
  @$pb.TagNumber(5)
  set avatar($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAvatar() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvatar() => $_clearField(5);
}

/// *
///  转让群主权限
class TransferOwnershipMsg extends $pb.GeneratedMessage {
  factory TransferOwnershipMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.String? newOwnerId,
    $core.String? reason,
    $core.String? operatorId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (newOwnerId != null) result.newOwnerId = newOwnerId;
    if (reason != null) result.reason = reason;
    if (operatorId != null) result.operatorId = operatorId;
    return result;
  }

  TransferOwnershipMsg._();

  factory TransferOwnershipMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory TransferOwnershipMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferOwnershipMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'newOwnerId')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..aOS(5, _omitFieldNames ? '' : 'operatorId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOwnershipMsg clone() => TransferOwnershipMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOwnershipMsg copyWith(void Function(TransferOwnershipMsg) updates) => super.copyWith((message) => updates(message as TransferOwnershipMsg)) as TransferOwnershipMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOwnershipMsg create() => TransferOwnershipMsg._();
  @$core.override
  TransferOwnershipMsg createEmptyInstance() => create();
  static $pb.PbList<TransferOwnershipMsg> createRepeated() => $pb.PbList<TransferOwnershipMsg>();
  @$core.pragma('dart2js:noInline')
  static TransferOwnershipMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferOwnershipMsg>(create);
  static TransferOwnershipMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get newOwnerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set newOwnerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewOwnerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewOwnerId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get operatorId => $_getSZ(4);
  @$pb.TagNumber(5)
  set operatorId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOperatorId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOperatorId() => $_clearField(5);
}

/// *
///  群成员在线状态
class MemberOnlineMsg extends $pb.GeneratedMessage {
  factory MemberOnlineMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.String? uid,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uid != null) result.uid = uid;
    return result;
  }

  MemberOnlineMsg._();

  factory MemberOnlineMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MemberOnlineMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MemberOnlineMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'uid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberOnlineMsg clone() => MemberOnlineMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberOnlineMsg copyWith(void Function(MemberOnlineMsg) updates) => super.copyWith((message) => updates(message as MemberOnlineMsg)) as MemberOnlineMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MemberOnlineMsg create() => MemberOnlineMsg._();
  @$core.override
  MemberOnlineMsg createEmptyInstance() => create();
  static $pb.PbList<MemberOnlineMsg> createRepeated() => $pb.PbList<MemberOnlineMsg>();
  @$core.pragma('dart2js:noInline')
  static MemberOnlineMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MemberOnlineMsg>(create);
  static MemberOnlineMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get uid => $_getSZ(2);
  @$pb.TagNumber(3)
  set uid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearUid() => $_clearField(3);
}

/// 群成员下线消息
class MemberOfflineMsg extends $pb.GeneratedMessage {
  factory MemberOfflineMsg({
    $fixnum.Int64? id,
    $core.String? groupId,
    $core.String? uid,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uid != null) result.uid = uid;
    return result;
  }

  MemberOfflineMsg._();

  factory MemberOfflineMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MemberOfflineMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MemberOfflineMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.group'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'uid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberOfflineMsg clone() => MemberOfflineMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberOfflineMsg copyWith(void Function(MemberOfflineMsg) updates) => super.copyWith((message) => updates(message as MemberOfflineMsg)) as MemberOfflineMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MemberOfflineMsg create() => MemberOfflineMsg._();
  @$core.override
  MemberOfflineMsg createEmptyInstance() => create();
  static $pb.PbList<MemberOfflineMsg> createRepeated() => $pb.PbList<MemberOfflineMsg>();
  @$core.pragma('dart2js:noInline')
  static MemberOfflineMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MemberOfflineMsg>(create);
  static MemberOfflineMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get uid => $_getSZ(2);
  @$pb.TagNumber(3)
  set uid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearUid() => $_clearField(3);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
