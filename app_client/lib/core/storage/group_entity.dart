import 'package:isar/isar.dart';

part 'group_entity.g.dart';

/// 本地群信息缓存。
@collection
class GroupEntity {
  GroupEntity();

  Id id = Isar.autoIncrement;

  /// 当前登录用户 ID。
  @Index(
    unique: true,
    replace: true,
    composite: [CompositeIndex('groupId')],
  )
  late int ownerId;

  /// 群 ID。
  late int groupId;

  /// 群名称。
  @Index()
  late String name;

  /// 群头像。
  String? avatar;

  /// 群公告。
  String? notice;

  /// 本地记录更新时间（毫秒）。
  @Index()
  late int updatedAt;
}
