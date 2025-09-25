import 'user_profile.dart';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
    required this.deviceId,
  });

  final String token;
  final UserProfile user;
  final String deviceId;

  AuthSession copyWith({
    String? token,
    UserProfile? user,
    String? deviceId,
  }) {
    return AuthSession(
      token: token ?? this.token,
      user: user ?? this.user,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'deviceId': deviceId,
      'user': user.toJson(),
    };
  }

  static const empty = AuthSession(
    token: '',
    user: UserProfile.empty,
    deviceId: 'desktop',
  );
}
