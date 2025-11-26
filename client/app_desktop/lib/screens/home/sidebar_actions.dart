import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/app_state.dart';

enum SidebarTab { friends, voice, chat, settings }

final sidebarTabProvider = StateProvider<SidebarTab>((_) => SidebarTab.friends);

class SidebarActions extends ConsumerWidget {
  const SidebarActions({super.key});

  static const double _barHeight = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sidebarTabProvider);
    return SizedBox(
      height: _barHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TabIcon(
              label: 'Friends',
              icon: Icons.people_outline,
              tab: SidebarTab.friends,
              current: current,
              onTap: () {
                ref.read(sidebarTabProvider.notifier).state = SidebarTab.friends;
                _loadFriends(ref);
              },
            ),
            IconButton(
              tooltip: 'Voice',
              onPressed: () {},
              icon: const Icon(Icons.call_outlined),
            ),
            IconButton(
              tooltip: 'Chat',
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.label,
    required this.icon,
    required this.tab,
    required this.current,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final SidebarTab tab;
  final SidebarTab current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = tab == current;
    final Color active = const Color(0xFF1E88E5); // Telegram-like blue
    final Color inactive = Colors.grey;
    return IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(
        icon,
        color: selected ? active : inactive,
      ),
    );
  }
}

void _loadFriends(WidgetRef ref) {
  final existing = ref.read(friendsProvider);
  
  List<Contact> list = existing;
if (list.isEmpty) {
    return;
  }

  list.sort((a, b) {
    final aTime = a.lastLoginAt ?? 0;
    final bTime = b.lastLoginAt ?? 0;
    return bTime.compareTo(aTime);
  });
  ref.read(friendsProvider.notifier).setFriends(list);
  if (list.isNotEmpty) {
    ref.read(selectedFriendProvider.notifier).state = list.first.friendId;
  }
}
