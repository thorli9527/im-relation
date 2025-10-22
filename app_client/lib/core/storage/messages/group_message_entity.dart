import 'package:isar/isar.dart';

import 'message_status.dart';

part 'group_message_entity.g.dart';

@collection
class GroupMessageEntity {
  GroupMessageEntity();

  Id id = Isar.autoIncrement;

  @Index()
  late int ownerId;

  @Index()
  late int groupId;

  @Index(unique: true)
  late int messageId;

  late int senderId;

  @Index()
  late int timestamp;

  /// socket.MsgKind value.
  late int kind;

  /// 是否为当前用户发送。
  late bool isOutgoing;

  /// 传输状态。
  late int deliveryStatus;

  String? textPreview;

  List<int> payload = [];
}

extension GroupMessageDeliveryStatusX on GroupMessageEntity {
  MessageDeliveryStatus get status =>
      MessageDeliveryStatus.values[deliveryStatus];

  set status(MessageDeliveryStatus value) {
    deliveryStatus = value.index;
  }
}
