import 'dart:async';
import 'dart:convert';

import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/l10n/app_localizations.dart';
import 'package:app_desktop/screens/home/chat_pane/chat_pane.dart';
import 'package:app_desktop/screens/home/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_desktop/src/rust/api/login_api.dart' as login_api;
import 'package:app_desktop/src/rust/api/socket_api.dart' as socket_api;
import 'package:app_desktop/src/rust/api/socket_api.dart' show SystemNoticeEvent;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  StreamSubscription<SystemNoticeEvent>? _noticeSub;
  bool _showingLogout = false;

  @override
  void initState() {
    super.initState();
    _noticeSub = socket_api.subscribeSystemNotice().listen(_handleSystemNotice);
  }

  @override
  void dispose() {
    _noticeSub?.cancel();
    super.dispose();
  }

  Future<void> _handleSystemNotice(SystemNoticeEvent event) async {
    // 5 表示 SYSTEM_BUSINESS_PASSIVE_LOGOUT
    if (event.businessType != 5 || _showingLogout || !mounted) {
      return;
    }
    _showingLogout = true;
    final l10n = AppLocalizations.of(context);
    Map<String, dynamic> detail = {};
    try {
      detail = jsonDecode(event.detail) as Map<String, dynamic>;
    } catch (_) {}
    final deviceId = detail['deviceId']?.toString() ?? '';
    final reason = detail['reason']?.toString() ?? '';
    final title = l10n?.passiveLogoutTitle ?? 'Signed in elsewhere';
    final messageBase =
        l10n?.passiveLogoutMessage ?? 'Your account signed in on another device and must log in again.';
    final List<String> lines = [messageBase];
    if (deviceId.isNotEmpty) {
      lines.add(l10n?.passiveLogoutDevice(deviceId) ?? 'Device ID: $deviceId');
    }
    if (reason.isNotEmpty) {
      lines.add(l10n?.passiveLogoutReason(reason) ?? 'Reason: $reason');
    }
    final message = lines.join('\n');
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            int secondsLeft = 10;
            Timer? timer;

            void closeDialog([bool result = true]) {
              timer?.cancel();
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop(result);
              }
            }

            return StatefulBuilder(
              builder: (context, setState) {
                timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
                  if (secondsLeft <= 1) {
                    closeDialog(true);
                  } else {
                    secondsLeft--;
                    setState(() {});
                  }
                });
                final countdownText = l10n?.passiveLogoutCountdown(secondsLeft.toString()) ??
                    'Auto redirecting to login in ${secondsLeft}s';
                return AlertDialog(
                  title: Text(title),
                  content: Text('$message\n$countdownText'),
                  actions: [
                    TextButton(
                      onPressed: () => closeDialog(true),
                      child: Text(l10n?.passiveLogoutAction ?? 'Re-login'),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;
    _showingLogout = false;
    if (!confirmed || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await _clearUserCache(prefs);
    await login_api.logout();
    if (!mounted) return;
    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<void> _clearUserCache(SharedPreferences prefs) async {
    for (final key in prefs.getKeys()) {
      if (key == 'device_id') continue;
      await prefs.remove(key);
    }
    ref.read(friendsProvider.notifier).setFriends(const []);
    ref.read(friendRequestsProvider.notifier).clear();
    ref.read(selectedFriendProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: const [Sidebar(), VerticalDivider(width: 1), ChatPane()],
      ),
      // bottomNavigationBar: BottomTabs(), // 如需底部 Tab 可启用
    );
  }
}
