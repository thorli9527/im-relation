import 'package:flutter/material.dart';
import '../../../responsive.dart';
import '../components/background.dart';
import '../components/desktop_background.dart';
import 'components/login_signup_btn.dart';
import 'components/welcome_image.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Responsive(
      mobile: MobileWelcomeScreenWrapper(),
      desktop: DesktopWelcomeScreenWrapper(),
    );
  }
}

class MobileWelcomeScreenWrapper extends StatelessWidget {
  const MobileWelcomeScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: SafeArea(
          child: MobileWelcomeScreen(),
        ),
      ),
    );
  }
}

class DesktopWelcomeScreenWrapper extends StatelessWidget {
  const DesktopWelcomeScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DesktopBackground(
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: WelcomeImage(),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 450,
                    child: LoginAndSignupBtn(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileWelcomeScreen extends StatelessWidget {
  const MobileWelcomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        WelcomeImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: LoginAndSignupBtn(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
