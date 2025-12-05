import 'package:app_desktop/app_state.dart';
import 'package:flutter/material.dart';

import 'sidebar_list_core.dart';

class SidebarListChat extends StatefulWidget {
  const SidebarListChat({
    super.key,
    required this.conversations,
    required this.friends,
    required this.onTap,
  });

  final List<ConversationSummary> conversations;
  final List<Contact> friends;
  final void Function(Contact contact) onTap;

  @override
  State<SidebarListChat> createState() => _SidebarListChatState();
}

class _SidebarListChatState extends State<SidebarListChat> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final friendName = {
      for (final f in widget.friends.where((f) => f.friendId != null)) f.friendId!: f
    };
    final contacts = widget.conversations
        .map(
          (c) => Contact(
            name: friendName[c.targetId]?.nickname ?? 'Chat ${c.targetId}',
            subtitle: c.lastMessageContent,
            nickname: friendName[c.targetId]?.nickname ?? 'Chat ${c.targetId}',
            friendId: c.targetId,
            color: friendName[c.targetId]?.color,
            avatarUrl: friendName[c.targetId]?.avatarUrl,
            lastLoginAt: null,
            unreadCount: c.unreadCount,
            conversationType: c.conversationType,
          ),
        )
        .toList();

    final filtered = contacts.where((c) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.nickname.toLowerCase().contains(q) ||
          c.subtitle.toLowerCase().contains(q);
    }).toList();

    final topArea = Column(
      children: [
        _ChatTopBar(onNewGroup: () => _showCreateGroupFlow(context)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SidebarSearchBox(
            hintText: 'Search',
            onChanged: (v) => setState(() => _query = v.trim()),
          ),
        ),
      ],
    );

    return SidebarListCore(
      contacts: filtered,
      onTap: widget.onTap,
      topArea: topArea,
    );
  }

  Future<void> _showCreateGroupFlow(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final confirmedName = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('群组名称'),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              hintText: '请输入群名称',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('下一步')),
          ],
        );
      },
    );
    if (confirmedName != true) return;

    final picked = await showDialog<Set<int>>(
      context: context,
      builder: (ctx) {
        Set<int> selected = {};
        final candidates = [...widget.friends]..sort((a, b) {
            final at = a.lastLoginAt ?? 0;
            final bt = b.lastLoginAt ?? 0;
            return bt.compareTo(at);
          });
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('添加成员 ${selected.length} / ${candidates.length}'),
              content: SizedBox(
                width: 360,
                height: 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selected
                          .map((id) {
                            final c = candidates.firstWhere((e) => e.friendId == id);
                            return Chip(
                              label: Text(c.nickname),
                              onDeleted: () => setState(() => selected.remove(id)),
                            );
                          })
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: candidates.length,
                        itemBuilder: (_, idx) {
                          final c = candidates[idx];
                          final checked = selected.contains(c.friendId);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: c.generatedColor(),
                              child: Text(c.nickname.characters.first),
                            ),
                            title: Text(c.nickname),
                            subtitle: Text(_formatLastSeen(c.lastLoginAt)),
                            trailing: checked
                                ? const Icon(Icons.check_circle, color: Colors.blue)
                                : const Icon(Icons.radio_button_unchecked),
                            onTap: () => setState(() {
                              if (c.friendId != null) {
                                if (checked) {
                                  selected.remove(c.friendId);
                                } else {
                                  selected.add(c.friendId!);
                                }
                              }
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('取消')),
                TextButton(onPressed: () => Navigator.pop(ctx, selected), child: const Text('创建')),
              ],
            );
          },
        );
      },
    );
    if (picked == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('创建群 "${nameCtrl.text}"，成员 ${picked.length}（待接入接口）')),
    );
  }

  String _formatLastSeen(int? ts) {
    if (ts == null || ts == 0) return '最近上线时间未知';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '最近上线于 ${dt.year}/${dt.month}/${dt.day}';
  }
}

class _ChatTopBar extends StatelessWidget {
  const _ChatTopBar({required this.onNewGroup});

  final VoidCallback onNewGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          const Spacer(),
          const Text(
            'Chats',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'New Group',
            onPressed: onNewGroup,
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
