// This is a generated file - do not edit.
//
// Generated from system.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// =======================================
/// 📢 通用系统通知消息
/// =======================================
/// 用于客户端接收系统级别的通知，如登录提醒、账号变动、强制下线等
class SystemNotificationMsg extends $pb.GeneratedMessage {
  factory SystemNotificationMsg({
    $core.String? notificationType,
    $core.String? sender,
    $core.String? target,
    $core.String? content,
    $fixnum.Int64? timestamp,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? meta,
  }) {
    final result = create();
    if (notificationType != null) result.notificationType = notificationType;
    if (sender != null) result.sender = sender;
    if (target != null) result.target = target;
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    if (meta != null) result.meta.addEntries(meta);
    return result;
  }

  SystemNotificationMsg._();

  factory SystemNotificationMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SystemNotificationMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SystemNotificationMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.system'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'notificationType')
    ..aOS(2, _omitFieldNames ? '' : 'sender')
    ..aOS(3, _omitFieldNames ? '' : 'target')
    ..aOS(4, _omitFieldNames ? '' : 'content')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'meta', entryClassName: 'SystemNotificationMsg.MetaEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('protocol.system'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemNotificationMsg clone() => SystemNotificationMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemNotificationMsg copyWith(void Function(SystemNotificationMsg) updates) => super.copyWith((message) => updates(message as SystemNotificationMsg)) as SystemNotificationMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemNotificationMsg create() => SystemNotificationMsg._();
  @$core.override
  SystemNotificationMsg createEmptyInstance() => create();
  static $pb.PbList<SystemNotificationMsg> createRepeated() => $pb.PbList<SystemNotificationMsg>();
  @$core.pragma('dart2js:noInline')
  static SystemNotificationMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SystemNotificationMsg>(create);
  static SystemNotificationMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get notificationType => $_getSZ(0);
  @$pb.TagNumber(1)
  set notificationType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNotificationType() => $_has(0);
  @$pb.TagNumber(1)
  void clearNotificationType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sender => $_getSZ(1);
  @$pb.TagNumber(2)
  set sender($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSender() => $_has(1);
  @$pb.TagNumber(2)
  void clearSender() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get target => $_getSZ(2);
  @$pb.TagNumber(3)
  set target($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTarget() => $_has(2);
  @$pb.TagNumber(3)
  void clearTarget() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get content => $_getSZ(3);
  @$pb.TagNumber(4)
  set content($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $core.String> get meta => $_getMap(5);
}

/// =======================================
/// 🚨 系统事件消息（Server 事件推送）
/// =======================================
/// 用于传递后端业务逻辑事件，例如用户被封禁、服务重启、设备冲突等
class SystemEventMsg extends $pb.GeneratedMessage {
  factory SystemEventMsg({
    $core.String? eventType,
    $core.String? description,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? details,
  }) {
    final result = create();
    if (eventType != null) result.eventType = eventType;
    if (description != null) result.description = description;
    if (details != null) result.details.addEntries(details);
    return result;
  }

  SystemEventMsg._();

  factory SystemEventMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SystemEventMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SystemEventMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.system'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'eventType')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'details', entryClassName: 'SystemEventMsg.DetailsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('protocol.system'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemEventMsg clone() => SystemEventMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemEventMsg copyWith(void Function(SystemEventMsg) updates) => super.copyWith((message) => updates(message as SystemEventMsg)) as SystemEventMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemEventMsg create() => SystemEventMsg._();
  @$core.override
  SystemEventMsg createEmptyInstance() => create();
  static $pb.PbList<SystemEventMsg> createRepeated() => $pb.PbList<SystemEventMsg>();
  @$core.pragma('dart2js:noInline')
  static SystemEventMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SystemEventMsg>(create);
  static SystemEventMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventType => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get details => $_getMap(2);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
