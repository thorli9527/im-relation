// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import 'package:im_client/core/config/app_config.dart';
import 'package:im_client/core/config/app_config_controller.dart';
import 'package:im_client/core/providers/app_providers.dart';
import 'package:im_client/core/socket/socket_manager.dart';
import 'package:im_client/core/storage/auth_session.dart';
import 'package:im_client/core/storage/device_profile.dart';
import 'package:im_client/core/storage/local_store.dart';
import 'package:im_client/features/auth/login_page.dart';
import 'package:im_client/features/chat/chat_home_page.dart';
import 'package:im_client/gen/api/auth.pb.dart';
import 'package:im_client/gen/api/socket.pb.dart' as socketpb;

void main() {
  testWidgets('Login page renders primary controls', (tester) async {
    final store = _FakeLocalStore();
    final socketStub = _StubSocketManager();
    addTearDown(() => socketStub.dispose());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigNotifierProvider.overrideWith(
            (_) => AppConfigNotifier(AppConfigData.fallback()),
          ),
          localStoreProvider.overrideWithValue(store),
          socketManagerProvider.overrideWithValue(socketStub),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('账号'), findsOneWidget);
    expect(find.text('用户名 / 邮箱 / 手机号'), findsOneWidget);
  });

  testWidgets('Submitting empty form shows validation errors', (tester) async {
    final store = _FakeLocalStore();
    final socketStub = _StubSocketManager();
    addTearDown(() => socketStub.dispose());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigNotifierProvider.overrideWith(
            (_) => AppConfigNotifier(AppConfigData.fallback()),
          ),
          localStoreProvider.overrideWithValue(store),
          socketManagerProvider.overrideWithValue(socketStub),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    expect(find.text('请输入账号'), findsOneWidget);
    expect(find.text('请输入密码'), findsOneWidget);
  });

  testWidgets('Chat home page renders sidebar and chat pane', (tester) async {
    final response = LoginResponse()..token = 'abcdefghijk';
    final store = _FakeLocalStore();
    final socketStub = _StubSocketManager();
    addTearDown(() => socketStub.dispose());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigNotifierProvider.overrideWith(
            (_) => AppConfigNotifier(AppConfigData.fallback()),
          ),
          localStoreProvider.overrideWithValue(store),
          socketManagerProvider.overrideWithValue(socketStub),
        ],
        child: MaterialApp(
          home: ChatHomePage(
            session: response,
            account: 'tester',
            userId: 1,
            deviceId: 'dev-test',
            deviceType: 4,
          ),
        ),
      ),
    );

    expect(find.text('暂无联系人'), findsOneWidget);
    expect(find.text('请选择会话'), findsOneWidget);
  });
}

class _FakeLocalStore implements LocalStore {
  _FakeLocalStore({String deviceId = 'dev-test'}) {
    final now = DateTime.now();
    _profile = DeviceProfile()
      ..id = 0
      ..deviceId = deviceId
      ..deviceType = kDefaultDeviceType
      ..createdAt = now
      ..updatedAt = now;
    _session = AuthSession()
      ..id = 0
      ..isLoggedIn = false
      ..updatedAt = now;
  }

  late DeviceProfile _profile;
  late AuthSession _session;

  @override
  Isar get isar => throw UnimplementedError('Not available in widget tests');

  @override
  Future<DeviceProfile> ensureDeviceProfile() async => _profile;

  @override
  Future<AuthSession> ensureAuthSession() async => _session;

  @override
  Future<DeviceProfile> getDeviceProfile() async => _profile;

  @override
  Future<AuthSession> getAuthSession() async => _session;

  @override
  Future<void> markLoggedOut() async {
    _session
      ..isLoggedIn = false
      ..userId = null
      ..token = null
      ..expiresAt = null
      ..socketAddr = null
      ..updatedAt = DateTime.now();
  }

  @override
  Future<void> persistLoginSuccess({
    required int userId,
    required int loginType,
    required String account,
    required String password,
    required int deviceType,
    required String deviceId,
    required String token,
    required int expiresAt,
    required String socketAddr,
  }) async {
    _session
      ..isLoggedIn = true
      ..userId = userId
      ..loginType = loginType
      ..account = account
      ..password = password
      ..deviceType = deviceType
      ..token = token
      ..expiresAt = expiresAt
      ..socketAddr = socketAddr
      ..updatedAt = DateTime.now();
    _profile
      ..deviceId = deviceId
      ..deviceType = deviceType
      ..updatedAt = DateTime.now();
  }

  @override
  Future<void> refreshToken({
    required String token,
    required int expiresAt,
    int? userId,
  }) async {
    _session
      ..token = token
      ..expiresAt = expiresAt
      ..isLoggedIn = true
      ..userId = userId ?? _session.userId
      ..updatedAt = DateTime.now();
  }
}

class _StubSocketManager extends SocketManager {
  _StubSocketManager()
    : _controller = StreamController<socketpb.ServerMsg>.broadcast(),
      super(logger: Logger());

  final StreamController<socketpb.ServerMsg> _controller;

  @override
  Stream<socketpb.ServerMsg> get messages => _controller.stream;

  @override
  Future<void> connect({
    required String address,
    required int userId,
    required int deviceType,
    required String deviceId,
    required String token,
    int? resumeAckId,
  }) async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
