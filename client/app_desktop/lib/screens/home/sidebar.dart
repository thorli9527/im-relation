import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/screens/home/sidebar_actions.dart';
import 'package:app_desktop/screens/home/sidebar_list.dart';
import 'package:app_desktop/src/rust/api/chat_api.dart' as chat_api;
import 'package:app_desktop/src/rust/api/friend_request_api.dart'
    as friend_request_api;
import 'package:app_desktop/src/rust/api/socket_api.dart' as socket_api;
import 'package:app_desktop/src/rust/api/socket_api.dart' show FriendRequestEvent;
import 'package:app_desktop/src/rust/domain/friend_entity.dart';
import 'package:app_desktop/src/rust/domain/friend_request_entity.dart';
import 'package:app_desktop/screens/home/sidebar_contact.dart';

class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  StreamSubscription<FriendRequestEvent>? _friendReqSub;

  @override
  void initState() {
    super.initState();
    _loadLocalFriends();
    _loadFriendRequests();
    _subscribeFriendRequests();
  }

  @override
  void dispose() {
    _friendReqSub?.cancel();
    super.dispose();
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
    final displayName =
        (f.nickname?.isNotEmpty ?? false) ? f.nickname! : 'Friend ${f.friendId}';
    return Contact(
      name: displayName,
      subtitle: f.remark ?? '',
      nickname: displayName,
      friendId: f.friendId.toInt(),
      avatarUrl: f.avatar.isNotEmpty ? f.avatar : null,
      lastLoginAt: f.lastLoginAt?.toInt(),
    );
  }

  Future<void> _loadFriendRequests() async {
    try {
      final page =
          await friend_request_api.getFriendRequestPage(page: 1, pageSize: 200);
      final mapped = page.items.map(_toFriendRequest).toList();
      if (mapped.isNotEmpty) {
        ref.read(friendRequestsProvider.notifier).setRequests(mapped);
      }
    } catch (_) {
      // ignore load errors for now
    }
  }

  FriendRequest _toFriendRequest(FriendRequestEntity e) {
    final name =
        (e.nickname?.isNotEmpty ?? false) ? e.nickname! : 'User ${e.fromUid}';
    final remark = (e.remark?.isNotEmpty ?? false) ? e.remark! : e.reason;
    final signature = (e.remark?.isNotEmpty ?? false)
        ? e.remark!
        : (e.reason.isNotEmpty ? e.reason : '该用户什么都没有留下');
    return FriendRequest(
      name: name,
      fromUid: e.fromUid.toInt(),
      nickname: e.nickname,
      avatarUrl: null,
      remark: remark,
      signature: signature,
      accepted: e.accepted ?? false,
    );
  }

  void _subscribeFriendRequests() {
    _friendReqSub = socket_api.subscribeFriendRequest().listen((event) {
      final name = (event.nickname?.isNotEmpty ?? false)
          ? event.nickname!
          : 'User ${event.fromUid}';
      final remark = (event.remark?.isNotEmpty ?? false)
          ? event.remark!
          : event.reason;
      final req = FriendRequest(
        name: name,
        fromUid: event.fromUid.toInt(),
        nickname: event.nickname?.isNotEmpty == true ? event.nickname! : null,
        avatarUrl: null,
        remark: remark,
        signature: (event.remark?.isNotEmpty ?? false)
            ? event.remark!
            : '该用户什么都没有留下',
        accepted: false,
      );
      final notifier = ref.read(friendRequestsProvider.notifier);
      final current = ref.read(friendRequestsProvider);
      notifier.setRequests([...current, req]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(friendsProvider);
    final requests = ref.watch(friendRequestsProvider);
    final pendingRequests = requests.where((r) => !r.accepted).toList();
    final List<Contact> list = [
      if (pendingRequests.isNotEmpty)
        Contact(
          name: 'New friends (${pendingRequests.length})',
          subtitle: 'Pending requests',
          nickname: 'New friends',
          friendId: -1,
          color: const Color(0xFFFF7043),
        ),
      ...contacts,
    ];
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
