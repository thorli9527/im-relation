import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

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

class DebugLogBuffer extends ChangeNotifier implements LogOutput {
  DebugLogBuffer({this.capacity = 500});

  final int capacity;
  final List<DebugLogRecord> _records = <DebugLogRecord>[];

  List<DebugLogRecord> get records => List.unmodifiable(_records);

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
