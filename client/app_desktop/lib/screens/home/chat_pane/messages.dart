import 'package:flutter/material.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/src/rust/api/chat_api.dart' as chat_api;

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key, required this.chat});

  final SelectedChat chat;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: chat_api.getMessagePage(
        conversationId: chat.targetId,
        page: 1,
        pageSize: 50,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Expanded(
            child: Center(
              child: Text('Load messages failed: ${snapshot.error}'),
            ),
          );
        }
        final items = snapshot.data?.items ?? const [];
        if (items.isEmpty) {
          return const Expanded(
            child: Center(child: Text('No messages')),
          );
        }
        return Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              // 这里暂时无法解码消息内容，先展示序号。
              final text = 'Message #${index + 1}';
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 520),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(text),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
