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
/// 😄 Emoji 类型定义（标准 + 自定义）
/// ======================================
/// 定义了系统中支持的 emoji 类型，包括标准 emoji 和自定义表情
class EmojiType extends $pb.ProtobufEnum {
  static const EmojiType EMOJI_UNKNOWN = EmojiType._(0, _omitEnumNames ? '' : 'EMOJI_UNKNOWN');
  /// 微笑表情
  static const EmojiType SMILE = EmojiType._(1, _omitEnumNames ? '' : 'SMILE');
  /// 咧嘴笑表情
  static const EmojiType GRIN = EmojiType._(2, _omitEnumNames ? '' : 'GRIN');
  /// 流泪表情
  static const EmojiType TEARS = EmojiType._(3, _omitEnumNames ? '' : 'TEARS');
  /// 吐舌头表情
  static const EmojiType STUCK_OUT_TONGUE = EmojiType._(4, _omitEnumNames ? '' : 'STUCK_OUT_TONGUE');
  /// 鼓掌表情
  static const EmojiType CLAP = EmojiType._(25, _omitEnumNames ? '' : 'CLAP');
  /// 便便表情
  static const EmojiType POOP = EmojiType._(28, _omitEnumNames ? '' : 'POOP');
  /// 爱心表情
  static const EmojiType HEART = EmojiType._(21, _omitEnumNames ? '' : 'HEART');
  /// ... 可继续扩展标准 Emoji
  /// 自定义表情（通过图片 URL 指定）
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

/// 通话媒体类型
class CallMediaType extends $pb.ProtobufEnum {
  /// 语音
  static const CallMediaType CALL_AUDIO = CallMediaType._(0, _omitEnumNames ? '' : 'CALL_AUDIO');
  /// 视频
  static const CallMediaType CALL_VIDEO = CallMediaType._(1, _omitEnumNames ? '' : 'CALL_VIDEO');

  static const $core.List<CallMediaType> values = <CallMediaType> [
    CALL_AUDIO,
    CALL_VIDEO,
  ];

  static final $core.List<CallMediaType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 1);
  static CallMediaType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CallMediaType._(super.value, super.name);
}

/// 通话结束原因
class CallEndReason extends $pb.ProtobufEnum {
  /// 未指定
  static const CallEndReason CER_UNSPECIFIED = CallEndReason._(0, _omitEnumNames ? '' : 'CER_UNSPECIFIED');
  /// 主动取消
  static const CallEndReason CER_CANCELLED = CallEndReason._(1, _omitEnumNames ? '' : 'CER_CANCELLED');
  /// 对方拒绝
  static const CallEndReason CER_REJECTED = CallEndReason._(2, _omitEnumNames ? '' : 'CER_REJECTED');
  /// 对方忙
  static const CallEndReason CER_BUSY = CallEndReason._(3, _omitEnumNames ? '' : 'CER_BUSY');
  /// 超时未应答
  static const CallEndReason CER_TIMEOUT = CallEndReason._(4, _omitEnumNames ? '' : 'CER_TIMEOUT');
  /// 正常挂断
  static const CallEndReason CER_HANGUP = CallEndReason._(5, _omitEnumNames ? '' : 'CER_HANGUP');
  /// 失败/异常
  static const CallEndReason CER_FAILED = CallEndReason._(6, _omitEnumNames ? '' : 'CER_FAILED');

  static const $core.List<CallEndReason> values = <CallEndReason> [
    CER_UNSPECIFIED,
    CER_CANCELLED,
    CER_REJECTED,
    CER_BUSY,
    CER_TIMEOUT,
    CER_HANGUP,
    CER_FAILED,
  ];

  static final $core.List<CallEndReason?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 6);
  static CallEndReason? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CallEndReason._(super.value, super.name);
}

/// 通话内修改类型
class CallModifyType extends $pb.ProtobufEnum {
  /// 未指定，用作默认值，满足 proto3 首元素为 0 的要求
  static const CallModifyType CMT_UNSPECIFIED = CallModifyType._(0, _omitEnumNames ? '' : 'CMT_UNSPECIFIED');
  /// 静音/取消静音
  static const CallModifyType CMT_MUTE = CallModifyType._(1, _omitEnumNames ? '' : 'CMT_MUTE');
  /// 开/关摄像头
  static const CallModifyType CMT_CAMERA = CallModifyType._(2, _omitEnumNames ? '' : 'CMT_CAMERA');
  /// 保持/恢复通话
  static const CallModifyType CMT_HOLD = CallModifyType._(3, _omitEnumNames ? '' : 'CMT_HOLD');
  /// 切换前后摄
  static const CallModifyType CMT_SWITCH_CAMERA = CallModifyType._(4, _omitEnumNames ? '' : 'CMT_SWITCH_CAMERA');

  static const $core.List<CallModifyType> values = <CallModifyType> [
    CMT_UNSPECIFIED,
    CMT_MUTE,
    CMT_CAMERA,
    CMT_HOLD,
    CMT_SWITCH_CAMERA,
  ];

  static final $core.List<CallModifyType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CallModifyType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CallModifyType._(super.value, super.name);
}

class ChatScene extends $pb.ProtobufEnum {
  /// 默认未知场景（防御值）
  static const ChatScene CHAT_UNKNOWN = ChatScene._(0, _omitEnumNames ? '' : 'CHAT_UNKNOWN');
  /// 单人会话：用户与用户之间的私聊
  static const ChatScene SINGLE = ChatScene._(1, _omitEnumNames ? '' : 'SINGLE');
  /// 群聊会话：群组内的多人聊天
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

/// Reaction 操作
class ReactionAction extends $pb.ProtobufEnum {
  /// 未指定动作
  static const ReactionAction RA_UNKNOWN = ReactionAction._(0, _omitEnumNames ? '' : 'RA_UNKNOWN');
  static const ReactionAction RA_ADD = ReactionAction._(1, _omitEnumNames ? '' : 'RA_ADD');
  static const ReactionAction RA_REMOVE = ReactionAction._(2, _omitEnumNames ? '' : 'RA_REMOVE');

  static const $core.List<ReactionAction> values = <ReactionAction> [
    RA_UNKNOWN,
    RA_ADD,
    RA_REMOVE,
  ];

  static final $core.List<ReactionAction?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ReactionAction? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ReactionAction._(super.value, super.name);
}

/// 正在输入状态
class TypingState extends $pb.ProtobufEnum {
  static const TypingState TYPING_NONE = TypingState._(0, _omitEnumNames ? '' : 'TYPING_NONE');
  static const TypingState TYPING_TEXT = TypingState._(1, _omitEnumNames ? '' : 'TYPING_TEXT');
  static const TypingState TYPING_VOICE = TypingState._(2, _omitEnumNames ? '' : 'TYPING_VOICE');
  static const TypingState TYPING_UPLOAD = TypingState._(3, _omitEnumNames ? '' : 'TYPING_UPLOAD');

  static const $core.List<TypingState> values = <TypingState> [
    TYPING_NONE,
    TYPING_TEXT,
    TYPING_VOICE,
    TYPING_UPLOAD,
  ];

  static final $core.List<TypingState?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TypingState? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TypingState._(super.value, super.name);
}

class AVCallContent_CallAction extends $pb.ProtobufEnum {
  /// 未知操作
  static const AVCallContent_CallAction UNKNOWN = AVCallContent_CallAction._(0, _omitEnumNames ? '' : 'UNKNOWN');
  /// 邀请：发起通话邀请
  static const AVCallContent_CallAction INVITE = AVCallContent_CallAction._(1, _omitEnumNames ? '' : 'INVITE');
  /// 接受：接受通话邀请
  static const AVCallContent_CallAction ACCEPT = AVCallContent_CallAction._(2, _omitEnumNames ? '' : 'ACCEPT');
  /// 拒绝：拒绝通话邀请
  static const AVCallContent_CallAction REJECT = AVCallContent_CallAction._(3, _omitEnumNames ? '' : 'REJECT');
  /// 取消：取消通话
  static const AVCallContent_CallAction CANCEL = AVCallContent_CallAction._(4, _omitEnumNames ? '' : 'CANCEL');
  /// 结束：结束通话
  static const AVCallContent_CallAction END = AVCallContent_CallAction._(5, _omitEnumNames ? '' : 'END');
  /// 超时：通话超时
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
  /// 音频通话：仅语音通话
  static const AVCallContent_CallType AUDIO = AVCallContent_CallType._(0, _omitEnumNames ? '' : 'AUDIO');
  /// 视频通话：音视频通话
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
