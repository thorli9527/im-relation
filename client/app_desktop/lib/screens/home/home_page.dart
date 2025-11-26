import 'package:flutter/material.dart';
import 'package:app_desktop/screens/home/sidebar.dart';
import 'package:app_desktop/screens/home/chat_pane/chat_pane.dart';
import 'package:app_desktop/screens/home/bottom_tabs.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: const [
          Sidebar(),
          VerticalDivider(width: 1),
          ChatPane(),
        ],
      ),
      // bottomNavigationBar: BottomTabs(), // 如需底部 Tab 可启用
    );
  }
}
