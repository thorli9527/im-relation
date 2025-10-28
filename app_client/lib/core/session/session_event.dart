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

class SessionEventNotifier extends StateNotifier<SessionEvent?> {
  SessionEventNotifier() : super(null);

  void emit(SessionEvent event) {
    state = event;
  }

  void clear() {
    state = null;
  }
}
