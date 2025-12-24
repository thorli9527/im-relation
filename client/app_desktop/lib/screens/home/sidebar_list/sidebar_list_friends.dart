import 'dart:async';

import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/l10n/app_localizations.dart';
import 'package:app_desktop/src/rust/api/chat_api.dart' as chat_api;
import 'package:app_desktop/src/rust/api/friend_api.dart' as friend_api;
import 'package:app_desktop/src/rust/api/socket_api.dart' as socket_api;
import 'package:app_desktop/src/rust/api/socket_api.dart' show FriendRequestEvent;
import 'package:app_desktop/src/rust/api/app_api_types.dart';
import 'package:app_desktop/src/rust/api/user_api_types.dart';
import 'package:app_desktop/src/rust/domain/friend_entity.dart';
import 'package:app_desktop/src/rust/domain/friend_request_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sidebar_list_core.dart';

class SidebarListFriends extends ConsumerStatefulWidget {
  const SidebarListFriends({super.key, required this.onTap});

  final void Function(Contact contact) onTap;

  @override
  ConsumerState<SidebarListFriends> createState() => _SidebarListFriendsState();
}

class _SidebarListFriendsState extends ConsumerState<SidebarListFriends> {
  StreamSubscription<FriendRequestEvent>? _friendReqSub;
  String _query = '';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contacts = ref.watch(friendsProvider);
    final requests = ref.watch(friendRequestsProvider);
    final pendingRequests = requests.where((r) => !r.accepted).toList();

    final list = [
      Contact(
        name: 'New friends (${pendingRequests.length})',
        subtitle: 'Pending requests',
        nickname: 'New friends',
        friendId: -1,
        color: const Color(0xFFFF7043),
      ),
      ...contacts,
    ];

    final filtered = list.where((c) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.nickname.toLowerCase().contains(q) ||
          c.subtitle.toLowerCase().contains(q);
    }).toList();

    final topArea = Column(
      children: [
        _FriendsTopBar(onAdd: () => _showAddFriendDialog(context, ref, l10n)),
        SidebarSearchBox(
          hintText: l10n.contacts,
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
      ],
    );

    return SidebarListCore(contacts: filtered, onTap: widget.onTap, topArea: topArea);
  }

  Future<void> _loadLocalFriends() async {
    try {
      final page = await chat_api.getFriendPage(page: 0, pageSize: 200);
      final mapped = page.items.map<Contact>(_toContact).toList();
      ref.read(friendsProvider.notifier).setFriends(mapped);
      if (mapped.isNotEmpty) {
        ref.read(selectedFriendProvider.notifier).state = mapped.first.friendId;
      }
    } catch (e, st) {
      _logError('loadLocalFriends', e, st);
    }
  }

  Contact _toContact(FriendEntity f) {
    final nickname = f.nickname;
    final displayName = nickname.isNotEmpty ? nickname : 'Friend ${f.friendId}';
    final avatar = (f.avatar?.isNotEmpty ?? false) ? f.avatar! : null;
    return Contact(
      name: displayName,
      subtitle: f.remark ?? '',
      nickname: displayName,
      friendId: f.friendId.toInt(),
      avatarUrl: avatar,
      lastLoginAt: f.lastLoginAt?.toInt(),
    );
  }

  Future<void> _loadFriendRequests() async {
    try {
      final page = await friend_api.getFriendRequestPage(page: 1, pageSize: 200);
      final mapped = page.items.map(_toFriendRequest).toList();
      if (mapped.isNotEmpty) {
        ref.read(friendRequestsProvider.notifier).setRequests(mapped);
      }
    } catch (e, st) {
      _logError('loadFriendRequests', e, st);
    }
  }

  FriendRequest _toFriendRequest(FriendRequestEntity e) {
    final name = (e.nickname?.isNotEmpty ?? false) ? e.nickname! : 'User ${e.fromUid}';
    final remark = (e.remark?.isNotEmpty ?? false) ? e.remark! : e.reason;
    final signature = (e.remark?.isNotEmpty ?? false)
        ? e.remark!
        : (e.reason.isNotEmpty ? e.reason : '该用户什么都没有留下');
    return FriendRequest(
      requestId: e.requestId.toInt(),
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
    _friendReqSub = socket_api.subscribeFriendRequest().listen(
      (event) async {
        try {
          final req = FriendRequest(
            requestId: event.requestId.toInt(),
            name: event.nickname ?? 'User ${event.fromUid}',
            fromUid: event.fromUid,
            nickname: event.nickname,
            avatarUrl: null,
            remark: event.remark,
            signature: event.remark ?? event.reason,
            accepted: false,
          );
          final notifier = ref.read(friendRequestsProvider.notifier);
          final current = ref.read(friendRequestsProvider);
          notifier.setRequests([...current, req]);
        } catch (err, stack) {
          _logError('subscribeFriendRequest', err, stack);
        }
      },
      onError: (err, stack) {
        _logError('subscribeFriendRequest', err, stack);
      },
    );
  }

  void _logError(String tag, Object error, [StackTrace? st]) {
    debugPrint('[$tag] $error\n$st');
  }

  String? _fallbackNickname(String input, UserProfile user) {
    final trimmed = input.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return user.nickname;
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text),
    );
  }

  String _initialForUser(String nickname, String username) {
    final value = nickname.isNotEmpty ? nickname : username;
    return value.isNotEmpty ? value.substring(0, 1) : '';
  }

  void _showAddFriendDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final contentCtrl = TextEditingController();
    final nicknameCtrl = TextEditingController();
    final remarkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        String? error;
        bool loading = false;
        return StatefulBuilder(
          builder: (ctx, setState) {
            void safeSetState(VoidCallback fn) {
              if (!ctx.mounted) return;
              setState(fn);
            }

            Future<void> submit() async {
              final input = contentCtrl.text.trim();
              if (input.isEmpty) {
                safeSetState(() => error = l10n.contentCannotBeEmpty);
                return;
              }
              safeSetState(() {
                error = null;
                loading = true;
              });
              final contacts = ref.read(friendsProvider);
              final parsedId = int.tryParse(input);
              if (parsedId != null &&
                  contacts.any((c) => c.friendId != null && c.friendId == parsedId)) {
                safeSetState(() {
                  error = l10n.alreadyFriend;
                  loading = false;
                });
                return;
              }
              try {
                final res = await friend_api.searchUser(query: SearchUserQuery(query: input));
                if (res.user == null) {
                  safeSetState(() {
                    error = l10n.userNotFound;
                    loading = false;
                  });
                  return;
                }
                final user = res.user!;
                final uid = user.uid;
                if (contacts.any((c) => c.friendId == uid)) {
                  safeSetState(() {
                    error = l10n.alreadyFriend;
                    loading = false;
                  });
                  return;
                }

                final preferredNickname = nicknameCtrl.text;
                final country = user.region?.isNotEmpty == true ? user.region! : 'N/A';
                const language = 'N/A';
                final detailBadges = <String>[
                  if (user.email != null && user.email!.isNotEmpty)
                    l10n.emailWithValue(user.email!),
                  if (user.phone != null && user.phone!.isNotEmpty)
                    l10n.phoneWithValue(user.phone!),
                ];
                String? dialogError;
                bool submitting = false;

                // ignore: use_build_context_synchronously
                await showDialog(
                  context: ctx,
                  builder: (dialogCtx) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text(l10n.userSummaryTitle),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                  backgroundImage:
                                      user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
                                  child: user.avatar.isEmpty
                                      ? Text(_initialForUser(user.nickname, user.username))
                                      : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${user.username} · ${l10n.uidWithValue(uid.toString())}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (user.nickname.isNotEmpty) _infoBadge(user.nickname),
                                  ...detailBadges.map(_infoBadge),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _infoBadge(l10n.countryWithValue(country)),
                                  _infoBadge(l10n.languageWithValue(language)),
                                ],
                              ),
                              if (dialogError != null) ...[
                                const SizedBox(height: 8),
                                Text(dialogError!, style: const TextStyle(color: Colors.red)),
                              ],
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: submitting ? null : () => Navigator.of(dialogCtx).pop(),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: submitting
                                  ? null
                                  : () async {
                                      setState(() {
                                        submitting = true;
                                        dialogError = null;
                                      });
                                      try {
                                        final res = await friend_api.addFriend(
                                          payload: AddFriendPayload(
                                            targetUid: user.uid,
                                            reason: remarkCtrl.text.isNotEmpty
                                                ? remarkCtrl.text
                                                : null,
                                            remark: remarkCtrl.text.isNotEmpty
                                                ? remarkCtrl.text
                                                : null,
                                            nickname: _fallbackNickname(preferredNickname, user),
                                            // 添加好友来源：用户ID添加
                                            source: 3,
                                          ),
                                        );
                                        Navigator.of(dialogCtx).pop();
                                        // 关闭外层搜索弹窗
                                        Navigator.of(context, rootNavigator: true).maybePop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              res.applied
                                                  ? l10n.friendRequestSent
                                                  : l10n.addedAsFriend,
                                            ),
                                          ),
                                        );
                                        if (!res.applied) {
                                          final notifier = ref.read(friendsProvider.notifier);
                                          final current = [...ref.read(friendsProvider)];
                                          if (!current.any((c) => c.friendId == uid)) {
                                            current.add(
                                              Contact(
                                                name: user.username,
                                                subtitle: l10n.uidWithValue(uid.toString()),
                                                nickname: user.nickname,
                                                friendId: uid,
                                                avatarUrl: user.avatar.isNotEmpty
                                                    ? user.avatar
                                                    : null,
                                              ),
                                            );
                                            notifier.setFriends(current);
                                          }
                                        }
                                      } catch (e) {
                                        _logError('userSummaryAddFriend', e);
                                        setState(() => dialogError = '$e');
                                      } finally {
                                        setState(() => submitting = false);
                                      }
                                    },
                              child: submitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(l10n.confirm),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              } catch (e, st) {
                _logError('showAddFriendDialog', e, st);
                safeSetState(() {
                  error = '$e';
                  loading = false;
                });
              }
            }

            return AlertDialog(
              title: Text(l10n.addContactTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: contentCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.addContactTitle,
                      helperText: l10n.addContactHint,
                    ),
                    onSubmitted: (_) => submit(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nicknameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.nickname,
                      helperText: l10n.nicknameOptional,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: remarkCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.remark,
                      helperText: l10n.remarkOptional,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FriendsTopBar extends StatelessWidget {
  const _FriendsTopBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          PopupMenuButton<String>(
            onSelected: (val) {
              // TODO: hook up sorting logic
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'name', child: Text(l10n.sortByName)),
              PopupMenuItem(value: 'last_login', child: Text(l10n.sortByLastLogin)),
            ],
            child: TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.sort),
              label: Text(l10n.sort),
            ),
          ),
          const Spacer(),
          Text(l10n.contacts, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          IconButton(
            tooltip: l10n.add,
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
    );
  }
}
