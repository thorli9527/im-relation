// This is a generated file - do not edit.
//
// Generated from common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'common.pbenum.dart';

/// *
///  通用响应结构
class CommonResp extends $pb.GeneratedMessage {
  factory CommonResp({
    $core.bool? success,
    $core.String? message,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    return result;
  }

  CommonResp._();

  factory CommonResp.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CommonResp.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommonResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'common'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommonResp clone() => CommonResp()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommonResp copyWith(void Function(CommonResp) updates) => super.copyWith((message) => updates(message as CommonResp)) as CommonResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommonResp create() => CommonResp._();
  @$core.override
  CommonResp createEmptyInstance() => create();
  static $pb.PbList<CommonResp> createRepeated() => $pb.PbList<CommonResp>();
  @$core.pragma('dart2js:noInline')
  static CommonResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommonResp>(create);
  static CommonResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

/// *
///  群标签信息
class TagInfo extends $pb.GeneratedMessage {
  factory TagInfo({
    $core.String? id,
    $core.String? name,
    $core.String? description,
    $core.String? color,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (color != null) result.color = color;
    return result;
  }

  TagInfo._();

  factory TagInfo.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory TagInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TagInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'common'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'color')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TagInfo clone() => TagInfo()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TagInfo copyWith(void Function(TagInfo) updates) => super.copyWith((message) => updates(message as TagInfo)) as TagInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TagInfo create() => TagInfo._();
  @$core.override
  TagInfo createEmptyInstance() => create();
  static $pb.PbList<TagInfo> createRepeated() => $pb.PbList<TagInfo>();
  @$core.pragma('dart2js:noInline')
  static TagInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TagInfo>(create);
  static TagInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get color => $_getSZ(3);
  @$pb.TagNumber(4)
  set color($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasColor() => $_has(3);
  @$pb.TagNumber(4)
  void clearColor() => $_clearField(4);
}

/// *
///  群组基本信息（用于展示和配置）
class GroupEntity extends $pb.GeneratedMessage {
  factory GroupEntity({
    $core.String? id,
    $core.String? name,
    $core.String? avatar,
    $core.String? description,
    $core.String? notice,
    JoinPermission? joinPermission,
    $core.String? ownerId,
    GroupType? groupType,
    $core.bool? allowSearch,
    $core.bool? enable,
    $fixnum.Int64? createTime,
    $fixnum.Int64? updateTime,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (description != null) result.description = description;
    if (notice != null) result.notice = notice;
    if (joinPermission != null) result.joinPermission = joinPermission;
    if (ownerId != null) result.ownerId = ownerId;
    if (groupType != null) result.groupType = groupType;
    if (allowSearch != null) result.allowSearch = allowSearch;
    if (enable != null) result.enable = enable;
    if (createTime != null) result.createTime = createTime;
    if (updateTime != null) result.updateTime = updateTime;
    return result;
  }

  GroupEntity._();

  factory GroupEntity.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GroupEntity.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupEntity', package: const $pb.PackageName(_omitMessageNames ? '' : 'common'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'notice')
    ..e<JoinPermission>(6, _omitFieldNames ? '' : 'joinPermission', $pb.PbFieldType.OE, defaultOrMaker: JoinPermission.ANYONE, valueOf: JoinPermission.valueOf, enumValues: JoinPermission.values)
    ..aOS(7, _omitFieldNames ? '' : 'ownerId')
    ..e<GroupType>(8, _omitFieldNames ? '' : 'groupType', $pb.PbFieldType.OE, defaultOrMaker: GroupType.UNKNOWN_GROUP_TYPE, valueOf: GroupType.valueOf, enumValues: GroupType.values)
    ..aOB(9, _omitFieldNames ? '' : 'allowSearch')
    ..aOB(10, _omitFieldNames ? '' : 'enable')
    ..a<$fixnum.Int64>(11, _omitFieldNames ? '' : 'createTime', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(12, _omitFieldNames ? '' : 'updateTime', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupEntity clone() => GroupEntity()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupEntity copyWith(void Function(GroupEntity) updates) => super.copyWith((message) => updates(message as GroupEntity)) as GroupEntity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupEntity create() => GroupEntity._();
  @$core.override
  GroupEntity createEmptyInstance() => create();
  static $pb.PbList<GroupEntity> createRepeated() => $pb.PbList<GroupEntity>();
  @$core.pragma('dart2js:noInline')
  static GroupEntity getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupEntity>(create);
  static GroupEntity? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get notice => $_getSZ(4);
  @$pb.TagNumber(5)
  set notice($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNotice() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotice() => $_clearField(5);

  @$pb.TagNumber(6)
  JoinPermission get joinPermission => $_getN(5);
  @$pb.TagNumber(6)
  set joinPermission(JoinPermission value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasJoinPermission() => $_has(5);
  @$pb.TagNumber(6)
  void clearJoinPermission() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get ownerId => $_getSZ(6);
  @$pb.TagNumber(7)
  set ownerId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOwnerId() => $_has(6);
  @$pb.TagNumber(7)
  void clearOwnerId() => $_clearField(7);

  @$pb.TagNumber(8)
  GroupType get groupType => $_getN(7);
  @$pb.TagNumber(8)
  set groupType(GroupType value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasGroupType() => $_has(7);
  @$pb.TagNumber(8)
  void clearGroupType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get allowSearch => $_getBF(8);
  @$pb.TagNumber(9)
  set allowSearch($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAllowSearch() => $_has(8);
  @$pb.TagNumber(9)
  void clearAllowSearch() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get enable => $_getBF(9);
  @$pb.TagNumber(10)
  set enable($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasEnable() => $_has(9);
  @$pb.TagNumber(10)
  void clearEnable() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get createTime => $_getI64(10);
  @$pb.TagNumber(11)
  set createTime($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCreateTime() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreateTime() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get updateTime => $_getI64(11);
  @$pb.TagNumber(12)
  set updateTime($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasUpdateTime() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdateTime() => $_clearField(12);
}

/// *
///  群组成员详细信息
class GroupMemberEntity extends $pb.GeneratedMessage {
  factory GroupMemberEntity({
    $core.String? id,
    $core.String? groupId,
    $core.String? uid,
    $core.String? alias,
    GroupRoleType? role,
    $core.bool? isMuted,
    $core.String? avatar,
    $fixnum.Int64? createTime,
    $fixnum.Int64? updateTime,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (uid != null) result.uid = uid;
    if (alias != null) result.alias = alias;
    if (role != null) result.role = role;
    if (isMuted != null) result.isMuted = isMuted;
    if (avatar != null) result.avatar = avatar;
    if (createTime != null) result.createTime = createTime;
    if (updateTime != null) result.updateTime = updateTime;
    return result;
  }

  GroupMemberEntity._();

  factory GroupMemberEntity.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GroupMemberEntity.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupMemberEntity', package: const $pb.PackageName(_omitMessageNames ? '' : 'common'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'uid')
    ..aOS(4, _omitFieldNames ? '' : 'alias')
    ..e<GroupRoleType>(5, _omitFieldNames ? '' : 'role', $pb.PbFieldType.OE, defaultOrMaker: GroupRoleType.OWNER, valueOf: GroupRoleType.valueOf, enumValues: GroupRoleType.values)
    ..aOB(6, _omitFieldNames ? '' : 'isMuted')
    ..aOS(7, _omitFieldNames ? '' : 'avatar')
    ..a<$fixnum.Int64>(8, _omitFieldNames ? '' : 'createTime', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(9, _omitFieldNames ? '' : 'updateTime', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMemberEntity clone() => GroupMemberEntity()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMemberEntity copyWith(void Function(GroupMemberEntity) updates) => super.copyWith((message) => updates(message as GroupMemberEntity)) as GroupMemberEntity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupMemberEntity create() => GroupMemberEntity._();
  @$core.override
  GroupMemberEntity createEmptyInstance() => create();
  static $pb.PbList<GroupMemberEntity> createRepeated() => $pb.PbList<GroupMemberEntity>();
  @$core.pragma('dart2js:noInline')
  static GroupMemberEntity getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupMemberEntity>(create);
  static GroupMemberEntity? _defaultInstance;

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
  GroupRoleType get role => $_getN(4);
  @$pb.TagNumber(5)
  set role(GroupRoleType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRole() => $_has(4);
  @$pb.TagNumber(5)
  void clearRole() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isMuted => $_getBF(5);
  @$pb.TagNumber(6)
  set isMuted($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsMuted() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsMuted() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get avatar => $_getSZ(6);
  @$pb.TagNumber(7)
  set avatar($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAvatar() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvatar() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get createTime => $_getI64(7);
  @$pb.TagNumber(8)
  set createTime($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCreateTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreateTime() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get updateTime => $_getI64(8);
  @$pb.TagNumber(9)
  set updateTime($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUpdateTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdateTime() => $_clearField(9);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
