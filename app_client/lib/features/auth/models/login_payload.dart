/// 登录请求相关的轻量模型与辅助枚举。
import 'package:im_client/gen/api/auth.pb.dart';

/// Backend `UserLogType` ids mirrored here to avoid magic numbers.
class UserLogTypeId {
  static const phone = 1;
  static const email = 2;
  static const qrCode = 3;
  static const loginName = 4;
}

/// Supported login methods aligned with the backend `UserLogType`.
enum LoginMethod {
  username,
  email,
  phone,
}

extension LoginMethodX on LoginMethod {
  int get loginTypeValue {
    switch (this) {
      case LoginMethod.username:
        return UserLogTypeId.loginName;
      case LoginMethod.email:
        return UserLogTypeId.email;
      case LoginMethod.phone:
        return UserLogTypeId.phone;
    }
  }

  static LoginMethod? fromLoginType(int value) {
    switch (value) {
      case UserLogTypeId.loginName:
        return LoginMethod.username;
      case UserLogTypeId.email:
        return LoginMethod.email;
      case UserLogTypeId.phone:
        return LoginMethod.phone;
      default:
        return null;
    }
  }
}

/// 构造用于 gRPC 的登录请求，附带序列化工具。
class LoginRequestPayload {
  LoginRequestPayload({
    required this.loginMethod,
    required this.target,
    required this.password,
    required this.deviceType,
    required this.deviceId,
  });

  final LoginMethod loginMethod;
  final String target;
  final String password;
  final int deviceType;
  final String deviceId;

  int get loginType => loginMethod.loginTypeValue;

  LoginRequest toProto() => LoginRequest()
    ..loginType = loginType
    ..target = target
    ..password = password
    ..deviceType = deviceType
    ..deviceId = deviceId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'login_type': loginType,
        'target': target,
        'password': password,
        'device_type': deviceType,
        'device_id': deviceId,
      };
}
