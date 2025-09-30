import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/constants.dart';
import '../../../../shared/widgets/svg_image_display.dar.dart';

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgImageDisplay(
      assetPath: "assets/icons/signup.svg",
      title: "Sign Up".toUpperCase(),
      titlePadding: defaultPadding,
    );
  }
}
