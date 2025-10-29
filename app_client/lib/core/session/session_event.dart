/// 会话事件模型与 Riverpod 通知工具，为 UI 提供被踢下线等系统提示。
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionEventType { kicked }

@immutable
class SessionEvent {
  const SessionEvent._({
    required this.type,
    this.reason,
    this.deviceType,
    this.noticeType,
    this.message,
    required this.timestamp,
  });

  final SessionEventType type;
  final String? reason;
  final String? deviceType;
  final String? noticeType;
  final String? message;
  final DateTime timestamp;

  /// 构造一次被踢下线事件，用于提示用户或强制退出到登录页。
  factory SessionEvent.kicked({
    String? reason,
    String? deviceType,
    String? noticeType,
    String? message,
  }) {
    return SessionEvent._(
      type: SessionEventType.kicked,
      reason: reason,
      deviceType: deviceType,
      noticeType: noticeType,
      message: message,
      timestamp: DateTime.now(),
    );
  }
}

/// Riverpod 状态管理器，用于广播最新的会话事件并在消费后清理。
class SessionEventNotifier extends StateNotifier<SessionEvent?> {
  SessionEventNotifier() : super(null);

  void emit(SessionEvent event) {
    state = event;
  }

  void clear() {
    state = null;
  }
}
