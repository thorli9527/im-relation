import 'package:isar/isar.dart';

import 'message_status.dart';

part 'voice_message_entity.g.dart';

/// 语音消息本地缓存。
///
/// 用于记录好友与群聊场景下语音消息的元数据，以及本地缓存状态，
/// 便于区分已发送/接收的语音消息和管理下载、播放等流程。
@collection
class VoiceMessageEntity {
  VoiceMessageEntity();

  Id id = Isar.autoIncrement;

  /// 当前登录用户（库持有者）的 ID。
  @Index()
  late int ownerId;

  /// 对话对象的 ID：好友 ID 或群组 ID。
  @Index()
  late int conversationId;

  /// 是否群聊消息，false 表示好友单聊。
  @Index()
  late bool isGroup;

  /// 消息 ID，与服务端保持一致。
  @Index(unique: true)
  late int messageId;

  /// 发送者用户 ID。
  @Index()
  late int senderId;

  /// 接收者用户 ID（群聊时为空）。
  int? receiverId;

  /// 消息时间戳（毫秒）。
  @Index()
  late int timestamp;

  /// 是否由当前用户发出。
  late bool isOutgoing;

  /// 语音远端访问地址。
  String? remoteUrl;

  /// 本地缓存文件路径。
  String? localPath;

  /// 播放时长（秒）。
  int? durationSeconds;

  /// 文件格式（如 mp3/wav）。
  String? format;

  /// 文件大小（字节）。
  int? fileSize;

  /// 上传/下载状态。
  int deliveryStatus = MessageDeliveryStatus.pending.index;

  /// 是否已被播放。
  bool isListened = false;
}

extension VoiceMessageDeliveryStatusX on VoiceMessageEntity {
  MessageDeliveryStatus get status =>
      MessageDeliveryStatus.values[deliveryStatus];

  set status(MessageDeliveryStatus value) {
    deliveryStatus = value.index;
  }

  /// 是否已经缓存到本地。
  @ignore
  bool get hasLocalFile => localPath?.isNotEmpty == true;
}
