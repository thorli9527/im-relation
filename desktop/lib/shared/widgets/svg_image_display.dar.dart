// 文件路径: lib/shared/widgets/svg_image_display.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgImageDisplay extends StatelessWidget {
  final String assetPath;
  final String title;
  final double titlePadding;

  const SvgImageDisplay({
    Key? key,
    required this.assetPath,
    required this.title,
    this.titlePadding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: titlePadding),
        SvgPicture.asset(
          assetPath,
          height: 200,
        ),
        SizedBox(height: titlePadding),
      ],
    );
  }
}
