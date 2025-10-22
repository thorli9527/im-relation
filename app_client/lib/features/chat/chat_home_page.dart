import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:im_client/core/providers/app_providers.dart';
import 'package:im_client/core/socket/socket_manager.dart';
import 'package:im_client/core/storage/messages/friend_message_entity.dart';
import 'package:im_client/features/chat/data/message_repository.dart';
import 'package:im_client/gen/api/auth.pb.dart';
import 'package:im_client/gen/api/socket.pb.dart' as socketpb;

class ChatHomePage extends ConsumerStatefulWidget {
  const ChatHomePage({
    super.key,
    required this.session,
    required this.account,
    required this.userId,
    required this.deviceId,
    required this.deviceType,
  });

  final LoginResponse session;
  final String account;
  final int userId;
  final String deviceId;
  final int deviceType;

  @override
  ConsumerState<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends ConsumerState<ChatHomePage> {
  int? _selectedFriendId;
  StreamSubscription<socketpb.ServerMsg>? _socketSubscription;
  String _socketStatus = '未连接';
  late final SocketManager _socketManager;
  late final MessageRepository _messageRepository;
  late final TextEditingController _searchController;
  String _searchQuery = '';

  void _selectConversation(int friendId) {
    if (_selectedFriendId == friendId) {
      return;
    }
    setState(() {
      _selectedFriendId = friendId;
    });
  }

  @override
  void initState() {
    super.initState();
    _socketManager = ref.read(socketManagerProvider);
    _messageRepository = ref.read(messageRepositoryProvider);
    _searchController = TextEditingController();
    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
    _socketSubscription = _socketManager.messages.listen(
      (msg) async {
        await _messageRepository.handleIncomingMessage(
          msg,
          ownerId: widget.userId,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          final kindName = msg.kind.name;
          _socketStatus = '收到 $kindName (#${msg.id})';
        });
      },
      onError: (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _socketStatus = '连接错误: $error';
        });
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectSocket();
    });
  }

  Future<void> _connectSocket() async {
    final socketAddr = widget.session.socketAddr;
    if (socketAddr.isEmpty) {
      setState(() {
        _socketStatus = '无可用 socket 节点';
      });
      return;
    }
    try {
      await _socketManager.connect(
        address: socketAddr,
        userId: widget.userId,
        deviceType: widget.deviceType,
        deviceId: widget.deviceId,
        token: widget.session.token,
        resumeAckId: null,
      );
      setState(() {
        _socketStatus = '已连接 $socketAddr';
      });
    } on SocketConnectionException catch (err) {
      setState(() {
        _socketStatus = '连接失败: ${err.message}';
      });
    } catch (err) {
      setState(() {
        _socketStatus = '连接失败: $err';
      });
    }
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _socketManager.disconnect();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = ref.watch(messageRepositoryProvider);
    return StreamBuilder<List<FriendMessageEntity>>(
      stream: repository.watchFriendMessages(ownerId: widget.userId),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? const [];
        final rawConversations = _groupByFriend(messages);
        final conversations = rawConversations.map(_toConversation).toList();
        final filteredConversations = _filterConversations(conversations);

        if (filteredConversations.isNotEmpty &&
            (_selectedFriendId == null ||
                !filteredConversations.any(
                  (conv) => conv.friendId == _selectedFriendId,
                ))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _selectedFriendId = filteredConversations.first.friendId;
            });
          });
        }

        final currentFriendId =
            _selectedFriendId ??
            (filteredConversations.isNotEmpty
                ? filteredConversations.first.friendId
                : null);
        final currentMessages = currentFriendId == null
            ? const <FriendMessageEntity>[]
            : (messages.where((msg) => msg.friendId == currentFriendId).toList()
                ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));

        final currentConversation = currentFriendId == null
            ? null
            : filteredConversations.firstWhere(
                (conv) => conv.friendId == currentFriendId,
                orElse: () => conversations.firstWhere(
                  (conv) => conv.friendId == currentFriendId,
                  orElse: () =>
                      _FriendConversation.placeholder(currentFriendId),
                ),
              );

        final sidebarWidth = MediaQuery.of(context).size.width >= 900
            ? 320.0
            : 280.0;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Row(
            children: [
              Container(
                width: sidebarWidth,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SidebarTopActions(
                          onSort: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('排序功能建设中')),
                            );
                          },
                          onAddFriend: () => _showAddFriendDialog(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: '搜索联系人',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: filteredConversations.isEmpty
                                    ? const _EmptyHint()
                                    : ListView.separated(
                                        itemCount: filteredConversations.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 4),
                                        itemBuilder: (context, index) {
                                          final conversation =
                                              filteredConversations[index];
                                          return _ConversationTile(
                                            title: conversation.title,
                                            snippet: conversation.subtitle,
                                            timeLabel: conversation.timeLabel,
                                            unreadCount: 0,
                                            isSelected:
                                                conversation.friendId ==
                                                currentFriendId,
                                            onTap: () => _selectConversation(
                                              conversation.friendId,
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: _SidebarBottomActions(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ChatToolbar(
                        title: currentConversation?.title ?? '选择会话',
                        subtitle: currentFriendId == null
                            ? _socketStatus
                            : currentConversation?.subtitle ?? _socketStatus,
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: Container(
                          color: theme.colorScheme.background,
                          child: currentFriendId == null
                              ? const Center(child: Text('请选择会话'))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  itemCount: currentMessages.length,
                                  itemBuilder: (context, index) {
                                    final message = currentMessages[index];
                                    final isMine = message.isOutgoing;
                                    final alignment = isMine
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft;
                                    final bubbleColor = isMine
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surfaceVariant
                                              .withOpacity(0.6);
                                    final textColor = isMine
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface;
                                    return Align(
                                      alignment: alignment,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        constraints: const BoxConstraints(
                                          maxWidth: 520,
                                        ),
                                        decoration: BoxDecoration(
                                          color: bubbleColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              message.textPreview ??
                                                  '[${socketpb.MsgKind.valueOf(message.kind)?.name ?? '消息'}]',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(color: textColor),
                                            ),
                                            const SizedBox(height: 4),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                _formatBubbleTime(
                                                  message.timestamp,
                                                ),
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: textColor
                                                          .withOpacity(0.75),
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      const Divider(height: 1),
                      _MessageComposer(
                        enabled: currentFriendId != null,
                        onSend: (text) {
                          if (currentFriendId == null) {
                            return;
                          }
                          unawaited(
                            _messageRepository.queueFriendText(
                              text,
                              ownerId: widget.userId,
                              friendId: currentFriendId,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<FriendMessageEntity> _groupByFriend(List<FriendMessageEntity> messages) {
    final latest = <int, FriendMessageEntity>{};
    for (final msg in messages) {
      final existing = latest[msg.friendId];
      if (existing == null || msg.timestamp > existing.timestamp) {
        latest[msg.friendId] = msg;
      }
    }
    final list = latest.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<_FriendConversation> _filterConversations(
    List<_FriendConversation> conversations,
  ) {
    if (_searchQuery.isEmpty) {
      return conversations;
    }
    final query = _searchQuery.toLowerCase();
    return conversations
        .where(
          (conv) =>
              conv.title.toLowerCase().contains(query) ||
              conv.subtitle.toLowerCase().contains(query),
        )
        .toList();
  }

  _FriendConversation _toConversation(FriendMessageEntity entity) {
    final dt = DateTime.fromMillisecondsSinceEpoch(entity.timestamp).toLocal();
    final title = '好友 #${entity.friendId}';
    final subtitle = entity.textPreview?.isNotEmpty == true
        ? entity.textPreview!
        : '[${socketpb.MsgKind.valueOf(entity.kind)?.name ?? '消息'}]';
    return _FriendConversation(
      friendId: entity.friendId,
      title: title,
      subtitle: subtitle,
      timeLabel: _formatListTileTime(dt),
      timestamp: entity.timestamp,
    );
  }

  Future<void> _showAddFriendDialog(BuildContext context) async {
    final controller = TextEditingController();
    var isLoading = false;
    UserProfile? profile;
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> search() async {
              final query = controller.text.trim();
              if (query.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('请输入查询内容')));
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
                setState(() {
                  isLoading = false;
                  profile = resp.user;
                  if (profile == null) {
                    errorText = '未找到相关用户';
                  }
                });
              } catch (err) {
                setState(() {
                  isLoading = false;
                  errorText = '搜索失败: $err';
                });
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
                      onSubmitted: (_) => search(),
                      decoration: const InputDecoration(
                        hintText: '请输入用户名、邮箱或电话号码',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (!isLoading && errorText != null)
                      Text(
                        errorText!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    if (!isLoading && profile != null)
                      _UserSearchResultCard(
                        profile: profile!,
                        onApply: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('已向 ${profile!.username} 发送好友申请'),
                            ),
                          );
                          Navigator.of(ctx).pop();
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: isLoading ? null : search,
                  child: const Text('搜索'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

String _formatBubbleTime(int timestamp) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  final now = DateTime.now();
  if (now.year == dt.year && now.month == dt.month && now.day == dt.day) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
  return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String _formatListTileTime(DateTime dt) {
  final now = DateTime.now();
  if (now.year == dt.year && now.month == dt.month && now.day == dt.day) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
  if (now.year == dt.year) {
    return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class _SidebarTopActions extends StatelessWidget {
  const _SidebarTopActions({required this.onAddFriend, required this.onSort});

  final VoidCallback onAddFriend;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Tooltip(
          message: '排序',
          child: IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: onSort,
          ),
        ),
        Expanded(
          child: Text(
            '联系人',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Tooltip(
          message: '添加好友',
          child: IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: onAddFriend,
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.people_outline, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('暂无联系人', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SidebarBottomActions extends StatelessWidget {
  const _SidebarBottomActions();

  @override
  Widget build(BuildContext context) {
    void placeholder() {}
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.6),
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          _SidebarBottomActionButton(
            icon: Icons.people_alt_outlined,
            label: '联系人',
            onTap: placeholder,
          ),
          _SidebarBottomActionButton(
            icon: Icons.mic_none_outlined,
            label: '语音',
            onTap: placeholder,
          ),
          _SidebarBottomActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: '消息',
            onTap: placeholder,
          ),
          _SidebarBottomActionButton(
            icon: Icons.settings_outlined,
            label: '设置',
            onTap: placeholder,
          ),
        ],
      ),
    );
  }
}

class _FriendConversation {
  _FriendConversation({
    required this.friendId,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.timestamp,
  });

  final int friendId;
  final String title;
  final String subtitle;
  final String timeLabel;
  final int timestamp;

  factory _FriendConversation.placeholder(int friendId) {
    final dt = DateTime.now();
    return _FriendConversation(
      friendId: friendId,
      title: '好友 #$friendId',
      subtitle: '暂无消息',
      timeLabel: _formatListTileTime(dt),
      timestamp: dt.millisecondsSinceEpoch,
    );
  }
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
  const _UserSearchResultCard({required this.profile, required this.onApply});

  final UserProfile profile;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = profile.username.isNotEmpty
        ? profile.username.characters.first
        : '?';
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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.person_add_alt),
                label: const Text('申请好友'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarBottomActionButton extends StatelessWidget {
  const _SidebarBottomActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Icon(
              icon,
              size: 24,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.title,
    required this.snippet,
    required this.timeLabel,
    required this.unreadCount,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String snippet;
  final String timeLabel;
  final int unreadCount;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileColor = isSelected
        ? theme.colorScheme.primary.withOpacity(0.12)
        : theme.colorScheme.surfaceVariant.withOpacity(0.3);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
          child: Text(
            title.characters.first.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(snippet, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(timeLabel, style: theme.textTheme.labelSmall),
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatToolbar extends StatelessWidget {
  const _ChatToolbar({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Icon(
              Icons.groups_2_outlined,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            tooltip: '搜索',
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: '更多',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({required this.onSend, required this.enabled});

  final ValueChanged<String>? onSend;
  final bool enabled;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: '输入消息，按回车发送',
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isEmpty) {
                  return;
                }
                widget.onSend?.call(value.trim());
                _controller.clear();
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: widget.enabled
                ? () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) {
                      return;
                    }
                    widget.onSend?.call(text);
                    _controller.clear();
                  }
                : null,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('发送'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
