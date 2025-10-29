import 'package:isar/isar.dart';

import 'message_status.dart';

part 'friend_message_entity.g.dart';

/// 好友聊天消息的本地缓存表。
@collection
class FriendMessageEntity {
  FriendMessageEntity();

  Id id = Isar.autoIncrement;

  @Index()
  late int ownerId;

  @Index()
  late int friendId;

  @Index(unique: true)
  late int messageId;

  late int senderId;

  late int receiverId;

  @Index()
  late int timestamp;

  /// socket.MsgKind value.
  late int kind;

  /// 是否为当前登录用户主动发送。
  late bool isOutgoing;

  /// 消息传输状态。
  late int deliveryStatus;

  /// 文本摘要，便于快速渲染列表。
  String? textPreview;

  /// 原始消息内容（例如 message.Content 的编码）。
  List<int> payload = [];
}

extension FriendMessageDeliveryStatusX on FriendMessageEntity {
  MessageDeliveryStatus get status =>
      MessageDeliveryStatus.values[deliveryStatus];

  set status(MessageDeliveryStatus value) {
    deliveryStatus = value.index;
  }
}
