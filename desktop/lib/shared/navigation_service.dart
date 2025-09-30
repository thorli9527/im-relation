// lib/shared/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static void navigateToLogin(BuildContext context, {bool replace = false}) {
    if (replace) {
      context.go('/login');
    } else {
      context.push('/login');
    }
  }

  static void navigateToSignUp(BuildContext context, {bool replace = false}) {
    if (replace) {
      context.go('/signup');
    } else {
      context.push('/signup');
    }
  }

  static void navigateToWelcome(BuildContext context, {bool replace = false}) {
    if (replace) {
      context.go('/welcome');
    } else {
      context.push('/welcome');
    }
  }

  // 添加导航到主界面的方法
  static void navigateToMain(BuildContext context, {bool replace = false}) {
    if (replace) {
      context.go('/'); // 主界面路由
    } else {
      context.push('/');
    }
  }
}
