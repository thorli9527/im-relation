import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ),
  )..interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: print, // 可替换为 logger.i
    ),
  );

  /// 通用 POST 请求
  static Future<ApiResponse<T>> post<T>({
    required String path,
    Map<String, dynamic>? data,
    required T Function(dynamic) fromJsonT,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse<T>.fromJson(response.data, fromJsonT);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 通用 GET 请求
  static Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParams,
    required T Function(dynamic) fromJsonT,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return ApiResponse<T>.fromJson(response.data, fromJsonT);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 错误处理提取
  static String _handleError(DioException e) {
    return e.response?.data?['message'] ?? e.message ?? 'Unknown error';
  }
}
