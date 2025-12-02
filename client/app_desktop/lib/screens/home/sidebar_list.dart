import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/theme/palette.dart';

class SidebarList extends ConsumerWidget {
  const SidebarList({super.key, required this.contacts, required this.onTap});

  final List<Contact> contacts;
  final void Function(Contact contact) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedFriendProvider);
    if (contacts.isEmpty) {
      return const Center(child: Text('No contacts'));
    }
    return ListView.separated(
      itemCount: contacts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final c = contacts[index];
        final isSelected = c.friendId != null && c.friendId == selectedId;
        final hasUnread = c.unreadCount > 0;
        return ListTile(
          leading: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
              ? CircleAvatar(backgroundImage: NetworkImage(c.avatarUrl!))
              : CircleAvatar(
                backgroundColor: _colorFor(c),
                child: Text(c.name.characters.first),
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
    );
  }

  Color _colorFor(Contact c) {
    if (c.color != null) return c.color!;
    if (c.friendId != null) {
      final idx = c.friendId!.abs() % avatarPalette.length;
      return avatarPalette[idx];
    }
    return Colors.blueGrey;
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
