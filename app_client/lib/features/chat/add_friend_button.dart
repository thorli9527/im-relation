import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:im_client/core/providers/app_providers.dart';
import 'package:im_client/gen/api/auth.pb.dart';
import 'package:im_client/gen/api/msg_friend.pb.dart' as friendpb;

class AddFriendButton extends ConsumerWidget {
  const AddFriendButton({super.key, required this.ownerId});

  final int ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: '添加好友',
      child: IconButton(
        icon: const Icon(Icons.person_add_alt_1_rounded),
        onPressed: () => _showAddFriendDialog(
          context,
          ref,
          ownerId: ownerId,
        ),
      ),
    );
  }
}

Future<void> _showAddFriendDialog(
  BuildContext context,
  WidgetRef ref, {
  required int ownerId,
}) async {
  final controller = TextEditingController();
  var isLoading = false;
  UserProfile? profile;
  String? errorText;
  var listenerAttached = false;
  var lastQuery = '';

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (dialogCtx, setState) {
          if (!listenerAttached) {
            controller.addListener(() {
              final trimmed = controller.text.trim();
              if (!dialogCtx.mounted) {
                return;
              }
              setState(() {
                final changed = trimmed != lastQuery;
                if (changed) {
                  profile = null;
                  errorText = null;
                } else if (trimmed.length < 2) {
                  errorText = null;
                }
              });
            });
            listenerAttached = true;
          }

          Future<void> search() async {
            final query = controller.text.trim();
            if (query.length < 2) {
              return;
            }
            setState(() {
              isLoading = true;
              profile = null;
              errorText = null;
            });

            final detected = _detectSearchType(query);
            final searchType = _grpcSearchTypeFor(detected);
            final api = ref.read(authApiClientProvider);
            try {
              final resp = await api.searchUser(searchType, query);
              final respProfile = resp.hasUser() ? resp.user : null;
              final userMissing =
                  respProfile == null || respProfile.userId == 0;
              setState(() {
                isLoading = false;
                lastQuery = query;
                if (userMissing) {
                  profile = null;
                  errorText = '用户不存在';
                } else {
                  profile = respProfile;
                }
              });
            } catch (err) {
              setState(() {
                isLoading = false;
                errorText = '搜索失败: $err';
              });
            }
          }

          final trimmedQuery = controller.text.trim();
          final canSearch = !isLoading && trimmedQuery.length >= 2;

          Future<void> applyFriend() async {
            final selected = profile;
            if (selected == null || isLoading) {
              return;
            }
            final policy = selected.addFriendPolicy;
            switch (policy) {
              case AddFriendPolicy.ANYONE:
              case AddFriendPolicy.ADD_FRIEND_UNSPECIFIED:
                try {
                  await _sendFriendRequest(
                    ref: ref,
                    ownerId: ownerId,
                    profile: selected,
                    remark: selected.username,
                    reason: '',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已向 ${selected.username} 发送好友申请'),
                      ),
                    );
                  }
                  if (dialogCtx.mounted) {
                    Navigator.of(dialogCtx).pop();
                  }
                } catch (err) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('发送失败: $err')),
                    );
                  }
                }
                break;
              case AddFriendPolicy.REQUIRE_VERIFY:
                final result = await _showFriendRequestForm(
                  context: context,
                  dialogContext: dialogCtx,
                  ref: ref,
                  ownerId: ownerId,
                  profile: selected,
                );
                if (result == true) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已向 ${selected.username} 发送好友申请'),
                      ),
                    );
                  }
                  if (dialogCtx.mounted) {
                    Navigator.of(dialogCtx).pop();
                  }
                }
                break;
              case AddFriendPolicy.PHONE_ONLY:
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('对方仅允许通过手机号添加好友'),
                    ),
                  );
                }
                break;
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('添加好友'),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onSubmitted: (_) {
                      if (canSearch) {
                        search();
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: '请输入用户名、邮箱或电话号码',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading) const Center(child: CircularProgressIndicator()),
                  if (!isLoading && errorText != null)
                    Text(
                      errorText!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  if (!isLoading && profile != null)
                    _UserSearchResultCard(profile: profile!),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: canSearch ? search : null,
                child: const Text('搜索'),
              ),
              FilledButton(
                onPressed:
                    (!isLoading && profile != null) ? () => applyFriend() : null,
                child: const Text('申请好友'),
              ),
            ],
          );
        },
      );
    },
  );
  controller.dispose();
}

enum _FriendSearchType { username, phone, email }

_FriendSearchType _detectSearchType(String query) {
  final trimmed = query.trim();
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final phoneRegex = RegExp(r'^\+?\d[\d\s-]{5,}$');
  if (emailRegex.hasMatch(trimmed)) {
    return _FriendSearchType.email;
  }
  if (phoneRegex.hasMatch(trimmed)) {
    return _FriendSearchType.phone;
  }
  return _FriendSearchType.username;
}

UserSearchType _grpcSearchTypeFor(_FriendSearchType type) {
  switch (type) {
    case _FriendSearchType.phone:
      return UserSearchType.USER_SEARCH_PHONE;
    case _FriendSearchType.email:
      return UserSearchType.USER_SEARCH_EMAIL;
    case _FriendSearchType.username:
      return UserSearchType.USER_SEARCH_USERNAME;
  }
}

class _UserSearchResultCard extends StatelessWidget {
  const _UserSearchResultCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = profile.username.isNotEmpty
        ? profile.username.characters.first
        : '?';
    final policyLabel = _policyDisplayName(profile.addFriendPolicy);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 28, child: Text(initials.toUpperCase())),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('用户ID: ${profile.userId}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.hasEmail() && profile.email.isNotEmpty)
              Text('邮箱: ${profile.email}'),
            if (profile.hasPhone() && profile.phone.isNotEmpty)
              Text('电话: ${profile.phone}'),
            Text(
              '签名: ${profile.hasSignature() && profile.signature.isNotEmpty ? profile.signature : '暂无'}',
            ),
            Text(
              '地区: ${profile.hasRegion() && profile.region.isNotEmpty ? profile.region : '未知'}',
            ),
            Text('添加策略: $policyLabel'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

Future<void> _sendFriendRequest({
  required WidgetRef ref,
  required int ownerId,
  required UserProfile profile,
  required String remark,
  required String reason,
}) async {
  final trimmedRemark = remark.trim();
  final trimmedReason = reason.trim();
  final repository = ref.read(messageRepositoryProvider);
  await repository.sendFriendRequest(
    ownerId: ownerId,
    targetUserId: profile.userId.toInt(),
    remark: trimmedRemark,
    reason: trimmedReason,
    source: friendpb.FriendRequestSource.FRS_USER_ID,
  );
}

String _policyDisplayName(AddFriendPolicy policy) {
  switch (policy) {
    case AddFriendPolicy.ANYONE:
      return '任何人可添加';
    case AddFriendPolicy.REQUIRE_VERIFY:
      return '需要验证';
    case AddFriendPolicy.PHONE_ONLY:
      return '仅允许手机号添加';
    case AddFriendPolicy.ADD_FRIEND_UNSPECIFIED:
    default:
      return '策略未设置';
  }
}

Future<bool?> _showFriendRequestForm({
  required BuildContext context,
  required BuildContext dialogContext,
  required WidgetRef ref,
  required int ownerId,
  required UserProfile profile,
}) async {
  final requireVerify = profile.addFriendPolicy == AddFriendPolicy.REQUIRE_VERIFY;
  final remarkController = TextEditingController(text: profile.username);
  final reasonController = TextEditingController();
  var isSubmitting = false;
  String? error;

  final result = await showDialog<bool>(
    context: dialogContext,
    builder: (formCtx) {
      return StatefulBuilder(
        builder: (formCtx, setState) {
          Future<void> submit() async {
            final remark = remarkController.text.trim();
            final reason = requireVerify ? reasonController.text.trim() : '';
            if (requireVerify && reason.isEmpty) {
              setState(() {
                error = '请输入申请理由';
              });
              return;
            }
            setState(() {
              isSubmitting = true;
              error = null;
            });
            try {
              await _sendFriendRequest(
                ref: ref,
                ownerId: ownerId,
                profile: profile,
                remark: remark,
                reason: reason,
              );
              if (formCtx.mounted) {
                Navigator.of(formCtx).pop(true);
              }
            } catch (err) {
              setState(() {
                isSubmitting = false;
                error = '发送失败: $err';
              });
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('发送好友申请'),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: remarkController,
                      decoration: const InputDecoration(
                        labelText: '好友备注',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (requireVerify) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: '申请理由',
                          hintText: '例如：我们在活动中认识',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                      Navigator.of(formCtx).pop(false);
                    },
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: isSubmitting ? null : submit,
                child: isSubmitting
                    ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('确认发送'),
              ),
            ],
          );
        },
      );
    },
  );

  remarkController.dispose();
  reasonController.dispose();
  return result;
}
