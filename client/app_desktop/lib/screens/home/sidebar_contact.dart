import 'package:flutter/material.dart';
import 'package:app_desktop/screens/home/sidebar_contact_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/app_state.dart';

/// 侧边栏顶部：联系人标题 + 搜索框。
class SidebarContact extends ConsumerWidget {
  const SidebarContact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(friendRequestsProvider);
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
        if (requests.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _RequestButton(requests: requests),
          ),
        ],
      ],
    );
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({required this.requests});

  final List<FriendRequest> requests;

  @override
  Widget build(BuildContext context) {
    final count = requests.length;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent,
        side: const BorderSide(color: Colors.redAccent),
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) => _RequestListSheet(requests: requests),
        );
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.person_add_alt_1, size: 20),
          Positioned(
            right: -10,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 20),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      label: Text(
        'New requests ($count)',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RequestListSheet extends StatelessWidget {
  const _RequestListSheet({required this.requests});

  final List<FriendRequest> requests;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friend requests',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (requests.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No pending requests'),
            )
          else
            ...requests.map(
              (r) => ListTile(
                leading: r.avatarUrl != null && r.avatarUrl!.isNotEmpty
                    ? CircleAvatar(backgroundImage: NetworkImage(r.avatarUrl!))
                    : const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(r.name),
                subtitle: r.remark != null && r.remark!.isNotEmpty
                    ? Text(r.remark!)
                    : null,
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
