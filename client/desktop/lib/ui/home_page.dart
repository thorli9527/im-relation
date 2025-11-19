/// 桌面端首页界面：负责双栏布局、侧边栏导航以及消息模块尚未完成时的占位内容。
library home_page_ui;

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';
import 'package:sdk/sdk.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'widgets/contact_avatar.dart';

part 'home_page/widgets/sidebar_lists.dart';
part 'home_page/widgets/common_row_tile.dart';
part 'home_page/widgets/contact_row.dart';
part 'home_page/widgets/chat_row.dart';
part 'home_page/widgets/call_row.dart';
part 'home_page/widgets/contact_chat_pane.dart';
part 'home_page/widgets/chat_composer.dart';

enum _SidebarTab { contacts, calls, chats, settings }

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.sdk});

  final ClientSdk sdk;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SplitViewController _controller;
  _SidebarTab _activeTab = _SidebarTab.contacts;
  int _selectedContactIndex = 0;
  int _selectedCallIndex = 0;
  int _selectedChatIndex = 2;
  _ContactItem? _activeContact;

  @override
  void initState() {
    super.initState();
    _controller = SplitViewController(weights: const [0.3, 0.7]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateController(double maxWidth) {
    if (maxWidth <= 0) return;

    // 宽屏时侧边栏最多占 300px；窄屏时按比例留出右侧内容区域。
    final leftWidth = maxWidth <= 600 ? maxWidth * 0.45 : 300.0;
    final leftWeight = (leftWidth / maxWidth).clamp(0.0, 1.0);
    final rightWeight = 1 - leftWeight;

    final weights = _controller.weights.toList();
    if (weights.length < 2 ||
        (weights[0] ?? 0) != leftWeight ||
        (weights[1] ?? 0) != rightWeight) {
      _controller.weights = [leftWeight, rightWeight];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          _updateController(constraints.maxWidth);

          // 将界面划分为左右两栏：左侧为侧边栏，右侧为详情区。为了模仿 Telegram
          // 的固定比例，此处隐藏了拖拽手柄，改用代码控制宽度。
          return SplitView(
            viewMode: SplitViewMode.Horizontal,
            gripSize: 1,
            controller: _controller,
            children: [
              _SidebarPane(
                tab: _activeTab,
                onTabChanged: (tab) => setState(() => _activeTab = tab),
                sdk: widget.sdk,
                selectedContactIndex: _selectedContactIndex,
                onContactSelected: (index, contact) => setState(() {
                  _selectedContactIndex = index;
                  _activeContact = contact;
                }),
                selectedCallIndex: _selectedCallIndex,
                onCallSelected: (index) =>
                    setState(() => _selectedCallIndex = index),
                selectedChatIndex: _selectedChatIndex,
                onChatSelected: (index) =>
                    setState(() => _selectedChatIndex = index),
              ),
              Container(
                color: const Color(0xFFFAFAFA),
                child: _MainContent(
                  tab: _activeTab,
                  contact: _activeContact,
                  sdk: widget.sdk,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 承载各个标签页的列表内容以及底部的公共导航栏。
class _SidebarPane extends StatelessWidget {
  const _SidebarPane({
    required this.tab,
    required this.onTabChanged,
    required this.sdk,
    required this.selectedContactIndex,
    required this.onContactSelected,
    required this.selectedCallIndex,
    required this.onCallSelected,
    required this.selectedChatIndex,
    required this.onChatSelected,
  });

  final _SidebarTab tab;
  final ValueChanged<_SidebarTab> onTabChanged;
  final ClientSdk sdk;
  final int selectedContactIndex;
  final void Function(int, _ContactItem) onContactSelected;
  final int selectedCallIndex;
  final ValueChanged<int> onCallSelected;
  final int selectedChatIndex;
  final ValueChanged<int> onChatSelected;

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (tab) {
      case _SidebarTab.contacts:
        content = _ContactsView(
          sdk: sdk,
          selectedIndex: selectedContactIndex,
          onSelected: onContactSelected,
        );
        break;
      case _SidebarTab.calls:
        content = _CallsView(
          selectedIndex: selectedCallIndex,
          onSelected: onCallSelected,
        );
        break;
      case _SidebarTab.chats:
        content = _ChatsView(
          sdk: sdk,
          selectedIndex: selectedChatIndex,
          onSelected: onChatSelected,
        );
        break;
      case _SidebarTab.settings:
        content = const _PlaceholderView(
          title: 'Settings',
          description: 'Customize your preferences',
        );
        break;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Column(
        children: [
          // 顶部区域展示当前标签页的工具栏和列表，底部保留统一的导航按钮。
          Expanded(child: content),
          _SidebarBottomBar(selected: tab, onSelect: onTabChanged),
        ],
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({required this.tab, required this.sdk, this.contact});

  final _SidebarTab tab;
  final ClientSdk sdk;
  final _ContactItem? contact;

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case _SidebarTab.contacts:
        if (contact != null) {
          return _ContactChatPane(sdk: sdk, contact: contact!);
        }
        return const _PlaceholderView(
          title: 'Select a contact',
          description: 'Choose someone from the list to start chatting.',
        );
      case _SidebarTab.chats:
        return const _ChatPane();
      case _SidebarTab.calls:
      case _SidebarTab.settings:
        return const SizedBox.shrink();
    }
  }
}

/// 联系人标签页的工具栏与列表。
/// 聊天标签页的临时占位内容，展示简单提示。
class _ChatPane extends StatelessWidget {
  const _ChatPane();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('聊天内容开发中', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ChatsView extends StatefulWidget {
  const _ChatsView({
    required this.sdk,
    required this.selectedIndex,
    required this.onSelected,
  });

  final ClientSdk sdk;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<_ChatsView> {
  List<_ChatItem> _chats = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final records = await widget.sdk.storage.getRecentChats();
    if (!mounted) return;
    setState(() {
      if (records.isEmpty) {
        _chats = const [];
      } else {
        _chats = records
            .map(
              (e) => _ChatItem(
                id: e.chatKey,
                initials: _initialFor(e.displayName),
                title: e.displayName,
                subtitle: e.lastMessage,
                time: _formatTime(e.lastActiveAt),
                avatarUrl: e.avatarUrl.isEmpty ? null : e.avatarUrl,
                unreadCount: 0,
                pinned: false,
              ),
            )
            .toList();
      }
      _loading = false;
    });
  }

  String _initialFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day) {
      return DateFormat.Hm().format(time);
    }
    if (now.difference(time).inDays < 7) {
      return DateFormat.E().format(time);
    }
    return DateFormat('MM/dd').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeIndex = _chats.isEmpty
        ? 0
        : math.max(0, math.min(widget.selectedIndex, _chats.length - 1));

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sort_rounded, size: 18),
                label: const Text('Sort'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueGrey.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Chats',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.create_outlined),
                tooltip: 'New message',
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search (Cmd+K)',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loading && _chats.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
              : ChatList(
                  onRefresh: _loadChats,
                  chats: _chats,
                  selectedIndex: safeIndex,
                  onSelected: widget.onSelected,
                ),
        ),
      ],
    );
  }
}

class _ContactsView extends StatefulWidget {
  const _ContactsView({
    required this.sdk,
    required this.selectedIndex,
    required this.onSelected,
  });

  final ClientSdk sdk;
  final int selectedIndex;
  final void Function(int, _ContactItem) onSelected;

  @override
  State<_ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<_ContactsView> {
  var _contacts = const <_ContactItem>[];
  bool _loading = true;
  bool _sentInitialSelection = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final entities = await widget.sdk.storage.getAllContacts();
    if (!mounted) return;
    final items = entities.isEmpty
        ? const <_ContactItem>[]
        : entities.map((e) {
            final displayName = e.remark.isNotEmpty ? e.remark : e.name;
            return _ContactItem(
              id: e.uid.toString(),
              initials: _initialFor(displayName),
              name: displayName,
              status: 'last seen recently',
              avatarUrl: e.avatarUrl.isEmpty ? null : e.avatarUrl,
            );
          }).toList();
    setState(() {
      _contacts = items;
      _loading = false;
    });

    if (!_sentInitialSelection && items.isNotEmpty) {
      _sentInitialSelection = true;
      final idx = math.max(0, math.min(widget.selectedIndex, items.length - 1));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onSelected(idx, items[idx]);
        }
      });
    }
  }

  String _initialFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sort_rounded, size: 18),
                label: const Text('Sort'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueGrey.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Contacts',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_outlined),
                tooltip: 'Add contact',
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search (Cmd+K)',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 0),
        Expanded(
          child: _loading && _contacts.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
              : ContactList(
                  onRefresh: _loadContacts,
                  contacts: _contacts,
                  selectedIndex: _contacts.isEmpty
                      ? 0
                      : math.max(
                          0,
                          math.min(widget.selectedIndex, _contacts.length - 1),
                        ),
                  onSelected: (index, item) => widget.onSelected(index, item),
                ),
        ),
      ],
    );
  }
}

class _CallsView extends StatelessWidget {
  const _CallsView({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _calls = [
    _CallItem('call_13', '十阿', '十三 阿哥 (2)', 'Outgoing', '00:59'),
    _CallItem('call_13_2', '十阿', '十三 阿哥', 'Outgoing', 'Fri'),
    _CallItem('call_ff', 'FF', 'Felix felix', 'Outgoing', '10/25/25'),
    _CallItem('call_13_3', '十阿', '十三 阿哥 (3)', 'Outgoing', '10/25/25'),
    _CallItem('call_13_4', '十阿', '十三 阿哥 (2)', 'Outgoing', '10/2/25'),
    _CallItem('call_ff_2', 'FF', 'Felix felix', 'Outgoing', '7/28/25'),
    _CallItem('call_kl', 'KL', 'king Lion 🦁', 'Incoming (29 sec)', '7/22/25'),
    _CallItem(
      'call_d',
      'D',
      'divyasshree | Bitquery',
      'Missed',
      '4/18/25',
      missed: true,
    ),
    _CallItem('call_bo', 'BO', 'BatMan 008 (4)', 'Outgoing', '7/26/24'),
    _CallItem('call_deleted', '👻', 'Deleted Account', 'Outgoing', '7/4/24'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Recent Calls',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(onPressed: () {}, child: const Text('Edit')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_ic_call_outlined),
                    tooltip: 'Create call',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Create New Call'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: Colors.grey.shade200,
          child: const Text('Recent Calls'),
        ),
        // 通话记录列表使用与联系人一致的头像配色策略，确保视觉统一。
        Expanded(
          child: CallList(
            calls: _calls,
            selectedIndex: selectedIndex,
            onSelected: onSelected,
          ),
        ),
      ],
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(description),
        const Spacer(),
      ],
    );
  }
}

class _SidebarBottomBar extends StatelessWidget {
  const _SidebarBottomBar({required this.selected, required this.onSelect});

  final _SidebarTab selected;
  final ValueChanged<_SidebarTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BottomNavIcon(
            icon: Icons.person_outline,
            highlighted: selected == _SidebarTab.contacts,
            onTap: () => onSelect(_SidebarTab.contacts),
          ),
          _BottomNavIcon(
            icon: Icons.call_outlined,
            highlighted: selected == _SidebarTab.calls,
            onTap: () => onSelect(_SidebarTab.calls),
          ),
          _BottomNavIcon(
            icon: Icons.chat_bubble_outline,
            highlighted: selected == _SidebarTab.chats,
            badgeCount: 1,
            onTap: () => onSelect(_SidebarTab.chats),
          ),
          _BottomNavIcon(
            icon: Icons.settings_outlined,
            highlighted: selected == _SidebarTab.settings,
            onTap: () => onSelect(_SidebarTab.settings),
          ),
        ],
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  const _BottomNavIcon({
    required this.icon,
    required this.highlighted,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final bool highlighted;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final baseColor = highlighted ? const Color(0xFF1976D2) : Colors.grey;
    final background = highlighted ? const Color(0xFFE3F2FD) : Colors.white;

    Widget iconWidget = InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: baseColor, size: 24),
      ),
    );

    if (badgeCount != null && badgeCount! > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount!.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return iconWidget;
  }
}
