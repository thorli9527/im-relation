import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/auth_session.dart';
import '../models/user_profile.dart';
import '../sample/sample_data.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<String> login(LoginPayload payload) async {
    final data = await _client.post('/auth/login', data: payload.toJson());
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ApiClientException('登录返回缺少令牌');
    }
    return token;
  }

  Future<String> requestRegisterCode(RegisterPayload payload) async {
    final response = await _client.post(
      '/auth/register/build/code',
      data: payload.toJson(),
    );
    final regId = response['regId'] as String? ?? response['reg_id'] as String?;
    if (regId == null || regId.isEmpty) {
      throw const ApiClientException('未获取到注册标识');
    }
    return regId;
  }

  Future<void> verifyRegister({required String regId, required String code}) async {
    await _client.post(
      '/auth/register/verify_code',
      data: {
        'reg_id': regId,
        'code': code,
      },
    );
  }

  Future<UserProfile> fetchProfile() async {
    try {
      final data = await _client.get('/auth/profile');
      if (data.isEmpty) {
        return SampleData.demoUser;
      }
      return UserProfile.fromJson(data);
    } on ApiClientException {
      return SampleData.demoUser;
    } on DioException {
      return SampleData.demoUser;
    }
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } catch (_) {
      // best effort
    }
  }
}

class LoginPayload {
  const LoginPayload({
    required this.identifier,
    required this.target,
    required this.password,
    required this.deviceId,
  });

  final LoginIdentifier identifier;
  final String target;
  final String password;
  final String deviceId;

  Map<String, dynamic> toJson() {
    return {
      'login_type': identifier.apiValue,
      'target': target,
      'password': password,
      'device_type': DeviceType.pc.apiValue,
      'device_id': deviceId,
    };
  }
}

class RegisterPayload {
  const RegisterPayload({
    required this.displayName,
    required this.password,
    required this.type,
    required this.target,
  });

  final String displayName;
  final String password;
  final RegisterType type;
  final String target;

  Map<String, dynamic> toJson() {
    return {
      'name': displayName,
      'password': password,
      'reg_type': type.apiValue,
      'target': target,
    };
  }
}

enum LoginIdentifier { phone, email, qrCode, loginName }

enum RegisterType { phone, email, loginName }

enum DeviceType { mobile(1), web(3), pc(4); }

extension LoginIdentifierMapper on LoginIdentifier {
  int get apiValue {
    switch (this) {
      case LoginIdentifier.phone:
        return 1;
      case LoginIdentifier.email:
        return 2;
      case LoginIdentifier.qrCode:
        return 3;
      case LoginIdentifier.loginName:
        return 4;
    }
  }
}

extension RegisterTypeMapper on RegisterType {
  int get apiValue {
    switch (this) {
      case RegisterType.phone:
        return 1;
      case RegisterType.email:
        return 2;
      case RegisterType.loginName:
        return 3;
    }
  }
}

extension DeviceTypeMapper on DeviceType {
  const DeviceTypeMapper(this.apiValue);
  final int apiValue;
}
