// 文件路径: lib/channel/stream_client.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:riverpod/riverpod.dart';

import '../models/generated/socket/socket.pb.dart' as socket_pb;
import '../models/generated/socket/socket.pbenum.dart' as socket_enum;
import '../utils/log_util.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
}

class SocketAuthContext {
  final int userId;
  final socket_enum.DeviceType deviceType;
  final String deviceId;
  final String token;
  final int expiresAtMs;
  final bool resume;
  final int lastAckId;
  final bool supportsEncryption;
  final List<String> encryptionSchemes;

  const SocketAuthContext({
    required this.userId,
    required this.deviceType,
    required this.deviceId,
    required this.token,
    required this.expiresAtMs,
    this.resume = false,
    this.lastAckId = 0,
    this.supportsEncryption = false,
    this.encryptionSchemes = const [],
  });

  socket_pb.AuthMsg toProto() {
    return socket_pb.AuthMsg(
      userId: Int64(userId),
      deviceType: deviceType,
      deviceId: deviceId,
      token: token,
      tsMs: Int64(DateTime.now().millisecondsSinceEpoch),
      resume: resume,
      lastAckId: Int64(lastAckId),
      supportsEncryption: supportsEncryption,
      encryptionSchemes: encryptionSchemes,
    );
  }
}

class StreamClient {
  Socket? _socket;
  StreamSubscription<List<int>>? _subscription;
  final _connectionController = StreamController<ConnectionStatus>.broadcast();
  final _messageController = StreamController<socket_pb.ServerMsg>.broadcast();
  final _buffer = BytesBuilder(copy: false);

  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionStatus get status => _status;
  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;
  Stream<socket_pb.ServerMsg> get messageStream => _messageController.stream;

  String? _currentHost;
  int? _currentPort;
  SocketAuthContext? _lastAuth;

  Future<void> connectWithAuth({
    required String host,
    required int port,
    required SocketAuthContext auth,
  }) async {
    if (_status != ConnectionStatus.disconnected) {
      await closeConnection();
    }

    _setStatus(ConnectionStatus.connecting);
    try {
      LogUtil.info('StreamClient', '🔌 连接中 $host:$port');
      final socket = await Socket.connect(host, port);
      socket.setOption(SocketOption.tcpNoDelay, true);
      _socket = socket;
      _currentHost = host;
      _currentPort = port;
      _lastAuth = auth;

      _subscription = socket.listen(
        _onData,
        onError: _onError,
        onDone: _onDisconnected,
        cancelOnError: true,
      );

      await _sendFrame(auth.toProto());
      _setStatus(ConnectionStatus.connected);
      LogUtil.info('StreamClient', '✅ 连接已建立并发送鉴权');
    } catch (e, stack) {
      LogUtil.error('StreamClient', '❌ 连接失败: $e', e, stack);
      _setStatus(ConnectionStatus.disconnected);
      rethrow;
    }
  }

  Future<void> reconnect() async {
    if (_currentHost == null || _currentPort == null || _lastAuth == null) {
      LogUtil.warning('StreamClient', '⚠️ 无可用的重连信息');
      return;
    }
    LogUtil.info('StreamClient', '🔁 正在重连...');
    await connectWithAuth(
      host: _currentHost!,
      port: _currentPort!,
      auth: _lastAuth!,
    );
  }

  Future<void> sendAck(int messageId) async {
    await sendClientMessage(ack: messageId);
  }

  Future<void> sendClientMessage({
    int? ack,
    socket_enum.MsgKind kind = socket_enum.MsgKind.MK_UNKNOWN,
    List<int> payload = const [],
    int? clientId,
  }) async {
    if (_socket == null) {
      LogUtil.warning('StreamClient', '🚫 无法发送消息：未连接');
      return;
    }

    final msg = socket_pb.ClientMsg(
      ack: ack != null ? Int64(ack) : null,
      kind: kind,
      payload: payload,
      clientId: clientId != null ? Int64(clientId) : null,
    );

    await _sendFrame(msg);
    LogUtil.debug('StreamClient', '📤 上行消息 kind=${kind.value} ack=$ack');
  }

  Future<void> closeConnection() async {
    _subscription?.cancel();
    _subscription = null;
    await _socket?.close();
    _socket = null;
    _buffer.clear();
    if (_status != ConnectionStatus.disconnected) {
      _setStatus(ConnectionStatus.disconnected);
    }
    LogUtil.info('StreamClient', '🔌 已断开连接');
  }

  void dispose() {
    closeConnection();
    _connectionController.close();
    _messageController.close();
  }

  void _onData(List<int> data) {
    _buffer.add(data);
    final bytes = _buffer.toBytes();

    int offset = 0;
    while (offset + 4 <= bytes.length) {
      final length = ByteData.sublistView(bytes, offset, offset + 4)
          .getUint32(0, Endian.big);
      offset += 4;

      if (offset + length > bytes.length) {
        // 未读完，下次继续
        offset -= 4;
        break;
      }

      final payload = bytes.sublist(offset, offset + length);
      offset += length;

      try {
        final message = socket_pb.ServerMsg.fromBuffer(payload);
        _messageController.add(message);
        LogUtil.debug('StreamClient', '📥 收到消息 kind=${message.kind}');
      } catch (e, stack) {
        LogUtil.error('StreamClient', '❌ 解析下行消息失败', e, stack);
      }
    }

    if (offset < bytes.length) {
      _buffer.clear();
      _buffer.add(bytes.sublist(offset));
    } else {
      _buffer.clear();
    }
  }

  void _onError(Object error) {
    LogUtil.error('StreamClient', '⚠️ Socket 错误', error);
    _setStatus(ConnectionStatus.disconnected);
  }

  void _onDisconnected() {
    LogUtil.info('StreamClient', '🔌 服务器断开连接');
    _setStatus(ConnectionStatus.disconnected);
  }

  void _setStatus(ConnectionStatus status) {
    if (_status == status) return;
    _status = status;
    _connectionController.add(status);
  }

  Future<void> _sendFrame(GeneratedMessage message) async {
    if (_socket == null) {
      throw StateError('Socket is not connected');
    }
    final payload = message.writeToBuffer();
    final buffer = Uint8List(payload.length + 4);
    final byteData = ByteData.view(buffer.buffer);
    byteData.setUint32(0, payload.length, Endian.big);
    buffer.setRange(4, buffer.length, payload);
    _socket!.add(buffer);
    await _socket!.flush();
  }

  // 旧接口兼容占位：当前协议不再支持 type-based 的原始发送
  void sendRaw(int messageType, Uint8List data, int messageId) {
    LogUtil.warning(
      'StreamClient',
      'sendRaw 已弃用，忽略消息 type=$messageType id=$messageId',
    );
  }

  // 旧接口兼容占位
  void send(GeneratedMessage message) {
    LogUtil.warning('StreamClient', 'send 已弃用，请使用 sendClientMessage');
  }

  Future<void> autoConnect() async {
    LogUtil.warning('StreamClient', 'autoConnect 在新协议中未实现');
  }
}

final streamClientProvider = Provider<StreamClient>((ref) {
  final client = StreamClient();
  ref.onDispose(client.dispose);
  return client;
});
