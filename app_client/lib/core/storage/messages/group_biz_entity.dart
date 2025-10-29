import 'package:isar/isar.dart';

part 'group_biz_entity.g.dart';

/// 群聊业务事件（公告、头像等变更）。
@collection
class GroupBizEntity {
  GroupBizEntity();

  Id id = Isar.autoIncrement;

  @Index()
  late int ownerId;

  @Index()
  late int groupId;

  @Index(unique: true)
  late int eventId;

  /// socket.MsgKind value.
  late int kind;

  @Index()
  late int timestamp;

  List<int> payload = [];
}
