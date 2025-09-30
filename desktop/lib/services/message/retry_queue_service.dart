// 文件路径: lib/services/message/retry_queue_service.dart

import 'dart:async';
import 'package:riverpod/riverpod.dart';
import 'package:isar/isar.dart';
import 'package:im_client/models/message/ack_message.dart';
import 'package:im_client/utils/log_util.dart';
import 'package:im_client/channel/stream_client.dart';
import 'package:im_client/services/database_service.dart';

class RetryQueueService {
  final Ref _ref;
  final Isar _isar;
  Timer? _retryTimer;
  StreamSubscription<ConnectionStatus>? _connectionSubscription;
  bool _isConnected = false;

  RetryQueueService(this._ref, this._isar) {
    _init();
  }

  void _init() {
    // 监听网络连接状态
    final streamClient = _ref.read(streamClientProvider);
    _connectionSubscription = streamClient.connectionStream.listen(_onConnectionStatusChanged);

    // 启动重试定时器
    _startRetryTimer();
  }

  /// 处理连接状态变化
  void _onConnectionStatusChanged(ConnectionStatus status) {
    _isConnected = status == ConnectionStatus.connected;

    if (_isConnected) {
      LogUtil.info('RetryQueueService', '🌐 网络已连接，开始处理离线消息队列');
      // 网络恢复时，处理离线消息
      _processOfflineMessages();
    } else {
      LogUtil.info('RetryQueueService', '🚫 网络断开连接');
    }
  }

  /// 添加消息到重试队列
  Future<void> addMessage(AckMessage message) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.ackMessages.put(message);
      });
      LogUtil.info('RetryQueueService', '📥 消息已添加到重试队列: ${message.messageId}');
    } catch (e) {
      LogUtil.error('RetryQueueService', '❌ 添加消息到重试队列失败', e);
    }
  }

  /// 标记消息为已确认
  Future<void> markAsAcknowledged(int messageId) async {
    try {
      final message = await _isar.ackMessages.filter().messageIdEqualTo(messageId).findFirst();
      if (message != null) {
        final updatedMessage = message.copyWith(
          status: AckStatus.acknowledged,
          ackTimestamp: DateTime.now(),
        );

        await _isar.writeTxn(() async {
          await _isar.ackMessages.put(updatedMessage);
        });

        LogUtil.info('RetryQueueService', '✅ 消息已确认: $messageId');
      }
    } catch (e) {
      LogUtil.error('RetryQueueService', '❌ 标记消息为已确认失败', e);
    }
  }

  /// 标记消息为失败
  Future<void> markAsFailed(int messageId, [int? errorCode]) async {
    try {
      final message = await _isar.ackMessages.filter().messageIdEqualTo(messageId).findFirst();
      if (message != null) {
        final updatedMessage = message.copyWith(
          status: AckStatus.failed,
          errorCode: errorCode,
          ackTimestamp: DateTime.now(),
        );

        await _isar.writeTxn(() async {
          await _isar.ackMessages.put(updatedMessage);
        });

        LogUtil.info('RetryQueueService', '❌ 消息失败: $messageId, 错误: $errorCode');
      }
    } catch (e) {
      LogUtil.error('RetryQueueService', '❌ 标记消息为失败失败', e);
    }
  }

  /// 启动重试定时器
  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _processRetryQueue();
    });
  }

  /// 处理重试队列
  Future<void> _processRetryQueue() async {
    if (!_isConnected) return;

    try {
      // 获取所有待发送或超时的消息
      final pendingMessages = await _isar.ackMessages
          .filter()
          .statusEqualTo(AckStatus.sent)
          .or()
          .statusEqualTo(AckStatus.timeout)
          .or()
          .statusEqualTo(AckStatus.pending)
          .findAll();

      for (final message in pendingMessages) {
        await _processMessage(message);
      }
    } catch (e) {
      LogUtil.error('RetryQueueService', '❌ 处理重试队列时出错', e);
    }
  }

  /// 处理单个消息
  Future<void> _processMessage(AckMessage message) async {
    try {
      // 检查是否需要重试
      if (message.status == AckStatus.sent || message.status == AckStatus.timeout) {
        final now = DateTime.now();
        final lastSendTime = message.lastSendTime ?? message.timestamp;
        final elapsed = now.difference(lastSendTime).inMilliseconds;
        final timeout = message.getNextRetryDelay();

        // 如果还没到重试时间，跳过
        if (elapsed < timeout) {
          return;
        }

        // 检查是否还能重试
        if (!message.canRetry()) {
          await markAsFailed(message.messageId, AckMessage.ERROR_CODE_RETRY_EXHAUSTED);
          return;
        }

        // 增加重试次数
        final updatedMessage = message.copyWith(
          retryCount: message.retryCount + 1,
          status: AckStatus.sent,
          lastSendTime: DateTime.now(),
        );

        await _isar.writeTxn(() async {
          await _isar.ackMessages.put(updatedMessage);
        });

        // 发送消息
        await _sendMessage(updatedMessage);
      } else if (message.status == AckStatus.pending) {
        // 首次发送消息
        final updatedMessage = message.copyWith(
          status: AckStatus.sent,
          lastSendTime: DateTime.now(),
        );

        await _isar.writeTxn(() async {
          await _isar.ackMessages.put(updatedMessage);
        });

        // 发送消息
        await _sendMessage(updatedMessage);
      }
    } catch (e) {
      LogUtil.error('RetryQueueService', '❌ 处理消息时出错: ${message.messageId}', e);
    }
  }

  /// 发送消息
  Future<void> _sendMessage(AckMessage message) async {
    try {
      final streamClient = _ref.read(streamClientProvider);

      // 根据消息类型创建对应的消息对象
      // 这里需要根据具体的protobuf消息类型来实现
      // 为简化示例，我们假设有一个通用的发送方法
      streamClient.sendRaw(message.messageType,message.originalData,message.messageId);

      LogUtil.info('RetryQueueService', '📤 发送消息: ${message.messageId}, 类型: ${message.messageType}');
    } catch (e) {
      LogUtil.error('RetryQueueService', '❌ 发送消息失败: ${message.messageId}', e);
      // 标记为超时，等待下次重试
      final updatedMessage = message.copyWith(status: AckStatus.timeout);
      await _isar.writeTxn(() async {
        await _isar.ackMessages.put(updatedMessage);
      });
    }
  }

  /// 处理离线消息
  Future<void> _processOfflineMessages() async {
    try {
      // 获取所有离线状态的消息
      final offlineMessages = await _isar.ackMessages
          .filter()
          .statusEqualTo(AckStatus.offline)
          .findAll();

      for (final message in offlineMessages) {
        final updatedMessage = message.copyWith(status: AckStatus.pending);
        await _isar.writeTxn(() async {
          await _isar.ackMessages.put(updatedMessage);
        });
        LogUtil.info('RetryQueueService', '🔄 离线消息转为待发送: ${message.messageId}');
      }
    } catch (e) {
      LogUtil.error('RetryQueueService', '❌ 处理离线消息时出错', e);
    }
  }

  /// 清理已完成的消息（可选）
  Future<void> cleanupCompletedMessages([Duration olderThan = const Duration(hours: 24)]) async {
    try {
      final cutoffTime = DateTime.now().subtract(olderThan);

      // 删除已确认或失败的消息
      final completedIds = await _isar.ackMessages
          .filter()
          .statusEqualTo(AckStatus.acknowledged)
          .or()
          .statusEqualTo(AckStatus.failed)
          .and()
          .timestampLessThan(cutoffTime)
          .idProperty()
          .findAll();

      if (completedIds.isNotEmpty) {
        await _isar.writeTxn(() async {
          await _isar.ackMessages.deleteAll(completedIds);
        });
        LogUtil.info('RetryQueueService', '🧹 清理完成消息: ${completedIds.length} 条');
      }
    } catch (e) {
      LogUtil.error('RetryQueueService', '❌ 清理完成消息时出错', e);
    }
  }

  void dispose() {
    _retryTimer?.cancel();
    _connectionSubscription?.cancel();
  }
}

// Riverpod Provider
final retryQueueServiceProvider = Provider<RetryQueueService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final service = RetryQueueService(ref, databaseService.db);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
