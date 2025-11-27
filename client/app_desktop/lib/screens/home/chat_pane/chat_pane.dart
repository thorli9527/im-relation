import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:characters/characters.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/screens/home/chat_pane/header.dart';
import 'package:app_desktop/screens/home/chat_pane/messages.dart';
import 'package:app_desktop/screens/home/chat_pane/input_bar.dart';
import 'package:app_desktop/src/rust/api/app_api_types.dart' show SearchUserQuery;
import 'package:app_desktop/src/rust/api/user_api.dart' as user_api;

class ChatPane extends ConsumerWidget {
  const ChatPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFriendProvider);
    final requests = ref.watch(friendRequestsProvider);
    final pending = requests.where((r) => !r.accepted).toList();
    final showingRequests = selected == -1;
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/chat_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            ChatHeader(
              title: showingRequests ? 'New friends' : null,
              subtitle: showingRequests
                  ? '${pending.length} pending'
                  : null,
            ),
            const Divider(height: 1),
            if (showingRequests)
              FriendRequestPanel(requests: pending)
            else ...const [
              ChatMessages(),
              Divider(height: 1),
              ChatInputBar(),
            ],
          ],
        ),
      ),
    );
  }
}

class FriendRequestPanel extends StatelessWidget {
  const FriendRequestPanel({super.key, required this.requests});

  final List<FriendRequest> requests;
  static final Map<int, Future<_ProfileInfo>> _profileCache = {};
  static const List<Color> _palette = [
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

  Future<_ProfileInfo> _profileFor(FriendRequest r) {
    final initial = _ProfileInfo(
      name: r.nickname ?? r.name,
      signature: (r.signature?.isNotEmpty ?? false)
          ? r.signature!
          : '该用户什么都没有留下',
    );
    if (_profileCache.containsKey(r.fromUid)) {
      return _profileCache[r.fromUid]!;
    }
    final fut = user_api
        .searchUser(query: SearchUserQuery(query: r.fromUid.toString()))
        .then((res) {
          final user = res.user;
          final name = user?.nickname?.isNotEmpty == true
              ? user!.nickname
              : initial.name;
          final signature = user?.signature?.isNotEmpty == true
              ? user!.signature!
              : initial.signature;
          return _ProfileInfo(name: name, signature: signature);
        })
        .catchError((_) => initial);
    _profileCache[r.fromUid] = fut;
    return fut;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white.withOpacity(0.8),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final r = requests[index];
            return ListTile(
              leading: r.avatarUrl != null && r.avatarUrl!.isNotEmpty
                  ? CircleAvatar(backgroundImage: NetworkImage(r.avatarUrl!))
                  : CircleAvatar(
                      backgroundColor: _colorForUid(r.fromUid),
                      child: Text(
                        _initialOf(r.nickname ?? r.name),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
              title: FutureBuilder<_ProfileInfo>(
                future: _profileFor(r),
                initialData: _ProfileInfo(
                  name: r.nickname ?? r.name,
                  signature: (r.signature?.isNotEmpty ?? false)
                      ? r.signature!
                      : '该用户什么都没有留下',
                ),
                builder: (context, snapshot) {
                  final info = snapshot.data;
                  final displayName = info?.name ?? (r.nickname ?? r.name);
                  final sig = info?.signature ?? '该用户什么都没有留下';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(sig, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  );
                },
              ),
              trailing: ElevatedButton(
                onPressed: null, // TODO: hook accept API when available
                child: Text(r.accepted ? '已受理' : '受理'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileInfo {
  final String name;
  final String signature;
  _ProfileInfo({required this.name, required this.signature});
}

String _initialOf(String value) {
  if (value.isEmpty) return '?';
  return value.characters.first;
}

Color _colorForUid(int uid) {
  final idx = uid.abs() % FriendRequestPanel._palette.length;
  return FriendRequestPanel._palette[idx];
}
