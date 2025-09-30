import 'dart:async';
import '../../models/generated/status.pb.dart';
import '../../utils/log_util.dart';
import '../stream_client.dart';

class HeartbeatTimer {
  Timer? _heartbeatTimer;
  final Duration interval;

  HeartbeatTimer({this.interval = const Duration(seconds: 20)});

  void start(StreamClient client, {required Duration interval}) {
    stop(); // 确保不重复创建

    _heartbeatTimer = Timer.periodic(interval, (_) {
      if (client.status != ConnectionStatus.connected) {
        LogUtil.warning('Heartbeat', '💔 Not connected, stopping heartbeat');
        stop();
        return;
      }

      try {
        client.send(HeartbeatMsg());
        LogUtil.debug('Heartbeat', '🫀 Sent heartbeat');
      } catch (e) {
        LogUtil.error('Heartbeat', '❌ Failed to send heartbeat: $e');
        stop();
      }
    });

    LogUtil.info('Heartbeat', '🔁 Heartbeat timer started');
  }

  void stop() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    LogUtil.info('Heartbeat', '⏹️ Heartbeat timer stopped');
  }

  bool get isRunning => _heartbeatTimer != null;
}
