class AppConfig {
  static const String baseUrl = 'http://127.0.0.1:8004';

  static const String apiGrpcHost = '127.0.0.1';
  static const int apiGrpcPort = 50051;
  static const String onlineGrpcHost = '127.0.0.1';
  static const int onlineGrpcPort = 6001;

  static const String socketHost = '127.0.0.1';
  static const int socketPort = 8001;

  static String get apiGrpcEndpoint => '$apiGrpcHost:$apiGrpcPort';
  static String get onlineGrpcEndpoint => '$onlineGrpcHost:$onlineGrpcPort';
}
