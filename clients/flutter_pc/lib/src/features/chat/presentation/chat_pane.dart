import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/conversation.dart';
import '../../../data/models/message.dart';
import 'chat_input_bar.dart';
import 'chat_message_bubble.dart';

class ChatPane extends StatefulWidget {
  const ChatPane({
    super.key,
    required this.conversation,
    required this.messages,
    required this.isLoading,
    required this.onSend,
  });

  final Conversation? conversation;
  final List<Message> messages;
  final bool isLoading;
  final ValueChanged<String> onSend;

  @override
  State<ChatPane> createState() => _ChatPaneState();
}

class _ChatPaneState extends State<ChatPane> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(ChatPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    if (widget.conversation?.id != oldWidget.conversation?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    if (conversation == null) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        _ChatHeader(conversation: conversation),
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    itemCount: widget.messages.length,
                    itemBuilder: (context, index) {
                      final message = widget.messages[index];
                      return ChatMessageBubble(message: message);
                    },
                  ),
                ),
        ),
        ChatInputBar(
          onSend: widget.onSend,
          enabled: !widget.isLoading,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.message_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            '选择左侧的联系人开始聊天',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '支持端到端加密、已读回执和多设备在线。',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final contact = conversation.contact;
    final formatter = DateFormat('MM/dd HH:mm');
    final subtitle = conversation.lastTimestamp != null
        ? '最近沟通：${formatter.format(conversation.lastTimestamp!)}'
        : '开始新的加密对话';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: contact.avatarUrl != null
                ? NetworkImage(contact.avatarUrl!)
                : null,
            child: contact.avatarUrl == null
                ? Text(contact.displayName.characters.first)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.displayName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined),
            label: const Text('语音'),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined),
            label: const Text('视频'),
          ),
        ],
      ),
    );
  }
}
