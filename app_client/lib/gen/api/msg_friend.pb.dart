// This is a generated file - do not edit.
//
// Generated from msg_friend.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'msg_friend.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'msg_friend.pbenum.dart';

/// 好友申请
class FriendRequest extends $pb.GeneratedMessage {
  factory FriendRequest({
    $fixnum.Int64? id,
    $fixnum.Int64? fromUserId,
    $fixnum.Int64? toUserId,
    $core.String? reason,
    FriendRequestSource? source,
    $fixnum.Int64? createdAt,
    $core.String? remark,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (toUserId != null) result.toUserId = toUserId;
    if (reason != null) result.reason = reason;
    if (source != null) result.source = source;
    if (createdAt != null) result.createdAt = createdAt;
    if (remark != null) result.remark = remark;
    return result;
  }

  FriendRequest._();

  factory FriendRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FriendRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FriendRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'fromUserId')
    ..aInt64(3, _omitFieldNames ? '' : 'toUserId')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..e<FriendRequestSource>(5, _omitFieldNames ? '' : 'source', $pb.PbFieldType.OE, defaultOrMaker: FriendRequestSource.FRS_UNKNOWN, valueOf: FriendRequestSource.valueOf, enumValues: FriendRequestSource.values)
    ..aInt64(6, _omitFieldNames ? '' : 'createdAt')
    ..aOS(7, _omitFieldNames ? '' : 'remark')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendRequest clone() => FriendRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendRequest copyWith(void Function(FriendRequest) updates) => super.copyWith((message) => updates(message as FriendRequest)) as FriendRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FriendRequest create() => FriendRequest._();
  @$core.override
  FriendRequest createEmptyInstance() => create();
  static $pb.PbList<FriendRequest> createRepeated() => $pb.PbList<FriendRequest>();
  @$core.pragma('dart2js:noInline')
  static FriendRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendRequest>(create);
  static FriendRequest? _defaultInstance;

  /// 好友申请ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// 申请人用户ID
  @$pb.TagNumber(2)
  $fixnum.Int64 get fromUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set fromUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromUserId() => $_clearField(2);

  /// 被申请人用户ID
  @$pb.TagNumber(3)
  $fixnum.Int64 get toUserId => $_getI64(2);
  @$pb.TagNumber(3)
  set toUserId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearToUserId() => $_clearField(3);

  /// 申请理由
  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);

  /// 申请来源
  @$pb.TagNumber(5)
  FriendRequestSource get source => $_getN(4);
  @$pb.TagNumber(5)
  set source(FriendRequestSource value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSource() => $_has(4);
  @$pb.TagNumber(5)
  void clearSource() => $_clearField(5);

  /// 申请创建时间
  @$pb.TagNumber(6)
  $fixnum.Int64 get createdAt => $_getI64(5);
  @$pb.TagNumber(6)
  set createdAt($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);

  /// 好友别名/备注（可选）
  @$pb.TagNumber(7)
  $core.String get remark => $_getSZ(6);
  @$pb.TagNumber(7)
  set remark($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRemark() => $_has(6);
  @$pb.TagNumber(7)
  void clearRemark() => $_clearField(7);
}

/// 处理好友申请（接受/拒绝）
class FriendRequestDecision extends $pb.GeneratedMessage {
  factory FriendRequestDecision({
    $fixnum.Int64? requestId,
    $core.bool? accept,
    $core.String? remark,
    $fixnum.Int64? decidedAt,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (accept != null) result.accept = accept;
    if (remark != null) result.remark = remark;
    if (decidedAt != null) result.decidedAt = decidedAt;
    return result;
  }

  FriendRequestDecision._();

  factory FriendRequestDecision.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FriendRequestDecision.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FriendRequestDecision', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'requestId')
    ..aOB(2, _omitFieldNames ? '' : 'accept')
    ..aOS(3, _omitFieldNames ? '' : 'remark')
    ..aInt64(4, _omitFieldNames ? '' : 'decidedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendRequestDecision clone() => FriendRequestDecision()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendRequestDecision copyWith(void Function(FriendRequestDecision) updates) => super.copyWith((message) => updates(message as FriendRequestDecision)) as FriendRequestDecision;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FriendRequestDecision create() => FriendRequestDecision._();
  @$core.override
  FriendRequestDecision createEmptyInstance() => create();
  static $pb.PbList<FriendRequestDecision> createRepeated() => $pb.PbList<FriendRequestDecision>();
  @$core.pragma('dart2js:noInline')
  static FriendRequestDecision getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendRequestDecision>(create);
  static FriendRequestDecision? _defaultInstance;

  /// 好友申请ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get requestId => $_getI64(0);
  @$pb.TagNumber(1)
  set requestId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// 是否接受
  @$pb.TagNumber(2)
  $core.bool get accept => $_getBF(1);
  @$pb.TagNumber(2)
  set accept($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccept() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccept() => $_clearField(2);

  /// 备注（可选）
  @$pb.TagNumber(3)
  $core.String get remark => $_getSZ(2);
  @$pb.TagNumber(3)
  set remark($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRemark() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemark() => $_clearField(3);

  /// 处理时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get decidedAt => $_getI64(3);
  @$pb.TagNumber(4)
  set decidedAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDecidedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearDecidedAt() => $_clearField(4);
}

/// 删除好友
class FriendDelete extends $pb.GeneratedMessage {
  factory FriendDelete({
    $fixnum.Int64? operatorUserId,
    $fixnum.Int64? friendUserId,
    $fixnum.Int64? at,
  }) {
    final result = create();
    if (operatorUserId != null) result.operatorUserId = operatorUserId;
    if (friendUserId != null) result.friendUserId = friendUserId;
    if (at != null) result.at = at;
    return result;
  }

  FriendDelete._();

  factory FriendDelete.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FriendDelete.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FriendDelete', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'operatorUserId')
    ..aInt64(2, _omitFieldNames ? '' : 'friendUserId')
    ..aInt64(3, _omitFieldNames ? '' : 'at')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendDelete clone() => FriendDelete()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendDelete copyWith(void Function(FriendDelete) updates) => super.copyWith((message) => updates(message as FriendDelete)) as FriendDelete;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FriendDelete create() => FriendDelete._();
  @$core.override
  FriendDelete createEmptyInstance() => create();
  static $pb.PbList<FriendDelete> createRepeated() => $pb.PbList<FriendDelete>();
  @$core.pragma('dart2js:noInline')
  static FriendDelete getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendDelete>(create);
  static FriendDelete? _defaultInstance;

  /// 发起人用户ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get operatorUserId => $_getI64(0);
  @$pb.TagNumber(1)
  set operatorUserId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOperatorUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperatorUserId() => $_clearField(1);

  /// 被删除的好友用户ID
  @$pb.TagNumber(2)
  $fixnum.Int64 get friendUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set friendUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFriendUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFriendUserId() => $_clearField(2);

  /// 时间
  @$pb.TagNumber(3)
  $fixnum.Int64 get at => $_getI64(2);
  @$pb.TagNumber(3)
  set at($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearAt() => $_clearField(3);
}

/// 更新好友备注
class FriendUpdateRemark extends $pb.GeneratedMessage {
  factory FriendUpdateRemark({
    $fixnum.Int64? userId,
    $fixnum.Int64? friendUserId,
    $core.String? remark,
    $fixnum.Int64? updatedAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (friendUserId != null) result.friendUserId = friendUserId;
    if (remark != null) result.remark = remark;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  FriendUpdateRemark._();

  factory FriendUpdateRemark.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FriendUpdateRemark.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FriendUpdateRemark', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'friendUserId')
    ..aOS(3, _omitFieldNames ? '' : 'remark')
    ..aInt64(4, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendUpdateRemark clone() => FriendUpdateRemark()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendUpdateRemark copyWith(void Function(FriendUpdateRemark) updates) => super.copyWith((message) => updates(message as FriendUpdateRemark)) as FriendUpdateRemark;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FriendUpdateRemark create() => FriendUpdateRemark._();
  @$core.override
  FriendUpdateRemark createEmptyInstance() => create();
  static $pb.PbList<FriendUpdateRemark> createRepeated() => $pb.PbList<FriendUpdateRemark>();
  @$core.pragma('dart2js:noInline')
  static FriendUpdateRemark getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendUpdateRemark>(create);
  static FriendUpdateRemark? _defaultInstance;

  /// 用户ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 好友用户ID
  @$pb.TagNumber(2)
  $fixnum.Int64 get friendUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set friendUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFriendUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFriendUserId() => $_clearField(2);

  /// 新备注
  @$pb.TagNumber(3)
  $core.String get remark => $_getSZ(2);
  @$pb.TagNumber(3)
  set remark($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRemark() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemark() => $_clearField(3);

  /// 时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get updatedAt => $_getI64(3);
  @$pb.TagNumber(4)
  set updatedAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdatedAt() => $_clearField(4);
}

/// 最小设备密钥 RPC（密钥托管与分发）
class IdentityKey extends $pb.GeneratedMessage {
  factory IdentityKey({
    $core.String? curve,
    $core.List<$core.int>? pubKey,
  }) {
    final result = create();
    if (curve != null) result.curve = curve;
    if (pubKey != null) result.pubKey = pubKey;
    return result;
  }

  IdentityKey._();

  factory IdentityKey.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory IdentityKey.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'IdentityKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'curve')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'pubKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentityKey clone() => IdentityKey()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentityKey copyWith(void Function(IdentityKey) updates) => super.copyWith((message) => updates(message as IdentityKey)) as IdentityKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IdentityKey create() => IdentityKey._();
  @$core.override
  IdentityKey createEmptyInstance() => create();
  static $pb.PbList<IdentityKey> createRepeated() => $pb.PbList<IdentityKey>();
  @$core.pragma('dart2js:noInline')
  static IdentityKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IdentityKey>(create);
  static IdentityKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get curve => $_getSZ(0);
  @$pb.TagNumber(1)
  set curve($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCurve() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurve() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get pubKey => $_getN(1);
  @$pb.TagNumber(2)
  set pubKey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPubKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearPubKey() => $_clearField(2);
}

class SignedPreKey extends $pb.GeneratedMessage {
  factory SignedPreKey({
    $core.int? keyId,
    $core.List<$core.int>? pubKey,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (keyId != null) result.keyId = keyId;
    if (pubKey != null) result.pubKey = pubKey;
    if (signature != null) result.signature = signature;
    return result;
  }

  SignedPreKey._();

  factory SignedPreKey.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SignedPreKey.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignedPreKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'keyId', $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'pubKey', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignedPreKey clone() => SignedPreKey()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignedPreKey copyWith(void Function(SignedPreKey) updates) => super.copyWith((message) => updates(message as SignedPreKey)) as SignedPreKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignedPreKey create() => SignedPreKey._();
  @$core.override
  SignedPreKey createEmptyInstance() => create();
  static $pb.PbList<SignedPreKey> createRepeated() => $pb.PbList<SignedPreKey>();
  @$core.pragma('dart2js:noInline')
  static SignedPreKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignedPreKey>(create);
  static SignedPreKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get keyId => $_getIZ(0);
  @$pb.TagNumber(1)
  set keyId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKeyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get pubKey => $_getN(1);
  @$pb.TagNumber(2)
  set pubKey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPubKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearPubKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get signature => $_getN(2);
  @$pb.TagNumber(3)
  set signature($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSignature() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignature() => $_clearField(3);
}

class OneTimePreKey extends $pb.GeneratedMessage {
  factory OneTimePreKey({
    $core.int? keyId,
    $core.List<$core.int>? pubKey,
  }) {
    final result = create();
    if (keyId != null) result.keyId = keyId;
    if (pubKey != null) result.pubKey = pubKey;
    return result;
  }

  OneTimePreKey._();

  factory OneTimePreKey.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory OneTimePreKey.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OneTimePreKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'keyId', $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'pubKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OneTimePreKey clone() => OneTimePreKey()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OneTimePreKey copyWith(void Function(OneTimePreKey) updates) => super.copyWith((message) => updates(message as OneTimePreKey)) as OneTimePreKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OneTimePreKey create() => OneTimePreKey._();
  @$core.override
  OneTimePreKey createEmptyInstance() => create();
  static $pb.PbList<OneTimePreKey> createRepeated() => $pb.PbList<OneTimePreKey>();
  @$core.pragma('dart2js:noInline')
  static OneTimePreKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OneTimePreKey>(create);
  static OneTimePreKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get keyId => $_getIZ(0);
  @$pb.TagNumber(1)
  set keyId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKeyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get pubKey => $_getN(1);
  @$pb.TagNumber(2)
  set pubKey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPubKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearPubKey() => $_clearField(2);
}

class UploadDeviceKeysRequest extends $pb.GeneratedMessage {
  factory UploadDeviceKeysRequest({
    $fixnum.Int64? userId,
    $core.String? deviceId,
    IdentityKey? identityKey,
    SignedPreKey? signedPreKey,
    $core.Iterable<OneTimePreKey>? oneTimePreKeys,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (identityKey != null) result.identityKey = identityKey;
    if (signedPreKey != null) result.signedPreKey = signedPreKey;
    if (oneTimePreKeys != null) result.oneTimePreKeys.addAll(oneTimePreKeys);
    return result;
  }

  UploadDeviceKeysRequest._();

  factory UploadDeviceKeysRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UploadDeviceKeysRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UploadDeviceKeysRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOM<IdentityKey>(3, _omitFieldNames ? '' : 'identityKey', subBuilder: IdentityKey.create)
    ..aOM<SignedPreKey>(4, _omitFieldNames ? '' : 'signedPreKey', subBuilder: SignedPreKey.create)
    ..pc<OneTimePreKey>(5, _omitFieldNames ? '' : 'oneTimePreKeys', $pb.PbFieldType.PM, subBuilder: OneTimePreKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadDeviceKeysRequest clone() => UploadDeviceKeysRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadDeviceKeysRequest copyWith(void Function(UploadDeviceKeysRequest) updates) => super.copyWith((message) => updates(message as UploadDeviceKeysRequest)) as UploadDeviceKeysRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadDeviceKeysRequest create() => UploadDeviceKeysRequest._();
  @$core.override
  UploadDeviceKeysRequest createEmptyInstance() => create();
  static $pb.PbList<UploadDeviceKeysRequest> createRepeated() => $pb.PbList<UploadDeviceKeysRequest>();
  @$core.pragma('dart2js:noInline')
  static UploadDeviceKeysRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UploadDeviceKeysRequest>(create);
  static UploadDeviceKeysRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  IdentityKey get identityKey => $_getN(2);
  @$pb.TagNumber(3)
  set identityKey(IdentityKey value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentityKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityKey() => $_clearField(3);
  @$pb.TagNumber(3)
  IdentityKey ensureIdentityKey() => $_ensure(2);

  @$pb.TagNumber(4)
  SignedPreKey get signedPreKey => $_getN(3);
  @$pb.TagNumber(4)
  set signedPreKey(SignedPreKey value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSignedPreKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignedPreKey() => $_clearField(4);
  @$pb.TagNumber(4)
  SignedPreKey ensureSignedPreKey() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<OneTimePreKey> get oneTimePreKeys => $_getList(4);
}

class UploadDeviceKeysResponse extends $pb.GeneratedMessage {
  factory UploadDeviceKeysResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  UploadDeviceKeysResponse._();

  factory UploadDeviceKeysResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UploadDeviceKeysResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UploadDeviceKeysResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadDeviceKeysResponse clone() => UploadDeviceKeysResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadDeviceKeysResponse copyWith(void Function(UploadDeviceKeysResponse) updates) => super.copyWith((message) => updates(message as UploadDeviceKeysResponse)) as UploadDeviceKeysResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadDeviceKeysResponse create() => UploadDeviceKeysResponse._();
  @$core.override
  UploadDeviceKeysResponse createEmptyInstance() => create();
  static $pb.PbList<UploadDeviceKeysResponse> createRepeated() => $pb.PbList<UploadDeviceKeysResponse>();
  @$core.pragma('dart2js:noInline')
  static UploadDeviceKeysResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UploadDeviceKeysResponse>(create);
  static UploadDeviceKeysResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class FetchDeviceKeysRequest extends $pb.GeneratedMessage {
  factory FetchDeviceKeysRequest({
    $fixnum.Int64? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  FetchDeviceKeysRequest._();

  factory FetchDeviceKeysRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FetchDeviceKeysRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FetchDeviceKeysRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchDeviceKeysRequest clone() => FetchDeviceKeysRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchDeviceKeysRequest copyWith(void Function(FetchDeviceKeysRequest) updates) => super.copyWith((message) => updates(message as FetchDeviceKeysRequest)) as FetchDeviceKeysRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FetchDeviceKeysRequest create() => FetchDeviceKeysRequest._();
  @$core.override
  FetchDeviceKeysRequest createEmptyInstance() => create();
  static $pb.PbList<FetchDeviceKeysRequest> createRepeated() => $pb.PbList<FetchDeviceKeysRequest>();
  @$core.pragma('dart2js:noInline')
  static FetchDeviceKeysRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FetchDeviceKeysRequest>(create);
  static FetchDeviceKeysRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

class DeviceKeyBundle extends $pb.GeneratedMessage {
  factory DeviceKeyBundle({
    $fixnum.Int64? userId,
    $core.String? deviceId,
    IdentityKey? identityKey,
    SignedPreKey? signedPreKey,
    $core.Iterable<OneTimePreKey>? oneTimePreKeys,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (identityKey != null) result.identityKey = identityKey;
    if (signedPreKey != null) result.signedPreKey = signedPreKey;
    if (oneTimePreKeys != null) result.oneTimePreKeys.addAll(oneTimePreKeys);
    return result;
  }

  DeviceKeyBundle._();

  factory DeviceKeyBundle.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DeviceKeyBundle.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeviceKeyBundle', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOM<IdentityKey>(3, _omitFieldNames ? '' : 'identityKey', subBuilder: IdentityKey.create)
    ..aOM<SignedPreKey>(4, _omitFieldNames ? '' : 'signedPreKey', subBuilder: SignedPreKey.create)
    ..pc<OneTimePreKey>(5, _omitFieldNames ? '' : 'oneTimePreKeys', $pb.PbFieldType.PM, subBuilder: OneTimePreKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceKeyBundle clone() => DeviceKeyBundle()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceKeyBundle copyWith(void Function(DeviceKeyBundle) updates) => super.copyWith((message) => updates(message as DeviceKeyBundle)) as DeviceKeyBundle;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceKeyBundle create() => DeviceKeyBundle._();
  @$core.override
  DeviceKeyBundle createEmptyInstance() => create();
  static $pb.PbList<DeviceKeyBundle> createRepeated() => $pb.PbList<DeviceKeyBundle>();
  @$core.pragma('dart2js:noInline')
  static DeviceKeyBundle getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeviceKeyBundle>(create);
  static DeviceKeyBundle? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  IdentityKey get identityKey => $_getN(2);
  @$pb.TagNumber(3)
  set identityKey(IdentityKey value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentityKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityKey() => $_clearField(3);
  @$pb.TagNumber(3)
  IdentityKey ensureIdentityKey() => $_ensure(2);

  @$pb.TagNumber(4)
  SignedPreKey get signedPreKey => $_getN(3);
  @$pb.TagNumber(4)
  set signedPreKey(SignedPreKey value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSignedPreKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignedPreKey() => $_clearField(4);
  @$pb.TagNumber(4)
  SignedPreKey ensureSignedPreKey() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<OneTimePreKey> get oneTimePreKeys => $_getList(4);
}

class FetchDeviceKeysResponse extends $pb.GeneratedMessage {
  factory FetchDeviceKeysResponse({
    $core.Iterable<DeviceKeyBundle>? bundles,
  }) {
    final result = create();
    if (bundles != null) result.bundles.addAll(bundles);
    return result;
  }

  FetchDeviceKeysResponse._();

  factory FetchDeviceKeysResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FetchDeviceKeysResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FetchDeviceKeysResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..pc<DeviceKeyBundle>(1, _omitFieldNames ? '' : 'bundles', $pb.PbFieldType.PM, subBuilder: DeviceKeyBundle.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchDeviceKeysResponse clone() => FetchDeviceKeysResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchDeviceKeysResponse copyWith(void Function(FetchDeviceKeysResponse) updates) => super.copyWith((message) => updates(message as FetchDeviceKeysResponse)) as FetchDeviceKeysResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FetchDeviceKeysResponse create() => FetchDeviceKeysResponse._();
  @$core.override
  FetchDeviceKeysResponse createEmptyInstance() => create();
  static $pb.PbList<FetchDeviceKeysResponse> createRepeated() => $pb.PbList<FetchDeviceKeysResponse>();
  @$core.pragma('dart2js:noInline')
  static FetchDeviceKeysResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FetchDeviceKeysResponse>(create);
  static FetchDeviceKeysResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DeviceKeyBundle> get bundles => $_getList(0);
}

/// 根据用户 ID 聚合拉取好友消息历史
class ListUserFriendMessagesRequest extends $pb.GeneratedMessage {
  factory ListUserFriendMessagesRequest({
    $fixnum.Int64? userId,
    $fixnum.Int64? sinceTimestamp,
    $core.int? limit,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (sinceTimestamp != null) result.sinceTimestamp = sinceTimestamp;
    if (limit != null) result.limit = limit;
    return result;
  }

  ListUserFriendMessagesRequest._();

  factory ListUserFriendMessagesRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ListUserFriendMessagesRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUserFriendMessagesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'msg_friend_service'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'sinceTimestamp')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUserFriendMessagesRequest clone() => ListUserFriendMessagesRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUserFriendMessagesRequest copyWith(void Function(ListUserFriendMessagesRequest) updates) => super.copyWith((message) => updates(message as ListUserFriendMessagesRequest)) as ListUserFriendMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUserFriendMessagesRequest create() => ListUserFriendMessagesRequest._();
  @$core.override
  ListUserFriendMessagesRequest createEmptyInstance() => create();
  static $pb.PbList<ListUserFriendMessagesRequest> createRepeated() => $pb.PbList<ListUserFriendMessagesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListUserFriendMessagesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUserFriendMessagesRequest>(create);
  static ListUserFriendMessagesRequest? _defaultInstance;

  /// 当前用户 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 起始时间（毫秒，闭区间）；传 0 表示不限制
  @$pb.TagNumber(2)
  $fixnum.Int64 get sinceTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set sinceTimestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSinceTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearSinceTimestamp() => $_clearField(2);

  /// 返回的最大消息数，缺省 200
  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
