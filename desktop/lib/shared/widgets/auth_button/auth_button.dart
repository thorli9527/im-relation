// 文件路径: lib/shared/widgets/auth_button/auth_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:im_client/services/user_service.dart';
import 'package:im_client/shared/navigation_service.dart';

class AuthButton extends ConsumerWidget {
  final bool isLogin;
  final VoidCallback? onPressed;

  const AuthButton({
    Key? key,
    this.isLogin = true,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: isLogin
          ? onPressed
          : () async {
              try {
                final userService = ref.read(userServiceProvider);
                await userService.logout();

                if (context.mounted) {
                  // 登出成功，返回欢迎页面
                  NavigationService.navigateToWelcome(context, replace: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已登出')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('登出失败: $e')),
                  );
                }
              }
            },
      child: Text(
        isLogin ? "Login".toUpperCase() : "Logout".toUpperCase(),
      ),
    );
  }
}
