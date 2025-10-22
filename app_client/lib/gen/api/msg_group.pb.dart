// This is a generated file - do not edit.
//
// Generated from msg_group.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'msg_group.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'msg_group.pbenum.dart';

/// -----------------------------------------------------------------------------
/// 成员引用（轻量成员视图）
/// - 在成员列表、事件通知、Socket 推送中广泛使用；
/// - alias 可为空；role 必填；
/// -----------------------------------------------------------------------------
class MemberRef extends $pb.GeneratedMessage {
  factory MemberRef({
    $fixnum.Int64? id,
    $core.String? alias,
    GroupRoleType? role,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (alias != null) result.alias = alias;
    if (role != null) result.role = role;
    return result;
  }

  MemberRef._();

  factory MemberRef.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MemberRef.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MemberRef', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'alias')
    ..e<GroupRoleType>(3, _omitFieldNames ? '' : 'role', $pb.PbFieldType.OE, defaultOrMaker: GroupRoleType.GROUP_ROLE_UNSPECIFIED, valueOf: GroupRoleType.valueOf, enumValues: GroupRoleType.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberRef clone() => MemberRef()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberRef copyWith(void Function(MemberRef) updates) => super.copyWith((message) => updates(message as MemberRef)) as MemberRef;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MemberRef create() => MemberRef._();
  @$core.override
  MemberRef createEmptyInstance() => create();
  static $pb.PbList<MemberRef> createRepeated() => $pb.PbList<MemberRef>();
  @$core.pragma('dart2js:noInline')
  static MemberRef getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MemberRef>(create);
  static MemberRef? _defaultInstance;

  /// 成员用户唯一 ID（必填）
  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// 群内别名；缺省或空串表示不设置别名
  @$pb.TagNumber(2)
  $core.String get alias => $_getSZ(1);
  @$pb.TagNumber(2)
  set alias($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlias() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlias() => $_clearField(2);

  /// 角色（OWNER/ADMIN/MEMBER）
  @$pb.TagNumber(3)
  GroupRoleType get role => $_getN(2);
  @$pb.TagNumber(3)
  set role(GroupRoleType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRole() => $_has(2);
  @$pb.TagNumber(3)
  void clearRole() => $_clearField(3);
}

/// -----------------------------------------------------------------------------
/// 群信息（对外查询返回）
/// - 所有时间戳单位为毫秒；member_cnt 为近实时统计，可能略有延迟；
/// - allow_search=true 表示允许通过搜索/公开入口被发现；enable=false 视为冻结/不可用；
/// -----------------------------------------------------------------------------
class GroupInfo extends $pb.GeneratedMessage {
  factory GroupInfo({
    $fixnum.Int64? id,
    $core.String? name,
    $core.String? avatar,
    $core.String? description,
    $core.String? notice,
    JoinPermission? joinPermission,
    $fixnum.Int64? ownerId,
    GroupType? groupType,
    $core.bool? allowSearch,
    $core.bool? enable,
    $fixnum.Int64? createTime,
    $fixnum.Int64? updateTime,
    $core.int? memberCnt,
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
    if (memberCnt != null) result.memberCnt = memberCnt;
    return result;
  }

  GroupInfo._();

  factory GroupInfo.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GroupInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'notice')
    ..e<JoinPermission>(6, _omitFieldNames ? '' : 'joinPermission', $pb.PbFieldType.OE, defaultOrMaker: JoinPermission.JOIN_PERMISSION_UNSPECIFIED, valueOf: JoinPermission.valueOf, enumValues: JoinPermission.values)
    ..aInt64(7, _omitFieldNames ? '' : 'ownerId')
    ..e<GroupType>(8, _omitFieldNames ? '' : 'groupType', $pb.PbFieldType.OE, defaultOrMaker: GroupType.UNKNOWN_GROUP_TYPE, valueOf: GroupType.valueOf, enumValues: GroupType.values)
    ..aOB(9, _omitFieldNames ? '' : 'allowSearch')
    ..aOB(10, _omitFieldNames ? '' : 'enable')
    ..a<$fixnum.Int64>(11, _omitFieldNames ? '' : 'createTime', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(12, _omitFieldNames ? '' : 'updateTime', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'memberCnt', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupInfo clone() => GroupInfo()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupInfo copyWith(void Function(GroupInfo) updates) => super.copyWith((message) => updates(message as GroupInfo)) as GroupInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupInfo create() => GroupInfo._();
  @$core.override
  GroupInfo createEmptyInstance() => create();
  static $pb.PbList<GroupInfo> createRepeated() => $pb.PbList<GroupInfo>();
  @$core.pragma('dart2js:noInline')
  static GroupInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupInfo>(create);
  static GroupInfo? _defaultInstance;

  /// 群 ID（全局唯一）
  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// 群名称（1~64 字；服务端需做敏感词/非法字符校验）
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// 群头像 URL（建议 https；服务端可代管上传）
  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  /// 群简介/描述（0~256 字）
  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  /// 群公告/置顶通知（0~1024 字）
  @$pb.TagNumber(5)
  $core.String get notice => $_getSZ(4);
  @$pb.TagNumber(5)
  set notice($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNotice() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotice() => $_clearField(5);

  /// 加群权限（ANYONE/NEED_APPROVAL/INVITE_ONLY/CLOSED）
  @$pb.TagNumber(6)
  JoinPermission get joinPermission => $_getN(5);
  @$pb.TagNumber(6)
  set joinPermission(JoinPermission value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasJoinPermission() => $_has(5);
  @$pb.TagNumber(6)
  void clearJoinPermission() => $_clearField(6);

  /// 群主 UID
  @$pb.TagNumber(7)
  $fixnum.Int64 get ownerId => $_getI64(6);
  @$pb.TagNumber(7)
  set ownerId($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOwnerId() => $_has(6);
  @$pb.TagNumber(7)
  void clearOwnerId() => $_clearField(7);

  /// 群类型（NORMAL/SUPER/SYSTEM）
  @$pb.TagNumber(8)
  GroupType get groupType => $_getN(7);
  @$pb.TagNumber(8)
  set groupType(GroupType value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasGroupType() => $_has(7);
  @$pb.TagNumber(8)
  void clearGroupType() => $_clearField(8);

  /// 是否允许被搜索到（公开属性）
  @$pb.TagNumber(9)
  $core.bool get allowSearch => $_getBF(8);
  @$pb.TagNumber(9)
  set allowSearch($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAllowSearch() => $_has(8);
  @$pb.TagNumber(9)
  void clearAllowSearch() => $_clearField(9);

  /// 是否启用（false 表示被封禁/冻结）
  @$pb.TagNumber(10)
  $core.bool get enable => $_getBF(9);
  @$pb.TagNumber(10)
  set enable($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasEnable() => $_has(9);
  @$pb.TagNumber(10)
  void clearEnable() => $_clearField(10);

  /// 创建时间（毫秒）
  @$pb.TagNumber(11)
  $fixnum.Int64 get createTime => $_getI64(10);
  @$pb.TagNumber(11)
  set createTime($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCreateTime() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreateTime() => $_clearField(11);

  /// 最近一次资料更新时间（毫秒）
  @$pb.TagNumber(12)
  $fixnum.Int64 get updateTime => $_getI64(11);
  @$pb.TagNumber(12)
  set updateTime($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasUpdateTime() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdateTime() => $_clearField(12);

  /// 成员数量（近实时）
  @$pb.TagNumber(13)
  $core.int get memberCnt => $_getIZ(12);
  @$pb.TagNumber(13)
  set memberCnt($core.int value) => $_setUnsignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasMemberCnt() => $_has(12);
  @$pb.TagNumber(13)
  void clearMemberCnt() => $_clearField(13);
}

/// -----------------------------------------------------------------------------
/// 创建群请求
/// - creator_id 必须为当前登录用户；members 不含自己；
/// - name/intro/avatar 存在内容安全与长度限制；
/// - 返回 group_id；建议服务端在创建成功后发送系统欢迎消息（可选）；
/// -----------------------------------------------------------------------------
class CreateGroupReq extends $pb.GeneratedMessage {
  factory CreateGroupReq({
    $fixnum.Int64? creatorId,
    $core.String? name,
    $core.Iterable<$fixnum.Int64>? members,
    $core.String? avatar,
    $core.String? intro,
  }) {
    final result = create();
    if (creatorId != null) result.creatorId = creatorId;
    if (name != null) result.name = name;
    if (members != null) result.members.addAll(members);
    if (avatar != null) result.avatar = avatar;
    if (intro != null) result.intro = intro;
    return result;
  }

  CreateGroupReq._();

  factory CreateGroupReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CreateGroupReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateGroupReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'creatorId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..p<$fixnum.Int64>(3, _omitFieldNames ? '' : 'members', $pb.PbFieldType.K6)
    ..aOS(4, _omitFieldNames ? '' : 'avatar')
    ..aOS(5, _omitFieldNames ? '' : 'intro')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupReq clone() => CreateGroupReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupReq copyWith(void Function(CreateGroupReq) updates) => super.copyWith((message) => updates(message as CreateGroupReq)) as CreateGroupReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupReq create() => CreateGroupReq._();
  @$core.override
  CreateGroupReq createEmptyInstance() => create();
  static $pb.PbList<CreateGroupReq> createRepeated() => $pb.PbList<CreateGroupReq>();
  @$core.pragma('dart2js:noInline')
  static CreateGroupReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateGroupReq>(create);
  static CreateGroupReq? _defaultInstance;

  /// 群创建者 UID（=调用者）
  @$pb.TagNumber(1)
  $fixnum.Int64 get creatorId => $_getI64(0);
  @$pb.TagNumber(1)
  set creatorId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCreatorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCreatorId() => $_clearField(1);

  /// 群名称（1~64 字）
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// 初始成员列表（不含 creator_id；长度上限由产品策略决定）
  @$pb.TagNumber(3)
  $pb.PbList<$fixnum.Int64> get members => $_getList(2);

  /// 头像 URL（可空）
  @$pb.TagNumber(4)
  $core.String get avatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatar($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatar() => $_clearField(4);

  /// 群简介（可空；0~256 字）
  @$pb.TagNumber(5)
  $core.String get intro => $_getSZ(4);
  @$pb.TagNumber(5)
  set intro($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIntro() => $_has(4);
  @$pb.TagNumber(5)
  void clearIntro() => $_clearField(5);
}

/// -----------------------------------------------------------------------------
/// 创建群返回
/// -----------------------------------------------------------------------------
class CreateGroupResp extends $pb.GeneratedMessage {
  factory CreateGroupResp({
    $fixnum.Int64? groupId,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  CreateGroupResp._();

  factory CreateGroupResp.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CreateGroupResp.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateGroupResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupResp clone() => CreateGroupResp()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupResp copyWith(void Function(CreateGroupResp) updates) => super.copyWith((message) => updates(message as CreateGroupResp)) as CreateGroupResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupResp create() => CreateGroupResp._();
  @$core.override
  CreateGroupResp createEmptyInstance() => create();
  static $pb.PbList<CreateGroupResp> createRepeated() => $pb.PbList<CreateGroupResp>();
  @$core.pragma('dart2js:noInline')
  static CreateGroupResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateGroupResp>(create);
  static CreateGroupResp? _defaultInstance;

  /// 新建群的 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);
}

/// -----------------------------------------------------------------------------
/// 更新群资料
/// - 允许更新 name/avatar/intro；operator_id 必须具备权限（OWNER/ADMIN）；
/// - 空串不代表“清空”，而是“将该字段更新为空串”；如果想“不修改”，请勿下发该字段（proto3 默认空值）；
/// -----------------------------------------------------------------------------
class UpdateGroupProfileReq extends $pb.GeneratedMessage {
  factory UpdateGroupProfileReq({
    $fixnum.Int64? operatorId,
    $fixnum.Int64? groupId,
    $core.String? name,
    $core.String? avatar,
    $core.String? intro,
  }) {
    final result = create();
    if (operatorId != null) result.operatorId = operatorId;
    if (groupId != null) result.groupId = groupId;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    if (intro != null) result.intro = intro;
    return result;
  }

  UpdateGroupProfileReq._();

  factory UpdateGroupProfileReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UpdateGroupProfileReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateGroupProfileReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'operatorId')
    ..aInt64(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'avatar')
    ..aOS(5, _omitFieldNames ? '' : 'intro')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupProfileReq clone() => UpdateGroupProfileReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupProfileReq copyWith(void Function(UpdateGroupProfileReq) updates) => super.copyWith((message) => updates(message as UpdateGroupProfileReq)) as UpdateGroupProfileReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupProfileReq create() => UpdateGroupProfileReq._();
  @$core.override
  UpdateGroupProfileReq createEmptyInstance() => create();
  static $pb.PbList<UpdateGroupProfileReq> createRepeated() => $pb.PbList<UpdateGroupProfileReq>();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupProfileReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateGroupProfileReq>(create);
  static UpdateGroupProfileReq? _defaultInstance;

  /// 操作者 UID（=调用者）
  @$pb.TagNumber(1)
  $fixnum.Int64 get operatorId => $_getI64(0);
  @$pb.TagNumber(1)
  set operatorId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOperatorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperatorId() => $_clearField(1);

  /// 目标群 ID
  @$pb.TagNumber(2)
  $fixnum.Int64 get groupId => $_getI64(1);
  @$pb.TagNumber(2)
  set groupId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  /// 新名称（可选；若不修改请勿下发）
  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  /// 新头像（可选）
  @$pb.TagNumber(4)
  $core.String get avatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatar($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatar() => $_clearField(4);

  /// 新简介（可选）
  @$pb.TagNumber(5)
  $core.String get intro => $_getSZ(4);
  @$pb.TagNumber(5)
  set intro($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIntro() => $_has(4);
  @$pb.TagNumber(5)
  void clearIntro() => $_clearField(5);
}

/// -----------------------------------------------------------------------------
/// 解散群（仅群主）
/// - 解散后应解除所有成员关系，写回执与历史消息保留策略按后端配置；
/// -----------------------------------------------------------------------------
class DismissGroupReq extends $pb.GeneratedMessage {
  factory DismissGroupReq({
    $fixnum.Int64? operatorId,
    $fixnum.Int64? groupId,
  }) {
    final result = create();
    if (operatorId != null) result.operatorId = operatorId;
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  DismissGroupReq._();

  factory DismissGroupReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DismissGroupReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DismissGroupReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'operatorId')
    ..aInt64(2, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DismissGroupReq clone() => DismissGroupReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DismissGroupReq copyWith(void Function(DismissGroupReq) updates) => super.copyWith((message) => updates(message as DismissGroupReq)) as DismissGroupReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DismissGroupReq create() => DismissGroupReq._();
  @$core.override
  DismissGroupReq createEmptyInstance() => create();
  static $pb.PbList<DismissGroupReq> createRepeated() => $pb.PbList<DismissGroupReq>();
  @$core.pragma('dart2js:noInline')
  static DismissGroupReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DismissGroupReq>(create);
  static DismissGroupReq? _defaultInstance;

  /// 操作者 UID（必须为群主）
  @$pb.TagNumber(1)
  $fixnum.Int64 get operatorId => $_getI64(0);
  @$pb.TagNumber(1)
  set operatorId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOperatorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperatorId() => $_clearField(1);

  /// 目标群 ID
  @$pb.TagNumber(2)
  $fixnum.Int64 get groupId => $_getI64(1);
  @$pb.TagNumber(2)
  set groupId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);
}

/// -----------------------------------------------------------------------------
/// 加群请求
/// - 支持自主加入或携带邀请信息；
/// - inviter_* 字段仅在被邀请场景下填写；join_time_ms 为客户端触发时间（毫秒）；
/// - extra/join_source 用于业务扩展（如来源渠道、备注等）；
/// -----------------------------------------------------------------------------
class JoinGroupReq extends $pb.GeneratedMessage {
  factory JoinGroupReq({
    $fixnum.Int64? groupId,
    $fixnum.Int64? userId,
    $core.String? extra,
    $core.String? joinSource,
    $fixnum.Int64? inviterId,
    $core.String? inviterExtra,
    $core.String? inviterJoinSource,
    $fixnum.Int64? joinTimeMs,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (userId != null) result.userId = userId;
    if (extra != null) result.extra = extra;
    if (joinSource != null) result.joinSource = joinSource;
    if (inviterId != null) result.inviterId = inviterId;
    if (inviterExtra != null) result.inviterExtra = inviterExtra;
    if (inviterJoinSource != null) result.inviterJoinSource = inviterJoinSource;
    if (joinTimeMs != null) result.joinTimeMs = joinTimeMs;
    return result;
  }

  JoinGroupReq._();

  factory JoinGroupReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory JoinGroupReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinGroupReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'extra')
    ..aOS(4, _omitFieldNames ? '' : 'joinSource')
    ..aInt64(5, _omitFieldNames ? '' : 'inviterId')
    ..aOS(6, _omitFieldNames ? '' : 'inviterExtra')
    ..aOS(7, _omitFieldNames ? '' : 'inviterJoinSource')
    ..aInt64(8, _omitFieldNames ? '' : 'joinTimeMs')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinGroupReq clone() => JoinGroupReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinGroupReq copyWith(void Function(JoinGroupReq) updates) => super.copyWith((message) => updates(message as JoinGroupReq)) as JoinGroupReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinGroupReq create() => JoinGroupReq._();
  @$core.override
  JoinGroupReq createEmptyInstance() => create();
  static $pb.PbList<JoinGroupReq> createRepeated() => $pb.PbList<JoinGroupReq>();
  @$core.pragma('dart2js:noInline')
  static JoinGroupReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinGroupReq>(create);
  static JoinGroupReq? _defaultInstance;

  /// 目标群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 申请人 UID（=调用者）
  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// 申请附言（可空，0~256 字）
  @$pb.TagNumber(3)
  $core.String get extra => $_getSZ(2);
  @$pb.TagNumber(3)
  set extra($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExtra() => $_has(2);
  @$pb.TagNumber(3)
  void clearExtra() => $_clearField(3);

  /// 申请来源（如 qrcode/search/share_link…）
  @$pb.TagNumber(4)
  $core.String get joinSource => $_getSZ(3);
  @$pb.TagNumber(4)
  set joinSource($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasJoinSource() => $_has(3);
  @$pb.TagNumber(4)
  void clearJoinSource() => $_clearField(4);

  /// 邀请人 UID（若为被邀请入群场景）
  @$pb.TagNumber(5)
  $fixnum.Int64 get inviterId => $_getI64(4);
  @$pb.TagNumber(5)
  set inviterId($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasInviterId() => $_has(4);
  @$pb.TagNumber(5)
  void clearInviterId() => $_clearField(5);

  /// 邀请附言（可空）
  @$pb.TagNumber(6)
  $core.String get inviterExtra => $_getSZ(5);
  @$pb.TagNumber(6)
  set inviterExtra($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasInviterExtra() => $_has(5);
  @$pb.TagNumber(6)
  void clearInviterExtra() => $_clearField(6);

  /// 邀请来源（如 member_invite/admin_invite）
  @$pb.TagNumber(7)
  $core.String get inviterJoinSource => $_getSZ(6);
  @$pb.TagNumber(7)
  set inviterJoinSource($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasInviterJoinSource() => $_has(6);
  @$pb.TagNumber(7)
  void clearInviterJoinSource() => $_clearField(7);

  /// 客户端记录的申请时间（ms；可用于去重/风控）
  @$pb.TagNumber(8)
  $fixnum.Int64 get joinTimeMs => $_getI64(7);
  @$pb.TagNumber(8)
  set joinTimeMs($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasJoinTimeMs() => $_has(7);
  @$pb.TagNumber(8)
  void clearJoinTimeMs() => $_clearField(8);
}

/// -----------------------------------------------------------------------------
/// 主动退群
/// - user_id 必须等于调用者；群主退群需转让群主或拒绝；
/// -----------------------------------------------------------------------------
class LeaveGroupReq extends $pb.GeneratedMessage {
  factory LeaveGroupReq({
    $fixnum.Int64? groupId,
    $fixnum.Int64? userId,
    $core.String? reason,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (userId != null) result.userId = userId;
    if (reason != null) result.reason = reason;
    return result;
  }

  LeaveGroupReq._();

  factory LeaveGroupReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LeaveGroupReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LeaveGroupReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveGroupReq clone() => LeaveGroupReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveGroupReq copyWith(void Function(LeaveGroupReq) updates) => super.copyWith((message) => updates(message as LeaveGroupReq)) as LeaveGroupReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveGroupReq create() => LeaveGroupReq._();
  @$core.override
  LeaveGroupReq createEmptyInstance() => create();
  static $pb.PbList<LeaveGroupReq> createRepeated() => $pb.PbList<LeaveGroupReq>();
  @$core.pragma('dart2js:noInline')
  static LeaveGroupReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LeaveGroupReq>(create);
  static LeaveGroupReq? _defaultInstance;

  /// 目标群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 退群用户 UID（=调用者）
  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// 退群原因（可空；用于审计/画像）
  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);
}

/// -----------------------------------------------------------------------------
/// 审批加群
/// - operator_id 必须具备审批权限（OWNER/ADMIN）；accept=true 通过，否则拒绝；
/// - remark 为审批备注；建议写入 Join 审批流水；
/// -----------------------------------------------------------------------------
class ApproveJoinReq extends $pb.GeneratedMessage {
  factory ApproveJoinReq({
    $fixnum.Int64? groupId,
    $fixnum.Int64? operatorId,
    $fixnum.Int64? applicantId,
    $core.bool? accept,
    $core.String? remark,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (operatorId != null) result.operatorId = operatorId;
    if (applicantId != null) result.applicantId = applicantId;
    if (accept != null) result.accept = accept;
    if (remark != null) result.remark = remark;
    return result;
  }

  ApproveJoinReq._();

  factory ApproveJoinReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ApproveJoinReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApproveJoinReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorId')
    ..aInt64(3, _omitFieldNames ? '' : 'applicantId')
    ..aOB(4, _omitFieldNames ? '' : 'accept')
    ..aOS(5, _omitFieldNames ? '' : 'remark')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveJoinReq clone() => ApproveJoinReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveJoinReq copyWith(void Function(ApproveJoinReq) updates) => super.copyWith((message) => updates(message as ApproveJoinReq)) as ApproveJoinReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApproveJoinReq create() => ApproveJoinReq._();
  @$core.override
  ApproveJoinReq createEmptyInstance() => create();
  static $pb.PbList<ApproveJoinReq> createRepeated() => $pb.PbList<ApproveJoinReq>();
  @$core.pragma('dart2js:noInline')
  static ApproveJoinReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApproveJoinReq>(create);
  static ApproveJoinReq? _defaultInstance;

  /// 目标群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 审批人 UID（=调用者）
  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorId() => $_clearField(2);

  /// 申请人 UID
  @$pb.TagNumber(3)
  $fixnum.Int64 get applicantId => $_getI64(2);
  @$pb.TagNumber(3)
  set applicantId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasApplicantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearApplicantId() => $_clearField(3);

  /// true=通过；false=拒绝
  @$pb.TagNumber(4)
  $core.bool get accept => $_getBF(3);
  @$pb.TagNumber(4)
  set accept($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAccept() => $_has(3);
  @$pb.TagNumber(4)
  void clearAccept() => $_clearField(4);

  /// 审批备注（可空）
  @$pb.TagNumber(5)
  $core.String get remark => $_getSZ(4);
  @$pb.TagNumber(5)
  set remark($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRemark() => $_has(4);
  @$pb.TagNumber(5)
  void clearRemark() => $_clearField(5);
}

/// -----------------------------------------------------------------------------
/// 邀请成员
/// - operator_id 必须具备邀请权限；invitee_ids 不得包含已在群内的用户（服务端需去重/过滤）；
/// - extra 可记录批次号/来源；
/// -----------------------------------------------------------------------------
class InviteMembersReq extends $pb.GeneratedMessage {
  factory InviteMembersReq({
    $fixnum.Int64? groupId,
    $fixnum.Int64? operatorId,
    $core.Iterable<$fixnum.Int64>? inviteeIds,
    $core.String? extra,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (operatorId != null) result.operatorId = operatorId;
    if (inviteeIds != null) result.inviteeIds.addAll(inviteeIds);
    if (extra != null) result.extra = extra;
    return result;
  }

  InviteMembersReq._();

  factory InviteMembersReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory InviteMembersReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InviteMembersReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorId')
    ..p<$fixnum.Int64>(3, _omitFieldNames ? '' : 'inviteeIds', $pb.PbFieldType.K6)
    ..aOS(4, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMembersReq clone() => InviteMembersReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMembersReq copyWith(void Function(InviteMembersReq) updates) => super.copyWith((message) => updates(message as InviteMembersReq)) as InviteMembersReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteMembersReq create() => InviteMembersReq._();
  @$core.override
  InviteMembersReq createEmptyInstance() => create();
  static $pb.PbList<InviteMembersReq> createRepeated() => $pb.PbList<InviteMembersReq>();
  @$core.pragma('dart2js:noInline')
  static InviteMembersReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InviteMembersReq>(create);
  static InviteMembersReq? _defaultInstance;

  /// 目标群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 邀请发起人 UID（=调用者）
  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorId() => $_clearField(2);

  /// 被邀请用户 UID 列表（去重）
  @$pb.TagNumber(3)
  $pb.PbList<$fixnum.Int64> get inviteeIds => $_getList(2);

  /// 扩展信息（可空）
  @$pb.TagNumber(4)
  $core.String get extra => $_getSZ(3);
  @$pb.TagNumber(4)
  set extra($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExtra() => $_has(3);
  @$pb.TagNumber(4)
  void clearExtra() => $_clearField(4);
}

/// -----------------------------------------------------------------------------
/// 踢出成员
/// - operator_id 必须具备权限；不可踢 OWNER；ADMIN 之间互踢策略按产品定义（通常不允许）；
/// -----------------------------------------------------------------------------
class KickMemberReq extends $pb.GeneratedMessage {
  factory KickMemberReq({
    $fixnum.Int64? groupId,
    $fixnum.Int64? operatorId,
    $fixnum.Int64? targetId,
    $core.String? reason,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (operatorId != null) result.operatorId = operatorId;
    if (targetId != null) result.targetId = targetId;
    if (reason != null) result.reason = reason;
    return result;
  }

  KickMemberReq._();

  factory KickMemberReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory KickMemberReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KickMemberReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorId')
    ..aInt64(3, _omitFieldNames ? '' : 'targetId')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KickMemberReq clone() => KickMemberReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KickMemberReq copyWith(void Function(KickMemberReq) updates) => super.copyWith((message) => updates(message as KickMemberReq)) as KickMemberReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KickMemberReq create() => KickMemberReq._();
  @$core.override
  KickMemberReq createEmptyInstance() => create();
  static $pb.PbList<KickMemberReq> createRepeated() => $pb.PbList<KickMemberReq>();
  @$core.pragma('dart2js:noInline')
  static KickMemberReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KickMemberReq>(create);
  static KickMemberReq? _defaultInstance;

  /// 目标群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 操作者 UID（=调用者）
  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorId() => $_clearField(2);

  /// 被移除用户 UID
  @$pb.TagNumber(3)
  $fixnum.Int64 get targetId => $_getI64(2);
  @$pb.TagNumber(3)
  set targetId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetId() => $_clearField(3);

  /// 原因（可空；用于审计）
  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);
}

/// -----------------------------------------------------------------------------
/// 更新群名片/别名
/// - operator 可更新自己或（ADMIN/OWNER）更新他人别名；空串表示清空；
/// -----------------------------------------------------------------------------
class UpdateMemberAliasReq extends $pb.GeneratedMessage {
  factory UpdateMemberAliasReq({
    $fixnum.Int64? groupId,
    $fixnum.Int64? operatorId,
    $fixnum.Int64? targetId,
    $core.String? alias,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (operatorId != null) result.operatorId = operatorId;
    if (targetId != null) result.targetId = targetId;
    if (alias != null) result.alias = alias;
    return result;
  }

  UpdateMemberAliasReq._();

  factory UpdateMemberAliasReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UpdateMemberAliasReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateMemberAliasReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorId')
    ..aInt64(3, _omitFieldNames ? '' : 'targetId')
    ..aOS(4, _omitFieldNames ? '' : 'alias')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateMemberAliasReq clone() => UpdateMemberAliasReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateMemberAliasReq copyWith(void Function(UpdateMemberAliasReq) updates) => super.copyWith((message) => updates(message as UpdateMemberAliasReq)) as UpdateMemberAliasReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateMemberAliasReq create() => UpdateMemberAliasReq._();
  @$core.override
  UpdateMemberAliasReq createEmptyInstance() => create();
  static $pb.PbList<UpdateMemberAliasReq> createRepeated() => $pb.PbList<UpdateMemberAliasReq>();
  @$core.pragma('dart2js:noInline')
  static UpdateMemberAliasReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateMemberAliasReq>(create);
  static UpdateMemberAliasReq? _defaultInstance;

  /// 目标群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 操作者 UID（=调用者）
  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorId() => $_clearField(2);

  /// 目标用户 UID（可=operator_id）
  @$pb.TagNumber(3)
  $fixnum.Int64 get targetId => $_getI64(2);
  @$pb.TagNumber(3)
  set targetId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetId() => $_clearField(3);

  /// 新别名；空串表示清空；长度建议 0~32 字
  @$pb.TagNumber(4)
  $core.String get alias => $_getSZ(3);
  @$pb.TagNumber(4)
  set alias($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAlias() => $_has(3);
  @$pb.TagNumber(4)
  void clearAlias() => $_clearField(4);
}

/// -----------------------------------------------------------------------------
/// 调整成员角色
/// - 仅群主可调用；不可将自己直接降为 MEMBER 而无人接任 OWNER（需走转让流程）；
/// -----------------------------------------------------------------------------
class ChangeMemberRoleReq extends $pb.GeneratedMessage {
  factory ChangeMemberRoleReq({
    $fixnum.Int64? groupId,
    $fixnum.Int64? operatorId,
    $fixnum.Int64? targetId,
    GroupRoleType? role,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (operatorId != null) result.operatorId = operatorId;
    if (targetId != null) result.targetId = targetId;
    if (role != null) result.role = role;
    return result;
  }

  ChangeMemberRoleReq._();

  factory ChangeMemberRoleReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangeMemberRoleReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangeMemberRoleReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorId')
    ..aInt64(3, _omitFieldNames ? '' : 'targetId')
    ..e<GroupRoleType>(4, _omitFieldNames ? '' : 'role', $pb.PbFieldType.OE, defaultOrMaker: GroupRoleType.GROUP_ROLE_UNSPECIFIED, valueOf: GroupRoleType.valueOf, enumValues: GroupRoleType.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeMemberRoleReq clone() => ChangeMemberRoleReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeMemberRoleReq copyWith(void Function(ChangeMemberRoleReq) updates) => super.copyWith((message) => updates(message as ChangeMemberRoleReq)) as ChangeMemberRoleReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeMemberRoleReq create() => ChangeMemberRoleReq._();
  @$core.override
  ChangeMemberRoleReq createEmptyInstance() => create();
  static $pb.PbList<ChangeMemberRoleReq> createRepeated() => $pb.PbList<ChangeMemberRoleReq>();
  @$core.pragma('dart2js:noInline')
  static ChangeMemberRoleReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangeMemberRoleReq>(create);
  static ChangeMemberRoleReq? _defaultInstance;

  /// 目标群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 操作者 UID（必须为群主）
  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorId() => $_clearField(2);

  /// 目标成员 UID
  @$pb.TagNumber(3)
  $fixnum.Int64 get targetId => $_getI64(2);
  @$pb.TagNumber(3)
  set targetId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetId() => $_clearField(3);

  /// 新角色（ADMIN/MEMBER；OWNER 转让需单独流程或在后端校验）
  @$pb.TagNumber(4)
  GroupRoleType get role => $_getN(3);
  @$pb.TagNumber(4)
  set role(GroupRoleType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRole() => $_clearField(4);
}

/// -----------------------------------------------------------------------------
/// 查询群资料
/// - 返回 GroupInfo；若群被冻结/解散，服务端可返回 NOT_FOUND 或 enable=false；
/// -----------------------------------------------------------------------------
class GetGroupReq extends $pb.GeneratedMessage {
  factory GetGroupReq({
    $fixnum.Int64? groupId,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  GetGroupReq._();

  factory GetGroupReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetGroupReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupReq clone() => GetGroupReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupReq copyWith(void Function(GetGroupReq) updates) => super.copyWith((message) => updates(message as GetGroupReq)) as GetGroupReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupReq create() => GetGroupReq._();
  @$core.override
  GetGroupReq createEmptyInstance() => create();
  static $pb.PbList<GetGroupReq> createRepeated() => $pb.PbList<GetGroupReq>();
  @$core.pragma('dart2js:noInline')
  static GetGroupReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupReq>(create);
  static GetGroupReq? _defaultInstance;

  /// 群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);
}

/// -----------------------------------------------------------------------------
/// 分页查询群成员
/// - page 从 1 开始；page_size 建议 1..=100；
/// - 返回 MemberRef 列表与可选 total；total 获取可能影响性能，默认不强制计算；
/// -----------------------------------------------------------------------------
class GetMembersReq extends $pb.GeneratedMessage {
  factory GetMembersReq({
    $fixnum.Int64? groupId,
    $core.int? page,
    $core.int? pageSize,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  GetMembersReq._();

  factory GetMembersReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetMembersReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMembersReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'page', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMembersReq clone() => GetMembersReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMembersReq copyWith(void Function(GetMembersReq) updates) => super.copyWith((message) => updates(message as GetMembersReq)) as GetMembersReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMembersReq create() => GetMembersReq._();
  @$core.override
  GetMembersReq createEmptyInstance() => create();
  static $pb.PbList<GetMembersReq> createRepeated() => $pb.PbList<GetMembersReq>();
  @$core.pragma('dart2js:noInline')
  static GetMembersReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMembersReq>(create);
  static GetMembersReq? _defaultInstance;

  /// 群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 页码（从 1 开始）
  @$pb.TagNumber(2)
  $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2)
  set page($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);

  /// 每页大小（建议 1..=100）
  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);
}

/// -----------------------------------------------------------------------------
/// 成员分页返回
/// -----------------------------------------------------------------------------
class GetMembersResp extends $pb.GeneratedMessage {
  factory GetMembersResp({
    $core.Iterable<MemberRef>? members,
    $fixnum.Int64? total,
  }) {
    final result = create();
    if (members != null) result.members.addAll(members);
    if (total != null) result.total = total;
    return result;
  }

  GetMembersResp._();

  factory GetMembersResp.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetMembersResp.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMembersResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..pc<MemberRef>(1, _omitFieldNames ? '' : 'members', $pb.PbFieldType.PM, subBuilder: MemberRef.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'total', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMembersResp clone() => GetMembersResp()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMembersResp copyWith(void Function(GetMembersResp) updates) => super.copyWith((message) => updates(message as GetMembersResp)) as GetMembersResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMembersResp create() => GetMembersResp._();
  @$core.override
  GetMembersResp createEmptyInstance() => create();
  static $pb.PbList<GetMembersResp> createRepeated() => $pb.PbList<GetMembersResp>();
  @$core.pragma('dart2js:noInline')
  static GetMembersResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMembersResp>(create);
  static GetMembersResp? _defaultInstance;

  /// 成员轻量视图列表
  @$pb.TagNumber(1)
  $pb.PbList<MemberRef> get members => $_getList(0);

  /// 成员总数（可选填充；未填充表示未计算）
  @$pb.TagNumber(2)
  $fixnum.Int64 get total => $_getI64(1);
  @$pb.TagNumber(2)
  set total($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

/// -----------------------------------------------------------------------------
/// 统计成员数量
/// - 返回 count；与 GroupInfo.member_cnt 可能略有差异（强一致 vs 近实时缓存）；
/// -----------------------------------------------------------------------------
class CountMembersReq extends $pb.GeneratedMessage {
  factory CountMembersReq({
    $fixnum.Int64? groupId,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  CountMembersReq._();

  factory CountMembersReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CountMembersReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CountMembersReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CountMembersReq clone() => CountMembersReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CountMembersReq copyWith(void Function(CountMembersReq) updates) => super.copyWith((message) => updates(message as CountMembersReq)) as CountMembersReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CountMembersReq create() => CountMembersReq._();
  @$core.override
  CountMembersReq createEmptyInstance() => create();
  static $pb.PbList<CountMembersReq> createRepeated() => $pb.PbList<CountMembersReq>();
  @$core.pragma('dart2js:noInline')
  static CountMembersReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CountMembersReq>(create);
  static CountMembersReq? _defaultInstance;

  /// 群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);
}

/// -----------------------------------------------------------------------------
/// 成员数量返回
/// -----------------------------------------------------------------------------
class CountMembersResp extends $pb.GeneratedMessage {
  factory CountMembersResp({
    $fixnum.Int64? count,
  }) {
    final result = create();
    if (count != null) result.count = count;
    return result;
  }

  CountMembersResp._();

  factory CountMembersResp.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CountMembersResp.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CountMembersResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'count', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CountMembersResp clone() => CountMembersResp()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CountMembersResp copyWith(void Function(CountMembersResp) updates) => super.copyWith((message) => updates(message as CountMembersResp)) as CountMembersResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CountMembersResp create() => CountMembersResp._();
  @$core.override
  CountMembersResp createEmptyInstance() => create();
  static $pb.PbList<CountMembersResp> createRepeated() => $pb.PbList<CountMembersResp>();
  @$core.pragma('dart2js:noInline')
  static CountMembersResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CountMembersResp>(create);
  static CountMembersResp? _defaultInstance;

  /// 成员数
  @$pb.TagNumber(1)
  $fixnum.Int64 get count => $_getI64(0);
  @$pb.TagNumber(1)
  set count($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => $_clearField(1);
}

/// -----------------------------------------------------------------------------
/// 查询用户参与的所有群
/// - 用于“我的群列表”初始化；返回 group_ids（可分页扩展）；
/// -----------------------------------------------------------------------------
class UserGroupsReq extends $pb.GeneratedMessage {
  factory UserGroupsReq({
    $fixnum.Int64? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  UserGroupsReq._();

  factory UserGroupsReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UserGroupsReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserGroupsReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserGroupsReq clone() => UserGroupsReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserGroupsReq copyWith(void Function(UserGroupsReq) updates) => super.copyWith((message) => updates(message as UserGroupsReq)) as UserGroupsReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserGroupsReq create() => UserGroupsReq._();
  @$core.override
  UserGroupsReq createEmptyInstance() => create();
  static $pb.PbList<UserGroupsReq> createRepeated() => $pb.PbList<UserGroupsReq>();
  @$core.pragma('dart2js:noInline')
  static UserGroupsReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserGroupsReq>(create);
  static UserGroupsReq? _defaultInstance;

  /// 用户 UID
  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

/// -----------------------------------------------------------------------------
/// 用户群列表返回
/// -----------------------------------------------------------------------------
class UserGroupsResp extends $pb.GeneratedMessage {
  factory UserGroupsResp({
    $core.Iterable<$fixnum.Int64>? groupIds,
  }) {
    final result = create();
    if (groupIds != null) result.groupIds.addAll(groupIds);
    return result;
  }

  UserGroupsResp._();

  factory UserGroupsResp.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UserGroupsResp.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserGroupsResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'groupIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserGroupsResp clone() => UserGroupsResp()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserGroupsResp copyWith(void Function(UserGroupsResp) updates) => super.copyWith((message) => updates(message as UserGroupsResp)) as UserGroupsResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserGroupsResp create() => UserGroupsResp._();
  @$core.override
  UserGroupsResp createEmptyInstance() => create();
  static $pb.PbList<UserGroupsResp> createRepeated() => $pb.PbList<UserGroupsResp>();
  @$core.pragma('dart2js:noInline')
  static UserGroupsResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserGroupsResp>(create);
  static UserGroupsResp? _defaultInstance;

  /// 群 ID 列表
  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get groupIds => $_getList(0);
}

/// -----------------------------------------------------------------------------
/// 入群申请通知（发给审批人/群主/管理员）
/// - 包含申请/邀请的关键上下文，用于前端渲染审批页；
/// -----------------------------------------------------------------------------
class JoinRequestNotice extends $pb.GeneratedMessage {
  factory JoinRequestNotice({
    $fixnum.Int64? groupId,
    $core.String? groupName,
    $fixnum.Int64? applicantId,
    $core.String? extra,
    $core.String? joinSource,
    $fixnum.Int64? inviterId,
    $core.String? inviterExtra,
    $fixnum.Int64? requestTime,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (groupName != null) result.groupName = groupName;
    if (applicantId != null) result.applicantId = applicantId;
    if (extra != null) result.extra = extra;
    if (joinSource != null) result.joinSource = joinSource;
    if (inviterId != null) result.inviterId = inviterId;
    if (inviterExtra != null) result.inviterExtra = inviterExtra;
    if (requestTime != null) result.requestTime = requestTime;
    return result;
  }

  JoinRequestNotice._();

  factory JoinRequestNotice.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory JoinRequestNotice.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinRequestNotice', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aOS(2, _omitFieldNames ? '' : 'groupName')
    ..aInt64(3, _omitFieldNames ? '' : 'applicantId')
    ..aOS(4, _omitFieldNames ? '' : 'extra')
    ..aOS(5, _omitFieldNames ? '' : 'joinSource')
    ..aInt64(6, _omitFieldNames ? '' : 'inviterId')
    ..aOS(7, _omitFieldNames ? '' : 'inviterExtra')
    ..aInt64(8, _omitFieldNames ? '' : 'requestTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestNotice clone() => JoinRequestNotice()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestNotice copyWith(void Function(JoinRequestNotice) updates) => super.copyWith((message) => updates(message as JoinRequestNotice)) as JoinRequestNotice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestNotice create() => JoinRequestNotice._();
  @$core.override
  JoinRequestNotice createEmptyInstance() => create();
  static $pb.PbList<JoinRequestNotice> createRepeated() => $pb.PbList<JoinRequestNotice>();
  @$core.pragma('dart2js:noInline')
  static JoinRequestNotice getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinRequestNotice>(create);
  static JoinRequestNotice? _defaultInstance;

  /// 目标群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 群名称快照（避免名称变更引发的前端闪烁）
  @$pb.TagNumber(2)
  $core.String get groupName => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupName() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupName() => $_clearField(2);

  /// 申请人 UID
  @$pb.TagNumber(3)
  $fixnum.Int64 get applicantId => $_getI64(2);
  @$pb.TagNumber(3)
  set applicantId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasApplicantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearApplicantId() => $_clearField(3);

  /// 申请附言
  @$pb.TagNumber(4)
  $core.String get extra => $_getSZ(3);
  @$pb.TagNumber(4)
  set extra($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExtra() => $_has(3);
  @$pb.TagNumber(4)
  void clearExtra() => $_clearField(4);

  /// 申请来源
  @$pb.TagNumber(5)
  $core.String get joinSource => $_getSZ(4);
  @$pb.TagNumber(5)
  set joinSource($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasJoinSource() => $_has(4);
  @$pb.TagNumber(5)
  void clearJoinSource() => $_clearField(5);

  /// 邀请人 UID（若有）
  @$pb.TagNumber(6)
  $fixnum.Int64 get inviterId => $_getI64(5);
  @$pb.TagNumber(6)
  set inviterId($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasInviterId() => $_has(5);
  @$pb.TagNumber(6)
  void clearInviterId() => $_clearField(6);

  /// 邀请附言
  @$pb.TagNumber(7)
  $core.String get inviterExtra => $_getSZ(6);
  @$pb.TagNumber(7)
  set inviterExtra($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasInviterExtra() => $_has(6);
  @$pb.TagNumber(7)
  void clearInviterExtra() => $_clearField(7);

  /// 申请时间（毫秒）
  @$pb.TagNumber(8)
  $fixnum.Int64 get requestTime => $_getI64(7);
  @$pb.TagNumber(8)
  set requestTime($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRequestTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequestTime() => $_clearField(8);
}

/// -----------------------------------------------------------------------------
/// 入群申请处理结果通知（发给申请人/相关管理员）
/// -----------------------------------------------------------------------------
class JoinRequestHandledNotice extends $pb.GeneratedMessage {
  factory JoinRequestHandledNotice({
    $fixnum.Int64? groupId,
    $fixnum.Int64? applicantId,
    $fixnum.Int64? operatorId,
    $core.bool? accepted,
    $core.String? remark,
    $fixnum.Int64? handledAt,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (applicantId != null) result.applicantId = applicantId;
    if (operatorId != null) result.operatorId = operatorId;
    if (accepted != null) result.accepted = accepted;
    if (remark != null) result.remark = remark;
    if (handledAt != null) result.handledAt = handledAt;
    return result;
  }

  JoinRequestHandledNotice._();

  factory JoinRequestHandledNotice.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory JoinRequestHandledNotice.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinRequestHandledNotice', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'applicantId')
    ..aInt64(3, _omitFieldNames ? '' : 'operatorId')
    ..aOB(4, _omitFieldNames ? '' : 'accepted')
    ..aOS(5, _omitFieldNames ? '' : 'remark')
    ..aInt64(6, _omitFieldNames ? '' : 'handledAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestHandledNotice clone() => JoinRequestHandledNotice()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRequestHandledNotice copyWith(void Function(JoinRequestHandledNotice) updates) => super.copyWith((message) => updates(message as JoinRequestHandledNotice)) as JoinRequestHandledNotice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinRequestHandledNotice create() => JoinRequestHandledNotice._();
  @$core.override
  JoinRequestHandledNotice createEmptyInstance() => create();
  static $pb.PbList<JoinRequestHandledNotice> createRepeated() => $pb.PbList<JoinRequestHandledNotice>();
  @$core.pragma('dart2js:noInline')
  static JoinRequestHandledNotice getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinRequestHandledNotice>(create);
  static JoinRequestHandledNotice? _defaultInstance;

  /// 目标群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 申请人 UID
  @$pb.TagNumber(2)
  $fixnum.Int64 get applicantId => $_getI64(1);
  @$pb.TagNumber(2)
  set applicantId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasApplicantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearApplicantId() => $_clearField(2);

  /// 审批人 UID
  @$pb.TagNumber(3)
  $fixnum.Int64 get operatorId => $_getI64(2);
  @$pb.TagNumber(3)
  set operatorId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOperatorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOperatorId() => $_clearField(3);

  /// 审批结果（true=通过 / false=拒绝）
  @$pb.TagNumber(4)
  $core.bool get accepted => $_getBF(3);
  @$pb.TagNumber(4)
  set accepted($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAccepted() => $_has(3);
  @$pb.TagNumber(4)
  void clearAccepted() => $_clearField(4);

  /// 审批备注
  @$pb.TagNumber(5)
  $core.String get remark => $_getSZ(4);
  @$pb.TagNumber(5)
  set remark($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRemark() => $_has(4);
  @$pb.TagNumber(5)
  void clearRemark() => $_clearField(5);

  /// 审批时间（毫秒）
  @$pb.TagNumber(6)
  $fixnum.Int64 get handledAt => $_getI64(5);
  @$pb.TagNumber(6)
  set handledAt($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHandledAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearHandledAt() => $_clearField(6);
}

/// -----------------------------------------------------------------------------
/// 群成员变更通知（入群/退群/踢人/改角色/改别名等）
/// - reason 示例：auto / approval / invite / kick / leave / role_change / alias_change；
/// -----------------------------------------------------------------------------
class GroupMemberChangeNotice extends $pb.GeneratedMessage {
  factory GroupMemberChangeNotice({
    $fixnum.Int64? groupId,
    $fixnum.Int64? operatorId,
    MemberRef? member,
    $core.String? reason,
    $fixnum.Int64? eventTime,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (operatorId != null) result.operatorId = operatorId;
    if (member != null) result.member = member;
    if (reason != null) result.reason = reason;
    if (eventTime != null) result.eventTime = eventTime;
    return result;
  }

  GroupMemberChangeNotice._();

  factory GroupMemberChangeNotice.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GroupMemberChangeNotice.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupMemberChangeNotice', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_group_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorId')
    ..aOM<MemberRef>(3, _omitFieldNames ? '' : 'member', subBuilder: MemberRef.create)
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..aInt64(5, _omitFieldNames ? '' : 'eventTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMemberChangeNotice clone() => GroupMemberChangeNotice()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMemberChangeNotice copyWith(void Function(GroupMemberChangeNotice) updates) => super.copyWith((message) => updates(message as GroupMemberChangeNotice)) as GroupMemberChangeNotice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupMemberChangeNotice create() => GroupMemberChangeNotice._();
  @$core.override
  GroupMemberChangeNotice createEmptyInstance() => create();
  static $pb.PbList<GroupMemberChangeNotice> createRepeated() => $pb.PbList<GroupMemberChangeNotice>();
  @$core.pragma('dart2js:noInline')
  static GroupMemberChangeNotice getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupMemberChangeNotice>(create);
  static GroupMemberChangeNotice? _defaultInstance;

  /// 群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 操作者 UID（系统自动为 0 或特定保留值）
  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorId() => $_clearField(2);

  /// 变动成员信息（含 id/alias/role）
  @$pb.TagNumber(3)
  MemberRef get member => $_getN(2);
  @$pb.TagNumber(3)
  set member(MemberRef value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMember() => $_has(2);
  @$pb.TagNumber(3)
  void clearMember() => $_clearField(3);
  @$pb.TagNumber(3)
  MemberRef ensureMember() => $_ensure(2);

  /// 业务原因（字符串，便于前端展示与埋点统计）
  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);

  /// 事件时间（毫秒）
  @$pb.TagNumber(5)
  $fixnum.Int64 get eventTime => $_getI64(4);
  @$pb.TagNumber(5)
  set eventTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEventTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearEventTime() => $_clearField(5);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
