// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_backup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodexBackup {

 String get backupId; int get createdAtMs; int get threadCount; List<String> get originalProviders;
/// Create a copy of CodexBackup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexBackupCopyWith<CodexBackup> get copyWith => _$CodexBackupCopyWithImpl<CodexBackup>(this as CodexBackup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexBackup&&(identical(other.backupId, backupId) || other.backupId == backupId)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.threadCount, threadCount) || other.threadCount == threadCount)&&const DeepCollectionEquality().equals(other.originalProviders, originalProviders));
}


@override
int get hashCode => Object.hash(runtimeType,backupId,createdAtMs,threadCount,const DeepCollectionEquality().hash(originalProviders));

@override
String toString() {
  return 'CodexBackup(backupId: $backupId, createdAtMs: $createdAtMs, threadCount: $threadCount, originalProviders: $originalProviders)';
}


}

/// @nodoc
abstract mixin class $CodexBackupCopyWith<$Res>  {
  factory $CodexBackupCopyWith(CodexBackup value, $Res Function(CodexBackup) _then) = _$CodexBackupCopyWithImpl;
@useResult
$Res call({
 String backupId, int createdAtMs, int threadCount, List<String> originalProviders
});




}
/// @nodoc
class _$CodexBackupCopyWithImpl<$Res>
    implements $CodexBackupCopyWith<$Res> {
  _$CodexBackupCopyWithImpl(this._self, this._then);

  final CodexBackup _self;
  final $Res Function(CodexBackup) _then;

/// Create a copy of CodexBackup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? backupId = null,Object? createdAtMs = null,Object? threadCount = null,Object? originalProviders = null,}) {
  return _then(_self.copyWith(
backupId: null == backupId ? _self.backupId : backupId // ignore: cast_nullable_to_non_nullable
as String,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,threadCount: null == threadCount ? _self.threadCount : threadCount // ignore: cast_nullable_to_non_nullable
as int,originalProviders: null == originalProviders ? _self.originalProviders : originalProviders // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexBackup].
extension CodexBackupPatterns on CodexBackup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexBackup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexBackup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexBackup value)  $default,){
final _that = this;
switch (_that) {
case _CodexBackup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexBackup value)?  $default,){
final _that = this;
switch (_that) {
case _CodexBackup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String backupId,  int createdAtMs,  int threadCount,  List<String> originalProviders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexBackup() when $default != null:
return $default(_that.backupId,_that.createdAtMs,_that.threadCount,_that.originalProviders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String backupId,  int createdAtMs,  int threadCount,  List<String> originalProviders)  $default,) {final _that = this;
switch (_that) {
case _CodexBackup():
return $default(_that.backupId,_that.createdAtMs,_that.threadCount,_that.originalProviders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String backupId,  int createdAtMs,  int threadCount,  List<String> originalProviders)?  $default,) {final _that = this;
switch (_that) {
case _CodexBackup() when $default != null:
return $default(_that.backupId,_that.createdAtMs,_that.threadCount,_that.originalProviders);case _:
  return null;

}
}

}

/// @nodoc


class _CodexBackup extends CodexBackup {
  const _CodexBackup({required this.backupId, required this.createdAtMs, required this.threadCount, required final  List<String> originalProviders}): _originalProviders = originalProviders,super._();
  

@override final  String backupId;
@override final  int createdAtMs;
@override final  int threadCount;
 final  List<String> _originalProviders;
@override List<String> get originalProviders {
  if (_originalProviders is EqualUnmodifiableListView) return _originalProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_originalProviders);
}


/// Create a copy of CodexBackup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexBackupCopyWith<_CodexBackup> get copyWith => __$CodexBackupCopyWithImpl<_CodexBackup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexBackup&&(identical(other.backupId, backupId) || other.backupId == backupId)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.threadCount, threadCount) || other.threadCount == threadCount)&&const DeepCollectionEquality().equals(other._originalProviders, _originalProviders));
}


@override
int get hashCode => Object.hash(runtimeType,backupId,createdAtMs,threadCount,const DeepCollectionEquality().hash(_originalProviders));

@override
String toString() {
  return 'CodexBackup(backupId: $backupId, createdAtMs: $createdAtMs, threadCount: $threadCount, originalProviders: $originalProviders)';
}


}

/// @nodoc
abstract mixin class _$CodexBackupCopyWith<$Res> implements $CodexBackupCopyWith<$Res> {
  factory _$CodexBackupCopyWith(_CodexBackup value, $Res Function(_CodexBackup) _then) = __$CodexBackupCopyWithImpl;
@override @useResult
$Res call({
 String backupId, int createdAtMs, int threadCount, List<String> originalProviders
});




}
/// @nodoc
class __$CodexBackupCopyWithImpl<$Res>
    implements _$CodexBackupCopyWith<$Res> {
  __$CodexBackupCopyWithImpl(this._self, this._then);

  final _CodexBackup _self;
  final $Res Function(_CodexBackup) _then;

/// Create a copy of CodexBackup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? backupId = null,Object? createdAtMs = null,Object? threadCount = null,Object? originalProviders = null,}) {
  return _then(_CodexBackup(
backupId: null == backupId ? _self.backupId : backupId // ignore: cast_nullable_to_non_nullable
as String,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,threadCount: null == threadCount ? _self.threadCount : threadCount // ignore: cast_nullable_to_non_nullable
as int,originalProviders: null == originalProviders ? _self._originalProviders : originalProviders // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
