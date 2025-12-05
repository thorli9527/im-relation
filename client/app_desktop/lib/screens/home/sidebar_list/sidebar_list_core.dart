import 'package:app_desktop/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SidebarListCore extends ConsumerWidget {
  const SidebarListCore({
    super.key,
    required this.contacts,
    required this.onTap,
    this.topArea,
  });

  final List<Contact> contacts;
  final void Function(Contact contact) onTap;
  final Widget? topArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedFriendProvider);
    return Column(
      children: [
        if (topArea != null) topArea!,
        if (contacts.isEmpty)
          const Expanded(child: Center(child: Text('No data')))
        else
          Expanded(
            child: ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = contacts[index];
                final isSelected = c.friendId != null && c.friendId == selectedId;
                final hasUnread = c.unreadCount > 0;
                final initials =
                    c.name.characters.isNotEmpty ? c.name.characters.first : '?';
                return ListTile(
                  leading: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(c.avatarUrl!))
                      : CircleAvatar(
                          backgroundColor: c.generatedColor(),
                          child: Text(initials),
                        ),
                  title: Text(
                    c.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                  subtitle: Text(
                    c.subtitle,
                    style: TextStyle(color: isSelected ? Colors.white70 : null),
                  ),
                  tileColor: isSelected ? const Color(0xFF4A90E2) : null,
                  trailing: hasUnread ? _UnreadDot(count: c.unreadCount) : null,
                  onTap: () => onTap(c),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : count.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minWidth: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SidebarSearchBox extends StatelessWidget {
  const SidebarSearchBox({
    super.key,
    required this.onChanged,
    this.hintText = 'Search',
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
