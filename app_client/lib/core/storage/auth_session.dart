import 'package:isar/isar.dart';

part 'auth_session.g.dart';

/// 登录会话状态，记录当前账号的缓存信息。
@collection
class AuthSession {
  AuthSession();

  /// 全局唯一记录，固定为 0。
  Id id = 0;

  /// 是否处于登录状态。
  bool isLoggedIn = false;

  /// 登录用户 ID。
  int? userId;

  /// 最近一次使用的登录类型（UserLogType 数值）。
  int? loginType;

  /// 登录使用的账号（手机号/邮箱/用户名）。
  String? account;

  /// 登录使用的明文密码，后续可考虑加密存储。
  String? password;

  /// 最近一次使用的设备类型。
  int? deviceType;

  /// 最近一次拿到的会话 token。
  String? token;

  /// token 过期时间毫秒时间戳。
  int? expiresAt;

  /// 最近一次登录返回的 socket 入口。
  String? socketAddr;

  /// 记录更新时间。
  DateTime? updatedAt;
}
