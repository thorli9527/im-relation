import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      '🔥🔥🔥 Alert: High Memory Usage\nPod: plugin-job-polygon-xxxx\nTime: 11:27',
      '🚨 Warning: CPU Spike\nPod: service-foo-123\nTime: 11:45',
      '✅ Recovered: Memory back to normal\nTime: 12:10',
    ];
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final text = messages[index];
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
  }
}
