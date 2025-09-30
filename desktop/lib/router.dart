// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:im_client/views/auth/welcome/welcome_screen.dart';
import 'package:im_client/views/auth/login/login_screen.dart';
import 'package:im_client/views/auth/signup/signup_screen.dart';
import 'package:im_client/views/main/main_screen.dart'; // 添加导入

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(), // 主界面作为首页
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
  ],
);
