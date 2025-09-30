// This is a generated file - do not edit.
//
// Generated from hot_online.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/field_mask.pb.dart' as $1;
import 'hot_online.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'hot_online.pbenum.dart';

class SetOnlineRequest extends $pb.GeneratedMessage {
  factory SetOnlineRequest({
    $fixnum.Int64? userId,
    $core.bool? online,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (online != null) result.online = online;
    return result;
  }

  SetOnlineRequest._();

  factory SetOnlineRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SetOnlineRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetOnlineRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOB(2, _omitFieldNames ? '' : 'online')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetOnlineRequest clone() => SetOnlineRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetOnlineRequest copyWith(void Function(SetOnlineRequest) updates) => super.copyWith((message) => updates(message as SetOnlineRequest)) as SetOnlineRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetOnlineRequest create() => SetOnlineRequest._();
  @$core.override
  SetOnlineRequest createEmptyInstance() => create();
  static $pb.PbList<SetOnlineRequest> createRepeated() => $pb.PbList<SetOnlineRequest>();
  @$core.pragma('dart2js:noInline')
  static SetOnlineRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetOnlineRequest>(create);
  static SetOnlineRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get online => $_getBF(1);
  @$pb.TagNumber(2)
  set online($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOnline() => $_has(1);
  @$pb.TagNumber(2)
  void clearOnline() => $_clearField(2);
}

class SetOnlineResponse extends $pb.GeneratedMessage {
  factory SetOnlineResponse({
    $core.bool? ok,
  }) {
    final result = create();
    if (ok != null) result.ok = ok;
    return result;
  }

  SetOnlineResponse._();

  factory SetOnlineResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SetOnlineResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetOnlineResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetOnlineResponse clone() => SetOnlineResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetOnlineResponse copyWith(void Function(SetOnlineResponse) updates) => super.copyWith((message) => updates(message as SetOnlineResponse)) as SetOnlineResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetOnlineResponse create() => SetOnlineResponse._();
  @$core.override
  SetOnlineResponse createEmptyInstance() => create();
  static $pb.PbList<SetOnlineResponse> createRepeated() => $pb.PbList<SetOnlineResponse>();
  @$core.pragma('dart2js:noInline')
  static SetOnlineResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetOnlineResponse>(create);
  static SetOnlineResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);
}

class CheckOnlineRequest extends $pb.GeneratedMessage {
  factory CheckOnlineRequest({
    $fixnum.Int64? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  CheckOnlineRequest._();

  factory CheckOnlineRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CheckOnlineRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckOnlineRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckOnlineRequest clone() => CheckOnlineRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckOnlineRequest copyWith(void Function(CheckOnlineRequest) updates) => super.copyWith((message) => updates(message as CheckOnlineRequest)) as CheckOnlineRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckOnlineRequest create() => CheckOnlineRequest._();
  @$core.override
  CheckOnlineRequest createEmptyInstance() => create();
  static $pb.PbList<CheckOnlineRequest> createRepeated() => $pb.PbList<CheckOnlineRequest>();
  @$core.pragma('dart2js:noInline')
  static CheckOnlineRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckOnlineRequest>(create);
  static CheckOnlineRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

class CheckOnlineResponse extends $pb.GeneratedMessage {
  factory CheckOnlineResponse({
    $core.bool? online,
  }) {
    final result = create();
    if (online != null) result.online = online;
    return result;
  }

  CheckOnlineResponse._();

  factory CheckOnlineResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CheckOnlineResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckOnlineResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'online')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckOnlineResponse clone() => CheckOnlineResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckOnlineResponse copyWith(void Function(CheckOnlineResponse) updates) => super.copyWith((message) => updates(message as CheckOnlineResponse)) as CheckOnlineResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckOnlineResponse create() => CheckOnlineResponse._();
  @$core.override
  CheckOnlineResponse createEmptyInstance() => create();
  static $pb.PbList<CheckOnlineResponse> createRepeated() => $pb.PbList<CheckOnlineResponse>();
  @$core.pragma('dart2js:noInline')
  static CheckOnlineResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckOnlineResponse>(create);
  static CheckOnlineResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get online => $_getBF(0);
  @$pb.TagNumber(1)
  set online($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOnline() => $_has(0);
  @$pb.TagNumber(1)
  void clearOnline() => $_clearField(1);
}

class CheckOnlineBatchRequest extends $pb.GeneratedMessage {
  factory CheckOnlineBatchRequest({
    $core.Iterable<$fixnum.Int64>? userIds,
  }) {
    final result = create();
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  CheckOnlineBatchRequest._();

  factory CheckOnlineBatchRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CheckOnlineBatchRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckOnlineBatchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'userIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckOnlineBatchRequest clone() => CheckOnlineBatchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckOnlineBatchRequest copyWith(void Function(CheckOnlineBatchRequest) updates) => super.copyWith((message) => updates(message as CheckOnlineBatchRequest)) as CheckOnlineBatchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckOnlineBatchRequest create() => CheckOnlineBatchRequest._();
  @$core.override
  CheckOnlineBatchRequest createEmptyInstance() => create();
  static $pb.PbList<CheckOnlineBatchRequest> createRepeated() => $pb.PbList<CheckOnlineBatchRequest>();
  @$core.pragma('dart2js:noInline')
  static CheckOnlineBatchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckOnlineBatchRequest>(create);
  static CheckOnlineBatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get userIds => $_getList(0);
}

class CheckOnlineBatchResponse extends $pb.GeneratedMessage {
  factory CheckOnlineBatchResponse({
    $core.Iterable<$core.bool>? results,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    return result;
  }

  CheckOnlineBatchResponse._();

  factory CheckOnlineBatchResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CheckOnlineBatchResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckOnlineBatchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..p<$core.bool>(1, _omitFieldNames ? '' : 'results', $pb.PbFieldType.KB)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckOnlineBatchResponse clone() => CheckOnlineBatchResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckOnlineBatchResponse copyWith(void Function(CheckOnlineBatchResponse) updates) => super.copyWith((message) => updates(message as CheckOnlineBatchResponse)) as CheckOnlineBatchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckOnlineBatchResponse create() => CheckOnlineBatchResponse._();
  @$core.override
  CheckOnlineBatchResponse createEmptyInstance() => create();
  static $pb.PbList<CheckOnlineBatchResponse> createRepeated() => $pb.PbList<CheckOnlineBatchResponse>();
  @$core.pragma('dart2js:noInline')
  static CheckOnlineBatchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckOnlineBatchResponse>(create);
  static CheckOnlineBatchResponse? _defaultInstance;

  /// 索引与输入 user_ids 对齐
  @$pb.TagNumber(1)
  $pb.PbList<$core.bool> get results => $_getList(0);
}

class GetStatsRequest extends $pb.GeneratedMessage {
  factory GetStatsRequest() => create();

  GetStatsRequest._();

  factory GetStatsRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetStatsRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStatsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsRequest clone() => GetStatsRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsRequest copyWith(void Function(GetStatsRequest) updates) => super.copyWith((message) => updates(message as GetStatsRequest)) as GetStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatsRequest create() => GetStatsRequest._();
  @$core.override
  GetStatsRequest createEmptyInstance() => create();
  static $pb.PbList<GetStatsRequest> createRepeated() => $pb.PbList<GetStatsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetStatsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStatsRequest>(create);
  static GetStatsRequest? _defaultInstance;
}

class GetStatsResponse extends $pb.GeneratedMessage {
  factory GetStatsResponse({
    $fixnum.Int64? total,
    $core.Iterable<$fixnum.Int64>? perShard,
    $core.int? maxShardIdx,
    $fixnum.Int64? maxShardCount,
  }) {
    final result = create();
    if (total != null) result.total = total;
    if (perShard != null) result.perShard.addAll(perShard);
    if (maxShardIdx != null) result.maxShardIdx = maxShardIdx;
    if (maxShardCount != null) result.maxShardCount = maxShardCount;
    return result;
  }

  GetStatsResponse._();

  factory GetStatsResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetStatsResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStatsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'total', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..p<$fixnum.Int64>(2, _omitFieldNames ? '' : 'perShard', $pb.PbFieldType.KU6)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'maxShardIdx', $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'maxShardCount', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsResponse clone() => GetStatsResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsResponse copyWith(void Function(GetStatsResponse) updates) => super.copyWith((message) => updates(message as GetStatsResponse)) as GetStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatsResponse create() => GetStatsResponse._();
  @$core.override
  GetStatsResponse createEmptyInstance() => create();
  static $pb.PbList<GetStatsResponse> createRepeated() => $pb.PbList<GetStatsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetStatsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStatsResponse>(create);
  static GetStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get total => $_getI64(0);
  @$pb.TagNumber(1)
  set total($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotal() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotal() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get perShard => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get maxShardIdx => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxShardIdx($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxShardIdx() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxShardIdx() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get maxShardCount => $_getI64(3);
  @$pb.TagNumber(4)
  set maxShardCount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxShardCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxShardCount() => $_clearField(4);
}

class UpsertSessionTokenRequest extends $pb.GeneratedMessage {
  factory UpsertSessionTokenRequest({
    $fixnum.Int64? userId,
    DeviceType? deviceType,
    $core.String? deviceId,
    $core.String? loginIp,
    $core.String? userAgent,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceType != null) result.deviceType = deviceType;
    if (deviceId != null) result.deviceId = deviceId;
    if (loginIp != null) result.loginIp = loginIp;
    if (userAgent != null) result.userAgent = userAgent;
    return result;
  }

  UpsertSessionTokenRequest._();

  factory UpsertSessionTokenRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UpsertSessionTokenRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpsertSessionTokenRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..e<DeviceType>(2, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.OE, defaultOrMaker: DeviceType.UNKNOWN, valueOf: DeviceType.valueOf, enumValues: DeviceType.values)
    ..aOS(3, _omitFieldNames ? '' : 'deviceId')
    ..aOS(4, _omitFieldNames ? '' : 'loginIp')
    ..aOS(5, _omitFieldNames ? '' : 'userAgent')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpsertSessionTokenRequest clone() => UpsertSessionTokenRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpsertSessionTokenRequest copyWith(void Function(UpsertSessionTokenRequest) updates) => super.copyWith((message) => updates(message as UpsertSessionTokenRequest)) as UpsertSessionTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpsertSessionTokenRequest create() => UpsertSessionTokenRequest._();
  @$core.override
  UpsertSessionTokenRequest createEmptyInstance() => create();
  static $pb.PbList<UpsertSessionTokenRequest> createRepeated() => $pb.PbList<UpsertSessionTokenRequest>();
  @$core.pragma('dart2js:noInline')
  static UpsertSessionTokenRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpsertSessionTokenRequest>(create);
  static UpsertSessionTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  DeviceType get deviceType => $_getN(1);
  @$pb.TagNumber(2)
  set deviceType(DeviceType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceId() => $_clearField(3);

  /// 可选：客户端上报的登录 IP/UA，便于审计
  @$pb.TagNumber(4)
  $core.String get loginIp => $_getSZ(3);
  @$pb.TagNumber(4)
  set loginIp($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLoginIp() => $_has(3);
  @$pb.TagNumber(4)
  void clearLoginIp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get userAgent => $_getSZ(4);
  @$pb.TagNumber(5)
  set userAgent($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUserAgent() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserAgent() => $_clearField(5);
}

class UpsertSessionTokenResponse extends $pb.GeneratedMessage {
  factory UpsertSessionTokenResponse({
    $core.String? sessionToken,
    $fixnum.Int64? expiresAt,
    $core.String? previousToken,
  }) {
    final result = create();
    if (sessionToken != null) result.sessionToken = sessionToken;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (previousToken != null) result.previousToken = previousToken;
    return result;
  }

  UpsertSessionTokenResponse._();

  factory UpsertSessionTokenResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UpsertSessionTokenResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpsertSessionTokenResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionToken')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'expiresAt', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'previousToken')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpsertSessionTokenResponse clone() => UpsertSessionTokenResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpsertSessionTokenResponse copyWith(void Function(UpsertSessionTokenResponse) updates) => super.copyWith((message) => updates(message as UpsertSessionTokenResponse)) as UpsertSessionTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpsertSessionTokenResponse create() => UpsertSessionTokenResponse._();
  @$core.override
  UpsertSessionTokenResponse createEmptyInstance() => create();
  static $pb.PbList<UpsertSessionTokenResponse> createRepeated() => $pb.PbList<UpsertSessionTokenResponse>();
  @$core.pragma('dart2js:noInline')
  static UpsertSessionTokenResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpsertSessionTokenResponse>(create);
  static UpsertSessionTokenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionToken() => $_clearField(1);

  /// 过期时间（毫秒时间戳）
  @$pb.TagNumber(2)
  $fixnum.Int64 get expiresAt => $_getI64(1);
  @$pb.TagNumber(2)
  set expiresAt($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiresAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresAt() => $_clearField(2);

  /// 若存在旧 token，则返回以便调用方通知下线
  @$pb.TagNumber(3)
  $core.String get previousToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set previousToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPreviousToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearPreviousToken() => $_clearField(3);
}

class ValidateSessionTokenRequest extends $pb.GeneratedMessage {
  factory ValidateSessionTokenRequest({
    $core.String? sessionToken,
  }) {
    final result = create();
    if (sessionToken != null) result.sessionToken = sessionToken;
    return result;
  }

  ValidateSessionTokenRequest._();

  factory ValidateSessionTokenRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ValidateSessionTokenRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateSessionTokenRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionToken')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateSessionTokenRequest clone() => ValidateSessionTokenRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateSessionTokenRequest copyWith(void Function(ValidateSessionTokenRequest) updates) => super.copyWith((message) => updates(message as ValidateSessionTokenRequest)) as ValidateSessionTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateSessionTokenRequest create() => ValidateSessionTokenRequest._();
  @$core.override
  ValidateSessionTokenRequest createEmptyInstance() => create();
  static $pb.PbList<ValidateSessionTokenRequest> createRepeated() => $pb.PbList<ValidateSessionTokenRequest>();
  @$core.pragma('dart2js:noInline')
  static ValidateSessionTokenRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateSessionTokenRequest>(create);
  static ValidateSessionTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionToken() => $_clearField(1);
}

class ValidateSessionTokenResponse extends $pb.GeneratedMessage {
  factory ValidateSessionTokenResponse({
    SessionTokenStatus? status,
    $fixnum.Int64? userId,
    DeviceType? deviceType,
    $core.String? deviceId,
    $fixnum.Int64? expiresAt,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (userId != null) result.userId = userId;
    if (deviceType != null) result.deviceType = deviceType;
    if (deviceId != null) result.deviceId = deviceId;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  ValidateSessionTokenResponse._();

  factory ValidateSessionTokenResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ValidateSessionTokenResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateSessionTokenResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..e<SessionTokenStatus>(1, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: SessionTokenStatus.STS_UNKNOWN, valueOf: SessionTokenStatus.valueOf, enumValues: SessionTokenStatus.values)
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..e<DeviceType>(3, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.OE, defaultOrMaker: DeviceType.UNKNOWN, valueOf: DeviceType.valueOf, enumValues: DeviceType.values)
    ..aOS(4, _omitFieldNames ? '' : 'deviceId')
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'expiresAt', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateSessionTokenResponse clone() => ValidateSessionTokenResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateSessionTokenResponse copyWith(void Function(ValidateSessionTokenResponse) updates) => super.copyWith((message) => updates(message as ValidateSessionTokenResponse)) as ValidateSessionTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateSessionTokenResponse create() => ValidateSessionTokenResponse._();
  @$core.override
  ValidateSessionTokenResponse createEmptyInstance() => create();
  static $pb.PbList<ValidateSessionTokenResponse> createRepeated() => $pb.PbList<ValidateSessionTokenResponse>();
  @$core.pragma('dart2js:noInline')
  static ValidateSessionTokenResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateSessionTokenResponse>(create);
  static ValidateSessionTokenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SessionTokenStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(SessionTokenStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  DeviceType get deviceType => $_getN(2);
  @$pb.TagNumber(3)
  set deviceType(DeviceType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get deviceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get expiresAt => $_getI64(4);
  @$pb.TagNumber(5)
  set expiresAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpiresAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiresAt() => $_clearField(5);
}

class TokenDeviceRef extends $pb.GeneratedMessage {
  factory TokenDeviceRef({
    $fixnum.Int64? userId,
    DeviceType? deviceType,
    $core.String? deviceId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceType != null) result.deviceType = deviceType;
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  TokenDeviceRef._();

  factory TokenDeviceRef.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory TokenDeviceRef.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TokenDeviceRef', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..e<DeviceType>(2, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.OE, defaultOrMaker: DeviceType.UNKNOWN, valueOf: DeviceType.valueOf, enumValues: DeviceType.values)
    ..aOS(3, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenDeviceRef clone() => TokenDeviceRef()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenDeviceRef copyWith(void Function(TokenDeviceRef) updates) => super.copyWith((message) => updates(message as TokenDeviceRef)) as TokenDeviceRef;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenDeviceRef create() => TokenDeviceRef._();
  @$core.override
  TokenDeviceRef createEmptyInstance() => create();
  static $pb.PbList<TokenDeviceRef> createRepeated() => $pb.PbList<TokenDeviceRef>();
  @$core.pragma('dart2js:noInline')
  static TokenDeviceRef getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenDeviceRef>(create);
  static TokenDeviceRef? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  DeviceType get deviceType => $_getN(1);
  @$pb.TagNumber(2)
  set deviceType(DeviceType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceId() => $_clearField(3);
}

enum RevokeSessionTokenRequest_Target {
  sessionToken, 
  device, 
  notSet
}

class RevokeSessionTokenRequest extends $pb.GeneratedMessage {
  factory RevokeSessionTokenRequest({
    $core.String? sessionToken,
    TokenDeviceRef? device,
    $core.String? reason,
  }) {
    final result = create();
    if (sessionToken != null) result.sessionToken = sessionToken;
    if (device != null) result.device = device;
    if (reason != null) result.reason = reason;
    return result;
  }

  RevokeSessionTokenRequest._();

  factory RevokeSessionTokenRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RevokeSessionTokenRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RevokeSessionTokenRequest_Target> _RevokeSessionTokenRequest_TargetByTag = {
    1 : RevokeSessionTokenRequest_Target.sessionToken,
    2 : RevokeSessionTokenRequest_Target.device,
    0 : RevokeSessionTokenRequest_Target.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RevokeSessionTokenRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, _omitFieldNames ? '' : 'sessionToken')
    ..aOM<TokenDeviceRef>(2, _omitFieldNames ? '' : 'device', subBuilder: TokenDeviceRef.create)
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeSessionTokenRequest clone() => RevokeSessionTokenRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeSessionTokenRequest copyWith(void Function(RevokeSessionTokenRequest) updates) => super.copyWith((message) => updates(message as RevokeSessionTokenRequest)) as RevokeSessionTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeSessionTokenRequest create() => RevokeSessionTokenRequest._();
  @$core.override
  RevokeSessionTokenRequest createEmptyInstance() => create();
  static $pb.PbList<RevokeSessionTokenRequest> createRepeated() => $pb.PbList<RevokeSessionTokenRequest>();
  @$core.pragma('dart2js:noInline')
  static RevokeSessionTokenRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevokeSessionTokenRequest>(create);
  static RevokeSessionTokenRequest? _defaultInstance;

  RevokeSessionTokenRequest_Target whichTarget() => _RevokeSessionTokenRequest_TargetByTag[$_whichOneof(0)]!;
  void clearTarget() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get sessionToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionToken() => $_clearField(1);

  @$pb.TagNumber(2)
  TokenDeviceRef get device => $_getN(1);
  @$pb.TagNumber(2)
  set device(TokenDeviceRef value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDevice() => $_has(1);
  @$pb.TagNumber(2)
  void clearDevice() => $_clearField(2);
  @$pb.TagNumber(2)
  TokenDeviceRef ensureDevice() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);
}

class RevokeSessionTokenResponse extends $pb.GeneratedMessage {
  factory RevokeSessionTokenResponse({
    $core.bool? ok,
    $core.String? revokedToken,
  }) {
    final result = create();
    if (ok != null) result.ok = ok;
    if (revokedToken != null) result.revokedToken = revokedToken;
    return result;
  }

  RevokeSessionTokenResponse._();

  factory RevokeSessionTokenResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RevokeSessionTokenResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RevokeSessionTokenResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..aOS(2, _omitFieldNames ? '' : 'revokedToken')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeSessionTokenResponse clone() => RevokeSessionTokenResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeSessionTokenResponse copyWith(void Function(RevokeSessionTokenResponse) updates) => super.copyWith((message) => updates(message as RevokeSessionTokenResponse)) as RevokeSessionTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeSessionTokenResponse create() => RevokeSessionTokenResponse._();
  @$core.override
  RevokeSessionTokenResponse createEmptyInstance() => create();
  static $pb.PbList<RevokeSessionTokenResponse> createRepeated() => $pb.PbList<RevokeSessionTokenResponse>();
  @$core.pragma('dart2js:noInline')
  static RevokeSessionTokenResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevokeSessionTokenResponse>(create);
  static RevokeSessionTokenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get revokedToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set revokedToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevokedToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevokedToken() => $_clearField(2);
}

class TouchSessionTokenRequest extends $pb.GeneratedMessage {
  factory TouchSessionTokenRequest({
    $core.Iterable<$core.String>? sessionTokens,
  }) {
    final result = create();
    if (sessionTokens != null) result.sessionTokens.addAll(sessionTokens);
    return result;
  }

  TouchSessionTokenRequest._();

  factory TouchSessionTokenRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory TouchSessionTokenRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TouchSessionTokenRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'sessionTokens')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchSessionTokenRequest clone() => TouchSessionTokenRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchSessionTokenRequest copyWith(void Function(TouchSessionTokenRequest) updates) => super.copyWith((message) => updates(message as TouchSessionTokenRequest)) as TouchSessionTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TouchSessionTokenRequest create() => TouchSessionTokenRequest._();
  @$core.override
  TouchSessionTokenRequest createEmptyInstance() => create();
  static $pb.PbList<TouchSessionTokenRequest> createRepeated() => $pb.PbList<TouchSessionTokenRequest>();
  @$core.pragma('dart2js:noInline')
  static TouchSessionTokenRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TouchSessionTokenRequest>(create);
  static TouchSessionTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get sessionTokens => $_getList(0);
}

class TouchSessionTokenResponse extends $pb.GeneratedMessage {
  factory TouchSessionTokenResponse({
    $core.int? touched,
  }) {
    final result = create();
    if (touched != null) result.touched = touched;
    return result;
  }

  TouchSessionTokenResponse._();

  factory TouchSessionTokenResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory TouchSessionTokenResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TouchSessionTokenResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'touched', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchSessionTokenResponse clone() => TouchSessionTokenResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchSessionTokenResponse copyWith(void Function(TouchSessionTokenResponse) updates) => super.copyWith((message) => updates(message as TouchSessionTokenResponse)) as TouchSessionTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TouchSessionTokenResponse create() => TouchSessionTokenResponse._();
  @$core.override
  TouchSessionTokenResponse createEmptyInstance() => create();
  static $pb.PbList<TouchSessionTokenResponse> createRepeated() => $pb.PbList<TouchSessionTokenResponse>();
  @$core.pragma('dart2js:noInline')
  static TouchSessionTokenResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TouchSessionTokenResponse>(create);
  static TouchSessionTokenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get touched => $_getIZ(0);
  @$pb.TagNumber(1)
  set touched($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTouched() => $_has(0);
  @$pb.TagNumber(1)
  void clearTouched() => $_clearField(1);
}

class LoginReqMsg extends $pb.GeneratedMessage {
  factory LoginReqMsg({
    $fixnum.Int64? id,
    AuthType? authType,
    $core.String? authContent,
    $core.String? password,
    DeviceType? deviceType,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (authType != null) result.authType = authType;
    if (authContent != null) result.authContent = authContent;
    if (password != null) result.password = password;
    if (deviceType != null) result.deviceType = deviceType;
    return result;
  }

  LoginReqMsg._();

  factory LoginReqMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LoginReqMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginReqMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..e<AuthType>(2, _omitFieldNames ? '' : 'authType', $pb.PbFieldType.OE, defaultOrMaker: AuthType.AUTH_TYPE_UNKNOWN, valueOf: AuthType.valueOf, enumValues: AuthType.values)
    ..aOS(3, _omitFieldNames ? '' : 'authContent')
    ..aOS(4, _omitFieldNames ? '' : 'password')
    ..e<DeviceType>(5, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.OE, defaultOrMaker: DeviceType.UNKNOWN, valueOf: DeviceType.valueOf, enumValues: DeviceType.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginReqMsg clone() => LoginReqMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginReqMsg copyWith(void Function(LoginReqMsg) updates) => super.copyWith((message) => updates(message as LoginReqMsg)) as LoginReqMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginReqMsg create() => LoginReqMsg._();
  @$core.override
  LoginReqMsg createEmptyInstance() => create();
  static $pb.PbList<LoginReqMsg> createRepeated() => $pb.PbList<LoginReqMsg>();
  @$core.pragma('dart2js:noInline')
  static LoginReqMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginReqMsg>(create);
  static LoginReqMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  AuthType get authType => $_getN(1);
  @$pb.TagNumber(2)
  set authType(AuthType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAuthType() => $_has(1);
  @$pb.TagNumber(2)
  void clearAuthType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get authContent => $_getSZ(2);
  @$pb.TagNumber(3)
  set authContent($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAuthContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearAuthContent() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get password => $_getSZ(3);
  @$pb.TagNumber(4)
  set password($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPassword() => $_has(3);
  @$pb.TagNumber(4)
  void clearPassword() => $_clearField(4);

  @$pb.TagNumber(5)
  DeviceType get deviceType => $_getN(4);
  @$pb.TagNumber(5)
  set deviceType(DeviceType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDeviceType() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeviceType() => $_clearField(5);
}

class LoginRespMsg extends $pb.GeneratedMessage {
  factory LoginRespMsg({
    $fixnum.Int64? id,
    $core.String? token,
    $fixnum.Int64? expiresAt,
    $core.bool? success,
    $core.String? msg,
    $fixnum.Int64? uid,
    $core.String? nickname,
    $core.String? avatar,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (token != null) result.token = token;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (success != null) result.success = success;
    if (msg != null) result.msg = msg;
    if (uid != null) result.uid = uid;
    if (nickname != null) result.nickname = nickname;
    if (avatar != null) result.avatar = avatar;
    return result;
  }

  LoginRespMsg._();

  factory LoginRespMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LoginRespMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginRespMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'expiresAt', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(4, _omitFieldNames ? '' : 'success')
    ..aOS(5, _omitFieldNames ? '' : 'msg')
    ..aInt64(6, _omitFieldNames ? '' : 'uid')
    ..aOS(7, _omitFieldNames ? '' : 'nickname')
    ..aOS(8, _omitFieldNames ? '' : 'avatar')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRespMsg clone() => LoginRespMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRespMsg copyWith(void Function(LoginRespMsg) updates) => super.copyWith((message) => updates(message as LoginRespMsg)) as LoginRespMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginRespMsg create() => LoginRespMsg._();
  @$core.override
  LoginRespMsg createEmptyInstance() => create();
  static $pb.PbList<LoginRespMsg> createRepeated() => $pb.PbList<LoginRespMsg>();
  @$core.pragma('dart2js:noInline')
  static LoginRespMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginRespMsg>(create);
  static LoginRespMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expiresAt => $_getI64(2);
  @$pb.TagNumber(3)
  set expiresAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get success => $_getBF(3);
  @$pb.TagNumber(4)
  set success($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSuccess() => $_has(3);
  @$pb.TagNumber(4)
  void clearSuccess() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get msg => $_getSZ(4);
  @$pb.TagNumber(5)
  set msg($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMsg() => $_has(4);
  @$pb.TagNumber(5)
  void clearMsg() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get uid => $_getI64(5);
  @$pb.TagNumber(6)
  set uid($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUid() => $_has(5);
  @$pb.TagNumber(6)
  void clearUid() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get nickname => $_getSZ(6);
  @$pb.TagNumber(7)
  set nickname($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNickname() => $_has(6);
  @$pb.TagNumber(7)
  void clearNickname() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get avatar => $_getSZ(7);
  @$pb.TagNumber(8)
  set avatar($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAvatar() => $_has(7);
  @$pb.TagNumber(8)
  void clearAvatar() => $_clearField(8);
}

class LogoutReqMsg extends $pb.GeneratedMessage {
  factory LogoutReqMsg({
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  LogoutReqMsg._();

  factory LogoutReqMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LogoutReqMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LogoutReqMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutReqMsg clone() => LogoutReqMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutReqMsg copyWith(void Function(LogoutReqMsg) updates) => super.copyWith((message) => updates(message as LogoutReqMsg)) as LogoutReqMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogoutReqMsg create() => LogoutReqMsg._();
  @$core.override
  LogoutReqMsg createEmptyInstance() => create();
  static $pb.PbList<LogoutReqMsg> createRepeated() => $pb.PbList<LogoutReqMsg>();
  @$core.pragma('dart2js:noInline')
  static LogoutReqMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogoutReqMsg>(create);
  static LogoutReqMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class LogoutRespMsg extends $pb.GeneratedMessage {
  factory LogoutRespMsg({
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  LogoutRespMsg._();

  factory LogoutRespMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LogoutRespMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LogoutRespMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutRespMsg clone() => LogoutRespMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutRespMsg copyWith(void Function(LogoutRespMsg) updates) => super.copyWith((message) => updates(message as LogoutRespMsg)) as LogoutRespMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogoutRespMsg create() => LogoutRespMsg._();
  @$core.override
  LogoutRespMsg createEmptyInstance() => create();
  static $pb.PbList<LogoutRespMsg> createRepeated() => $pb.PbList<LogoutRespMsg>();
  @$core.pragma('dart2js:noInline')
  static LogoutRespMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogoutRespMsg>(create);
  static LogoutRespMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class SendVerificationCodeReqMsg extends $pb.GeneratedMessage {
  factory SendVerificationCodeReqMsg({
    $fixnum.Int64? id,
    $core.String? receiver,
    $core.String? channel,
    $core.String? scene,
    $fixnum.Int64? uid,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (receiver != null) result.receiver = receiver;
    if (channel != null) result.channel = channel;
    if (scene != null) result.scene = scene;
    if (uid != null) result.uid = uid;
    return result;
  }

  SendVerificationCodeReqMsg._();

  factory SendVerificationCodeReqMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SendVerificationCodeReqMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendVerificationCodeReqMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'receiver')
    ..aOS(3, _omitFieldNames ? '' : 'channel')
    ..aOS(4, _omitFieldNames ? '' : 'scene')
    ..aInt64(5, _omitFieldNames ? '' : 'uid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendVerificationCodeReqMsg clone() => SendVerificationCodeReqMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendVerificationCodeReqMsg copyWith(void Function(SendVerificationCodeReqMsg) updates) => super.copyWith((message) => updates(message as SendVerificationCodeReqMsg)) as SendVerificationCodeReqMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendVerificationCodeReqMsg create() => SendVerificationCodeReqMsg._();
  @$core.override
  SendVerificationCodeReqMsg createEmptyInstance() => create();
  static $pb.PbList<SendVerificationCodeReqMsg> createRepeated() => $pb.PbList<SendVerificationCodeReqMsg>();
  @$core.pragma('dart2js:noInline')
  static SendVerificationCodeReqMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendVerificationCodeReqMsg>(create);
  static SendVerificationCodeReqMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get receiver => $_getSZ(1);
  @$pb.TagNumber(2)
  set receiver($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReceiver() => $_has(1);
  @$pb.TagNumber(2)
  void clearReceiver() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get channel => $_getSZ(2);
  @$pb.TagNumber(3)
  set channel($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChannel() => $_has(2);
  @$pb.TagNumber(3)
  void clearChannel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get scene => $_getSZ(3);
  @$pb.TagNumber(4)
  set scene($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScene() => $_has(3);
  @$pb.TagNumber(4)
  void clearScene() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get uid => $_getI64(4);
  @$pb.TagNumber(5)
  set uid($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUid() => $_has(4);
  @$pb.TagNumber(5)
  void clearUid() => $_clearField(5);
}

class SendVerificationCodeRepMsg extends $pb.GeneratedMessage {
  factory SendVerificationCodeRepMsg({
    $fixnum.Int64? id,
    $core.bool? success,
    $core.String? message,
    $fixnum.Int64? expiredIn,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (expiredIn != null) result.expiredIn = expiredIn;
    return result;
  }

  SendVerificationCodeRepMsg._();

  factory SendVerificationCodeRepMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SendVerificationCodeRepMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendVerificationCodeRepMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..aInt64(4, _omitFieldNames ? '' : 'expiredIn')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendVerificationCodeRepMsg clone() => SendVerificationCodeRepMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendVerificationCodeRepMsg copyWith(void Function(SendVerificationCodeRepMsg) updates) => super.copyWith((message) => updates(message as SendVerificationCodeRepMsg)) as SendVerificationCodeRepMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendVerificationCodeRepMsg create() => SendVerificationCodeRepMsg._();
  @$core.override
  SendVerificationCodeRepMsg createEmptyInstance() => create();
  static $pb.PbList<SendVerificationCodeRepMsg> createRepeated() => $pb.PbList<SendVerificationCodeRepMsg>();
  @$core.pragma('dart2js:noInline')
  static SendVerificationCodeRepMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendVerificationCodeRepMsg>(create);
  static SendVerificationCodeRepMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get expiredIn => $_getI64(3);
  @$pb.TagNumber(4)
  set expiredIn($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpiredIn() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiredIn() => $_clearField(4);
}

class OnlineStatusMsg extends $pb.GeneratedMessage {
  factory OnlineStatusMsg({
    $fixnum.Int64? id,
    $fixnum.Int64? uid,
    DeviceType? deviceType,
    $fixnum.Int64? clientId,
    $fixnum.Int64? loginTime,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (uid != null) result.uid = uid;
    if (deviceType != null) result.deviceType = deviceType;
    if (clientId != null) result.clientId = clientId;
    if (loginTime != null) result.loginTime = loginTime;
    return result;
  }

  OnlineStatusMsg._();

  factory OnlineStatusMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory OnlineStatusMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OnlineStatusMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'uid')
    ..e<DeviceType>(3, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.OE, defaultOrMaker: DeviceType.UNKNOWN, valueOf: DeviceType.valueOf, enumValues: DeviceType.values)
    ..aInt64(4, _omitFieldNames ? '' : 'clientId')
    ..aInt64(5, _omitFieldNames ? '' : 'loginTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnlineStatusMsg clone() => OnlineStatusMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnlineStatusMsg copyWith(void Function(OnlineStatusMsg) updates) => super.copyWith((message) => updates(message as OnlineStatusMsg)) as OnlineStatusMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OnlineStatusMsg create() => OnlineStatusMsg._();
  @$core.override
  OnlineStatusMsg createEmptyInstance() => create();
  static $pb.PbList<OnlineStatusMsg> createRepeated() => $pb.PbList<OnlineStatusMsg>();
  @$core.pragma('dart2js:noInline')
  static OnlineStatusMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OnlineStatusMsg>(create);
  static OnlineStatusMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get uid => $_getI64(1);
  @$pb.TagNumber(2)
  set uid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearUid() => $_clearField(2);

  @$pb.TagNumber(3)
  DeviceType get deviceType => $_getN(2);
  @$pb.TagNumber(3)
  set deviceType(DeviceType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get clientId => $_getI64(3);
  @$pb.TagNumber(4)
  set clientId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get loginTime => $_getI64(4);
  @$pb.TagNumber(5)
  set loginTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLoginTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearLoginTime() => $_clearField(5);
}

class OfflineStatueMsg extends $pb.GeneratedMessage {
  factory OfflineStatueMsg({
    $fixnum.Int64? id,
    $core.String? uid,
    DeviceType? deviceType,
    $fixnum.Int64? clientId,
    $fixnum.Int64? logoutTime,
    $core.String? reason,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (uid != null) result.uid = uid;
    if (deviceType != null) result.deviceType = deviceType;
    if (clientId != null) result.clientId = clientId;
    if (logoutTime != null) result.logoutTime = logoutTime;
    if (reason != null) result.reason = reason;
    return result;
  }

  OfflineStatueMsg._();

  factory OfflineStatueMsg.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory OfflineStatueMsg.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OfflineStatueMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'uid')
    ..e<DeviceType>(3, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.OE, defaultOrMaker: DeviceType.UNKNOWN, valueOf: DeviceType.valueOf, enumValues: DeviceType.values)
    ..aInt64(4, _omitFieldNames ? '' : 'clientId')
    ..aInt64(5, _omitFieldNames ? '' : 'logoutTime')
    ..aOS(6, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OfflineStatueMsg clone() => OfflineStatueMsg()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OfflineStatueMsg copyWith(void Function(OfflineStatueMsg) updates) => super.copyWith((message) => updates(message as OfflineStatueMsg)) as OfflineStatueMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OfflineStatueMsg create() => OfflineStatueMsg._();
  @$core.override
  OfflineStatueMsg createEmptyInstance() => create();
  static $pb.PbList<OfflineStatueMsg> createRepeated() => $pb.PbList<OfflineStatueMsg>();
  @$core.pragma('dart2js:noInline')
  static OfflineStatueMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OfflineStatueMsg>(create);
  static OfflineStatueMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get uid => $_getSZ(1);
  @$pb.TagNumber(2)
  set uid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearUid() => $_clearField(2);

  @$pb.TagNumber(3)
  DeviceType get deviceType => $_getN(2);
  @$pb.TagNumber(3)
  set deviceType(DeviceType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get clientId => $_getI64(3);
  @$pb.TagNumber(4)
  set clientId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get logoutTime => $_getI64(4);
  @$pb.TagNumber(5)
  set logoutTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLogoutTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearLogoutTime() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get reason => $_getSZ(5);
  @$pb.TagNumber(6)
  set reason($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearReason() => $_clearField(6);
}

class ClientEntity extends $pb.GeneratedMessage {
  factory ClientEntity({
    $fixnum.Int64? id,
    $core.String? password,
    $core.String? name,
    $core.String? email,
    $core.String? phone,
    $core.String? language,
    $core.String? avatar,
    AddFriendPolicy? allowAddFriend,
    Gender? gender,
    UserType? userType,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? profileFields,
    $fixnum.Int64? createTime,
    $fixnum.Int64? updateTime,
    $core.int? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (password != null) result.password = password;
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (language != null) result.language = language;
    if (avatar != null) result.avatar = avatar;
    if (allowAddFriend != null) result.allowAddFriend = allowAddFriend;
    if (gender != null) result.gender = gender;
    if (userType != null) result.userType = userType;
    if (profileFields != null) result.profileFields.addEntries(profileFields);
    if (createTime != null) result.createTime = createTime;
    if (updateTime != null) result.updateTime = updateTime;
    if (version != null) result.version = version;
    return result;
  }

  ClientEntity._();

  factory ClientEntity.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ClientEntity.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientEntity', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'email')
    ..aOS(5, _omitFieldNames ? '' : 'phone')
    ..aOS(6, _omitFieldNames ? '' : 'language')
    ..aOS(7, _omitFieldNames ? '' : 'avatar')
    ..e<AddFriendPolicy>(8, _omitFieldNames ? '' : 'allowAddFriend', $pb.PbFieldType.OE, defaultOrMaker: AddFriendPolicy.ADD_FRIEND_UNSPECIFIED, valueOf: AddFriendPolicy.valueOf, enumValues: AddFriendPolicy.values)
    ..e<Gender>(9, _omitFieldNames ? '' : 'gender', $pb.PbFieldType.OE, defaultOrMaker: Gender.GENDER_UNSPECIFIED, valueOf: Gender.valueOf, enumValues: Gender.values)
    ..e<UserType>(10, _omitFieldNames ? '' : 'userType', $pb.PbFieldType.OE, defaultOrMaker: UserType.USER_TYPE_UNSPECIFIED, valueOf: UserType.valueOf, enumValues: UserType.values)
    ..m<$core.String, $core.String>(11, _omitFieldNames ? '' : 'profileFields', entryClassName: 'ClientEntity.ProfileFieldsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('online_service'))
    ..aInt64(12, _omitFieldNames ? '' : 'createTime')
    ..aInt64(13, _omitFieldNames ? '' : 'updateTime')
    ..a<$core.int>(14, _omitFieldNames ? '' : 'version', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientEntity clone() => ClientEntity()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientEntity copyWith(void Function(ClientEntity) updates) => super.copyWith((message) => updates(message as ClientEntity)) as ClientEntity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientEntity create() => ClientEntity._();
  @$core.override
  ClientEntity createEmptyInstance() => create();
  static $pb.PbList<ClientEntity> createRepeated() => $pb.PbList<ClientEntity>();
  @$core.pragma('dart2js:noInline')
  static ClientEntity getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientEntity>(create);
  static ClientEntity? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get email => $_getSZ(3);
  @$pb.TagNumber(4)
  set email($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmail() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmail() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get phone => $_getSZ(4);
  @$pb.TagNumber(5)
  set phone($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPhone() => $_has(4);
  @$pb.TagNumber(5)
  void clearPhone() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get language => $_getSZ(5);
  @$pb.TagNumber(6)
  set language($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLanguage() => $_has(5);
  @$pb.TagNumber(6)
  void clearLanguage() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get avatar => $_getSZ(6);
  @$pb.TagNumber(7)
  set avatar($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAvatar() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvatar() => $_clearField(7);

  @$pb.TagNumber(8)
  AddFriendPolicy get allowAddFriend => $_getN(7);
  @$pb.TagNumber(8)
  set allowAddFriend(AddFriendPolicy value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasAllowAddFriend() => $_has(7);
  @$pb.TagNumber(8)
  void clearAllowAddFriend() => $_clearField(8);

  @$pb.TagNumber(9)
  Gender get gender => $_getN(8);
  @$pb.TagNumber(9)
  set gender(Gender value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasGender() => $_has(8);
  @$pb.TagNumber(9)
  void clearGender() => $_clearField(9);

  @$pb.TagNumber(10)
  UserType get userType => $_getN(9);
  @$pb.TagNumber(10)
  set userType(UserType value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasUserType() => $_has(9);
  @$pb.TagNumber(10)
  void clearUserType() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbMap<$core.String, $core.String> get profileFields => $_getMap(10);

  @$pb.TagNumber(12)
  $fixnum.Int64 get createTime => $_getI64(11);
  @$pb.TagNumber(12)
  set createTime($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCreateTime() => $_has(11);
  @$pb.TagNumber(12)
  void clearCreateTime() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get updateTime => $_getI64(12);
  @$pb.TagNumber(13)
  set updateTime($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasUpdateTime() => $_has(12);
  @$pb.TagNumber(13)
  void clearUpdateTime() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get version => $_getIZ(13);
  @$pb.TagNumber(14)
  set version($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasVersion() => $_has(13);
  @$pb.TagNumber(14)
  void clearVersion() => $_clearField(14);
}

class FindClientDto extends $pb.GeneratedMessage {
  factory FindClientDto({
    ClientEntity? client,
  }) {
    final result = create();
    if (client != null) result.client = client;
    return result;
  }

  FindClientDto._();

  factory FindClientDto.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FindClientDto.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FindClientDto', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aOM<ClientEntity>(1, _omitFieldNames ? '' : 'client', subBuilder: ClientEntity.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FindClientDto clone() => FindClientDto()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FindClientDto copyWith(void Function(FindClientDto) updates) => super.copyWith((message) => updates(message as FindClientDto)) as FindClientDto;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FindClientDto create() => FindClientDto._();
  @$core.override
  FindClientDto createEmptyInstance() => create();
  static $pb.PbList<FindClientDto> createRepeated() => $pb.PbList<FindClientDto>();
  @$core.pragma('dart2js:noInline')
  static FindClientDto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FindClientDto>(create);
  static FindClientDto? _defaultInstance;

  @$pb.TagNumber(1)
  ClientEntity get client => $_getN(0);
  @$pb.TagNumber(1)
  set client(ClientEntity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasClient() => $_has(0);
  @$pb.TagNumber(1)
  void clearClient() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientEntity ensureClient() => $_ensure(0);
}

class RegisterUserReq extends $pb.GeneratedMessage {
  factory RegisterUserReq({
    $core.String? name,
    $core.String? password,
    $core.String? email,
    $core.String? phone,
    $core.String? language,
    $core.String? avatar,
    AddFriendPolicy? allowAddFriend,
    Gender? gender,
    UserType? userType,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? profileFields,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (password != null) result.password = password;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (language != null) result.language = language;
    if (avatar != null) result.avatar = avatar;
    if (allowAddFriend != null) result.allowAddFriend = allowAddFriend;
    if (gender != null) result.gender = gender;
    if (userType != null) result.userType = userType;
    if (profileFields != null) result.profileFields.addEntries(profileFields);
    return result;
  }

  RegisterUserReq._();

  factory RegisterUserReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RegisterUserReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterUserReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..aOS(4, _omitFieldNames ? '' : 'email')
    ..aOS(5, _omitFieldNames ? '' : 'phone')
    ..aOS(6, _omitFieldNames ? '' : 'language')
    ..aOS(7, _omitFieldNames ? '' : 'avatar')
    ..e<AddFriendPolicy>(8, _omitFieldNames ? '' : 'allowAddFriend', $pb.PbFieldType.OE, defaultOrMaker: AddFriendPolicy.ADD_FRIEND_UNSPECIFIED, valueOf: AddFriendPolicy.valueOf, enumValues: AddFriendPolicy.values)
    ..e<Gender>(9, _omitFieldNames ? '' : 'gender', $pb.PbFieldType.OE, defaultOrMaker: Gender.GENDER_UNSPECIFIED, valueOf: Gender.valueOf, enumValues: Gender.values)
    ..e<UserType>(10, _omitFieldNames ? '' : 'userType', $pb.PbFieldType.OE, defaultOrMaker: UserType.USER_TYPE_UNSPECIFIED, valueOf: UserType.valueOf, enumValues: UserType.values)
    ..m<$core.String, $core.String>(11, _omitFieldNames ? '' : 'profileFields', entryClassName: 'RegisterUserReq.ProfileFieldsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('online_service'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterUserReq clone() => RegisterUserReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterUserReq copyWith(void Function(RegisterUserReq) updates) => super.copyWith((message) => updates(message as RegisterUserReq)) as RegisterUserReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterUserReq create() => RegisterUserReq._();
  @$core.override
  RegisterUserReq createEmptyInstance() => create();
  static $pb.PbList<RegisterUserReq> createRepeated() => $pb.PbList<RegisterUserReq>();
  @$core.pragma('dart2js:noInline')
  static RegisterUserReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegisterUserReq>(create);
  static RegisterUserReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  @$pb.TagNumber(4)
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(4)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(4)
  void clearEmail() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get phone => $_getSZ(3);
  @$pb.TagNumber(5)
  set phone($core.String value) => $_setString(3, value);
  @$pb.TagNumber(5)
  $core.bool hasPhone() => $_has(3);
  @$pb.TagNumber(5)
  void clearPhone() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get language => $_getSZ(4);
  @$pb.TagNumber(6)
  set language($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6)
  $core.bool hasLanguage() => $_has(4);
  @$pb.TagNumber(6)
  void clearLanguage() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get avatar => $_getSZ(5);
  @$pb.TagNumber(7)
  set avatar($core.String value) => $_setString(5, value);
  @$pb.TagNumber(7)
  $core.bool hasAvatar() => $_has(5);
  @$pb.TagNumber(7)
  void clearAvatar() => $_clearField(7);

  @$pb.TagNumber(8)
  AddFriendPolicy get allowAddFriend => $_getN(6);
  @$pb.TagNumber(8)
  set allowAddFriend(AddFriendPolicy value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasAllowAddFriend() => $_has(6);
  @$pb.TagNumber(8)
  void clearAllowAddFriend() => $_clearField(8);

  @$pb.TagNumber(9)
  Gender get gender => $_getN(7);
  @$pb.TagNumber(9)
  set gender(Gender value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasGender() => $_has(7);
  @$pb.TagNumber(9)
  void clearGender() => $_clearField(9);

  @$pb.TagNumber(10)
  UserType get userType => $_getN(8);
  @$pb.TagNumber(10)
  set userType(UserType value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasUserType() => $_has(8);
  @$pb.TagNumber(10)
  void clearUserType() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbMap<$core.String, $core.String> get profileFields => $_getMap(9);
}

class ChangePasswordReq extends $pb.GeneratedMessage {
  factory ChangePasswordReq({
    $fixnum.Int64? id,
    $core.String? oldPassword,
    $core.String? newPassword,
    $core.String? verifyToken,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (oldPassword != null) result.oldPassword = oldPassword;
    if (newPassword != null) result.newPassword = newPassword;
    if (verifyToken != null) result.verifyToken = verifyToken;
    return result;
  }

  ChangePasswordReq._();

  factory ChangePasswordReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangePasswordReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePasswordReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'oldPassword')
    ..aOS(3, _omitFieldNames ? '' : 'newPassword')
    ..aOS(4, _omitFieldNames ? '' : 'verifyToken')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordReq clone() => ChangePasswordReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordReq copyWith(void Function(ChangePasswordReq) updates) => super.copyWith((message) => updates(message as ChangePasswordReq)) as ChangePasswordReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePasswordReq create() => ChangePasswordReq._();
  @$core.override
  ChangePasswordReq createEmptyInstance() => create();
  static $pb.PbList<ChangePasswordReq> createRepeated() => $pb.PbList<ChangePasswordReq>();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangePasswordReq>(create);
  static ChangePasswordReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get oldPassword => $_getSZ(1);
  @$pb.TagNumber(2)
  set oldPassword($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOldPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearOldPassword() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get newPassword => $_getSZ(2);
  @$pb.TagNumber(3)
  set newPassword($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewPassword() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get verifyToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set verifyToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVerifyToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearVerifyToken() => $_clearField(4);
}

class ChangePhoneReq extends $pb.GeneratedMessage {
  factory ChangePhoneReq({
    $fixnum.Int64? id,
    $core.String? newPhone,
    $core.String? verifyToken,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (newPhone != null) result.newPhone = newPhone;
    if (verifyToken != null) result.verifyToken = verifyToken;
    return result;
  }

  ChangePhoneReq._();

  factory ChangePhoneReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangePhoneReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePhoneReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'newPhone')
    ..aOS(3, _omitFieldNames ? '' : 'verifyToken')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePhoneReq clone() => ChangePhoneReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePhoneReq copyWith(void Function(ChangePhoneReq) updates) => super.copyWith((message) => updates(message as ChangePhoneReq)) as ChangePhoneReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePhoneReq create() => ChangePhoneReq._();
  @$core.override
  ChangePhoneReq createEmptyInstance() => create();
  static $pb.PbList<ChangePhoneReq> createRepeated() => $pb.PbList<ChangePhoneReq>();
  @$core.pragma('dart2js:noInline')
  static ChangePhoneReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangePhoneReq>(create);
  static ChangePhoneReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get newPhone => $_getSZ(1);
  @$pb.TagNumber(2)
  set newPhone($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewPhone() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewPhone() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get verifyToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set verifyToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVerifyToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerifyToken() => $_clearField(3);
}

class ChangeEmailReq extends $pb.GeneratedMessage {
  factory ChangeEmailReq({
    $fixnum.Int64? id,
    $core.String? newEmail,
    $core.String? verifyToken,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (newEmail != null) result.newEmail = newEmail;
    if (verifyToken != null) result.verifyToken = verifyToken;
    return result;
  }

  ChangeEmailReq._();

  factory ChangeEmailReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangeEmailReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangeEmailReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'newEmail')
    ..aOS(3, _omitFieldNames ? '' : 'verifyToken')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeEmailReq clone() => ChangeEmailReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeEmailReq copyWith(void Function(ChangeEmailReq) updates) => super.copyWith((message) => updates(message as ChangeEmailReq)) as ChangeEmailReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeEmailReq create() => ChangeEmailReq._();
  @$core.override
  ChangeEmailReq createEmptyInstance() => create();
  static $pb.PbList<ChangeEmailReq> createRepeated() => $pb.PbList<ChangeEmailReq>();
  @$core.pragma('dart2js:noInline')
  static ChangeEmailReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangeEmailReq>(create);
  static ChangeEmailReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get newEmail => $_getSZ(1);
  @$pb.TagNumber(2)
  set newEmail($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewEmail() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewEmail() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get verifyToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set verifyToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVerifyToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerifyToken() => $_clearField(3);
}

class UpdateClientReq extends $pb.GeneratedMessage {
  factory UpdateClientReq({
    ClientEntity? patch,
    $1.FieldMask? updateMask,
  }) {
    final result = create();
    if (patch != null) result.patch = patch;
    if (updateMask != null) result.updateMask = updateMask;
    return result;
  }

  UpdateClientReq._();

  factory UpdateClientReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UpdateClientReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateClientReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aOM<ClientEntity>(1, _omitFieldNames ? '' : 'patch', subBuilder: ClientEntity.create)
    ..aOM<$1.FieldMask>(2, _omitFieldNames ? '' : 'updateMask', subBuilder: $1.FieldMask.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateClientReq clone() => UpdateClientReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateClientReq copyWith(void Function(UpdateClientReq) updates) => super.copyWith((message) => updates(message as UpdateClientReq)) as UpdateClientReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateClientReq create() => UpdateClientReq._();
  @$core.override
  UpdateClientReq createEmptyInstance() => create();
  static $pb.PbList<UpdateClientReq> createRepeated() => $pb.PbList<UpdateClientReq>();
  @$core.pragma('dart2js:noInline')
  static UpdateClientReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateClientReq>(create);
  static UpdateClientReq? _defaultInstance;

  @$pb.TagNumber(1)
  ClientEntity get patch => $_getN(0);
  @$pb.TagNumber(1)
  set patch(ClientEntity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPatch() => $_has(0);
  @$pb.TagNumber(1)
  void clearPatch() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientEntity ensurePatch() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($1.FieldMask value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.FieldMask ensureUpdateMask() => $_ensure(1);
}

class GetClientReq extends $pb.GeneratedMessage {
  factory GetClientReq({
    $fixnum.Int64? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetClientReq._();

  factory GetClientReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetClientReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetClientReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetClientReq clone() => GetClientReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetClientReq copyWith(void Function(GetClientReq) updates) => super.copyWith((message) => updates(message as GetClientReq)) as GetClientReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetClientReq create() => GetClientReq._();
  @$core.override
  GetClientReq createEmptyInstance() => create();
  static $pb.PbList<GetClientReq> createRepeated() => $pb.PbList<GetClientReq>();
  @$core.pragma('dart2js:noInline')
  static GetClientReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetClientReq>(create);
  static GetClientReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ChangeResponse extends $pb.GeneratedMessage {
  factory ChangeResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  ChangeResponse._();

  factory ChangeResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangeResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeResponse clone() => ChangeResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeResponse copyWith(void Function(ChangeResponse) updates) => super.copyWith((message) => updates(message as ChangeResponse)) as ChangeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeResponse create() => ChangeResponse._();
  @$core.override
  ChangeResponse createEmptyInstance() => create();
  static $pb.PbList<ChangeResponse> createRepeated() => $pb.PbList<ChangeResponse>();
  @$core.pragma('dart2js:noInline')
  static ChangeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangeResponse>(create);
  static ChangeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class FindByContentReq extends $pb.GeneratedMessage {
  factory FindByContentReq({
    $core.String? content,
  }) {
    final result = create();
    if (content != null) result.content = content;
    return result;
  }

  FindByContentReq._();

  factory FindByContentReq.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FindByContentReq.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FindByContentReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'online_service'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'content')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FindByContentReq clone() => FindByContentReq()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FindByContentReq copyWith(void Function(FindByContentReq) updates) => super.copyWith((message) => updates(message as FindByContentReq)) as FindByContentReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FindByContentReq create() => FindByContentReq._();
  @$core.override
  FindByContentReq createEmptyInstance() => create();
  static $pb.PbList<FindByContentReq> createRepeated() => $pb.PbList<FindByContentReq>();
  @$core.pragma('dart2js:noInline')
  static FindByContentReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FindByContentReq>(create);
  static FindByContentReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get content => $_getSZ(0);
  @$pb.TagNumber(1)
  set content($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
