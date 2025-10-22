import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:im_client/gen/api/socket.pb.dart' as socketpb;
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

  int? _lastAckId;

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
    await disconnect();

    final uri = _parseAddress(address);
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

      _lastAckId = resumeAckId;
      final auth = socketpb.AuthMsg()
        ..userId = Int64(userId)
        ..deviceType =
            socketpb.DeviceType.valueOf(deviceType) ??
            socketpb.DeviceType.UNKNOWN
        ..deviceId = deviceId
        ..token = token
        ..tsMs = Int64(DateTime.now().millisecondsSinceEpoch)
        ..resume = (_lastAckId ?? 0) > 0
        ..lastAckId = Int64(_lastAckId ?? 0)
        ..supportsEncryption = false;

      await _sendMessage(auth);
      _logger.i(
        'socket handshake sent userId=$userId device=$deviceType resume=${auth.resume}',
      );
    } on SocketException catch (err) {
      await disconnect();
      throw SocketConnectionException('connect socket failed', err);
    }
  }

  Future<void> disconnect() async {
    _reader.reset();
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close();
    _socket = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _incomingController.close();
  }

  Uri _parseAddress(String address) {
    if (address.contains('://')) {
      return Uri.parse(address);
    }
    return Uri.parse('tcp://$address');
  }

  Future<void> _sendMessage(pb.GeneratedMessage message) async {
    final socket = _socket;
    if (socket == null) {
      throw SocketConnectionException('socket closed');
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
    await disconnect();
  }
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
