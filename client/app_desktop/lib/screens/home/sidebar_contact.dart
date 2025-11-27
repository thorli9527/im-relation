import 'package:flutter/material.dart';
import 'package:app_desktop/screens/home/sidebar_contact_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/app_state.dart';

/// 侧边栏顶部：联系人标题 + 搜索框。
class SidebarContact extends ConsumerWidget {
  const SidebarContact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const SidebarContactHeader(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              ),
            ),
          ),
      ],
    );
  }
}
