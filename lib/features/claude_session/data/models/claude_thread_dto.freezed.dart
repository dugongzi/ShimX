// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'claude_thread_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClaudeThreadDto {

 String get sessionId; String get jsonlPath; String get title; String get preview; String get cwd; String get gitBranch; int get updatedAtMs; int get createdAtMs; int get sizeBytes;
/// Create a copy of ClaudeThreadDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeThreadDtoCopyWith<ClaudeThreadDto> get copyWith => _$ClaudeThreadDtoCopyWithImpl<ClaudeThreadDto>(this as ClaudeThreadDto, _$identity);

  /// Serializes this ClaudeThreadDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeThreadDto&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.jsonlPath, jsonlPath) || other.jsonlPath == jsonlPath)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.gitBranch, gitBranch) || other.gitBranch == gitBranch)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,jsonlPath,title,preview,cwd,gitBranch,updatedAtMs,createdAtMs,sizeBytes);

@override
String toString() {
  return 'ClaudeThreadDto(sessionId: $sessionId, jsonlPath: $jsonlPath, title: $title, preview: $preview, cwd: $cwd, gitBranch: $gitBranch, updatedAtMs: $updatedAtMs, createdAtMs: $createdAtMs, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class $ClaudeThreadDtoCopyWith<$Res>  {
  factory $ClaudeThreadDtoCopyWith(ClaudeThreadDto value, $Res Function(ClaudeThreadDto) _then) = _$ClaudeThreadDtoCopyWithImpl;
@useResult
$Res call({
 String sessionId, String jsonlPath, String title, String preview, String cwd, String gitBranch, int updatedAtMs, int createdAtMs, int sizeBytes
});




}
/// @nodoc
class _$ClaudeThreadDtoCopyWithImpl<$Res>
    implements $ClaudeThreadDtoCopyWith<$Res> {
  _$ClaudeThreadDtoCopyWithImpl(this._self, this._then);

  final ClaudeThreadDto _self;
  final $Res Function(ClaudeThreadDto) _then;

/// Create a copy of ClaudeThreadDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? jsonlPath = null,Object? title = null,Object? preview = null,Object? cwd = null,Object? gitBranch = null,Object? updatedAtMs = null,Object? createdAtMs = null,Object? sizeBytes = null,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,jsonlPath: null == jsonlPath ? _self.jsonlPath : jsonlPath // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,gitBranch: null == gitBranch ? _self.gitBranch : gitBranch // ignore: cast_nullable_to_non_nullable
as String,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ClaudeThreadDto].
extension ClaudeThreadDtoPatterns on ClaudeThreadDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClaudeThreadDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClaudeThreadDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClaudeThreadDto value)  $default,){
final _that = this;
switch (_that) {
case _ClaudeThreadDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClaudeThreadDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClaudeThreadDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String jsonlPath,  String title,  String preview,  String cwd,  String gitBranch,  int updatedAtMs,  int createdAtMs,  int sizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClaudeThreadDto() when $default != null:
return $default(_that.sessionId,_that.jsonlPath,_that.title,_that.preview,_that.cwd,_that.gitBranch,_that.updatedAtMs,_that.createdAtMs,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String jsonlPath,  String title,  String preview,  String cwd,  String gitBranch,  int updatedAtMs,  int createdAtMs,  int sizeBytes)  $default,) {final _that = this;
switch (_that) {
case _ClaudeThreadDto():
return $default(_that.sessionId,_that.jsonlPath,_that.title,_that.preview,_that.cwd,_that.gitBranch,_that.updatedAtMs,_that.createdAtMs,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String jsonlPath,  String title,  String preview,  String cwd,  String gitBranch,  int updatedAtMs,  int createdAtMs,  int sizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _ClaudeThreadDto() when $default != null:
return $default(_that.sessionId,_that.jsonlPath,_that.title,_that.preview,_that.cwd,_that.gitBranch,_that.updatedAtMs,_that.createdAtMs,_that.sizeBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClaudeThreadDto extends ClaudeThreadDto {
  const _ClaudeThreadDto({this.sessionId = '', this.jsonlPath = '', this.title = '', this.preview = '', this.cwd = '', this.gitBranch = '', this.updatedAtMs = 0, this.createdAtMs = 0, this.sizeBytes = 0}): super._();
  factory _ClaudeThreadDto.fromJson(Map<String, dynamic> json) => _$ClaudeThreadDtoFromJson(json);

@override@JsonKey() final  String sessionId;
@override@JsonKey() final  String jsonlPath;
@override@JsonKey() final  String title;
@override@JsonKey() final  String preview;
@override@JsonKey() final  String cwd;
@override@JsonKey() final  String gitBranch;
@override@JsonKey() final  int updatedAtMs;
@override@JsonKey() final  int createdAtMs;
@override@JsonKey() final  int sizeBytes;

/// Create a copy of ClaudeThreadDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudeThreadDtoCopyWith<_ClaudeThreadDto> get copyWith => __$ClaudeThreadDtoCopyWithImpl<_ClaudeThreadDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClaudeThreadDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudeThreadDto&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.jsonlPath, jsonlPath) || other.jsonlPath == jsonlPath)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.gitBranch, gitBranch) || other.gitBranch == gitBranch)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,jsonlPath,title,preview,cwd,gitBranch,updatedAtMs,createdAtMs,sizeBytes);

@override
String toString() {
  return 'ClaudeThreadDto(sessionId: $sessionId, jsonlPath: $jsonlPath, title: $title, preview: $preview, cwd: $cwd, gitBranch: $gitBranch, updatedAtMs: $updatedAtMs, createdAtMs: $createdAtMs, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class _$ClaudeThreadDtoCopyWith<$Res> implements $ClaudeThreadDtoCopyWith<$Res> {
  factory _$ClaudeThreadDtoCopyWith(_ClaudeThreadDto value, $Res Function(_ClaudeThreadDto) _then) = __$ClaudeThreadDtoCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String jsonlPath, String title, String preview, String cwd, String gitBranch, int updatedAtMs, int createdAtMs, int sizeBytes
});




}
/// @nodoc
class __$ClaudeThreadDtoCopyWithImpl<$Res>
    implements _$ClaudeThreadDtoCopyWith<$Res> {
  __$ClaudeThreadDtoCopyWithImpl(this._self, this._then);

  final _ClaudeThreadDto _self;
  final $Res Function(_ClaudeThreadDto) _then;

/// Create a copy of ClaudeThreadDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? jsonlPath = null,Object? title = null,Object? preview = null,Object? cwd = null,Object? gitBranch = null,Object? updatedAtMs = null,Object? createdAtMs = null,Object? sizeBytes = null,}) {
  return _then(_ClaudeThreadDto(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,jsonlPath: null == jsonlPath ? _self.jsonlPath : jsonlPath // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,gitBranch: null == gitBranch ? _self.gitBranch : gitBranch // ignore: cast_nullable_to_non_nullable
as String,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
