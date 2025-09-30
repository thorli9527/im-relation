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

import 'package:protobuf/protobuf.dart' as $pb;

/// ======================================
/// 💬 会话场景类型
/// ======================================
/// 用于标识消息所属的会话类型，帮助客户端进行不同的渲染和处理
class ChatScene extends $pb.ProtobufEnum {
  static const ChatScene CHAT_UNKNOWN = ChatScene._(0, _omitEnumNames ? '' : 'CHAT_UNKNOWN');
  static const ChatScene SINGLE = ChatScene._(1, _omitEnumNames ? '' : 'SINGLE');
  static const ChatScene GROUP = ChatScene._(2, _omitEnumNames ? '' : 'GROUP');

  static const $core.List<ChatScene> values = <ChatScene> [
    CHAT_UNKNOWN,
    SINGLE,
    GROUP,
  ];

  static final $core.List<ChatScene?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ChatScene? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ChatScene._(super.value, super.name);
}

/// ======================================
/// 😄 Emoji 类型定义（标准 + 自定义）
/// ======================================
/// 定义了系统中支持的 emoji 类型，包括标准 emoji 和自定义表情
class EmojiType extends $pb.ProtobufEnum {
  static const EmojiType EMOJI_UNKNOWN = EmojiType._(0, _omitEnumNames ? '' : 'EMOJI_UNKNOWN');
  static const EmojiType SMILE = EmojiType._(1, _omitEnumNames ? '' : 'SMILE');
  static const EmojiType GRIN = EmojiType._(2, _omitEnumNames ? '' : 'GRIN');
  static const EmojiType TEARS = EmojiType._(3, _omitEnumNames ? '' : 'TEARS');
  static const EmojiType STUCK_OUT_TONGUE = EmojiType._(4, _omitEnumNames ? '' : 'STUCK_OUT_TONGUE');
  static const EmojiType CLAP = EmojiType._(25, _omitEnumNames ? '' : 'CLAP');
  static const EmojiType POOP = EmojiType._(28, _omitEnumNames ? '' : 'POOP');
  static const EmojiType HEART = EmojiType._(21, _omitEnumNames ? '' : 'HEART');
  /// ... 可继续扩展标准 Emoji
  static const EmojiType CUSTOM_EMOJI = EmojiType._(1000, _omitEnumNames ? '' : 'CUSTOM_EMOJI');

  static const $core.List<EmojiType> values = <EmojiType> [
    EMOJI_UNKNOWN,
    SMILE,
    GRIN,
    TEARS,
    STUCK_OUT_TONGUE,
    CLAP,
    POOP,
    HEART,
    CUSTOM_EMOJI,
  ];

  static final $core.Map<$core.int, EmojiType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static EmojiType? valueOf($core.int value) => _byValue[value];

  const EmojiType._(super.value, super.name);
}

class AVCallContent_CallAction extends $pb.ProtobufEnum {
  static const AVCallContent_CallAction UNKNOWN = AVCallContent_CallAction._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const AVCallContent_CallAction INVITE = AVCallContent_CallAction._(1, _omitEnumNames ? '' : 'INVITE');
  static const AVCallContent_CallAction ACCEPT = AVCallContent_CallAction._(2, _omitEnumNames ? '' : 'ACCEPT');
  static const AVCallContent_CallAction REJECT = AVCallContent_CallAction._(3, _omitEnumNames ? '' : 'REJECT');
  static const AVCallContent_CallAction CANCEL = AVCallContent_CallAction._(4, _omitEnumNames ? '' : 'CANCEL');
  static const AVCallContent_CallAction END = AVCallContent_CallAction._(5, _omitEnumNames ? '' : 'END');
  static const AVCallContent_CallAction TIMEOUT = AVCallContent_CallAction._(6, _omitEnumNames ? '' : 'TIMEOUT');

  static const $core.List<AVCallContent_CallAction> values = <AVCallContent_CallAction> [
    UNKNOWN,
    INVITE,
    ACCEPT,
    REJECT,
    CANCEL,
    END,
    TIMEOUT,
  ];

  static final $core.List<AVCallContent_CallAction?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 6);
  static AVCallContent_CallAction? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AVCallContent_CallAction._(super.value, super.name);
}

class AVCallContent_CallType extends $pb.ProtobufEnum {
  static const AVCallContent_CallType AUDIO = AVCallContent_CallType._(0, _omitEnumNames ? '' : 'AUDIO');
  static const AVCallContent_CallType VIDEO = AVCallContent_CallType._(1, _omitEnumNames ? '' : 'VIDEO');

  static const $core.List<AVCallContent_CallType> values = <AVCallContent_CallType> [
    AUDIO,
    VIDEO,
  ];

  static final $core.List<AVCallContent_CallType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 1);
  static AVCallContent_CallType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AVCallContent_CallType._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
