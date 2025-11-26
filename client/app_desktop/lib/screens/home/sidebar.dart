import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/screens/home/sidebar_actions.dart';
import 'package:app_desktop/screens/home/sidebar_list.dart';
import 'package:app_desktop/src/rust/api/chat_api.dart' as chat_api;
import 'package:app_desktop/src/rust/domain/friend_entity.dart';
import 'package:app_desktop/screens/home/sidebar_contact.dart';

class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  @override
  void initState() {
    super.initState();
    _loadLocalFriends();
  }

  Future<void> _loadLocalFriends() async {
    try {
      // 直接从 flutter_sdk 本地数据库分页读取好友数据，填充到状态。
      final page = await chat_api.getFriendPage(page: 1, pageSize: 200);
      final mapped = page.items.map<Contact>(_toContact).toList();
      ref.read(friendsProvider.notifier).setFriends(mapped);
      if (mapped.isNotEmpty) {
        ref.read(selectedFriendProvider.notifier).state = mapped.first.friendId;
      }
    } catch (e) {
      // 静默失败，保持现有列表。
    }
  }

  Contact _toContact(FriendEntity f) {
    return Contact(
      name: f.nickname ?? 'Friend ${f.friendId}',
      subtitle: f.remark ?? '',
      friendId: f.friendId.toInt(),
      avatarUrl: f.avatar.isNotEmpty ? f.avatar : null,
      lastLoginAt: f.lastLoginAt?.toInt(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(friendsProvider);
    final list = contacts;
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          const SidebarContact(),
          const SizedBox(height: 12),
          Expanded(child: SidebarList(contacts: list)),
          const Divider(height: 1),
          const SidebarActions(),
        ],
      ),
    );
  }
}
