// This is a generated file - do not edit.
//
// Generated from user.proto.

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
/// 👤 用户资料更新推送消息（UserFlush）
/// =======================================
/// 用于通知客户端"某个用户资料已被修改"，例如昵称、头像、状态等。
/// 常见触发：用户主动修改资料、后台修改资料、服务端同步触发。
/// 客户端收到后应刷新本地缓存信息。
class UserFlushMsg extends $pb.GeneratedMessage {
  factory UserFlushMsg({
    $core.String? uid,
    $core.String? operatorId,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? fields,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (uid != null) result.uid = uid;
    if (operatorId != null) result.operatorId = operatorId;
    if (fields != null) result.fields.addEntries(fields);
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  UserFlushMsg._();

  factory UserFlushMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UserFlushMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserFlushMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.user'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'uid')
    ..aOS(2, _omitFieldNames ? '' : 'operatorId')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'fields', entryClassName: 'UserFlushMsg.FieldsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('protocol.user'))
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserFlushMsg clone() => UserFlushMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserFlushMsg copyWith(void Function(UserFlushMsg) updates) => super.copyWith((message) => updates(message as UserFlushMsg)) as UserFlushMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserFlushMsg create() => UserFlushMsg._();
  @$core.override
  UserFlushMsg createEmptyInstance() => create();
  static $pb.PbList<UserFlushMsg> createRepeated() => $pb.PbList<UserFlushMsg>();
  @$core.pragma('dart2js:noInline')
  static UserFlushMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserFlushMsg>(create);
  static UserFlushMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uid => $_getSZ(0);
  @$pb.TagNumber(1)
  set uid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get operatorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set operatorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get fields => $_getMap(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
