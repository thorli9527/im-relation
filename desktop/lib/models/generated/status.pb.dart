// This is a generated file - do not edit.
//
// Generated from status.proto.

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

/// =======================================
/// ✅ 消息已读回执（Read Receipt）
/// =======================================
/// 表示某条消息已被哪些用户阅读，适用于单聊或群聊消息同步场景。
class ReadReceiptMsg extends $pb.GeneratedMessage {
  factory ReadReceiptMsg({
    $fixnum.Int64? messageId,
    $core.Iterable<$core.String>? readerIds,
    $fixnum.Int64? readTime,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (readerIds != null) result.readerIds.addAll(readerIds);
    if (readTime != null) result.readTime = readTime;
    return result;
  }

  ReadReceiptMsg._();

  factory ReadReceiptMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ReadReceiptMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReadReceiptMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.status'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPS(2, _omitFieldNames ? '' : 'readerIds')
    ..aInt64(3, _omitFieldNames ? '' : 'readTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadReceiptMsg clone() => ReadReceiptMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadReceiptMsg copyWith(void Function(ReadReceiptMsg) updates) => super.copyWith((message) => updates(message as ReadReceiptMsg)) as ReadReceiptMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReadReceiptMsg create() => ReadReceiptMsg._();
  @$core.override
  ReadReceiptMsg createEmptyInstance() => create();
  static $pb.PbList<ReadReceiptMsg> createRepeated() => $pb.PbList<ReadReceiptMsg>();
  @$core.pragma('dart2js:noInline')
  static ReadReceiptMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReadReceiptMsg>(create);
  static ReadReceiptMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get readerIds => $_getList(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get readTime => $_getI64(2);
  @$pb.TagNumber(3)
  set readTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReadTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearReadTime() => $_clearField(3);
}

/// =======================================
/// ✍️ 正在输入通知（Typing Notice）
/// =======================================
/// 表示某个用户正在对另一个用户/会话进行输入操作，适用于 UI "对方正在输入..." 提示。
class TypingNoticeMsg extends $pb.GeneratedMessage {
  factory TypingNoticeMsg({
    $core.String? fromUid,
    $core.String? toUid,
    $core.bool? isTyping,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (fromUid != null) result.fromUid = fromUid;
    if (toUid != null) result.toUid = toUid;
    if (isTyping != null) result.isTyping = isTyping;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  TypingNoticeMsg._();

  factory TypingNoticeMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory TypingNoticeMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TypingNoticeMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.status'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fromUid')
    ..aOS(2, _omitFieldNames ? '' : 'toUid')
    ..aOB(3, _omitFieldNames ? '' : 'isTyping')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingNoticeMsg clone() => TypingNoticeMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingNoticeMsg copyWith(void Function(TypingNoticeMsg) updates) => super.copyWith((message) => updates(message as TypingNoticeMsg)) as TypingNoticeMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingNoticeMsg create() => TypingNoticeMsg._();
  @$core.override
  TypingNoticeMsg createEmptyInstance() => create();
  static $pb.PbList<TypingNoticeMsg> createRepeated() => $pb.PbList<TypingNoticeMsg>();
  @$core.pragma('dart2js:noInline')
  static TypingNoticeMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TypingNoticeMsg>(create);
  static TypingNoticeMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromUid => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromUid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toUid => $_getSZ(1);
  @$pb.TagNumber(2)
  set toUid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearToUid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isTyping => $_getBF(2);
  @$pb.TagNumber(3)
  set isTyping($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsTyping() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsTyping() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// =======================================
/// ❤️ 心跳包（Heartbeat）
/// =======================================
/// 用于维持客户端与服务器之间的长连接状态，客户端定时发送。
class HeartbeatMsg extends $pb.GeneratedMessage {
  factory HeartbeatMsg() => create();

  HeartbeatMsg._();

  factory HeartbeatMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory HeartbeatMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HeartbeatMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.status'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatMsg clone() => HeartbeatMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatMsg copyWith(void Function(HeartbeatMsg) updates) => super.copyWith((message) => updates(message as HeartbeatMsg)) as HeartbeatMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HeartbeatMsg create() => HeartbeatMsg._();
  @$core.override
  HeartbeatMsg createEmptyInstance() => create();
  static $pb.PbList<HeartbeatMsg> createRepeated() => $pb.PbList<HeartbeatMsg>();
  @$core.pragma('dart2js:noInline')
  static HeartbeatMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HeartbeatMsg>(create);
  static HeartbeatMsg? _defaultInstance;
}

/// =======================================
/// 📨 ACK 确认消息（AckMessage）
/// =======================================
/// 用于确认收到某一封消息（包括聊天、系统等），支持链路追踪和可靠性保证。
class AckMsg extends $pb.GeneratedMessage {
  factory AckMsg({
    $fixnum.Int64? messageId,
    $0.ByteMessageType? ackType,
    $core.bool? success,
    $core.int? errorCode,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (ackType != null) result.ackType = ackType;
    if (success != null) result.success = success;
    if (errorCode != null) result.errorCode = errorCode;
    return result;
  }

  AckMsg._();

  factory AckMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AckMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AckMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.status'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..e<$0.ByteMessageType>(2, _omitFieldNames ? '' : 'ackType', $pb.PbFieldType.OE, defaultOrMaker: $0.ByteMessageType.UNKNOWN_BYTE_MESSAGE_TYPE, valueOf: $0.ByteMessageType.valueOf, enumValues: $0.ByteMessageType.values)
    ..aOB(3, _omitFieldNames ? '' : 'success')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'errorCode', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AckMsg clone() => AckMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AckMsg copyWith(void Function(AckMsg) updates) => super.copyWith((message) => updates(message as AckMsg)) as AckMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AckMsg create() => AckMsg._();
  @$core.override
  AckMsg createEmptyInstance() => create();
  static $pb.PbList<AckMsg> createRepeated() => $pb.PbList<AckMsg>();
  @$core.pragma('dart2js:noInline')
  static AckMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AckMsg>(create);
  static AckMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.ByteMessageType get ackType => $_getN(1);
  @$pb.TagNumber(2)
  set ackType($0.ByteMessageType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAckType() => $_has(1);
  @$pb.TagNumber(2)
  void clearAckType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get success => $_getBF(2);
  @$pb.TagNumber(3)
  set success($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSuccess() => $_has(2);
  @$pb.TagNumber(3)
  void clearSuccess() => $_clearField(3);

  @$pb.TagNumber(5)
  $core.int get errorCode => $_getIZ(3);
  @$pb.TagNumber(5)
  set errorCode($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(5)
  $core.bool hasErrorCode() => $_has(3);
  @$pb.TagNumber(5)
  void clearErrorCode() => $_clearField(5);
}

/// =======================================
/// 🔗 重连消息（ReConnectMsg）
/// =================
class ReConnectMsg extends $pb.GeneratedMessage {
  factory ReConnectMsg({
    $fixnum.Int64? messageId,
    $core.String? socketAddr,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (socketAddr != null) result.socketAddr = socketAddr;
    return result;
  }

  ReConnectMsg._();

  factory ReConnectMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ReConnectMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReConnectMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.status'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'socketAddr')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReConnectMsg clone() => ReConnectMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReConnectMsg copyWith(void Function(ReConnectMsg) updates) => super.copyWith((message) => updates(message as ReConnectMsg)) as ReConnectMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReConnectMsg create() => ReConnectMsg._();
  @$core.override
  ReConnectMsg createEmptyInstance() => create();
  static $pb.PbList<ReConnectMsg> createRepeated() => $pb.PbList<ReConnectMsg>();
  @$core.pragma('dart2js:noInline')
  static ReConnectMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReConnectMsg>(create);
  static ReConnectMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get socketAddr => $_getSZ(1);
  @$pb.TagNumber(2)
  set socketAddr($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSocketAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearSocketAddr() => $_clearField(2);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
