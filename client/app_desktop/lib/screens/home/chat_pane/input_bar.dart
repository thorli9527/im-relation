import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    const barHeight = 60.0;
    return SizedBox(
      height: barHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined)),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Write a message...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
          ],
        ),
      ),
    );
  }
}
