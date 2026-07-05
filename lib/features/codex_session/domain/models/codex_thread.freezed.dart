// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodexThread {

 String get id; String get title; String get preview; String get firstUserMessage; String get cwd; bool get archived; int get updatedAtMs; int get createdAtMs; int get tokensUsed; String get modelProvider;
/// Create a copy of CodexThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexThreadCopyWith<CodexThread> get copyWith => _$CodexThreadCopyWithImpl<CodexThread>(this as CodexThread, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexThread&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.firstUserMessage, firstUserMessage) || other.firstUserMessage == firstUserMessage)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.tokensUsed, tokensUsed) || other.tokensUsed == tokensUsed)&&(identical(other.modelProvider, modelProvider) || other.modelProvider == modelProvider));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,preview,firstUserMessage,cwd,archived,updatedAtMs,createdAtMs,tokensUsed,modelProvider);

@override
String toString() {
  return 'CodexThread(id: $id, title: $title, preview: $preview, firstUserMessage: $firstUserMessage, cwd: $cwd, archived: $archived, updatedAtMs: $updatedAtMs, createdAtMs: $createdAtMs, tokensUsed: $tokensUsed, modelProvider: $modelProvider)';
}


}

/// @nodoc
abstract mixin class $CodexThreadCopyWith<$Res>  {
  factory $CodexThreadCopyWith(CodexThread value, $Res Function(CodexThread) _then) = _$CodexThreadCopyWithImpl;
@useResult
$Res call({
 String id, String title, String preview, String firstUserMessage, String cwd, bool archived, int updatedAtMs, int createdAtMs, int tokensUsed, String modelProvider
});




}
/// @nodoc
class _$CodexThreadCopyWithImpl<$Res>
    implements $CodexThreadCopyWith<$Res> {
  _$CodexThreadCopyWithImpl(this._self, this._then);

  final CodexThread _self;
  final $Res Function(CodexThread) _then;

/// Create a copy of CodexThread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? preview = null,Object? firstUserMessage = null,Object? cwd = null,Object? archived = null,Object? updatedAtMs = null,Object? createdAtMs = null,Object? tokensUsed = null,Object? modelProvider = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,firstUserMessage: null == firstUserMessage ? _self.firstUserMessage : firstUserMessage // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,tokensUsed: null == tokensUsed ? _self.tokensUsed : tokensUsed // ignore: cast_nullable_to_non_nullable
as int,modelProvider: null == modelProvider ? _self.modelProvider : modelProvider // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexThread].
extension CodexThreadPatterns on CodexThread {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexThread() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexThread value)  $default,){
final _that = this;
switch (_that) {
case _CodexThread():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexThread value)?  $default,){
final _that = this;
switch (_that) {
case _CodexThread() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String preview,  String firstUserMessage,  String cwd,  bool archived,  int updatedAtMs,  int createdAtMs,  int tokensUsed,  String modelProvider)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexThread() when $default != null:
return $default(_that.id,_that.title,_that.preview,_that.firstUserMessage,_that.cwd,_that.archived,_that.updatedAtMs,_that.createdAtMs,_that.tokensUsed,_that.modelProvider);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String preview,  String firstUserMessage,  String cwd,  bool archived,  int updatedAtMs,  int createdAtMs,  int tokensUsed,  String modelProvider)  $default,) {final _that = this;
switch (_that) {
case _CodexThread():
return $default(_that.id,_that.title,_that.preview,_that.firstUserMessage,_that.cwd,_that.archived,_that.updatedAtMs,_that.createdAtMs,_that.tokensUsed,_that.modelProvider);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String preview,  String firstUserMessage,  String cwd,  bool archived,  int updatedAtMs,  int createdAtMs,  int tokensUsed,  String modelProvider)?  $default,) {final _that = this;
switch (_that) {
case _CodexThread() when $default != null:
return $default(_that.id,_that.title,_that.preview,_that.firstUserMessage,_that.cwd,_that.archived,_that.updatedAtMs,_that.createdAtMs,_that.tokensUsed,_that.modelProvider);case _:
  return null;

}
}

}

/// @nodoc


class _CodexThread extends CodexThread {
  const _CodexThread({required this.id, required this.title, required this.preview, required this.firstUserMessage, required this.cwd, required this.archived, required this.updatedAtMs, required this.createdAtMs, required this.tokensUsed, this.modelProvider = ''}): super._();
  

@override final  String id;
@override final  String title;
@override final  String preview;
@override final  String firstUserMessage;
@override final  String cwd;
@override final  bool archived;
@override final  int updatedAtMs;
@override final  int createdAtMs;
@override final  int tokensUsed;
@override@JsonKey() final  String modelProvider;

/// Create a copy of CodexThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexThreadCopyWith<_CodexThread> get copyWith => __$CodexThreadCopyWithImpl<_CodexThread>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexThread&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.firstUserMessage, firstUserMessage) || other.firstUserMessage == firstUserMessage)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.tokensUsed, tokensUsed) || other.tokensUsed == tokensUsed)&&(identical(other.modelProvider, modelProvider) || other.modelProvider == modelProvider));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,preview,firstUserMessage,cwd,archived,updatedAtMs,createdAtMs,tokensUsed,modelProvider);

@override
String toString() {
  return 'CodexThread(id: $id, title: $title, preview: $preview, firstUserMessage: $firstUserMessage, cwd: $cwd, archived: $archived, updatedAtMs: $updatedAtMs, createdAtMs: $createdAtMs, tokensUsed: $tokensUsed, modelProvider: $modelProvider)';
}


}

/// @nodoc
abstract mixin class _$CodexThreadCopyWith<$Res> implements $CodexThreadCopyWith<$Res> {
  factory _$CodexThreadCopyWith(_CodexThread value, $Res Function(_CodexThread) _then) = __$CodexThreadCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String preview, String firstUserMessage, String cwd, bool archived, int updatedAtMs, int createdAtMs, int tokensUsed, String modelProvider
});




}
/// @nodoc
class __$CodexThreadCopyWithImpl<$Res>
    implements _$CodexThreadCopyWith<$Res> {
  __$CodexThreadCopyWithImpl(this._self, this._then);

  final _CodexThread _self;
  final $Res Function(_CodexThread) _then;

/// Create a copy of CodexThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? preview = null,Object? firstUserMessage = null,Object? cwd = null,Object? archived = null,Object? updatedAtMs = null,Object? createdAtMs = null,Object? tokensUsed = null,Object? modelProvider = null,}) {
  return _then(_CodexThread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,firstUserMessage: null == firstUserMessage ? _self.firstUserMessage : firstUserMessage // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,tokensUsed: null == tokensUsed ? _self.tokensUsed : tokensUsed // ignore: cast_nullable_to_non_nullable
as int,modelProvider: null == modelProvider ? _self.modelProvider : modelProvider // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
