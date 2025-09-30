import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    final BaseOptions options = BaseOptions(
      baseUrl: 'https://your-api-base-url.com', // 修改为你的地址
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    dio.interceptors.addAll([
      _HeaderInterceptor(),
      _LoggerInterceptor(),
      _ErrorInterceptor(),
    ]);
  }
}


class _HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = "nonce_${DateTime.now().microsecondsSinceEpoch}";
    final signature = _generateSignature( timestamp, nonce); // 自定义

    options.headers.addAll({
      'timestamp': timestamp,
      'nonce': nonce,
      'signature': signature,
    });

    return handler.next(options);
  }

  String _generateSignature( String timestamp, String nonce) {
    // 可用 HMAC 或自定义规则
    return "mock_signature"; // 替换为实际签名
  }
}
class _LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('➡️ [${options.method}] ${options.uri}');
    print('Headers: ${options.headers}');
    print('Data: ${options.data}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ [${response.statusCode}] ${response.requestOptions.uri}');
    print('Response: ${response.data}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ Error: ${err.message}');
    return handler.next(err);
  }
}
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 可根据 statusCode 或 type 进行处理
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        err = DioException(requestOptions: err.requestOptions, message: "连接超时");
        break;
      case DioExceptionType.receiveTimeout:
        err = DioException(requestOptions: err.requestOptions, message: "响应超时");
        break;
      case DioExceptionType.badResponse:
        err = DioException(
          requestOptions: err.requestOptions,
          message: "服务异常 (${err.response?.statusCode})",
        );
        break;
      default:
        err = DioException(requestOptions: err.requestOptions, message: "网络错误");
    }

    return handler.next(err);
  }
}
