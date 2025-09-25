import 'package:flutter/material.dart';

Future<String?> showAddFriendDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _AddFriendDialog(),
  );
}

class _AddFriendDialog extends StatefulWidget {
  const _AddFriendDialog();

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final _controller = TextEditingController();
  String _hint = '手机号 / 邮箱 / 用户名';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加好友'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '好友账号',
                hintText: _hint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '输入对方的登录名 / 手机号 / 邮箱，系统将发送好友申请。',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final value = _controller.text.trim();
            if (value.isEmpty) {
              setState(() {
                _hint = '请输入好友信息';
              });
              return;
            }
            Navigator.of(context).pop(value);
          },
          child: const Text('发送申请'),
        ),
      ],
    );
  }
}
