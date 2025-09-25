import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({required String baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            headers: {'content-type': 'application/json'},
          ),
        );

  final Dio _dio;
  String? _token;

  void updateToken(String? token) {
    _token = token;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: _requestOptions(),
    );
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      options: _requestOptions(),
    );
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      path,
      data: data,
      options: _requestOptions(),
    );
    return _unwrap(response);
  }

  Map<String, dynamic> _unwrap(Response<Map<String, dynamic>> response) {
    final payload = response.data;
    if (payload == null) {
      throw const ApiClientException('服务器返回为空');
    }

    final code = payload['code'] ?? payload['status'];
    final message = payload['message']?.toString() ?? '未知错误';
    final data = payload['data'];

    final successCodes = {0, 200};
    if (successCodes.contains(code)) {
      if (data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data);
      }
      if (data is List) {
        return {'list': data};
      }
      if (data == null) {
        return <String, dynamic>{};
      }
      return {'value': data};
    }

    throw ApiClientException(message, code: code is int ? code : null);
  }

  Options _requestOptions() {
    final headers = <String, dynamic>{};
    if (_token != null && _token!.isNotEmpty) {
      headers['authorization'] = _token;
    }
    return Options(headers: headers);
  }

  void dispose() {
    _dio.close(force: true);
  }
}

class ApiClientException implements Exception {
  const ApiClientException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'ApiClientException($code): $message';
}
