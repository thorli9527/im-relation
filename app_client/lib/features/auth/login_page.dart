import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:im_client/core/api/grpc_channel.dart';
import 'package:im_client/core/config/app_config.dart';
import 'package:im_client/features/auth/data/auth_api_client.dart';
import 'package:im_client/features/auth/models/login_payload.dart';
import 'package:im_client/features/chat/chat_home_page.dart';
import 'package:logger/logger.dart';

// Pc device type value from `DeviceType::Pc` in `online_service.rs`.
const int _pcDeviceTypeValue = 4;

final RegExp _emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
final RegExp _phoneRegExp = RegExp(r'^\+?\d[\d\s-]{6,}$');

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _targetController = TextEditingController();
  final _passwordController = TextEditingController();
  late final TextEditingController _deviceIdController;
  AuthApiClient? _authClient;
  AppConfigController? _configController;

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _deviceIdController = TextEditingController(text: _generateDeviceId());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AppConfigScope.maybeOf(context);
    if (_configController == controller && _authClient != null) {
      return;
    }
    _configController?.removeListener(_handleConfigChanged);
    _configController = controller;
    if (controller != null) {
      controller.addListener(_handleConfigChanged);
      _rebuildClient(controller.value);
    } else {
      _rebuildClient(AppConfigData.fallback());
    }
  }

  Color _applyOpacity(Color color, double opacity) {
    final value = (opacity.clamp(0, 1) * 255).round();
    return color.withAlpha(value);
  }

  @override
  void dispose() {
    _targetController.dispose();
    _passwordController.dispose();
    _deviceIdController.dispose();
    _configController?.removeListener(_handleConfigChanged);
    unawaited(_authClient?.dispose());
    super.dispose();
  }

  void _handleConfigChanged() {
    final controller = _configController;
    if (controller == null) {
      return;
    }
    _rebuildClient(controller.value);
  }

  void _rebuildClient(AppConfigData data) {
    final endpoint = data.activeServer;
    final logger = Logger(
      level: data.logLevel.loggerLevel,
    );
    final manager = GrpcChannelManager(
      config: GrpcConfig(
        host: endpoint.grpcHost,
        port: endpoint.grpcPort,
        useTls: endpoint.useTls,
      ),
      logger: logger,
    );
    unawaited(_authClient?.dispose());
    _authClient = AuthApiClient(channelManager: manager);
  }

  String _generateDeviceId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final buffer = StringBuffer('dev-');
    for (var i = 0; i < 10; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

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

  Future<void> _submit() async {
    final client = _authClient;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('未初始化客户端配置，请检查设置。'),
        ),
      );
      return;
    }
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
      final method = _inferLoginMethod(_targetController.text);
      final payload = LoginRequestPayload(
        loginMethod: method,
        target: _targetController.text.trim(),
        password: _passwordController.text,
        deviceType: _pcDeviceTypeValue,
        deviceId: _deviceIdController.text.trim(),
      );
      final response = await client.login(payload);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatHomePage(
            session: response,
            account: _targetController.text.trim(),
          ),
        ),
      );
    } on GrpcError catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.message?.isNotEmpty == true ? error.message! : '登录失败';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登录出现错误: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _openSettings() async {
    final controller = _configController;
    final fallbackData = AppConfigData.fallback();
    final servers = controller?.servers ?? fallbackData.servers;
    if (!mounted) {
      return;
    }
    if (servers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可用服务器配置')),
      );
      return;
    }
    var selectedServerId =
        controller?.value.activeServerId ?? fallbackData.activeServerId;
    var selectedLogLevel = controller?.value.logLevel ?? fallbackData.logLevel;

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
                    decoration: const InputDecoration(
                      labelText: '服务器',
                    ),
                    items: servers
                        .map(
                          (server) => DropdownMenuItem(
                            value: server.id,
                            child: Text('${server.name} (${server.grpcHost}:${server.grpcPort})'),
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
                    decoration: const InputDecoration(
                      labelText: '日志级别',
                    ),
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
                if (controller != null) {
                  controller
                    ..setActiveServer(selectedServerId)
                    ..setLogLevel(selectedLogLevel);
                }
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
            final horizontalPadding = isWide ? constraints.maxWidth * 0.25 : 24.0;
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
                          onPressed: _openSettings,
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
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
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
