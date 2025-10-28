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

class SocketConnectionException implements Exception {
  SocketConnectionException(this.message, [this.inner]);

  final String message;
  final Object? inner;

  @override
  String toString() => inner == null ? message : '$message: $inner';
}

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

  Stream<socketpb.ServerMsg> get messages => _incomingController.stream;

  bool get isConnected => _socket != null;

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

  Future<void> disconnect() async {
    _autoReconnectEnabled = false;
    _connectionOptions = null;
    _reconnectAttempt = 0;
    _cancelReconnectTimer();
    _lastAckId = null;
    await _cleanupSocket();
  }

  Future<void> dispose() async {
    await disconnect();
    await _incomingController.close();
  }

  Future<void> _cleanupSocket() async {
    _stopHeartbeat();
    _reader.reset();
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close();
    _socket = null;
  }

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

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Uri _parseAddress(String address) {
    if (address.contains('://')) {
      return Uri.parse(address);
    }
    return Uri.parse('tcp://$address');
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _queueHeartbeat(),
    );
    _queueHeartbeat();
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _queueHeartbeat() {
    unawaited(_sendHeartbeat());
  }

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

  Future<void> sendClientMessage(socketpb.ClientMsg message) async {
    await _sendMessage(message);
  }

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

class _FrameReader {
  _FrameReader({required this.onFrame});

  final void Function(Uint8List frame) onFrame;
  Uint8List _buffer = Uint8List(0);

  void reset() {
    _buffer = Uint8List(0);
  }

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
