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

import 'package:protobuf/protobuf.dart' as $pb;

/// -----------------------------------------------------------------------------
/// 群成员角色类型（与数据库/内存中的角色编码严格对齐）
/// - 角色决定可执行的管理操作范围（审批、邀请、踢人、改别名、改角色等）；
/// - 角色升级/降级需满足业务约束（仅群主可设为 ADMIN/转让 OWNER）；
/// -----------------------------------------------------------------------------
class GroupRoleType extends $pb.ProtobufEnum {
  /// 未指定（默认值，避免 proto3 默认 0 解析失败）
  static const GroupRoleType GROUP_ROLE_UNSPECIFIED = GroupRoleType._(0, _omitEnumNames ? '' : 'GROUP_ROLE_UNSPECIFIED');
  /// 群主（最高权限；可解散群、转让群主、设/撤管理员、踢人）
  static const GroupRoleType OWNER = GroupRoleType._(1, _omitEnumNames ? '' : 'OWNER');
  /// 管理员（可审批、邀请、踢人；不可解散群、不可转让群主）
  static const GroupRoleType ADMIN = GroupRoleType._(2, _omitEnumNames ? '' : 'ADMIN');
  /// 普通成员（仅参与聊天、可退群、可更新自己的别名）
  static const GroupRoleType MEMBER = GroupRoleType._(3, _omitEnumNames ? '' : 'MEMBER');

  static const $core.List<GroupRoleType> values = <GroupRoleType> [
    GROUP_ROLE_UNSPECIFIED,
    OWNER,
    ADMIN,
    MEMBER,
  ];

  static final $core.List<GroupRoleType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static GroupRoleType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GroupRoleType._(super.value, super.name);
}

/// -----------------------------------------------------------------------------
/// 加群权限控制
/// - 用于 GetGroup 查询与前端入群入口显隐；
/// - 修改该配置应触发缓存刷新与事件通知（可选）；
/// -----------------------------------------------------------------------------
class JoinPermission extends $pb.ProtobufEnum {
  /// 未指定
  static const JoinPermission JOIN_PERMISSION_UNSPECIFIED = JoinPermission._(0, _omitEnumNames ? '' : 'JOIN_PERMISSION_UNSPECIFIED');
  /// 任何人可直接加入（不走审批流）
  static const JoinPermission ANYONE = JoinPermission._(1, _omitEnumNames ? '' : 'ANYONE');
  /// 申请后需群主或管理员审批
  static const JoinPermission NEED_APPROVAL = JoinPermission._(2, _omitEnumNames ? '' : 'NEED_APPROVAL');
  /// 仅允许邀请加入（成员/管理员发起邀请）
  static const JoinPermission INVITE_ONLY = JoinPermission._(3, _omitEnumNames ? '' : 'INVITE_ONLY');
  /// 完全关闭加入能力（仅保留当前成员）
  static const JoinPermission CLOSED = JoinPermission._(4, _omitEnumNames ? '' : 'CLOSED');

  static const $core.List<JoinPermission> values = <JoinPermission> [
    JOIN_PERMISSION_UNSPECIFIED,
    ANYONE,
    NEED_APPROVAL,
    INVITE_ONLY,
    CLOSED,
  ];

  static final $core.List<JoinPermission?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static JoinPermission? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const JoinPermission._(super.value, super.name);
}

/// -----------------------------------------------------------------------------
/// 群组类型
/// - NORMAL：常规上限；SUPER：更高人数上限/特殊路由；SYSTEM：系统内置（公告/客服）；
/// - 不同类型在服务端可能走不同配额/限流策略；
/// -----------------------------------------------------------------------------
class GroupType extends $pb.ProtobufEnum {
  /// 未知（保底值；不应在正常业务流出现）
  static const GroupType UNKNOWN_GROUP_TYPE = GroupType._(0, _omitEnumNames ? '' : 'UNKNOWN_GROUP_TYPE');
  /// 普通群组
  static const GroupType NORMAL_GROUP = GroupType._(1, _omitEnumNames ? '' : 'NORMAL_GROUP');
  /// 超级群组（高并发/高上限）
  static const GroupType SUPER_GROUP = GroupType._(2, _omitEnumNames ? '' : 'SUPER_GROUP');
  /// 系统群组（内置用途，不对外创建）
  static const GroupType SYSTEM_GROUP = GroupType._(3, _omitEnumNames ? '' : 'SYSTEM_GROUP');

  static const $core.List<GroupType> values = <GroupType> [
    UNKNOWN_GROUP_TYPE,
    NORMAL_GROUP,
    SUPER_GROUP,
    SYSTEM_GROUP,
  ];

  static final $core.List<GroupType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static GroupType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GroupType._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
