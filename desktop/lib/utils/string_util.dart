import 'package:uuid/uuid.dart';

class StringUtil {
  /// 判断字符串是否为空或null
  static bool isNullOrEmpty(String? s) {
    return s == null || s.trim().isEmpty;
  }

  /// 截取字符串（从 start 到 end）
  static String substring(String s, int start, [int? end]) {
    if (start < 0) start = 0;
    if (end == null || end > s.length) end = s.length;
    return s.substring(start, end);
  }

  /// 超出长度后省略
  static String ellipsis(String s, int maxLength) {
    if (s.length <= maxLength) {
      return s;
    } else {
      return '${s.substring(0, maxLength)}...';
    }
  }

  /// 移除所有空白字符
  static String removeWhitespace(String s) {
    return s.replaceAll(RegExp(r'\s+'), '');
  }

  /// 判断是否是纯数字
  static bool isNumeric(String? s) {
    if (s == null || s.isEmpty) return false;
    return double.tryParse(s) != null;
  }

  /// 将字符串首字母大写
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String buildUUid(){
    return Uuid().v4().replaceAll('-', '');
  }
}
