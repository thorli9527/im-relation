// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_business_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Action {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FriendRequestPayload field0) request,
    required TResult Function(FriendRequestDecisionPayload field0) decision,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FriendRequestPayload field0)? request,
    TResult? Function(FriendRequestDecisionPayload field0)? decision,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FriendRequestPayload field0)? request,
    TResult Function(FriendRequestDecisionPayload field0)? decision,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Action_Request value) request,
    required TResult Function(Action_Decision value) decision,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Action_Request value)? request,
    TResult? Function(Action_Decision value)? decision,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Action_Request value)? request,
    TResult Function(Action_Decision value)? decision,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionCopyWith<$Res> {
  factory $ActionCopyWith(Action value, $Res Function(Action) then) =
      _$ActionCopyWithImpl<$Res, Action>;
}

/// @nodoc
class _$ActionCopyWithImpl<$Res, $Val extends Action>
    implements $ActionCopyWith<$Res> {
  _$ActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$Action_RequestImplCopyWith<$Res> {
  factory _$$Action_RequestImplCopyWith(
    _$Action_RequestImpl value,
    $Res Function(_$Action_RequestImpl) then,
  ) = __$$Action_RequestImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FriendRequestPayload field0});
}

/// @nodoc
class __$$Action_RequestImplCopyWithImpl<$Res>
    extends _$ActionCopyWithImpl<$Res, _$Action_RequestImpl>
    implements _$$Action_RequestImplCopyWith<$Res> {
  __$$Action_RequestImplCopyWithImpl(
    _$Action_RequestImpl _value,
    $Res Function(_$Action_RequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$Action_RequestImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as FriendRequestPayload,
      ),
    );
  }
}

/// @nodoc

class _$Action_RequestImpl extends Action_Request {
  const _$Action_RequestImpl(this.field0) : super._();

  @override
  final FriendRequestPayload field0;

  @override
  String toString() {
    return 'Action.request(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Action_RequestImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Action_RequestImplCopyWith<_$Action_RequestImpl> get copyWith =>
      __$$Action_RequestImplCopyWithImpl<_$Action_RequestImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FriendRequestPayload field0) request,
    required TResult Function(FriendRequestDecisionPayload field0) decision,
  }) {
    return request(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FriendRequestPayload field0)? request,
    TResult? Function(FriendRequestDecisionPayload field0)? decision,
  }) {
    return request?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FriendRequestPayload field0)? request,
    TResult Function(FriendRequestDecisionPayload field0)? decision,
    required TResult orElse(),
  }) {
    if (request != null) {
      return request(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Action_Request value) request,
    required TResult Function(Action_Decision value) decision,
  }) {
    return request(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Action_Request value)? request,
    TResult? Function(Action_Decision value)? decision,
  }) {
    return request?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Action_Request value)? request,
    TResult Function(Action_Decision value)? decision,
    required TResult orElse(),
  }) {
    if (request != null) {
      return request(this);
    }
    return orElse();
  }
}

abstract class Action_Request extends Action {
  const factory Action_Request(final FriendRequestPayload field0) =
      _$Action_RequestImpl;
  const Action_Request._() : super._();

  @override
  FriendRequestPayload get field0;

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Action_RequestImplCopyWith<_$Action_RequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Action_DecisionImplCopyWith<$Res> {
  factory _$$Action_DecisionImplCopyWith(
    _$Action_DecisionImpl value,
    $Res Function(_$Action_DecisionImpl) then,
  ) = __$$Action_DecisionImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FriendRequestDecisionPayload field0});
}

/// @nodoc
class __$$Action_DecisionImplCopyWithImpl<$Res>
    extends _$ActionCopyWithImpl<$Res, _$Action_DecisionImpl>
    implements _$$Action_DecisionImplCopyWith<$Res> {
  __$$Action_DecisionImplCopyWithImpl(
    _$Action_DecisionImpl _value,
    $Res Function(_$Action_DecisionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$Action_DecisionImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as FriendRequestDecisionPayload,
      ),
    );
  }
}

/// @nodoc

class _$Action_DecisionImpl extends Action_Decision {
  const _$Action_DecisionImpl(this.field0) : super._();

  @override
  final FriendRequestDecisionPayload field0;

  @override
  String toString() {
    return 'Action.decision(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Action_DecisionImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Action_DecisionImplCopyWith<_$Action_DecisionImpl> get copyWith =>
      __$$Action_DecisionImplCopyWithImpl<_$Action_DecisionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FriendRequestPayload field0) request,
    required TResult Function(FriendRequestDecisionPayload field0) decision,
  }) {
    return decision(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FriendRequestPayload field0)? request,
    TResult? Function(FriendRequestDecisionPayload field0)? decision,
  }) {
    return decision?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FriendRequestPayload field0)? request,
    TResult Function(FriendRequestDecisionPayload field0)? decision,
    required TResult orElse(),
  }) {
    if (decision != null) {
      return decision(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Action_Request value) request,
    required TResult Function(Action_Decision value) decision,
  }) {
    return decision(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Action_Request value)? request,
    TResult? Function(Action_Decision value)? decision,
  }) {
    return decision?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Action_Request value)? request,
    TResult Function(Action_Decision value)? decision,
    required TResult orElse(),
  }) {
    if (decision != null) {
      return decision(this);
    }
    return orElse();
  }
}

abstract class Action_Decision extends Action {
  const factory Action_Decision(final FriendRequestDecisionPayload field0) =
      _$Action_DecisionImpl;
  const Action_Decision._() : super._();

  @override
  FriendRequestDecisionPayload get field0;

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Action_DecisionImplCopyWith<_$Action_DecisionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
