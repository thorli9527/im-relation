// This is a generated file - do not edit.
//
// Generated from hot_online.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'hot_online.pb.dart' as $0;

export 'hot_online.pb.dart';

@$pb.GrpcServiceName('online_service.OnlineService')
class OnlineServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  OnlineServiceClient(super.channel, {super.options, super.interceptors});

  /// 设置在线/离线（幂等）
  $grpc.ResponseFuture<$0.SetOnlineResponse> setOnline($0.SetOnlineRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$setOnline, request, options: options);
  }

  /// 单查
  $grpc.ResponseFuture<$0.CheckOnlineResponse> checkOnline($0.CheckOnlineRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$checkOnline, request, options: options);
  }

  /// 批量查
  $grpc.ResponseFuture<$0.CheckOnlineBatchResponse> checkOnlineBatch($0.CheckOnlineBatchRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$checkOnlineBatch, request, options: options);
  }

  /// 统计信息
  $grpc.ResponseFuture<$0.GetStatsResponse> getStats($0.GetStatsRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$getStats, request, options: options);
  }

  /// 生成/刷新设备 session token
  $grpc.ResponseFuture<$0.UpsertSessionTokenResponse> upsertSessionToken($0.UpsertSessionTokenRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$upsertSessionToken, request, options: options);
  }

  /// 校验 session token 合法性
  $grpc.ResponseFuture<$0.ValidateSessionTokenResponse> validateSessionToken($0.ValidateSessionTokenRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$validateSessionToken, request, options: options);
  }

  /// 吊销指定 token 或设备会话
  $grpc.ResponseFuture<$0.RevokeSessionTokenResponse> revokeSessionToken($0.RevokeSessionTokenRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$revokeSessionToken, request, options: options);
  }

  /// 批量刷新最后活跃时间
  $grpc.ResponseFuture<$0.TouchSessionTokenResponse> touchSessionToken($0.TouchSessionTokenRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$touchSessionToken, request, options: options);
  }

    // method descriptors

  static final _$setOnline = $grpc.ClientMethod<$0.SetOnlineRequest, $0.SetOnlineResponse>(
      '/online_service.OnlineService/SetOnline',
      ($0.SetOnlineRequest value) => value.writeToBuffer(),
      $0.SetOnlineResponse.fromBuffer);
  static final _$checkOnline = $grpc.ClientMethod<$0.CheckOnlineRequest, $0.CheckOnlineResponse>(
      '/online_service.OnlineService/CheckOnline',
      ($0.CheckOnlineRequest value) => value.writeToBuffer(),
      $0.CheckOnlineResponse.fromBuffer);
  static final _$checkOnlineBatch = $grpc.ClientMethod<$0.CheckOnlineBatchRequest, $0.CheckOnlineBatchResponse>(
      '/online_service.OnlineService/CheckOnlineBatch',
      ($0.CheckOnlineBatchRequest value) => value.writeToBuffer(),
      $0.CheckOnlineBatchResponse.fromBuffer);
  static final _$getStats = $grpc.ClientMethod<$0.GetStatsRequest, $0.GetStatsResponse>(
      '/online_service.OnlineService/GetStats',
      ($0.GetStatsRequest value) => value.writeToBuffer(),
      $0.GetStatsResponse.fromBuffer);
  static final _$upsertSessionToken = $grpc.ClientMethod<$0.UpsertSessionTokenRequest, $0.UpsertSessionTokenResponse>(
      '/online_service.OnlineService/UpsertSessionToken',
      ($0.UpsertSessionTokenRequest value) => value.writeToBuffer(),
      $0.UpsertSessionTokenResponse.fromBuffer);
  static final _$validateSessionToken = $grpc.ClientMethod<$0.ValidateSessionTokenRequest, $0.ValidateSessionTokenResponse>(
      '/online_service.OnlineService/ValidateSessionToken',
      ($0.ValidateSessionTokenRequest value) => value.writeToBuffer(),
      $0.ValidateSessionTokenResponse.fromBuffer);
  static final _$revokeSessionToken = $grpc.ClientMethod<$0.RevokeSessionTokenRequest, $0.RevokeSessionTokenResponse>(
      '/online_service.OnlineService/RevokeSessionToken',
      ($0.RevokeSessionTokenRequest value) => value.writeToBuffer(),
      $0.RevokeSessionTokenResponse.fromBuffer);
  static final _$touchSessionToken = $grpc.ClientMethod<$0.TouchSessionTokenRequest, $0.TouchSessionTokenResponse>(
      '/online_service.OnlineService/TouchSessionToken',
      ($0.TouchSessionTokenRequest value) => value.writeToBuffer(),
      $0.TouchSessionTokenResponse.fromBuffer);
}

@$pb.GrpcServiceName('online_service.OnlineService')
abstract class OnlineServiceBase extends $grpc.Service {
  $core.String get $name => 'online_service.OnlineService';

  OnlineServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SetOnlineRequest, $0.SetOnlineResponse>(
        'SetOnline',
        setOnline_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetOnlineRequest.fromBuffer(value),
        ($0.SetOnlineResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CheckOnlineRequest, $0.CheckOnlineResponse>(
        'CheckOnline',
        checkOnline_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CheckOnlineRequest.fromBuffer(value),
        ($0.CheckOnlineResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CheckOnlineBatchRequest, $0.CheckOnlineBatchResponse>(
        'CheckOnlineBatch',
        checkOnlineBatch_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CheckOnlineBatchRequest.fromBuffer(value),
        ($0.CheckOnlineBatchResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetStatsRequest, $0.GetStatsResponse>(
        'GetStats',
        getStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetStatsRequest.fromBuffer(value),
        ($0.GetStatsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpsertSessionTokenRequest, $0.UpsertSessionTokenResponse>(
        'UpsertSessionToken',
        upsertSessionToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpsertSessionTokenRequest.fromBuffer(value),
        ($0.UpsertSessionTokenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ValidateSessionTokenRequest, $0.ValidateSessionTokenResponse>(
        'ValidateSessionToken',
        validateSessionToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ValidateSessionTokenRequest.fromBuffer(value),
        ($0.ValidateSessionTokenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeSessionTokenRequest, $0.RevokeSessionTokenResponse>(
        'RevokeSessionToken',
        revokeSessionToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RevokeSessionTokenRequest.fromBuffer(value),
        ($0.RevokeSessionTokenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TouchSessionTokenRequest, $0.TouchSessionTokenResponse>(
        'TouchSessionToken',
        touchSessionToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TouchSessionTokenRequest.fromBuffer(value),
        ($0.TouchSessionTokenResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.SetOnlineResponse> setOnline_Pre($grpc.ServiceCall $call, $async.Future<$0.SetOnlineRequest> $request) async {
    return setOnline($call, await $request);
  }

  $async.Future<$0.SetOnlineResponse> setOnline($grpc.ServiceCall call, $0.SetOnlineRequest request);

  $async.Future<$0.CheckOnlineResponse> checkOnline_Pre($grpc.ServiceCall $call, $async.Future<$0.CheckOnlineRequest> $request) async {
    return checkOnline($call, await $request);
  }

  $async.Future<$0.CheckOnlineResponse> checkOnline($grpc.ServiceCall call, $0.CheckOnlineRequest request);

  $async.Future<$0.CheckOnlineBatchResponse> checkOnlineBatch_Pre($grpc.ServiceCall $call, $async.Future<$0.CheckOnlineBatchRequest> $request) async {
    return checkOnlineBatch($call, await $request);
  }

  $async.Future<$0.CheckOnlineBatchResponse> checkOnlineBatch($grpc.ServiceCall call, $0.CheckOnlineBatchRequest request);

  $async.Future<$0.GetStatsResponse> getStats_Pre($grpc.ServiceCall $call, $async.Future<$0.GetStatsRequest> $request) async {
    return getStats($call, await $request);
  }

  $async.Future<$0.GetStatsResponse> getStats($grpc.ServiceCall call, $0.GetStatsRequest request);

  $async.Future<$0.UpsertSessionTokenResponse> upsertSessionToken_Pre($grpc.ServiceCall $call, $async.Future<$0.UpsertSessionTokenRequest> $request) async {
    return upsertSessionToken($call, await $request);
  }

  $async.Future<$0.UpsertSessionTokenResponse> upsertSessionToken($grpc.ServiceCall call, $0.UpsertSessionTokenRequest request);

  $async.Future<$0.ValidateSessionTokenResponse> validateSessionToken_Pre($grpc.ServiceCall $call, $async.Future<$0.ValidateSessionTokenRequest> $request) async {
    return validateSessionToken($call, await $request);
  }

  $async.Future<$0.ValidateSessionTokenResponse> validateSessionToken($grpc.ServiceCall call, $0.ValidateSessionTokenRequest request);

  $async.Future<$0.RevokeSessionTokenResponse> revokeSessionToken_Pre($grpc.ServiceCall $call, $async.Future<$0.RevokeSessionTokenRequest> $request) async {
    return revokeSessionToken($call, await $request);
  }

  $async.Future<$0.RevokeSessionTokenResponse> revokeSessionToken($grpc.ServiceCall call, $0.RevokeSessionTokenRequest request);

  $async.Future<$0.TouchSessionTokenResponse> touchSessionToken_Pre($grpc.ServiceCall $call, $async.Future<$0.TouchSessionTokenRequest> $request) async {
    return touchSessionToken($call, await $request);
  }

  $async.Future<$0.TouchSessionTokenResponse> touchSessionToken($grpc.ServiceCall call, $0.TouchSessionTokenRequest request);

}
@$pb.GrpcServiceName('online_service.ClientRpcService')
class ClientRpcServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ClientRpcServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.FindClientDto> findByEmail($0.FindByContentReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$findByEmail, request, options: options);
  }

  $grpc.ResponseFuture<$0.FindClientDto> findByPhone($0.FindByContentReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$findByPhone, request, options: options);
  }

  $grpc.ResponseFuture<$0.FindClientDto> findByName($0.FindByContentReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$findByName, request, options: options);
  }

  $grpc.ResponseFuture<$0.ClientEntity> register($0.RegisterUserReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$register, request, options: options);
  }

  $grpc.ResponseFuture<$0.ChangeResponse> changePassword($0.ChangePasswordReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$changePassword, request, options: options);
  }

  $grpc.ResponseFuture<$0.ClientEntity> changePhone($0.ChangePhoneReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$changePhone, request, options: options);
  }

  $grpc.ResponseFuture<$0.ClientEntity> changeEmail($0.ChangeEmailReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$changeEmail, request, options: options);
  }

  $grpc.ResponseFuture<$0.ClientEntity> updateClient($0.UpdateClientReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$updateClient, request, options: options);
  }

  $grpc.ResponseFuture<$0.ClientEntity> getClient($0.GetClientReq request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$getClient, request, options: options);
  }

    // method descriptors

  static final _$findByEmail = $grpc.ClientMethod<$0.FindByContentReq, $0.FindClientDto>(
      '/online_service.ClientRpcService/findByEmail',
      ($0.FindByContentReq value) => value.writeToBuffer(),
      $0.FindClientDto.fromBuffer);
  static final _$findByPhone = $grpc.ClientMethod<$0.FindByContentReq, $0.FindClientDto>(
      '/online_service.ClientRpcService/findByPhone',
      ($0.FindByContentReq value) => value.writeToBuffer(),
      $0.FindClientDto.fromBuffer);
  static final _$findByName = $grpc.ClientMethod<$0.FindByContentReq, $0.FindClientDto>(
      '/online_service.ClientRpcService/findByName',
      ($0.FindByContentReq value) => value.writeToBuffer(),
      $0.FindClientDto.fromBuffer);
  static final _$register = $grpc.ClientMethod<$0.RegisterUserReq, $0.ClientEntity>(
      '/online_service.ClientRpcService/Register',
      ($0.RegisterUserReq value) => value.writeToBuffer(),
      $0.ClientEntity.fromBuffer);
  static final _$changePassword = $grpc.ClientMethod<$0.ChangePasswordReq, $0.ChangeResponse>(
      '/online_service.ClientRpcService/ChangePassword',
      ($0.ChangePasswordReq value) => value.writeToBuffer(),
      $0.ChangeResponse.fromBuffer);
  static final _$changePhone = $grpc.ClientMethod<$0.ChangePhoneReq, $0.ClientEntity>(
      '/online_service.ClientRpcService/ChangePhone',
      ($0.ChangePhoneReq value) => value.writeToBuffer(),
      $0.ClientEntity.fromBuffer);
  static final _$changeEmail = $grpc.ClientMethod<$0.ChangeEmailReq, $0.ClientEntity>(
      '/online_service.ClientRpcService/ChangeEmail',
      ($0.ChangeEmailReq value) => value.writeToBuffer(),
      $0.ClientEntity.fromBuffer);
  static final _$updateClient = $grpc.ClientMethod<$0.UpdateClientReq, $0.ClientEntity>(
      '/online_service.ClientRpcService/UpdateClient',
      ($0.UpdateClientReq value) => value.writeToBuffer(),
      $0.ClientEntity.fromBuffer);
  static final _$getClient = $grpc.ClientMethod<$0.GetClientReq, $0.ClientEntity>(
      '/online_service.ClientRpcService/GetClient',
      ($0.GetClientReq value) => value.writeToBuffer(),
      $0.ClientEntity.fromBuffer);
}

@$pb.GrpcServiceName('online_service.ClientRpcService')
abstract class ClientRpcServiceBase extends $grpc.Service {
  $core.String get $name => 'online_service.ClientRpcService';

  ClientRpcServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.FindByContentReq, $0.FindClientDto>(
        'findByEmail',
        findByEmail_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FindByContentReq.fromBuffer(value),
        ($0.FindClientDto value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FindByContentReq, $0.FindClientDto>(
        'findByPhone',
        findByPhone_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FindByContentReq.fromBuffer(value),
        ($0.FindClientDto value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FindByContentReq, $0.FindClientDto>(
        'findByName',
        findByName_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FindByContentReq.fromBuffer(value),
        ($0.FindClientDto value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RegisterUserReq, $0.ClientEntity>(
        'Register',
        register_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RegisterUserReq.fromBuffer(value),
        ($0.ClientEntity value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangePasswordReq, $0.ChangeResponse>(
        'ChangePassword',
        changePassword_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChangePasswordReq.fromBuffer(value),
        ($0.ChangeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangePhoneReq, $0.ClientEntity>(
        'ChangePhone',
        changePhone_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChangePhoneReq.fromBuffer(value),
        ($0.ClientEntity value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeEmailReq, $0.ClientEntity>(
        'ChangeEmail',
        changeEmail_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChangeEmailReq.fromBuffer(value),
        ($0.ClientEntity value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateClientReq, $0.ClientEntity>(
        'UpdateClient',
        updateClient_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateClientReq.fromBuffer(value),
        ($0.ClientEntity value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetClientReq, $0.ClientEntity>(
        'GetClient',
        getClient_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetClientReq.fromBuffer(value),
        ($0.ClientEntity value) => value.writeToBuffer()));
  }

  $async.Future<$0.FindClientDto> findByEmail_Pre($grpc.ServiceCall $call, $async.Future<$0.FindByContentReq> $request) async {
    return findByEmail($call, await $request);
  }

  $async.Future<$0.FindClientDto> findByEmail($grpc.ServiceCall call, $0.FindByContentReq request);

  $async.Future<$0.FindClientDto> findByPhone_Pre($grpc.ServiceCall $call, $async.Future<$0.FindByContentReq> $request) async {
    return findByPhone($call, await $request);
  }

  $async.Future<$0.FindClientDto> findByPhone($grpc.ServiceCall call, $0.FindByContentReq request);

  $async.Future<$0.FindClientDto> findByName_Pre($grpc.ServiceCall $call, $async.Future<$0.FindByContentReq> $request) async {
    return findByName($call, await $request);
  }

  $async.Future<$0.FindClientDto> findByName($grpc.ServiceCall call, $0.FindByContentReq request);

  $async.Future<$0.ClientEntity> register_Pre($grpc.ServiceCall $call, $async.Future<$0.RegisterUserReq> $request) async {
    return register($call, await $request);
  }

  $async.Future<$0.ClientEntity> register($grpc.ServiceCall call, $0.RegisterUserReq request);

  $async.Future<$0.ChangeResponse> changePassword_Pre($grpc.ServiceCall $call, $async.Future<$0.ChangePasswordReq> $request) async {
    return changePassword($call, await $request);
  }

  $async.Future<$0.ChangeResponse> changePassword($grpc.ServiceCall call, $0.ChangePasswordReq request);

  $async.Future<$0.ClientEntity> changePhone_Pre($grpc.ServiceCall $call, $async.Future<$0.ChangePhoneReq> $request) async {
    return changePhone($call, await $request);
  }

  $async.Future<$0.ClientEntity> changePhone($grpc.ServiceCall call, $0.ChangePhoneReq request);

  $async.Future<$0.ClientEntity> changeEmail_Pre($grpc.ServiceCall $call, $async.Future<$0.ChangeEmailReq> $request) async {
    return changeEmail($call, await $request);
  }

  $async.Future<$0.ClientEntity> changeEmail($grpc.ServiceCall call, $0.ChangeEmailReq request);

  $async.Future<$0.ClientEntity> updateClient_Pre($grpc.ServiceCall $call, $async.Future<$0.UpdateClientReq> $request) async {
    return updateClient($call, await $request);
  }

  $async.Future<$0.ClientEntity> updateClient($grpc.ServiceCall call, $0.UpdateClientReq request);

  $async.Future<$0.ClientEntity> getClient_Pre($grpc.ServiceCall $call, $async.Future<$0.GetClientReq> $request) async {
    return getClient($call, await $request);
  }

  $async.Future<$0.ClientEntity> getClient($grpc.ServiceCall call, $0.GetClientReq request);

}
