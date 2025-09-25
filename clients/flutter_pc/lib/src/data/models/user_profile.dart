class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.statusMessage,
    this.phone,
    this.email,
    this.isOnline = true,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? statusMessage;
  final String? phone;
  final String? email;
  final bool isOnline;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '0',
      displayName: json['displayName'] as String? ??
          json['nickname'] as String? ??
          json['name'] as String? ??
          '未命名用户',
      avatarUrl: json['avatar'] as String? ?? json['avatarUrl'] as String?,
      statusMessage: json['status'] as String? ?? json['signature'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isOnline: json['isOnline'] as bool? ?? json['online'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'status': statusMessage,
      'phone': phone,
      'email': email,
      'isOnline': isOnline,
    }..removeWhere((key, value) => value == null);
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    String? statusMessage,
    String? phone,
    String? email,
    bool? isOnline,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      statusMessage: statusMessage ?? this.statusMessage,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  static const empty = UserProfile(id: '0', displayName: '访客');
}
