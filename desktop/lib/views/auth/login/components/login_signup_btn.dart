// 文件路径: lib/views/auth/welcome/components/login_signup_btn.dart

import 'package:flutter/material.dart';

import '../../../../shared/constants.dart';
import '../../../../shared/navigation_service.dart';

class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => NavigationService.navigateToLogin(context),
          child: Text("Login".toUpperCase()),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => NavigationService.navigateToSignUp(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryLightColor,
            elevation: 0,
          ),
          child: Text(
            "Sign Up".toUpperCase(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
