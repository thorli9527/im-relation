import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomTabs extends StatelessWidget {
  const BottomTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Friends'),
        BottomNavigationBarItem(icon: Icon(Icons.call_outlined), label: 'Voice'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
      currentIndex: 2,
      onTap: (i) {
        if (i == 3) {
          context.go('/login');
        }
      },
    );
  }
}
