import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSend, this.enabled = true});

  final ValueChanged<String> onSend;
  final bool enabled;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: '发送文件',
            onPressed: widget.enabled ? () {} : null,
            icon: const Icon(Icons.attachment_outlined),
          ),
          IconButton(
            tooltip: '发起语音 / 视频',
            onPressed: widget.enabled ? () {} : null,
            icon: const Icon(Icons.mic_none_outlined),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: widget.enabled ? '发送一条加密消息…' : '正在加载历史消息…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: widget.enabled ? _submit : null,
            icon: const Icon(Icons.send_rounded),
            label: const Text('发送'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    widget.onSend(text);
    _controller.clear();
  }
}
