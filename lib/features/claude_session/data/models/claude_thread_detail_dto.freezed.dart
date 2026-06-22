// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'claude_thread_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClaudeThreadDetailDto {

 String get sessionId; String get title; String get cwd; String get gitBranch; String get cliVersion; String get jsonlPath; int get createdAtMs; int get updatedAtMs; List<ClaudeThreadMessageDto> get messages;
/// Create a copy of ClaudeThreadDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeThreadDetailDtoCopyWith<ClaudeThreadDetailDto> get copyWith => _$ClaudeThreadDetailDtoCopyWithImpl<ClaudeThreadDetailDto>(this as ClaudeThreadDetailDto, _$identity);

  /// Serializes this ClaudeThreadDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeThreadDetailDto&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.title, title) || other.title == title)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.gitBranch, gitBranch) || other.gitBranch == gitBranch)&&(identical(other.cliVersion, cliVersion) || other.cliVersion == cliVersion)&&(identical(other.jsonlPath, jsonlPath) || other.jsonlPath == jsonlPath)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&const DeepCollectionEquality().equals(other.messages, messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,title,cwd,gitBranch,cliVersion,jsonlPath,createdAtMs,updatedAtMs,const DeepCollectionEquality().hash(messages));

@override
String toString() {
  return 'ClaudeThreadDetailDto(sessionId: $sessionId, title: $title, cwd: $cwd, gitBranch: $gitBranch, cliVersion: $cliVersion, jsonlPath: $jsonlPath, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs, messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ClaudeThreadDetailDtoCopyWith<$Res>  {
  factory $ClaudeThreadDetailDtoCopyWith(ClaudeThreadDetailDto value, $Res Function(ClaudeThreadDetailDto) _then) = _$ClaudeThreadDetailDtoCopyWithImpl;
@useResult
$Res call({
 String sessionId, String title, String cwd, String gitBranch, String cliVersion, String jsonlPath, int createdAtMs, int updatedAtMs, List<ClaudeThreadMessageDto> messages
});




}
/// @nodoc
class _$ClaudeThreadDetailDtoCopyWithImpl<$Res>
    implements $ClaudeThreadDetailDtoCopyWith<$Res> {
  _$ClaudeThreadDetailDtoCopyWithImpl(this._self, this._then);

  final ClaudeThreadDetailDto _self;
  final $Res Function(ClaudeThreadDetailDto) _then;

/// Create a copy of ClaudeThreadDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? title = null,Object? cwd = null,Object? gitBranch = null,Object? cliVersion = null,Object? jsonlPath = null,Object? createdAtMs = null,Object? updatedAtMs = null,Object? messages = null,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,gitBranch: null == gitBranch ? _self.gitBranch : gitBranch // ignore: cast_nullable_to_non_nullable
as String,cliVersion: null == cliVersion ? _self.cliVersion : cliVersion // ignore: cast_nullable_to_non_nullable
as String,jsonlPath: null == jsonlPath ? _self.jsonlPath : jsonlPath // ignore: cast_nullable_to_non_nullable
as String,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ClaudeThreadMessageDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClaudeThreadDetailDto].
extension ClaudeThreadDetailDtoPatterns on ClaudeThreadDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClaudeThreadDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClaudeThreadDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClaudeThreadDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _ClaudeThreadDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClaudeThreadDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClaudeThreadDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String title,  String cwd,  String gitBranch,  String cliVersion,  String jsonlPath,  int createdAtMs,  int updatedAtMs,  List<ClaudeThreadMessageDto> messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClaudeThreadDetailDto() when $default != null:
return $default(_that.sessionId,_that.title,_that.cwd,_that.gitBranch,_that.cliVersion,_that.jsonlPath,_that.createdAtMs,_that.updatedAtMs,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String title,  String cwd,  String gitBranch,  String cliVersion,  String jsonlPath,  int createdAtMs,  int updatedAtMs,  List<ClaudeThreadMessageDto> messages)  $default,) {final _that = this;
switch (_that) {
case _ClaudeThreadDetailDto():
return $default(_that.sessionId,_that.title,_that.cwd,_that.gitBranch,_that.cliVersion,_that.jsonlPath,_that.createdAtMs,_that.updatedAtMs,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String title,  String cwd,  String gitBranch,  String cliVersion,  String jsonlPath,  int createdAtMs,  int updatedAtMs,  List<ClaudeThreadMessageDto> messages)?  $default,) {final _that = this;
switch (_that) {
case _ClaudeThreadDetailDto() when $default != null:
return $default(_that.sessionId,_that.title,_that.cwd,_that.gitBranch,_that.cliVersion,_that.jsonlPath,_that.createdAtMs,_that.updatedAtMs,_that.messages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClaudeThreadDetailDto extends ClaudeThreadDetailDto {
  const _ClaudeThreadDetailDto({this.sessionId = '', this.title = '', this.cwd = '', this.gitBranch = '', this.cliVersion = '', this.jsonlPath = '', this.createdAtMs = 0, this.updatedAtMs = 0, final  List<ClaudeThreadMessageDto> messages = const []}): _messages = messages,super._();
  factory _ClaudeThreadDetailDto.fromJson(Map<String, dynamic> json) => _$ClaudeThreadDetailDtoFromJson(json);

@override@JsonKey() final  String sessionId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String cwd;
@override@JsonKey() final  String gitBranch;
@override@JsonKey() final  String cliVersion;
@override@JsonKey() final  String jsonlPath;
@override@JsonKey() final  int createdAtMs;
@override@JsonKey() final  int updatedAtMs;
 final  List<ClaudeThreadMessageDto> _messages;
@override@JsonKey() List<ClaudeThreadMessageDto> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of ClaudeThreadDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudeThreadDetailDtoCopyWith<_ClaudeThreadDetailDto> get copyWith => __$ClaudeThreadDetailDtoCopyWithImpl<_ClaudeThreadDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClaudeThreadDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudeThreadDetailDto&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.title, title) || other.title == title)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.gitBranch, gitBranch) || other.gitBranch == gitBranch)&&(identical(other.cliVersion, cliVersion) || other.cliVersion == cliVersion)&&(identical(other.jsonlPath, jsonlPath) || other.jsonlPath == jsonlPath)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&const DeepCollectionEquality().equals(other._messages, _messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,title,cwd,gitBranch,cliVersion,jsonlPath,createdAtMs,updatedAtMs,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'ClaudeThreadDetailDto(sessionId: $sessionId, title: $title, cwd: $cwd, gitBranch: $gitBranch, cliVersion: $cliVersion, jsonlPath: $jsonlPath, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$ClaudeThreadDetailDtoCopyWith<$Res> implements $ClaudeThreadDetailDtoCopyWith<$Res> {
  factory _$ClaudeThreadDetailDtoCopyWith(_ClaudeThreadDetailDto value, $Res Function(_ClaudeThreadDetailDto) _then) = __$ClaudeThreadDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String title, String cwd, String gitBranch, String cliVersion, String jsonlPath, int createdAtMs, int updatedAtMs, List<ClaudeThreadMessageDto> messages
});




}
/// @nodoc
class __$ClaudeThreadDetailDtoCopyWithImpl<$Res>
    implements _$ClaudeThreadDetailDtoCopyWith<$Res> {
  __$ClaudeThreadDetailDtoCopyWithImpl(this._self, this._then);

  final _ClaudeThreadDetailDto _self;
  final $Res Function(_ClaudeThreadDetailDto) _then;

/// Create a copy of ClaudeThreadDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? title = null,Object? cwd = null,Object? gitBranch = null,Object? cliVersion = null,Object? jsonlPath = null,Object? createdAtMs = null,Object? updatedAtMs = null,Object? messages = null,}) {
  return _then(_ClaudeThreadDetailDto(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,gitBranch: null == gitBranch ? _self.gitBranch : gitBranch // ignore: cast_nullable_to_non_nullable
as String,cliVersion: null == cliVersion ? _self.cliVersion : cliVersion // ignore: cast_nullable_to_non_nullable
as String,jsonlPath: null == jsonlPath ? _self.jsonlPath : jsonlPath // ignore: cast_nullable_to_non_nullable
as String,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ClaudeThreadMessageDto>,
  ));
}


}

// dart format on
