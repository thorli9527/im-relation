import 'package:isar/isar.dart';

part 'device_profile.g.dart';

/// 设备信息，仅维护一条记录。
@collection
class DeviceProfile {
  DeviceProfile();

  /// 全局唯一记录，固定为 0。
  Id id = 0;

  /// 设备标识，用于登录参数。
  late String deviceId;

  /// 设备类型（对应后端 DeviceType 枚举值）。
  late int deviceType;

  /// 创建时间，便于排查问题。
  late DateTime createdAt;

  /// 最近一次更新，是为了后续可能扩展字段。
  late DateTime updatedAt;
}
