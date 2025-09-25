class Contact {
  const Contact({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.description,
    this.isOnline = false,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? description;
  final bool isOnline;

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id']?.toString() ?? '0',
      displayName: json['displayName'] as String? ??
          json['remark'] as String? ??
          json['name'] as String? ??
          '未知联系人',
      avatarUrl: json['avatar'] as String? ?? json['avatarUrl'] as String?,
      description: json['description'] as String? ??
          json['signature'] as String? ??
          json['status'] as String?,
      isOnline: json['isOnline'] as bool? ?? json['online'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'description': description,
      'isOnline': isOnline,
    }..removeWhere((key, value) => value == null);
  }

  Contact copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    String? description,
    bool? isOnline,
  }) {
    return Contact(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      description: description ?? this.description,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
