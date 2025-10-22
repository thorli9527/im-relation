// This is a generated file - do not edit.
//
// Generated from socket.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'socket.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'socket.pbenum.dart';

/// 客户端握手请求：连接建立后首帧
class AuthMsg extends $pb.GeneratedMessage {
  factory AuthMsg({
    $fixnum.Int64? userId,
    DeviceType? deviceType,
    $core.String? deviceId,
    $core.String? token,
    $fixnum.Int64? tsMs,
    $core.List<$core.int>? nonce,
    $core.List<$core.int>? signature,
    $core.bool? resume,
    $fixnum.Int64? lastAckId,
    $core.bool? supportsEncryption,
    $core.Iterable<$core.String>? encryptionSchemes,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceType != null) result.deviceType = deviceType;
    if (deviceId != null) result.deviceId = deviceId;
    if (token != null) result.token = token;
    if (tsMs != null) result.tsMs = tsMs;
    if (nonce != null) result.nonce = nonce;
    if (signature != null) result.signature = signature;
    if (resume != null) result.resume = resume;
    if (lastAckId != null) result.lastAckId = lastAckId;
    if (supportsEncryption != null) result.supportsEncryption = supportsEncryption;
    if (encryptionSchemes != null) result.encryptionSchemes.addAll(encryptionSchemes);
    return result;
  }

  AuthMsg._();

  factory AuthMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AuthMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..e<DeviceType>(2, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.OE, defaultOrMaker: DeviceType.UNKNOWN, valueOf: DeviceType.valueOf, enumValues: DeviceType.values)
    ..aOS(3, _omitFieldNames ? '' : 'deviceId')
    ..aOS(4, _omitFieldNames ? '' : 'token')
    ..aInt64(5, _omitFieldNames ? '' : 'tsMs')
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(7, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..aOB(8, _omitFieldNames ? '' : 'resume')
    ..aInt64(9, _omitFieldNames ? '' : 'lastAckId')
    ..aOB(10, _omitFieldNames ? '' : 'supportsEncryption')
    ..pPS(11, _omitFieldNames ? '' : 'encryptionSchemes')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthMsg clone() => AuthMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthMsg copyWith(void Function(AuthMsg) updates) => super.copyWith((message) => updates(message as AuthMsg)) as AuthMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthMsg create() => AuthMsg._();
  @$core.override
  AuthMsg createEmptyInstance() => create();
  static $pb.PbList<AuthMsg> createRepeated() => $pb.PbList<AuthMsg>();
  @$core.pragma('dart2js:noInline')
  static AuthMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthMsg>(create);
  static AuthMsg? _defaultInstance;

  /// 用户唯一 ID（由服务端体系分配）
  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 设备类型（枚举）
  @$pb.TagNumber(2)
  DeviceType get deviceType => $_getN(1);
  @$pb.TagNumber(2)
  set deviceType(DeviceType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceType() => $_clearField(2);

  /// 设备标识（业务自定义，如设备号、推送 token 等）
  @$pb.TagNumber(3)
  $core.String get deviceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceId() => $_clearField(3);

  /// 鉴权令牌（JWT/opaque），用于绑定 user_id 校验
  @$pb.TagNumber(4)
  $core.String get token => $_getSZ(3);
  @$pb.TagNumber(4)
  set token($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearToken() => $_clearField(4);

  /// 客户端时间戳（毫秒），用于时钟漂移/重放保护
  @$pb.TagNumber(5)
  $fixnum.Int64 get tsMs => $_getI64(4);
  @$pb.TagNumber(5)
  set tsMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTsMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearTsMs() => $_clearField(5);

  /// 随机数，结合签名防重放
  @$pb.TagNumber(6)
  $core.List<$core.int> get nonce => $_getN(5);
  @$pb.TagNumber(6)
  set nonce($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNonce() => $_has(5);
  @$pb.TagNumber(6)
  void clearNonce() => $_clearField(6);

  /// 对关键字段的签名/HMAC（例如 HMAC(key, user_id|device_id|ts|nonce|token) ）
  @$pb.TagNumber(7)
  $core.List<$core.int> get signature => $_getN(6);
  @$pb.TagNumber(7)
  set signature($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSignature() => $_has(6);
  @$pb.TagNumber(7)
  void clearSignature() => $_clearField(7);

  /// 是否尝试恢复会话（断线重连）
  @$pb.TagNumber(8)
  $core.bool get resume => $_getBF(7);
  @$pb.TagNumber(8)
  set resume($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasResume() => $_has(7);
  @$pb.TagNumber(8)
  void clearResume() => $_clearField(8);

  /// 客户端已确认的最后一条消息 ID（用于快速补发）
  @$pb.TagNumber(9)
  $fixnum.Int64 get lastAckId => $_getI64(8);
  @$pb.TagNumber(9)
  set lastAckId($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLastAckId() => $_has(8);
  @$pb.TagNumber(9)
  void clearLastAckId() => $_clearField(9);

  /// 能力协商：是否支持端到端加密（仅占位，不影响现有流程）
  @$pb.TagNumber(10)
  $core.bool get supportsEncryption => $_getBF(9);
  @$pb.TagNumber(10)
  set supportsEncryption($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSupportsEncryption() => $_has(9);
  @$pb.TagNumber(10)
  void clearSupportsEncryption() => $_clearField(10);

  /// 支持的加密方案（如 "x25519+chacha20poly1305"）
  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get encryptionSchemes => $_getList(10);
}

/// 客户端上行消息（含 ACK）
class ClientMsg extends $pb.GeneratedMessage {
  factory ClientMsg({
    $fixnum.Int64? ack,
    MsgKind? kind,
    $core.List<$core.int>? payload,
    $fixnum.Int64? clientId,
  }) {
    final result = create();
    if (ack != null) result.ack = ack;
    if (kind != null) result.kind = kind;
    if (payload != null) result.payload = payload;
    if (clientId != null) result.clientId = clientId;
    return result;
  }

  ClientMsg._();

  factory ClientMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ClientMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'ack')
    ..e<MsgKind>(2, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: MsgKind.MK_UNKNOWN, valueOf: MsgKind.valueOf, enumValues: MsgKind.values)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aInt64(5, _omitFieldNames ? '' : 'clientId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientMsg clone() => ClientMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientMsg copyWith(void Function(ClientMsg) updates) => super.copyWith((message) => updates(message as ClientMsg)) as ClientMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientMsg create() => ClientMsg._();
  @$core.override
  ClientMsg createEmptyInstance() => create();
  static $pb.PbList<ClientMsg> createRepeated() => $pb.PbList<ClientMsg>();
  @$core.pragma('dart2js:noInline')
  static ClientMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientMsg>(create);
  static ClientMsg? _defaultInstance;

  /// 若存在，表示对服务端某条 id 的确认
  @$pb.TagNumber(1)
  $fixnum.Int64 get ack => $_getI64(0);
  @$pb.TagNumber(1)
  set ack($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAck() => $_has(0);
  @$pb.TagNumber(1)
  void clearAck() => $_clearField(1);

  /// 业务类型（枚举）
  @$pb.TagNumber(2)
  MsgKind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(MsgKind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  /// 二进制负载（建议为具体业务的 Protobuf）
  @$pb.TagNumber(3)
  $core.List<$core.int> get payload => $_getN(2);
  @$pb.TagNumber(3)
  set payload($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField(3);

  /// 客户端上行幂等ID（用于去重/重试对账），不参与 ACK 语义
  @$pb.TagNumber(5)
  $fixnum.Int64 get clientId => $_getI64(3);
  @$pb.TagNumber(5)
  set clientId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(5)
  $core.bool hasClientId() => $_has(3);
  @$pb.TagNumber(5)
  void clearClientId() => $_clearField(5);
}

/// 服务端下行消息（投递给客户端）
class ServerMsg extends $pb.GeneratedMessage {
  factory ServerMsg({
    $fixnum.Int64? id,
    MsgKind? kind,
    $core.List<$core.int>? payload,
    $fixnum.Int64? tsMs,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (payload != null) result.payload = payload;
    if (tsMs != null) result.tsMs = tsMs;
    return result;
  }

  ServerMsg._();

  factory ServerMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ServerMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ServerMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..e<MsgKind>(2, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: MsgKind.MK_UNKNOWN, valueOf: MsgKind.valueOf, enumValues: MsgKind.values)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aInt64(4, _omitFieldNames ? '' : 'tsMs')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerMsg clone() => ServerMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerMsg copyWith(void Function(ServerMsg) updates) => super.copyWith((message) => updates(message as ServerMsg)) as ServerMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerMsg create() => ServerMsg._();
  @$core.override
  ServerMsg createEmptyInstance() => create();
  static $pb.PbList<ServerMsg> createRepeated() => $pb.PbList<ServerMsg>();
  @$core.pragma('dart2js:noInline')
  static ServerMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServerMsg>(create);
  static ServerMsg? _defaultInstance;

  /// 消息唯一 ID（用于客户端 ACK 对齐）
  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// 业务类型（枚举）
  @$pb.TagNumber(2)
  MsgKind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(MsgKind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  /// 二进制负载（建议为具体业务的 Protobuf）
  @$pb.TagNumber(3)
  $core.List<$core.int> get payload => $_getN(2);
  @$pb.TagNumber(3)
  set payload($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField(3);

  /// 业务时间戳（毫秒）
  @$pb.TagNumber(4)
  $fixnum.Int64 get tsMs => $_getI64(3);
  @$pb.TagNumber(4)
  set tsMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTsMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearTsMs() => $_clearField(4);
}

/// Kafka 投递消息（生产者 → socket 分发）
class KafkaMsg extends $pb.GeneratedMessage {
  factory KafkaMsg({
    $fixnum.Int64? to,
    $fixnum.Int64? id,
    MsgKind? kind,
    $core.List<$core.int>? payload,
    $core.bool? requireAck,
    $fixnum.Int64? expireMs,
    $core.int? maxRetry,
    $fixnum.Int64? tsMs,
  }) {
    final result = create();
    if (to != null) result.to = to;
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (payload != null) result.payload = payload;
    if (requireAck != null) result.requireAck = requireAck;
    if (expireMs != null) result.expireMs = expireMs;
    if (maxRetry != null) result.maxRetry = maxRetry;
    if (tsMs != null) result.tsMs = tsMs;
    return result;
  }

  KafkaMsg._();

  factory KafkaMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory KafkaMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KafkaMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'to')
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..e<MsgKind>(3, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: MsgKind.MK_UNKNOWN, valueOf: MsgKind.valueOf, enumValues: MsgKind.values)
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aOB(5, _omitFieldNames ? '' : 'requireAck')
    ..a<$fixnum.Int64>(6, _omitFieldNames ? '' : 'expireMs', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'maxRetry', $pb.PbFieldType.OU3)
    ..aInt64(8, _omitFieldNames ? '' : 'tsMs')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KafkaMsg clone() => KafkaMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KafkaMsg copyWith(void Function(KafkaMsg) updates) => super.copyWith((message) => updates(message as KafkaMsg)) as KafkaMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KafkaMsg create() => KafkaMsg._();
  @$core.override
  KafkaMsg createEmptyInstance() => create();
  static $pb.PbList<KafkaMsg> createRepeated() => $pb.PbList<KafkaMsg>();
  @$core.pragma('dart2js:noInline')
  static KafkaMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KafkaMsg>(create);
  static KafkaMsg? _defaultInstance;

  /// 目标用户 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get to => $_getI64(0);
  @$pb.TagNumber(1)
  set to($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTo() => $_has(0);
  @$pb.TagNumber(1)
  void clearTo() => $_clearField(1);

  /// 消息唯一 ID（可选；缺省由消费者在接收处生成）
  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  /// 业务类型（枚举）
  @$pb.TagNumber(3)
  MsgKind get kind => $_getN(2);
  @$pb.TagNumber(3)
  set kind(MsgKind value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  /// 二进制负载（建议为具体业务的 Protobuf）
  @$pb.TagNumber(4)
  $core.List<$core.int> get payload => $_getN(3);
  @$pb.TagNumber(4)
  set payload($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayload() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayload() => $_clearField(4);

  /// 是否需要 ACK（缺省 true）
  @$pb.TagNumber(5)
  $core.bool get requireAck => $_getBF(4);
  @$pb.TagNumber(5)
  set requireAck($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRequireAck() => $_has(4);
  @$pb.TagNumber(5)
  void clearRequireAck() => $_clearField(5);

  /// ACK 超时时间（毫秒，缺省 10000）
  @$pb.TagNumber(6)
  $fixnum.Int64 get expireMs => $_getI64(5);
  @$pb.TagNumber(6)
  set expireMs($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExpireMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpireMs() => $_clearField(6);

  /// 最大重试次数（缺省 2）
  @$pb.TagNumber(7)
  $core.int get maxRetry => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxRetry($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxRetry() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxRetry() => $_clearField(7);

  /// 业务时间戳（毫秒；缺省使用 id）
  @$pb.TagNumber(8)
  $fixnum.Int64 get tsMs => $_getI64(7);
  @$pb.TagNumber(8)
  set tsMs($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTsMs() => $_has(7);
  @$pb.TagNumber(8)
  void clearTsMs() => $_clearField(8);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
