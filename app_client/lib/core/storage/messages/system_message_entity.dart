import 'package:isar/isar.dart';

part 'system_message_entity.g.dart';

/// 系统通知消息的本地存储。
@collection
class SystemMessageEntity {
  SystemMessageEntity();

  Id id = Isar.autoIncrement;

  @Index()
  late int ownerId;

  @Index(unique: true)
  late int messageId;

  /// socket.MsgKind value.
  late int kind;

  @Index()
  late int timestamp;

  /// 可选的文本摘要，便于展示。
  String? textPreview;

  /// 原始载荷。
  List<int> payload = [];
}
