import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../data/models/auth_session.dart';
import '../data/models/message.dart';
import '../data/sample/sample_data.dart';

class SocketService {
  SocketService({required this.socketUrl});

  final String socketUrl;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final _controller = StreamController<Message>.broadcast();

  Stream<Message> get messages => _controller.stream;

  Future<void> connect(AuthSession session) async {
    await disconnect();
    try {
      final uri = Uri.parse(socketUrl);
      _channel = WebSocketChannel.connect(uri);
      _subscription = _channel!.stream.listen(
        (event) {
          _controller.add(
            Message.system(
              id: 'socket-${DateTime.now().millisecondsSinceEpoch}',
              conversationId: 'conv-lena',
              content: '收到原始推送：$event',
            ),
          );
        },
        onError: (error, stackTrace) {
          _controller.add(
            Message.system(
              id: 'socket-error',
              conversationId: 'conv-lena',
              content: 'Socket 错误：$error',
            ),
          );
        },
        onDone: () {
          _controller.add(
            Message.system(
              id: 'socket-closed',
              conversationId: 'conv-lena',
              content: 'Socket 已断开',
            ),
          );
        },
      );

      _channel!.sink.add('AUTH ${session.token}');
      _simulateIncoming();
    } catch (error) {
      _controller.add(
        Message.system(
          id: 'socket-failed',
          conversationId: 'conv-lena',
          content: '无法连接消息网关：$error',
        ),
      );
      _simulateIncoming();
    }
  }

  void _simulateIncoming() {
    Future.delayed(const Duration(seconds: 4), () {
      if (_controller.isClosed) return;
      final contact = SampleData.contacts().first;
      _controller.add(
        SampleData.incomingMessage('conv-lena', contact),
      );
    });
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    unawaited(disconnect());
    _controller.close();
  }
}
