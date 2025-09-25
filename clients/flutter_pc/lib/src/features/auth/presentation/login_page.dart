import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_providers.dart';
import '../../../data/auth/auth_repository.dart';
import '../application/auth_controller.dart';
import '../application/auth_state.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginIdentifier _identifier = LoginIdentifier.phone;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final error = widget.errorMessage ?? authState.errorMessage;
    final isLoading = authState.status == AuthStatus.authenticating;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: _SignalInspiredHero(isLoading: isLoading),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _buildForm(context, isLoading, error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isLoading, String? error) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '欢迎回到 IM Relation',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '使用安全通信账号在桌面端登录，享受 Signal 风格的沉浸体验。',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: '登录方式',
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<LoginIdentifier>(
                    value: _identifier,
                    onChanged: isLoading
                        ? null
                        : (value) => setState(() => _identifier = value!),
                    items: const [
                      DropdownMenuItem(
                        value: LoginIdentifier.phone,
                        child: Text('手机号'),
                      ),
                      DropdownMenuItem(
                        value: LoginIdentifier.email,
                        child: Text('邮箱'),
                      ),
                      DropdownMenuItem(
                        value: LoginIdentifier.loginName,
                        child: Text('用户名'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _accountController,
                enabled: !isLoading,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(
                  labelText: '账号 / 手机号 / 邮箱',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                enabled: !isLoading,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
                  ),
                ),
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 16),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              FilledButton(
                onPressed: isLoading ? null : _handleLogin,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Text('登录并进入会话'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                        ref.read(authControllerProvider.notifier).clearError();
                      },
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('新用户注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    final account = _accountController.text.trim();
    final password = _passwordController.text.trim();
    if (account.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入完整的账号与密码。')),
      );
      return;
    }

    ref.read(authControllerProvider.notifier).login(
          identifier: _identifier,
          target: account,
          password: password,
        );
  }
}

class _SignalInspiredHero extends StatelessWidget {
  const _SignalInspiredHero({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.9),
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IM Relation 桌面端',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '与好友保持安全通信，参考 Signal 的三栏交互。'
              ' 左侧管理联系人与会话，中间专注聊天，右侧展示会话详情。',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.9),
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Icon(Icons.security_outlined, color: colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text(
                  '端到端加密 · 多端在线同步 · 消息送达回执',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: colorScheme.onPrimary),
                ),
              ],
            ),
            const SizedBox(height: 48),
            AnimatedOpacity(
              opacity: isLoading ? 1 : 0.6,
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  const Icon(Icons.desktop_windows_outlined, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    '正在准备安全的桌面通信环境…',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
