import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/src/rust/api/user_api.dart' as user_api;
import 'package:app_desktop/src/rust/api/app_api_types.dart';
import 'package:app_desktop/src/rust/api/user_api_types.dart';

class SidebarContactHeader extends ConsumerWidget {
  const SidebarContactHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          PopupMenuButton<String>(
            onSelected: (val) {
              // TODO: hook up sorting logic
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'name', child: Text('by name')),
              PopupMenuItem(value: 'last_login', child: Text('by last login')),
            ],
            child: TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.sort),
              label: const Text('Sort'),
            ),
          ),
          const Spacer(),
          const Text(
            'Contacts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Add',
            onPressed: () => _showAddFriendDialog(context, ref),
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
  void _showAddFriendDialog(BuildContext context, WidgetRef ref) {
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
                safeSetState(() => error = "content cannot be empty");
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
                  error = 'Already a friend';
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
                    error = 'User not found';
                    loading = false;
                  });
                  return;
                }

                final uid = user.uid.toInt();
                if (contacts.any((c) => c.friendId == uid)) {
                  // 已是好友
                  safeSetState(() {
                    error = 'Already a friend';
                    loading = false;
                  });
                  return;
                }

                final policy = user.addFriendPolicy;
                if (policy == 3) {
                  // 对方拒绝加好友
                  safeSetState(() {
                    error = 'Target does not accept friend requests';
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
              title: const Text('Add Contact'),
              content: SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      _roundField(
                        controller: contentCtrl,
                        hint: 'UID/Email/Phone',
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
                        hint: 'Nickname (optional)',
                        prefix: const Icon(Icons.emoji_emotions_outlined),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 10),
                      _roundField(
                        controller: remarkCtrl,
                        hint: 'Remark (optional)',
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
                  child: const Text('Cancel'),
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
                      : const Text('Create'),
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
              subtitle: 'UID $uid',
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
      ).showSnackBar(SnackBar(content: Text('Add friend failed: $e')));
    }
  }

  Future<void> _showApplyDialog(
    BuildContext context,
    WidgetRef ref, {
    required UserProfile user,
    required String preferredNickname,
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
              title: const Text('Friend Request'),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _roundField(
                      controller: nicknameCtrl,
                      hint: 'Nickname',
                      prefix: const Icon(Icons.emoji_emotions_outlined),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 10),
                    _roundField(
                      controller: reasonCtrl,
                      hint: 'Reason ',
                      prefix: const Icon(Icons.message_outlined),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    _roundField(
                      controller: remarkCtrl,
                      hint: 'Remark ',
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
                  child: const Text('Cancel'),
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
                                      ? 'Friend request sent'
                                      : 'Added as friend',
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
                                    subtitle: 'UID $uid',
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
                      : const Text('Confirm'),
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
  }) async {
    final uid = user.uid.toInt();
    final detailBadges = <String>[
      if (user.email?.isNotEmpty == true) 'Email: ${user.email}',
      if (user.phone?.isNotEmpty == true) 'Phone: ${user.phone}',
      if (user.username.isNotEmpty) 'Username: ${user.username}',
    ];
    final country = (user.region ?? '').isNotEmpty ? user.region! : '-';
    const language = '-';
    final nicknameLabel = preferredNickname.isNotEmpty
        ? 'Nickname: $preferredNickname'
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
              title: const Text('User Summary'),
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
                            '${user.username} · UID $uid',
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
                        _infoBadge('Country: $country'),
                        _infoBadge('Language: $language'),
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
                  child: const Text('Cancel'),
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
                                      ? 'Friend request sent'
                                      : 'Added as friend',
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
                                    subtitle: 'UID $uid',
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
                      : const Text('Confirm'),
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
