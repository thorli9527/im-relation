import 'package:isar/isar.dart';

part 'friend_entity.g.dart';

/// 本地好友资料。
@collection
class FriendEntity {
  FriendEntity();

  Id id = Isar.autoIncrement;

  /// 当前登录用户 ID。
  @Index(
    unique: true,
    replace: true,
    composite: [CompositeIndex('friendId')],
  )
  late int ownerId;

  /// 好友用户 ID。
  late int friendId;

  /// 添加时间（毫秒）。
  @Index()
  late int addedAt;

  /// 添加来源（例如手机号/邮箱/搜索）。
  String? addSource;

  /// 备注名。
  String? alias;

  /// 头像 URL。
  String? avatar;

  /// 备注信息。
  String? remark;

  /// 上次更新本地缓存的时间。
  @Index()
  late int updatedAt;
}
