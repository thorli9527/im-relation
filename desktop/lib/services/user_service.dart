// 文件路径: lib/services/user_service.dart

import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:im_client/channel/stream_client.dart';
import 'package:im_client/config/app_config.dart';
import 'package:im_client/models/api_response.dart';
import 'package:im_client/models/generated/api/auth.pbgrpc.dart'
    show ApiServiceClient, LoginRequest, LoginResponse;
import 'package:im_client/models/generated/online/hot_online.pb.dart'
    show ValidateSessionTokenRequest, ValidateSessionTokenResponse;
import 'package:im_client/models/generated/online/hot_online.pbgrpc.dart'
    show OnlineServiceClient;
import 'package:im_client/models/generated/online/hot_online.pbenum.dart'
    show DeviceType, SessionTokenStatus;
import 'package:im_client/models/generated/socket/socket.pbenum.dart' as socket;
import 'package:im_client/services/app_config_service.dart';
import 'package:im_client/utils/id_utils.dart';
import 'package:im_client/utils/log_util.dart';
import 'package:riverpod/riverpod.dart';

import '../models/system/system_config.dart';
import '../utils/validator_util.dart';

class UserService {
  final Ref _ref;

  UserService(this._ref);

  /// 使用 app_api 完成登录并建立 socket 链路
  Future<ApiResponse> loginWithSocket({
    required String authContent,
    required String password,
  }) async {
    try {
      LogUtil.info('UserService', '🔐 开始登录流程: $authContent');

      final bool isMail = ValidatorUtil.isEmail(authContent);
      final bool isPhone = ValidatorUtil.isPhone(authContent);
      if (!isMail && !isPhone) {
        return ApiResponse(
          code: 400,
          success: false,
          message: '请输入正确的邮箱或手机号',
        );
      }

      final appConfigService = await _ref.read(appConfigServiceProvider.future);
      final deviceId =
          appConfigService.deviceId ?? await _ensureDeviceId(appConfigService);

      final loginResponse = await _loginViaGrpc(
        authContent: authContent,
        password: password,
        deviceId: deviceId,
        loginType: isMail ? 2 : 1, // UserLogType: Phone=1, Email=2
      );

      final sessionInfo = await _validateSessionToken(loginResponse.token);
      if (sessionInfo.status != SessionTokenStatus.STS_ACTIVE) {
        throw Exception('登录凭证校验失败，请重试');
      }

      final userId = sessionInfo.userId.toInt();
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        sessionInfo.expiresAt.toInt(),
        isUtc: true,
      );

      await _persistLoginState(
        token: loginResponse.token,
        expiresAt: expiresAt,
        loginType: isMail ? 'email' : 'phone',
        authContent: authContent,
        userId: userId,
      );

      final streamClient = _ref.read(streamClientProvider);
      final socketHost = loginResponse.socketHost.isNotEmpty
          ? loginResponse.socketHost
          : AppConfig.socketHost;
      final socketPort = loginResponse.socketPort != 0
          ? loginResponse.socketPort.toInt()
          : AppConfig.socketPort;

      final authContext = SocketAuthContext(
        userId: userId,
        deviceId: deviceId,
        token: loginResponse.token,
        deviceType: socket.DeviceType.PC,
        expiresAtMs: sessionInfo.expiresAt.toInt(),
      );

      await streamClient.connectWithAuth(
        host: socketHost,
        port: socketPort,
        auth: authContext,
      );

      LogUtil.info('UserService', '✅ 登录成功: uid=$userId, host=$socketHost');
      return ApiResponse(code: 200, success: true);
    } on SocketException catch (e) {
      LogUtil.error('UserService', '❌ Socket 连接失败', e);
      throw Exception(
        '网络连接失败，请确认 socket 服务运行在 ${AppConfig.socketHost}:${AppConfig.socketPort}',
      );
    } on GrpcError catch (e) {
      LogUtil.error('UserService', '❌ gRPC 调用失败', e);
      throw Exception(e.message ?? '登录失败');
    }
  }

  Future<bool> isLoggedIn() async {
    final appConfigService = await _ref.read(appConfigServiceProvider.future);
    final result =
        await appConfigService.getString(ConfigTypeEnum.LOGIN_STATUS);
    return result.fold(
      (status) => status == 'true',
      (exception) => false,
    );
  }

  Future<void> logout() async {
    try {
      LogUtil.info('UserService', '🚪 开始登出');
      final streamClient = _ref.read(streamClientProvider);
      await streamClient.closeConnection();

      final appConfigService = await _ref.read(appConfigServiceProvider.future);
      await _clearLoginState(appConfigService);

      LogUtil.info('UserService', '✅ 登出成功');
    } catch (e) {
      LogUtil.error('UserService', '❌ 登出失败', e);
      rethrow;
    }
  }

  Future<String?> getToken() async {
    final appConfigService = await _ref.read(appConfigServiceProvider.future);
    final result = await appConfigService.getString(ConfigTypeEnum.TOKEN);
    return result.fold(
      (token) => token,
      (exception) => null,
    );
  }

  Future<void> _persistLoginState({
    required String token,
    required DateTime expiresAt,
    required String loginType,
    required String authContent,
    required int userId,
  }) async {
    final appConfigService = await _ref.read(appConfigServiceProvider.future);
    await Future.wait([
      appConfigService.setString(ConfigTypeEnum.LOGIN_STATUS, 'true'),
      appConfigService.setString(ConfigTypeEnum.LOGIN_TYPE, loginType),
      appConfigService.setString(ConfigTypeEnum.LOGIN_CONTENT, authContent),
      appConfigService.setString(ConfigTypeEnum.TOKEN, token),
      appConfigService.setString(ConfigTypeEnum.UID, userId.toString()),
      appConfigService.setString(
        ConfigTypeEnum.TOKEN_EXPIRE_TIME,
        expiresAt.millisecondsSinceEpoch.toString(),
      ),
    ], eagerError: false);
  }

  Future<void> _clearLoginState(AppConfigService appConfigService) async {
    final keys = [
      ConfigTypeEnum.LOGIN_STATUS,
      ConfigTypeEnum.LOGIN_CONTENT,
      ConfigTypeEnum.LOGIN_TYPE,
      ConfigTypeEnum.TOKEN,
      ConfigTypeEnum.TOKEN_EXPIRE_TIME,
      ConfigTypeEnum.UID,
      ConfigTypeEnum.NICKNAME,
      ConfigTypeEnum.AVATAR,
    ];
    for (final key in keys) {
      await appConfigService.remove(key);
    }
  }

  Future<String> _ensureDeviceId(AppConfigService appConfigService) async {
    final deviceId = IdUtils.buildUuid();
    await appConfigService.setString(ConfigTypeEnum.DEVICE_ID, deviceId);
    return deviceId;
  }

  Future<LoginResponse> _loginViaGrpc({
    required String authContent,
    required String password,
    required String deviceId,
    required int loginType,
  }) async {
    final channel = ClientChannel(
      AppConfig.apiGrpcHost,
      port: AppConfig.apiGrpcPort,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    try {
      final client = ApiServiceClient(channel);
      final request = LoginRequest(
        loginType: loginType,
        password: password,
        target: authContent,
        deviceType: DeviceType.PC.value,
        deviceId: deviceId,
      );
      return await client.login(request);
    } finally {
      await channel.shutdown();
    }
  }

  Future<ValidateSessionTokenResponse> _validateSessionToken(
      String token) async {
    final channel = ClientChannel(
      AppConfig.onlineGrpcHost,
      port: AppConfig.onlineGrpcPort,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    try {
      final client = OnlineServiceClient(channel);
      return await client.validateSessionToken(
        ValidateSessionTokenRequest(sessionToken: token),
      );
    } finally {
      await channel.shutdown();
    }
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref);
});
