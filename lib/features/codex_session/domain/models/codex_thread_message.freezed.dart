// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_thread_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodexThreadMessage {

/// 0-based 在 rollout 流里的位置
 int get index;/// 事件时间戳(ISO 8601 UTC)。可能为空字符串,表示没拿到。
 String get timestamp;/// user / assistant / developer / system / tool
 String get role;/// text / tool_use / tool_result / raws
 String get kind;/// 纯文本内容(tool_use 时是 "<toolName>(<jsonArgs>)" 之类的字符串描述)
 String get text;
/// Create a copy of CodexThreadMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexThreadMessageCopyWith<CodexThreadMessage> get copyWith => _$CodexThreadMessageCopyWithImpl<CodexThreadMessage>(this as CodexThreadMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexThreadMessage&&(identical(other.index, index) || other.index == index)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.role, role) || other.role == role)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,index,timestamp,role,kind,text);

@override
String toString() {
  return 'CodexThreadMessage(index: $index, timestamp: $timestamp, role: $role, kind: $kind, text: $text)';
}


}

/// @nodoc
abstract mixin class $CodexThreadMessageCopyWith<$Res>  {
  factory $CodexThreadMessageCopyWith(CodexThreadMessage value, $Res Function(CodexThreadMessage) _then) = _$CodexThreadMessageCopyWithImpl;
@useResult
$Res call({
 int index, String timestamp, String role, String kind, String text
});




}
/// @nodoc
class _$CodexThreadMessageCopyWithImpl<$Res>
    implements $CodexThreadMessageCopyWith<$Res> {
  _$CodexThreadMessageCopyWithImpl(this._self, this._then);

  final CodexThreadMessage _self;
  final $Res Function(CodexThreadMessage) _then;

/// Create a copy of CodexThreadMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? timestamp = null,Object? role = null,Object? kind = null,Object? text = null,}) {
  return _then(_self.copyWith(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexThreadMessage].
extension CodexThreadMessagePatterns on CodexThreadMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexThreadMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexThreadMessage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexThreadMessage value)  $default,){
final _that = this;
switch (_that) {
case _CodexThreadMessage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexThreadMessage value)?  $default,){
final _that = this;
switch (_that) {
case _CodexThreadMessage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  String timestamp,  String role,  String kind,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexThreadMessage() when $default != null:
return $default(_that.index,_that.timestamp,_that.role,_that.kind,_that.text);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  String timestamp,  String role,  String kind,  String text)  $default,) {final _that = this;
switch (_that) {
case _CodexThreadMessage():
return $default(_that.index,_that.timestamp,_that.role,_that.kind,_that.text);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  String timestamp,  String role,  String kind,  String text)?  $default,) {final _that = this;
switch (_that) {
case _CodexThreadMessage() when $default != null:
return $default(_that.index,_that.timestamp,_that.role,_that.kind,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _CodexThreadMessage extends CodexThreadMessage {
  const _CodexThreadMessage({required this.index, required this.timestamp, required this.role, required this.kind, required this.text}): super._();
  

/// 0-based 在 rollout 流里的位置
@override final  int index;
/// 事件时间戳(ISO 8601 UTC)。可能为空字符串,表示没拿到。
@override final  String timestamp;
/// user / assistant / developer / system / tool
@override final  String role;
/// text / tool_use / tool_result / raws
@override final  String kind;
/// 纯文本内容(tool_use 时是 "<toolName>(<jsonArgs>)" 之类的字符串描述)
@override final  String text;

/// Create a copy of CodexThreadMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexThreadMessageCopyWith<_CodexThreadMessage> get copyWith => __$CodexThreadMessageCopyWithImpl<_CodexThreadMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexThreadMessage&&(identical(other.index, index) || other.index == index)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.role, role) || other.role == role)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,index,timestamp,role,kind,text);

@override
String toString() {
  return 'CodexThreadMessage(index: $index, timestamp: $timestamp, role: $role, kind: $kind, text: $text)';
}


}

/// @nodoc
abstract mixin class _$CodexThreadMessageCopyWith<$Res> implements $CodexThreadMessageCopyWith<$Res> {
  factory _$CodexThreadMessageCopyWith(_CodexThreadMessage value, $Res Function(_CodexThreadMessage) _then) = __$CodexThreadMessageCopyWithImpl;
@override @useResult
$Res call({
 int index, String timestamp, String role, String kind, String text
});




}
/// @nodoc
class __$CodexThreadMessageCopyWithImpl<$Res>
    implements _$CodexThreadMessageCopyWith<$Res> {
  __$CodexThreadMessageCopyWithImpl(this._self, this._then);

  final _CodexThreadMessage _self;
  final $Res Function(_CodexThreadMessage) _then;

/// Create a copy of CodexThreadMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? timestamp = null,Object? role = null,Object? kind = null,Object? text = null,}) {
  return _then(_CodexThreadMessage(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
