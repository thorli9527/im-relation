// 文件路径: lib/views/auth/login/components/login_screen_top_image.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:im_client/shared/constants.dart';

class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "LOGIN",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: defaultPadding * 2),
        SvgPicture.asset(
          "assets/icons/login.svg",
          height: 200,
        ),
        SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
