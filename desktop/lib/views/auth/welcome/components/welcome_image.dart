import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/constants.dart';
import '../../../../shared/widgets/svg_image_display.dar.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgImageDisplay(
      assetPath: "assets/icons/chat.svg",
      title: "WELCOME TO EDU",
      titlePadding: defaultPadding * 2,
    );
  }
}
