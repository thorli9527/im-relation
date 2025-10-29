import 'package:isar/isar.dart';

part 'friend_biz_entity.g.dart';

/// 好友相关业务事件（好友申请、备注更新等）。
@collection
class FriendBizEntity {
  FriendBizEntity();

  Id id = Isar.autoIncrement;

  @Index()
  late int ownerId;

  @Index()
  late int friendId;

  @Index(unique: true)
  late int eventId;

  /// 对应 socket.MsgKind 值。
  late int kind;

  @Index()
  late int timestamp;

  /// 原始业务载荷。
  List<int> payload = [];
}
