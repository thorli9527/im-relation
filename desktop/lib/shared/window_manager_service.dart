import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

class WindowManagerService {
  static Future<void> init() async {
    if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
      return;
    }

    try {
      // 必须在 runApp 之前调用
      await windowManager.ensureInitialized();

      // 设置窗口初始化选项
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1200, 800), // 设置默认窗口大小
        center: true,          // 窗口居中
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.maximize(); // 启动时最大化窗口
        await windowManager.show();
      });
    } catch (e) {
      // 错误处理，避免因为窗口管理问题导致应用无法启动
      print('Window manager initialization failed: $e');
    }
  }

  // 其他方法保持不变...
}
