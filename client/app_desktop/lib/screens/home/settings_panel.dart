import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_desktop/screens/home/sidebar.dart';

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
    return Row(
      children: [
        Container(
          width: 220,
          color: Colors.grey.shade100,
          child: ListView(
            children: [
              _MenuItem(
                icon: Icons.article_outlined,
                label: '日志',
                selected: current == SettingsMenu.logs,
                onTap: () => _selectMenu(SettingsMenu.logs),
              ),
              _MenuItem(
                icon: Icons.exit_to_app,
                label: '退出',
                selected: current == SettingsMenu.logout,
                onTap: () => _selectMenu(SettingsMenu.logout),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: current == SettingsMenu.logs
                ? _LogViewer(
                    future: _logFuture,
                    onRefresh: () {
                      setState(() {
                        _logFuture = _loadLogs();
                      });
                    },
                  )
                : const Center(
                    child: Text(
                      '确认退出请点击左侧“退出”',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.blue : Colors.grey),
      title: Text(label),
      selected: selected,
      onTap: onTap,
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
