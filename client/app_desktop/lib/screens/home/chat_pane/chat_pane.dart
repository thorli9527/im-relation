import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:characters/characters.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/screens/home/chat_pane/header.dart';
import 'package:app_desktop/screens/home/chat_pane/messages.dart';
import 'package:app_desktop/screens/home/chat_pane/input_bar.dart';
import 'package:app_desktop/src/rust/api/app_api_types.dart' show SearchUserQuery;
import 'package:app_desktop/src/rust/api/friend_api.dart' as friend_api;
import 'package:app_desktop/theme/palette.dart';

class ChatPane extends ConsumerWidget {
  const ChatPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChat = ref.watch(selectedChatProvider);
    final selected = ref.watch(selectedFriendProvider);
    final requests = ref.watch(friendRequestsProvider);
    final pending = requests.where((r) => !r.accepted).toList();
    final showingRequests = selected == -1;
    final hasSelection = selectedChat != null && !showingRequests;
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
              title: showingRequests
                  ? 'New friends'
                  : (selectedChat?.title ?? 'Chat'),
              subtitle: showingRequests
                  ? '${pending.length} pending'
                  : null,
            ),
            const Divider(height: 1),
            if (showingRequests)
              FriendRequestPanel(requests: pending)
            else if (hasSelection) ...[
              ChatMessages(chat: selectedChat!),
              const Divider(height: 1),
              const ChatInputBar(),
            ] else ...const [
              Expanded(child: Center(child: Text('Select a chat'))),
            ],
          ],
        ),
      ),
    );
  }
}

class FriendRequestPanel extends ConsumerWidget {
  const FriendRequestPanel({super.key, required this.requests});

  final List<FriendRequest> requests;
  static final Map<int, Future<_ProfileInfo>> _profileCache = {};

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
    final fut = friend_api
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
  Widget build(BuildContext context, WidgetRef ref) {
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
              trailing: _DecisionButtons(
                request: r,
                onHandled: () =>
                    _profileCache.remove(r.fromUid), // drop cache after decision
                ref: ref,
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
  final idx = uid.abs() % avatarPalette.length;
  return avatarPalette[idx];
}

class _DecisionButtons extends StatefulWidget {
  const _DecisionButtons(
      {required this.request, required this.onHandled, required this.ref});
  final FriendRequest request;
  final VoidCallback onHandled;
  final WidgetRef ref;

  @override
  State<_DecisionButtons> createState() => _DecisionButtonsState();
}

class _DecisionButtonsState extends State<_DecisionButtons> {
  bool _busy = false;

  Future<void> _showDecisionDialog(bool accept) async {
    final r = widget.request;
    final name = r.nickname?.isNotEmpty == true ? r.nickname! : r.name;
    final nicknameCtrl = TextEditingController(text: name);
    final remarkCtrl = TextEditingController(text: r.remark ?? '');
    String? error;
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: Text(accept ? '受理好友申请' : '拒绝好友申请'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('来自 UID ${r.fromUid}'),
                const SizedBox(height: 12),
                TextField(
                  controller: nicknameCtrl,
                  decoration: const InputDecoration(
                    labelText: '好友昵称',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: remarkCtrl,
                  decoration: const InputDecoration(labelText: '备注'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ]
              ],
            ),
            actions: [
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(ctx).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () async {
                        setState(() => _busy = true);
                        try {
                          if (accept) {
                            await friend_api.acceptFriendRequest(
                              requestId: BigInt.from(r.requestId),
                              fromUid: r.fromUid,
                              remark: remarkCtrl.text.trim().isEmpty
                                  ? null
                                  : remarkCtrl.text.trim(),
                              nickname: nicknameCtrl.text.trim().isEmpty
                                  ? null
                                  : nicknameCtrl.text.trim(),
                            );
                          } else {
                            await friend_api.rejectFriendRequest(
                              requestId: BigInt.from(r.requestId),
                              fromUid: r.fromUid,
                              remark: remarkCtrl.text.trim().isEmpty
                                  ? null
                                  : remarkCtrl.text.trim(),
                            );
                          }
                          if (mounted) {
                            Navigator.of(ctx).pop(true);
                          }
                        } catch (e) {
                          setState(() => error = '$e');
                        } finally {
                          setState(() => _busy = false);
                        }
                      },
                child: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(accept ? '同意' : '拒绝'),
              ),
            ],
          );
        });
      },
    ).then((ok) {
      if (ok == true) {
        widget.onHandled();
        final notifier = widget.ref.read(friendRequestsProvider.notifier);
        final current = widget.ref.read(friendRequestsProvider);
        final updated = current
            .map((req) => req.requestId == r.requestId
                ? req.copyWith(
                    accepted: accept,
                    remark: remarkCtrl.text.trim().isEmpty
                        ? req.remark
                        : remarkCtrl.text.trim(),
                    nickname: nicknameCtrl.text.trim().isEmpty
                        ? req.nickname
                        : nicknameCtrl.text.trim(),
                  )
                : req)
            .toList();
        notifier.setRequests(updated);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    if (r.accepted) {
      return const Text('已受理');
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: _busy ? null : () => _showDecisionDialog(false),
          child: const Text('拒绝'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _busy ? null : () => _showDecisionDialog(true),
          child: const Text('受理'),
        ),
      ],
    );
  }
}
