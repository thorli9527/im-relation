enum MessageDirection { incoming, outgoing, system }

enum MessageStatus { sending, sent, delivered, read, failed }

enum MessageContentType { text, image, audio, video, file, system }

class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.direction,
    this.status = MessageStatus.sent,
    this.type = MessageContentType.text,
    this.isEncrypted = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageDirection direction;
  final MessageStatus status;
  final MessageContentType type;
  final bool isEncrypted;

  bool get isOutgoing => direction == MessageDirection.outgoing;

  bool get isSystem => direction == MessageDirection.system;

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    DateTime? timestamp,
    MessageDirection? direction,
    MessageStatus? status,
    MessageContentType? type,
    bool? isEncrypted,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      type: type ?? this.type,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    final directionValue = (json['direction'] as String?) ??
        (json['isOutgoing'] == true ? 'outgoing' : 'incoming');
    final typeValue = (json['type'] as String?) ?? 'text';
    return Message(
      id: json['id']?.toString() ?? json['messageId']?.toString() ?? '',
      conversationId:
          json['conversationId']?.toString() ?? json['sessionId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? json['from']?.toString() ?? '',
      content: json['content'] as String? ?? json['body'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      direction: MessageDirection.values.firstWhere(
        (item) => item.name == directionValue,
        orElse: () => MessageDirection.incoming,
      ),
      status: MessageStatus.values.firstWhere(
        (item) => item.name == (json['status'] as String? ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      type: MessageContentType.values.firstWhere(
        (item) => item.name == typeValue,
        orElse: () => MessageContentType.text,
      ),
      isEncrypted: json['isEncrypted'] as bool? ?? false,
    );
  }

  static Message system({
    required String id,
    required String conversationId,
    required String content,
  }) {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: 'system',
      content: content,
      timestamp: DateTime.now(),
      direction: MessageDirection.system,
      status: MessageStatus.delivered,
      type: MessageContentType.system,
      isEncrypted: false,
    );
  }
}
