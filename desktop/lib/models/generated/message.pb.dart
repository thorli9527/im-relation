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

import 'common.pbenum.dart' as $0;
import 'message.pbenum.dart';

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
    0 : MessageContent_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21])
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TextContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InlineEntity', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.int get start => $_getIZ(0);
  @$pb.TagNumber(1)
  set start($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearStart() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get end => $_getIZ(1);
  @$pb.TagNumber(2)
  set end($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImageContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get thumbnailUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set thumbnailUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasThumbnailUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearThumbnailUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get format => $_getSZ(4);
  @$pb.TagNumber(5)
  set format($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFormat() => $_has(4);
  @$pb.TagNumber(5)
  void clearFormat() => $_clearField(5);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AudioContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get duration => $_getIZ(1);
  @$pb.TagNumber(2)
  set duration($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get format => $_getSZ(2);
  @$pb.TagNumber(3)
  set format($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFormat() => $_has(2);
  @$pb.TagNumber(3)
  void clearFormat() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get size => $_getI64(3);
  @$pb.TagNumber(4)
  set size($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearSize() => $_clearField(4);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VideoContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get duration => $_getIZ(1);
  @$pb.TagNumber(2)
  set duration($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get coverUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set coverUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCoverUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearCoverUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get width => $_getIZ(3);
  @$pb.TagNumber(4)
  set width($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearWidth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get height => $_getIZ(4);
  @$pb.TagNumber(5)
  set height($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeight() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get format => $_getSZ(5);
  @$pb.TagNumber(6)
  set format($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFormat() => $_has(5);
  @$pb.TagNumber(6)
  void clearFormat() => $_clearField(6);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LocationContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get poiName => $_getSZ(3);
  @$pb.TagNumber(4)
  set poiName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPoiName() => $_has(3);
  @$pb.TagNumber(4)
  void clearPoiName() => $_clearField(4);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FileContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get size => $_getI64(2);
  @$pb.TagNumber(3)
  set size($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fileType => $_getSZ(3);
  @$pb.TagNumber(4)
  set fileType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFileType() => $_has(3);
  @$pb.TagNumber(4)
  void clearFileType() => $_clearField(4);

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
    $core.String? initiatorId,
    $core.Iterable<$core.String>? participantIds,
    AVCallContent_CallAction? action,
    AVCallContent_CallType? type,
    $fixnum.Int64? timestamp,
    $core.int? duration,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (initiatorId != null) result.initiatorId = initiatorId;
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AVCallContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aOS(2, _omitFieldNames ? '' : 'initiatorId')
    ..pPS(3, _omitFieldNames ? '' : 'participantIds')
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

  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get initiatorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set initiatorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInitiatorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInitiatorId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get participantIds => $_getList(2);

  @$pb.TagNumber(4)
  AVCallContent_CallAction get action => $_getN(3);
  @$pb.TagNumber(4)
  set action(AVCallContent_CallAction value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearAction() => $_clearField(4);

  @$pb.TagNumber(5)
  AVCallContent_CallType get type => $_getN(4);
  @$pb.TagNumber(5)
  set type(AVCallContent_CallType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get customType => $_getSZ(0);
  @$pb.TagNumber(1)
  set customType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCustomType() => $_has(0);
  @$pb.TagNumber(1)
  void clearCustomType() => $_clearField(1);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EmojiContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  EmojiType get emoji => $_getN(0);
  @$pb.TagNumber(1)
  set emoji(EmojiType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEmoji() => $_has(0);
  @$pb.TagNumber(1)
  void clearEmoji() => $_clearField(1);

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
    $core.String? operatorId,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RevokeContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'targetMessageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'operatorId')
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

  @$pb.TagNumber(1)
  $fixnum.Int64 get targetMessageId => $_getI64(0);
  @$pb.TagNumber(1)
  set targetMessageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get operatorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set operatorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperatorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperatorId() => $_clearField(2);

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
    $0.ContentType? originalType,
    $core.String? summary,
  }) {
    final result = create();
    if (originalMessageId != null) result.originalMessageId = originalMessageId;
    if (originalSenderId != null) result.originalSenderId = originalSenderId;
    if (originalType != null) result.originalType = originalType;
    if (summary != null) result.summary = summary;
    return result;
  }

  ForwardContent._();

  factory ForwardContent.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ForwardContent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ForwardContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'originalMessageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'originalSenderId')
    ..e<$0.ContentType>(3, _omitFieldNames ? '' : 'originalType', $pb.PbFieldType.OE, defaultOrMaker: $0.ContentType.UNKNOWN, valueOf: $0.ContentType.valueOf, enumValues: $0.ContentType.values)
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

  @$pb.TagNumber(1)
  $fixnum.Int64 get originalMessageId => $_getI64(0);
  @$pb.TagNumber(1)
  set originalMessageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOriginalMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOriginalMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get originalSenderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set originalSenderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOriginalSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOriginalSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.ContentType get originalType => $_getN(2);
  @$pb.TagNumber(3)
  set originalType($0.ContentType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOriginalType() => $_has(2);
  @$pb.TagNumber(3)
  void clearOriginalType() => $_clearField(3);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'QuoteContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $fixnum.Int64 get quotedMessageId => $_getI64(0);
  @$pb.TagNumber(1)
  set quotedMessageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuotedMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuotedMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get quotedContentPreview => $_getSZ(1);
  @$pb.TagNumber(2)
  set quotedContentPreview($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuotedContentPreview() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuotedContentPreview() => $_clearField(2);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HtmlContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoipContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get callerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get calleeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set calleeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCalleeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCalleeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get duration => $_getI64(2);
  @$pb.TagNumber(3)
  set duration($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDuration() => $_has(2);
  @$pb.TagNumber(3)
  void clearDuration() => $_clearField(3);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NotificationContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'body')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'metadata', entryClassName: 'NotificationContent.MetadataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('protocol.message'))
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

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get body => $_getSZ(1);
  @$pb.TagNumber(2)
  set body($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SystemContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get content => $_getSZ(0);
  @$pb.TagNumber(1)
  set content($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReminderContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

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
/// 👪 群组事件
/// ===============================
/// 用于群组相关事件，包含群组信息和操作者
class GroupEventContent extends $pb.GeneratedMessage {
  factory GroupEventContent({
    $core.String? groupId,
    $core.String? event,
    $core.String? operatorId,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupEventContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..aOS(2, _omitFieldNames ? '' : 'event')
    ..aOS(3, _omitFieldNames ? '' : 'operatorId')
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

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get event => $_getSZ(1);
  @$pb.TagNumber(2)
  set event($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get operatorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set operatorId($core.String value) => $_setString(2, value);
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactCardContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
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

  @$pb.TagNumber(1)
  $core.String get targetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => $_clearField(3);

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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoteContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'topic')
    ..pPS(2, _omitFieldNames ? '' : 'options')
    ..m<$core.String, $core.int>(3, _omitFieldNames ? '' : 'result', entryClassName: 'VoteContent.ResultEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.O3, packageName: const $pb.PackageName('protocol.message'))
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

  @$pb.TagNumber(1)
  $core.String get topic => $_getSZ(0);
  @$pb.TagNumber(1)
  set topic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTopic() => $_has(0);
  @$pb.TagNumber(1)
  void clearTopic() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get options => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.int> get result => $_getMap(2);

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
    $core.String? senderId,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RedEnvelopeContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'senderId')
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

  @$pb.TagNumber(1)
  $core.String get senderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set senderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSenderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSenderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get amount => $_getIZ(1);
  @$pb.TagNumber(2)
  set amount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get blessing => $_getSZ(2);
  @$pb.TagNumber(3)
  set blessing($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlessing() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlessing() => $_clearField(3);

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
    $core.String? segmentId,
    $fixnum.Int64? seqInMsg,
    $core.bool? edited,
    $core.bool? visible,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (body != null) result.body = body;
    if (segmentId != null) result.segmentId = segmentId;
    if (seqInMsg != null) result.seqInMsg = seqInMsg;
    if (edited != null) result.edited = edited;
    if (visible != null) result.visible = visible;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  Segment._();

  factory Segment.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory Segment.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Segment', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
    ..aOM<MessageContent>(1, _omitFieldNames ? '' : 'body', subBuilder: MessageContent.create)
    ..aOS(2, _omitFieldNames ? '' : 'segmentId')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'seqInMsg', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(4, _omitFieldNames ? '' : 'edited')
    ..aOB(5, _omitFieldNames ? '' : 'visible')
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'metadata', entryClassName: 'Segment.MetadataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('protocol.message'))
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

  @$pb.TagNumber(2)
  $core.String get segmentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set segmentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSegmentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSegmentId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get seqInMsg => $_getI64(2);
  @$pb.TagNumber(3)
  set seqInMsg($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeqInMsg() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeqInMsg() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get edited => $_getBF(3);
  @$pb.TagNumber(4)
  set edited($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEdited() => $_has(3);
  @$pb.TagNumber(4)
  void clearEdited() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get visible => $_getBF(4);
  @$pb.TagNumber(5)
  set visible($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVisible() => $_has(4);
  @$pb.TagNumber(5)
  void clearVisible() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(5);
}

/// ======================================
/// 📨 顶层消息结构
/// ======================================
/// 定义了消息的基本框架，包含发送者、接收者、时间等元数据
class Content extends $pb.GeneratedMessage {
  factory Content({
    $fixnum.Int64? messageId,
    $core.String? senderId,
    $core.String? receiverId,
    $fixnum.Int64? timestamp,
    $0.ContentType? messageType,
    ChatScene? scene,
    $core.Iterable<MessageContent>? contents,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (senderId != null) result.senderId = senderId;
    if (receiverId != null) result.receiverId = receiverId;
    if (timestamp != null) result.timestamp = timestamp;
    if (messageType != null) result.messageType = messageType;
    if (scene != null) result.scene = scene;
    if (contents != null) result.contents.addAll(contents);
    return result;
  }

  Content._();

  factory Content.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory Content.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Content', package: const $pb.PackageName(_omitMessageNames ? '' : 'protocol.message'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'messageId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'senderId')
    ..aOS(3, _omitFieldNames ? '' : 'receiverId')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..e<$0.ContentType>(5, _omitFieldNames ? '' : 'messageType', $pb.PbFieldType.OE, defaultOrMaker: $0.ContentType.UNKNOWN, valueOf: $0.ContentType.valueOf, enumValues: $0.ContentType.values)
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

  @$pb.TagNumber(1)
  $fixnum.Int64 get messageId => $_getI64(0);
  @$pb.TagNumber(1)
  set messageId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get senderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get receiverId => $_getSZ(2);
  @$pb.TagNumber(3)
  set receiverId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReceiverId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReceiverId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.ContentType get messageType => $_getN(4);
  @$pb.TagNumber(5)
  set messageType($0.ContentType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasMessageType() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessageType() => $_clearField(5);

  @$pb.TagNumber(6)
  ChatScene get scene => $_getN(5);
  @$pb.TagNumber(6)
  set scene(ChatScene value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasScene() => $_has(5);
  @$pb.TagNumber(6)
  void clearScene() => $_clearField(6);

  @$pb.TagNumber(10)
  $pb.PbList<MessageContent> get contents => $_getList(6);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
