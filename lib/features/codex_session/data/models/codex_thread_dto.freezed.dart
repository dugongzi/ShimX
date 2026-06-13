// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_thread_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CodexThreadDto {

 String get id; String get title; String get preview; String get firstUserMessage; String get cwd; int get archived; int get updatedAtMs; int get createdAtMs; int get tokensUsed;
/// Create a copy of CodexThreadDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexThreadDtoCopyWith<CodexThreadDto> get copyWith => _$CodexThreadDtoCopyWithImpl<CodexThreadDto>(this as CodexThreadDto, _$identity);

  /// Serializes this CodexThreadDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexThreadDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.firstUserMessage, firstUserMessage) || other.firstUserMessage == firstUserMessage)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.tokensUsed, tokensUsed) || other.tokensUsed == tokensUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,preview,firstUserMessage,cwd,archived,updatedAtMs,createdAtMs,tokensUsed);

@override
String toString() {
  return 'CodexThreadDto(id: $id, title: $title, preview: $preview, firstUserMessage: $firstUserMessage, cwd: $cwd, archived: $archived, updatedAtMs: $updatedAtMs, createdAtMs: $createdAtMs, tokensUsed: $tokensUsed)';
}


}

/// @nodoc
abstract mixin class $CodexThreadDtoCopyWith<$Res>  {
  factory $CodexThreadDtoCopyWith(CodexThreadDto value, $Res Function(CodexThreadDto) _then) = _$CodexThreadDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title, String preview, String firstUserMessage, String cwd, int archived, int updatedAtMs, int createdAtMs, int tokensUsed
});




}
/// @nodoc
class _$CodexThreadDtoCopyWithImpl<$Res>
    implements $CodexThreadDtoCopyWith<$Res> {
  _$CodexThreadDtoCopyWithImpl(this._self, this._then);

  final CodexThreadDto _self;
  final $Res Function(CodexThreadDto) _then;

/// Create a copy of CodexThreadDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? preview = null,Object? firstUserMessage = null,Object? cwd = null,Object? archived = null,Object? updatedAtMs = null,Object? createdAtMs = null,Object? tokensUsed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,firstUserMessage: null == firstUserMessage ? _self.firstUserMessage : firstUserMessage // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,tokensUsed: null == tokensUsed ? _self.tokensUsed : tokensUsed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexThreadDto].
extension CodexThreadDtoPatterns on CodexThreadDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexThreadDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexThreadDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexThreadDto value)  $default,){
final _that = this;
switch (_that) {
case _CodexThreadDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexThreadDto value)?  $default,){
final _that = this;
switch (_that) {
case _CodexThreadDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String preview,  String firstUserMessage,  String cwd,  int archived,  int updatedAtMs,  int createdAtMs,  int tokensUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexThreadDto() when $default != null:
return $default(_that.id,_that.title,_that.preview,_that.firstUserMessage,_that.cwd,_that.archived,_that.updatedAtMs,_that.createdAtMs,_that.tokensUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String preview,  String firstUserMessage,  String cwd,  int archived,  int updatedAtMs,  int createdAtMs,  int tokensUsed)  $default,) {final _that = this;
switch (_that) {
case _CodexThreadDto():
return $default(_that.id,_that.title,_that.preview,_that.firstUserMessage,_that.cwd,_that.archived,_that.updatedAtMs,_that.createdAtMs,_that.tokensUsed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String preview,  String firstUserMessage,  String cwd,  int archived,  int updatedAtMs,  int createdAtMs,  int tokensUsed)?  $default,) {final _that = this;
switch (_that) {
case _CodexThreadDto() when $default != null:
return $default(_that.id,_that.title,_that.preview,_that.firstUserMessage,_that.cwd,_that.archived,_that.updatedAtMs,_that.createdAtMs,_that.tokensUsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CodexThreadDto extends CodexThreadDto {
  const _CodexThreadDto({this.id = '', this.title = '', this.preview = '', this.firstUserMessage = '', this.cwd = '', this.archived = 0, this.updatedAtMs = 0, this.createdAtMs = 0, this.tokensUsed = 0}): super._();
  factory _CodexThreadDto.fromJson(Map<String, dynamic> json) => _$CodexThreadDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String preview;
@override@JsonKey() final  String firstUserMessage;
@override@JsonKey() final  String cwd;
@override@JsonKey() final  int archived;
@override@JsonKey() final  int updatedAtMs;
@override@JsonKey() final  int createdAtMs;
@override@JsonKey() final  int tokensUsed;

/// Create a copy of CodexThreadDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexThreadDtoCopyWith<_CodexThreadDto> get copyWith => __$CodexThreadDtoCopyWithImpl<_CodexThreadDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodexThreadDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexThreadDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.firstUserMessage, firstUserMessage) || other.firstUserMessage == firstUserMessage)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.tokensUsed, tokensUsed) || other.tokensUsed == tokensUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,preview,firstUserMessage,cwd,archived,updatedAtMs,createdAtMs,tokensUsed);

@override
String toString() {
  return 'CodexThreadDto(id: $id, title: $title, preview: $preview, firstUserMessage: $firstUserMessage, cwd: $cwd, archived: $archived, updatedAtMs: $updatedAtMs, createdAtMs: $createdAtMs, tokensUsed: $tokensUsed)';
}


}

/// @nodoc
abstract mixin class _$CodexThreadDtoCopyWith<$Res> implements $CodexThreadDtoCopyWith<$Res> {
  factory _$CodexThreadDtoCopyWith(_CodexThreadDto value, $Res Function(_CodexThreadDto) _then) = __$CodexThreadDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String preview, String firstUserMessage, String cwd, int archived, int updatedAtMs, int createdAtMs, int tokensUsed
});




}
/// @nodoc
class __$CodexThreadDtoCopyWithImpl<$Res>
    implements _$CodexThreadDtoCopyWith<$Res> {
  __$CodexThreadDtoCopyWithImpl(this._self, this._then);

  final _CodexThreadDto _self;
  final $Res Function(_CodexThreadDto) _then;

/// Create a copy of CodexThreadDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? preview = null,Object? firstUserMessage = null,Object? cwd = null,Object? archived = null,Object? updatedAtMs = null,Object? createdAtMs = null,Object? tokensUsed = null,}) {
  return _then(_CodexThreadDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,firstUserMessage: null == firstUserMessage ? _self.firstUserMessage : firstUserMessage // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,tokensUsed: null == tokensUsed ? _self.tokensUsed : tokensUsed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
