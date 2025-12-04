import 'dart:async';
import 'dart:io';

import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/l10n/app_localizations.dart';
import 'package:app_desktop/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/src/rust/api/chat_api.dart' as chat_api;
import 'package:app_desktop/src/rust/api/friend_request_api.dart'
    as friend_request_api;
import 'package:app_desktop/src/rust/api/socket_api.dart' as socket_api;
import 'package:app_desktop/src/rust/api/socket_api.dart' show FriendRequestEvent;
import 'package:app_desktop/src/rust/api/user_api.dart' as user_api;
import 'package:app_desktop/src/rust/api/app_api_types.dart';
import 'package:app_desktop/src/rust/api/user_api_types.dart';
import 'package:app_desktop/src/rust/domain/friend_entity.dart';
import 'package:app_desktop/src/rust/domain/friend_request_entity.dart';

/// Sidebar 可选择的动作。
enum SidebarAction { friends, voice, chat, settings }

/// 当前选中的侧边栏动作。
final sidebarActionProvider =
    StateProvider<SidebarAction>((_) => SidebarAction.friends);

/// 设置页的菜单项。
enum SettingsMenu { logs, logout }

/// 当前选中的设置菜单。
final settingsMenuProvider =
    StateProvider<SettingsMenu>((_) => SettingsMenu.logs);

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
      final page = await chat_api.getFriendPage(page: 0, pageSize: 200);
      final mapped = page.items.map<Contact>(_toContact).toList();
      ref.read(friendsProvider.notifier).setFriends(mapped);
      if (mapped.isNotEmpty) {
        ref.read(selectedFriendProvider.notifier).state = mapped.first.friendId;
      }
    } catch (e, st) {
      _logError('loadLocalFriends', e, st);
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
    } catch (e, st) {
      _logError('loadFriendRequests', e, st);
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
      (event) {
        final name = (event.nickname?.isNotEmpty ?? false)
            ? event.nickname!
            : 'User ${event.fromUid}';
        final remark = (event.remark?.isNotEmpty ?? false)
            ? event.remark!
            : event.reason;
        final req = FriendRequest(
          requestId: event.requestId.toInt(),
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
      },
      onError: (err, stack) => _logError('subscribeFriendRequest', err, stack),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(friendsProvider);
    final requests = ref.watch(friendRequestsProvider);
    final convs = ref.watch(conversationsProvider);
    final currentTab = ref.watch(sidebarActionProvider);
    final pendingRequests = requests.where((r) => !r.accepted).toList();
    final List<Contact> list = currentTab == SidebarAction.chat
        ? _buildConversations(convs, contacts)
        : [
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
          Expanded(
            child: SidebarList(
              contacts: list,
              onTap: (c) => _handleSelect(c),
            ),
          ),
          const Divider(height: 1),
          const SidebarActions(),
        ],
      ),
    );
  }

  List<Contact> _buildConversations(
      List<ConversationSummary> convs, List<Contact> friends) {
    final friendName = {
      for (final f in friends.where((f) => f.friendId != null)) f.friendId!: f
    };
    return convs
        .map(
          (c) => Contact(
            name: friendName[c.targetId]?.nickname ?? 'Chat ${c.targetId}',
            subtitle: c.lastMessageContent,
            nickname: friendName[c.targetId]?.nickname ?? 'Chat ${c.targetId}',
            friendId: c.targetId,
            color: friendName[c.targetId]?.color,
            avatarUrl: friendName[c.targetId]?.avatarUrl,
            lastLoginAt: null,
            unreadCount: c.unreadCount,
            conversationType: c.conversationType,
          ),
        )
        .toList();
  }

  void _handleSelect(Contact c) {
    final id = c.friendId;
    ref.read(selectedFriendProvider.notifier).state = id;
    if (id == null || id == -1) {
      ref.read(selectedChatProvider.notifier).state = null;
      return;
    }
    ref.read(selectedChatProvider.notifier).state = SelectedChat(
      conversationType: c.conversationType,
      targetId: id,
      title: c.nickname,
    );
  }
}

class SidebarActions extends ConsumerWidget {
  const SidebarActions({super.key});

  static const double _barHeight = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sidebarActionProvider);
    final pendingRequests = ref.watch(friendRequestsProvider).length;
    final unreadTotal = ref.watch(unreadTotalProvider);
    return SizedBox(
      height: _barHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TabIcon(
              label: 'Friends',
              icon: Icons.people_outline,
              tab: SidebarAction.friends,
              current: current,
              badge: pendingRequests,
              onTap: () {
                ref.read(sidebarActionProvider.notifier).state =
                    SidebarAction.friends;
                _loadFriends(ref);
                _loadFriendRequests(ref);
              },
            ),
            IconButton(
              tooltip: 'Voice',
              onPressed: () {},
              icon: const Icon(Icons.call_outlined),
            ),
            _TabIcon(
              label: 'Chat',
              icon: Icons.chat_bubble_outline,
              tab: SidebarAction.chat,
              current: current,
              badge: unreadTotal,
              onTap: () {
                ref.read(sidebarActionProvider.notifier).state =
                    SidebarAction.chat;
              },
            ),
            _TabIcon(
              label: 'Settings',
              icon: Icons.settings_outlined,
              tab: SidebarAction.settings,
              current: current,
              onTap: () {
                ref.read(sidebarActionProvider.notifier).state =
                    SidebarAction.settings;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.label,
    required this.icon,
    required this.tab,
    required this.current,
    this.badge = 0,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final SidebarAction tab;
  final SidebarAction current;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = tab == current;
    final Color active = const Color(0xFF1E88E5); // Telegram-like blue
    final Color inactive = Colors.grey;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: label,
          onPressed: onTap,
          icon: Icon(
            icon,
            color: selected ? active : inactive,
          ),
        ),
        if (badge > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(minWidth: 20),
              child: Text(
                badge > 99 ? '99+' : badge.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SidebarContact extends ConsumerWidget {
  const SidebarContact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const SidebarContactHeader(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SidebarContactHeader extends ConsumerWidget {
  const SidebarContactHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          PopupMenuButton<String>(
            onSelected: (val) {
              // TODO: hook up sorting logic
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'name', child: Text(l10n.sortByName)),
              PopupMenuItem(
                value: 'last_login',
                child: Text(l10n.sortByLastLogin),
              ),
            ],
            child: TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.sort),
              label: Text(l10n.sort),
            ),
          ),
          const Spacer(),
          Text(
            l10n.contacts,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            tooltip: l10n.add,
            onPressed: () => _showAddFriendDialog(context, ref, l10n),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
    );
  }

  String? _fallbackNickname(String input, UserProfile user) {
    final trimmed = input.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    // 目标用户昵称必然非空，直接使用。
    return user.nickname;
  }

  /// 弹出“添加好友”对话框：
  /// 1) 校验输入非空，若是数字并已存在本地好友则提示已是好友。
  /// 2) 调用后端 searchUser（uid/email/phone/用户名自动判定）。
  /// 3) 未找到则提示；根据策略提示不可添加/占位后续直接添加或申请流程。
  /// （TODO: 接入实际直接添加与申请接口，当前仅提示。）
  void _showAddFriendDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
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
              // 简单本地好友检测：若输入为数字并存在对应 friendId，则提示已是好友。
              final contacts = ref.read(friendsProvider);
              final parsedId = int.tryParse(input);
              if (parsedId != null &&
                  contacts.any(
                    (c) => c.friendId != null && c.friendId == parsedId,
                  )) {
                safeSetState(() {
                  error = l10n.alreadyFriend;
                  loading = false;
                });
                return;
              }

              try {
                final res = await user_api.searchUser(
                  query: SearchUserQuery(query: input),
                );
                final user = res.user;
                if (user == null) {
                  // 后端未找到用户
                  safeSetState(() {
                    error = l10n.userNotFound;
                    loading = false;
                  });
                  return;
                }

                final uid = user.uid.toInt();
                if (contacts.any((c) => c.friendId == uid)) {
                  // 已是好友
                  safeSetState(() {
                    error = l10n.alreadyFriend;
                    loading = false;
                  });
                  return;
                }

                final policy = user.addFriendPolicy;
                if (policy == 3) {
                  // 对方拒绝加好友
                  safeSetState(() {
                    error = l10n.targetRejectsFriendRequest;
                    loading = false;
                  });
                  return;
                }

                if (policy == 1) {
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  await _addFriendDirect(
                    context,
                    ref,
                    user,
                    nicknameCtrl.text.trim(),
                    l10n,
                  );
                  return;
                }

                // 需要验证或未指定：弹出申请对话框。
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                await _showApplyDialog(
                  context,
                  ref,
                  user: user,
                  preferredNickname: nicknameCtrl.text.trim(),
                  l10n: l10n,
                );
              } catch (e) {
                safeSetState(() => error = '$e');
              } finally {
                safeSetState(() => loading = false);
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(l10n.addContactTitle),
              content: SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      _roundField(
                        controller: contentCtrl,
                        hint: l10n.addContactHint,
                        keyboardType: TextInputType.text,
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      _roundField(
                        controller: nicknameCtrl,
                        hint: l10n.nicknameOptional,
                        prefix: const Icon(Icons.emoji_emotions_outlined),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 10),
                      _roundField(
                        controller: remarkCtrl,
                        hint: l10n.remarkOptional,
                        prefix: const Icon(Icons.sticky_note_2_outlined),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: loading ? null : submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(120, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.create),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addFriendDirect(
    BuildContext context,
    WidgetRef ref,
    UserProfile user,
    String preferredNickname,
    AppLocalizations l10n,
  ) async {
    final uid = user.uid.toInt();
    try {
      final res = await user_api.addFriend(
        payload: AddFriendPayload(
          targetUid: user.uid,
          reason: null,
          remark: null,
          nickname: _fallbackNickname(preferredNickname, user),
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
              avatarUrl: user.avatar.isNotEmpty ? user.avatar : null,
            ),
          );
          notifier.setFriends(current);
        }
      }
    } catch (e, st) {
      _logError('addFriendDirect', e, st);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addFriendFailed('$e'))));
    }
  }

  Future<void> _showApplyDialog(
    BuildContext context,
    WidgetRef ref, {
    required UserProfile user,
    required String preferredNickname,
    required AppLocalizations l10n,
  }) async {
    final nicknameCtrl = TextEditingController(text: preferredNickname);
    final reasonCtrl = TextEditingController();
    final remarkCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogCtx) {
        bool submitting = false;
        String? error;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(l10n.friendRequestTitle),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _roundField(
                      controller: nicknameCtrl,
                      hint: l10n.nickname,
                      prefix: const Icon(Icons.emoji_emotions_outlined),
                      maxLines: 1,
                      helperText:
                          nicknameCtrl.text.trim().isEmpty ? l10n.nickname : null,
                    ),
                    const SizedBox(height: 10),
                    _roundField(
                      controller: reasonCtrl,
                      hint: l10n.reason,
                      prefix: const Icon(Icons.message_outlined),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _roundField(
                      controller: remarkCtrl,
                      hint: l10n.remark,
                      prefix: const Icon(Icons.sticky_note_2_outlined),
                      maxLines: 1,
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(dialogCtx).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          setState(() {
                            submitting = true;
                            error = null;
                          });
                          try {
                            final res = await user_api.addFriend(
                              payload: AddFriendPayload(
                                targetUid: user.uid,
                                reason: reasonCtrl.text.trim().isEmpty
                                    ? null
                                    : reasonCtrl.text.trim(),
                                remark: remarkCtrl.text.trim().isEmpty
                                    ? null
                                    : remarkCtrl.text.trim(),
                                nickname: _fallbackNickname(
                                  nicknameCtrl.text.trim(),
                                  user,
                                ),
                              ),
                            );
                            Navigator.of(dialogCtx).pop();
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
                              final uid = user.uid.toInt();
                              final notifier = ref.read(
                                friendsProvider.notifier,
                              );
                              final current = [...ref.read(friendsProvider)];
                              if (!current.any((c) => c.friendId == uid)) {
                                current.add(
                                  Contact(
                                    name: user.username,
                                    subtitle: l10n.uidWithValue(
                                      uid.toString(),
                                    ),
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
                            _logError('applyFriendDialog', e);
                            setState(() => error = '$e');
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
  }

  Future<void> _showUserSummaryDialog(
    BuildContext context,
    WidgetRef ref, {
    required UserProfile user,
    required String preferredNickname,
    required AppLocalizations l10n,
  }) async {
    final uid = user.uid.toInt();
    final detailBadges = <String>[
      if (user.email?.isNotEmpty == true) l10n.emailWithValue(user.email!),
      if (user.phone?.isNotEmpty == true) l10n.phoneWithValue(user.phone!),
      if (user.username.isNotEmpty) l10n.usernameWithValue(user.username),
    ];
    final country = (user.region ?? '').isNotEmpty ? user.region! : '-';
    const language = '-';
    final nicknameLabel = preferredNickname.isNotEmpty
        ? '${l10n.nickname}: $preferredNickname'
        : null;

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        bool submitting = false;
        String? error;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(l10n.userSummaryTitle),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: user.avatar.isNotEmpty
                              ? NetworkImage(user.avatar)
                              : null,
                          child: user.avatar.isEmpty
                              ? Text(
                                  user.username.isNotEmpty
                                      ? user.username.substring(0, 1).toUpperCase()
                                      : '?',
                                )
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
                        if (nicknameLabel != null) _infoBadge(nicknameLabel),
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
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(dialogCtx).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          setState(() {
                            submitting = true;
                            error = null;
                          });
                          try {
                            final res = await user_api.addFriend(
                              payload: AddFriendPayload(
                                targetUid: user.uid,
                                reason: null,
                                remark: null,
                                nickname: _fallbackNickname(
                                  preferredNickname,
                                  user,
                                ),
                              ),
                            );
                            Navigator.of(dialogCtx).pop();
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
                              final notifier = ref.read(
                                friendsProvider.notifier,
                              );
                              final current = [...ref.read(friendsProvider)];
                              if (!current.any((c) => c.friendId == uid)) {
                                current.add(
                                  Contact(
                                    name: user.username,
                                    subtitle: l10n.uidWithValue(
                                      uid.toString(),
                                    ),
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
                            setState(() => error = '$e');
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

  Widget _roundField({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: prefix,
        hintText: hint,
        helperText: helperText,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}

class SidebarList extends ConsumerWidget {
  const SidebarList({super.key, required this.contacts, required this.onTap});

  final List<Contact> contacts;
  final void Function(Contact contact) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedFriendProvider);
    if (contacts.isEmpty) {
      return const Center(child: Text('No contacts'));
    }
    return ListView.separated(
      itemCount: contacts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final c = contacts[index];
        final isSelected = c.friendId != null && c.friendId == selectedId;
        final hasUnread = c.unreadCount > 0;
        return ListTile(
          leading: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
              ? CircleAvatar(backgroundImage: NetworkImage(c.avatarUrl!))
              : CircleAvatar(
                  backgroundColor: _colorFor(c),
                  child: Text(c.name.characters.first),
                ),
          title: Text(
            c.nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.w600 : null,
            ),
          ),
          subtitle: Text(
            c.subtitle,
            style: TextStyle(color: isSelected ? Colors.white70 : null),
          ),
          tileColor: isSelected ? const Color(0xFF4A90E2) : null,
          trailing: hasUnread ? _UnreadDot(count: c.unreadCount) : null,
          onTap: () => onTap(c),
        );
      },
    );
  }

  Color _colorFor(Contact c) {
    if (c.color != null) return c.color!;
    if (c.friendId != null) {
      final idx = c.friendId!.abs() % avatarPalette.length;
      return avatarPalette[idx];
    }
    return Colors.blueGrey;
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : count.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minWidth: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

void _loadFriends(WidgetRef ref) {
  final existing = ref.read(friendsProvider);

  List<Contact> list = existing;
  if (list.isEmpty) {
    return;
  }

  list.sort((a, b) {
    final aTime = a.lastLoginAt ?? 0;
    final bTime = b.lastLoginAt ?? 0;
    return bTime.compareTo(aTime);
  });
  ref.read(friendsProvider.notifier).setFriends(list);
  if (list.isNotEmpty) {
    ref.read(selectedFriendProvider.notifier).state = list.first.friendId;
  }
}

Future<void> _loadFriendRequests(WidgetRef ref) async {
  try {
    final page = await friend_request_api.getFriendRequestPage(
      page: 1,
      pageSize: 200,
    );
    final mapped = page.items.map((e) {
      final name =
          (e.nickname?.isNotEmpty ?? false) ? e.nickname! : 'User ${e.fromUid}';
      final remark = (e.remark?.isNotEmpty ?? false) ? e.remark! : e.reason;
      final signature = (e.remark?.isNotEmpty ?? false)
          ? e.remark!
          : (e.reason.isNotEmpty ? e.reason : '该用户什么都没有留下');
      return FriendRequest(
        requestId: e.requestId.toInt(),
        name: name,
        fromUid: e.fromUid.toInt(),
        nickname: e.nickname?.isNotEmpty == true ? e.nickname! : null,
        avatarUrl: null,
        remark: remark,
        signature: signature,
        accepted: e.accepted ?? false,
      );
    }).toList();
    ref.read(friendRequestsProvider.notifier).setRequests(mapped);
  } catch (e, st) {
    _logError('loadFriendRequestsGlobal', e, st);
    // 忽略加载错误，保持现有数据
  }
}

void _logError(String tag, Object error, [StackTrace? stack]) {
  try {
    final ts = _formatTimestamp();
    final file = File('logs/app.log');
    file.createSync(recursive: true);
    final buffer = StringBuffer()
      ..write('[$ts][$tag] $error');
    if (stack != null) {
      buffer
        ..write('\n')
        ..write(stack);
    }
    buffer.write('\n');
    file.writeAsStringSync(buffer.toString(), mode: FileMode.append);
  } catch (_) {
    // 如果写日志失败，避免影响主流程。
  }
}

String _formatTimestamp() {
  final now = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  String three(int v) => v.toString().padLeft(3, '0');
  return '${now.year}-${two(now.month)}-${two(now.day)} '
      '${two(now.hour)}:${two(now.minute)}:${two(now.second)}.${three(now.millisecond)}';
}
