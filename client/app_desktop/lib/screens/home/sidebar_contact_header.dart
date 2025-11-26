import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/l10n/app_localizations.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/src/rust/api/user_api.dart' as user_api;
import 'package:app_desktop/src/rust/api/app_api_types.dart';
import 'package:app_desktop/src/rust/api/user_api_types.dart';

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
          nickname: preferredNickname.isEmpty ? null : preferredNickname,
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
              friendId: uid,
              avatarUrl: user.avatar.isNotEmpty ? user.avatar : null,
            ),
          );
          notifier.setFriends(current);
        }
      }
    } catch (e) {
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
                                nickname: nicknameCtrl.text.trim().isEmpty
                                    ? null
                                    : nicknameCtrl.text.trim(),
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
      if (user.email?.isNotEmpty == true)
        l10n.emailWithValue(user.email!),
      if (user.phone?.isNotEmpty == true)
        l10n.phoneWithValue(user.phone!),
      if (user.username.isNotEmpty)
        l10n.usernameWithValue(user.username),
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
                                      ? user.username
                                            .substring(0, 1)
                                            .toUpperCase()
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
                                nickname: preferredNickname.isEmpty
                                    ? null
                                    : preferredNickname,
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: prefix,
        hintText: hint,
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
