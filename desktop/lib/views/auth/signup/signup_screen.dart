import 'package:flutter/material.dart';
import '../../../responsive.dart';
import '../components/background.dart';
import '../components/desktop_background.dart';
import 'components/sign_up_top_image.dart';
import 'components/signup_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Responsive(
      mobile: MobileSignupScreenWrapper(),
      desktop: DesktopSignupScreenWrapper(),
    );
  }
}

class MobileSignupScreenWrapper extends StatelessWidget {
  const MobileSignupScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: MobileSignupScreen(),
      ),
    );
  }
}

class DesktopSignupScreenWrapper extends StatelessWidget {
  const DesktopSignupScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DesktopBackground(
      child: Row(
        children: [
          Expanded(
            child: SignUpScreenTopImage(),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 450,
                  child: SignUpForm(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SignUpScreenTopImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: SignUpForm(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
