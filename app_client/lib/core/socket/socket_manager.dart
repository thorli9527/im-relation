/// TCP socket 管理器，负责与 app_socket 建立连接、维持心跳并落地消息。
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:im_client/gen/api/socket.pb.dart' as socketpb;
import 'package:im_client/gen/api/message.pb.dart' as msgpb;
import 'package:im_client/gen/api/msg_friend.pb.dart' as friendpb;
import 'package:protobuf/protobuf.dart' as pb;
import 'package:logger/logger.dart';

/// 包装 socket 连接阶段的异常，保留原始错误方便日志排查。
class SocketConnectionException implements Exception {
  SocketConnectionException(this.message, [this.inner]);

  final String message;
  final Object? inner;

  @override
  String toString() => inner == null ? message : '$message: $inner';
}

/// 负责建立 TCP 连接、自动重连、心跳保活以及消息编解码的核心类。
class SocketManager {
  SocketManager({required Logger logger}) : _logger = logger {
    _reader = _FrameReader(onFrame: _handleFrame);
  }

  final Logger _logger;

  Socket? _socket;
  StreamSubscription<List<int>>? _subscription;
  late final _FrameReader _reader;
  final StreamController<socketpb.ServerMsg> _incomingController =
      StreamController<socketpb.ServerMsg>.broadcast();
  Timer? _heartbeatTimer;
  int? _lastAckId;

  _ConnectionOptions? _connectionOptions;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _autoReconnectEnabled = false;

  /// 广播通道，暴露原始的服务端消息给上层仓库。
  Stream<socketpb.ServerMsg> get messages => _incomingController.stream;

  /// 当前是否持有活跃的 socket 连接。
  bool get isConnected => _socket != null;

  /// 主动建立连接，同时启用自动重连与心跳机制。
  Future<void> connect({
    required String address,
    required int userId,
    required int deviceType,
    required String deviceId,
    required String token,
    int? resumeAckId,
  }) async {
    if (address.isEmpty) {
      _logger.w('socket address is empty, skip connecting');
      return;
    }

    final options = _ConnectionOptions(
      address: address,
      userId: userId,
      deviceType: deviceType,
      deviceId: deviceId,
      token: token,
    );

    _connectionOptions = options;
    _autoReconnectEnabled = true;
    _reconnectAttempt = 0;
    _cancelReconnectTimer();

    if (resumeAckId != null) {
      _lastAckId = resumeAckId;
    }

    await _cleanupSocket();
    try {
      await _establishConnection(options, resumeAckId ?? _lastAckId);
    } on SocketConnectionException catch (err) {
      _logger.w(
        'socket initial connect failed: ${err.message}',
        error: err.inner ?? err,
      );
      _scheduleReconnect();
      rethrow;
    }
  }

  /// 主动断开连接并关闭自动重连，用于用户退出或应用销毁。
  Future<void> disconnect() async {
    _autoReconnectEnabled = false;
    _connectionOptions = null;
    _reconnectAttempt = 0;
    _cancelReconnectTimer();
    _lastAckId = null;
    await _cleanupSocket();
  }

  /// 释放全部资源，包含 StreamController 及底层连接。
  Future<void> dispose() async {
    await disconnect();
    await _incomingController.close();
  }

  /// 清理与 socket 相关的状态与监听，确保下次重连前处于全新状态。
  Future<void> _cleanupSocket() async {
    _stopHeartbeat();
    _reader.reset();
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close();
    _socket = null;
  }

  /// 建立真实的 TCP 连接，并发送握手报文（AuthMsg）。
  Future<void> _establishConnection(
    _ConnectionOptions options,
    int? resumeAckId,
  ) async {
    final uri = _parseAddress(options.address);
    _logger.i('connecting to socket ${uri.host}:${uri.port}');

    try {
      final socket = await Socket.connect(uri.host, uri.port);
      socket.setOption(SocketOption.tcpNoDelay, true);
      _socket = socket;
      _subscription = socket.listen(
        _reader.add,
        onDone: () => _handleSocketClosed(null),
        onError: (Object err, StackTrace st) => _handleSocketClosed(err),
        cancelOnError: true,
      );

      final ackId = resumeAckId ?? 0;
      final auth = socketpb.AuthMsg()
        ..userId = Int64(options.userId)
        ..deviceType =
            socketpb.DeviceType.valueOf(options.deviceType) ??
            socketpb.DeviceType.UNKNOWN
        ..deviceId = options.deviceId
        ..token = options.token
        ..tsMs = Int64(DateTime.now().millisecondsSinceEpoch)
        ..resume = ackId > 0
        ..lastAckId = Int64(ackId)
        ..supportsEncryption = false;

      await _sendMessage(auth);
      _logger.i(
        'socket handshake sent userId=${options.userId} device=${options.deviceType} resume=${auth.resume}',
      );

      _startHeartbeat();
      if (ackId > 0) {
        _lastAckId = ackId;
      }
      _reconnectAttempt = 0;
    } on SocketConnectionException {
      await _cleanupSocket();
      rethrow;
    } on SocketException catch (err) {
      await _cleanupSocket();
      throw SocketConnectionException('connect socket failed', err);
    } catch (err) {
      await _cleanupSocket();
      throw SocketConnectionException('connect socket failed', err);
    }
  }

  /// 根据指数退避窗口安排下一次重连，确保不会重复排队。
  void _scheduleReconnect() {
    if (!_autoReconnectEnabled || _connectionOptions == null) {
      return;
    }
    if (_reconnectTimer != null) {
      return;
    }
    const delays = [1, 2, 5, 10, 30];
    final maxIndex = delays.length - 1;
    final index = _reconnectAttempt > maxIndex ? maxIndex : _reconnectAttempt;
    final delaySeconds = delays[index];
    _logger.i('socket reconnect scheduled in ${delaySeconds}s');
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _reconnectTimer = null;
      unawaited(_attemptReconnect());
    });
    if (_reconnectAttempt < maxIndex) {
      _reconnectAttempt += 1;
    }
  }

  /// 执行重连逻辑，失败时继续排队直到成功或被显式停止。
  Future<void> _attemptReconnect() async {
    final options = _connectionOptions;
    if (!_autoReconnectEnabled || options == null) {
      return;
    }
    try {
      await _establishConnection(options, _lastAckId);
      _logger.i('socket reconnected successfully');
    } on SocketConnectionException catch (err, st) {
      _logger.w(
        'socket reconnect failed: ${err.message}',
        error: err.inner ?? err,
        stackTrace: st,
      );
      _scheduleReconnect();
    } catch (err, st) {
      _logger.e(
        'socket reconnect unexpected error: $err',
        error: err,
        stackTrace: st,
      );
      _scheduleReconnect();
    }
  }

  /// 取消正在等待的重连任务。
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// 支持 `tcp://` 与裸地址两种写法，统一转换为 `Uri`。
  Uri _parseAddress(String address) {
    if (address.contains('://')) {
      return Uri.parse(address);
    }
    return Uri.parse('tcp://$address');
  }

  /// 定期发送心跳以保持长连接，首次建立时立即发送一次。
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _queueHeartbeat(),
    );
    _queueHeartbeat();
  }

  /// 停止心跳定时器，通常在断开连接或清理时调用。
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 安排一次异步心跳发送，避免阻塞当前调用栈。
  void _queueHeartbeat() {
    unawaited(_sendHeartbeat());
  }

  /// 向服务器发送心跳包，若连接已断开则静默跳过。
  Future<void> _sendHeartbeat() async {
    if (_socket == null) {
      return;
    }
    final heartbeat = socketpb.ClientMsg()
      ..kind = socketpb.MsgKind.MK_HEARTBEAT
      ..clientId = Int64(DateTime.now().millisecondsSinceEpoch)
      ..payload = Uint8List(0);
    try {
      await _sendMessage(heartbeat);
    } catch (err, st) {
      _logger.w('failed to send heartbeat: $err', error: err, stackTrace: st);
    }
  }

  /// 将 protobuf 消息编码为带长度前缀的帧并写入 socket。
  Future<void> _sendMessage(pb.GeneratedMessage message) async {
    final socket = _socket;
    if (socket == null) {
      throw SocketConnectionException('socket closed');
    }
    if (message is socketpb.ClientMsg) {
      final payloadSize = message.hasPayload() ? message.payload.length : 0;
      if (message.kind != socketpb.MsgKind.MK_HEARTBEAT) {
        _logger.i(
          'socket -> client kind=${message.kind.name} payload=$payloadSize bytes',
        );
        _logDecodedClientPayload(message);
      }
    } else if (message is socketpb.AuthMsg) {
      _logger.i(
        'socket -> auth userId=${message.userId.toInt()} resume=${message.resume}',
      );
    } else {
      _logger.i('socket -> ${message.runtimeType}');
    }
    final payload = message.writeToBuffer();
    final frame = Uint8List(4 + payload.length);
    final byteData = ByteData.view(frame.buffer);
    byteData.setUint32(0, payload.length, Endian.big);
    frame.setAll(4, payload);
    socket.add(frame);
    await socket.flush();
  }

  /// 公开的发送接口，供业务层写出任意客户端消息。
  Future<void> sendClientMessage(socketpb.ClientMsg message) async {
    await _sendMessage(message);
  }

  /// 处理服务端推送的完整帧，解析后写入消息流并自动回复 ACK。
  void _handleFrame(Uint8List frame) {
    try {
      final msg = socketpb.ServerMsg.fromBuffer(frame);
      _lastAckId = msg.id.toInt();
      _logger.i(
        'socket <- server id=${msg.id} kind=${msg.kind.name} payload=${msg.payload.length} bytes',
      );
      _logDecodedServerPayload(msg);
      _incomingController.add(msg);
      _sendAck(msg.id.toInt());
    } catch (err, st) {
      _logger.e('failed to decode server frame', error: err, stackTrace: st);
    }
  }

  /// 将 ACK 写回服务端，告知已处理的消息编号。
  Future<void> _sendAck(int id) async {
    if (id <= 0) {
      return;
    }
    final ack = socketpb.ClientMsg()
      ..ack = Int64(id)
      ..kind = socketpb.MsgKind.MK_ACK
      ..payload = Uint8List(0);
    try {
      _logger.d('socket -> ack id=$id');
      await _sendMessage(ack);
    } catch (err, st) {
      _logger.w('failed to send ack: $err', error: err, stackTrace: st);
    }
  }

  /// 统一处理 socket 断开场景，确保清理并尝试重连。
  Future<void> _handleSocketClosed(Object? error) async {
    if (error != null) {
      _logger.w('socket closed with error: $error');
      _incomingController.addError(error);
    } else {
      _logger.i('socket closed');
    }
    await _cleanupSocket();
    _scheduleReconnect();
  }

  /// 为调试目的解码服务器负载，失败时仍保持主流程继续。
  void _logDecodedServerPayload(socketpb.ServerMsg msg) {
    try {
      switch (msg.kind) {
        case socketpb.MsgKind.MK_FRIEND:
        case socketpb.MsgKind.MK_GROUP:
          final content = msgpb.Content.fromBuffer(msg.payload);
          _logger.d(
            'decoded server message: ${jsonEncode(content.toProto3Json())}',
          );
          break;
        case socketpb.MsgKind.MK_FRIEND_REQUEST:
          final request = friendpb.FriendRequest.fromBuffer(msg.payload);
          _logger.d(
            'decoded server friend request: ${jsonEncode(request.toProto3Json())}',
          );
          break;
        case socketpb.MsgKind.MK_HEARTBEAT:
          _logger.d('decoded server heartbeat');
          break;
        default:
          _logger.d(
            'decoded server payload (${msg.kind.name}) length=${msg.payload.length} bytes',
          );
          break;
      }
    } catch (err, st) {
      _logger.w(
        'failed to decode server payload for logging: $err',
        error: err,
        stackTrace: st,
      );
    }
  }

  /// 为调试目的解码客户端负载，便于观察发送内容。
  void _logDecodedClientPayload(socketpb.ClientMsg msg) {
    try {
      switch (msg.kind) {
        case socketpb.MsgKind.MK_FRIEND:
        case socketpb.MsgKind.MK_GROUP:
          if (!msg.hasPayload()) {
            _logger.d(
              'decoded client message (${msg.kind.name}) empty payload',
            );
            break;
          }
          final content = msgpb.Content.fromBuffer(msg.payload);
          _logger.d(
            'decoded client message: ${jsonEncode(content.toProto3Json())}',
          );
          break;
        case socketpb.MsgKind.MK_FRIEND_REQUEST:
          if (!msg.hasPayload()) {
            _logger.d('decoded client friend request missing payload');
            break;
          }
          final request = friendpb.FriendRequest.fromBuffer(msg.payload);
          _logger.d(
            'decoded client friend request: ${jsonEncode(request.toProto3Json())}',
          );
          break;
        case socketpb.MsgKind.MK_HEARTBEAT:
          _logger.d('decoded client heartbeat');
          break;
        default:
          if (!msg.hasPayload()) {
            _logger.d('decoded client payload (${msg.kind.name}) empty');
            break;
          }
          _logger.d(
            'decoded client payload (${msg.kind.name}) length=${msg.payload.length} bytes',
          );
          break;
      }
    } catch (err, st) {
      _logger.w(
        'failed to decode client payload for logging: $err',
        error: err,
        stackTrace: st,
      );
    }
  }
}

/// 记录一次连接所需的所有参数，方便重连时复用。
class _ConnectionOptions {
  const _ConnectionOptions({
    required this.address,
    required this.userId,
    required this.deviceType,
    required this.deviceId,
    required this.token,
  });

  final String address;
  final int userId;
  final int deviceType;
  final String deviceId;
  final String token;
}

/// 将 TCP 字节流重组为长度前缀帧的工具。
class _FrameReader {
  _FrameReader({required this.onFrame});

  final void Function(Uint8List frame) onFrame;
  Uint8List _buffer = Uint8List(0);

  /// 丢弃缓存数据，重新从空白状态开始接收。
  void reset() {
    _buffer = Uint8List(0);
  }

  /// 接收 socket 读取的原始字节并尝试拼接成完整帧。
  void add(List<int> chunk) {
    if (chunk.isEmpty) {
      return;
    }
    if (_buffer.isEmpty) {
      _buffer = Uint8List.fromList(chunk);
    } else {
      final merged = Uint8List(_buffer.length + chunk.length);
      merged.setAll(0, _buffer);
      merged.setAll(_buffer.length, chunk);
      _buffer = merged;
    }
    _process();
  }

  /// 解析内部缓冲，多次提取完整帧并回调 `onFrame`。
  void _process() {
    var offset = 0;
    while (_buffer.length - offset >= 4) {
      final len = ByteData.sublistView(
        _buffer,
        offset,
        offset + 4,
      ).getUint32(0, Endian.big);
      if (_buffer.length - offset - 4 < len) {
        break;
      }
      final slice = Uint8List(len);
      slice.setAll(0, _buffer.sublist(offset + 4, offset + 4 + len));
      onFrame(slice);
      offset += 4 + len;
    }
    if (offset == 0) {
      return;
    }
    if (offset >= _buffer.length) {
      _buffer = Uint8List(0);
    } else {
      _buffer = Uint8List.fromList(_buffer.sublist(offset));
    }
  }
}
