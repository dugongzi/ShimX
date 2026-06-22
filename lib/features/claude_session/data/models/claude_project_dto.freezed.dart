// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'claude_project_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClaudeProjectDto {

 String get encodedDir; String get cwd; int get sessionCount; int get lastActiveMs;
/// Create a copy of ClaudeProjectDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeProjectDtoCopyWith<ClaudeProjectDto> get copyWith => _$ClaudeProjectDtoCopyWithImpl<ClaudeProjectDto>(this as ClaudeProjectDto, _$identity);

  /// Serializes this ClaudeProjectDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeProjectDto&&(identical(other.encodedDir, encodedDir) || other.encodedDir == encodedDir)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.lastActiveMs, lastActiveMs) || other.lastActiveMs == lastActiveMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,encodedDir,cwd,sessionCount,lastActiveMs);

@override
String toString() {
  return 'ClaudeProjectDto(encodedDir: $encodedDir, cwd: $cwd, sessionCount: $sessionCount, lastActiveMs: $lastActiveMs)';
}


}

/// @nodoc
abstract mixin class $ClaudeProjectDtoCopyWith<$Res>  {
  factory $ClaudeProjectDtoCopyWith(ClaudeProjectDto value, $Res Function(ClaudeProjectDto) _then) = _$ClaudeProjectDtoCopyWithImpl;
@useResult
$Res call({
 String encodedDir, String cwd, int sessionCount, int lastActiveMs
});




}
/// @nodoc
class _$ClaudeProjectDtoCopyWithImpl<$Res>
    implements $ClaudeProjectDtoCopyWith<$Res> {
  _$ClaudeProjectDtoCopyWithImpl(this._self, this._then);

  final ClaudeProjectDto _self;
  final $Res Function(ClaudeProjectDto) _then;

/// Create a copy of ClaudeProjectDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? encodedDir = null,Object? cwd = null,Object? sessionCount = null,Object? lastActiveMs = null,}) {
  return _then(_self.copyWith(
encodedDir: null == encodedDir ? _self.encodedDir : encodedDir // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,lastActiveMs: null == lastActiveMs ? _self.lastActiveMs : lastActiveMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ClaudeProjectDto].
extension ClaudeProjectDtoPatterns on ClaudeProjectDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClaudeProjectDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClaudeProjectDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClaudeProjectDto value)  $default,){
final _that = this;
switch (_that) {
case _ClaudeProjectDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClaudeProjectDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClaudeProjectDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String encodedDir,  String cwd,  int sessionCount,  int lastActiveMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClaudeProjectDto() when $default != null:
return $default(_that.encodedDir,_that.cwd,_that.sessionCount,_that.lastActiveMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String encodedDir,  String cwd,  int sessionCount,  int lastActiveMs)  $default,) {final _that = this;
switch (_that) {
case _ClaudeProjectDto():
return $default(_that.encodedDir,_that.cwd,_that.sessionCount,_that.lastActiveMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String encodedDir,  String cwd,  int sessionCount,  int lastActiveMs)?  $default,) {final _that = this;
switch (_that) {
case _ClaudeProjectDto() when $default != null:
return $default(_that.encodedDir,_that.cwd,_that.sessionCount,_that.lastActiveMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClaudeProjectDto extends ClaudeProjectDto {
  const _ClaudeProjectDto({this.encodedDir = '', this.cwd = '', this.sessionCount = 0, this.lastActiveMs = 0}): super._();
  factory _ClaudeProjectDto.fromJson(Map<String, dynamic> json) => _$ClaudeProjectDtoFromJson(json);

@override@JsonKey() final  String encodedDir;
@override@JsonKey() final  String cwd;
@override@JsonKey() final  int sessionCount;
@override@JsonKey() final  int lastActiveMs;

/// Create a copy of ClaudeProjectDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudeProjectDtoCopyWith<_ClaudeProjectDto> get copyWith => __$ClaudeProjectDtoCopyWithImpl<_ClaudeProjectDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClaudeProjectDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudeProjectDto&&(identical(other.encodedDir, encodedDir) || other.encodedDir == encodedDir)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.lastActiveMs, lastActiveMs) || other.lastActiveMs == lastActiveMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,encodedDir,cwd,sessionCount,lastActiveMs);

@override
String toString() {
  return 'ClaudeProjectDto(encodedDir: $encodedDir, cwd: $cwd, sessionCount: $sessionCount, lastActiveMs: $lastActiveMs)';
}


}

/// @nodoc
abstract mixin class _$ClaudeProjectDtoCopyWith<$Res> implements $ClaudeProjectDtoCopyWith<$Res> {
  factory _$ClaudeProjectDtoCopyWith(_ClaudeProjectDto value, $Res Function(_ClaudeProjectDto) _then) = __$ClaudeProjectDtoCopyWithImpl;
@override @useResult
$Res call({
 String encodedDir, String cwd, int sessionCount, int lastActiveMs
});




}
/// @nodoc
class __$ClaudeProjectDtoCopyWithImpl<$Res>
    implements _$ClaudeProjectDtoCopyWith<$Res> {
  __$ClaudeProjectDtoCopyWithImpl(this._self, this._then);

  final _ClaudeProjectDto _self;
  final $Res Function(_ClaudeProjectDto) _then;

/// Create a copy of ClaudeProjectDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? encodedDir = null,Object? cwd = null,Object? sessionCount = null,Object? lastActiveMs = null,}) {
  return _then(_ClaudeProjectDto(
encodedDir: null == encodedDir ? _self.encodedDir : encodedDir // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,lastActiveMs: null == lastActiveMs ? _self.lastActiveMs : lastActiveMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
