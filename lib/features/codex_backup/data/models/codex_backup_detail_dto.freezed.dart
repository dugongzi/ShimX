// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_backup_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CodexBackupDetailDto {

 String get backupId; int get createdAtMs; List<CodexBackupEntryDto> get entries;
/// Create a copy of CodexBackupDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexBackupDetailDtoCopyWith<CodexBackupDetailDto> get copyWith => _$CodexBackupDetailDtoCopyWithImpl<CodexBackupDetailDto>(this as CodexBackupDetailDto, _$identity);

  /// Serializes this CodexBackupDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexBackupDetailDto&&(identical(other.backupId, backupId) || other.backupId == backupId)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&const DeepCollectionEquality().equals(other.entries, entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,backupId,createdAtMs,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'CodexBackupDetailDto(backupId: $backupId, createdAtMs: $createdAtMs, entries: $entries)';
}


}

/// @nodoc
abstract mixin class $CodexBackupDetailDtoCopyWith<$Res>  {
  factory $CodexBackupDetailDtoCopyWith(CodexBackupDetailDto value, $Res Function(CodexBackupDetailDto) _then) = _$CodexBackupDetailDtoCopyWithImpl;
@useResult
$Res call({
 String backupId, int createdAtMs, List<CodexBackupEntryDto> entries
});




}
/// @nodoc
class _$CodexBackupDetailDtoCopyWithImpl<$Res>
    implements $CodexBackupDetailDtoCopyWith<$Res> {
  _$CodexBackupDetailDtoCopyWithImpl(this._self, this._then);

  final CodexBackupDetailDto _self;
  final $Res Function(CodexBackupDetailDto) _then;

/// Create a copy of CodexBackupDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? backupId = null,Object? createdAtMs = null,Object? entries = null,}) {
  return _then(_self.copyWith(
backupId: null == backupId ? _self.backupId : backupId // ignore: cast_nullable_to_non_nullable
as String,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<CodexBackupEntryDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexBackupDetailDto].
extension CodexBackupDetailDtoPatterns on CodexBackupDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexBackupDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexBackupDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexBackupDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _CodexBackupDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexBackupDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _CodexBackupDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String backupId,  int createdAtMs,  List<CodexBackupEntryDto> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexBackupDetailDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String backupId,  int createdAtMs,  List<CodexBackupEntryDto> entries)  $default,) {final _that = this;
switch (_that) {
case _CodexBackupDetailDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String backupId,  int createdAtMs,  List<CodexBackupEntryDto> entries)?  $default,) {final _that = this;
switch (_that) {
case _CodexBackupDetailDto() when $default != null:
return $default(_that.backupId,_that.createdAtMs,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CodexBackupDetailDto extends CodexBackupDetailDto {
  const _CodexBackupDetailDto({this.backupId = '', this.createdAtMs = 0, final  List<CodexBackupEntryDto> entries = const <CodexBackupEntryDto>[]}): _entries = entries,super._();
  factory _CodexBackupDetailDto.fromJson(Map<String, dynamic> json) => _$CodexBackupDetailDtoFromJson(json);

@override@JsonKey() final  String backupId;
@override@JsonKey() final  int createdAtMs;
 final  List<CodexBackupEntryDto> _entries;
@override@JsonKey() List<CodexBackupEntryDto> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of CodexBackupDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexBackupDetailDtoCopyWith<_CodexBackupDetailDto> get copyWith => __$CodexBackupDetailDtoCopyWithImpl<_CodexBackupDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodexBackupDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexBackupDetailDto&&(identical(other.backupId, backupId) || other.backupId == backupId)&&(identical(other.createdAtMs, createdAtMs) || other.createdAtMs == createdAtMs)&&const DeepCollectionEquality().equals(other._entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,backupId,createdAtMs,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'CodexBackupDetailDto(backupId: $backupId, createdAtMs: $createdAtMs, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$CodexBackupDetailDtoCopyWith<$Res> implements $CodexBackupDetailDtoCopyWith<$Res> {
  factory _$CodexBackupDetailDtoCopyWith(_CodexBackupDetailDto value, $Res Function(_CodexBackupDetailDto) _then) = __$CodexBackupDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String backupId, int createdAtMs, List<CodexBackupEntryDto> entries
});




}
/// @nodoc
class __$CodexBackupDetailDtoCopyWithImpl<$Res>
    implements _$CodexBackupDetailDtoCopyWith<$Res> {
  __$CodexBackupDetailDtoCopyWithImpl(this._self, this._then);

  final _CodexBackupDetailDto _self;
  final $Res Function(_CodexBackupDetailDto) _then;

/// Create a copy of CodexBackupDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? backupId = null,Object? createdAtMs = null,Object? entries = null,}) {
  return _then(_CodexBackupDetailDto(
backupId: null == backupId ? _self.backupId : backupId // ignore: cast_nullable_to_non_nullable
as String,createdAtMs: null == createdAtMs ? _self.createdAtMs : createdAtMs // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<CodexBackupEntryDto>,
  ));
}


}

// dart format on
