// This is a generated file - do not edit.
//
// Generated from friend.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'friend.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'friend.pbenum.dart';

/// ================================
/// 📦 好友事件消息结构
/// ================================
/// 用于客户端/服务端之间同步好友事件记录，包含完整的事件信息
class FriendEventMsg extends $pb.GeneratedMessage {
  factory FriendEventMsg({
    $fixnum.Int64? messageId,
    $core.String? fromUid,
    $core.String? toUid,
    FriendEventType? eventType,
    $core.String? message,
    EventStatus? status,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? updatedAt,
    FriendSourceType? sourceType,
    $core.String? fromAName,
    $core.String? toAName,
    $core.String? fromRemark,
    $core.String? toRemark,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (fromUid != null) result.fromUid = fromUid;
    if (toUid != null) result.toUid = toUid;
    if (eventType != null) result.eventType = eventType;
    if (message != null) result.message = message;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (sourceType != null) result.sourceType = sourceType;
    if (fromAName != null) result.fromAName = fromAName;
    if (toAName != null) result.toAName = toAName;
    if (fromRemark != null) result.fromRemark = fromRemark;
    if (toRemark != null) result.toRemark = toRemark;
    return result;
  }

  FriendEventMsg._();

  factory FriendEventMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FriendEventMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FriendEventMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.friend'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'fromUid')
    ..aOS(3, _omitFieldNames ? '' : 'toUid')
    ..e<FriendEventType>(4, _omitFieldNames ? '' : 'eventType', $pb.PbFieldType.OE, defaultOrMaker: FriendEventType.FRIEND_EVENT_UNKNOWN, valueOf: FriendEventType.valueOf, enumValues: FriendEventType.values)
    ..aOS(5, _omitFieldNames ? '' : 'message')
    ..e<EventStatus>(6, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: EventStatus.PENDING, valueOf: EventStatus.valueOf, enumValues: EventStatus.values)
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'createdAt', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(8, _omitFieldNames ? '' : 'updatedAt', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..e<FriendSourceType>(9, _omitFieldNames ? '' : 'sourceType', $pb.PbFieldType.OE, defaultOrMaker: FriendSourceType.FRIEND_SOURCE_UNKNOWN, valueOf: FriendSourceType.valueOf, enumValues: FriendSourceType.values)
    ..aOS(10, _omitFieldNames ? '' : 'fromAName')
    ..aOS(11, _omitFieldNames ? '' : 'toAName')
    ..aOS(12, _omitFieldNames ? '' : 'fromRemark')
    ..aOS(13, _omitFieldNames ? '' : 'toRemark')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendEventMsg clone() => FriendEventMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendEventMsg copyWith(void Function(FriendEventMsg) updates) => super.copyWith((message) => updates(message as FriendEventMsg)) as FriendEventMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FriendEventMsg create() => FriendEventMsg._();
  @$core.override
  FriendEventMsg createEmptyInstance() => create();
  static $pb.PbList<FriendEventMsg> createRepeated() => $pb.PbList<FriendEventMsg>();
  @$core.pragma('dart2js:noInline')
  static FriendEventMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendEventMsg>(create);
  static FriendEventMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fromUid => $_getSZ(1);
  @$pb.TagNumber(2)
  set fromUid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromUid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get toUid => $_getSZ(2);
  @$pb.TagNumber(3)
  set toUid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearToUid() => $_clearField(3);

  @$pb.TagNumber(4)
  FriendEventType get eventType => $_getN(3);
  @$pb.TagNumber(4)
  set eventType(FriendEventType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEventType() => $_has(3);
  @$pb.TagNumber(4)
  void clearEventType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get message => $_getSZ(4);
  @$pb.TagNumber(5)
  set message($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessage() => $_clearField(5);

  @$pb.TagNumber(6)
  EventStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(EventStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get createdAt => $_getI64(6);
  @$pb.TagNumber(7)
  set createdAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get updatedAt => $_getI64(7);
  @$pb.TagNumber(8)
  set updatedAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUpdatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdatedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  FriendSourceType get sourceType => $_getN(8);
  @$pb.TagNumber(9)
  set sourceType(FriendSourceType value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasSourceType() => $_has(8);
  @$pb.TagNumber(9)
  void clearSourceType() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get fromAName => $_getSZ(9);
  @$pb.TagNumber(10)
  set fromAName($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasFromAName() => $_has(9);
  @$pb.TagNumber(10)
  void clearFromAName() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get toAName => $_getSZ(10);
  @$pb.TagNumber(11)
  set toAName($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasToAName() => $_has(10);
  @$pb.TagNumber(11)
  void clearToAName() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get fromRemark => $_getSZ(11);
  @$pb.TagNumber(12)
  set fromRemark($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasFromRemark() => $_has(11);
  @$pb.TagNumber(12)
  void clearFromRemark() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get toRemark => $_getSZ(12);
  @$pb.TagNumber(13)
  set toRemark($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasToRemark() => $_has(12);
  @$pb.TagNumber(13)
  void clearToRemark() => $_clearField(13);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
