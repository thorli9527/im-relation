import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/app_providers.dart';
import '../../../data/api/api_client.dart';
import '../../../data/models/auth_session.dart';
import '../../../data/models/conversation.dart';
import '../../../data/models/message.dart';
import '../../../data/models/user_profile.dart';
import '../../../features/chat/application/chat_state.dart';
import '../../../features/chat/presentation/chat_pane.dart';
import '../../../features/contacts/presentation/add_friend_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.listen<ChatState>(
      chatControllerProvider,
      (previous, next) {
        final error = next.errorMessage;
        if (error != null && error.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
            ref.read(chatControllerProvider.notifier).clearError();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 300,
              child: _Sidebar(
                session: session,
                chatState: chatState,
                onSelectConversation: (conversation) {
                  ref
                      .read(chatControllerProvider.notifier)
                      .loadMessages(conversation.id);
                },
                onAddFriend: () => _handleAddFriend(context),
                onLogout: () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ),
            Expanded(
              child: ChatPane(
                conversation: chatState.activeConversation,
                messages: chatState.messages,
                isLoading: chatState.loadingMessages,
                onSend: (value) =>
                    ref.read(chatControllerProvider.notifier).sendMessage(value),
              ),
            ),
            SizedBox(
              width: 320,
              child: _DetailsPanel(
                conversation: chatState.activeConversation,
                socketConnected: chatState.socketConnected,
                currentUser: session?.user,
                onRefreshProfile: () =>
                    ref.read(authControllerProvider.notifier).refreshProfile(),
                messages: chatState.messages,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddFriend(BuildContext context) async {
    final query = await showAddFriendDialog(context);
    if (query == null) return;
    try {
      await ref.read(chatControllerProvider.notifier).addFriend(query);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已向 $query 发送好友申请')), 
      );
    } on ApiClientException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加好友失败：${error.message}')),
      );
    }
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.session,
    required this.chatState,
    required this.onSelectConversation,
    required this.onAddFriend,
    required this.onLogout,
  });

  final AuthSession? session;
  final ChatState chatState;
  final ValueChanged<Conversation> onSelectConversation;
  final VoidCallback onAddFriend;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final conversations = chatState.conversations;
    final selectedId = chatState.activeConversation?.id;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          _SidebarHeader(
            session: session,
            onAddFriend: onAddFriend,
            onLogout: onLogout,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: '搜索好友 / 会话 (即将推出)',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          if (chatState.loadingConversations)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _ConversationTile(
                  conversation: conversation,
                  selected: conversation.id == selectedId,
                  onTap: () => onSelectConversation(conversation),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.session,
    required this.onAddFriend,
    required this.onLogout,
  });

  final AuthSession? session;
  final VoidCallback onAddFriend;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final user = session?.user ?? UserProfile.empty;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(user.displayName.characters.first)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle,
                        size: 10, color: user.isOnline ? Colors.green : Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      user.statusMessage ?? '保持连接',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '添加好友',
            onPressed: onAddFriend,
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
          IconButton(
            tooltip: '注销',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.selected,
    required this.onTap,
  });

  final Conversation conversation;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contact = conversation.contact;
    final subtitle = conversation.lastMessagePreview ?? '发起新的聊天';
    final formatter = DateFormat('HH:mm');

    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: contact.avatarUrl != null
                    ? NetworkImage(contact.avatarUrl!)
                    : null,
                child: contact.avatarUrl == null
                    ? Text(contact.displayName.characters.first)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (conversation.lastTimestamp != null)
                          Text(
                            formatter.format(conversation.lastTimestamp!),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (conversation.unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({
    required this.conversation,
    required this.socketConnected,
    required this.currentUser,
    required this.onRefreshProfile,
    required this.messages,
  });

  final Conversation? conversation;
  final bool socketConnected;
  final UserProfile? currentUser;
  final Future<UserProfile> Function() onRefreshProfile;
  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (conversation == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              '选择会话查看详情',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '这里将展示好友资料、设备状态和加密信息。',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final contact = conversation!.contact;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                contact.avatarUrl != null ? NetworkImage(contact.avatarUrl!) : null,
            child: contact.avatarUrl == null
                ? Text(contact.displayName.characters.first)
                : null,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              contact.displayName,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              contact.description ?? '保持联系，安全沟通',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.lock_outline, color: colorScheme.primary),
            title: const Text('端到端加密已启用'),
            subtitle: const Text('消息内容仅对你和联系人可见'),
            trailing: Icon(Icons.verified_user_outlined, color: colorScheme.primary),
          ),
          ListTile(
            leading: Icon(Icons.devices_other_outlined,
                color: socketConnected ? Colors.green : colorScheme.outline),
            title: Text(socketConnected ? '已连接到消息网关' : '等待连接'),
            subtitle: Text(
              socketConnected
                  ? '桌面端实时接收来自 app_socket 的推送'
                  : '即将尝试重新连接',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('我的资料'),
            subtitle: Text(currentUser?.displayName ?? '未登录'),
            trailing: IconButton(
              tooltip: '刷新资料',
              icon: const Icon(Icons.refresh_outlined),
              onPressed: () async {
                await onRefreshProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已刷新个人资料')),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '最近消息概览',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _MessagePreviewList(messages: messages.take(5).toList()),
        ],
      ),
    );
  }
}

class _MessagePreviewList extends StatelessWidget {
  const _MessagePreviewList({required this.messages});

  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.chat_bubble_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '会话消息将在这里快速预览，便于查找历史内容。',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    final formatter = DateFormat('MM/dd HH:mm');
    return Column(
      children: messages.map((message) {
        return ListTile(
          leading: Icon(
            message.isOutgoing ? Icons.north_east : Icons.south_west,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            message.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(formatter.format(message.timestamp)),
        );
      }).toList(),
    );
  }
}
