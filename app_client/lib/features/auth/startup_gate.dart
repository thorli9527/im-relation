import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:im_client/features/auth/application/startup_provider.dart';
import 'package:im_client/features/auth/login_page.dart';
import 'package:im_client/features/chat/chat_home_page.dart';

class StartupGate extends ConsumerWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(authStartupProvider);
    return startup.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => _StartupErrorView(
        message: '启动失败：$error',
        onRetry: () => ref.invalidate(authStartupProvider),
      ),
      data: (result) {
        if (result.error != null) {
          return _StartupErrorView(
            message: '启动失败：${result.error}',
            onRetry: () => ref.invalidate(authStartupProvider),
          );
        }
        if (result.needsLogin) {
          return LoginPage(
            initialAccount: result.account,
            initialDeviceId: result.deviceId,
          );
        }
        final session = result.session;
        if (session == null) {
          return _StartupErrorView(
            message: '缺少会话信息，请重新登录',
            onRetry: () => ref.invalidate(authStartupProvider),
          );
        }
        final account = result.account ?? '';
        final userId = result.userId;
        final deviceId = result.deviceId;
        final deviceType = result.deviceType;
        if (userId == null || deviceId == null || deviceType == null) {
          return _StartupErrorView(
            message: '会话信息缺失（用户或设备），请重新登录',
            onRetry: () => ref.invalidate(authStartupProvider),
          );
        }
        return ChatHomePage(
          session: session,
          account: account,
          userId: userId,
          deviceId: deviceId,
          deviceType: deviceType,
        );
      },
    );
  }
}

class _StartupErrorView extends StatelessWidget {
  const _StartupErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ),
        ),
      ),
    );
  }
}
