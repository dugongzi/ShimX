// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'claude_project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClaudeProject {

/// 目录名(原始,作为 ID 用),例如 `f--Programming-projects-FlutterProject-shimx`
 String get encodedDir;/// 解码后的 cwd(优先取 jsonl 内的 cwd 字段,fallback 用 encodedDir 推算)
 String get cwd;/// 会话数(jsonl 文件数)
 int get sessionCount;/// 该项目最近活跃时间 = max(jsonl mtime)
 int get lastActiveMs;
/// Create a copy of ClaudeProject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeProjectCopyWith<ClaudeProject> get copyWith => _$ClaudeProjectCopyWithImpl<ClaudeProject>(this as ClaudeProject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeProject&&(identical(other.encodedDir, encodedDir) || other.encodedDir == encodedDir)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.lastActiveMs, lastActiveMs) || other.lastActiveMs == lastActiveMs));
}


@override
int get hashCode => Object.hash(runtimeType,encodedDir,cwd,sessionCount,lastActiveMs);

@override
String toString() {
  return 'ClaudeProject(encodedDir: $encodedDir, cwd: $cwd, sessionCount: $sessionCount, lastActiveMs: $lastActiveMs)';
}


}

/// @nodoc
abstract mixin class $ClaudeProjectCopyWith<$Res>  {
  factory $ClaudeProjectCopyWith(ClaudeProject value, $Res Function(ClaudeProject) _then) = _$ClaudeProjectCopyWithImpl;
@useResult
$Res call({
 String encodedDir, String cwd, int sessionCount, int lastActiveMs
});




}
/// @nodoc
class _$ClaudeProjectCopyWithImpl<$Res>
    implements $ClaudeProjectCopyWith<$Res> {
  _$ClaudeProjectCopyWithImpl(this._self, this._then);

  final ClaudeProject _self;
  final $Res Function(ClaudeProject) _then;

/// Create a copy of ClaudeProject
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


/// Adds pattern-matching-related methods to [ClaudeProject].
extension ClaudeProjectPatterns on ClaudeProject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClaudeProject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClaudeProject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClaudeProject value)  $default,){
final _that = this;
switch (_that) {
case _ClaudeProject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClaudeProject value)?  $default,){
final _that = this;
switch (_that) {
case _ClaudeProject() when $default != null:
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
case _ClaudeProject() when $default != null:
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
case _ClaudeProject():
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
case _ClaudeProject() when $default != null:
return $default(_that.encodedDir,_that.cwd,_that.sessionCount,_that.lastActiveMs);case _:
  return null;

}
}

}

/// @nodoc


class _ClaudeProject extends ClaudeProject {
  const _ClaudeProject({required this.encodedDir, required this.cwd, required this.sessionCount, required this.lastActiveMs}): super._();
  

/// 目录名(原始,作为 ID 用),例如 `f--Programming-projects-FlutterProject-shimx`
@override final  String encodedDir;
/// 解码后的 cwd(优先取 jsonl 内的 cwd 字段,fallback 用 encodedDir 推算)
@override final  String cwd;
/// 会话数(jsonl 文件数)
@override final  int sessionCount;
/// 该项目最近活跃时间 = max(jsonl mtime)
@override final  int lastActiveMs;

/// Create a copy of ClaudeProject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudeProjectCopyWith<_ClaudeProject> get copyWith => __$ClaudeProjectCopyWithImpl<_ClaudeProject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudeProject&&(identical(other.encodedDir, encodedDir) || other.encodedDir == encodedDir)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.lastActiveMs, lastActiveMs) || other.lastActiveMs == lastActiveMs));
}


@override
int get hashCode => Object.hash(runtimeType,encodedDir,cwd,sessionCount,lastActiveMs);

@override
String toString() {
  return 'ClaudeProject(encodedDir: $encodedDir, cwd: $cwd, sessionCount: $sessionCount, lastActiveMs: $lastActiveMs)';
}


}

/// @nodoc
abstract mixin class _$ClaudeProjectCopyWith<$Res> implements $ClaudeProjectCopyWith<$Res> {
  factory _$ClaudeProjectCopyWith(_ClaudeProject value, $Res Function(_ClaudeProject) _then) = __$ClaudeProjectCopyWithImpl;
@override @useResult
$Res call({
 String encodedDir, String cwd, int sessionCount, int lastActiveMs
});




}
/// @nodoc
class __$ClaudeProjectCopyWithImpl<$Res>
    implements _$ClaudeProjectCopyWith<$Res> {
  __$ClaudeProjectCopyWithImpl(this._self, this._then);

  final _ClaudeProject _self;
  final $Res Function(_ClaudeProject) _then;

/// Create a copy of ClaudeProject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? encodedDir = null,Object? cwd = null,Object? sessionCount = null,Object? lastActiveMs = null,}) {
  return _then(_ClaudeProject(
encodedDir: null == encodedDir ? _self.encodedDir : encodedDir // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,lastActiveMs: null == lastActiveMs ? _self.lastActiveMs : lastActiveMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
