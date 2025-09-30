import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

/// 构造符合 Rust 后端协议格式的消息帧
///
/// 结构: [4字节 BigEndian 长度] + [1字节类型码 ByteMessageType] + [protobuf 编码内容]
///
/// - [type] 为 ByteMessageType 枚举对应的整型值（0-255）
/// - [protoBytes] 是调用 writeToBuffer() 得到的 Protobuf 编码结果
///
/// 返回: 最终封装后的 Uint8List 可发送数据帧
Uint8List encodeFramedMessage(int type, List<int> protoBytes) {
  if (type < 0 || type > 255) {
    throw ArgumentError('ByteMessageType must be in range 0–255');
  }

  // 构建消息体: [type_byte] + [protobuf payload]
  final body = Uint8List(protoBytes.length + 1);
  body[0] = type;
  body.setRange(1, body.length, protoBytes);

  // 构建长度头: 4 字节 Big Endian 表示消息体长度
  final header = ByteData(4)..setUint32(0, body.length, Endian.big);

  // 拼接最终帧: [4字节长度] + [消息体]
  return Uint8List(4 + body.length)
    ..setRange(0, 4, header.buffer.asUint8List())
    ..setRange(4, 4 + body.length, body);
}
Uint8List encodeMessage(int type,  GeneratedMessage message) {
  if (type < 0 || type > 255) {
    throw ArgumentError('ByteMessageType must be in range 0–255');
  }

  var writeToBuffer = message.writeToBuffer();
  final body = Uint8List(writeToBuffer.length + 1);
  body[0] = type;
  body.setRange(1, body.length, writeToBuffer);

  // 构建长度头: 4 字节 Big Endian 表示消息体长度
  final header = ByteData(4)..setUint32(0, body.length, Endian.big);

  // 拼接最终帧: [4字节长度] + [消息体]
  return Uint8List(4 + body.length)
    ..setRange(0, 4, header.buffer.asUint8List())
    ..setRange(4, 4 + body.length, body);
}
