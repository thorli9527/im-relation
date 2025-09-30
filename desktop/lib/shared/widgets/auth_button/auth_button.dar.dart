import 'package:flutter/material.dart';

import '../../constants.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const AuthButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: isPrimary
          ? null
          : ElevatedButton.styleFrom(
              backgroundColor: kPrimaryLightColor,
              elevation: 0,
            ),
      child: Text(
        text.toUpperCase(),
        style: !isPrimary
            ? const TextStyle(color: Colors.black)
            : null,
      ),
    );
  }
}
