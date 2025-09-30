import 'package:flutter/material.dart';

import '../../../shared/constants.dart';

class AuthModeToggle extends StatelessWidget {
  final bool isLoginMode;
  final VoidCallback onTap;

  const AuthModeToggle({
    Key? key,
    this.isLoginMode = true,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          isLoginMode
              ? "Don't have an Account? "
              : "Already have an Account? ",
          style: const TextStyle(color: kPrimaryColor),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            isLoginMode ? "Sign Up" : "Sign In",
            style: const TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
