/// gRPC 登录页面，负责凭证输入、配置切换以及登录结果处理。
import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:im_client/core/config/app_config.dart';
import 'package:im_client/core/providers/app_providers.dart';
import 'package:im_client/features/auth/models/login_payload.dart';
import 'package:im_client/features/chat/chat_home_page.dart';

final RegExp _emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
final RegExp _phoneRegExp = RegExp(r'^\+?\d[\d\s-]{6,}$');

/// 登录入口界面，可根据缓存预填账号与设备信息。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.initialAccount, this.initialDeviceId});

  final String? initialAccount;
  final String? initialDeviceId;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

/// 处理登录流程、表单校验以及配置弹窗的状态类。
class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _targetController = TextEditingController();
  final _passwordController = TextEditingController();
  late final TextEditingController _deviceIdController;

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _deviceIdController = TextEditingController(
      text: widget.initialDeviceId ?? '',
    );
    _targetController.text = widget.initialAccount ?? '';
    _hydrateFromStore();
  }

  Color _applyOpacity(Color color, double opacity) {
    final value = (opacity.clamp(0, 1) * 255).round();
    return color.withAlpha(value);
  }

  /// 从本地存储中恢复设备 ID 与最近一次登录账号。
  Future<void> _hydrateFromStore() async {
    final store = ref.read(localStoreProvider);
    final profile = await store.getDeviceProfile();
    final session = await store.getAuthSession();
    if (!mounted) {
      return;
    }
    if (widget.initialDeviceId == null && profile.deviceId.isNotEmpty) {
      _deviceIdController.text = profile.deviceId;
    }
    final savedAccount = session.account;
    if (widget.initialAccount == null && savedAccount?.isNotEmpty == true) {
      _targetController.text = savedAccount!;
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    _passwordController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  /// 根据输入内容推断对应的登录方式。
  LoginMethod _inferLoginMethod(String input) {
    final trimmed = input.trim();
    if (_emailRegExp.hasMatch(trimmed)) {
      return LoginMethod.email;
    }
    if (_phoneRegExp.hasMatch(trimmed)) {
      return LoginMethod.phone;
    }
    return LoginMethod.username;
  }

  /// 执行登录流程，并在成功后跳转到聊天主页。
  Future<void> _submit() async {
    final client = ref.read(authApiClientProvider);
    final store = ref.read(localStoreProvider);
    final form = _formKey.currentState;
    if (form == null) {
      return;
    }
    if (!form.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      final profile = await store.getDeviceProfile();
      final deviceId = _deviceIdController.text.trim().isEmpty
          ? profile.deviceId
          : _deviceIdController.text.trim();
      final deviceType = profile.deviceType;
      final method = _inferLoginMethod(_targetController.text);
      final payload = LoginRequestPayload(
        loginMethod: method,
        target: _targetController.text.trim(),
        password: _passwordController.text,
        deviceType: deviceType,
        deviceId: deviceId,
      );
      final response = await client.login(payload);
      final validation = await client.validateToken(response.token);
      if (!validation.ok) {
        throw GrpcError.unauthenticated('token 无效');
      }

      final refreshedToken = validation.token.isNotEmpty
          ? validation.token
          : response.token;
      final expiresAt = validation.expiresAt > Int64.ZERO
          ? validation.expiresAt.toInt()
          : response.expiresAt.toInt();
      final userId = validation.userId.toInt();

      response
        ..token = refreshedToken
        ..expiresAt = Int64(expiresAt);

      await store.persistLoginSuccess(
        userId: userId,
        loginType: payload.loginType,
        account: payload.target,
        password: payload.password,
        deviceType: payload.deviceType,
        deviceId: payload.deviceId,
        token: refreshedToken,
        expiresAt: expiresAt,
        socketAddr: response.socketAddr,
      );
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatHomePage(
            session: response,
            account: _targetController.text.trim(),
            userId: userId,
            deviceId: payload.deviceId,
            deviceType: payload.deviceType,
          ),
        ),
      );
    } on GrpcError catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.message?.isNotEmpty == true
          ? error.message!
          : '登录失败';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('登录出现错误: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 打开客户端配置弹窗，允许切换服务端与日志等级。
  Future<void> _openSettings(AppConfigData currentConfig) async {
    final fallbackData = AppConfigData.fallback();
    final servers = currentConfig.servers.isEmpty
        ? fallbackData.servers
        : currentConfig.servers;
    if (!mounted) {
      return;
    }
    if (servers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('暂无可用服务器配置')));
      return;
    }
    var selectedServerId = currentConfig.activeServerId.isNotEmpty
        ? currentConfig.activeServerId
        : servers.first.id;
    var selectedLogLevel = currentConfig.logLevel;
    final notifier = ref.read(appConfigNotifierProvider.notifier);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('客户端配置'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedServerId,
                    decoration: const InputDecoration(labelText: '服务器'),
                    items: servers
                        .map(
                          (server) => DropdownMenuItem(
                            value: server.id,
                            child: Text(
                              '${server.name} (${server.grpcHost}:${server.grpcPort})',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedServerId = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<LogLevelSetting>(
                    initialValue: selectedLogLevel,
                    decoration: const InputDecoration(labelText: '日志级别'),
                    items: LogLevelSetting.values
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedLogLevel = value;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                notifier
                  ..setActiveServer(selectedServerId)
                  ..setLogLevel(selectedLogLevel);
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigNotifierProvider);
    final theme = Theme.of(context);
    final secondaryTextColor = _applyOpacity(
      theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface,
      0.7,
    );
    final footnoteColor = _applyOpacity(
      theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurfaceVariant,
      0.6,
    );
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 640;
            final horizontalPadding = isWide
                ? constraints.maxWidth * 0.25
                : 24.0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => _openSettings(config),
                          tooltip: '配置',
                          icon: const Icon(Icons.tune),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Icon(
                        Icons.message_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '欢迎回来',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '使用用户名、邮箱或手机号登录，体验即时通讯服务。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _targetController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: '账号',
                                hintText: '用户名 / 邮箱 / 手机号',
                                prefixIcon: Icon(Icons.account_circle_outlined),
                              ),
                              validator: _validateTarget,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: '密码',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入密码';
                                }
                                if (value.length < 6) {
                                  return '密码至少需要 6 位字符';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('登录'),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('暂未开放注册，请联系管理员。'),
                                  ),
                                );
                              },
                              child: const Text('还没有账号？立即注册'),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '登录即表示您同意服务条款与隐私政策。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: footnoteColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 校验账号输入，允许用户名、邮箱或手机号。
  String? _validateTarget(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '请输入账号';
    }
    if (_emailRegExp.hasMatch(trimmed)) {
      return null;
    }
    if (_phoneRegExp.hasMatch(trimmed)) {
      return null;
    }
    if (trimmed.length < 3) {
      return '账号至少需要 3 个字符';
    }
    return null;
  }
}
