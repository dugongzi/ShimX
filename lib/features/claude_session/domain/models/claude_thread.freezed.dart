// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'claude_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClaudeThread {

/// 文件名里的 uuid(去 .jsonl 后缀)
 String get sessionId;/// 完整 jsonl 路径,做 detail 加载用
 String get jsonlPath;/// 显示标题(首条 user 文本截断到 60 字符)
 String get title;/// 列表预览(同 title,可能更长一些用于副标题)
 String get preview;/// 会话 cwd(jsonl 头部里的 cwd 字段)
 String get cwd;/// git 分支(可能为空)
 String get gitBranch;/// 文件 mtime
 int get updatedAtMs;/// 文件 ctime
 int get createdAtMs;/// 文件大小(字节),做粗略判断是否大文件
 int get sizeBytes;
/// Create a copy of ClaudeThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeThreadCopyWith<ClaudeThread> get copyWith => _$ClaudeThreadCopyWithImpl<ClaudeThread>(this as ClaudeThread, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeThread&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.jsonlPath, jsonlPath) || other.jsonlPath == jsonlPath)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.gitBranch, gitBranch) || other.gitBranch == gitBranch)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,jsonlPath,title,preview,cwd,gitBranch,updatedAtMs,createdAtMs,sizeBytes);

@override
String toString() {
  return 'ClaudeThread(sessionId: $sessionId, jsonlPath: $jsonlPath, title: $title, preview: $preview, cwd: $cwd, gitBranch: $gitBranch, updatedAtMs: $updatedAtMs, createdAtMs: $createdAtMs, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class $ClaudeThreadCopyWith<$Res>  {
  factory $ClaudeThreadCopyWith(ClaudeThread value, $Res Function(ClaudeThread) _then) = _$ClaudeThreadCopyWithImpl;
@useResult
$Res call({
 String sessionId, String jsonlPath, String title, String preview, String cwd, String gitBranch, int updatedAtMs, int createdAtMs, int sizeBytes
});




}
/// @nodoc
class _$ClaudeThreadCopyWithImpl<$Res>
    implements $ClaudeThreadCopyWith<$Res> {
  _$ClaudeThreadCopyWithImpl(this._self, this._then);

  final ClaudeThread _self;
  final $Res Function(ClaudeThread) _then;

/// Create a copy of ClaudeThread
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


/// Adds pattern-matching-related methods to [ClaudeThread].
extension ClaudeThreadPatterns on ClaudeThread {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClaudeThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClaudeThread() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClaudeThread value)  $default,){
final _that = this;
switch (_that) {
case _ClaudeThread():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClaudeThread value)?  $default,){
final _that = this;
switch (_that) {
case _ClaudeThread() when $default != null:
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
case _ClaudeThread() when $default != null:
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
case _ClaudeThread():
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
case _ClaudeThread() when $default != null:
return $default(_that.sessionId,_that.jsonlPath,_that.title,_that.preview,_that.cwd,_that.gitBranch,_that.updatedAtMs,_that.createdAtMs,_that.sizeBytes);case _:
  return null;

}
}

}

/// @nodoc


class _ClaudeThread extends ClaudeThread {
  const _ClaudeThread({required this.sessionId, required this.jsonlPath, required this.title, required this.preview, required this.cwd, required this.gitBranch, required this.updatedAtMs, required this.createdAtMs, required this.sizeBytes}): super._();
  

/// 文件名里的 uuid(去 .jsonl 后缀)
@override final  String sessionId;
/// 完整 jsonl 路径,做 detail 加载用
@override final  String jsonlPath;
/// 显示标题(首条 user 文本截断到 60 字符)
@override final  String title;
/// 列表预览(同 title,可能更长一些用于副标题)
@override final  String preview;
/// 会话 cwd(jsonl 头部里的 cwd 字段)
@override final  String cwd;
/// git 分支(可能为空)
@override final  String gitBranch;
/// 文件 mtime
@override final  int updatedAtMs;
/// 文件 ctime
@override final  int createdAtMs;
/// 文件大小(字节),做粗略判断是否大文件
@override final  int sizeBytes;

/// Create a copy of ClaudeThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudeThreadCopyWith<_ClaudeThread> get copyWith => __$ClaudeThreadCopyWithImpl<_ClaudeThread>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudeThread&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.jsonlPath, jsonlPath) || other.jsonlPath == jsonlPath)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.gitBranch, gitBranch) || other.gitBranch == gitBranch)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,jsonlPath,title,preview,cwd,gitBranch,updatedAtMs,createdAtMs,sizeBytes);

@override
String toString() {
  return 'ClaudeThread(sessionId: $sessionId, jsonlPath: $jsonlPath, title: $title, preview: $preview, cwd: $cwd, gitBranch: $gitBranch, updatedAtMs: $updatedAtMs, createdAtMs: $createdAtMs, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class _$ClaudeThreadCopyWith<$Res> implements $ClaudeThreadCopyWith<$Res> {
  factory _$ClaudeThreadCopyWith(_ClaudeThread value, $Res Function(_ClaudeThread) _then) = __$ClaudeThreadCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String jsonlPath, String title, String preview, String cwd, String gitBranch, int updatedAtMs, int createdAtMs, int sizeBytes
});




}
/// @nodoc
class __$ClaudeThreadCopyWithImpl<$Res>
    implements _$ClaudeThreadCopyWith<$Res> {
  __$ClaudeThreadCopyWithImpl(this._self, this._then);

  final _ClaudeThread _self;
  final $Res Function(_ClaudeThread) _then;

/// Create a copy of ClaudeThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? jsonlPath = null,Object? title = null,Object? preview = null,Object? cwd = null,Object? gitBranch = null,Object? updatedAtMs = null,Object? createdAtMs = null,Object? sizeBytes = null,}) {
  return _then(_ClaudeThread(
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
