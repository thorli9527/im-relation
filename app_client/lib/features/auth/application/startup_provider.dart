import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:im_client/core/providers/app_providers.dart';
import 'package:im_client/features/auth/models/login_payload.dart';
import 'package:im_client/gen/api/auth.pb.dart';

class StartupResult {
  const StartupResult._({
    required this.needsLogin,
    this.deviceId,
    this.deviceType,
    this.userId,
    this.account,
    this.session,
    this.error,
  });

  final bool needsLogin;
  final String? deviceId;
  final int? deviceType;
  final int? userId;
  final String? account;
  final LoginResponse? session;
  final String? error;

  factory StartupResult.loginRequired({
    required String deviceId,
    int? deviceType,
    String? account,
  }) => StartupResult._(
    needsLogin: true,
    deviceId: deviceId,
    deviceType: deviceType,
    account: account,
  );

  factory StartupResult.loggedIn({
    required String account,
    required LoginResponse session,
    required int userId,
    required String deviceId,
    required int deviceType,
  }) => StartupResult._(
    needsLogin: false,
    userId: userId,
    deviceId: deviceId,
    deviceType: deviceType,
    account: account,
    session: session,
  );

  factory StartupResult.error(String message) =>
      StartupResult._(needsLogin: true, error: message);
}

final authStartupProvider = FutureProvider<StartupResult>((ref) async {
  final store = ref.read(localStoreProvider);
  final device = await store.getDeviceProfile();
  final session = await store.getAuthSession();

  final storedToken = session.token;
  final storedAccount = session.account;
  final storedPassword = session.password;
  final storedLoginType = session.loginType;
  final storedDeviceType = session.deviceType ?? device.deviceType;

  if (session.isLoggedIn != true ||
      storedToken == null ||
      storedToken.isEmpty) {
    await store.markLoggedOut();
    return StartupResult.loginRequired(
      deviceId: device.deviceId,
      deviceType: storedDeviceType,
      account: storedAccount,
    );
  }

  final api = ref.read(authApiClientProvider);
  try {
    final validation = await api.validateToken(storedToken);
    if (!validation.ok) {
      final method = storedLoginType != null
          ? LoginMethodX.fromLoginType(storedLoginType)
          : null;
      if (storedAccount?.isNotEmpty == true &&
          storedPassword?.isNotEmpty == true &&
          method != null) {
        final payload = LoginRequestPayload(
          loginMethod: method,
          target: storedAccount!,
          password: storedPassword!,
          deviceType: storedDeviceType,
          deviceId: device.deviceId,
        );
        final loginResp = await api.login(payload);
        final loginValidation = await api.validateToken(loginResp.token);
        if (!loginValidation.ok) {
          await store.markLoggedOut();
          return StartupResult.loginRequired(
            deviceId: device.deviceId,
            deviceType: payload.deviceType,
            account: storedAccount,
          );
        }

        final refreshedToken = loginValidation.token.isNotEmpty
            ? loginValidation.token
            : loginResp.token;
        final expiresAt = loginValidation.expiresAt.toInt();
        final userId = loginValidation.userId.toInt();

        loginResp
          ..token = refreshedToken
          ..expiresAt = loginValidation.expiresAt;

        await store.persistLoginSuccess(
          userId: userId,
          loginType: payload.loginType,
          account: payload.target,
          password: payload.password,
          deviceType: payload.deviceType,
          deviceId: payload.deviceId,
          token: refreshedToken,
          expiresAt: expiresAt,
          socketAddr: loginResp.socketAddr,
        );
        return StartupResult.loggedIn(
          account: payload.target,
          session: loginResp,
          userId: userId,
          deviceId: payload.deviceId,
          deviceType: payload.deviceType,
        );
      }

      await store.markLoggedOut();
      return StartupResult.loginRequired(
        deviceId: device.deviceId,
        deviceType: storedDeviceType,
        account: storedAccount,
      );
    }

    final userId = validation.userId.toInt();
    final refreshedToken = validation.token.isNotEmpty
        ? validation.token
        : storedToken;
    final expiresAt = validation.expiresAt.toInt();

    await store.refreshToken(
      token: refreshedToken,
      expiresAt: expiresAt,
      userId: userId,
    );

    final refreshedSession = LoginResponse(
      token: refreshedToken,
      expiresAt: validation.expiresAt,
      socketAddr: session.socketAddr ?? '',
    );

    return StartupResult.loggedIn(
      account: storedAccount ?? '',
      session: refreshedSession,
      userId: userId,
      deviceId: device.deviceId,
      deviceType: storedDeviceType,
    );
  } catch (error, stackTrace) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('auth bootstrap failed: $error\n$stackTrace');
    }
    return StartupResult.error(error.toString());
  }
});
