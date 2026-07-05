// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_backup_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodexBackupDetail {

 String get backupId; int get createdAtMs; List<CodexBackupEntry> get entries;
/// Create a copy of CodexBackupDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexBackupDetailCopyWith<CodexBackupDetail> get copyWith => _$CodexBackupDetailCopyWithImpl<CodexBackupDetail>(this as CodexBackupDetail, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexBackupDetail&&(identical(other.backupId, backupId) || other.backupId == backupId)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&const DeepCollectionEquality().equals(other.entries, entries));
}


@override
int get hashCode => Object.hash(runtimeType,backupId,createdAtMs,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'CodexBackupDetail(backupId: $backupId, createdAtMs: $createdAtMs, entries: $entries)';
}


}

/// @nodoc
abstract mixin class $CodexBackupDetailCopyWith<$Res>  {
  factory $CodexBackupDetailCopyWith(CodexBackupDetail value, $Res Function(CodexBackupDetail) _then) = _$CodexBackupDetailCopyWithImpl;
@useResult
$Res call({
 String backupId, int createdAtMs, List<CodexBackupEntry> entries
});




}
/// @nodoc
class _$CodexBackupDetailCopyWithImpl<$Res>
    implements $CodexBackupDetailCopyWith<$Res> {
  _$CodexBackupDetailCopyWithImpl(this._self, this._then);

  final CodexBackupDetail _self;
  final $Res Function(CodexBackupDetail) _then;

/// Create a copy of CodexBackupDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? backupId = null,Object? createdAtMs = null,Object? entries = null,}) {
  return _then(_self.copyWith(
backupId: null == backupId ? _self.backupId : backupId // ignore: cast_nullable_to_non_nullable
as String,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<CodexBackupEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexBackupDetail].
extension CodexBackupDetailPatterns on CodexBackupDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexBackupDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexBackupDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexBackupDetail value)  $default,){
final _that = this;
switch (_that) {
case _CodexBackupDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexBackupDetail value)?  $default,){
final _that = this;
switch (_that) {
case _CodexBackupDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String backupId,  int createdAtMs,  List<CodexBackupEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexBackupDetail() when $default != null:
return $default(_that.backupId,_that.createdAtMs,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String backupId,  int createdAtMs,  List<CodexBackupEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _CodexBackupDetail():
return $default(_that.backupId,_that.createdAtMs,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String backupId,  int createdAtMs,  List<CodexBackupEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _CodexBackupDetail() when $default != null:
return $default(_that.backupId,_that.createdAtMs,_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _CodexBackupDetail extends CodexBackupDetail {
  const _CodexBackupDetail({required this.backupId, required this.createdAtMs, required final  List<CodexBackupEntry> entries}): _entries = entries,super._();
  

@override final  String backupId;
@override final  int createdAtMs;
 final  List<CodexBackupEntry> _entries;
@override List<CodexBackupEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of CodexBackupDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexBackupDetailCopyWith<_CodexBackupDetail> get copyWith => __$CodexBackupDetailCopyWithImpl<_CodexBackupDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexBackupDetail&&(identical(other.backupId, backupId) || other.backupId == backupId)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&const DeepCollectionEquality().equals(other._entries, _entries));
}


@override
int get hashCode => Object.hash(runtimeType,backupId,createdAtMs,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'CodexBackupDetail(backupId: $backupId, createdAtMs: $createdAtMs, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$CodexBackupDetailCopyWith<$Res> implements $CodexBackupDetailCopyWith<$Res> {
  factory _$CodexBackupDetailCopyWith(_CodexBackupDetail value, $Res Function(_CodexBackupDetail) _then) = __$CodexBackupDetailCopyWithImpl;
@override @useResult
$Res call({
 String backupId, int createdAtMs, List<CodexBackupEntry> entries
});




}
/// @nodoc
class __$CodexBackupDetailCopyWithImpl<$Res>
    implements _$CodexBackupDetailCopyWith<$Res> {
  __$CodexBackupDetailCopyWithImpl(this._self, this._then);

  final _CodexBackupDetail _self;
  final $Res Function(_CodexBackupDetail) _then;

/// Create a copy of CodexBackupDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? backupId = null,Object? createdAtMs = null,Object? entries = null,}) {
  return _then(_CodexBackupDetail(
backupId: null == backupId ? _self.backupId : backupId // ignore: cast_nullable_to_non_nullable
as String,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<CodexBackupEntry>,
  ));
}


}

// dart format on
