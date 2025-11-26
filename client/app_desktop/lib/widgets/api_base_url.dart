import 'package:flutter/material.dart';
import 'package:app_desktop/src/rust/api/config_api.dart' as config_api;

class ApiBaseUrlButton extends StatelessWidget {
  const ApiBaseUrlButton({super.key, required this.onSaved});

  final Future<void> Function() onSaved;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '设置 API 地址',
      onPressed: onSaved,
      icon: const Icon(Icons.settings),
    );
  }
}

Future<void> showApiBaseUrlDialog(BuildContext context) async {
  final current = await config_api.getAppApiBaseUrl();
  final controller = TextEditingController(text: current);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (context) {
      bool saving = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('设置 API 地址'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'app_api_base_url',
                hintText: 'https://api.example.com',
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        setState(() => saving = true);
                        try {
                          await config_api
                              .setAppApiBaseUrl(baseUrl: controller.text);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已更新 API 地址')),
                            );
                          }
                        } catch (e) {
                          setState(() => saving = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('更新失败: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('保存'),
              ),
            ],
          );
        },
      );
    },
  );
}
