// lib/utils/log_util.dart
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warning,
  error;

  /// 将字符串转换为 LogLevel
  static LogLevel fromString(String level) {
    switch (level.toUpperCase()) {
      case 'DEBUG':
        return LogLevel.debug;
      case 'INFO':
        return LogLevel.info;
      case 'WARNING':
        return LogLevel.warning;
      case 'ERROR':
        return LogLevel.error;
      default:
        return LogLevel.debug;
    }
  }

  @override
  String toString() {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}

/// 日志工具类
///
/// 提供日志记录功能，支持不同日志级别和文件输出
class LogUtil {
  static bool _isDebug = kDebugMode;
  static LogLevel _currentLevel = LogLevel.debug;
  static bool _isInitialized = false;
  static String? _logFilePath;
  static IOSink? _fileSink;
  static final _lock = Lock(); // 线程安全锁
  static int _logFileSize = 0;
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB

  /// 初始化日志服务
  ///
  /// 创建日志目录和文件，准备写入日志
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 获取日志文件路径
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      // 创建日志目录（如果不存在）
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // 清理旧日志文件（保留最近30天）
      await _cleanupOldLogs(logDir);

      // 创建日志文件
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final timestamp = "${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";
      final logFile = File('${logDir.path}/app_$dateStr-$timestamp.log');
      _logFilePath = logFile.path;

      // 创建文件写入流
      _fileSink = logFile.openWrite(mode: FileMode.append);
      _logFileSize = await logFile.length();

      _isInitialized = true;

      // 在初始化完成后记录日志
      info('LogUtil', '✅ 日志服务初始化完成');
      info('LogUtil', '📂 日志文件路径: $_logFilePath');
    } catch (e) {
      // 在初始化失败时使用基本的print输出错误
      if (kDebugMode) {
        print('❌ 日志服务初始化失败: $e');
      }
    }
  }

  /// 清理旧日志文件
  static Future<void> _cleanupOldLogs(Directory logDir) async {
    try {
      final files = logDir.listSync().whereType<File>();
      final now = DateTime.now();

      for (final file in files) {
        final lastModified = await file.lastModified();
        final difference = now.difference(lastModified).inDays;
        // 删除30天前的日志文件
        if (difference > 30) {
          await file.delete();
          if (kDebugMode) {
            print('🗑️ 删除旧日志文件: ${file.path}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 清理旧日志文件时出错: $e');
      }
    }
  }

  /// 记录调试日志
  static void debug(String tag, String message) {
    _log(LogLevel.debug, tag, message);
  }

  /// 记录错误日志
  static void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, tag, message, error, stackTrace);
  }

  /// 记录信息日志
  static void info(String tag, String message) {
    _log(LogLevel.info, tag, message);
  }

  /// 记录警告日志
  static void warning(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, tag, message, error, stackTrace);
  }

  /// 设置日志开关
  static void setLogEnable(bool enable) {
    _isDebug = enable;
  }

  /// 设置日志输出级别
  static void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// 判断是否应该记录指定级别的日志
  static bool _shouldLog(LogLevel level) {
    if (!_isDebug) return false;

    const levelValues = {LogLevel.debug: 0, LogLevel.info: 1, LogLevel.warning: 2, LogLevel.error: 3};
    return levelValues[level]! >= levelValues[_currentLevel]!;
  }

  /// 公共日志处理方法
  static void _log(LogLevel level, String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (!_shouldLog(level)) return;

    final now = DateTime.now();
    final timestamp = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}";

    final logMessage = '[$timestamp] ${level.toString().toUpperCase()} [$tag] $message';

    // 控制台输出
    if (kDebugMode) {
      // 根据日志级别使用不同颜色输出
      final coloredMessage = _colorizeLog(level, logMessage);
      print(coloredMessage);

      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace:\n$stackTrace');
    }

    // 文件输出（使用锁确保线程安全）
    _lock.synchronized(() async {
      if (_isInitialized && _fileSink != null) {
        try {
          _fileSink!.writeln(logMessage);
          _logFileSize += logMessage.length + 1; // +1 for newline

          if (error != null) {
            final errorStr = 'Error: $error';
            _fileSink!.writeln(errorStr);
            _logFileSize += errorStr.length + 1;
          }

          if (stackTrace != null) {
            final stackTraceStr = 'StackTrace:\n$stackTrace';
            _fileSink!.writeln(stackTraceStr);
            _logFileSize += stackTraceStr.length + 1;
          }

          // 定期刷新文件缓冲区
          await _fileSink!.flush();

          // 检查文件大小，如果超过限制则轮转
          if (_logFileSize > _maxFileSize) {
            await _rotateLogFile();
          }
        } catch (e) {
          // 文件写入失败时仅在控制台输出错误
          if (kDebugMode) {
            print('❌ 写入日志文件时出错: $e');
          }
        }
      }
    });
  }

  /// 为控制台输出添加颜色
  static String _colorizeLog(LogLevel level, String message) {
    if (!kDebugMode) return message;

    const reset = '\x1B[0m';
    const red = '\x1B[31m';
    const green = '\x1B[32m';
    const yellow = '\x1B[33m';
    const magenta = '\x1B[35m';

    switch (level) {
      case LogLevel.debug:
        return '$magenta$message$reset';
      case LogLevel.info:
        return '$green$message$reset';
      case LogLevel.warning:
        return '$yellow$message$reset';
      case LogLevel.error:
        return '$red$message$reset';
    }
  }

  /// 轮转日志文件
  static Future<void> _rotateLogFile() async {
    try {
      await _fileSink?.flush();
      await _fileSink?.close();

      // 重命名当前日志文件
      final oldFile = File(_logFilePath!);
      final newName = '${_logFilePath!.split('.log')[0]}_old.log';
      await oldFile.rename(newName);

      // 创建新的日志文件
      final newFile = File(_logFilePath!);
      _fileSink = newFile.openWrite(mode: FileMode.append);
      _logFileSize = 0;

      info('LogUtil', '🔄 日志文件已轮转');
    } catch (e) {
      if (kDebugMode) {
        print('❌ 轮转日志文件时出错: $e');
      }
    }
  }

  /// 获取日志文件路径
  static String? get logFilePath => _logFilePath;

  /// 关闭日志服务，释放资源
  static Future<void> close() async {
    await _lock.synchronized(() async {
      await _fileSink?.flush();
      await _fileSink?.close();
      _fileSink = null;
      _isInitialized = false;
    });
  }
}
