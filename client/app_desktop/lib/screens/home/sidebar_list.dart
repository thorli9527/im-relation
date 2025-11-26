import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/app_state.dart';

class SidebarList extends ConsumerWidget {
  const SidebarList({super.key, required this.contacts});

  final List<Contact> contacts;
  static const List<Color> _palette = [
    Color(0xFFE57373),
    Color(0xFFF06292),
    Color(0xFFBA68C8),
    Color(0xFF9575CD),
    Color(0xFF7986CB),
    Color(0xFF64B5F6),
    Color(0xFF4FC3F7),
    Color(0xFF4DD0E1),
    Color(0xFF4DB6AC),
    Color(0xFF81C784),
    Color(0xFFAED581),
    Color(0xFFFF8A65),
    Color(0xFFD4E157),
    Color(0xFFFFD54F),
    Color(0xFFFFB74D),
    Color(0xFFA1887F),
    Color(0xFF90A4AE),
    Color(0xFFFF7043),
    Color(0xFFAB47BC),
    Color(0xFF5C6BC0),
    Color(0xFF42A5F5),
    Color(0xFF26C6DA),
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFFDCE775),
    Color(0xFFFFEE58),
    Color(0xFFFFCA28),
    Color(0xFFFFA726),
    Color(0xFF8D6E63),
    Color(0xFF78909C),
    Color(0xFF26A69A),
    Color(0xFFEF9A9A),
  ];

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
        return ListTile(
          leading: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
              ? CircleAvatar(backgroundImage: NetworkImage(c.avatarUrl!))
              : CircleAvatar(
                backgroundColor: _colorFor(c),
                child: Text(c.name.characters.first),
              ),
          title: Text(
            c.name,
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
          onTap: () => ref.read(selectedFriendProvider.notifier).state = c.friendId,
        );
      },
    );
  }

  Color _colorFor(Contact c) {
    if (c.color != null) return c.color!;
    if (c.friendId != null) {
      final idx = c.friendId!.abs() % _palette.length;
      return _palette[idx];
    }
    return Colors.blueGrey;
  }
}
