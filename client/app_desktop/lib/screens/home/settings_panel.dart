import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sidebar.dart';

class SettingsPanel extends ConsumerStatefulWidget {
  const SettingsPanel({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  ConsumerState<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends ConsumerState<SettingsPanel> {
  static const String _defaultLogPath = 'logs/app.log';
  late Future<String> _logFuture;
  bool _logoutTriggered = false;
  String _selectedLanguage = '简体中文';

  @override
  void initState() {
    super.initState();
    _logFuture = _loadLogs();
  }

  Future<String> _loadLogs() async {
    final file = File(_defaultLogPath);
    if (!await file.exists()) {
      return 'Log file not found at $_defaultLogPath';
    }
    try {
      final content = await file.readAsString();
      return content.isEmpty ? 'Log file is empty' : content;
    } catch (e) {
      return 'Failed to read log file: $e';
    }
  }

  void _selectMenu(SettingsMenu menu) {
    ref.read(settingsMenuProvider.notifier).state = menu;
    if (menu == SettingsMenu.logs) {
      setState(() {
        _logFuture = _loadLogs();
      });
    } else if (menu == SettingsMenu.logout) {
      widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(settingsMenuProvider);
    if (current == SettingsMenu.logout && !_logoutTriggered) {
      _logoutTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onLogout();
      });
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: switch (current) {
        SettingsMenu.logs => _LogViewer(
            future: _logFuture,
            onRefresh: () {
              setState(() {
                _logFuture = _loadLogs();
              });
            },
          ),
        SettingsMenu.language => _LanguagePanel(
            selected: _selectedLanguage,
            onSelected: (lang) {
              setState(() {
                _selectedLanguage = lang;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('语言已切换为 $lang（仅客户端示例）'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        SettingsMenu.logout => const Center(
            child: Text(
              '确认退出请点击左侧“退出”',
              style: TextStyle(fontSize: 16),
            ),
          ),
      },
    );
  }
}

class _LogViewer extends StatelessWidget {
  const _LogViewer({required this.future, required this.onRefresh});

  final Future<String> future;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '应用日志',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              tooltip: '刷新',
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<String>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final text = snapshot.data ?? snapshot.error?.toString() ?? '';
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    text,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LanguagePanel extends StatelessWidget {
  const _LanguagePanel({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const languages = ['简体中文', 'English', '繁體中文'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '语言',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: languages
                .map(
                  (lang) => RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: selected,
                    onChanged: (v) {
                      if (v != null) onSelected(v);
                    },
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '选择后立即生效（示例），可在重启后保持当前选择。',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
