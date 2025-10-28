import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:im_client/core/session/session_event.dart';
import 'package:im_client/core/socket/socket_manager.dart';
import 'package:im_client/core/storage/local_store.dart';
import 'package:im_client/core/storage/messages/friend_biz_entity.dart';
import 'package:im_client/core/storage/messages/friend_message_entity.dart';
import 'package:im_client/core/storage/messages/group_biz_entity.dart';
import 'package:im_client/core/storage/messages/group_message_entity.dart';
import 'package:im_client/core/storage/messages/message_status.dart';
import 'package:im_client/core/storage/messages/outbox_message_entity.dart';
import 'package:im_client/core/storage/messages/system_message_entity.dart';
import 'package:im_client/core/storage/messages/voice_message_entity.dart';
import 'package:im_client/gen/api/message.pb.dart' as msgpb;
import 'package:im_client/gen/api/msg_friend.pb.dart' as friendpb;
import 'package:im_client/gen/api/msg_group.pb.dart' as grouppb;
import 'package:im_client/gen/api/socket.pb.dart' as socketpb;
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

class MessageRepository {
  MessageRepository({
    required LocalStore store,
    required SocketManager socketManager,
    required Logger logger,
    required SessionEventNotifier sessionEvents,
  }) : _store = store,
       _socketManager = socketManager,
       _logger = logger,
       _sessionEvents = sessionEvents;

  final LocalStore _store;
  final SocketManager _socketManager;
  final Logger _logger;
  final SessionEventNotifier _sessionEvents;

  Isar get _isar => _store.isar;

  void dispose() {}

  Future<void> handleIncomingMessage(
    socketpb.ServerMsg message, {
    required int ownerId,
  }) async {
    final kind = message.kind;
    try {
      switch (kind) {
        case socketpb.MsgKind.MK_FRIEND:
          await _handleFriendChat(message, ownerId: ownerId);
          break;
        case socketpb.MsgKind.MK_GROUP:
          await _handleGroupChat(message, ownerId: ownerId);
          break;
        case socketpb.MsgKind.MK_ACK:
          await _handleAck(message, ownerId: ownerId);
          break;
        default:
          if (_isFriendBiz(kind)) {
            await _handleFriendBiz(message, ownerId: ownerId);
          } else if (_isGroupBiz(kind)) {
            await _handleGroupBiz(message, ownerId: ownerId);
          } else if (_isSystemKind(kind)) {
            await _handleSystemMsg(message, ownerId: ownerId);
          } else {
            _logger.w('Unhandled message kind: ${kind.name}');
          }
      }
    } catch (err, st) {
      _logger.e(
        'Failed to persist message ${kind.name}',
        error: err,
        stackTrace: st,
      );
    }
  }

  Stream<List<FriendMessageEntity>> watchFriendMessages({
    required int ownerId,
    int? friendId,
  }) async* {
    yield await _fetchFriendMessages(ownerId: ownerId, friendId: friendId);
    await for (final _ in _isar.friendMessageEntitys.watchLazy()) {
      yield await _fetchFriendMessages(ownerId: ownerId, friendId: friendId);
    }
  }

  Stream<List<GroupMessageEntity>> watchGroupMessages({
    required int ownerId,
    required int groupId,
  }) async* {
    yield await _fetchGroupMessages(ownerId: ownerId, groupId: groupId);
    await for (final _ in _isar.groupMessageEntitys.watchLazy()) {
      yield await _fetchGroupMessages(ownerId: ownerId, groupId: groupId);
    }
  }

  Stream<List<VoiceMessageEntity>> watchVoiceMessages({
    required int ownerId,
  }) async* {
    yield await _fetchVoiceMessages(ownerId: ownerId);
    await for (final _ in _isar.voiceMessageEntitys.watchLazy()) {
      yield await _fetchVoiceMessages(ownerId: ownerId);
    }
  }

  Future<void> queueFriendText(
    String text, {
    required int ownerId,
    required int friendId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final messageId = now;
    final content = msgpb.Content()
      ..messageId = Int64(messageId)
      ..senderId = Int64(ownerId)
      ..receiverId = Int64(friendId)
      ..timestamp = Int64(now)
      ..msgKind = socketpb.MsgKind.MK_FRIEND
      ..scene = msgpb.ChatScene.SINGLE
      ..contents.add(
        msgpb.MessageContent()..text = (msgpb.TextContent()..text = text),
      );

    final payload = content.writeToBuffer();

    final friendMessage = FriendMessageEntity()
      ..ownerId = ownerId
      ..friendId = friendId
      ..messageId = messageId
      ..senderId = ownerId
      ..receiverId = friendId
      ..timestamp = now
      ..kind = socketpb.MsgKind.MK_FRIEND.value
      ..isOutgoing = true
      ..status = MessageDeliveryStatus.pending
      ..textPreview = text
      ..payload = List<int>.from(payload);

    final outbox = OutboxMessageEntity()
      ..ownerId = ownerId
      ..targetId = friendId
      ..isGroup = false
      ..kind = socketpb.MsgKind.MK_FRIEND.value
      ..createdAt = now
      ..deliveryStatus = MessageDeliveryStatus.pending
      ..payloadType = msgpb.Content().info_.qualifiedMessageName
      ..messageId = messageId
      ..payload = List<int>.from(payload);

    await _isar.writeTxn(() async {
      await _isar.friendMessageEntitys.put(friendMessage);
      await _isar.outboxMessageEntitys.put(outbox);
    });

    await _flushOutbox();
  }

  Future<void> sendFriendRequest({
    required int ownerId,
    required int targetUserId,
    required String remark,
    required String reason,
    friendpb.FriendRequestSource source =
        friendpb.FriendRequestSource.FRS_USER_ID,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final request = friendpb.FriendRequest()
      ..id = Int64(now)
      ..fromUserId = Int64(ownerId)
      ..toUserId = Int64(targetUserId)
      ..reason = reason
      ..source = source
      ..createdAt = Int64(now);
    if (remark.trim().isNotEmpty) {
      request.remark = remark.trim();
    }

    final clientMsg = socketpb.ClientMsg()
      ..kind = socketpb.MsgKind.MK_FRIEND_REQUEST
      ..clientId = Int64(now)
      ..payload = request.writeToBuffer();

    await _socketManager.sendClientMessage(clientMsg);
  }

  Future<void> _handleFriendChat(
    socketpb.ServerMsg msg, {
    required int ownerId,
  }) async {
    final content = msgpb.Content.fromBuffer(msg.payload);
    final friendId = content.senderId.toInt() == ownerId
        ? content.receiverId.toInt()
        : content.senderId.toInt();
    final entity = FriendMessageEntity()
      ..ownerId = ownerId
      ..friendId = friendId
      ..messageId = content.messageId.toInt()
      ..senderId = content.senderId.toInt()
      ..receiverId = content.receiverId.toInt()
      ..timestamp = content.timestamp.toInt()
      ..kind = msg.kind.value
      ..isOutgoing = content.senderId.toInt() == ownerId
      ..textPreview = _extractText(content)
      ..payload = msg.payload.toList()
      ..status = MessageDeliveryStatus.received;

    await _isar.writeTxn(() async {
      await _isar.friendMessageEntitys.putByMessageId(entity);
    });
  }

  Future<void> _handleGroupChat(
    socketpb.ServerMsg msg, {
    required int ownerId,
  }) async {
    final content = msgpb.Content.fromBuffer(msg.payload);
    final entity = GroupMessageEntity()
      ..ownerId = ownerId
      ..groupId = content.receiverId.toInt()
      ..messageId = content.messageId.toInt()
      ..senderId = content.senderId.toInt()
      ..timestamp = content.timestamp.toInt()
      ..kind = msg.kind.value
      ..isOutgoing = content.senderId.toInt() == ownerId
      ..textPreview = _extractText(content)
      ..payload = msg.payload.toList()
      ..status = MessageDeliveryStatus.received;

    await _isar.writeTxn(() async {
      await _isar.groupMessageEntitys.putByMessageId(entity);
    });
  }

  Future<void> _handleFriendBiz(
    socketpb.ServerMsg msg, {
    required int ownerId,
  }) async {
    final kind = msg.kind;
    final payload = msg.payload.toList();
    int friendId = 0;
    switch (kind) {
      case socketpb.MsgKind.MK_FRIEND_REQUEST:
        final data = friendpb.FriendRequest.fromBuffer(payload);
        friendId = data.fromUserId.toInt() == ownerId
            ? data.toUserId.toInt()
            : data.fromUserId.toInt();
        break;
      case socketpb.MsgKind.MK_FRIEND_DELETE:
        final data = friendpb.FriendDelete.fromBuffer(payload);
        friendId = data.friendUserId.toInt();
        break;
      default:
        break;
    }

    final entity = FriendBizEntity()
      ..ownerId = ownerId
      ..friendId = friendId
      ..eventId = msg.id.toInt()
      ..kind = kind.value
      ..timestamp = msg.tsMs.toInt()
      ..payload = payload;

    await _isar.writeTxn(() async {
      await _isar.friendBizEntitys.putByEventId(entity);
    });
  }

  Future<void> _handleGroupBiz(
    socketpb.ServerMsg msg, {
    required int ownerId,
  }) async {
    final kind = msg.kind;
    final payload = msg.payload.toList();
    int groupId = 0;
    switch (kind) {
      case socketpb.MsgKind.MK_GROUP_UPDATE_NAME:
      case socketpb.MsgKind.MK_GROUP_UPDATE_AVATAR:
      case socketpb.MsgKind.MK_GROUP_UPDATE_ANNOUNCEMENT:
        final data = grouppb.UpdateGroupProfileReq.fromBuffer(payload);
        groupId = data.groupId.toInt();
        break;
      default:
        break;
    }

    final entity = GroupBizEntity()
      ..ownerId = ownerId
      ..groupId = groupId
      ..eventId = msg.id.toInt()
      ..kind = kind.value
      ..timestamp = msg.tsMs.toInt()
      ..payload = payload;

    await _isar.writeTxn(() async {
      await _isar.groupBizEntitys.putByEventId(entity);
    });
  }

  Future<void> _handleSystemMsg(
    socketpb.ServerMsg msg, {
    required int ownerId,
  }) async {
    _maybeEmitSessionEvent(msg);
    final payload = msg.payload.toList();
    String? preview;
    try {
      final content = msgpb.Content.fromBuffer(payload);
      preview = _extractText(content);
    } catch (_) {
      // 非 Content 结构，保持空摘要。
    }

    final entity = SystemMessageEntity()
      ..ownerId = ownerId
      ..messageId = msg.id.toInt()
      ..kind = msg.kind.value
      ..timestamp = msg.tsMs.toInt()
      ..textPreview = preview
      ..payload = payload;

    await _isar.writeTxn(() async {
      await _isar.systemMessageEntitys.putByMessageId(entity);
    });
  }

  void _maybeEmitSessionEvent(socketpb.ServerMsg msg) {
    if (msg.kind != socketpb.MsgKind.MK_SYS_NOTICE) {
      return;
    }
    String raw;
    try {
      raw = utf8.decode(msg.payload, allowMalformed: false);
    } catch (err) {
      _logger.d('system notice payload decode failed: $err');
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      final noticeType = decoded['notice_type']?.toString();
      if (noticeType != 'login_duplicate') {
        return;
      }
      final content = decoded['content']?.toString();
      _logger.i('session notice login_duplicate content=$content');
      _sessionEvents.emit(
        SessionEvent.kicked(noticeType: noticeType, message: content),
      );
    } catch (err, stackTrace) {
      _logger.d(
        'system notice payload parse failed',
        error: err,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _handleAck(
    socketpb.ServerMsg msg, {
    required int ownerId,
  }) async {
    final ack = msgpb.AckContent.fromBuffer(msg.payload);
    if (!ack.hasRefMessageId()) {
      return;
    }
    final refId = ack.refMessageId.toInt();
    await _isar.writeTxn(() async {
      final outbox = await _isar.outboxMessageEntitys
          .filter()
          .ownerIdEqualTo(ownerId)
          .messageIdEqualTo(refId)
          .findFirst();
      if (outbox != null) {
        outbox.deliveryStatus = MessageDeliveryStatus.sent;
        await _isar.outboxMessageEntitys.put(outbox);
      }
      final friendMsg = await _isar.friendMessageEntitys
          .filter()
          .ownerIdEqualTo(ownerId)
          .messageIdEqualTo(refId)
          .findFirst();
      if (friendMsg != null) {
        friendMsg.status = MessageDeliveryStatus.sent;
        await _isar.friendMessageEntitys.put(friendMsg);
      }
    });
  }

  Future<void> _flushOutbox() async {
    final pending = await _isar.outboxMessageEntitys
        .filter()
        .statusEqualTo(MessageDeliveryStatus.pending.index)
        .findAll();
    for (final item in pending) {
      final msgKind =
          socketpb.MsgKind.valueOf(item.kind) ?? socketpb.MsgKind.MK_UNKNOWN;
      final msg = socketpb.ClientMsg()
        ..kind = msgKind
        ..payload = Uint8List.fromList(item.payload)
        ..clientId = Int64(item.id);
      if (item.messageId != null) {
        msg.ack = Int64(item.messageId!);
      }
      try {
        await _socketManager.sendClientMessage(msg);
        await _isar.writeTxn(() async {
          item.deliveryStatus = MessageDeliveryStatus.sending;
          await _isar.outboxMessageEntitys.put(item);
          if (item.messageId != null) {
            final friendMsg = await _isar.friendMessageEntitys
                .filter()
                .ownerIdEqualTo(item.ownerId)
                .messageIdEqualTo(item.messageId!)
                .findFirst();
            if (friendMsg != null) {
              friendMsg.status = MessageDeliveryStatus.sending;
              await _isar.friendMessageEntitys.put(friendMsg);
            }
          }
        });
      } catch (err, st) {
        _logger.e('Failed to send outbox message', error: err, stackTrace: st);
        await _isar.writeTxn(() async {
          item.deliveryStatus = MessageDeliveryStatus.failed;
          await _isar.outboxMessageEntitys.put(item);
          if (item.messageId != null) {
            final friendMsg = await _isar.friendMessageEntitys
                .filter()
                .ownerIdEqualTo(item.ownerId)
                .messageIdEqualTo(item.messageId!)
                .findFirst();
            if (friendMsg != null) {
              friendMsg.status = MessageDeliveryStatus.failed;
              await _isar.friendMessageEntitys.put(friendMsg);
            }
          }
        });
      }
    }
  }

  String? _extractText(msgpb.Content content) {
    for (final body in content.contents) {
      if (body.hasText()) {
        return body.text.text;
      }
    }
    return null;
  }

  Future<List<FriendMessageEntity>> _fetchFriendMessages({
    required int ownerId,
    int? friendId,
  }) async {
    final query = _isar.friendMessageEntitys
        .filter()
        .ownerIdEqualTo(ownerId)
        .optional(friendId != null, (q) => q.friendIdEqualTo(friendId!));
    final result = await query.findAll();
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return result.take(200).toList();
  }

  Future<List<GroupMessageEntity>> _fetchGroupMessages({
    required int ownerId,
    required int groupId,
  }) async {
    final result = await _isar.groupMessageEntitys
        .filter()
        .ownerIdEqualTo(ownerId)
        .groupIdEqualTo(groupId)
        .findAll();
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return result.take(200).toList();
  }

  Future<List<VoiceMessageEntity>> _fetchVoiceMessages({
    required int ownerId,
  }) async {
    final result = await _isar.voiceMessageEntitys
        .filter()
        .ownerIdEqualTo(ownerId)
        .sortByTimestampDesc()
        .findAll();
    return result.take(200).toList();
  }

  bool _isFriendBiz(socketpb.MsgKind kind) {
    const friendBizKinds = {
      socketpb.MsgKind.MK_FRIEND_REQUEST,
      socketpb.MsgKind.MK_FRIEND_REQUEST_ACK,
      socketpb.MsgKind.MK_FRIEND_REQUEST_REJECT,
      socketpb.MsgKind.MK_FRIEND_DELETE,
      socketpb.MsgKind.MK_FRIEND_UPDATE_REMARK,
    };
    return friendBizKinds.contains(kind);
  }

  bool _isGroupBiz(socketpb.MsgKind kind) {
    const groupBizKinds = {
      socketpb.MsgKind.MK_GROUP_UPDATE_NAME,
      socketpb.MsgKind.MK_GROUP_UPDATE_AVATAR,
      socketpb.MsgKind.MK_GROUP_UPDATE_ANNOUNCEMENT,
      socketpb.MsgKind.MK_GROUP_MEMBER_ADD,
      socketpb.MsgKind.MK_GROUP_MEMBER_DELETE,
      socketpb.MsgKind.MK_GROUP_MEMBER_QUIT,
      socketpb.MsgKind.MK_GROUP_MEMBER_UPDATE,
      socketpb.MsgKind.MK_GROUP_DISMISS,
      socketpb.MsgKind.MK_GROUP_TRANSFER,
    };
    return groupBizKinds.contains(kind);
  }

  bool _isSystemKind(socketpb.MsgKind kind) {
    const systemKinds = {
      socketpb.MsgKind.MK_SYS_NOTICE,
      socketpb.MsgKind.MK_USER_PRESENCE,
      socketpb.MsgKind.MK_USER_PROFILE_UPDATE,
      socketpb.MsgKind.MK_USER_PRIVACY_UPDATE,
      socketpb.MsgKind.MK_USER_ACCOUNT_DATA,
      socketpb.MsgKind.MK_MSG_RECALL,
    };
    return systemKinds.contains(kind);
  }
}
