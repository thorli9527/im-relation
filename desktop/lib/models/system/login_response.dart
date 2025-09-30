class LoginResponse {
  final String token;
  final String username;
  final String avatar;

  LoginResponse({required this.token, required this.username,required this.avatar});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      username: json['username'],
      avatar: json['avatar'],
    );
  }
}
