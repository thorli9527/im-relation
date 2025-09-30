// lib/models/system/system_config.dart
import 'package:isar/isar.dart';

part 'system_config.g.dart';

/// 系统配置表：用于本地存储一些通用配置信息，如登录状态、用户名、令牌创建时间等。
/// 每条配置是一个键值对（枚举标识 + 字符串内容）
@collection
class SystemConfig {
  /// 主键 ID，自增，无需手动赋值
  Id id = Isar.autoIncrement;

  /// 配置类型（枚举标识），用于区别不同的配置项
  /// 示例：ConfigTypeEnum.USER_NAME 表示存储用户名的配置
  ///
  /// 注意：
  /// - Isar 会将 enum 作为整数存储（通过 index）
  /// - 使用时必须初始化（配合 late）
  @enumerated
  @Index(unique: true)
  late ConfigTypeEnum configType;

  /// 配置内容的值，使用字符串存储（可存 text, 时间戳, bool 字符串等）
  /// 示例：
  /// - 用户名："Alice"
  /// - 登录状态："true"
  /// - 令牌创建时间："1689475000000"
  late String content;
}

/// 配置类型枚举：用于标识每种配置项的逻辑用途
/// 可用于本地存储的通用 key
enum ConfigTypeEnum {
  /// 是否已登录（"true"/"false"）
  LOGIN_STATUS,
  /// 登录方式（"email"/"phone"）
  LOGIN_TYPE,
  /// 登录方式对应内容 （邮箱/手机号）
  LOGIN_CONTENT,
  /// 用户TOKEN
  TOKEN,
  /// 用户ID
  UID,
  /// Token 过期时间
  TOKEN_EXPIRE_TIME,
  /// 主题模式
  THEME_MODE,
  /// 首次启动时间戳
  FIRST_START_TIME,
  /// 用户昵称
  NICKNAME,
  /// 用户头像
  AVATAR,
  /// 设备ID
  DEVICE_ID
}
