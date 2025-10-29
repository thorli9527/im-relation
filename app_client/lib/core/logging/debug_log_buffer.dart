/// 将 `logger` 输出缓冲到内存，供调试界面展示最近日志。
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 单条日志的标准化结构，便于界面统一渲染。
class DebugLogRecord {
  DebugLogRecord({
    required this.level,
    required this.time,
    required this.message,
    required this.lines,
    this.error,
    this.stackTrace,
  });

  final Level level;
  final DateTime time;
  final String message;
  final List<String> lines;
  final Object? error;
  final StackTrace? stackTrace;

  /// 将 `logger` 框架的输出事件转换为内部结构。
  factory DebugLogRecord.fromOutput(OutputEvent event) {
    final logEvent = event.origin;
    return DebugLogRecord(
      level: logEvent.level,
      time: logEvent.time,
      message: logEvent.message?.toString() ?? '',
      lines: List<String>.from(event.lines),
      error: logEvent.error,
      stackTrace: logEvent.stackTrace,
    );
  }
}

/// 环形缓冲实现，既作为 `LogOutput` 接收日志，又向监听者广播变更。
class DebugLogBuffer extends ChangeNotifier implements LogOutput {
  DebugLogBuffer({this.capacity = 500});

  final int capacity;
  final List<DebugLogRecord> _records = <DebugLogRecord>[];

  List<DebugLogRecord> get records => List.unmodifiable(_records);

  /// 清空所有历史记录并通知监听者。
  void clear() {
    if (_records.isEmpty) {
      return;
    }
    _records.clear();
    notifyListeners();
  }

  @override
  Future<void> init() async {}

  @override
  /// 将新的日志事件放入缓存，超过容量时丢弃最旧记录。
  void output(OutputEvent event) {
    final record = DebugLogRecord.fromOutput(event);
    _records.add(record);
    if (_records.length > capacity) {
      _records.removeRange(0, _records.length - capacity);
    }
    notifyListeners();
  }

  @override
  Future<void> destroy() async {}
}
