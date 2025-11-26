import 'package:flutter/material.dart';
import 'package:app_desktop/screens/home/chat_pane/header.dart';
import 'package:app_desktop/screens/home/chat_pane/messages.dart';
import 'package:app_desktop/screens/home/chat_pane/input_bar.dart';

class ChatPane extends StatelessWidget {
  const ChatPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/chat_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: const [
            ChatHeader(),
            Divider(height: 1),
            ChatMessages(),
            Divider(height: 1),
            ChatInputBar(),
          ],
        ),
      ),
    );
  }
}
