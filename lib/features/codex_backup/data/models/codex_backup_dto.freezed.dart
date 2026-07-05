// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_backup_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CodexBackupDto {

 String get backupId; int get createdAtMs; int get threadCount; List<String> get originalProviders;
/// Create a copy of CodexBackupDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexBackupDtoCopyWith<CodexBackupDto> get copyWith => _$CodexBackupDtoCopyWithImpl<CodexBackupDto>(this as CodexBackupDto, _$identity);

  /// Serializes this CodexBackupDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexBackupDto&&(identical(other.backupId, backupId) || other.backupId == backupId)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.threadCount, threadCount) || other.threadCount == threadCount)&&const DeepCollectionEquality().equals(other.originalProviders, originalProviders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,backupId,createdAtMs,threadCount,const DeepCollectionEquality().hash(originalProviders));

@override
String toString() {
  return 'CodexBackupDto(backupId: $backupId, createdAtMs: $createdAtMs, threadCount: $threadCount, originalProviders: $originalProviders)';
}


}

/// @nodoc
abstract mixin class $CodexBackupDtoCopyWith<$Res>  {
  factory $CodexBackupDtoCopyWith(CodexBackupDto value, $Res Function(CodexBackupDto) _then) = _$CodexBackupDtoCopyWithImpl;
@useResult
$Res call({
 String backupId, int createdAtMs, int threadCount, List<String> originalProviders
});




}
/// @nodoc
class _$CodexBackupDtoCopyWithImpl<$Res>
    implements $CodexBackupDtoCopyWith<$Res> {
  _$CodexBackupDtoCopyWithImpl(this._self, this._then);

  final CodexBackupDto _self;
  final $Res Function(CodexBackupDto) _then;

/// Create a copy of CodexBackupDto
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


/// Adds pattern-matching-related methods to [CodexBackupDto].
extension CodexBackupDtoPatterns on CodexBackupDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexBackupDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexBackupDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexBackupDto value)  $default,){
final _that = this;
switch (_that) {
case _CodexBackupDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexBackupDto value)?  $default,){
final _that = this;
switch (_that) {
case _CodexBackupDto() when $default != null:
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
case _CodexBackupDto() when $default != null:
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
case _CodexBackupDto():
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
case _CodexBackupDto() when $default != null:
return $default(_that.backupId,_that.createdAtMs,_that.threadCount,_that.originalProviders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CodexBackupDto extends CodexBackupDto {
  const _CodexBackupDto({this.backupId = '', this.createdAtMs = 0, this.threadCount = 0, final  List<String> originalProviders = const <String>[]}): _originalProviders = originalProviders,super._();
  factory _CodexBackupDto.fromJson(Map<String, dynamic> json) => _$CodexBackupDtoFromJson(json);

@override@JsonKey() final  String backupId;
@override@JsonKey() final  int createdAtMs;
@override@JsonKey() final  int threadCount;
 final  List<String> _originalProviders;
@override@JsonKey() List<String> get originalProviders {
  if (_originalProviders is EqualUnmodifiableListView) return _originalProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_originalProviders);
}


/// Create a copy of CodexBackupDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexBackupDtoCopyWith<_CodexBackupDto> get copyWith => __$CodexBackupDtoCopyWithImpl<_CodexBackupDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodexBackupDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexBackupDto&&(identical(other.backupId, backupId) || other.backupId == backupId)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&(identical(other.threadCount, threadCount) || other.threadCount == threadCount)&&const DeepCollectionEquality().equals(other._originalProviders, _originalProviders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,backupId,createdAtMs,threadCount,const DeepCollectionEquality().hash(_originalProviders));

@override
String toString() {
  return 'CodexBackupDto(backupId: $backupId, createdAtMs: $createdAtMs, threadCount: $threadCount, originalProviders: $originalProviders)';
}


}

/// @nodoc
abstract mixin class _$CodexBackupDtoCopyWith<$Res> implements $CodexBackupDtoCopyWith<$Res> {
  factory _$CodexBackupDtoCopyWith(_CodexBackupDto value, $Res Function(_CodexBackupDto) _then) = __$CodexBackupDtoCopyWithImpl;
@override @useResult
$Res call({
 String backupId, int createdAtMs, int threadCount, List<String> originalProviders
});




}
/// @nodoc
class __$CodexBackupDtoCopyWithImpl<$Res>
    implements _$CodexBackupDtoCopyWith<$Res> {
  __$CodexBackupDtoCopyWithImpl(this._self, this._then);

  final _CodexBackupDto _self;
  final $Res Function(_CodexBackupDto) _then;

/// Create a copy of CodexBackupDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? backupId = null,Object? createdAtMs = null,Object? threadCount = null,Object? originalProviders = null,}) {
  return _then(_CodexBackupDto(
backupId: null == backupId ? _self.backupId : backupId // ignore: cast_nullable_to_non_nullable
as String,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,threadCount: null == threadCount ? _self.threadCount : threadCount // ignore: cast_nullable_to_non_nullable
as int,originalProviders: null == originalProviders ? _self._originalProviders : originalProviders // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
