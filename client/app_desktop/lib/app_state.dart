import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/src/rust/api/config_api.dart' as config_api;

/// 全局维护的联系人模型。
class Contact {
  Contact({
    required this.name,
    required this.subtitle,
    this.nickname,
    this.friendId,
    this.color,
    this.avatarUrl,
    this.lastLoginAt,
  });

  final String name;
  final String subtitle;
  final String? nickname;
  final int? friendId;
  final Color? color;
  final String? avatarUrl;
  final int? lastLoginAt;

  /// 根据 friendId 生成稳定的背景色（无头像时使用）。
  Color generatedColor() {
    if (color != null) return color!;
    if (friendId == null) return Colors.blueGrey;
    final idx = friendId!.abs() % _avatarPalette.length;
    return _avatarPalette[idx];
  }
}

/// 32 组预设色，哈希取模使用。
const List<Color> _avatarPalette = [
  Color(0xFFE57373),
  Color(0xFFF06292),
  Color(0xFFBA68C8),
  Color(0xFF9575CD),
  Color(0xFF7986CB),
  Color(0xFF64B5F6),
  Color(0xFF4FC3F7),
  Color(0xFF4DD0E1),
  Color(0xFF4DB6AC),
  Color(0xFF81C784),
  Color(0xFFAED581),
  Color(0xFFFF8A65),
  Color(0xFFD4E157),
  Color(0xFFFFD54F),
  Color(0xFFFFB74D),
  Color(0xFFA1887F),
  Color(0xFF90A4AE),
  Color(0xFFFF7043),
  Color(0xFFAB47BC),
  Color(0xFF5C6BC0),
  Color(0xFF42A5F5),
  Color(0xFF26C6DA),
  Color(0xFF26A69A),
  Color(0xFF66BB6A),
  Color(0xFFDCE775),
  Color(0xFFFFEE58),
  Color(0xFFFFCA28),
  Color(0xFFFFA726),
  Color(0xFF8D6E63),
  Color(0xFF78909C),
  Color(0xFF26A69A),
  Color(0xFFEF9A9A),
];

/// 选中的好友 ID。
final selectedFriendProvider = StateProvider<int?>((_) => null);

/// 全局联系人列表。
class FriendsNotifier extends StateNotifier<List<Contact>> {
  FriendsNotifier() : super(const []);

  void setFriends(List<Contact> friends) {
    state = friends;
  }
}

final friendsProvider =
    StateNotifierProvider<FriendsNotifier, List<Contact>>(
        (ref) => FriendsNotifier());

/// 好友申请数据
class FriendRequest {
  FriendRequest({
    required this.name,
    required this.fromUid,
    this.nickname,
    this.avatarUrl,
    this.remark,
    this.signature,
    this.accepted = false,
  });

  final String name;
  final int fromUid;
  final String? nickname;
  final String? avatarUrl;
  final String? remark;
  final String? signature;
  final bool accepted;
}

class FriendRequestNotifier extends StateNotifier<List<FriendRequest>> {
  FriendRequestNotifier() : super(const []);

  void setRequests(List<FriendRequest> list) {
    state = list;
  }

  void clear() {
    state = const [];
  }
}

final friendRequestsProvider =
    StateNotifierProvider<FriendRequestNotifier, List<FriendRequest>>(
        (_) => FriendRequestNotifier());

/// 当前界面覆盖的语言。
final localeOverrideProvider = StateProvider<Locale?>((_) => null);

/// 从配置中读取上次保存的语言。
final savedLocaleProvider = FutureProvider<Locale?>((ref) async {
  final lang = await config_api.getLanguage();
  if (lang == null || lang.isEmpty) return null;
  if (lang.startsWith('zh')) return const Locale('zh', 'CN');
  if (lang.startsWith('en')) return const Locale('en', 'US');
  return null;
});
