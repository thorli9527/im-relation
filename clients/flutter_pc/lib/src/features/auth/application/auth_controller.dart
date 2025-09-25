import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_providers.dart';
import '../../../data/api/api_client.dart';
import '../../../data/auth/auth_repository.dart';
import '../../../data/models/auth_session.dart';
import '../../../data/models/user_profile.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(AuthState.initializing) {
    _restoreSession();
  }

  final Ref _ref;
  static const _tokenKey = 'session.token';
  static const _deviceKey = 'session.deviceId';

  Future<void> _restoreSession() async {
    state = AuthState.initializing;
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final storedToken = prefs.getString(_tokenKey);
      final deviceId = prefs.getString(_deviceKey) ?? _generateDeviceId();
      if (storedToken == null || storedToken.isEmpty) {
        state = AuthState.unauthenticated;
        return;
      }

      _ref.read(apiClientProvider).updateToken(storedToken);
      final profile = await _ref.read(authRepositoryProvider).fetchProfile();
      final session = AuthSession(
        token: storedToken,
        user: profile,
        deviceId: deviceId,
      );
      state = AuthState(status: AuthStatus.authenticated, session: session);
    } catch (_) {
      state = AuthState.unauthenticated;
    }
  }

  Future<void> login({
    required LoginIdentifier identifier,
    required String target,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final deviceId = prefs.getString(_deviceKey) ?? _generateDeviceId();
      final payload = LoginPayload(
        identifier: identifier,
        target: target,
        password: password,
        deviceId: deviceId,
      );
      final token = await _ref.read(authRepositoryProvider).login(payload);
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_deviceKey, deviceId);

      _ref.read(apiClientProvider).updateToken(token);
      final profile = await _ref.read(authRepositoryProvider).fetchProfile();
      final session = AuthSession(token: token, user: profile, deviceId: deviceId);
      state = AuthState(status: AuthStatus.authenticated, session: session);
    } on ApiClientException catch (error) {
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: error.message,
      );
    } catch (error) {
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_tokenKey);
    _ref.read(apiClientProvider).updateToken(null);
    state = AuthState.unauthenticated;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<UserProfile> refreshProfile() async {
    final profile = await _ref.read(authRepositoryProvider).fetchProfile();
    final current = state.session;
    if (current != null) {
      final updated = current.copyWith(user: profile);
      state = state.copyWith(session: updated);
    }
    return profile;
  }

  String _generateDeviceId() {
    final random = Random.secure().nextInt(999999);
    return 'desktop-$random-${DateTime.now().millisecondsSinceEpoch}';
  }
}
