import 'dart:convert';

import 'package:isar/isar.dart';

import 'package:im_client/core/storage/auth_session.dart';
import 'package:im_client/core/storage/device_profile.dart';
import 'package:im_client/core/storage/friend_entity.dart';
import 'package:im_client/core/storage/group_entity.dart';
import 'package:im_client/core/storage/messages/friend_biz_entity.dart';
import 'package:im_client/core/storage/messages/friend_message_entity.dart';
import 'package:im_client/core/storage/messages/group_biz_entity.dart';
import 'package:im_client/core/storage/messages/group_message_entity.dart';
import 'package:im_client/core/storage/messages/message_status.dart';
import 'package:im_client/core/storage/messages/outbox_message_entity.dart';
import 'package:im_client/core/storage/messages/system_message_entity.dart';
import 'package:im_client/core/storage/messages/voice_message_entity.dart';

enum DebugFieldType { string, text, int, double, boolean, dateTime, bytes }

class DebugField<T> {
  const DebugField({
    required this.name,
    required this.label,
    required this.type,
    required this.getValue,
    this.setValue,
    this.optional = false,
    this.editable = true,
  });

  final String name;
  final String label;
  final DebugFieldType type;
  final bool optional;
  final bool editable;
  final dynamic Function(T record) getValue;
  final void Function(T record, dynamic value)? setValue;
}

class DebugFieldView {
  const DebugFieldView({
    required this.name,
    required this.label,
    required this.type,
    required this.optional,
    required this.editable,
    required this.getValue,
    this.setValue,
  });

  final String name;
  final String label;
  final DebugFieldType type;
  final bool optional;
  final bool editable;
  final dynamic Function(dynamic record) getValue;
  final void Function(dynamic record, dynamic value)? setValue;
}

abstract class IsarDebugCollection {
  String get name;
  List<DebugFieldView> get fields;
  Future<List<dynamic>> fetchAll(Isar isar);
  dynamic createNew();
  Future<void> save(Isar isar, dynamic record);
  Future<void> delete(Isar isar, dynamic record);
  Future<void> clear(Isar isar);
  int? idOf(dynamic record);
  String displayTitle(dynamic record);
}

class TypedIsarDebugCollection<T> implements IsarDebugCollection {
  TypedIsarDebugCollection({
    required this.name,
    required IsarCollection<T> Function(Isar isar) accessor,
    required T Function() create,
    required List<DebugField<T>> fields,
    required int? Function(T record) getId,
    required String Function(T record) titleBuilder,
  }) : _accessor = accessor,
       _create = create,
       _fields = fields,
       _getId = getId,
       _titleBuilder = titleBuilder;

  @override
  final String name;

  final IsarCollection<T> Function(Isar) _accessor;
  final T Function() _create;
  final List<DebugField<T>> _fields;
  final int? Function(T record) _getId;
  final String Function(T record) _titleBuilder;

  @override
  List<DebugFieldView> get fields => _fields
      .map(
        (f) => DebugFieldView(
          name: f.name,
          label: f.label,
          type: f.type,
          optional: f.optional,
          editable: f.editable,
          getValue: (record) => f.getValue(record as T),
          setValue: f.setValue == null
              ? null
              : (record, value) => f.setValue!(record as T, value),
        ),
      )
      .toList(growable: false);

  @override
  Future<List<dynamic>> fetchAll(Isar isar) {
    return _accessor(isar).where().findAll().then((value) => value.cast());
  }

  @override
  dynamic createNew() => _create();

  @override
  Future<void> save(Isar isar, dynamic record) async {
    await isar.writeTxn(() async {
      await _accessor(isar).put(record as T);
    });
  }

  @override
  Future<void> delete(Isar isar, dynamic record) async {
    final id = _getId(record as T);
    if (id == null) {
      return;
    }
    await isar.writeTxn(() async {
      await _accessor(isar).delete(id);
    });
  }

  @override
  Future<void> clear(Isar isar) async {
    await isar.writeTxn(() async {
      await _accessor(isar).clear();
    });
  }

  @override
  int? idOf(dynamic record) => _getId(record as T);

  @override
  String displayTitle(dynamic record) => _titleBuilder(record as T);
}

String formatDebugValue(DebugFieldType type, dynamic value) {
  if (value == null) {
    return '';
  }
  switch (type) {
    case DebugFieldType.boolean:
      return value == true ? 'true' : 'false';
    case DebugFieldType.bytes:
      if (value is List<int>) {
        if (value.isEmpty) {
          return '';
        }
        return base64Encode(value);
      }
      return value.toString();
    case DebugFieldType.dateTime:
      if (value is DateTime) {
        return value.toIso8601String();
      }
      return value.toString();
    case DebugFieldType.double:
    case DebugFieldType.int:
      return value.toString();
    case DebugFieldType.string:
    case DebugFieldType.text:
      return value.toString();
  }
}

List<IsarDebugCollection> buildIsarDebugCollections() => _collections;

final List<IsarDebugCollection> _collections = [
  TypedIsarDebugCollection<DeviceProfile>(
    name: 'DeviceProfile',
    accessor: (isar) => isar.deviceProfiles,
    create: () => DeviceProfile()
      ..id = 0
      ..deviceId = ''
      ..deviceType = 0
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now(),
    getId: (record) => record.id,
    titleBuilder: (record) => 'Device (${record.deviceId})',
    fields: [
      DebugField<DeviceProfile>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<DeviceProfile>(
        name: 'deviceId',
        label: 'Device ID',
        type: DebugFieldType.string,
        getValue: (r) => r.deviceId,
        setValue: (r, v) => r.deviceId = v as String,
      ),
      DebugField<DeviceProfile>(
        name: 'deviceType',
        label: 'Device Type',
        type: DebugFieldType.int,
        getValue: (r) => r.deviceType,
        setValue: (r, v) => r.deviceType = v as int,
      ),
      DebugField<DeviceProfile>(
        name: 'createdAt',
        label: 'Created At',
        type: DebugFieldType.dateTime,
        getValue: (r) => r.createdAt,
        setValue: (r, v) => r.createdAt = v as DateTime,
      ),
      DebugField<DeviceProfile>(
        name: 'updatedAt',
        label: 'Updated At',
        type: DebugFieldType.dateTime,
        getValue: (r) => r.updatedAt,
        setValue: (r, v) => r.updatedAt = v as DateTime,
      ),
    ],
  ),
  TypedIsarDebugCollection<AuthSession>(
    name: 'AuthSession',
    accessor: (isar) => isar.authSessions,
    create: () => AuthSession()
      ..id = 0
      ..isLoggedIn = false
      ..updatedAt = DateTime.now(),
    getId: (record) => record.id,
    titleBuilder: (record) => 'Auth Session',
    fields: [
      DebugField<AuthSession>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<AuthSession>(
        name: 'isLoggedIn',
        label: 'Is Logged In',
        type: DebugFieldType.boolean,
        getValue: (r) => r.isLoggedIn,
        setValue: (r, v) => r.isLoggedIn = v as bool,
      ),
      DebugField<AuthSession>(
        name: 'userId',
        label: 'User ID',
        type: DebugFieldType.int,
        optional: true,
        getValue: (r) => r.userId,
        setValue: (r, v) => r.userId = v as int?,
      ),
      DebugField<AuthSession>(
        name: 'loginType',
        label: 'Login Type',
        type: DebugFieldType.int,
        optional: true,
        getValue: (r) => r.loginType,
        setValue: (r, v) => r.loginType = v as int?,
      ),
      DebugField<AuthSession>(
        name: 'account',
        label: 'Account',
        type: DebugFieldType.string,
        optional: true,
        getValue: (r) => r.account,
        setValue: (r, v) => r.account = v as String?,
      ),
      DebugField<AuthSession>(
        name: 'password',
        label: 'Password',
        type: DebugFieldType.string,
        optional: true,
        getValue: (r) => r.password,
        setValue: (r, v) => r.password = v as String?,
      ),
      DebugField<AuthSession>(
        name: 'deviceType',
        label: 'Device Type',
        type: DebugFieldType.int,
        optional: true,
        getValue: (r) => r.deviceType,
        setValue: (r, v) => r.deviceType = v as int?,
      ),
      DebugField<AuthSession>(
        name: 'token',
        label: 'Token',
        type: DebugFieldType.text,
        optional: true,
        getValue: (r) => r.token,
        setValue: (r, v) => r.token = v as String?,
      ),
      DebugField<AuthSession>(
        name: 'expiresAt',
        label: 'Expires At',
        type: DebugFieldType.int,
        optional: true,
        getValue: (r) => r.expiresAt,
        setValue: (r, v) => r.expiresAt = v as int?,
      ),
      DebugField<AuthSession>(
        name: 'socketAddr',
        label: 'Socket Addr',
        type: DebugFieldType.string,
        optional: true,
        getValue: (r) => r.socketAddr,
        setValue: (r, v) => r.socketAddr = v as String?,
      ),
      DebugField<AuthSession>(
        name: 'updatedAt',
        label: 'Updated At',
        type: DebugFieldType.dateTime,
        optional: true,
        getValue: (r) => r.updatedAt,
        setValue: (r, v) => r.updatedAt = v as DateTime?,
      ),
    ],
  ),
  TypedIsarDebugCollection<FriendEntity>(
    name: 'FriendEntity',
    accessor: (isar) => isar.friendEntitys,
    create: () => FriendEntity()
      ..ownerId = 0
      ..friendId = 0
      ..addedAt = DateTime.now().millisecondsSinceEpoch
      ..updatedAt = DateTime.now().millisecondsSinceEpoch,
    getId: (record) => record.id,
    titleBuilder: (record) => 'Friend ${record.friendId}',
    fields: [
      DebugField<FriendEntity>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<FriendEntity>(
        name: 'ownerId',
        label: 'Owner ID',
        type: DebugFieldType.int,
        getValue: (r) => r.ownerId,
        setValue: (r, v) => r.ownerId = v as int,
      ),
      DebugField<FriendEntity>(
        name: 'friendId',
        label: 'Friend ID',
        type: DebugFieldType.int,
        getValue: (r) => r.friendId,
        setValue: (r, v) => r.friendId = v as int,
      ),
      DebugField<FriendEntity>(
        name: 'addedAt',
        label: 'Added At',
        type: DebugFieldType.int,
        getValue: (r) => r.addedAt,
        setValue: (r, v) => r.addedAt = v as int,
      ),
      DebugField<FriendEntity>(
        name: 'addSource',
        label: 'Add Source',
        type: DebugFieldType.string,
        optional: true,
        getValue: (r) => r.addSource,
        setValue: (r, v) => r.addSource = v as String?,
      ),
      DebugField<FriendEntity>(
        name: 'alias',
        label: 'Alias',
        type: DebugFieldType.string,
        optional: true,
        getValue: (r) => r.alias,
        setValue: (r, v) => r.alias = v as String?,
      ),
      DebugField<FriendEntity>(
        name: 'avatar',
        label: 'Avatar',
        type: DebugFieldType.string,
        optional: true,
        getValue: (r) => r.avatar,
        setValue: (r, v) => r.avatar = v as String?,
      ),
      DebugField<FriendEntity>(
        name: 'remark',
        label: 'Remark',
        type: DebugFieldType.text,
        optional: true,
        getValue: (r) => r.remark,
        setValue: (r, v) => r.remark = v as String?,
      ),
      DebugField<FriendEntity>(
        name: 'updatedAt',
        label: 'Updated At',
        type: DebugFieldType.int,
        getValue: (r) => r.updatedAt,
        setValue: (r, v) => r.updatedAt = v as int,
      ),
    ],
  ),
  TypedIsarDebugCollection<GroupEntity>(
    name: 'GroupEntity',
    accessor: (isar) => isar.groupEntitys,
    create: () => GroupEntity()
      ..ownerId = 0
      ..groupId = 0
      ..name = ''
      ..updatedAt = DateTime.now().millisecondsSinceEpoch,
    getId: (record) => record.id,
    titleBuilder: (record) => 'Group ${record.groupId}',
    fields: [
      DebugField<GroupEntity>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<GroupEntity>(
        name: 'ownerId',
        label: 'Owner ID',
        type: DebugFieldType.int,
        getValue: (r) => r.ownerId,
        setValue: (r, v) => r.ownerId = v as int,
      ),
      DebugField<GroupEntity>(
        name: 'groupId',
        label: 'Group ID',
        type: DebugFieldType.int,
        getValue: (r) => r.groupId,
        setValue: (r, v) => r.groupId = v as int,
      ),
      DebugField<GroupEntity>(
        name: 'name',
        label: 'Name',
        type: DebugFieldType.string,
        getValue: (r) => r.name,
        setValue: (r, v) => r.name = v as String,
      ),
      DebugField<GroupEntity>(
        name: 'avatar',
        label: 'Avatar',
        type: DebugFieldType.string,
        optional: true,
        getValue: (r) => r.avatar,
        setValue: (r, v) => r.avatar = v as String?,
      ),
      DebugField<GroupEntity>(
        name: 'notice',
        label: 'Notice',
        type: DebugFieldType.text,
        optional: true,
        getValue: (r) => r.notice,
        setValue: (r, v) => r.notice = v as String?,
      ),
      DebugField<GroupEntity>(
        name: 'updatedAt',
        label: 'Updated At',
        type: DebugFieldType.int,
        getValue: (r) => r.updatedAt,
        setValue: (r, v) => r.updatedAt = v as int,
      ),
    ],
  ),
  TypedIsarDebugCollection<FriendMessageEntity>(
    name: 'FriendMessage',
    accessor: (isar) => isar.friendMessageEntitys,
    create: () => FriendMessageEntity()
      ..ownerId = 0
      ..friendId = 0
      ..messageId = 0
      ..senderId = 0
      ..receiverId = 0
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..kind = 0
      ..isOutgoing = false
      ..deliveryStatus = MessageDeliveryStatus.pending.index,
    getId: (record) => record.id,
    titleBuilder: (record) => 'FriendMsg #${record.messageId}',
    fields: [
      DebugField<FriendMessageEntity>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<FriendMessageEntity>(
        name: 'ownerId',
        label: 'Owner ID',
        type: DebugFieldType.int,
        getValue: (r) => r.ownerId,
        setValue: (r, v) => r.ownerId = v as int,
      ),
      DebugField<FriendMessageEntity>(
        name: 'friendId',
        label: 'Friend ID',
        type: DebugFieldType.int,
        getValue: (r) => r.friendId,
        setValue: (r, v) => r.friendId = v as int,
      ),
      DebugField<FriendMessageEntity>(
        name: 'messageId',
        label: 'Message ID',
        type: DebugFieldType.int,
        getValue: (r) => r.messageId,
        setValue: (r, v) => r.messageId = v as int,
      ),
      DebugField<FriendMessageEntity>(
        name: 'senderId',
        label: 'Sender ID',
        type: DebugFieldType.int,
        getValue: (r) => r.senderId,
        setValue: (r, v) => r.senderId = v as int,
      ),
      DebugField<FriendMessageEntity>(
        name: 'receiverId',
        label: 'Receiver ID',
        type: DebugFieldType.int,
        getValue: (r) => r.receiverId,
        setValue: (r, v) => r.receiverId = v as int,
      ),
      DebugField<FriendMessageEntity>(
        name: 'timestamp',
        label: 'Timestamp',
        type: DebugFieldType.int,
        getValue: (r) => r.timestamp,
        setValue: (r, v) => r.timestamp = v as int,
      ),
      DebugField<FriendMessageEntity>(
        name: 'kind',
        label: 'Kind',
        type: DebugFieldType.int,
        getValue: (r) => r.kind,
        setValue: (r, v) => r.kind = v as int,
      ),
      DebugField<FriendMessageEntity>(
        name: 'isOutgoing',
        label: 'Is Outgoing',
        type: DebugFieldType.boolean,
        getValue: (r) => r.isOutgoing,
        setValue: (r, v) => r.isOutgoing = v as bool,
      ),
      DebugField<FriendMessageEntity>(
        name: 'deliveryStatus',
        label: 'Delivery Status',
        type: DebugFieldType.int,
        getValue: (r) => r.deliveryStatus,
        setValue: (r, v) => r.deliveryStatus = v as int,
      ),
      DebugField<FriendMessageEntity>(
        name: 'textPreview',
        label: 'Text Preview',
        type: DebugFieldType.text,
        optional: true,
        getValue: (r) => r.textPreview,
        setValue: (r, v) => r.textPreview = v as String?,
      ),
      DebugField<FriendMessageEntity>(
        name: 'payload',
        label: 'Payload (base64)',
        type: DebugFieldType.bytes,
        optional: true,
        getValue: (r) => r.payload,
        setValue: (r, v) => r.payload = (v as List<int>? ?? <int>[]),
      ),
    ],
  ),
  TypedIsarDebugCollection<FriendBizEntity>(
    name: 'FriendBiz',
    accessor: (isar) => isar.friendBizEntitys,
    create: () => FriendBizEntity()
      ..ownerId = 0
      ..friendId = 0
      ..eventId = 0
      ..kind = 0
      ..timestamp = DateTime.now().millisecondsSinceEpoch,
    getId: (record) => record.id,
    titleBuilder: (record) => 'FriendBiz #${record.eventId}',
    fields: [
      DebugField<FriendBizEntity>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<FriendBizEntity>(
        name: 'ownerId',
        label: 'Owner ID',
        type: DebugFieldType.int,
        getValue: (r) => r.ownerId,
        setValue: (r, v) => r.ownerId = v as int,
      ),
      DebugField<FriendBizEntity>(
        name: 'friendId',
        label: 'Friend ID',
        type: DebugFieldType.int,
        getValue: (r) => r.friendId,
        setValue: (r, v) => r.friendId = v as int,
      ),
      DebugField<FriendBizEntity>(
        name: 'eventId',
        label: 'Event ID',
        type: DebugFieldType.int,
        getValue: (r) => r.eventId,
        setValue: (r, v) => r.eventId = v as int,
      ),
      DebugField<FriendBizEntity>(
        name: 'kind',
        label: 'Kind',
        type: DebugFieldType.int,
        getValue: (r) => r.kind,
        setValue: (r, v) => r.kind = v as int,
      ),
      DebugField<FriendBizEntity>(
        name: 'timestamp',
        label: 'Timestamp',
        type: DebugFieldType.int,
        getValue: (r) => r.timestamp,
        setValue: (r, v) => r.timestamp = v as int,
      ),
      DebugField<FriendBizEntity>(
        name: 'payload',
        label: 'Payload (base64)',
        type: DebugFieldType.bytes,
        optional: true,
        getValue: (r) => r.payload,
        setValue: (r, v) => r.payload = (v as List<int>? ?? <int>[]),
      ),
    ],
  ),
  TypedIsarDebugCollection<GroupMessageEntity>(
    name: 'GroupMessage',
    accessor: (isar) => isar.groupMessageEntitys,
    create: () => GroupMessageEntity()
      ..ownerId = 0
      ..groupId = 0
      ..messageId = 0
      ..senderId = 0
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..kind = 0
      ..isOutgoing = false
      ..deliveryStatus = MessageDeliveryStatus.pending.index,
    getId: (record) => record.id,
    titleBuilder: (record) => 'GroupMsg #${record.messageId}',
    fields: [
      DebugField<GroupMessageEntity>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<GroupMessageEntity>(
        name: 'ownerId',
        label: 'Owner ID',
        type: DebugFieldType.int,
        getValue: (r) => r.ownerId,
        setValue: (r, v) => r.ownerId = v as int,
      ),
      DebugField<GroupMessageEntity>(
        name: 'groupId',
        label: 'Group ID',
        type: DebugFieldType.int,
        getValue: (r) => r.groupId,
        setValue: (r, v) => r.groupId = v as int,
      ),
      DebugField<GroupMessageEntity>(
        name: 'messageId',
        label: 'Message ID',
        type: DebugFieldType.int,
        getValue: (r) => r.messageId,
        setValue: (r, v) => r.messageId = v as int,
      ),
      DebugField<GroupMessageEntity>(
        name: 'senderId',
        label: 'Sender ID',
        type: DebugFieldType.int,
        getValue: (r) => r.senderId,
        setValue: (r, v) => r.senderId = v as int,
      ),
      DebugField<GroupMessageEntity>(
        name: 'timestamp',
        label: 'Timestamp',
        type: DebugFieldType.int,
        getValue: (r) => r.timestamp,
        setValue: (r, v) => r.timestamp = v as int,
      ),
      DebugField<GroupMessageEntity>(
        name: 'kind',
        label: 'Kind',
        type: DebugFieldType.int,
        getValue: (r) => r.kind,
        setValue: (r, v) => r.kind = v as int,
      ),
      DebugField<GroupMessageEntity>(
        name: 'isOutgoing',
        label: 'Is Outgoing',
        type: DebugFieldType.boolean,
        getValue: (r) => r.isOutgoing,
        setValue: (r, v) => r.isOutgoing = v as bool,
      ),
      DebugField<GroupMessageEntity>(
        name: 'deliveryStatus',
        label: 'Delivery Status',
        type: DebugFieldType.int,
        getValue: (r) => r.deliveryStatus,
        setValue: (r, v) => r.deliveryStatus = v as int,
      ),
      DebugField<GroupMessageEntity>(
        name: 'textPreview',
        label: 'Text Preview',
        type: DebugFieldType.text,
        optional: true,
        getValue: (r) => r.textPreview,
        setValue: (r, v) => r.textPreview = v as String?,
      ),
      DebugField<GroupMessageEntity>(
        name: 'payload',
        label: 'Payload (base64)',
        type: DebugFieldType.bytes,
        optional: true,
        getValue: (r) => r.payload,
        setValue: (r, v) => r.payload = (v as List<int>? ?? <int>[]),
      ),
    ],
  ),
  TypedIsarDebugCollection<GroupBizEntity>(
    name: 'GroupBiz',
    accessor: (isar) => isar.groupBizEntitys,
    create: () => GroupBizEntity()
      ..ownerId = 0
      ..groupId = 0
      ..eventId = 0
      ..kind = 0
      ..timestamp = DateTime.now().millisecondsSinceEpoch,
    getId: (record) => record.id,
    titleBuilder: (record) => 'GroupBiz #${record.eventId}',
    fields: [
      DebugField<GroupBizEntity>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<GroupBizEntity>(
        name: 'ownerId',
        label: 'Owner ID',
        type: DebugFieldType.int,
        getValue: (r) => r.ownerId,
        setValue: (r, v) => r.ownerId = v as int,
      ),
      DebugField<GroupBizEntity>(
        name: 'groupId',
        label: 'Group ID',
        type: DebugFieldType.int,
        getValue: (r) => r.groupId,
        setValue: (r, v) => r.groupId = v as int,
      ),
      DebugField<GroupBizEntity>(
        name: 'eventId',
        label: 'Event ID',
        type: DebugFieldType.int,
        getValue: (r) => r.eventId,
        setValue: (r, v) => r.eventId = v as int,
      ),
      DebugField<GroupBizEntity>(
        name: 'kind',
        label: 'Kind',
        type: DebugFieldType.int,
        getValue: (r) => r.kind,
        setValue: (r, v) => r.kind = v as int,
      ),
      DebugField<GroupBizEntity>(
        name: 'timestamp',
        label: 'Timestamp',
        type: DebugFieldType.int,
        getValue: (r) => r.timestamp,
        setValue: (r, v) => r.timestamp = v as int,
      ),
      DebugField<GroupBizEntity>(
        name: 'payload',
        label: 'Payload (base64)',
        type: DebugFieldType.bytes,
        optional: true,
        getValue: (r) => r.payload,
        setValue: (r, v) => r.payload = (v as List<int>? ?? <int>[]),
      ),
    ],
  ),
  TypedIsarDebugCollection<OutboxMessageEntity>(
    name: 'OutboxMessage',
    accessor: (isar) => isar.outboxMessageEntitys,
    create: () => OutboxMessageEntity()
      ..ownerId = 0
      ..targetId = 0
      ..isGroup = false
      ..kind = 0
      ..clientMessageId = 0
      ..retryCount = 0
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..status = MessageDeliveryStatus.pending.index
      ..payloadType = 'message.Content',
    getId: (record) => record.id,
    titleBuilder: (record) => 'Outbox #${record.clientMessageId}',
    fields: [
      DebugField<OutboxMessageEntity>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'ownerId',
        label: 'Owner ID',
        type: DebugFieldType.int,
        getValue: (r) => r.ownerId,
        setValue: (r, v) => r.ownerId = v as int,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'targetId',
        label: 'Target ID',
        type: DebugFieldType.int,
        getValue: (r) => r.targetId,
        setValue: (r, v) => r.targetId = v as int,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'isGroup',
        label: 'Is Group',
        type: DebugFieldType.boolean,
        getValue: (r) => r.isGroup,
        setValue: (r, v) => r.isGroup = v as bool,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'kind',
        label: 'Kind',
        type: DebugFieldType.int,
        getValue: (r) => r.kind,
        setValue: (r, v) => r.kind = v as int,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'messageId',
        label: 'Message ID',
        type: DebugFieldType.int,
        optional: true,
        getValue: (r) => r.messageId,
        setValue: (r, v) => r.messageId = v as int?,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'clientMessageId',
        label: 'Client Message ID',
        type: DebugFieldType.int,
        getValue: (r) => r.clientMessageId,
        setValue: (r, v) => r.clientMessageId = v as int,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'retryCount',
        label: 'Retry Count',
        type: DebugFieldType.int,
        getValue: (r) => r.retryCount,
        setValue: (r, v) => r.retryCount = v as int,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'lastAttemptAt',
        label: 'Last Attempt At',
        type: DebugFieldType.int,
        optional: true,
        getValue: (r) => r.lastAttemptAt,
        setValue: (r, v) => r.lastAttemptAt = v as int?,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'createdAt',
        label: 'Created At',
        type: DebugFieldType.int,
        getValue: (r) => r.createdAt,
        setValue: (r, v) => r.createdAt = v as int,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'status',
        label: 'Status',
        type: DebugFieldType.int,
        getValue: (r) => r.status,
        setValue: (r, v) => r.status = v as int,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'payloadType',
        label: 'Payload Type',
        type: DebugFieldType.string,
        getValue: (r) => r.payloadType,
        setValue: (r, v) => r.payloadType = v as String,
      ),
      DebugField<OutboxMessageEntity>(
        name: 'payload',
        label: 'Payload (base64)',
        type: DebugFieldType.bytes,
        optional: true,
        getValue: (r) => r.payload,
        setValue: (r, v) => r.payload = (v as List<int>? ?? <int>[]),
      ),
    ],
  ),
  TypedIsarDebugCollection<SystemMessageEntity>(
    name: 'SystemMessage',
    accessor: (isar) => isar.systemMessageEntitys,
    create: () => SystemMessageEntity()
      ..ownerId = 0
      ..messageId = 0
      ..kind = 0
      ..timestamp = DateTime.now().millisecondsSinceEpoch,
    getId: (record) => record.id,
    titleBuilder: (record) => 'SystemMsg #${record.messageId}',
    fields: [
      DebugField<SystemMessageEntity>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<SystemMessageEntity>(
        name: 'ownerId',
        label: 'Owner ID',
        type: DebugFieldType.int,
        getValue: (r) => r.ownerId,
        setValue: (r, v) => r.ownerId = v as int,
      ),
      DebugField<SystemMessageEntity>(
        name: 'messageId',
        label: 'Message ID',
        type: DebugFieldType.int,
        getValue: (r) => r.messageId,
        setValue: (r, v) => r.messageId = v as int,
      ),
      DebugField<SystemMessageEntity>(
        name: 'kind',
        label: 'Kind',
        type: DebugFieldType.int,
        getValue: (r) => r.kind,
        setValue: (r, v) => r.kind = v as int,
      ),
      DebugField<SystemMessageEntity>(
        name: 'timestamp',
        label: 'Timestamp',
        type: DebugFieldType.int,
        getValue: (r) => r.timestamp,
        setValue: (r, v) => r.timestamp = v as int,
      ),
      DebugField<SystemMessageEntity>(
        name: 'textPreview',
        label: 'Text Preview',
        type: DebugFieldType.text,
        optional: true,
        getValue: (r) => r.textPreview,
        setValue: (r, v) => r.textPreview = v as String?,
      ),
      DebugField<SystemMessageEntity>(
        name: 'payload',
        label: 'Payload (base64)',
        type: DebugFieldType.bytes,
        optional: true,
        getValue: (r) => r.payload,
        setValue: (r, v) => r.payload = (v as List<int>? ?? <int>[]),
      ),
    ],
  ),
  TypedIsarDebugCollection<VoiceMessageEntity>(
    name: 'VoiceMessage',
    accessor: (isar) => isar.voiceMessageEntitys,
    create: () => VoiceMessageEntity()
      ..ownerId = 0
      ..conversationId = 0
      ..isGroup = false
      ..messageId = 0
      ..senderId = 0
      ..timestamp = DateTime.now().millisecondsSinceEpoch
      ..isOutgoing = false
      ..deliveryStatus = MessageDeliveryStatus.pending.index,
    getId: (record) => record.id,
    titleBuilder: (record) => 'VoiceMsg #${record.messageId}',
    fields: [
      DebugField<VoiceMessageEntity>(
        name: 'id',
        label: 'ID',
        type: DebugFieldType.int,
        editable: false,
        getValue: (r) => r.id,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'ownerId',
        label: 'Owner ID',
        type: DebugFieldType.int,
        getValue: (r) => r.ownerId,
        setValue: (r, v) => r.ownerId = v as int,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'conversationId',
        label: 'Conversation ID',
        type: DebugFieldType.int,
        getValue: (r) => r.conversationId,
        setValue: (r, v) => r.conversationId = v as int,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'isGroup',
        label: 'Is Group',
        type: DebugFieldType.boolean,
        getValue: (r) => r.isGroup,
        setValue: (r, v) => r.isGroup = v as bool,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'messageId',
        label: 'Message ID',
        type: DebugFieldType.int,
        getValue: (r) => r.messageId,
        setValue: (r, v) => r.messageId = v as int,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'senderId',
        label: 'Sender ID',
        type: DebugFieldType.int,
        getValue: (r) => r.senderId,
        setValue: (r, v) => r.senderId = v as int,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'receiverId',
        label: 'Receiver ID',
        type: DebugFieldType.int,
        optional: true,
        getValue: (r) => r.receiverId,
        setValue: (r, v) => r.receiverId = v as int?,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'timestamp',
        label: 'Timestamp',
        type: DebugFieldType.int,
        getValue: (r) => r.timestamp,
        setValue: (r, v) => r.timestamp = v as int,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'isOutgoing',
        label: 'Is Outgoing',
        type: DebugFieldType.boolean,
        getValue: (r) => r.isOutgoing,
        setValue: (r, v) => r.isOutgoing = v as bool,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'remoteUrl',
        label: 'Remote URL',
        type: DebugFieldType.string,
        optional: true,
        getValue: (r) => r.remoteUrl,
        setValue: (r, v) => r.remoteUrl = v as String?,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'localPath',
        label: 'Local Path',
        type: DebugFieldType.string,
        optional: true,
        getValue: (r) => r.localPath,
        setValue: (r, v) => r.localPath = v as String?,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'durationSeconds',
        label: 'Duration Seconds',
        type: DebugFieldType.int,
        optional: true,
        getValue: (r) => r.durationSeconds,
        setValue: (r, v) => r.durationSeconds = v as int?,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'format',
        label: 'Format',
        type: DebugFieldType.string,
        optional: true,
        getValue: (r) => r.format,
        setValue: (r, v) => r.format = v as String?,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'fileSize',
        label: 'File Size',
        type: DebugFieldType.int,
        optional: true,
        getValue: (r) => r.fileSize,
        setValue: (r, v) => r.fileSize = v as int?,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'deliveryStatus',
        label: 'Delivery Status',
        type: DebugFieldType.int,
        getValue: (r) => r.deliveryStatus,
        setValue: (r, v) => r.deliveryStatus = v as int,
      ),
      DebugField<VoiceMessageEntity>(
        name: 'isListened',
        label: 'Is Listened',
        type: DebugFieldType.boolean,
        getValue: (r) => r.isListened,
        setValue: (r, v) => r.isListened = v as bool,
      ),
    ],
  ),
];

List<int>? decodeBytesField(String? input) {
  if (input == null || input.trim().isEmpty) {
    return <int>[];
  }
  try {
    return base64Decode(input);
  } catch (_) {
    return null;
  }
}
