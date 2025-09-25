class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.socketUrl,
  });

  final String apiBaseUrl;
  final String socketUrl;

  static const AppConfig defaults = AppConfig(
    apiBaseUrl: 'http://127.0.0.1:8004',
    socketUrl: 'ws://127.0.0.1:9004/ws',
  );
}
