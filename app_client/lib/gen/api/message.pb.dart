// This is a generated file - do not edit.
//
// Generated from message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'message.pbenum.dart';
import 'socket.pbenum.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'message.pbenum.dart';

enum MessageContent_Content {
  text, 
  image, 
  audio, 
  video, 
  location, 
  file, 
  avCall, 
  custom, 
  emoji, 
  revoke, 
  forward, 
  quote, 
  html, 
  voip, 
  notification, 
  system, 
  reminder, 
  groupEvent, 
  contactCard, 
  vote, 
  redEnvelope, 
  encrypted, 
  ack, 
  notSet
}

/// ======================================
/// 💠 消息内容结构（oneof 类型）
/// ======================================
/// 使用 oneof 定义不同类型的消息内容，确保消息类型的互斥性
class MessageContent extends $pb.GeneratedMessage {
  factory MessageContent({
    TextContent? text,
    ImageContent? image,
    AudioContent? audio,
    VideoContent? video,
    LocationContent? location,
    FileContent? file,
    AVCallContent? avCall,
    CustomContent? custom,
    EmojiContent? emoji,
    RevokeContent? revoke,
    ForwardContent? forward,
    QuoteContent? quote,
    HtmlContent? html,
    VoipContent? voip,
    NotificationContent? notification,
    SystemContent? system,
    ReminderContent? reminder,
    GroupEventContent? groupEvent,
    ContactCardContent? contactCard,
    VoteContent? vote,
    RedEnvelopeContent? redEnvelope,
    EncryptedContent? encrypted,
    AckContent? ack,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (image != null) result.image = image;
    if (audio != null) result.audio = audio;
    if (video != null) result.video = video;
    if (location != null) result.location = location;
    if (file != null) result.file = file;
    if (avCall != null) result.avCall = avCall;
    if (custom != null) result.custom = custom;
    if (emoji != null) result.emoji = emoji;
    if (revoke != null) result.revoke = revoke;
    if (forward != null) result.forward = forward;
    if (quote != null) result.quote = quote;
    if (html != null) result.html = html;
    if (voip != null) result.voip = voip;
    if (notification != null) result.notification = notification;
    if (system != null) result.system = system;
    if (reminder != null) result.reminder = reminder;
    if (groupEvent != null) result.groupEvent = groupEvent;
    if (contactCard != null) result.contactCard = contactCard;
    if (vote != null) result.vote = vote;
    if (redEnvelope != null) result.redEnvelope = redEnvelope;
    if (encrypted != null) result.encrypted = encrypted;
    if (ack != null) result.ack = ack;
    return result;
  }

  MessageContent._();

  factory MessageContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MessageContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, MessageContent_Content> _MessageContent_ContentByTag = {
    1 : MessageContent_Content.text,
    2 : MessageContent_Content.image,
    3 : MessageContent_Content.audio,
    4 : MessageContent_Content.video,
    5 : MessageContent_Content.location,
    6 : MessageContent_Content.file,
    7 : MessageContent_Content.avCall,
    8 : MessageContent_Content.custom,
    9 : MessageContent_Content.emoji,
    10 : MessageContent_Content.revoke,
    11 : MessageContent_Content.forward,
    12 : MessageContent_Content.quote,
    13 : MessageContent_Content.html,
    14 : MessageContent_Content.voip,
    15 : MessageContent_Content.notification,
    16 : MessageContent_Content.system,
    17 : MessageContent_Content.reminder,
    18 : MessageContent_Content.groupEvent,
    19 : MessageContent_Content.contactCard,
    20 : MessageContent_Content.vote,
    21 : MessageContent_Content.redEnvelope,
    22 : MessageContent_Content.encrypted,
    23 : MessageContent_Content.ack,
    0 : MessageContent_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23])
    ..aOM<TextContent>(1, _omitFieldNames ? '' : 'text', subBuilder: TextContent.create)
    ..aOM<ImageContent>(2, _omitFieldNames ? '' : 'image', subBuilder: ImageContent.create)
    ..aOM<AudioContent>(3, _omitFieldNames ? '' : 'audio', subBuilder: AudioContent.create)
    ..aOM<VideoContent>(4, _omitFieldNames ? '' : 'video', subBuilder: VideoContent.create)
    ..aOM<LocationContent>(5, _omitFieldNames ? '' : 'location', subBuilder: LocationContent.create)
    ..aOM<FileContent>(6, _omitFieldNames ? '' : 'file', subBuilder: FileContent.create)
    ..aOM<AVCallContent>(7, _omitFieldNames ? '' : 'avCall', subBuilder: AVCallContent.create)
    ..aOM<CustomContent>(8, _omitFieldNames ? '' : 'custom', subBuilder: CustomContent.create)
    ..aOM<EmojiContent>(9, _omitFieldNames ? '' : 'emoji', subBuilder: EmojiContent.create)
    ..aOM<RevokeContent>(10, _omitFieldNames ? '' : 'revoke', subBuilder: RevokeContent.create)
    ..aOM<ForwardContent>(11, _omitFieldNames ? '' : 'forward', subBuilder: ForwardContent.create)
    ..aOM<QuoteContent>(12, _omitFieldNames ? '' : 'quote', subBuilder: QuoteContent.create)
    ..aOM<HtmlContent>(13, _omitFieldNames ? '' : 'html', subBuilder: HtmlContent.create)
    ..aOM<VoipContent>(14, _omitFieldNames ? '' : 'voip', subBuilder: VoipContent.create)
    ..aOM<NotificationContent>(15, _omitFieldNames ? '' : 'notification', subBuilder: NotificationContent.create)
    ..aOM<SystemContent>(16, _omitFieldNames ? '' : 'system', subBuilder: SystemContent.create)
    ..aOM<ReminderContent>(17, _omitFieldNames ? '' : 'reminder', subBuilder: ReminderContent.create)
    ..aOM<GroupEventContent>(18, _omitFieldNames ? '' : 'groupEvent', subBuilder: GroupEventContent.create)
    ..aOM<ContactCardContent>(19, _omitFieldNames ? '' : 'contactCard', subBuilder: ContactCardContent.create)
    ..aOM<VoteContent>(20, _omitFieldNames ? '' : 'vote', subBuilder: VoteContent.create)
    ..aOM<RedEnvelopeContent>(21, _omitFieldNames ? '' : 'redEnvelope', subBuilder: RedEnvelopeContent.create)
    ..aOM<EncryptedContent>(22, _omitFieldNames ? '' : 'encrypted', subBuilder: EncryptedContent.create)
    ..aOM<AckContent>(23, _omitFieldNames ? '' : 'ack', subBuilder: AckContent.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageContent clone() => MessageContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageContent copyWith(void Function(MessageContent) updates) => super.copyWith((message) => updates(message as MessageContent)) as MessageContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageContent create() => MessageContent._();
  @$core.override
  MessageContent createEmptyInstance() => create();
  static $pb.PbList<MessageContent> createRepeated() => $pb.PbList<MessageContent>();
  @$core.pragma('dart2js:noInline')
  static MessageContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageContent>(create);
  static MessageContent? _defaultInstance;

  MessageContent_Content whichContent() => _MessageContent_ContentByTag[$_whichOneof(0)]!;
  void clearContent() => $_clearField($_whichOneof(0));

  /// 文本消息：纯文本内容
  @$pb.TagNumber(1)
  TextContent get text => $_getN(0);
  @$pb.TagNumber(1)
  set text(TextContent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);
  @$pb.TagNumber(1)
  TextContent ensureText() => $_ensure(0);

  /// 图片消息：图片文件
  @$pb.TagNumber(2)
  ImageContent get image => $_getN(1);
  @$pb.TagNumber(2)
  set image(ImageContent value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasImage() => $_has(1);
  @$pb.TagNumber(2)
  void clearImage() => $_clearField(2);
  @$pb.TagNumber(2)
  ImageContent ensureImage() => $_ensure(1);

  /// 音频消息：语音或音乐
  @$pb.TagNumber(3)
  AudioContent get audio => $_getN(2);
  @$pb.TagNumber(3)
  set audio(AudioContent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAudio() => $_has(2);
  @$pb.TagNumber(3)
  void clearAudio() => $_clearField(3);
  @$pb.TagNumber(3)
  AudioContent ensureAudio() => $_ensure(2);

  /// 视频消息：视频文件
  @$pb.TagNumber(4)
  VideoContent get video => $_getN(3);
  @$pb.TagNumber(4)
  set video(VideoContent value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasVideo() => $_has(3);
  @$pb.TagNumber(4)
  void clearVideo() => $_clearField(4);
  @$pb.TagNumber(4)
  VideoContent ensureVideo() => $_ensure(3);

  /// 位置消息：地理位置信息
  @$pb.TagNumber(5)
  LocationContent get location => $_getN(4);
  @$pb.TagNumber(5)
  set location(LocationContent value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLocation() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocation() => $_clearField(5);
  @$pb.TagNumber(5)
  LocationContent ensureLocation() => $_ensure(4);

  /// 文件消息：任意文件类型
  @$pb.TagNumber(6)
  FileContent get file => $_getN(5);
  @$pb.TagNumber(6)
  set file(FileContent value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasFile() => $_has(5);
  @$pb.TagNumber(6)
  void clearFile() => $_clearField(6);
  @$pb.TagNumber(6)
  FileContent ensureFile() => $_ensure(5);

  /// 音视频通话信令：通话控制消息
  @$pb.TagNumber(7)
  AVCallContent get avCall => $_getN(6);
  @$pb.TagNumber(7)
  set avCall(AVCallContent value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasAvCall() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvCall() => $_clearField(7);
  @$pb.TagNumber(7)
  AVCallContent ensureAvCall() => $_ensure(6);

  /// 自定义消息：开发者自定义结构
  @$pb.TagNumber(8)
  CustomContent get custom => $_getN(7);
  @$pb.TagNumber(8)
  set custom(CustomContent value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCustom() => $_has(7);
  @$pb.TagNumber(8)
  void clearCustom() => $_clearField(8);
  @$pb.TagNumber(8)
  CustomContent ensureCustom() => $_ensure(7);

  /// 表情消息：emoji 表情
  @$pb.TagNumber(9)
  EmojiContent get emoji => $_getN(8);
  @$pb.TagNumber(9)
  set emoji(EmojiContent value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasEmoji() => $_has(8);
  @$pb.TagNumber(9)
  void clearEmoji() => $_clearField(9);
  @$pb.TagNumber(9)
  EmojiContent ensureEmoji() => $_ensure(8);

  /// 撤回消息：消息撤回通知
  @$pb.TagNumber(10)
  RevokeContent get revoke => $_getN(9);
  @$pb.TagNumber(10)
  set revoke(RevokeContent value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasRevoke() => $_has(9);
  @$pb.TagNumber(10)
  void clearRevoke() => $_clearField(10);
  @$pb.TagNumber(10)
  RevokeContent ensureRevoke() => $_ensure(9);

  /// 转发消息：消息转发
  @$pb.TagNumber(11)
  ForwardContent get forward => $_getN(10);
  @$pb.TagNumber(11)
  set forward(ForwardContent value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasForward() => $_has(10);
  @$pb.TagNumber(11)
  void clearForward() => $_clearField(11);
  @$pb.TagNumber(11)
  ForwardContent ensureForward() => $_ensure(10);

  /// 引用回复消息：回复特定消息
  @$pb.TagNumber(12)
  QuoteContent get quote => $_getN(11);
  @$pb.TagNumber(12)
  set quote(QuoteContent value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasQuote() => $_has(11);
  @$pb.TagNumber(12)
  void clearQuote() => $_clearField(12);
  @$pb.TagNumber(12)
  QuoteContent ensureQuote() => $_ensure(11);

  /// HTML 卡片：富文本内容
  @$pb.TagNumber(13)
  HtmlContent get html => $_getN(12);
  @$pb.TagNumber(13)
  set html(HtmlContent value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasHtml() => $_has(12);
  @$pb.TagNumber(13)
  void clearHtml() => $_clearField(13);
  @$pb.TagNumber(13)
  HtmlContent ensureHtml() => $_ensure(12);

  /// VOIP 通话记录：通话日志
  @$pb.TagNumber(14)
  VoipContent get voip => $_getN(13);
  @$pb.TagNumber(14)
  set voip(VoipContent value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasVoip() => $_has(13);
  @$pb.TagNumber(14)
  void clearVoip() => $_clearField(14);
  @$pb.TagNumber(14)
  VoipContent ensureVoip() => $_ensure(13);

  /// 通知消息：系统通知
  @$pb.TagNumber(15)
  NotificationContent get notification => $_getN(14);
  @$pb.TagNumber(15)
  set notification(NotificationContent value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasNotification() => $_has(14);
  @$pb.TagNumber(15)
  void clearNotification() => $_clearField(15);
  @$pb.TagNumber(15)
  NotificationContent ensureNotification() => $_ensure(14);

  /// 系统消息：系统级消息
  @$pb.TagNumber(16)
  SystemContent get system => $_getN(15);
  @$pb.TagNumber(16)
  set system(SystemContent value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasSystem() => $_has(15);
  @$pb.TagNumber(16)
  void clearSystem() => $_clearField(16);
  @$pb.TagNumber(16)
  SystemContent ensureSystem() => $_ensure(15);

  /// 提醒消息：提醒事项
  @$pb.TagNumber(17)
  ReminderContent get reminder => $_getN(16);
  @$pb.TagNumber(17)
  set reminder(ReminderContent value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasReminder() => $_has(16);
  @$pb.TagNumber(17)
  void clearReminder() => $_clearField(17);
  @$pb.TagNumber(17)
  ReminderContent ensureReminder() => $_ensure(16);

  /// 群组事件：群组相关事件
  @$pb.TagNumber(18)
  GroupEventContent get groupEvent => $_getN(17);
  @$pb.TagNumber(18)
  set groupEvent(GroupEventContent value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasGroupEvent() => $_has(17);
  @$pb.TagNumber(18)
  void clearGroupEvent() => $_clearField(18);
  @$pb.TagNumber(18)
  GroupEventContent ensureGroupEvent() => $_ensure(17);

  /// 名片消息：联系人分享
  @$pb.TagNumber(19)
  ContactCardContent get contactCard => $_getN(18);
  @$pb.TagNumber(19)
  set contactCard(ContactCardContent value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasContactCard() => $_has(18);
  @$pb.TagNumber(19)
  void clearContactCard() => $_clearField(19);
  @$pb.TagNumber(19)
  ContactCardContent ensureContactCard() => $_ensure(18);

  /// 投票消息：投票内容
  @$pb.TagNumber(20)
  VoteContent get vote => $_getN(19);
  @$pb.TagNumber(20)
  set vote(VoteContent value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasVote() => $_has(19);
  @$pb.TagNumber(20)
  void clearVote() => $_clearField(20);
  @$pb.TagNumber(20)
  VoteContent ensureVote() => $_ensure(19);

  /// 红包消息：红包内容
  @$pb.TagNumber(21)
  RedEnvelopeContent get redEnvelope => $_getN(20);
  @$pb.TagNumber(21)
  set redEnvelope(RedEnvelopeContent value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasRedEnvelope() => $_has(20);
  @$pb.TagNumber(21)
  void clearRedEnvelope() => $_clearField(21);
  @$pb.TagNumber(21)
  RedEnvelopeContent ensureRedEnvelope() => $_ensure(20);

  /// 加密内容封装（端到端加密）
  @$pb.TagNumber(22)
  EncryptedContent get encrypted => $_getN(21);
  @$pb.TagNumber(22)
  set encrypted(EncryptedContent value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasEncrypted() => $_has(21);
  @$pb.TagNumber(22)
  void clearEncrypted() => $_clearField(22);
  @$pb.TagNumber(22)
  EncryptedContent ensureEncrypted() => $_ensure(21);

  /// 通用业务确认/通知（处理结果回执）
  @$pb.TagNumber(23)
  AckContent get ack => $_getN(22);
  @$pb.TagNumber(23)
  set ack(AckContent value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasAck() => $_has(22);
  @$pb.TagNumber(23)
  void clearAck() => $_clearField(23);
  @$pb.TagNumber(23)
  AckContent ensureAck() => $_ensure(22);
}

/// ===============================
/// ✅ 通用业务确认/通知（处理结果回执）
/// ===============================
/// 用于服务端向客户端回传“该业务已处理”的标准结构。
class AckContent extends $pb.GeneratedMessage {
  factory AckContent({
    $core.bool? ok,
    $core.int? code,
    $core.String? message,
    $core.int? requestKind,
    $fixnum.Int64? refMessageId,
    $core.List<$core.int>? extra,
  }) {
    final result = create();
    if (ok != null) result.ok = ok;
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (requestKind != null) result.requestKind = requestKind;
    if (refMessageId != null) result.refMessageId = refMessageId;
    if (extra != null) result.extra = extra;
    return result;
  }

  AckContent._();

  factory AckContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AckContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AckContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'requestKind', $pb.PbFieldType.O3)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'refMessageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'extra', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AckContent clone() => AckContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AckContent copyWith(void Function(AckContent) updates) => super.copyWith((message) => updates(message as AckContent)) as AckContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AckContent create() => AckContent._();
  @$core.override
  AckContent createEmptyInstance() => create();
  static $pb.PbList<AckContent> createRepeated() => $pb.PbList<AckContent>();
  @$core.pragma('dart2js:noInline')
  static AckContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AckContent>(create);
  static AckContent? _defaultInstance;

  /// 是否成功
  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);

  /// 业务错误码（0 表示无错误）
  @$pb.TagNumber(2)
  $core.int get code => $_getIZ(1);
  @$pb.TagNumber(2)
  set code($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);

  /// 文本信息（可本地化）
  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);

  /// 请求的业务种类（如 socket 的 MsgKind 值）
  @$pb.TagNumber(4)
  $core.int get requestKind => $_getIZ(3);
  @$pb.TagNumber(4)
  set requestKind($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRequestKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequestKind() => $_clearField(4);

  /// 可选的引用消息 ID（与此次处理相关的消息）
  @$pb.TagNumber(5)
  $fixnum.Int64 get refMessageId => $_getI64(4);
  @$pb.TagNumber(5)
  set refMessageId($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRefMessageId() => $_has(4);
  @$pb.TagNumber(5)
  void clearRefMessageId() => $_clearField(5);

  /// 附加数据（预留）
  @$pb.TagNumber(6)
  $core.List<$core.int> get extra => $_getN(5);
  @$pb.TagNumber(6)
  set extra($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExtra() => $_has(5);
  @$pb.TagNumber(6)
  void clearExtra() => $_clearField(6);
}

/// ===============================
/// 📄 文本消息
/// ===============================
/// 支持纯文本和富文本格式，包含内联实体（链接、@用户、话题等）
class TextContent extends $pb.GeneratedMessage {
  factory TextContent({
    $core.String? text,
    $core.Iterable<InlineEntity>? entities,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (entities != null) result.entities.addAll(entities);
    return result;
  }

  TextContent._();

  factory TextContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory TextContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TextContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..pc<InlineEntity>(2, _omitFieldNames ? '' : 'entities', $pb.PbFieldType.PM, subBuilder: InlineEntity.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextContent clone() => TextContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextContent copyWith(void Function(TextContent) updates) => super.copyWith((message) => updates(message as TextContent)) as TextContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TextContent create() => TextContent._();
  @$core.override
  TextContent createEmptyInstance() => create();
  static $pb.PbList<TextContent> createRepeated() => $pb.PbList<TextContent>();
  @$core.pragma('dart2js:noInline')
  static TextContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TextContent>(create);
  static TextContent? _defaultInstance;

  /// 文本主体内容：消息的文本内容
  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  /// 富文本实体，如链接/@用户/话题：文本中的特殊元素
  @$pb.TagNumber(2)
  $pb.PbList<InlineEntity> get entities => $_getList(1);
}

/// 内联实体：用于在文本中标记特殊元素
class InlineEntity extends $pb.GeneratedMessage {
  factory InlineEntity({
    $core.int? start,
    $core.int? end,
    $core.String? type,
    $core.String? value,
  }) {
    final result = create();
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    if (type != null) result.type = type;
    if (value != null) result.value = value;
    return result;
  }

  InlineEntity._();

  factory InlineEntity.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory InlineEntity.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InlineEntity', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'start', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'end', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..aOS(4, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InlineEntity clone() => InlineEntity()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InlineEntity copyWith(void Function(InlineEntity) updates) => super.copyWith((message) => updates(message as InlineEntity)) as InlineEntity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InlineEntity create() => InlineEntity._();
  @$core.override
  InlineEntity createEmptyInstance() => create();
  static $pb.PbList<InlineEntity> createRepeated() => $pb.PbList<InlineEntity>();
  @$core.pragma('dart2js:noInline')
  static InlineEntity getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InlineEntity>(create);
  static InlineEntity? _defaultInstance;

  /// 起始位置（UTF-8 字符索引）：实体在文本中的开始位置
  @$pb.TagNumber(1)
  $core.int get start => $_getIZ(0);
  @$pb.TagNumber(1)
  set start($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearStart() => $_clearField(1);

  /// 结束位置（不含）：实体在文本中的结束位置
  @$pb.TagNumber(2)
  $core.int get end => $_getIZ(1);
  @$pb.TagNumber(2)
  set end($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => $_clearField(2);

  /// 类型：link / mention / hashtag：实体的类型
  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  /// 附加值：URL、用户ID等：实体的具体值
  @$pb.TagNumber(4)
  $core.String get value => $_getSZ(3);
  @$pb.TagNumber(4)
  set value($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => $_clearField(4);
}

/// ===============================
/// 🖼️ 图片消息
/// ===============================
/// 包含图片的完整信息，支持原图和缩略图
class ImageContent extends $pb.GeneratedMessage {
  factory ImageContent({
    $core.String? url,
    $core.String? thumbnailUrl,
    $core.int? width,
    $core.int? height,
    $core.String? format,
    $fixnum.Int64? size,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (thumbnailUrl != null) result.thumbnailUrl = thumbnailUrl;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (format != null) result.format = format;
    if (size != null) result.size = size;
    return result;
  }

  ImageContent._();

  factory ImageContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ImageContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImageContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'thumbnailUrl')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'format')
    ..aInt64(6, _omitFieldNames ? '' : 'size')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageContent clone() => ImageContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageContent copyWith(void Function(ImageContent) updates) => super.copyWith((message) => updates(message as ImageContent)) as ImageContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageContent create() => ImageContent._();
  @$core.override
  ImageContent createEmptyInstance() => create();
  static $pb.PbList<ImageContent> createRepeated() => $pb.PbList<ImageContent>();
  @$core.pragma('dart2js:noInline')
  static ImageContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImageContent>(create);
  static ImageContent? _defaultInstance;

  /// 原图 URL：图片的完整地址
  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  /// 缩略图 URL：图片的缩略图地址
  @$pb.TagNumber(2)
  $core.String get thumbnailUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set thumbnailUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasThumbnailUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearThumbnailUrl() => $_clearField(2);

  /// 宽度（像素）：图片的宽度
  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  /// 高度（像素）：图片的高度
  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);

  /// 格式（如 jpg/png）：图片的文件格式
  @$pb.TagNumber(5)
  $core.String get format => $_getSZ(4);
  @$pb.TagNumber(5)
  set format($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFormat() => $_has(4);
  @$pb.TagNumber(5)
  void clearFormat() => $_clearField(5);

  /// 文件大小（字节）：图片文件的大小
  @$pb.TagNumber(6)
  $fixnum.Int64 get size => $_getI64(5);
  @$pb.TagNumber(6)
  set size($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearSize() => $_clearField(6);
}

/// ===============================
/// 🔊 音频消息
/// ===============================
/// 支持语音聊天和音乐播放，包含时长和格式信息
class AudioContent extends $pb.GeneratedMessage {
  factory AudioContent({
    $core.String? url,
    $core.int? duration,
    $core.String? format,
    $fixnum.Int64? size,
    $core.bool? isVoice,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (duration != null) result.duration = duration;
    if (format != null) result.format = format;
    if (size != null) result.size = size;
    if (isVoice != null) result.isVoice = isVoice;
    return result;
  }

  AudioContent._();

  factory AudioContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AudioContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AudioContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'duration', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'format')
    ..aInt64(4, _omitFieldNames ? '' : 'size')
    ..aOB(5, _omitFieldNames ? '' : 'isVoice')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioContent clone() => AudioContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioContent copyWith(void Function(AudioContent) updates) => super.copyWith((message) => updates(message as AudioContent)) as AudioContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AudioContent create() => AudioContent._();
  @$core.override
  AudioContent createEmptyInstance() => create();
  static $pb.PbList<AudioContent> createRepeated() => $pb.PbList<AudioContent>();
  @$core.pragma('dart2js:noInline')
  static AudioContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AudioContent>(create);
  static AudioContent? _defaultInstance;

  /// 音频文件 URL：音频文件的地址
  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  /// 时长（秒）：音频的播放时长
  @$pb.TagNumber(2)
  $core.int get duration => $_getIZ(1);
  @$pb.TagNumber(2)
  set duration($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => $_clearField(2);

  /// 格式：音频文件格式（如 mp3/wav）
  @$pb.TagNumber(3)
  $core.String get format => $_getSZ(2);
  @$pb.TagNumber(3)
  set format($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFormat() => $_has(2);
  @$pb.TagNumber(3)
  void clearFormat() => $_clearField(3);

  /// 文件大小（字节）：音频文件的大小
  @$pb.TagNumber(4)
  $fixnum.Int64 get size => $_getI64(3);
  @$pb.TagNumber(4)
  set size($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearSize() => $_clearField(4);

  /// 是否语音（vs 音乐类音频）：true表示语音，false表示音乐
  @$pb.TagNumber(5)
  $core.bool get isVoice => $_getBF(4);
  @$pb.TagNumber(5)
  set isVoice($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsVoice() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsVoice() => $_clearField(5);
}

/// ===============================
/// 🎞️ 视频消息
/// ===============================
/// 包含视频文件和封面图，支持播放控制
class VideoContent extends $pb.GeneratedMessage {
  factory VideoContent({
    $core.String? url,
    $core.int? duration,
    $core.String? coverUrl,
    $core.int? width,
    $core.int? height,
    $core.String? format,
    $fixnum.Int64? size,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (duration != null) result.duration = duration;
    if (coverUrl != null) result.coverUrl = coverUrl;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (format != null) result.format = format;
    if (size != null) result.size = size;
    return result;
  }

  VideoContent._();

  factory VideoContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory VideoContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VideoContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'duration', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'coverUrl')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'format')
    ..aInt64(7, _omitFieldNames ? '' : 'size')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VideoContent clone() => VideoContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VideoContent copyWith(void Function(VideoContent) updates) => super.copyWith((message) => updates(message as VideoContent)) as VideoContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VideoContent create() => VideoContent._();
  @$core.override
  VideoContent createEmptyInstance() => create();
  static $pb.PbList<VideoContent> createRepeated() => $pb.PbList<VideoContent>();
  @$core.pragma('dart2js:noInline')
  static VideoContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VideoContent>(create);
  static VideoContent? _defaultInstance;

  /// 视频文件 URL：视频文件的地址
  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  /// 时长（秒）：视频的播放时长
  @$pb.TagNumber(2)
  $core.int get duration => $_getIZ(1);
  @$pb.TagNumber(2)
  set duration($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => $_clearField(2);

  /// 封面图 URL：视频的封面图片
  @$pb.TagNumber(3)
  $core.String get coverUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set coverUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCoverUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearCoverUrl() => $_clearField(3);

  /// 宽度（像素）：视频的宽度
  @$pb.TagNumber(4)
  $core.int get width => $_getIZ(3);
  @$pb.TagNumber(4)
  set width($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearWidth() => $_clearField(4);

  /// 高度（像素）：视频的高度
  @$pb.TagNumber(5)
  $core.int get height => $_getIZ(4);
  @$pb.TagNumber(5)
  set height($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeight() => $_clearField(5);

  /// 格式：视频文件格式（如 mp4/avi）
  @$pb.TagNumber(6)
  $core.String get format => $_getSZ(5);
  @$pb.TagNumber(6)
  set format($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFormat() => $_has(5);
  @$pb.TagNumber(6)
  void clearFormat() => $_clearField(6);

  /// 文件大小（字节）：视频文件的大小
  @$pb.TagNumber(7)
  $fixnum.Int64 get size => $_getI64(6);
  @$pb.TagNumber(7)
  set size($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSize() => $_has(6);
  @$pb.TagNumber(7)
  void clearSize() => $_clearField(7);
}

/// ===============================
/// 📍 位置消息
/// ===============================
/// 包含地理位置信息，支持地址描述和地图显示
class LocationContent extends $pb.GeneratedMessage {
  factory LocationContent({
    $core.double? latitude,
    $core.double? longitude,
    $core.String? address,
    $core.String? poiName,
    $core.String? thumbnailUrl,
  }) {
    final result = create();
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (address != null) result.address = address;
    if (poiName != null) result.poiName = poiName;
    if (thumbnailUrl != null) result.thumbnailUrl = thumbnailUrl;
    return result;
  }

  LocationContent._();

  factory LocationContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LocationContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LocationContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'latitude', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'longitude', $pb.PbFieldType.OD)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'poiName')
    ..aOS(5, _omitFieldNames ? '' : 'thumbnailUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationContent clone() => LocationContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationContent copyWith(void Function(LocationContent) updates) => super.copyWith((message) => updates(message as LocationContent)) as LocationContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocationContent create() => LocationContent._();
  @$core.override
  LocationContent createEmptyInstance() => create();
  static $pb.PbList<LocationContent> createRepeated() => $pb.PbList<LocationContent>();
  @$core.pragma('dart2js:noInline')
  static LocationContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LocationContent>(create);
  static LocationContent? _defaultInstance;

  /// 纬度：地理位置的纬度坐标
  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => $_clearField(1);

  /// 经度：地理位置的经度坐标
  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => $_clearField(2);

  /// 地址描述：位置的文字描述
  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  /// 地点名称：具体的地点名称
  @$pb.TagNumber(4)
  $core.String get poiName => $_getSZ(3);
  @$pb.TagNumber(4)
  set poiName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPoiName() => $_has(3);
  @$pb.TagNumber(4)
  void clearPoiName() => $_clearField(4);

  /// 缩略图 URL：位置的地图缩略图
  @$pb.TagNumber(5)
  $core.String get thumbnailUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set thumbnailUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasThumbnailUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearThumbnailUrl() => $_clearField(5);
}

/// ===============================
/// 📁 文件消息
/// ===============================
/// 支持任意文件类型，包含文件信息和图标
class FileContent extends $pb.GeneratedMessage {
  factory FileContent({
    $core.String? url,
    $core.String? name,
    $fixnum.Int64? size,
    $core.String? fileType,
    $core.String? iconUrl,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (name != null) result.name = name;
    if (size != null) result.size = size;
    if (fileType != null) result.fileType = fileType;
    if (iconUrl != null) result.iconUrl = iconUrl;
    return result;
  }

  FileContent._();

  factory FileContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory FileContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FileContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aInt64(3, _omitFieldNames ? '' : 'size')
    ..aOS(4, _omitFieldNames ? '' : 'fileType')
    ..aOS(5, _omitFieldNames ? '' : 'iconUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileContent clone() => FileContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileContent copyWith(void Function(FileContent) updates) => super.copyWith((message) => updates(message as FileContent)) as FileContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileContent create() => FileContent._();
  @$core.override
  FileContent createEmptyInstance() => create();
  static $pb.PbList<FileContent> createRepeated() => $pb.PbList<FileContent>();
  @$core.pragma('dart2js:noInline')
  static FileContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileContent>(create);
  static FileContent? _defaultInstance;

  /// 文件 URL：文件的下载地址
  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  /// 文件名：文件的显示名称
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// 文件大小（字节）：文件的大小
  @$pb.TagNumber(3)
  $fixnum.Int64 get size => $_getI64(2);
  @$pb.TagNumber(3)
  set size($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearSize() => $_clearField(3);

  /// 文件类型：文件的 MIME 类型
  @$pb.TagNumber(4)
  $core.String get fileType => $_getSZ(3);
  @$pb.TagNumber(4)
  set fileType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFileType() => $_has(3);
  @$pb.TagNumber(4)
  void clearFileType() => $_clearField(4);

  /// 图标 URL：文件类型的图标
  @$pb.TagNumber(5)
  $core.String get iconUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set iconUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIconUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearIconUrl() => $_clearField(5);
}

/// ===============================
/// 📞 音视频通话信令
/// ===============================
/// 用于音视频通话的控制信令，包含通话状态和参与者信息
class AVCallContent extends $pb.GeneratedMessage {
  factory AVCallContent({
    $core.String? callId,
    $fixnum.Int64? initiatorUid,
    $core.Iterable<$fixnum.Int64>? participantIds,
    AVCallContent_CallAction? action,
    AVCallContent_CallType? type,
    $fixnum.Int64? timestamp,
    $core.int? duration,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (initiatorUid != null) result.initiatorUid = initiatorUid;
    if (participantIds != null) result.participantIds.addAll(participantIds);
    if (action != null) result.action = action;
    if (type != null) result.type = type;
    if (timestamp != null) result.timestamp = timestamp;
    if (duration != null) result.duration = duration;
    return result;
  }

  AVCallContent._();

  factory AVCallContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AVCallContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AVCallContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aInt64(2, _omitFieldNames ? '' : 'initiatorUid')
    ..p<$fixnum.Int64>(3, _omitFieldNames ? '' : 'participantIds', $pb.PbFieldType.K6)
    ..e<AVCallContent_CallAction>(4, _omitFieldNames ? '' : 'action', $pb.PbFieldType.OE, defaultOrMaker: AVCallContent_CallAction.UNKNOWN, valueOf: AVCallContent_CallAction.valueOf, enumValues: AVCallContent_CallAction.values)
    ..e<AVCallContent_CallType>(5, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: AVCallContent_CallType.AUDIO, valueOf: AVCallContent_CallType.valueOf, enumValues: AVCallContent_CallType.values)
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'duration', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AVCallContent clone() => AVCallContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AVCallContent copyWith(void Function(AVCallContent) updates) => super.copyWith((message) => updates(message as AVCallContent)) as AVCallContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AVCallContent create() => AVCallContent._();
  @$core.override
  AVCallContent createEmptyInstance() => create();
  static $pb.PbList<AVCallContent> createRepeated() => $pb.PbList<AVCallContent>();
  @$core.pragma('dart2js:noInline')
  static AVCallContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AVCallContent>(create);
  static AVCallContent? _defaultInstance;

  /// 通话 ID：通话的唯一标识
  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  /// 发起者 ID：通话的发起用户
  @$pb.TagNumber(2)
  $fixnum.Int64 get initiatorUid => $_getI64(1);
  @$pb.TagNumber(2)
  set initiatorUid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInitiatorUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearInitiatorUid() => $_clearField(2);

  /// 参与者 ID 列表：通话的所有参与者
  @$pb.TagNumber(3)
  $pb.PbList<$fixnum.Int64> get participantIds => $_getList(2);

  /// 通话操作：具体的通话动作
  @$pb.TagNumber(4)
  AVCallContent_CallAction get action => $_getN(3);
  @$pb.TagNumber(4)
  set action(AVCallContent_CallAction value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearAction() => $_clearField(4);

  /// 通话类型：通话的类型
  @$pb.TagNumber(5)
  AVCallContent_CallType get type => $_getN(4);
  @$pb.TagNumber(5)
  set type(AVCallContent_CallType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);

  /// 时间戳：操作的时间
  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);

  /// 时长（秒）：通话的持续时间
  @$pb.TagNumber(7)
  $core.int get duration => $_getIZ(6);
  @$pb.TagNumber(7)
  set duration($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDuration() => $_has(6);
  @$pb.TagNumber(7)
  void clearDuration() => $_clearField(7);
}

/// ===============================
/// 💠 自定义结构化消息
/// ===============================
/// 支持开发者自定义的消息结构，通常以 JSON 格式承载
class CustomContent extends $pb.GeneratedMessage {
  factory CustomContent({
    $core.String? customType,
    $core.String? jsonPayload,
  }) {
    final result = create();
    if (customType != null) result.customType = customType;
    if (jsonPayload != null) result.jsonPayload = jsonPayload;
    return result;
  }

  CustomContent._();

  factory CustomContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CustomContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'customType')
    ..aOS(2, _omitFieldNames ? '' : 'jsonPayload')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomContent clone() => CustomContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomContent copyWith(void Function(CustomContent) updates) => super.copyWith((message) => updates(message as CustomContent)) as CustomContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomContent create() => CustomContent._();
  @$core.override
  CustomContent createEmptyInstance() => create();
  static $pb.PbList<CustomContent> createRepeated() => $pb.PbList<CustomContent>();
  @$core.pragma('dart2js:noInline')
  static CustomContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomContent>(create);
  static CustomContent? _defaultInstance;

  /// 自定义类型：消息的自定义类型标识
  @$pb.TagNumber(1)
  $core.String get customType => $_getSZ(0);
  @$pb.TagNumber(1)
  set customType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCustomType() => $_has(0);
  @$pb.TagNumber(1)
  void clearCustomType() => $_clearField(1);

  /// JSON 载荷：自定义消息的 JSON 数据
  @$pb.TagNumber(2)
  $core.String get jsonPayload => $_getSZ(1);
  @$pb.TagNumber(2)
  set jsonPayload($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJsonPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearJsonPayload() => $_clearField(2);
}

/// ===============================
/// 😄 表情消息
/// ===============================
/// 支持标准 emoji 和自定义表情
class EmojiContent extends $pb.GeneratedMessage {
  factory EmojiContent({
    EmojiType? emoji,
    $core.String? customEmojiUrl,
  }) {
    final result = create();
    if (emoji != null) result.emoji = emoji;
    if (customEmojiUrl != null) result.customEmojiUrl = customEmojiUrl;
    return result;
  }

  EmojiContent._();

  factory EmojiContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory EmojiContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EmojiContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..e<EmojiType>(1, _omitFieldNames ? '' : 'emoji', $pb.PbFieldType.OE, defaultOrMaker: EmojiType.EMOJI_UNKNOWN, valueOf: EmojiType.valueOf, enumValues: EmojiType.values)
    ..aOS(2, _omitFieldNames ? '' : 'customEmojiUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EmojiContent clone() => EmojiContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EmojiContent copyWith(void Function(EmojiContent) updates) => super.copyWith((message) => updates(message as EmojiContent)) as EmojiContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EmojiContent create() => EmojiContent._();
  @$core.override
  EmojiContent createEmptyInstance() => create();
  static $pb.PbList<EmojiContent> createRepeated() => $pb.PbList<EmojiContent>();
  @$core.pragma('dart2js:noInline')
  static EmojiContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EmojiContent>(create);
  static EmojiContent? _defaultInstance;

  /// 表情类型：标准 emoji 类型
  @$pb.TagNumber(1)
  EmojiType get emoji => $_getN(0);
  @$pb.TagNumber(1)
  set emoji(EmojiType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEmoji() => $_has(0);
  @$pb.TagNumber(1)
  void clearEmoji() => $_clearField(1);

  /// 自定义表情 URL：自定义表情的图片地址
  @$pb.TagNumber(2)
  $core.String get customEmojiUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set customEmojiUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCustomEmojiUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomEmojiUrl() => $_clearField(2);
}

/// ===============================
/// ⛔ 撤回消息
/// ===============================
/// 用于通知消息撤回，包含撤回的目标消息信息
class RevokeContent extends $pb.GeneratedMessage {
  factory RevokeContent({
    $fixnum.Int64? targetMessageId,
    $fixnum.Int64? operatorId,
    $fixnum.Int64? revokeTime,
  }) {
    final result = create();
    if (targetMessageId != null) result.targetMessageId = targetMessageId;
    if (operatorId != null) result.operatorId = operatorId;
    if (revokeTime != null) result.revokeTime = revokeTime;
    return result;
  }

  RevokeContent._();

  factory RevokeContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RevokeContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RevokeContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'targetMessageId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorId')
    ..aInt64(3, _omitFieldNames ? '' : 'revokeTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeContent clone() => RevokeContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeContent copyWith(void Function(RevokeContent) updates) => super.copyWith((message) => updates(message as RevokeContent)) as RevokeContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeContent create() => RevokeContent._();
  @$core.override
  RevokeContent createEmptyInstance() => create();
  static $pb.PbList<RevokeContent> createRepeated() => $pb.PbList<RevokeContent>();
  @$core.pragma('dart2js:noInline')
  static RevokeContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevokeContent>(create);
  static RevokeContent? _defaultInstance;

  /// 目标消息 ID：被撤回的消息ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get targetMessageId => $_getI64(0);
  @$pb.TagNumber(1)
  set targetMessageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetMessageId() => $_clearField(1);

  /// 操作者 ID：执行撤回操作的用户
  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorId() => $_clearField(2);

  /// 撤回时间：撤回操作的时间戳
  @$pb.TagNumber(3)
  $fixnum.Int64 get revokeTime => $_getI64(2);
  @$pb.TagNumber(3)
  set revokeTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevokeTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevokeTime() => $_clearField(3);
}

/// ===============================
/// 📤 转发消息
/// ===============================
/// 用于消息转发，包含原消息的基本信息
class ForwardContent extends $pb.GeneratedMessage {
  factory ForwardContent({
    $fixnum.Int64? originalMessageId,
    $core.String? originalSenderId,
    $0.MsgKind? originalKind,
    $core.String? summary,
  }) {
    final result = create();
    if (originalMessageId != null) result.originalMessageId = originalMessageId;
    if (originalSenderId != null) result.originalSenderId = originalSenderId;
    if (originalKind != null) result.originalKind = originalKind;
    if (summary != null) result.summary = summary;
    return result;
  }

  ForwardContent._();

  factory ForwardContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ForwardContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ForwardContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'originalMessageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'originalSenderId')
    ..e<$0.MsgKind>(3, _omitFieldNames ? '' : 'originalKind', $pb.PbFieldType.OE, defaultOrMaker: $0.MsgKind.MK_UNKNOWN, valueOf: $0.MsgKind.valueOf, enumValues: $0.MsgKind.values)
    ..aOS(4, _omitFieldNames ? '' : 'summary')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardContent clone() => ForwardContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardContent copyWith(void Function(ForwardContent) updates) => super.copyWith((message) => updates(message as ForwardContent)) as ForwardContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardContent create() => ForwardContent._();
  @$core.override
  ForwardContent createEmptyInstance() => create();
  static $pb.PbList<ForwardContent> createRepeated() => $pb.PbList<ForwardContent>();
  @$core.pragma('dart2js:noInline')
  static ForwardContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ForwardContent>(create);
  static ForwardContent? _defaultInstance;

  /// 原消息 ID：被转发消息的ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get originalMessageId => $_getI64(0);
  @$pb.TagNumber(1)
  set originalMessageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOriginalMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOriginalMessageId() => $_clearField(1);

  /// 原发送者 ID：原消息的发送者
  @$pb.TagNumber(2)
  $core.String get originalSenderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set originalSenderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOriginalSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOriginalSenderId() => $_clearField(2);

  /// 原消息类型：原消息的 MsgKind
  @$pb.TagNumber(3)
  $0.MsgKind get originalKind => $_getN(2);
  @$pb.TagNumber(3)
  set originalKind($0.MsgKind value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOriginalKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearOriginalKind() => $_clearField(3);

  /// 摘要：转发的摘要信息
  @$pb.TagNumber(4)
  $core.String get summary => $_getSZ(3);
  @$pb.TagNumber(4)
  set summary($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSummary() => $_has(3);
  @$pb.TagNumber(4)
  void clearSummary() => $_clearField(4);
}

/// ===============================
/// 📌 引用回复消息
/// ===============================
/// 用于回复特定消息，包含被引用消息的信息
class QuoteContent extends $pb.GeneratedMessage {
  factory QuoteContent({
    $fixnum.Int64? quotedMessageId,
    $core.String? quotedContentPreview,
    $core.String? quoteText,
  }) {
    final result = create();
    if (quotedMessageId != null) result.quotedMessageId = quotedMessageId;
    if (quotedContentPreview != null) result.quotedContentPreview = quotedContentPreview;
    if (quoteText != null) result.quoteText = quoteText;
    return result;
  }

  QuoteContent._();

  factory QuoteContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory QuoteContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'QuoteContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'quotedMessageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'quotedContentPreview')
    ..aOS(3, _omitFieldNames ? '' : 'quoteText')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuoteContent clone() => QuoteContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuoteContent copyWith(void Function(QuoteContent) updates) => super.copyWith((message) => updates(message as QuoteContent)) as QuoteContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuoteContent create() => QuoteContent._();
  @$core.override
  QuoteContent createEmptyInstance() => create();
  static $pb.PbList<QuoteContent> createRepeated() => $pb.PbList<QuoteContent>();
  @$core.pragma('dart2js:noInline')
  static QuoteContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuoteContent>(create);
  static QuoteContent? _defaultInstance;

  /// 被引用消息 ID：被回复消息的ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get quotedMessageId => $_getI64(0);
  @$pb.TagNumber(1)
  set quotedMessageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuotedMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuotedMessageId() => $_clearField(1);

  /// 被引用内容预览：被回复消息的预览
  @$pb.TagNumber(2)
  $core.String get quotedContentPreview => $_getSZ(1);
  @$pb.TagNumber(2)
  set quotedContentPreview($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuotedContentPreview() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuotedContentPreview() => $_clearField(2);

  /// 引用文本：回复的文本内容
  @$pb.TagNumber(3)
  $core.String get quoteText => $_getSZ(2);
  @$pb.TagNumber(3)
  set quoteText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuoteText() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuoteText() => $_clearField(3);
}

/// ===============================
/// 🌐 HTML 卡片
/// ===============================
/// 用于富文本内容，支持网页链接和预览
class HtmlContent extends $pb.GeneratedMessage {
  factory HtmlContent({
    $core.String? title,
    $core.String? url,
    $core.String? preview,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (url != null) result.url = url;
    if (preview != null) result.preview = preview;
    return result;
  }

  HtmlContent._();

  factory HtmlContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory HtmlContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HtmlContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..aOS(3, _omitFieldNames ? '' : 'preview')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HtmlContent clone() => HtmlContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HtmlContent copyWith(void Function(HtmlContent) updates) => super.copyWith((message) => updates(message as HtmlContent)) as HtmlContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HtmlContent create() => HtmlContent._();
  @$core.override
  HtmlContent createEmptyInstance() => create();
  static $pb.PbList<HtmlContent> createRepeated() => $pb.PbList<HtmlContent>();
  @$core.pragma('dart2js:noInline')
  static HtmlContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HtmlContent>(create);
  static HtmlContent? _defaultInstance;

  /// 标题：卡片的标题
  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  /// URL：链接地址
  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

  /// 预览：内容的预览文本
  @$pb.TagNumber(3)
  $core.String get preview => $_getSZ(2);
  @$pb.TagNumber(3)
  set preview($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPreview() => $_has(2);
  @$pb.TagNumber(3)
  void clearPreview() => $_clearField(3);
}

/// ===============================
/// 📞 VOIP 通话记录
/// ===============================
/// 用于记录通话历史，包含通话的基本信息
class VoipContent extends $pb.GeneratedMessage {
  factory VoipContent({
    $core.String? callerId,
    $core.String? calleeId,
    $fixnum.Int64? duration,
    $core.String? status,
  }) {
    final result = create();
    if (callerId != null) result.callerId = callerId;
    if (calleeId != null) result.calleeId = calleeId;
    if (duration != null) result.duration = duration;
    if (status != null) result.status = status;
    return result;
  }

  VoipContent._();

  factory VoipContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory VoipContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoipContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callerId')
    ..aOS(2, _omitFieldNames ? '' : 'calleeId')
    ..aInt64(3, _omitFieldNames ? '' : 'duration')
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoipContent clone() => VoipContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoipContent copyWith(void Function(VoipContent) updates) => super.copyWith((message) => updates(message as VoipContent)) as VoipContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoipContent create() => VoipContent._();
  @$core.override
  VoipContent createEmptyInstance() => create();
  static $pb.PbList<VoipContent> createRepeated() => $pb.PbList<VoipContent>();
  @$core.pragma('dart2js:noInline')
  static VoipContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoipContent>(create);
  static VoipContent? _defaultInstance;

  /// 主叫 ID：发起通话的用户
  @$pb.TagNumber(1)
  $core.String get callerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallerId() => $_clearField(1);

  /// 被叫 ID：接收通话的用户
  @$pb.TagNumber(2)
  $core.String get calleeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set calleeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCalleeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCalleeId() => $_clearField(2);

  /// 通话时长（秒）：通话的持续时间
  @$pb.TagNumber(3)
  $fixnum.Int64 get duration => $_getI64(2);
  @$pb.TagNumber(3)
  set duration($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDuration() => $_has(2);
  @$pb.TagNumber(3)
  void clearDuration() => $_clearField(3);

  /// 通话状态：通话的结果状态
  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);
}

/// ===============================
/// 🔔 通知消息
/// ===============================
/// 用于系统通知，包含标题、内容和元数据
class NotificationContent extends $pb.GeneratedMessage {
  factory NotificationContent({
    $core.String? title,
    $core.String? body,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (body != null) result.body = body;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  NotificationContent._();

  factory NotificationContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory NotificationContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NotificationContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'body')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'metadata', entryClassName: 'NotificationContent.MetadataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('message'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationContent clone() => NotificationContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationContent copyWith(void Function(NotificationContent) updates) => super.copyWith((message) => updates(message as NotificationContent)) as NotificationContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationContent create() => NotificationContent._();
  @$core.override
  NotificationContent createEmptyInstance() => create();
  static $pb.PbList<NotificationContent> createRepeated() => $pb.PbList<NotificationContent>();
  @$core.pragma('dart2js:noInline')
  static NotificationContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NotificationContent>(create);
  static NotificationContent? _defaultInstance;

  /// 标题：通知的标题
  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  /// 内容：通知的主体内容
  @$pb.TagNumber(2)
  $core.String get body => $_getSZ(1);
  @$pb.TagNumber(2)
  set body($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);

  /// 元数据：通知的附加信息
  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(2);
}

/// ===============================
/// ⚙️ 系统消息
/// ===============================
/// 用于系统级消息，包含系统代码和内容
class SystemContent extends $pb.GeneratedMessage {
  factory SystemContent({
    $core.String? content,
    $core.String? code,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (code != null) result.code = code;
    return result;
  }

  SystemContent._();

  factory SystemContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory SystemContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SystemContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'content')
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemContent clone() => SystemContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemContent copyWith(void Function(SystemContent) updates) => super.copyWith((message) => updates(message as SystemContent)) as SystemContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemContent create() => SystemContent._();
  @$core.override
  SystemContent createEmptyInstance() => create();
  static $pb.PbList<SystemContent> createRepeated() => $pb.PbList<SystemContent>();
  @$core.pragma('dart2js:noInline')
  static SystemContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SystemContent>(create);
  static SystemContent? _defaultInstance;

  /// 内容：系统消息的内容
  @$pb.TagNumber(1)
  $core.String get content => $_getSZ(0);
  @$pb.TagNumber(1)
  set content($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);

  /// 代码：系统消息的代码标识
  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);
}

/// ===============================
/// ⏰ 提醒事项
/// ===============================
/// 用于提醒功能，包含提醒文本和时间
class ReminderContent extends $pb.GeneratedMessage {
  factory ReminderContent({
    $core.String? text,
    $fixnum.Int64? remindAt,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (remindAt != null) result.remindAt = remindAt;
    return result;
  }

  ReminderContent._();

  factory ReminderContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ReminderContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReminderContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aInt64(2, _omitFieldNames ? '' : 'remindAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReminderContent clone() => ReminderContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReminderContent copyWith(void Function(ReminderContent) updates) => super.copyWith((message) => updates(message as ReminderContent)) as ReminderContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReminderContent create() => ReminderContent._();
  @$core.override
  ReminderContent createEmptyInstance() => create();
  static $pb.PbList<ReminderContent> createRepeated() => $pb.PbList<ReminderContent>();
  @$core.pragma('dart2js:noInline')
  static ReminderContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReminderContent>(create);
  static ReminderContent? _defaultInstance;

  /// 文本：提醒的内容
  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  /// 提醒时间：提醒触发的时间戳
  @$pb.TagNumber(2)
  $fixnum.Int64 get remindAt => $_getI64(1);
  @$pb.TagNumber(2)
  set remindAt($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRemindAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemindAt() => $_clearField(2);
}

/// ===============================
/// 👥 群组事件
/// ===============================
/// 用于群组相关事件，包含群组信息和操作者
class GroupEventContent extends $pb.GeneratedMessage {
  factory GroupEventContent({
    $fixnum.Int64? groupId,
    $core.String? event,
    $fixnum.Int64? operatorId,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (event != null) result.event = event;
    if (operatorId != null) result.operatorId = operatorId;
    return result;
  }

  GroupEventContent._();

  factory GroupEventContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory GroupEventContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupEventContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aOS(2, _omitFieldNames ? '' : 'event')
    ..aInt64(3, _omitFieldNames ? '' : 'operatorId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupEventContent clone() => GroupEventContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupEventContent copyWith(void Function(GroupEventContent) updates) => super.copyWith((message) => updates(message as GroupEventContent)) as GroupEventContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupEventContent create() => GroupEventContent._();
  @$core.override
  GroupEventContent createEmptyInstance() => create();
  static $pb.PbList<GroupEventContent> createRepeated() => $pb.PbList<GroupEventContent>();
  @$core.pragma('dart2js:noInline')
  static GroupEventContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupEventContent>(create);
  static GroupEventContent? _defaultInstance;

  /// 群组 ID：事件相关的群组
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 事件：事件的具体描述
  @$pb.TagNumber(2)
  $core.String get event => $_getSZ(1);
  @$pb.TagNumber(2)
  set event($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField(2);

  /// 操作者 ID：执行操作的用户
  @$pb.TagNumber(3)
  $fixnum.Int64 get operatorId => $_getI64(2);
  @$pb.TagNumber(3)
  set operatorId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOperatorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOperatorId() => $_clearField(3);
}

/// ===============================
/// 📇 名片消息
/// ===============================
/// 用于分享联系人信息，包含用户的基本信息
class ContactCardContent extends $pb.GeneratedMessage {
  factory ContactCardContent({
    $core.String? targetId,
    $core.String? displayName,
    $core.String? avatarUrl,
    $core.String? cardType,
  }) {
    final result = create();
    if (targetId != null) result.targetId = targetId;
    if (displayName != null) result.displayName = displayName;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (cardType != null) result.cardType = cardType;
    return result;
  }

  ContactCardContent._();

  factory ContactCardContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ContactCardContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactCardContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'targetId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(4, _omitFieldNames ? '' : 'cardType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContactCardContent clone() => ContactCardContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContactCardContent copyWith(void Function(ContactCardContent) updates) => super.copyWith((message) => updates(message as ContactCardContent)) as ContactCardContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactCardContent create() => ContactCardContent._();
  @$core.override
  ContactCardContent createEmptyInstance() => create();
  static $pb.PbList<ContactCardContent> createRepeated() => $pb.PbList<ContactCardContent>();
  @$core.pragma('dart2js:noInline')
  static ContactCardContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactCardContent>(create);
  static ContactCardContent? _defaultInstance;

  /// 目标 ID：被分享用户的ID
  @$pb.TagNumber(1)
  $core.String get targetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetId() => $_clearField(1);

  /// 显示名称：用户的显示名称
  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  /// 头像 URL：用户的头像地址
  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => $_clearField(3);

  /// 卡片类型：名片的类型（用户/群组）
  @$pb.TagNumber(4)
  $core.String get cardType => $_getSZ(3);
  @$pb.TagNumber(4)
  set cardType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCardType() => $_has(3);
  @$pb.TagNumber(4)
  void clearCardType() => $_clearField(4);
}

/// ===============================
/// 📊 投票消息
/// ===============================
/// 用于群组投票功能，包含投票选项和结果
class VoteContent extends $pb.GeneratedMessage {
  factory VoteContent({
    $core.String? topic,
    $core.Iterable<$core.String>? options,
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? result,
    $core.bool? multiChoice,
  }) {
    final result$ = create();
    if (topic != null) result$.topic = topic;
    if (options != null) result$.options.addAll(options);
    if (result != null) result$.result.addEntries(result);
    if (multiChoice != null) result$.multiChoice = multiChoice;
    return result$;
  }

  VoteContent._();

  factory VoteContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory VoteContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'topic')
    ..pPS(2, _omitFieldNames ? '' : 'options')
    ..m<$core.String, $core.int>(3, _omitFieldNames ? '' : 'result', entryClassName: 'VoteContent.ResultEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O3, packageName: const $pb.PackageName('message'))
    ..aOB(4, _omitFieldNames ? '' : 'multiChoice')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteContent clone() => VoteContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoteContent copyWith(void Function(VoteContent) updates) => super.copyWith((message) => updates(message as VoteContent)) as VoteContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteContent create() => VoteContent._();
  @$core.override
  VoteContent createEmptyInstance() => create();
  static $pb.PbList<VoteContent> createRepeated() => $pb.PbList<VoteContent>();
  @$core.pragma('dart2js:noInline')
  static VoteContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoteContent>(create);
  static VoteContent? _defaultInstance;

  /// 主题：投票的主题
  @$pb.TagNumber(1)
  $core.String get topic => $_getSZ(0);
  @$pb.TagNumber(1)
  set topic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTopic() => $_has(0);
  @$pb.TagNumber(1)
  void clearTopic() => $_clearField(1);

  /// 选项：投票的选项列表
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get options => $_getList(1);

  /// 结果：投票结果统计
  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.int> get result => $_getMap(2);

  /// 多选：是否允许多选
  @$pb.TagNumber(4)
  $core.bool get multiChoice => $_getBF(3);
  @$pb.TagNumber(4)
  set multiChoice($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMultiChoice() => $_has(3);
  @$pb.TagNumber(4)
  void clearMultiChoice() => $_clearField(4);
}

/// ===============================
/// 💰 红包消息
/// ===============================
/// 用于红包功能，包含红包金额和状态
class RedEnvelopeContent extends $pb.GeneratedMessage {
  factory RedEnvelopeContent({
    $fixnum.Int64? senderId,
    $core.int? amount,
    $core.String? blessing,
    $core.bool? claimed,
  }) {
    final result = create();
    if (senderId != null) result.senderId = senderId;
    if (amount != null) result.amount = amount;
    if (blessing != null) result.blessing = blessing;
    if (claimed != null) result.claimed = claimed;
    return result;
  }

  RedEnvelopeContent._();

  factory RedEnvelopeContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RedEnvelopeContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RedEnvelopeContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'senderId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'blessing')
    ..aOB(4, _omitFieldNames ? '' : 'claimed')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RedEnvelopeContent clone() => RedEnvelopeContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RedEnvelopeContent copyWith(void Function(RedEnvelopeContent) updates) => super.copyWith((message) => updates(message as RedEnvelopeContent)) as RedEnvelopeContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RedEnvelopeContent create() => RedEnvelopeContent._();
  @$core.override
  RedEnvelopeContent createEmptyInstance() => create();
  static $pb.PbList<RedEnvelopeContent> createRepeated() => $pb.PbList<RedEnvelopeContent>();
  @$core.pragma('dart2js:noInline')
  static RedEnvelopeContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RedEnvelopeContent>(create);
  static RedEnvelopeContent? _defaultInstance;

  /// 发送者 ID：红包发送者
  @$pb.TagNumber(1)
  $fixnum.Int64 get senderId => $_getI64(0);
  @$pb.TagNumber(1)
  set senderId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSenderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSenderId() => $_clearField(1);

  /// 金额：红包金额（分）
  @$pb.TagNumber(2)
  $core.int get amount => $_getIZ(1);
  @$pb.TagNumber(2)
  set amount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  /// 祝福语：红包的祝福语
  @$pb.TagNumber(3)
  $core.String get blessing => $_getSZ(2);
  @$pb.TagNumber(3)
  set blessing($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlessing() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlessing() => $_clearField(3);

  /// 是否已领取：红包是否已被领取
  @$pb.TagNumber(4)
  $core.bool get claimed => $_getBF(3);
  @$pb.TagNumber(4)
  set claimed($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClaimed() => $_has(3);
  @$pb.TagNumber(4)
  void clearClaimed() => $_clearField(4);
}

/// ======================================
/// ✂️ Segment - 消息段结构（用于复合内容）
/// ======================================
/// 表示一条消息中的一个独立段（如文本段、图片段等），支持排序、编辑、标记等
class Segment extends $pb.GeneratedMessage {
  factory Segment({
    MessageContent? body,
    $fixnum.Int64? seqInMsg,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (body != null) result.body = body;
    if (seqInMsg != null) result.seqInMsg = seqInMsg;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  Segment._();

  factory Segment.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory Segment.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Segment', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOM<MessageContent>(1, _omitFieldNames ? '' : 'body', subBuilder: MessageContent.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'seqInMsg', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'metadata', entryClassName: 'Segment.MetadataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('message'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Segment clone() => Segment()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Segment copyWith(void Function(Segment) updates) => super.copyWith((message) => updates(message as Segment)) as Segment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Segment create() => Segment._();
  @$core.override
  Segment createEmptyInstance() => create();
  static $pb.PbList<Segment> createRepeated() => $pb.PbList<Segment>();
  @$core.pragma('dart2js:noInline')
  static Segment getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Segment>(create);
  static Segment? _defaultInstance;

  /// 消息段内容（如文本、图片等，使用 oneof 封装）：段的具体内容
  @$pb.TagNumber(1)
  MessageContent get body => $_getN(0);
  @$pb.TagNumber(1)
  set body(MessageContent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBody() => $_has(0);
  @$pb.TagNumber(1)
  void clearBody() => $_clearField(1);
  @$pb.TagNumber(1)
  MessageContent ensureBody() => $_ensure(0);

  /// 消息内顺序编号（用于前端渲染排序）：段在消息中的顺序
  @$pb.TagNumber(2)
  $fixnum.Int64 get seqInMsg => $_getI64(1);
  @$pb.TagNumber(2)
  set seqInMsg($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeqInMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeqInMsg() => $_clearField(2);

  /// 通用扩展字段（以字符串键值对存储 JSON 扁平数据）：段的元数据
  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(2);
}

/// ======================================
/// 📨 顶层消息结构
/// ======================================
/// 定义了消息的基本框架，包含发送者、接收者、时间等元数据
class Content extends $pb.GeneratedMessage {
  factory Content({
    $fixnum.Int64? messageId,
    $fixnum.Int64? senderId,
    $fixnum.Int64? receiverId,
    $fixnum.Int64? timestamp,
    $0.MsgKind? msgKind,
    ChatScene? scene,
    $core.Iterable<MessageContent>? contents,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (senderId != null) result.senderId = senderId;
    if (receiverId != null) result.receiverId = receiverId;
    if (timestamp != null) result.timestamp = timestamp;
    if (msgKind != null) result.msgKind = msgKind;
    if (scene != null) result.scene = scene;
    if (contents != null) result.contents.addAll(contents);
    return result;
  }

  Content._();

  factory Content.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory Content.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Content', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(2, _omitFieldNames ? '' : 'senderId')
    ..aInt64(3, _omitFieldNames ? '' : 'receiverId')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..e<$0.MsgKind>(5, _omitFieldNames ? '' : 'msgKind', $pb.PbFieldType.OE, defaultOrMaker: $0.MsgKind.MK_UNKNOWN, valueOf: $0.MsgKind.valueOf, enumValues: $0.MsgKind.values)
    ..e<ChatScene>(6, _omitFieldNames ? '' : 'scene', $pb.PbFieldType.OE, defaultOrMaker: ChatScene.CHAT_UNKNOWN, valueOf: ChatScene.valueOf, enumValues: ChatScene.values)
    ..pc<MessageContent>(10, _omitFieldNames ? '' : 'contents', $pb.PbFieldType.PM, subBuilder: MessageContent.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Content clone() => Content()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Content copyWith(void Function(Content) updates) => super.copyWith((message) => updates(message as Content)) as Content;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Content create() => Content._();
  @$core.override
  Content createEmptyInstance() => create();
  static $pb.PbList<Content> createRepeated() => $pb.PbList<Content>();
  @$core.pragma('dart2js:noInline')
  static Content getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Content>(create);
  static Content? _defaultInstance;

  /// 唯一消息 ID（客户端生成或服务端补全）：消息的唯一标识
  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  /// 消息发送方：发送消息的用户ID
  @$pb.TagNumber(2)
  $fixnum.Int64 get senderId => $_getI64(1);
  @$pb.TagNumber(2)
  set senderId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderId() => $_clearField(2);

  /// 消息接收方（单聊为对方 ID，群聊为群 ID）：接收消息的目标
  @$pb.TagNumber(3)
  $fixnum.Int64 get receiverId => $_getI64(2);
  @$pb.TagNumber(3)
  set receiverId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReceiverId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReceiverId() => $_clearField(3);

  /// 消息发送时间（毫秒时间戳）：消息创建的时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);

  /// 主消息类型（socket 层 MsgKind，用于快速渲染判断）
  @$pb.TagNumber(5)
  $0.MsgKind get msgKind => $_getN(4);
  @$pb.TagNumber(5)
  set msgKind($0.MsgKind value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasMsgKind() => $_has(4);
  @$pb.TagNumber(5)
  void clearMsgKind() => $_clearField(5);

  /// 消息所属会话类型（单聊/群聊）：消息的会话场景
  @$pb.TagNumber(6)
  ChatScene get scene => $_getN(5);
  @$pb.TagNumber(6)
  set scene(ChatScene value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasScene() => $_has(5);
  @$pb.TagNumber(6)
  void clearScene() => $_clearField(6);

  /// 多段复合内容（如文本 + 图片）：消息的具体内容
  @$pb.TagNumber(10)
  $pb.PbList<MessageContent> get contents => $_getList(6);
}

/// 发起呼叫（带 SDP offer）
class CallInvite extends $pb.GeneratedMessage {
  factory CallInvite({
    $core.String? callId,
    $fixnum.Int64? fromUserId,
    $fixnum.Int64? toUserId,
    CallMediaType? mediaType,
    $core.String? sdpOffer,
    $core.String? ext,
    $fixnum.Int64? createdAt,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (toUserId != null) result.toUserId = toUserId;
    if (mediaType != null) result.mediaType = mediaType;
    if (sdpOffer != null) result.sdpOffer = sdpOffer;
    if (ext != null) result.ext = ext;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  CallInvite._();

  factory CallInvite.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CallInvite.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallInvite', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aInt64(2, _omitFieldNames ? '' : 'fromUserId')
    ..aInt64(3, _omitFieldNames ? '' : 'toUserId')
    ..e<CallMediaType>(4, _omitFieldNames ? '' : 'mediaType', $pb.PbFieldType.OE, defaultOrMaker: CallMediaType.CALL_AUDIO, valueOf: CallMediaType.valueOf, enumValues: CallMediaType.values)
    ..aOS(5, _omitFieldNames ? '' : 'sdpOffer')
    ..aOS(6, _omitFieldNames ? '' : 'ext')
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'createdAt', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallInvite clone() => CallInvite()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallInvite copyWith(void Function(CallInvite) updates) => super.copyWith((message) => updates(message as CallInvite)) as CallInvite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallInvite create() => CallInvite._();
  @$core.override
  CallInvite createEmptyInstance() => create();
  static $pb.PbList<CallInvite> createRepeated() => $pb.PbList<CallInvite>();
  @$core.pragma('dart2js:noInline')
  static CallInvite getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallInvite>(create);
  static CallInvite? _defaultInstance;

  /// 通话ID（全局唯一字符串/雪花）
  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  /// 主叫用户ID
  @$pb.TagNumber(2)
  $fixnum.Int64 get fromUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set fromUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromUserId() => $_clearField(2);

  /// 被叫用户ID
  @$pb.TagNumber(3)
  $fixnum.Int64 get toUserId => $_getI64(2);
  @$pb.TagNumber(3)
  set toUserId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearToUserId() => $_clearField(3);

  /// 媒体类型（语音/视频）
  @$pb.TagNumber(4)
  CallMediaType get mediaType => $_getN(3);
  @$pb.TagNumber(4)
  set mediaType(CallMediaType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMediaType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMediaType() => $_clearField(4);

  /// SDP offer（若使用 WebRTC）
  @$pb.TagNumber(5)
  $core.String get sdpOffer => $_getSZ(4);
  @$pb.TagNumber(5)
  set sdpOffer($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSdpOffer() => $_has(4);
  @$pb.TagNumber(5)
  void clearSdpOffer() => $_clearField(5);

  /// 扩展字段
  @$pb.TagNumber(6)
  $core.String get ext => $_getSZ(5);
  @$pb.TagNumber(6)
  set ext($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExt() => $_has(5);
  @$pb.TagNumber(6)
  void clearExt() => $_clearField(6);

  /// 发起时间
  @$pb.TagNumber(7)
  $fixnum.Int64 get createdAt => $_getI64(6);
  @$pb.TagNumber(7)
  set createdAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
}

/// 取消呼叫（振铃阶段）
class CallCancel extends $pb.GeneratedMessage {
  factory CallCancel({
    $core.String? callId,
    $fixnum.Int64? operatorUserId,
    $core.String? reason,
    $fixnum.Int64? at,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (operatorUserId != null) result.operatorUserId = operatorUserId;
    if (reason != null) result.reason = reason;
    if (at != null) result.at = at;
    return result;
  }

  CallCancel._();

  factory CallCancel.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CallCancel.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallCancel', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorUserId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'at', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallCancel clone() => CallCancel()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallCancel copyWith(void Function(CallCancel) updates) => super.copyWith((message) => updates(message as CallCancel)) as CallCancel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallCancel create() => CallCancel._();
  @$core.override
  CallCancel createEmptyInstance() => create();
  static $pb.PbList<CallCancel> createRepeated() => $pb.PbList<CallCancel>();
  @$core.pragma('dart2js:noInline')
  static CallCancel getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallCancel>(create);
  static CallCancel? _defaultInstance;

  /// 通话ID
  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  /// 操作者
  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorUserId() => $_clearField(2);

  /// 原因（可选）
  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);

  /// 时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get at => $_getI64(3);
  @$pb.TagNumber(4)
  set at($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearAt() => $_clearField(4);
}

/// 拒绝呼叫
class CallReject extends $pb.GeneratedMessage {
  factory CallReject({
    $core.String? callId,
    $fixnum.Int64? rejectUserId,
    $core.String? reason,
    $fixnum.Int64? at,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (rejectUserId != null) result.rejectUserId = rejectUserId;
    if (reason != null) result.reason = reason;
    if (at != null) result.at = at;
    return result;
  }

  CallReject._();

  factory CallReject.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CallReject.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallReject', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aInt64(2, _omitFieldNames ? '' : 'rejectUserId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'at', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallReject clone() => CallReject()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallReject copyWith(void Function(CallReject) updates) => super.copyWith((message) => updates(message as CallReject)) as CallReject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallReject create() => CallReject._();
  @$core.override
  CallReject createEmptyInstance() => create();
  static $pb.PbList<CallReject> createRepeated() => $pb.PbList<CallReject>();
  @$core.pragma('dart2js:noInline')
  static CallReject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallReject>(create);
  static CallReject? _defaultInstance;

  /// 通话ID
  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  /// 拒绝者
  @$pb.TagNumber(2)
  $fixnum.Int64 get rejectUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set rejectUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRejectUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRejectUserId() => $_clearField(2);

  /// 原因（可选）
  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);

  /// 时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get at => $_getI64(3);
  @$pb.TagNumber(4)
  set at($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearAt() => $_clearField(4);
}

/// 接受呼叫（带 SDP answer）
class CallAccept extends $pb.GeneratedMessage {
  factory CallAccept({
    $core.String? callId,
    $fixnum.Int64? acceptUserId,
    $core.String? sdpAnswer,
    $fixnum.Int64? at,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (acceptUserId != null) result.acceptUserId = acceptUserId;
    if (sdpAnswer != null) result.sdpAnswer = sdpAnswer;
    if (at != null) result.at = at;
    return result;
  }

  CallAccept._();

  factory CallAccept.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CallAccept.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallAccept', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aInt64(2, _omitFieldNames ? '' : 'acceptUserId')
    ..aOS(3, _omitFieldNames ? '' : 'sdpAnswer')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'at', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallAccept clone() => CallAccept()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallAccept copyWith(void Function(CallAccept) updates) => super.copyWith((message) => updates(message as CallAccept)) as CallAccept;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallAccept create() => CallAccept._();
  @$core.override
  CallAccept createEmptyInstance() => create();
  static $pb.PbList<CallAccept> createRepeated() => $pb.PbList<CallAccept>();
  @$core.pragma('dart2js:noInline')
  static CallAccept getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallAccept>(create);
  static CallAccept? _defaultInstance;

  /// 通话ID
  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  /// 接受者
  @$pb.TagNumber(2)
  $fixnum.Int64 get acceptUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set acceptUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAcceptUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAcceptUserId() => $_clearField(2);

  /// SDP answer（若使用 WebRTC）
  @$pb.TagNumber(3)
  $core.String get sdpAnswer => $_getSZ(2);
  @$pb.TagNumber(3)
  set sdpAnswer($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSdpAnswer() => $_has(2);
  @$pb.TagNumber(3)
  void clearSdpAnswer() => $_clearField(3);

  /// 时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get at => $_getI64(3);
  @$pb.TagNumber(4)
  set at($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearAt() => $_clearField(4);
}

/// 通话结束/挂断
class CallHangup extends $pb.GeneratedMessage {
  factory CallHangup({
    $core.String? callId,
    $fixnum.Int64? operatorUserId,
    CallEndReason? reason,
    $fixnum.Int64? durationMs,
    $fixnum.Int64? at,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (operatorUserId != null) result.operatorUserId = operatorUserId;
    if (reason != null) result.reason = reason;
    if (durationMs != null) result.durationMs = durationMs;
    if (at != null) result.at = at;
    return result;
  }

  CallHangup._();

  factory CallHangup.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CallHangup.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallHangup', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorUserId')
    ..e<CallEndReason>(3, _omitFieldNames ? '' : 'reason', $pb.PbFieldType.OE, defaultOrMaker: CallEndReason.CER_UNSPECIFIED, valueOf: CallEndReason.valueOf, enumValues: CallEndReason.values)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'durationMs', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'at', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallHangup clone() => CallHangup()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallHangup copyWith(void Function(CallHangup) updates) => super.copyWith((message) => updates(message as CallHangup)) as CallHangup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallHangup create() => CallHangup._();
  @$core.override
  CallHangup createEmptyInstance() => create();
  static $pb.PbList<CallHangup> createRepeated() => $pb.PbList<CallHangup>();
  @$core.pragma('dart2js:noInline')
  static CallHangup getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallHangup>(create);
  static CallHangup? _defaultInstance;

  /// 通话ID
  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  /// 操作者
  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorUserId() => $_clearField(2);

  /// 结束原因
  @$pb.TagNumber(3)
  CallEndReason get reason => $_getN(2);
  @$pb.TagNumber(3)
  set reason(CallEndReason value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);

  /// 通话时长（毫秒，可选）
  @$pb.TagNumber(4)
  $fixnum.Int64 get durationMs => $_getI64(3);
  @$pb.TagNumber(4)
  set durationMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDurationMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearDurationMs() => $_clearField(4);

  /// 时间
  @$pb.TagNumber(5)
  $fixnum.Int64 get at => $_getI64(4);
  @$pb.TagNumber(5)
  set at($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearAt() => $_clearField(5);
}

/// 通话中修改（静音/开关摄像头等）
class CallModify extends $pb.GeneratedMessage {
  factory CallModify({
    $core.String? callId,
    $fixnum.Int64? operatorUserId,
    CallModifyType? modify,
    $core.bool? on,
    $fixnum.Int64? at,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (operatorUserId != null) result.operatorUserId = operatorUserId;
    if (modify != null) result.modify = modify;
    if (on != null) result.on = on;
    if (at != null) result.at = at;
    return result;
  }

  CallModify._();

  factory CallModify.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CallModify.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallModify', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorUserId')
    ..e<CallModifyType>(3, _omitFieldNames ? '' : 'modify', $pb.PbFieldType.OE, defaultOrMaker: CallModifyType.CMT_UNSPECIFIED, valueOf: CallModifyType.valueOf, enumValues: CallModifyType.values)
    ..aOB(4, _omitFieldNames ? '' : 'on')
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'at', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallModify clone() => CallModify()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallModify copyWith(void Function(CallModify) updates) => super.copyWith((message) => updates(message as CallModify)) as CallModify;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallModify create() => CallModify._();
  @$core.override
  CallModify createEmptyInstance() => create();
  static $pb.PbList<CallModify> createRepeated() => $pb.PbList<CallModify>();
  @$core.pragma('dart2js:noInline')
  static CallModify getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallModify>(create);
  static CallModify? _defaultInstance;

  /// 通话ID
  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  /// 操作者
  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorUserId() => $_clearField(2);

  /// 修改类型
  @$pb.TagNumber(3)
  CallModifyType get modify => $_getN(2);
  @$pb.TagNumber(3)
  set modify(CallModifyType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasModify() => $_has(2);
  @$pb.TagNumber(3)
  void clearModify() => $_clearField(3);

  /// 开关值（true=开/启用，false=关/禁用）
  @$pb.TagNumber(4)
  $core.bool get on => $_getBF(3);
  @$pb.TagNumber(4)
  set on($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOn() => $_has(3);
  @$pb.TagNumber(4)
  void clearOn() => $_clearField(4);

  /// 时间
  @$pb.TagNumber(5)
  $fixnum.Int64 get at => $_getI64(4);
  @$pb.TagNumber(5)
  set at($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearAt() => $_clearField(5);
}

/// DTMF 信令
class CallDtmf extends $pb.GeneratedMessage {
  factory CallDtmf({
    $core.String? callId,
    $fixnum.Int64? fromUserId,
    $core.String? digits,
    $fixnum.Int64? at,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (digits != null) result.digits = digits;
    if (at != null) result.at = at;
    return result;
  }

  CallDtmf._();

  factory CallDtmf.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CallDtmf.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CallDtmf', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aInt64(2, _omitFieldNames ? '' : 'fromUserId')
    ..aOS(3, _omitFieldNames ? '' : 'digits')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'at', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallDtmf clone() => CallDtmf()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallDtmf copyWith(void Function(CallDtmf) updates) => super.copyWith((message) => updates(message as CallDtmf)) as CallDtmf;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallDtmf create() => CallDtmf._();
  @$core.override
  CallDtmf createEmptyInstance() => create();
  static $pb.PbList<CallDtmf> createRepeated() => $pb.PbList<CallDtmf>();
  @$core.pragma('dart2js:noInline')
  static CallDtmf getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallDtmf>(create);
  static CallDtmf? _defaultInstance;

  /// 通话ID
  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  /// 发送者
  @$pb.TagNumber(2)
  $fixnum.Int64 get fromUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set fromUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromUserId() => $_clearField(2);

  /// DTMF 按键序列（如 "123#*")
  @$pb.TagNumber(3)
  $core.String get digits => $_getSZ(2);
  @$pb.TagNumber(3)
  set digits($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDigits() => $_has(2);
  @$pb.TagNumber(3)
  void clearDigits() => $_clearField(3);

  /// 时间
  @$pb.TagNumber(4)
  $fixnum.Int64 get at => $_getI64(3);
  @$pb.TagNumber(4)
  set at($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearAt() => $_clearField(4);
}

/// 送达回执确认（客户端→服务端：收到 delivered）
class MsgDeliveredAck extends $pb.GeneratedMessage {
  factory MsgDeliveredAck({
    $fixnum.Int64? msgId,
    $fixnum.Int64? ackUserId,
    $fixnum.Int64? ackAt,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (ackUserId != null) result.ackUserId = ackUserId;
    if (ackAt != null) result.ackAt = ackAt;
    return result;
  }

  MsgDeliveredAck._();

  factory MsgDeliveredAck.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MsgDeliveredAck.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MsgDeliveredAck', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'msgId')
    ..aInt64(2, _omitFieldNames ? '' : 'ackUserId')
    ..aInt64(3, _omitFieldNames ? '' : 'ackAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgDeliveredAck clone() => MsgDeliveredAck()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgDeliveredAck copyWith(void Function(MsgDeliveredAck) updates) => super.copyWith((message) => updates(message as MsgDeliveredAck)) as MsgDeliveredAck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MsgDeliveredAck create() => MsgDeliveredAck._();
  @$core.override
  MsgDeliveredAck createEmptyInstance() => create();
  static $pb.PbList<MsgDeliveredAck> createRepeated() => $pb.PbList<MsgDeliveredAck>();
  @$core.pragma('dart2js:noInline')
  static MsgDeliveredAck getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgDeliveredAck>(create);
  static MsgDeliveredAck? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get msgId => $_getI64(0);
  @$pb.TagNumber(1)
  set msgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get ackUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set ackUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAckUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAckUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get ackAt => $_getI64(2);
  @$pb.TagNumber(3)
  set ackAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAckAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearAckAt() => $_clearField(3);
}

/// 已读上报（客户端→服务端）
class MsgRead extends $pb.GeneratedMessage {
  factory MsgRead({
    $fixnum.Int64? msgId,
    $fixnum.Int64? userId,
    $fixnum.Int64? chatId,
    $fixnum.Int64? readAt,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (userId != null) result.userId = userId;
    if (chatId != null) result.chatId = chatId;
    if (readAt != null) result.readAt = readAt;
    return result;
  }

  MsgRead._();

  factory MsgRead.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MsgRead.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MsgRead', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'msgId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aInt64(3, _omitFieldNames ? '' : 'chatId')
    ..aInt64(4, _omitFieldNames ? '' : 'readAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgRead clone() => MsgRead()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgRead copyWith(void Function(MsgRead) updates) => super.copyWith((message) => updates(message as MsgRead)) as MsgRead;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MsgRead create() => MsgRead._();
  @$core.override
  MsgRead createEmptyInstance() => create();
  static $pb.PbList<MsgRead> createRepeated() => $pb.PbList<MsgRead>();
  @$core.pragma('dart2js:noInline')
  static MsgRead getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgRead>(create);
  static MsgRead? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get msgId => $_getI64(0);
  @$pb.TagNumber(1)
  set msgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get chatId => $_getI64(2);
  @$pb.TagNumber(3)
  set chatId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChatId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChatId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get readAt => $_getI64(3);
  @$pb.TagNumber(4)
  set readAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReadAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearReadAt() => $_clearField(4);
}

/// 已读回执确认（服务端→客户端：收到 read）
class MsgReadAck extends $pb.GeneratedMessage {
  factory MsgReadAck({
    $fixnum.Int64? msgId,
    $fixnum.Int64? ackUserId,
    $fixnum.Int64? ackAt,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (ackUserId != null) result.ackUserId = ackUserId;
    if (ackAt != null) result.ackAt = ackAt;
    return result;
  }

  MsgReadAck._();

  factory MsgReadAck.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MsgReadAck.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MsgReadAck', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'msgId')
    ..aInt64(2, _omitFieldNames ? '' : 'ackUserId')
    ..aInt64(3, _omitFieldNames ? '' : 'ackAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgReadAck clone() => MsgReadAck()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgReadAck copyWith(void Function(MsgReadAck) updates) => super.copyWith((message) => updates(message as MsgReadAck)) as MsgReadAck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MsgReadAck create() => MsgReadAck._();
  @$core.override
  MsgReadAck createEmptyInstance() => create();
  static $pb.PbList<MsgReadAck> createRepeated() => $pb.PbList<MsgReadAck>();
  @$core.pragma('dart2js:noInline')
  static MsgReadAck getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgReadAck>(create);
  static MsgReadAck? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get msgId => $_getI64(0);
  @$pb.TagNumber(1)
  set msgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get ackUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set ackUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAckUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAckUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get ackAt => $_getI64(2);
  @$pb.TagNumber(3)
  set ackAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAckAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearAckAt() => $_clearField(3);
}

/// 消息撤回
class MsgRecall extends $pb.GeneratedMessage {
  factory MsgRecall({
    $fixnum.Int64? msgId,
    $fixnum.Int64? operatorUserId,
    $core.String? reason,
    $fixnum.Int64? recalledAt,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (operatorUserId != null) result.operatorUserId = operatorUserId;
    if (reason != null) result.reason = reason;
    if (recalledAt != null) result.recalledAt = recalledAt;
    return result;
  }

  MsgRecall._();

  factory MsgRecall.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MsgRecall.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MsgRecall', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'msgId')
    ..aInt64(2, _omitFieldNames ? '' : 'operatorUserId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..aInt64(4, _omitFieldNames ? '' : 'recalledAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgRecall clone() => MsgRecall()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgRecall copyWith(void Function(MsgRecall) updates) => super.copyWith((message) => updates(message as MsgRecall)) as MsgRecall;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MsgRecall create() => MsgRecall._();
  @$core.override
  MsgRecall createEmptyInstance() => create();
  static $pb.PbList<MsgRecall> createRepeated() => $pb.PbList<MsgRecall>();
  @$core.pragma('dart2js:noInline')
  static MsgRecall getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgRecall>(create);
  static MsgRecall? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get msgId => $_getI64(0);
  @$pb.TagNumber(1)
  set msgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get operatorUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set operatorUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get recalledAt => $_getI64(3);
  @$pb.TagNumber(4)
  set recalledAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRecalledAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearRecalledAt() => $_clearField(4);
}

/// 消息转发
class MsgForward extends $pb.GeneratedMessage {
  factory MsgForward({
    $fixnum.Int64? srcMsgId,
    $fixnum.Int64? newMsgId,
    $fixnum.Int64? fromUserId,
    $fixnum.Int64? toUserId,
    $fixnum.Int64? createdAt,
  }) {
    final result = create();
    if (srcMsgId != null) result.srcMsgId = srcMsgId;
    if (newMsgId != null) result.newMsgId = newMsgId;
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (toUserId != null) result.toUserId = toUserId;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  MsgForward._();

  factory MsgForward.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MsgForward.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MsgForward', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'srcMsgId')
    ..aInt64(2, _omitFieldNames ? '' : 'newMsgId')
    ..aInt64(3, _omitFieldNames ? '' : 'fromUserId')
    ..aInt64(4, _omitFieldNames ? '' : 'toUserId')
    ..aInt64(5, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgForward clone() => MsgForward()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgForward copyWith(void Function(MsgForward) updates) => super.copyWith((message) => updates(message as MsgForward)) as MsgForward;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MsgForward create() => MsgForward._();
  @$core.override
  MsgForward createEmptyInstance() => create();
  static $pb.PbList<MsgForward> createRepeated() => $pb.PbList<MsgForward>();
  @$core.pragma('dart2js:noInline')
  static MsgForward getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgForward>(create);
  static MsgForward? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get srcMsgId => $_getI64(0);
  @$pb.TagNumber(1)
  set srcMsgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSrcMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSrcMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get newMsgId => $_getI64(1);
  @$pb.TagNumber(2)
  set newMsgId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get fromUserId => $_getI64(2);
  @$pb.TagNumber(3)
  set fromUserId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get toUserId => $_getI64(3);
  @$pb.TagNumber(4)
  set toUserId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasToUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearToUserId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get createdAt => $_getI64(4);
  @$pb.TagNumber(5)
  set createdAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);
}

/// 消息表态（emoji/reaction）
class MsgReaction extends $pb.GeneratedMessage {
  factory MsgReaction({
    $fixnum.Int64? msgId,
    $fixnum.Int64? userId,
    ReactionAction? action,
    $core.String? emoji,
    $fixnum.Int64? at,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (userId != null) result.userId = userId;
    if (action != null) result.action = action;
    if (emoji != null) result.emoji = emoji;
    if (at != null) result.at = at;
    return result;
  }

  MsgReaction._();

  factory MsgReaction.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory MsgReaction.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MsgReaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'msgId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..e<ReactionAction>(3, _omitFieldNames ? '' : 'action', $pb.PbFieldType.OE, defaultOrMaker: ReactionAction.RA_UNKNOWN, valueOf: ReactionAction.valueOf, enumValues: ReactionAction.values)
    ..aOS(4, _omitFieldNames ? '' : 'emoji')
    ..aInt64(5, _omitFieldNames ? '' : 'at')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgReaction clone() => MsgReaction()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MsgReaction copyWith(void Function(MsgReaction) updates) => super.copyWith((message) => updates(message as MsgReaction)) as MsgReaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MsgReaction create() => MsgReaction._();
  @$core.override
  MsgReaction createEmptyInstance() => create();
  static $pb.PbList<MsgReaction> createRepeated() => $pb.PbList<MsgReaction>();
  @$core.pragma('dart2js:noInline')
  static MsgReaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgReaction>(create);
  static MsgReaction? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get msgId => $_getI64(0);
  @$pb.TagNumber(1)
  set msgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  ReactionAction get action => $_getN(2);
  @$pb.TagNumber(3)
  set action(ReactionAction value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get emoji => $_getSZ(3);
  @$pb.TagNumber(4)
  set emoji($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmoji() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmoji() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get at => $_getI64(4);
  @$pb.TagNumber(5)
  set at($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearAt() => $_clearField(5);
}

enum Typing_Target {
  toUserId, 
  groupId, 
  notSet
}

/// 正在输入
class Typing extends $pb.GeneratedMessage {
  factory Typing({
    $fixnum.Int64? fromUserId,
    $fixnum.Int64? toUserId,
    TypingState? state,
    $fixnum.Int64? at,
    $fixnum.Int64? groupId,
    $core.Iterable<$fixnum.Int64>? notifyUserIds,
  }) {
    final result = create();
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (toUserId != null) result.toUserId = toUserId;
    if (state != null) result.state = state;
    if (at != null) result.at = at;
    if (groupId != null) result.groupId = groupId;
    if (notifyUserIds != null) result.notifyUserIds.addAll(notifyUserIds);
    return result;
  }

  Typing._();

  factory Typing.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory Typing.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Typing_Target> _Typing_TargetByTag = {
    2 : Typing_Target.toUserId,
    5 : Typing_Target.groupId,
    0 : Typing_Target.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Typing', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..oo(0, [2, 5])
    ..aInt64(1, _omitFieldNames ? '' : 'fromUserId')
    ..aInt64(2, _omitFieldNames ? '' : 'toUserId')
    ..e<TypingState>(3, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: TypingState.TYPING_NONE, valueOf: TypingState.valueOf, enumValues: TypingState.values)
    ..aInt64(4, _omitFieldNames ? '' : 'at')
    ..aInt64(5, _omitFieldNames ? '' : 'groupId')
    ..p<$fixnum.Int64>(6, _omitFieldNames ? '' : 'notifyUserIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Typing clone() => Typing()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Typing copyWith(void Function(Typing) updates) => super.copyWith((message) => updates(message as Typing)) as Typing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Typing create() => Typing._();
  @$core.override
  Typing createEmptyInstance() => create();
  static $pb.PbList<Typing> createRepeated() => $pb.PbList<Typing>();
  @$core.pragma('dart2js:noInline')
  static Typing getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Typing>(create);
  static Typing? _defaultInstance;

  Typing_Target whichTarget() => _Typing_TargetByTag[$_whichOneof(0)]!;
  void clearTarget() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $fixnum.Int64 get fromUserId => $_getI64(0);
  @$pb.TagNumber(1)
  set fromUserId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get toUserId => $_getI64(1);
  @$pb.TagNumber(2)
  set toUserId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearToUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  TypingState get state => $_getN(2);
  @$pb.TagNumber(3)
  set state(TypingState value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasState() => $_has(2);
  @$pb.TagNumber(3)
  void clearState() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get at => $_getI64(3);
  @$pb.TagNumber(4)
  set at($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get groupId => $_getI64(4);
  @$pb.TagNumber(5)
  set groupId($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGroupId() => $_has(4);
  @$pb.TagNumber(5)
  void clearGroupId() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$fixnum.Int64> get notifyUserIds => $_getList(5);
}

/// 查询好友消息历史
class QueryFriendMessagesRequest extends $pb.GeneratedMessage {
  factory QueryFriendMessagesRequest({
    $fixnum.Int64? userId,
    $fixnum.Int64? friendId,
    $fixnum.Int64? beforeMessageId,
    $fixnum.Int64? beforeTimestamp,
    $core.int? limit,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (friendId != null) result.friendId = friendId;
    if (beforeMessageId != null) result.beforeMessageId = beforeMessageId;
    if (beforeTimestamp != null) result.beforeTimestamp = beforeTimestamp;
    if (limit != null) result.limit = limit;
    return result;
  }

  QueryFriendMessagesRequest._();

  factory QueryFriendMessagesRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory QueryFriendMessagesRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'QueryFriendMessagesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'friendId')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'beforeMessageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(4, _omitFieldNames ? '' : 'beforeTimestamp')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryFriendMessagesRequest clone() => QueryFriendMessagesRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryFriendMessagesRequest copyWith(void Function(QueryFriendMessagesRequest) updates) => super.copyWith((message) => updates(message as QueryFriendMessagesRequest)) as QueryFriendMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QueryFriendMessagesRequest create() => QueryFriendMessagesRequest._();
  @$core.override
  QueryFriendMessagesRequest createEmptyInstance() => create();
  static $pb.PbList<QueryFriendMessagesRequest> createRepeated() => $pb.PbList<QueryFriendMessagesRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryFriendMessagesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryFriendMessagesRequest>(create);
  static QueryFriendMessagesRequest? _defaultInstance;

  /// 当前用户 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// 好友 ID
  @$pb.TagNumber(2)
  $fixnum.Int64 get friendId => $_getI64(1);
  @$pb.TagNumber(2)
  set friendId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFriendId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFriendId() => $_clearField(2);

  /// 分页游标：消息 ID 上限（不含）
  @$pb.TagNumber(3)
  $fixnum.Int64 get beforeMessageId => $_getI64(2);
  @$pb.TagNumber(3)
  set beforeMessageId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBeforeMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBeforeMessageId() => $_clearField(3);

  /// 分页游标：时间上限（毫秒，不含）
  @$pb.TagNumber(4)
  $fixnum.Int64 get beforeTimestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set beforeTimestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBeforeTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearBeforeTimestamp() => $_clearField(4);

  /// 返回条目上限，缺省 20
  @$pb.TagNumber(5)
  $core.int get limit => $_getIZ(4);
  @$pb.TagNumber(5)
  set limit($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLimit() => $_has(4);
  @$pb.TagNumber(5)
  void clearLimit() => $_clearField(5);
}

/// 查询群聊消息历史
class QueryGroupMessagesRequest extends $pb.GeneratedMessage {
  factory QueryGroupMessagesRequest({
    $fixnum.Int64? groupId,
    $fixnum.Int64? beforeMessageId,
    $fixnum.Int64? beforeTimestamp,
    $core.int? limit,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (beforeMessageId != null) result.beforeMessageId = beforeMessageId;
    if (beforeTimestamp != null) result.beforeTimestamp = beforeTimestamp;
    if (limit != null) result.limit = limit;
    return result;
  }

  QueryGroupMessagesRequest._();

  factory QueryGroupMessagesRequest.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory QueryGroupMessagesRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'QueryGroupMessagesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'beforeMessageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(3, _omitFieldNames ? '' : 'beforeTimestamp')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryGroupMessagesRequest clone() => QueryGroupMessagesRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryGroupMessagesRequest copyWith(void Function(QueryGroupMessagesRequest) updates) => super.copyWith((message) => updates(message as QueryGroupMessagesRequest)) as QueryGroupMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QueryGroupMessagesRequest create() => QueryGroupMessagesRequest._();
  @$core.override
  QueryGroupMessagesRequest createEmptyInstance() => create();
  static $pb.PbList<QueryGroupMessagesRequest> createRepeated() => $pb.PbList<QueryGroupMessagesRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryGroupMessagesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryGroupMessagesRequest>(create);
  static QueryGroupMessagesRequest? _defaultInstance;

  /// 群 ID
  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  /// 分页游标：消息 ID 上限（不含）
  @$pb.TagNumber(2)
  $fixnum.Int64 get beforeMessageId => $_getI64(1);
  @$pb.TagNumber(2)
  set beforeMessageId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBeforeMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBeforeMessageId() => $_clearField(2);

  /// 分页游标：时间上限（毫秒，不含）
  @$pb.TagNumber(3)
  $fixnum.Int64 get beforeTimestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set beforeTimestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBeforeTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearBeforeTimestamp() => $_clearField(3);

  /// 返回条目上限，缺省 20
  @$pb.TagNumber(4)
  $core.int get limit => $_getIZ(3);
  @$pb.TagNumber(4)
  set limit($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimit() => $_clearField(4);
}

/// 历史消息查询统一响应
class QueryMessagesResponse extends $pb.GeneratedMessage {
  factory QueryMessagesResponse({
    $core.Iterable<Content>? messages,
    $core.bool? hasMore,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  QueryMessagesResponse._();

  factory QueryMessagesResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory QueryMessagesResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'QueryMessagesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..pc<Content>(1, _omitFieldNames ? '' : 'messages', $pb.PbFieldType.PM, subBuilder: Content.create)
    ..aOB(2, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryMessagesResponse clone() => QueryMessagesResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryMessagesResponse copyWith(void Function(QueryMessagesResponse) updates) => super.copyWith((message) => updates(message as QueryMessagesResponse)) as QueryMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QueryMessagesResponse create() => QueryMessagesResponse._();
  @$core.override
  QueryMessagesResponse createEmptyInstance() => create();
  static $pb.PbList<QueryMessagesResponse> createRepeated() => $pb.PbList<QueryMessagesResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryMessagesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryMessagesResponse>(create);
  static QueryMessagesResponse? _defaultInstance;

  /// 消息列表（按时间倒序或应用约定排序）
  @$pb.TagNumber(1)
  $pb.PbList<Content> get messages => $_getList(0);

  /// 是否还有更多数据
  @$pb.TagNumber(2)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(2)
  set hasMore($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasMore() => $_clearField(2);
}

/// ===============
/// 加密载荷封装（端到端加密）
/// ===============
/// 说明：服务端只透传本结构中的密文，不解密
class EncryptedContent extends $pb.GeneratedMessage {
  factory EncryptedContent({
    $core.String? scheme,
    $core.List<$core.int>? senderPub,
    $core.String? keyId,
    $core.List<$core.int>? nonce,
    $core.List<$core.int>? ciphertext,
    $core.List<$core.int>? aad,
    $fixnum.Int64? msgNo,
  }) {
    final result = create();
    if (scheme != null) result.scheme = scheme;
    if (senderPub != null) result.senderPub = senderPub;
    if (keyId != null) result.keyId = keyId;
    if (nonce != null) result.nonce = nonce;
    if (ciphertext != null) result.ciphertext = ciphertext;
    if (aad != null) result.aad = aad;
    if (msgNo != null) result.msgNo = msgNo;
    return result;
  }

  EncryptedContent._();

  factory EncryptedContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory EncryptedContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptedContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'scheme')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'senderPub', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'keyId')
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'ciphertext', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'aad', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'msgNo', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedContent clone() => EncryptedContent()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedContent copyWith(void Function(EncryptedContent) updates) => super.copyWith((message) => updates(message as EncryptedContent)) as EncryptedContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptedContent create() => EncryptedContent._();
  @$core.override
  EncryptedContent createEmptyInstance() => create();
  static $pb.PbList<EncryptedContent> createRepeated() => $pb.PbList<EncryptedContent>();
  @$core.pragma('dart2js:noInline')
  static EncryptedContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncryptedContent>(create);
  static EncryptedContent? _defaultInstance;

  /// 加密方案标识，如 "x25519+chacha20poly1305"
  @$pb.TagNumber(1)
  $core.String get scheme => $_getSZ(0);
  @$pb.TagNumber(1)
  set scheme($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScheme() => $_has(0);
  @$pb.TagNumber(1)
  void clearScheme() => $_clearField(1);

  /// 发送方的会话公钥（如 X25519 公钥）
  @$pb.TagNumber(2)
  $core.List<$core.int> get senderPub => $_getN(1);
  @$pb.TagNumber(2)
  set senderPub($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSenderPub() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderPub() => $_clearField(2);

  /// 会话/密钥标识（便于接收端定位密钥材料）
  @$pb.TagNumber(3)
  $core.String get keyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set keyId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKeyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearKeyId() => $_clearField(3);

  /// AEAD 随机数/计数随机量
  @$pb.TagNumber(4)
  $core.List<$core.int> get nonce => $_getN(3);
  @$pb.TagNumber(4)
  set nonce($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNonce() => $_has(3);
  @$pb.TagNumber(4)
  void clearNonce() => $_clearField(4);

  /// AEAD 密文（含认证标签）；密文内容为“单条 MessageContent 的 Protobuf 编码”
  /// 注意：仅对 MessageContent 加密，顶层 Content 的元数据（sender/receiver/timestamp/scene/msg_kind）保持明文
  @$pb.TagNumber(5)
  $core.List<$core.int> get ciphertext => $_getN(4);
  @$pb.TagNumber(5)
  set ciphertext($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCiphertext() => $_has(4);
  @$pb.TagNumber(5)
  void clearCiphertext() => $_clearField(5);

  /// 附加认证数据（A.A.D.，可为空）
  /// 建议包含：message_id|sender_id|receiver_id|scene|timestamp（按一致序拼接），用于端到端防篡改
  @$pb.TagNumber(6)
  $core.List<$core.int> get aad => $_getN(5);
  @$pb.TagNumber(6)
  set aad($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAad() => $_has(5);
  @$pb.TagNumber(6)
  void clearAad() => $_clearField(6);

  /// 发送方本地单调消息序号（防重放/乱序）
  @$pb.TagNumber(7)
  $fixnum.Int64 get msgNo => $_getI64(6);
  @$pb.TagNumber(7)
  set msgNo($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMsgNo() => $_has(6);
  @$pb.TagNumber(7)
  void clearMsgNo() => $_clearField(7);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
