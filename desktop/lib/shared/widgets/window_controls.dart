import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowControls extends StatefulWidget {
  const WindowControls({Key? key}) : super(key: key);

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                icon: const Icon(Icons.minimize, size: 18),
                onPressed: () => windowManager.minimize(),
                padding: EdgeInsets.zero,
                splashRadius: 18,
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                icon: const Icon(Icons.crop_square, size: 16),
                onPressed: () => windowManager.maximize(),
                padding: EdgeInsets.zero,
                splashRadius: 18,
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => windowManager.close(),
                padding: EdgeInsets.zero,
                splashRadius: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
