// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'auth.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'auth.pbenum.dart';

/// 构建注册验证码（手机/邮箱等渠道）。
class BuildRegisterCodeRequest extends $pb.GeneratedMessage {
  factory BuildRegisterCodeRequest({
    $core.String? name,
    $core.String? password,
    $core.int? regType,
    $core.String? target,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (password != null) result.password = password;
    if (regType != null) result.regType = regType;
    if (target != null) result.target = target;
    return result;
  }

  BuildRegisterCodeRequest._();

  factory BuildRegisterCodeRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory BuildRegisterCodeRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BuildRegisterCodeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'regType', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'target')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildRegisterCodeRequest clone() => BuildRegisterCodeRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildRegisterCodeRequest copyWith(void Function(BuildRegisterCodeRequest) updates) => super.copyWith((message) => updates(message as BuildRegisterCodeRequest)) as BuildRegisterCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BuildRegisterCodeRequest create() => BuildRegisterCodeRequest._();
  @$core.override
  BuildRegisterCodeRequest createEmptyInstance() => create();
  static $pb.PbList<BuildRegisterCodeRequest> createRepeated() => $pb.PbList<BuildRegisterCodeRequest>();
  @$core.pragma('dart2js:noInline')
  static BuildRegisterCodeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BuildRegisterCodeRequest>(create);
  static BuildRegisterCodeRequest? _defaultInstance;

  /// 唯一用户名，例如手机号、邮箱或登录名。
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// 注册时提交的明文密码。
  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  /// 注册介质，对应服务层的 `UserRegType` 枚举。
  @$pb.TagNumber(3)
  $core.int get regType => $_getIZ(2);
  @$pb.TagNumber(3)
  set regType($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRegType() => $_has(2);
  @$pb.TagNumber(3)
  void clearRegType() => $_clearField(3);

  /// 发送目标，如手机号或邮箱地址。
  @$pb.TagNumber(4)
  $core.String get target => $_getSZ(3);
  @$pb.TagNumber(4)
  set target($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTarget() => $_has(3);
  @$pb.TagNumber(4)
  void clearTarget() => $_clearField(4);
}

/// 注册验证码接口返回值。
class BuildRegisterCodeResponse extends $pb.GeneratedMessage {
  factory BuildRegisterCodeResponse({
    $core.String? regId,
    $fixnum.Int64? uid,
  }) {
    final result = create();
    if (regId != null) result.regId = regId;
    if (uid != null) result.uid = uid;
    return result;
  }

  BuildRegisterCodeResponse._();

  factory BuildRegisterCodeResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory BuildRegisterCodeResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BuildRegisterCodeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'regId')
    ..aInt64(2, _omitFieldNames ? '' : 'uid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildRegisterCodeResponse clone() => BuildRegisterCodeResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildRegisterCodeResponse copyWith(void Function(BuildRegisterCodeResponse) updates) => super.copyWith((message) => updates(message as BuildRegisterCodeResponse)) as BuildRegisterCodeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BuildRegisterCodeResponse create() => BuildRegisterCodeResponse._();
  @$core.override
  BuildRegisterCodeResponse createEmptyInstance() => create();
  static $pb.PbList<BuildRegisterCodeResponse> createRepeated() => $pb.PbList<BuildRegisterCodeResponse>();
  @$core.pragma('dart2js:noInline')
  static BuildRegisterCodeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BuildRegisterCodeResponse>(create);
  static BuildRegisterCodeResponse? _defaultInstance;

  /// 注册流程 ID；当 reg_type=LoginName 时为空。
  @$pb.TagNumber(1)
  $core.String get regId => $_getSZ(0);
  @$pb.TagNumber(1)
  set regId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegId() => $_clearField(1);

  /// 登录名注册时返回新用户 UID（同步创建路径）。
  @$pb.TagNumber(2)
  $fixnum.Int64 get uid => $_getI64(1);
  @$pb.TagNumber(2)
  set uid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearUid() => $_clearField(2);
}

/// 用户输入验证码时提交的参数。
class VerifyRegisterCodeRequest extends $pb.GeneratedMessage {
  factory VerifyRegisterCodeRequest({
    $core.String? regId,
    $core.String? code,
  }) {
    final result = create();
    if (regId != null) result.regId = regId;
    if (code != null) result.code = code;
    return result;
  }

  VerifyRegisterCodeRequest._();

  factory VerifyRegisterCodeRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory VerifyRegisterCodeRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyRegisterCodeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'regId')
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyRegisterCodeRequest clone() => VerifyRegisterCodeRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyRegisterCodeRequest copyWith(void Function(VerifyRegisterCodeRequest) updates) => super.copyWith((message) => updates(message as VerifyRegisterCodeRequest)) as VerifyRegisterCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyRegisterCodeRequest create() => VerifyRegisterCodeRequest._();
  @$core.override
  VerifyRegisterCodeRequest createEmptyInstance() => create();
  static $pb.PbList<VerifyRegisterCodeRequest> createRepeated() => $pb.PbList<VerifyRegisterCodeRequest>();
  @$core.pragma('dart2js:noInline')
  static VerifyRegisterCodeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifyRegisterCodeRequest>(create);
  static VerifyRegisterCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get regId => $_getSZ(0);
  @$pb.TagNumber(1)
  set regId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);
}

/// 验证码校验结果。
class VerifyRegisterCodeResponse extends $pb.GeneratedMessage {
  factory VerifyRegisterCodeResponse({
    $core.bool? ok,
  }) {
    final result = create();
    if (ok != null) result.ok = ok;
    return result;
  }

  VerifyRegisterCodeResponse._();

  factory VerifyRegisterCodeResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory VerifyRegisterCodeResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyRegisterCodeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyRegisterCodeResponse clone() => VerifyRegisterCodeResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyRegisterCodeResponse copyWith(void Function(VerifyRegisterCodeResponse) updates) => super.copyWith((message) => updates(message as VerifyRegisterCodeResponse)) as VerifyRegisterCodeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyRegisterCodeResponse create() => VerifyRegisterCodeResponse._();
  @$core.override
  VerifyRegisterCodeResponse createEmptyInstance() => create();
  static $pb.PbList<VerifyRegisterCodeResponse> createRepeated() => $pb.PbList<VerifyRegisterCodeResponse>();
  @$core.pragma('dart2js:noInline')
  static VerifyRegisterCodeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifyRegisterCodeResponse>(create);
  static VerifyRegisterCodeResponse? _defaultInstance;

  /// 验证是否成功。
  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);
}

/// 通用登录请求；`target` 表示登录标识（手机号/邮箱等）。
class LoginRequest extends $pb.GeneratedMessage {
  factory LoginRequest({
    $core.int? loginType,
    $core.String? password,
    $core.String? target,
    $core.int? deviceType,
    $core.String? deviceId,
  }) {
    final result = create();
    if (loginType != null) result.loginType = loginType;
    if (password != null) result.password = password;
    if (target != null) result.target = target;
    if (deviceType != null) result.deviceType = deviceType;
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  LoginRequest._();

  factory LoginRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LoginRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'loginType', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..aOS(3, _omitFieldNames ? '' : 'target')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRequest clone() => LoginRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRequest copyWith(void Function(LoginRequest) updates) => super.copyWith((message) => updates(message as LoginRequest)) as LoginRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginRequest create() => LoginRequest._();
  @$core.override
  LoginRequest createEmptyInstance() => create();
  static $pb.PbList<LoginRequest> createRepeated() => $pb.PbList<LoginRequest>();
  @$core.pragma('dart2js:noInline')
  static LoginRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginRequest>(create);
  static LoginRequest? _defaultInstance;

  /// 登录渠道类型，对应 `UserLogType`。
  @$pb.TagNumber(1)
  $core.int get loginType => $_getIZ(0);
  @$pb.TagNumber(1)
  set loginType($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoginType() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoginType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get target => $_getSZ(2);
  @$pb.TagNumber(3)
  set target($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTarget() => $_has(2);
  @$pb.TagNumber(3)
  void clearTarget() => $_clearField(3);

  /// 设备类型，对应 hot_online 的 DeviceType 枚举。
  @$pb.TagNumber(4)
  $core.int get deviceType => $_getIZ(3);
  @$pb.TagNumber(4)
  set deviceType($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceType() => $_clearField(4);

  /// 设备唯一标识，用于多端登录策略。
  @$pb.TagNumber(5)
  $core.String get deviceId => $_getSZ(4);
  @$pb.TagNumber(5)
  set deviceId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDeviceId() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeviceId() => $_clearField(5);
}

/// 登录成功后返回的会话信息。
class LoginResponse extends $pb.GeneratedMessage {
  factory LoginResponse({
    $core.String? token,
    $fixnum.Int64? expiresAt,
    $core.String? socketAddr,
  }) {
    final result = create();
    if (token != null) result.token = token;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (socketAddr != null) result.socketAddr = socketAddr;
    return result;
  }

  LoginResponse._();

  factory LoginResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LoginResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'expiresAt', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'socketAddr')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginResponse clone() => LoginResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginResponse copyWith(void Function(LoginResponse) updates) => super.copyWith((message) => updates(message as LoginResponse)) as LoginResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginResponse create() => LoginResponse._();
  @$core.override
  LoginResponse createEmptyInstance() => create();
  static $pb.PbList<LoginResponse> createRepeated() => $pb.PbList<LoginResponse>();
  @$core.pragma('dart2js:noInline')
  static LoginResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginResponse>(create);
  static LoginResponse? _defaultInstance;

  /// 会话 token，下游服务与 socket 握手使用。
  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);

  /// token 失效时间（毫秒时间戳）。
  @$pb.TagNumber(2)
  $fixnum.Int64 get expiresAt => $_getI64(1);
  @$pb.TagNumber(2)
  set expiresAt($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiresAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresAt() => $_clearField(2);

  /// 按 arb 哈希得到的 socket 入口地址（host:port）。无节点时为空字符串。
  @$pb.TagNumber(3)
  $core.String get socketAddr => $_getSZ(2);
  @$pb.TagNumber(3)
  set socketAddr($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSocketAddr() => $_has(2);
  @$pb.TagNumber(3)
  void clearSocketAddr() => $_clearField(3);
}

/// 验证 session_token 是否有效。
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateSessionTokenRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
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

/// token 验证结果返回值。
class ValidateSessionTokenResponse extends $pb.GeneratedMessage {
  factory ValidateSessionTokenResponse({
    $core.bool? ok,
    $fixnum.Int64? userId,
    $fixnum.Int64? expiresAt,
    $core.String? token,
  }) {
    final result = create();
    if (ok != null) result.ok = ok;
    if (userId != null) result.userId = userId;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (token != null) result.token = token;
    return result;
  }

  ValidateSessionTokenResponse._();

  factory ValidateSessionTokenResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ValidateSessionTokenResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateSessionTokenResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'expiresAt', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'token')
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
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  /// token 失效时间（毫秒时间戳）。当 ok=false 时为 0。
  @$pb.TagNumber(3)
  $fixnum.Int64 get expiresAt => $_getI64(2);
  @$pb.TagNumber(3)
  set expiresAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);

  /// 若验证成功，返回一个新的 session token。
  @$pb.TagNumber(4)
  $core.String get token => $_getSZ(3);
  @$pb.TagNumber(4)
  set token($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearToken() => $_clearField(4);
}

/// 使用当前会话修改密码。
class ChangePasswordRequest extends $pb.GeneratedMessage {
  factory ChangePasswordRequest({
    $core.String? sessionToken,
    $core.String? oldPassword,
    $core.String? newPassword,
  }) {
    final result = create();
    if (sessionToken != null) result.sessionToken = sessionToken;
    if (oldPassword != null) result.oldPassword = oldPassword;
    if (newPassword != null) result.newPassword = newPassword;
    return result;
  }

  ChangePasswordRequest._();

  factory ChangePasswordRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangePasswordRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePasswordRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionToken')
    ..aOS(2, _omitFieldNames ? '' : 'oldPassword')
    ..aOS(3, _omitFieldNames ? '' : 'newPassword')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordRequest clone() => ChangePasswordRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordRequest copyWith(void Function(ChangePasswordRequest) updates) => super.copyWith((message) => updates(message as ChangePasswordRequest)) as ChangePasswordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest create() => ChangePasswordRequest._();
  @$core.override
  ChangePasswordRequest createEmptyInstance() => create();
  static $pb.PbList<ChangePasswordRequest> createRepeated() => $pb.PbList<ChangePasswordRequest>();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangePasswordRequest>(create);
  static ChangePasswordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionToken() => $_clearField(1);

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
}

/// 修改密码操作的反馈。
class ChangePasswordResponse extends $pb.GeneratedMessage {
  factory ChangePasswordResponse({
    $core.bool? ok,
  }) {
    final result = create();
    if (ok != null) result.ok = ok;
    return result;
  }

  ChangePasswordResponse._();

  factory ChangePasswordResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangePasswordResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePasswordResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordResponse clone() => ChangePasswordResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordResponse copyWith(void Function(ChangePasswordResponse) updates) => super.copyWith((message) => updates(message as ChangePasswordResponse)) as ChangePasswordResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePasswordResponse create() => ChangePasswordResponse._();
  @$core.override
  ChangePasswordResponse createEmptyInstance() => create();
  static $pb.PbList<ChangePasswordResponse> createRepeated() => $pb.PbList<ChangePasswordResponse>();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangePasswordResponse>(create);
  static ChangePasswordResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);
}

/// 修改绑定手机号；可选旧验证码用于双重验证。
class ChangePhoneRequest extends $pb.GeneratedMessage {
  factory ChangePhoneRequest({
    $core.String? sessionToken,
    $core.String? newPhone,
    $core.String? oldPhoneCode,
    $core.String? newPhoneCode,
  }) {
    final result = create();
    if (sessionToken != null) result.sessionToken = sessionToken;
    if (newPhone != null) result.newPhone = newPhone;
    if (oldPhoneCode != null) result.oldPhoneCode = oldPhoneCode;
    if (newPhoneCode != null) result.newPhoneCode = newPhoneCode;
    return result;
  }

  ChangePhoneRequest._();

  factory ChangePhoneRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangePhoneRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePhoneRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionToken')
    ..aOS(2, _omitFieldNames ? '' : 'newPhone')
    ..aOS(3, _omitFieldNames ? '' : 'oldPhoneCode')
    ..aOS(4, _omitFieldNames ? '' : 'newPhoneCode')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePhoneRequest clone() => ChangePhoneRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePhoneRequest copyWith(void Function(ChangePhoneRequest) updates) => super.copyWith((message) => updates(message as ChangePhoneRequest)) as ChangePhoneRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePhoneRequest create() => ChangePhoneRequest._();
  @$core.override
  ChangePhoneRequest createEmptyInstance() => create();
  static $pb.PbList<ChangePhoneRequest> createRepeated() => $pb.PbList<ChangePhoneRequest>();
  @$core.pragma('dart2js:noInline')
  static ChangePhoneRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangePhoneRequest>(create);
  static ChangePhoneRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get newPhone => $_getSZ(1);
  @$pb.TagNumber(2)
  set newPhone($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewPhone() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewPhone() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get oldPhoneCode => $_getSZ(2);
  @$pb.TagNumber(3)
  set oldPhoneCode($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOldPhoneCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearOldPhoneCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get newPhoneCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set newPhoneCode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNewPhoneCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearNewPhoneCode() => $_clearField(4);
}

/// 修改手机号操作的反馈。
class ChangePhoneResponse extends $pb.GeneratedMessage {
  factory ChangePhoneResponse({
    $core.bool? ok,
    $core.String? phone,
  }) {
    final result = create();
    if (ok != null) result.ok = ok;
    if (phone != null) result.phone = phone;
    return result;
  }

  ChangePhoneResponse._();

  factory ChangePhoneResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangePhoneResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePhoneResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..aOS(2, _omitFieldNames ? '' : 'phone')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePhoneResponse clone() => ChangePhoneResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePhoneResponse copyWith(void Function(ChangePhoneResponse) updates) => super.copyWith((message) => updates(message as ChangePhoneResponse)) as ChangePhoneResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePhoneResponse create() => ChangePhoneResponse._();
  @$core.override
  ChangePhoneResponse createEmptyInstance() => create();
  static $pb.PbList<ChangePhoneResponse> createRepeated() => $pb.PbList<ChangePhoneResponse>();
  @$core.pragma('dart2js:noInline')
  static ChangePhoneResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangePhoneResponse>(create);
  static ChangePhoneResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get phone => $_getSZ(1);
  @$pb.TagNumber(2)
  set phone($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPhone() => $_has(1);
  @$pb.TagNumber(2)
  void clearPhone() => $_clearField(2);
}

/// 修改绑定邮箱。
class ChangeEmailRequest extends $pb.GeneratedMessage {
  factory ChangeEmailRequest({
    $core.String? sessionToken,
    $core.String? newEmail,
    $core.String? oldEmailCode,
    $core.String? newEmailCode,
  }) {
    final result = create();
    if (sessionToken != null) result.sessionToken = sessionToken;
    if (newEmail != null) result.newEmail = newEmail;
    if (oldEmailCode != null) result.oldEmailCode = oldEmailCode;
    if (newEmailCode != null) result.newEmailCode = newEmailCode;
    return result;
  }

  ChangeEmailRequest._();

  factory ChangeEmailRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangeEmailRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangeEmailRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionToken')
    ..aOS(2, _omitFieldNames ? '' : 'newEmail')
    ..aOS(3, _omitFieldNames ? '' : 'oldEmailCode')
    ..aOS(4, _omitFieldNames ? '' : 'newEmailCode')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeEmailRequest clone() => ChangeEmailRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeEmailRequest copyWith(void Function(ChangeEmailRequest) updates) => super.copyWith((message) => updates(message as ChangeEmailRequest)) as ChangeEmailRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeEmailRequest create() => ChangeEmailRequest._();
  @$core.override
  ChangeEmailRequest createEmptyInstance() => create();
  static $pb.PbList<ChangeEmailRequest> createRepeated() => $pb.PbList<ChangeEmailRequest>();
  @$core.pragma('dart2js:noInline')
  static ChangeEmailRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangeEmailRequest>(create);
  static ChangeEmailRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get newEmail => $_getSZ(1);
  @$pb.TagNumber(2)
  set newEmail($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewEmail() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewEmail() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get oldEmailCode => $_getSZ(2);
  @$pb.TagNumber(3)
  set oldEmailCode($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOldEmailCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearOldEmailCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get newEmailCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set newEmailCode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNewEmailCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearNewEmailCode() => $_clearField(4);
}

/// 修改邮箱操作的反馈。
class ChangeEmailResponse extends $pb.GeneratedMessage {
  factory ChangeEmailResponse({
    $core.bool? ok,
    $core.String? email,
  }) {
    final result = create();
    if (ok != null) result.ok = ok;
    if (email != null) result.email = email;
    return result;
  }

  ChangeEmailResponse._();

  factory ChangeEmailResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChangeEmailResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangeEmailResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..aOS(2, _omitFieldNames ? '' : 'email')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeEmailResponse clone() => ChangeEmailResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeEmailResponse copyWith(void Function(ChangeEmailResponse) updates) => super.copyWith((message) => updates(message as ChangeEmailResponse)) as ChangeEmailResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeEmailResponse create() => ChangeEmailResponse._();
  @$core.override
  ChangeEmailResponse createEmptyInstance() => create();
  static $pb.PbList<ChangeEmailResponse> createRepeated() => $pb.PbList<ChangeEmailResponse>();
  @$core.pragma('dart2js:noInline')
  static ChangeEmailResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangeEmailResponse>(create);
  static ChangeEmailResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get email => $_getSZ(1);
  @$pb.TagNumber(2)
  set email($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEmail() => $_has(1);
  @$pb.TagNumber(2)
  void clearEmail() => $_clearField(2);
}

/// 更新基础资料字段。
class UpdateProfileRequest extends $pb.GeneratedMessage {
  factory UpdateProfileRequest({
    $core.String? sessionToken,
    $core.String? avatar,
    $core.int? gender,
  }) {
    final result = create();
    if (sessionToken != null) result.sessionToken = sessionToken;
    if (avatar != null) result.avatar = avatar;
    if (gender != null) result.gender = gender;
    return result;
  }

  UpdateProfileRequest._();

  factory UpdateProfileRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UpdateProfileRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateProfileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionToken')
    ..aOS(2, _omitFieldNames ? '' : 'avatar')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'gender', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfileRequest clone() => UpdateProfileRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfileRequest copyWith(void Function(UpdateProfileRequest) updates) => super.copyWith((message) => updates(message as UpdateProfileRequest)) as UpdateProfileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProfileRequest create() => UpdateProfileRequest._();
  @$core.override
  UpdateProfileRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateProfileRequest> createRepeated() => $pb.PbList<UpdateProfileRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateProfileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProfileRequest>(create);
  static UpdateProfileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get avatar => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatar($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAvatar() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatar() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get gender => $_getIZ(2);
  @$pb.TagNumber(3)
  set gender($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGender() => $_has(2);
  @$pb.TagNumber(3)
  void clearGender() => $_clearField(3);
}

/// 更新资料操作的反馈。
class UpdateProfileResponse extends $pb.GeneratedMessage {
  factory UpdateProfileResponse({
    $core.bool? ok,
  }) {
    final result = create();
    if (ok != null) result.ok = ok;
    return result;
  }

  UpdateProfileResponse._();

  factory UpdateProfileResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UpdateProfileResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateProfileResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfileResponse clone() => UpdateProfileResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfileResponse copyWith(void Function(UpdateProfileResponse) updates) => super.copyWith((message) => updates(message as UpdateProfileResponse)) as UpdateProfileResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProfileResponse create() => UpdateProfileResponse._();
  @$core.override
  UpdateProfileResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateProfileResponse> createRepeated() => $pb.PbList<UpdateProfileResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateProfileResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProfileResponse>(create);
  static UpdateProfileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);
}

class SearchUserRequest extends $pb.GeneratedMessage {
  factory SearchUserRequest({
    UserSearchType? searchType,
    $core.String? query,
  }) {
    final result = create();
    if (searchType != null) result.searchType = searchType;
    if (query != null) result.query = query;
    return result;
  }

  SearchUserRequest._();

  factory SearchUserRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SearchUserRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SearchUserRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..e<UserSearchType>(1, _omitFieldNames ? '' : 'searchType', $pb.PbFieldType.OE, defaultOrMaker: UserSearchType.USER_SEARCH_UNKNOWN, valueOf: UserSearchType.valueOf, enumValues: UserSearchType.values)
    ..aOS(2, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserRequest clone() => SearchUserRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserRequest copyWith(void Function(SearchUserRequest) updates) => super.copyWith((message) => updates(message as SearchUserRequest)) as SearchUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUserRequest create() => SearchUserRequest._();
  @$core.override
  SearchUserRequest createEmptyInstance() => create();
  static $pb.PbList<SearchUserRequest> createRepeated() => $pb.PbList<SearchUserRequest>();
  @$core.pragma('dart2js:noInline')
  static SearchUserRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchUserRequest>(create);
  static SearchUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  UserSearchType get searchType => $_getN(0);
  @$pb.TagNumber(1)
  set searchType(UserSearchType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSearchType() => $_has(0);
  @$pb.TagNumber(1)
  void clearSearchType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get query => $_getSZ(1);
  @$pb.TagNumber(2)
  set query($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuery() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuery() => $_clearField(2);
}

class UserProfile extends $pb.GeneratedMessage {
  factory UserProfile({
    $fixnum.Int64? userId,
    $core.String? username,
    $core.String? avatar,
    $core.String? email,
    $core.String? phone,
    $core.String? signature,
    $core.String? region,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (username != null) result.username = username;
    if (avatar != null) result.avatar = avatar;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (signature != null) result.signature = signature;
    if (region != null) result.region = region;
    return result;
  }

  UserProfile._();

  factory UserProfile.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory UserProfile.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserProfile', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..aOS(4, _omitFieldNames ? '' : 'email')
    ..aOS(5, _omitFieldNames ? '' : 'phone')
    ..aOS(6, _omitFieldNames ? '' : 'signature')
    ..aOS(7, _omitFieldNames ? '' : 'region')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserProfile clone() => UserProfile()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserProfile copyWith(void Function(UserProfile) updates) => super.copyWith((message) => updates(message as UserProfile)) as UserProfile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserProfile create() => UserProfile._();
  @$core.override
  UserProfile createEmptyInstance() => create();
  static $pb.PbList<UserProfile> createRepeated() => $pb.PbList<UserProfile>();
  @$core.pragma('dart2js:noInline')
  static UserProfile getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserProfile>(create);
  static UserProfile? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

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
  $core.String get signature => $_getSZ(5);
  @$pb.TagNumber(6)
  set signature($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSignature() => $_has(5);
  @$pb.TagNumber(6)
  void clearSignature() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get region => $_getSZ(6);
  @$pb.TagNumber(7)
  set region($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRegion() => $_has(6);
  @$pb.TagNumber(7)
  void clearRegion() => $_clearField(7);
}

class SearchUserResponse extends $pb.GeneratedMessage {
  factory SearchUserResponse({
    UserProfile? user,
  }) {
    final result = create();
    if (user != null) result.user = user;
    return result;
  }

  SearchUserResponse._();

  factory SearchUserResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SearchUserResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SearchUserResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOM<UserProfile>(1, _omitFieldNames ? '' : 'user', subBuilder: UserProfile.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserResponse clone() => SearchUserResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserResponse copyWith(void Function(SearchUserResponse) updates) => super.copyWith((message) => updates(message as SearchUserResponse)) as SearchUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUserResponse create() => SearchUserResponse._();
  @$core.override
  SearchUserResponse createEmptyInstance() => create();
  static $pb.PbList<SearchUserResponse> createRepeated() => $pb.PbList<SearchUserResponse>();
  @$core.pragma('dart2js:noInline')
  static SearchUserResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchUserResponse>(create);
  static SearchUserResponse? _defaultInstance;

  @$pb.TagNumber(1)
  UserProfile get user => $_getN(0);
  @$pb.TagNumber(1)
  set user(UserProfile value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);
  @$pb.TagNumber(1)
  UserProfile ensureUser() => $_ensure(0);
}

class FriendSummary extends $pb.GeneratedMessage {
  factory FriendSummary({
    $fixnum.Int64? friendId,
    $core.String? nickname,
    $core.String? avatar,
    $core.String? remark,
  }) {
    final result = create();
    if (friendId != null) result.friendId = friendId;
    if (nickname != null) result.nickname = nickname;
    if (avatar != null) result.avatar = avatar;
    if (remark != null) result.remark = remark;
    return result;
  }

  FriendSummary._();

  factory FriendSummary.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FriendSummary.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FriendSummary', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..aOS(4, _omitFieldNames ? '' : 'remark')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendSummary clone() => FriendSummary()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendSummary copyWith(void Function(FriendSummary) updates) => super.copyWith((message) => updates(message as FriendSummary)) as FriendSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FriendSummary create() => FriendSummary._();
  @$core.override
  FriendSummary createEmptyInstance() => create();
  static $pb.PbList<FriendSummary> createRepeated() => $pb.PbList<FriendSummary>();
  @$core.pragma('dart2js:noInline')
  static FriendSummary getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendSummary>(create);
  static FriendSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get friendId => $_getI64(0);
  @$pb.TagNumber(1)
  set friendId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get remark => $_getSZ(3);
  @$pb.TagNumber(4)
  set remark($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRemark() => $_has(3);
  @$pb.TagNumber(4)
  void clearRemark() => $_clearField(4);
}

class GetFriendListRequest extends $pb.GeneratedMessage {
  factory GetFriendListRequest({
    $core.String? sessionToken,
    $core.int? page,
    $core.int? pageSize,
  }) {
    final result = create();
    if (sessionToken != null) result.sessionToken = sessionToken;
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  GetFriendListRequest._();

  factory GetFriendListRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetFriendListRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFriendListRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionToken')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'page', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFriendListRequest clone() => GetFriendListRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFriendListRequest copyWith(void Function(GetFriendListRequest) updates) => super.copyWith((message) => updates(message as GetFriendListRequest)) as GetFriendListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFriendListRequest create() => GetFriendListRequest._();
  @$core.override
  GetFriendListRequest createEmptyInstance() => create();
  static $pb.PbList<GetFriendListRequest> createRepeated() => $pb.PbList<GetFriendListRequest>();
  @$core.pragma('dart2js:noInline')
  static GetFriendListRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFriendListRequest>(create);
  static GetFriendListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2)
  set page($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);
}

class GetFriendListResponse extends $pb.GeneratedMessage {
  factory GetFriendListResponse({
    $core.Iterable<FriendSummary>? friends,
    $core.int? page,
    $core.int? pageSize,
    $core.bool? hasMore,
  }) {
    final result = create();
    if (friends != null) result.friends.addAll(friends);
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  GetFriendListResponse._();

  factory GetFriendListResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetFriendListResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFriendListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..pc<FriendSummary>(1, _omitFieldNames ? '' : 'friends', $pb.PbFieldType.PM, subBuilder: FriendSummary.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'page', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFriendListResponse clone() => GetFriendListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFriendListResponse copyWith(void Function(GetFriendListResponse) updates) => super.copyWith((message) => updates(message as GetFriendListResponse)) as GetFriendListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFriendListResponse create() => GetFriendListResponse._();
  @$core.override
  GetFriendListResponse createEmptyInstance() => create();
  static $pb.PbList<GetFriendListResponse> createRepeated() => $pb.PbList<GetFriendListResponse>();
  @$core.pragma('dart2js:noInline')
  static GetFriendListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFriendListResponse>(create);
  static GetFriendListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FriendSummary> get friends => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2)
  set page($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get hasMore => $_getBF(3);
  @$pb.TagNumber(4)
  set hasMore($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHasMore() => $_has(3);
  @$pb.TagNumber(4)
  void clearHasMore() => $_clearField(4);
}

class GroupMemberSummary extends $pb.GeneratedMessage {
  factory GroupMemberSummary({
    $fixnum.Int64? groupId,
    $fixnum.Int64? memberId,
    $core.String? nickname,
    $core.String? avatar,
    $core.int? role,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (memberId != null) result.memberId = memberId;
    if (nickname != null) result.nickname = nickname;
    if (avatar != null) result.avatar = avatar;
    if (role != null) result.role = role;
    return result;
  }

  GroupMemberSummary._();

  factory GroupMemberSummary.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GroupMemberSummary.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupMemberSummary', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'memberId')
    ..aOS(3, _omitFieldNames ? '' : 'nickname')
    ..aOS(4, _omitFieldNames ? '' : 'avatar')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'role', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMemberSummary clone() => GroupMemberSummary()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMemberSummary copyWith(void Function(GroupMemberSummary) updates) => super.copyWith((message) => updates(message as GroupMemberSummary)) as GroupMemberSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupMemberSummary create() => GroupMemberSummary._();
  @$core.override
  GroupMemberSummary createEmptyInstance() => create();
  static $pb.PbList<GroupMemberSummary> createRepeated() => $pb.PbList<GroupMemberSummary>();
  @$core.pragma('dart2js:noInline')
  static GroupMemberSummary getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupMemberSummary>(create);
  static GroupMemberSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get memberId => $_getI64(1);
  @$pb.TagNumber(2)
  set memberId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nickname => $_getSZ(2);
  @$pb.TagNumber(3)
  set nickname($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNickname() => $_has(2);
  @$pb.TagNumber(3)
  void clearNickname() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatar($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatar() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get role => $_getIZ(4);
  @$pb.TagNumber(5)
  set role($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRole() => $_has(4);
  @$pb.TagNumber(5)
  void clearRole() => $_clearField(5);
}

class GetGroupMembersRequest extends $pb.GeneratedMessage {
  factory GetGroupMembersRequest({
    $core.String? sessionToken,
    $fixnum.Int64? groupId,
    $core.int? page,
    $core.int? pageSize,
  }) {
    final result = create();
    if (sessionToken != null) result.sessionToken = sessionToken;
    if (groupId != null) result.groupId = groupId;
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  GetGroupMembersRequest._();

  factory GetGroupMembersRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetGroupMembersRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupMembersRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionToken')
    ..aInt64(2, _omitFieldNames ? '' : 'groupId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'page', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMembersRequest clone() => GetGroupMembersRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMembersRequest copyWith(void Function(GetGroupMembersRequest) updates) => super.copyWith((message) => updates(message as GetGroupMembersRequest)) as GetGroupMembersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMembersRequest create() => GetGroupMembersRequest._();
  @$core.override
  GetGroupMembersRequest createEmptyInstance() => create();
  static $pb.PbList<GetGroupMembersRequest> createRepeated() => $pb.PbList<GetGroupMembersRequest>();
  @$core.pragma('dart2js:noInline')
  static GetGroupMembersRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupMembersRequest>(create);
  static GetGroupMembersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get groupId => $_getI64(1);
  @$pb.TagNumber(2)
  set groupId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get page => $_getIZ(2);
  @$pb.TagNumber(3)
  set page($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPage() => $_has(2);
  @$pb.TagNumber(3)
  void clearPage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => $_clearField(4);
}

class GetGroupMembersResponse extends $pb.GeneratedMessage {
  factory GetGroupMembersResponse({
    $core.Iterable<GroupMemberSummary>? members,
    $core.int? page,
    $core.int? pageSize,
    $core.bool? hasMore,
  }) {
    final result = create();
    if (members != null) result.members.addAll(members);
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  GetGroupMembersResponse._();

  factory GetGroupMembersResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetGroupMembersResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupMembersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..pc<GroupMemberSummary>(1, _omitFieldNames ? '' : 'members', $pb.PbFieldType.PM, subBuilder: GroupMemberSummary.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'page', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMembersResponse clone() => GetGroupMembersResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMembersResponse copyWith(void Function(GetGroupMembersResponse) updates) => super.copyWith((message) => updates(message as GetGroupMembersResponse)) as GetGroupMembersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMembersResponse create() => GetGroupMembersResponse._();
  @$core.override
  GetGroupMembersResponse createEmptyInstance() => create();
  static $pb.PbList<GetGroupMembersResponse> createRepeated() => $pb.PbList<GetGroupMembersResponse>();
  @$core.pragma('dart2js:noInline')
  static GetGroupMembersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupMembersResponse>(create);
  static GetGroupMembersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GroupMemberSummary> get members => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2)
  set page($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get hasMore => $_getBF(3);
  @$pb.TagNumber(4)
  set hasMore($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHasMore() => $_has(3);
  @$pb.TagNumber(4)
  void clearHasMore() => $_clearField(4);
}

class GetGroupMemberDetailRequest extends $pb.GeneratedMessage {
  factory GetGroupMemberDetailRequest({
    $core.String? sessionToken,
    $fixnum.Int64? groupId,
    $fixnum.Int64? memberId,
  }) {
    final result = create();
    if (sessionToken != null) result.sessionToken = sessionToken;
    if (groupId != null) result.groupId = groupId;
    if (memberId != null) result.memberId = memberId;
    return result;
  }

  GetGroupMemberDetailRequest._();

  factory GetGroupMemberDetailRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetGroupMemberDetailRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupMemberDetailRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionToken')
    ..aInt64(2, _omitFieldNames ? '' : 'groupId')
    ..aInt64(3, _omitFieldNames ? '' : 'memberId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMemberDetailRequest clone() => GetGroupMemberDetailRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMemberDetailRequest copyWith(void Function(GetGroupMemberDetailRequest) updates) => super.copyWith((message) => updates(message as GetGroupMemberDetailRequest)) as GetGroupMemberDetailRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMemberDetailRequest create() => GetGroupMemberDetailRequest._();
  @$core.override
  GetGroupMemberDetailRequest createEmptyInstance() => create();
  static $pb.PbList<GetGroupMemberDetailRequest> createRepeated() => $pb.PbList<GetGroupMemberDetailRequest>();
  @$core.pragma('dart2js:noInline')
  static GetGroupMemberDetailRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupMemberDetailRequest>(create);
  static GetGroupMemberDetailRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get groupId => $_getI64(1);
  @$pb.TagNumber(2)
  set groupId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get memberId => $_getI64(2);
  @$pb.TagNumber(3)
  set memberId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberId() => $_clearField(3);
}

class GetGroupMemberDetailResponse extends $pb.GeneratedMessage {
  factory GetGroupMemberDetailResponse({
    GroupMemberSummary? member,
    $core.bool? isFriend,
  }) {
    final result = create();
    if (member != null) result.member = member;
    if (isFriend != null) result.isFriend = isFriend;
    return result;
  }

  GetGroupMemberDetailResponse._();

  factory GetGroupMemberDetailResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GetGroupMemberDetailResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupMemberDetailResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'api'), createEmptyInstance: create)
    ..aOM<GroupMemberSummary>(1, _omitFieldNames ? '' : 'member', subBuilder: GroupMemberSummary.create)
    ..aOB(2, _omitFieldNames ? '' : 'isFriend')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMemberDetailResponse clone() => GetGroupMemberDetailResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMemberDetailResponse copyWith(void Function(GetGroupMemberDetailResponse) updates) => super.copyWith((message) => updates(message as GetGroupMemberDetailResponse)) as GetGroupMemberDetailResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMemberDetailResponse create() => GetGroupMemberDetailResponse._();
  @$core.override
  GetGroupMemberDetailResponse createEmptyInstance() => create();
  static $pb.PbList<GetGroupMemberDetailResponse> createRepeated() => $pb.PbList<GetGroupMemberDetailResponse>();
  @$core.pragma('dart2js:noInline')
  static GetGroupMemberDetailResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupMemberDetailResponse>(create);
  static GetGroupMemberDetailResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GroupMemberSummary get member => $_getN(0);
  @$pb.TagNumber(1)
  set member(GroupMemberSummary value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMember() => $_has(0);
  @$pb.TagNumber(1)
  void clearMember() => $_clearField(1);
  @$pb.TagNumber(1)
  GroupMemberSummary ensureMember() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get isFriend => $_getBF(1);
  @$pb.TagNumber(2)
  set isFriend($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsFriend() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFriend() => $_clearField(2);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
