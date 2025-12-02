import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/screens/home/sidebar_state.dart';

class SidebarActions extends ConsumerWidget {
  const SidebarActions({super.key});

  static const double _barHeight = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sidebarActionProvider);
    final pendingRequests = ref.watch(friendRequestsProvider).length;
    final unreadTotal = ref.watch(unreadTotalProvider);
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
              tab: SidebarAction.friends,
              current: current,
              badge: pendingRequests,
              onTap: () {
                ref.read(sidebarActionProvider.notifier).state = SidebarAction.friends;
                _loadFriends(ref);
              },
            ),
            IconButton(
              tooltip: 'Voice',
              onPressed: () {},
              icon: const Icon(Icons.call_outlined),
            ),
            _TabIcon(
              label: 'Chat',
              icon: Icons.chat_bubble_outline,
              tab: SidebarAction.chat,
              current: current,
              badge: unreadTotal,
              onTap: () {
                ref.read(sidebarActionProvider.notifier).state = SidebarAction.chat;
              },
            ),
            _TabIcon(
              label: 'Settings',
              icon: Icons.settings_outlined,
              tab: SidebarAction.settings,
              current: current,
              onTap: () {
                ref.read(sidebarActionProvider.notifier).state = SidebarAction.settings;
              },
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
    this.badge = 0,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final SidebarAction tab;
  final SidebarAction current;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = tab == current;
    final Color active = const Color(0xFF1E88E5); // Telegram-like blue
    final Color inactive = Colors.grey;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: label,
          onPressed: onTap,
          icon: Icon(
            icon,
            color: selected ? active : inactive,
          ),
        ),
        if (badge > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(minWidth: 20),
              child: Text(
                badge > 99 ? '99+' : badge.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
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
