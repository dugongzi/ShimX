// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_backup_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodexBackupEntry {

 String get threadId; String get title; String get cwd; int get updatedAtMs; String get originalProvider; String get jsonlFilename;
/// Create a copy of CodexBackupEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexBackupEntryCopyWith<CodexBackupEntry> get copyWith => _$CodexBackupEntryCopyWithImpl<CodexBackupEntry>(this as CodexBackupEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexBackupEntry&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.title, title) || other.title == title)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.originalProvider, originalProvider) || other.originalProvider == originalProvider)&&(identical(other.jsonlFilename, jsonlFilename) || other.jsonlFilename == jsonlFilename));
}


@override
int get hashCode => Object.hash(runtimeType,threadId,title,cwd,updatedAtMs,originalProvider,jsonlFilename);

@override
String toString() {
  return 'CodexBackupEntry(threadId: $threadId, title: $title, cwd: $cwd, updatedAtMs: $updatedAtMs, originalProvider: $originalProvider, jsonlFilename: $jsonlFilename)';
}


}

/// @nodoc
abstract mixin class $CodexBackupEntryCopyWith<$Res>  {
  factory $CodexBackupEntryCopyWith(CodexBackupEntry value, $Res Function(CodexBackupEntry) _then) = _$CodexBackupEntryCopyWithImpl;
@useResult
$Res call({
 String threadId, String title, String cwd, int updatedAtMs, String originalProvider, String jsonlFilename
});




}
/// @nodoc
class _$CodexBackupEntryCopyWithImpl<$Res>
    implements $CodexBackupEntryCopyWith<$Res> {
  _$CodexBackupEntryCopyWithImpl(this._self, this._then);

  final CodexBackupEntry _self;
  final $Res Function(CodexBackupEntry) _then;

/// Create a copy of CodexBackupEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? threadId = null,Object? title = null,Object? cwd = null,Object? updatedAtMs = null,Object? originalProvider = null,Object? jsonlFilename = null,}) {
  return _then(_self.copyWith(
threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,originalProvider: null == originalProvider ? _self.originalProvider : originalProvider // ignore: cast_nullable_to_non_nullable
as String,jsonlFilename: null == jsonlFilename ? _self.jsonlFilename : jsonlFilename // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexBackupEntry].
extension CodexBackupEntryPatterns on CodexBackupEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexBackupEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexBackupEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexBackupEntry value)  $default,){
final _that = this;
switch (_that) {
case _CodexBackupEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexBackupEntry value)?  $default,){
final _that = this;
switch (_that) {
case _CodexBackupEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String threadId,  String title,  String cwd,  int updatedAtMs,  String originalProvider,  String jsonlFilename)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexBackupEntry() when $default != null:
return $default(_that.threadId,_that.title,_that.cwd,_that.updatedAtMs,_that.originalProvider,_that.jsonlFilename);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String threadId,  String title,  String cwd,  int updatedAtMs,  String originalProvider,  String jsonlFilename)  $default,) {final _that = this;
switch (_that) {
case _CodexBackupEntry():
return $default(_that.threadId,_that.title,_that.cwd,_that.updatedAtMs,_that.originalProvider,_that.jsonlFilename);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String threadId,  String title,  String cwd,  int updatedAtMs,  String originalProvider,  String jsonlFilename)?  $default,) {final _that = this;
switch (_that) {
case _CodexBackupEntry() when $default != null:
return $default(_that.threadId,_that.title,_that.cwd,_that.updatedAtMs,_that.originalProvider,_that.jsonlFilename);case _:
  return null;

}
}

}

/// @nodoc


class _CodexBackupEntry extends CodexBackupEntry {
  const _CodexBackupEntry({required this.threadId, required this.title, required this.cwd, required this.updatedAtMs, required this.originalProvider, required this.jsonlFilename}): super._();
  

@override final  String threadId;
@override final  String title;
@override final  String cwd;
@override final  int updatedAtMs;
@override final  String originalProvider;
@override final  String jsonlFilename;

/// Create a copy of CodexBackupEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexBackupEntryCopyWith<_CodexBackupEntry> get copyWith => __$CodexBackupEntryCopyWithImpl<_CodexBackupEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexBackupEntry&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.title, title) || other.title == title)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.originalProvider, originalProvider) || other.originalProvider == originalProvider)&&(identical(other.jsonlFilename, jsonlFilename) || other.jsonlFilename == jsonlFilename));
}


@override
int get hashCode => Object.hash(runtimeType,threadId,title,cwd,updatedAtMs,originalProvider,jsonlFilename);

@override
String toString() {
  return 'CodexBackupEntry(threadId: $threadId, title: $title, cwd: $cwd, updatedAtMs: $updatedAtMs, originalProvider: $originalProvider, jsonlFilename: $jsonlFilename)';
}


}

/// @nodoc
abstract mixin class _$CodexBackupEntryCopyWith<$Res> implements $CodexBackupEntryCopyWith<$Res> {
  factory _$CodexBackupEntryCopyWith(_CodexBackupEntry value, $Res Function(_CodexBackupEntry) _then) = __$CodexBackupEntryCopyWithImpl;
@override @useResult
$Res call({
 String threadId, String title, String cwd, int updatedAtMs, String originalProvider, String jsonlFilename
});




}
/// @nodoc
class __$CodexBackupEntryCopyWithImpl<$Res>
    implements _$CodexBackupEntryCopyWith<$Res> {
  __$CodexBackupEntryCopyWithImpl(this._self, this._then);

  final _CodexBackupEntry _self;
  final $Res Function(_CodexBackupEntry) _then;

/// Create a copy of CodexBackupEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? threadId = null,Object? title = null,Object? cwd = null,Object? updatedAtMs = null,Object? originalProvider = null,Object? jsonlFilename = null,}) {
  return _then(_CodexBackupEntry(
threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,originalProvider: null == originalProvider ? _self.originalProvider : originalProvider // ignore: cast_nullable_to_non_nullable
as String,jsonlFilename: null == jsonlFilename ? _self.jsonlFilename : jsonlFilename // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
