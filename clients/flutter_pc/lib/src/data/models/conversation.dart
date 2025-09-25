import 'contact.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.contact,
    this.lastMessagePreview,
    this.lastTimestamp,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
  });

  final String id;
  final Contact contact;
  final String? lastMessagePreview;
  final DateTime? lastTimestamp;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;

  Conversation copyWith({
    String? id,
    Contact? contact,
    String? lastMessagePreview,
    DateTime? lastTimestamp,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
  }) {
    return Conversation(
      id: id ?? this.id,
      contact: contact ?? this.contact,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastTimestamp: lastTimestamp ?? this.lastTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? json['conversationId']?.toString() ?? '0',
      contact: json['contact'] is Map<String, dynamic>
          ? Contact.fromJson(json['contact'] as Map<String, dynamic>)
          : Contact.fromJson(json),
      lastMessagePreview: json['lastMessage'] as String? ??
          json['lastMessagePreview'] as String?,
      lastTimestamp: json['lastTimestamp'] != null
          ? DateTime.tryParse(json['lastTimestamp'].toString())
          : null,
      unreadCount: json['unreadCount'] as int? ?? json['unread'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? json['pinned'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? json['muted'] as bool? ?? false,
    );
  }
}
