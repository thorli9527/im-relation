// This is a generated file - do not edit.
//
// Generated from auth.proto.

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

import 'auth.pb.dart' as $0;

export 'auth.pb.dart';

/// 对外 API 服务，兼顾注册、登录与账号管理接口。
@$pb.GrpcServiceName('api.ApiService')
class ApiServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ApiServiceClient(super.channel, {super.options, super.interceptors});

  /// 生成注册验证码：手机/邮箱注册场景需调用。
  $grpc.ResponseFuture<$0.BuildRegisterCodeResponse> buildRegisterCode($0.BuildRegisterCodeRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$buildRegisterCode, request, options: options);
  }

  /// 校验注册验证码：用户输入验证码后触发。
  $grpc.ResponseFuture<$0.VerifyRegisterCodeResponse> verifyRegisterCode($0.VerifyRegisterCodeRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$verifyRegisterCode, request, options: options);
  }

  /// 执行登录流程：校验账号密码并下发会话信息。
  $grpc.ResponseFuture<$0.LoginResponse> login($0.LoginRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$login, request, options: options);
  }

  /// 校验 session_token 有效性，并返回关联用户信息。
  $grpc.ResponseFuture<$0.ValidateSessionTokenResponse> validateSessionToken($0.ValidateSessionTokenRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$validateSessionToken, request, options: options);
  }

  /// 修改当前账号密码。
  $grpc.ResponseFuture<$0.ChangePasswordResponse> changePassword($0.ChangePasswordRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$changePassword, request, options: options);
  }

  /// 替换绑定手机号。
  $grpc.ResponseFuture<$0.ChangePhoneResponse> changePhone($0.ChangePhoneRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$changePhone, request, options: options);
  }

  /// 替换绑定邮箱。
  $grpc.ResponseFuture<$0.ChangeEmailResponse> changeEmail($0.ChangeEmailRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$changeEmail, request, options: options);
  }

  /// 更新昵称、头像等基础资料。
  $grpc.ResponseFuture<$0.UpdateProfileResponse> updateProfile($0.UpdateProfileRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$updateProfile, request, options: options);
  }

  /// 获取当前用户好友列表
  $grpc.ResponseFuture<$0.GetFriendListResponse> getFriendList($0.GetFriendListRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$getFriendList, request, options: options);
  }

  /// 获取指定群的成员列表
  $grpc.ResponseFuture<$0.GetGroupMembersResponse> getGroupMembers($0.GetGroupMembersRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$getGroupMembers, request, options: options);
  }

  /// 获取群成员详情，同时返回是否为好友
  $grpc.ResponseFuture<$0.GetGroupMemberDetailResponse> getGroupMemberDetail($0.GetGroupMemberDetailRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$getGroupMemberDetail, request, options: options);
  }

  $grpc.ResponseFuture<$0.SearchUserResponse> searchUser($0.SearchUserRequest request, {$grpc.CallOptions? options,}) {
    return $createUnaryCall(_$searchUser, request, options: options);
  }

    // method descriptors

  static final _$buildRegisterCode = $grpc.ClientMethod<$0.BuildRegisterCodeRequest, $0.BuildRegisterCodeResponse>(
      '/api.ApiService/BuildRegisterCode',
      ($0.BuildRegisterCodeRequest value) => value.writeToBuffer(),
      $0.BuildRegisterCodeResponse.fromBuffer);
  static final _$verifyRegisterCode = $grpc.ClientMethod<$0.VerifyRegisterCodeRequest, $0.VerifyRegisterCodeResponse>(
      '/api.ApiService/VerifyRegisterCode',
      ($0.VerifyRegisterCodeRequest value) => value.writeToBuffer(),
      $0.VerifyRegisterCodeResponse.fromBuffer);
  static final _$login = $grpc.ClientMethod<$0.LoginRequest, $0.LoginResponse>(
      '/api.ApiService/Login',
      ($0.LoginRequest value) => value.writeToBuffer(),
      $0.LoginResponse.fromBuffer);
  static final _$validateSessionToken = $grpc.ClientMethod<$0.ValidateSessionTokenRequest, $0.ValidateSessionTokenResponse>(
      '/api.ApiService/ValidateSessionToken',
      ($0.ValidateSessionTokenRequest value) => value.writeToBuffer(),
      $0.ValidateSessionTokenResponse.fromBuffer);
  static final _$changePassword = $grpc.ClientMethod<$0.ChangePasswordRequest, $0.ChangePasswordResponse>(
      '/api.ApiService/ChangePassword',
      ($0.ChangePasswordRequest value) => value.writeToBuffer(),
      $0.ChangePasswordResponse.fromBuffer);
  static final _$changePhone = $grpc.ClientMethod<$0.ChangePhoneRequest, $0.ChangePhoneResponse>(
      '/api.ApiService/ChangePhone',
      ($0.ChangePhoneRequest value) => value.writeToBuffer(),
      $0.ChangePhoneResponse.fromBuffer);
  static final _$changeEmail = $grpc.ClientMethod<$0.ChangeEmailRequest, $0.ChangeEmailResponse>(
      '/api.ApiService/ChangeEmail',
      ($0.ChangeEmailRequest value) => value.writeToBuffer(),
      $0.ChangeEmailResponse.fromBuffer);
  static final _$updateProfile = $grpc.ClientMethod<$0.UpdateProfileRequest, $0.UpdateProfileResponse>(
      '/api.ApiService/UpdateProfile',
      ($0.UpdateProfileRequest value) => value.writeToBuffer(),
      $0.UpdateProfileResponse.fromBuffer);
  static final _$getFriendList = $grpc.ClientMethod<$0.GetFriendListRequest, $0.GetFriendListResponse>(
      '/api.ApiService/GetFriendList',
      ($0.GetFriendListRequest value) => value.writeToBuffer(),
      $0.GetFriendListResponse.fromBuffer);
  static final _$getGroupMembers = $grpc.ClientMethod<$0.GetGroupMembersRequest, $0.GetGroupMembersResponse>(
      '/api.ApiService/GetGroupMembers',
      ($0.GetGroupMembersRequest value) => value.writeToBuffer(),
      $0.GetGroupMembersResponse.fromBuffer);
  static final _$getGroupMemberDetail = $grpc.ClientMethod<$0.GetGroupMemberDetailRequest, $0.GetGroupMemberDetailResponse>(
      '/api.ApiService/GetGroupMemberDetail',
      ($0.GetGroupMemberDetailRequest value) => value.writeToBuffer(),
      $0.GetGroupMemberDetailResponse.fromBuffer);
  static final _$searchUser = $grpc.ClientMethod<$0.SearchUserRequest, $0.SearchUserResponse>(
      '/api.ApiService/SearchUser',
      ($0.SearchUserRequest value) => value.writeToBuffer(),
      $0.SearchUserResponse.fromBuffer);
}

@$pb.GrpcServiceName('api.ApiService')
abstract class ApiServiceBase extends $grpc.Service {
  $core.String get $name => 'api.ApiService';

  ApiServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.BuildRegisterCodeRequest, $0.BuildRegisterCodeResponse>(
        'BuildRegisterCode',
        buildRegisterCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BuildRegisterCodeRequest.fromBuffer(value),
        ($0.BuildRegisterCodeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.VerifyRegisterCodeRequest, $0.VerifyRegisterCodeResponse>(
        'VerifyRegisterCode',
        verifyRegisterCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.VerifyRegisterCodeRequest.fromBuffer(value),
        ($0.VerifyRegisterCodeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoginRequest, $0.LoginResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginRequest.fromBuffer(value),
        ($0.LoginResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ValidateSessionTokenRequest, $0.ValidateSessionTokenResponse>(
        'ValidateSessionToken',
        validateSessionToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ValidateSessionTokenRequest.fromBuffer(value),
        ($0.ValidateSessionTokenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangePasswordRequest, $0.ChangePasswordResponse>(
        'ChangePassword',
        changePassword_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChangePasswordRequest.fromBuffer(value),
        ($0.ChangePasswordResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangePhoneRequest, $0.ChangePhoneResponse>(
        'ChangePhone',
        changePhone_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChangePhoneRequest.fromBuffer(value),
        ($0.ChangePhoneResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeEmailRequest, $0.ChangeEmailResponse>(
        'ChangeEmail',
        changeEmail_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChangeEmailRequest.fromBuffer(value),
        ($0.ChangeEmailResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateProfileRequest, $0.UpdateProfileResponse>(
        'UpdateProfile',
        updateProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateProfileRequest.fromBuffer(value),
        ($0.UpdateProfileResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetFriendListRequest, $0.GetFriendListResponse>(
        'GetFriendList',
        getFriendList_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetFriendListRequest.fromBuffer(value),
        ($0.GetFriendListResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGroupMembersRequest, $0.GetGroupMembersResponse>(
        'GetGroupMembers',
        getGroupMembers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetGroupMembersRequest.fromBuffer(value),
        ($0.GetGroupMembersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGroupMemberDetailRequest, $0.GetGroupMemberDetailResponse>(
        'GetGroupMemberDetail',
        getGroupMemberDetail_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetGroupMemberDetailRequest.fromBuffer(value),
        ($0.GetGroupMemberDetailResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SearchUserRequest, $0.SearchUserResponse>(
        'SearchUser',
        searchUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SearchUserRequest.fromBuffer(value),
        ($0.SearchUserResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.BuildRegisterCodeResponse> buildRegisterCode_Pre($grpc.ServiceCall $call, $async.Future<$0.BuildRegisterCodeRequest> $request) async {
    return buildRegisterCode($call, await $request);
  }

  $async.Future<$0.BuildRegisterCodeResponse> buildRegisterCode($grpc.ServiceCall call, $0.BuildRegisterCodeRequest request);

  $async.Future<$0.VerifyRegisterCodeResponse> verifyRegisterCode_Pre($grpc.ServiceCall $call, $async.Future<$0.VerifyRegisterCodeRequest> $request) async {
    return verifyRegisterCode($call, await $request);
  }

  $async.Future<$0.VerifyRegisterCodeResponse> verifyRegisterCode($grpc.ServiceCall call, $0.VerifyRegisterCodeRequest request);

  $async.Future<$0.LoginResponse> login_Pre($grpc.ServiceCall $call, $async.Future<$0.LoginRequest> $request) async {
    return login($call, await $request);
  }

  $async.Future<$0.LoginResponse> login($grpc.ServiceCall call, $0.LoginRequest request);

  $async.Future<$0.ValidateSessionTokenResponse> validateSessionToken_Pre($grpc.ServiceCall $call, $async.Future<$0.ValidateSessionTokenRequest> $request) async {
    return validateSessionToken($call, await $request);
  }

  $async.Future<$0.ValidateSessionTokenResponse> validateSessionToken($grpc.ServiceCall call, $0.ValidateSessionTokenRequest request);

  $async.Future<$0.ChangePasswordResponse> changePassword_Pre($grpc.ServiceCall $call, $async.Future<$0.ChangePasswordRequest> $request) async {
    return changePassword($call, await $request);
  }

  $async.Future<$0.ChangePasswordResponse> changePassword($grpc.ServiceCall call, $0.ChangePasswordRequest request);

  $async.Future<$0.ChangePhoneResponse> changePhone_Pre($grpc.ServiceCall $call, $async.Future<$0.ChangePhoneRequest> $request) async {
    return changePhone($call, await $request);
  }

  $async.Future<$0.ChangePhoneResponse> changePhone($grpc.ServiceCall call, $0.ChangePhoneRequest request);

  $async.Future<$0.ChangeEmailResponse> changeEmail_Pre($grpc.ServiceCall $call, $async.Future<$0.ChangeEmailRequest> $request) async {
    return changeEmail($call, await $request);
  }

  $async.Future<$0.ChangeEmailResponse> changeEmail($grpc.ServiceCall call, $0.ChangeEmailRequest request);

  $async.Future<$0.UpdateProfileResponse> updateProfile_Pre($grpc.ServiceCall $call, $async.Future<$0.UpdateProfileRequest> $request) async {
    return updateProfile($call, await $request);
  }

  $async.Future<$0.UpdateProfileResponse> updateProfile($grpc.ServiceCall call, $0.UpdateProfileRequest request);

  $async.Future<$0.GetFriendListResponse> getFriendList_Pre($grpc.ServiceCall $call, $async.Future<$0.GetFriendListRequest> $request) async {
    return getFriendList($call, await $request);
  }

  $async.Future<$0.GetFriendListResponse> getFriendList($grpc.ServiceCall call, $0.GetFriendListRequest request);

  $async.Future<$0.GetGroupMembersResponse> getGroupMembers_Pre($grpc.ServiceCall $call, $async.Future<$0.GetGroupMembersRequest> $request) async {
    return getGroupMembers($call, await $request);
  }

  $async.Future<$0.GetGroupMembersResponse> getGroupMembers($grpc.ServiceCall call, $0.GetGroupMembersRequest request);

  $async.Future<$0.GetGroupMemberDetailResponse> getGroupMemberDetail_Pre($grpc.ServiceCall $call, $async.Future<$0.GetGroupMemberDetailRequest> $request) async {
    return getGroupMemberDetail($call, await $request);
  }

  $async.Future<$0.GetGroupMemberDetailResponse> getGroupMemberDetail($grpc.ServiceCall call, $0.GetGroupMemberDetailRequest request);

  $async.Future<$0.SearchUserResponse> searchUser_Pre($grpc.ServiceCall $call, $async.Future<$0.SearchUserRequest> $request) async {
    return searchUser($call, await $request);
  }

  $async.Future<$0.SearchUserResponse> searchUser($grpc.ServiceCall call, $0.SearchUserRequest request);

}
