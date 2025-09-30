import 'dart:ffi';
import 'package:fixnum/fixnum.dart';
import 'package:intl/intl.dart';

class TimeUtil {
  /// 格式化时间戳为指定格式
  static String formatTimestamp(int timestamp, [String format = "yyyy-MM-dd HH:mm:ss"]) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat(format).format(date);
  }

  /// 获取当前时间戳（毫秒）
  static int currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static Int64 currentTimeI64() {
    return Int64(currentTimeMillis());
  }
  /// 判断是否是今天
  static bool isToday(int timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// 判断两个时间是否同一天
  static bool isSameDay(int timestamp1, int timestamp2) {
    final date1 = DateTime.fromMillisecondsSinceEpoch(timestamp1);
    final date2 = DateTime.fromMillisecondsSinceEpoch(timestamp2);
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
