import 'package:isar/isar.dart';

import 'message_status.dart';

part 'outbox_message_entity.g.dart';

/// 待发送消息队列，用于补偿 socket 网络波动。
@collection
class OutboxMessageEntity {
  OutboxMessageEntity();

  Id id = Isar.autoIncrement;

  @Index()
  late int ownerId;

  /// 如果是好友会话，则为好友 ID；群会话则为群 ID。
  @Index()
  late int targetId;

  /// 是否为群聊。
  late bool isGroup;

  /// 对应 socket.MsgKind。
  late int kind;

  /// 业务消息 ID（对于聊天消息为 message.Content.message_id）。
  int? messageId;
  
  /// 客户端生成的唯一消息 ID，用于幂等和 ACK 匹配。
  @Index()
  late int clientMessageId;
  
  /// 已经尝试发送的次数。
  int retryCount = 0;
  
  /// 最后一次发送时间戳（毫秒）。
  int? lastAttemptAt;

  @Index()
  late int createdAt;

  /// 发送状态。
  late int status;

  /// 底层载荷类型，用于还原 pb（例如 message.Content）。
  late String payloadType;

  /// 原始载荷字节。
  List<int> payload = [];
}

extension OutboxStatusX on OutboxMessageEntity {
  MessageDeliveryStatus get deliveryStatus =>
      MessageDeliveryStatus.values[status];

  set deliveryStatus(MessageDeliveryStatus value) {
    status = value.index;
  }
}
