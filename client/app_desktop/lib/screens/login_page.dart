import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_desktop/src/rust/api/config_api.dart' as config_api;
import 'package:app_desktop/src/rust/api/login_api.dart' as login_api;
import 'package:app_desktop/src/rust/api/login_api_types.dart';
import 'package:app_desktop/src/rust/api/app_api.dart' as app_api;
import 'package:app_desktop/widgets/api_base_url.dart';
import 'package:app_desktop/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _targetCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loggingIn = false;
  static const _lastLoginKey = 'last_login_name';

  @override
  void initState() {
    super.initState();
    _loadLastLogin();
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_lastLoginKey);
    if (last != null && last.isNotEmpty) {
      _targetCtrl.text = last;
    }
  }

  Future<void> _saveLastLogin(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLoginKey, name);
  }

  Future<void> _openApiBaseDialog(BuildContext context) =>
      showApiBaseUrlDialog(context);

  Future<void> _doLogin(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final target = _targetCtrl.text.trim();
    final pwd = _passwordCtrl.text;
    if (target.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.login)),
      );
      return;
    }
    setState(() => _loggingIn = true);
    try {
      final deviceId = await config_api.getDeviceId();
      final req = LoginRequest(
        password: pwd,
        target: target,
        deviceType: 4, // PC
        deviceId: deviceId,
      );
      final res = await login_api.login(payload: req);
      await _saveLastLogin(target);
      // 登录成功后触发一次增量同步，确保进入首页前数据最新。
      await app_api.syncOnWake(sessionToken: res.token, resetCursor: false);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.login} failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loggingIn = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
        actions: [
          ApiBaseUrlButton(onSaved: () => _openApiBaseDialog(context)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _targetCtrl,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loggingIn ? null : () => _doLogin(context),
                child: _loggingIn
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.login),
              ),
              TextButton(
                onPressed: () => context.go('/register'),
                child: Text(l10n.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
