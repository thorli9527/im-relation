class ApiResponse<T> {
  /// 业务状态码（如 200 表示成功）
  final int code;

  /// 接口返回信息
  final String? message;

  /// 是否成功（可用于统一判断）
  final bool success;

  /// 泛型数据字段
  final T? data;

  ApiResponse({
    required this.code,
    required this.success,
    this.message,
    this.data,
  });

  /// 从 JSON 构造泛型响应体
  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    return ApiResponse<T>(
      code: json['code'] ?? -1,
      success: json['success'] ?? false,
      message: json['message'], // 允许为 null
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  /// 是否请求成功（可选快捷方法）
  bool get isOk => success == true;
}
