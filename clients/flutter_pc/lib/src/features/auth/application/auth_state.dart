import '../../../data/models/auth_session.dart';

enum AuthStatus { initializing, unauthenticated, authenticating, authenticated, failure }

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    String? errorMessage,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  static const AuthState initializing =
      AuthState(status: AuthStatus.initializing);

  static const AuthState unauthenticated =
      AuthState(status: AuthStatus.unauthenticated);
}
