import 'package:app_desktop/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sidebar_list/sidebar_list_chat.dart';
import 'sidebar_list/sidebar_list_friends.dart';
import 'sidebar_list/sidebar_list_settings.dart';
import 'sidebar_list/sidebar_list_voice.dart';

/// Sidebar 可选择的动作。
enum SidebarAction { friends, voice, chat, settings }

/// 当前选中的侧边栏动作。
final sidebarActionProvider =
    StateProvider<SidebarAction>((_) => SidebarAction.friends);

/// 设置页的菜单项。
enum SettingsMenu { logs, language, logout }

/// 当前选中的设置菜单。
final settingsMenuProvider =
    StateProvider<SettingsMenu>((_) => SettingsMenu.logs);



class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  static const int _settingsLogId = -9000;
  static const int _settingsLanguageId = -9002;
  static const int _settingsLogoutId = -9001;

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(friendsProvider);
    final convs = ref.watch(conversationsProvider);
    final currentTab = ref.watch(sidebarActionProvider);
    final void Function(Contact) handler = currentTab == SidebarAction.settings
        ? _handleSettingsSelect
        : _handleSelect;
    final Widget listWidget = switch (currentTab) {
      SidebarAction.chat => SidebarListChat(
          conversations: convs, friends: contacts, onTap: (c) => handler(c)),
      SidebarAction.voice =>
          SidebarListVoice(contacts: contacts, onTap: handler),
      SidebarAction.settings =>
          SidebarListSettings(contacts: _buildSettingsMenu(), onTap: handler),
      _ => SidebarListFriends(onTap: (c) => handler(c)),
    };
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Expanded(
            child: listWidget,
          ),
          const Divider(height: 1),
          const SidebarActions(),
        ],
      ),
    );
  }

  void _handleSelect(Contact c) {
    final id = c.friendId;
    ref.read(selectedFriendProvider.notifier).state = id;
    if (ref.read(sidebarActionProvider) == SidebarAction.settings) {
      ref.read(sidebarActionProvider.notifier).state = SidebarAction.settings;
    }
    if (id == null || id == -1) {
      ref.read(selectedChatProvider.notifier).state = null;
      return;
    }
    ref.read(selectedChatProvider.notifier).state = SelectedChat(
      conversationType: c.conversationType,
      targetId: id,
      title: c.nickname,
    );
  }

  List<Contact> _buildSettingsMenu() {
    return [
      Contact(
        name: '日志',
        subtitle: '查看应用日志',
        nickname: '日志',
        friendId: _settingsLogId,
        color: const Color(0xFF4A90E2),
      ),
      Contact(
        name: '语言',
        subtitle: '切换显示语言',
        nickname: '语言',
        friendId: _settingsLanguageId,
        color: const Color(0xFF8E44AD),
      ),
      Contact(
        name: '退出',
        subtitle: '退出登录',
        nickname: '退出',
        friendId: _settingsLogoutId,
        color: Colors.redAccent,
      ),
    ];
  }

  void _handleSettingsSelect(Contact c) {
    ref.read(selectedFriendProvider.notifier).state = c.friendId;
    ref.read(sidebarActionProvider.notifier).state = SidebarAction.settings;
    final menu = switch (c.friendId) {
      _settingsLanguageId => SettingsMenu.language,
      _settingsLogoutId => SettingsMenu.logout,
      _ => SettingsMenu.logs,
    };
    ref.read(settingsMenuProvider.notifier).state = menu;
  }
}

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
                ref.read(sidebarActionProvider.notifier).state =
                    SidebarAction.friends;
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
                ref.read(sidebarActionProvider.notifier).state =
                    SidebarAction.chat;
              },
            ),
            _TabIcon(
              label: 'Settings',
              icon: Icons.settings_outlined,
              tab: SidebarAction.settings,
              current: current,
              onTap: () {
                ref.read(sidebarActionProvider.notifier).state =
                    SidebarAction.settings;
                // 进入设置页时重置到默认菜单，避免上次停留在“退出”导致直接登出。
                ref.read(settingsMenuProvider.notifier).state =
                    SettingsMenu.logs;
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
