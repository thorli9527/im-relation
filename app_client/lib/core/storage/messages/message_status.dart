/// 消息投递状态，既用于本地消息也用于出站队列。
enum MessageDeliveryStatus { pending, sending, sent, received, failed }

/// 出站消息类型，便于扩展其他发送场景。
enum OutboxMessageType { friendText, unknown }
