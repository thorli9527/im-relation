// 文件路径: lib/views/auth/login/components/login_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:im_client/shared/constants.dart';
import 'package:im_client/shared/navigation_service.dart';
import 'package:im_client/services/user_service.dart';
import 'package:im_client/utils/validator_util.dart';
import 'package:im_client/models/api_response.dart';

import '../../components/auth_mode_toggle.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userService = ref.read(userServiceProvider);
        final response = await userService.loginWithSocket(
          authContent: _identifierController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          if (response.success) {
            // 登录成功，跳转到主界面
            NavigationService.navigateToMain(context, replace: true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('登录成功')),
            );
          } else {
            // 登录失败，显示错误信息
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('登录失败: ${response.message ?? "未知错误"}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('登录过程中发生错误: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _identifierController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入邮箱或手机号';
              }

              // 检查是否为有效的邮箱或手机号
              if (!ValidatorUtil.isEmail(value) && !ValidatorUtil.isPhone(value)) {
                return '请输入有效的邮箱或手机号';
              }

              return null;
            },
            decoration: const InputDecoration(
              hintText: "邮箱或手机号",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入密码';
                }
                if (value.length < 6) {
                  return '密码至少6位';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text("Login".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AuthModeToggle(
            isLoginMode: true,
            onTap: () => NavigationService.navigateToSignUp(context),
          ),
        ],
      ),
    );
  }
}
