// 文件路径: lib/models/message/ack_message.dart

import 'dart:typed_data';
import 'package:isar/isar.dart';
part 'ack_message.g.dart';
enum AckStatus {
  pending,      // 待发送
  sent,         // 已发送，等待ACK
  acknowledged, // 已确认
  failed,       // 发送失败
  timeout,      // 超时
  offline       // 离线状态
}

@collection
class AckMessage {
  static const int ERROR_CODE_RETRY_EXHAUSTED = 1001; // 重试次数用完错误码
  static const int ERROR_CODE_TIMEOUT = 1000;         // 超时错误码
  static const int ERROR_CODE_UNKNOWN = 9999;         // 未知错误码
  Id id = Isar.autoIncrement;

  /// 使用雪花ID作为消息ID
  late int messageId;

  /// 消息类型 (存储为 int 值以兼容 Isar)
  late int messageType;

  /// 原始消息数据
  @ignore
  late Uint8List originalData;

  /// 重试次数
  late int retryCount;

  /// 最大重试次数
  late int maxRetries;

  /// 当前状态
  @Enumerated(EnumType.name)
  late AckStatus status;

  /// 创建时间
  late DateTime  timestamp;

  /// 最后发送时间
  DateTime? lastSendTime;

  /// 确认时间
  DateTime? ackTimestamp;

  /// 错误编码
  int? errorCode;

  /// 重试间隔（毫秒）- 直接存储固定值1000毫秒
  int retryInterval = 1000;

  AckMessage({
    required this.messageId,
    required this.messageType,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.status = AckStatus.pending,
    this.lastSendTime,
    this.ackTimestamp,
    this.errorCode,
    int retryInterval = 1000,
  }) :
      timestamp =  DateTime.now(),
      retryInterval = retryInterval;

  /// 便捷构造函数：使用 int 类型的消息类型
  AckMessage.withType({
    required this.messageId,
    required int messageType,
    required Uint8List originalData,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.status = AckStatus.pending,
    DateTime? timestamp,
    this.lastSendTime,
    this.ackTimestamp,
    this.errorCode,
    int retryInterval = 1000,
  }) :
      timestamp = timestamp ?? DateTime.now(),
      originalData = originalData,
      messageType = messageType,
      retryInterval = retryInterval;

  AckMessage copyWith({
    int? messageId,
    int? messageType,
    Uint8List? originalData,
    int? retryCount,
    int? maxRetries,
    AckStatus? status,
    DateTime? timestamp,
    DateTime? lastSendTime,
    DateTime? ackTimestamp,
    int? errorCode,
    int? retryInterval,
  }) {
    return AckMessage.withType(
      messageId: messageId ?? this.messageId,
      messageType: messageType ?? this.messageType,
      originalData: originalData ?? this.originalData,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      lastSendTime: lastSendTime ?? this.lastSendTime,
      ackTimestamp: ackTimestamp ?? this.ackTimestamp,
      errorCode: errorCode ?? this.errorCode,
      retryInterval: retryInterval ?? this.retryInterval,
    );
  }

  /// 获取下次重试的延迟时间（固定为1000毫秒）
  int getNextRetryDelay() {
    return retryInterval;
  }

  /// 是否可以重试
  bool canRetry() {
    return retryCount < maxRetries && status != AckStatus.acknowledged;
  }

  /// 增加重试次数
  void incrementRetry() {
    retryCount++;
  }

  @override
  String toString() {
    return 'AckMessage{messageId: $messageId, messageType: $messageType, status: $status, retryCount: $retryCount}';
  }
}
