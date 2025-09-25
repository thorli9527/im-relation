import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_providers.dart';
import '../../../data/api/api_client.dart';
import '../../../data/auth/auth_repository.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  RegisterType _registerType = RegisterType.phone;
  int _currentStep = 0;
  String? _registerId;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建 IM Relation 账号'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    FilledButton(
                      onPressed:
                          _submitting ? null : () => _handleStep(details.currentStep),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : Text(details.currentStep == 0 ? '发送验证码' : '完成注册'),
                    ),
                    const SizedBox(width: 12),
                    if (_currentStep == 1)
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => setState(() => _currentStep = 0),
                        child: const Text('返回上一步'),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                isActive: _currentStep >= 0,
                title: const Text('填写信息'),
                content: _buildBaseInfoForm(),
              ),
              Step(
                isActive: _currentStep >= 1,
                title: const Text('验证码'),
                content: _buildVerifyForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBaseInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '昵称',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        InputDecorator(
          decoration: const InputDecoration(labelText: '注册方式'),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RegisterType>(
              value: _registerType,
              onChanged: (value) => setState(() => _registerType = value!),
              items: const [
                DropdownMenuItem(
                  value: RegisterType.phone,
                  child: Text('手机号'),
                ),
                DropdownMenuItem(
                  value: RegisterType.email,
                  child: Text('邮箱'),
                ),
                DropdownMenuItem(
                  value: RegisterType.loginName,
                  child: Text('用户名'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _targetController,
          decoration: const InputDecoration(
            labelText: '手机号 / 邮箱 / 用户名',
            prefixIcon: Icon(Icons.alternate_email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '密码（至少 6 位，包含字母与数字）',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '系统会通过短信 / 邮件发送验证码，验证码有效期 10 分钟。',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildVerifyForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _codeController,
          decoration: const InputDecoration(
            labelText: '验证码',
            prefixIcon: Icon(Icons.verified_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _registerId == null
              ? '请先获取验证码。'
              : '验证码已发送，注册 ID：$_registerId',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Future<void> _handleStep(int step) async {
    if (step == 0) {
      await _requestCode();
    } else {
      await _verifyCode();
    }
  }

  Future<void> _requestCode() async {
    final displayName = _nameController.text.trim();
    final target = _targetController.text.trim();
    final password = _passwordController.text.trim();
    if (displayName.length < 4 || target.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请完整填写注册信息。')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final payload = RegisterPayload(
        displayName: displayName,
        password: password,
        type: _registerType,
        target: target,
      );
      final regId = await ref.read(authRepositoryProvider).requestRegisterCode(payload);
      setState(() {
        _registerId = regId;
        _currentStep = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('验证码已发送。注册 ID：$regId')),
      );
    } on ApiClientException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('注册失败：${error.message}')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_registerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先获取验证码。')),
      );
      return;
    }

    if (_codeController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入收到的验证码。')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(authRepositoryProvider).verifyRegister(
            regId: _registerId!,
            code: _codeController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注册成功，请返回登录。')),
      );
      Navigator.of(context).pop();
    } on ApiClientException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('验证失败：${error.message}')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }
}
