// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_backup_entry_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CodexBackupEntryDto {

 String get threadId; String get title; String get cwd; int get updatedAtMs; String get originalProvider; String get jsonlFilename;
/// Create a copy of CodexBackupEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexBackupEntryDtoCopyWith<CodexBackupEntryDto> get copyWith => _$CodexBackupEntryDtoCopyWithImpl<CodexBackupEntryDto>(this as CodexBackupEntryDto, _$identity);

  /// Serializes this CodexBackupEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexBackupEntryDto&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.title, title) || other.title == title)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.originalProvider, originalProvider) || other.originalProvider == originalProvider)&&(identical(other.jsonlFilename, jsonlFilename) || other.jsonlFilename == jsonlFilename));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,threadId,title,cwd,updatedAtMs,originalProvider,jsonlFilename);

@override
String toString() {
  return 'CodexBackupEntryDto(threadId: $threadId, title: $title, cwd: $cwd, updatedAtMs: $updatedAtMs, originalProvider: $originalProvider, jsonlFilename: $jsonlFilename)';
}


}

/// @nodoc
abstract mixin class $CodexBackupEntryDtoCopyWith<$Res>  {
  factory $CodexBackupEntryDtoCopyWith(CodexBackupEntryDto value, $Res Function(CodexBackupEntryDto) _then) = _$CodexBackupEntryDtoCopyWithImpl;
@useResult
$Res call({
 String threadId, String title, String cwd, int updatedAtMs, String originalProvider, String jsonlFilename
});




}
/// @nodoc
class _$CodexBackupEntryDtoCopyWithImpl<$Res>
    implements $CodexBackupEntryDtoCopyWith<$Res> {
  _$CodexBackupEntryDtoCopyWithImpl(this._self, this._then);

  final CodexBackupEntryDto _self;
  final $Res Function(CodexBackupEntryDto) _then;

/// Create a copy of CodexBackupEntryDto
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


/// Adds pattern-matching-related methods to [CodexBackupEntryDto].
extension CodexBackupEntryDtoPatterns on CodexBackupEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexBackupEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexBackupEntryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexBackupEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _CodexBackupEntryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexBackupEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _CodexBackupEntryDto() when $default != null:
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
case _CodexBackupEntryDto() when $default != null:
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
case _CodexBackupEntryDto():
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
case _CodexBackupEntryDto() when $default != null:
return $default(_that.threadId,_that.title,_that.cwd,_that.updatedAtMs,_that.originalProvider,_that.jsonlFilename);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CodexBackupEntryDto extends CodexBackupEntryDto {
  const _CodexBackupEntryDto({this.threadId = '', this.title = '', this.cwd = '', this.updatedAtMs = 0, this.originalProvider = '', this.jsonlFilename = ''}): super._();
  factory _CodexBackupEntryDto.fromJson(Map<String, dynamic> json) => _$CodexBackupEntryDtoFromJson(json);

@override@JsonKey() final  String threadId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String cwd;
@override@JsonKey() final  int updatedAtMs;
@override@JsonKey() final  String originalProvider;
@override@JsonKey() final  String jsonlFilename;

/// Create a copy of CodexBackupEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexBackupEntryDtoCopyWith<_CodexBackupEntryDto> get copyWith => __$CodexBackupEntryDtoCopyWithImpl<_CodexBackupEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodexBackupEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexBackupEntryDto&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.title, title) || other.title == title)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.originalProvider, originalProvider) || other.originalProvider == originalProvider)&&(identical(other.jsonlFilename, jsonlFilename) || other.jsonlFilename == jsonlFilename));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,threadId,title,cwd,updatedAtMs,originalProvider,jsonlFilename);

@override
String toString() {
  return 'CodexBackupEntryDto(threadId: $threadId, title: $title, cwd: $cwd, updatedAtMs: $updatedAtMs, originalProvider: $originalProvider, jsonlFilename: $jsonlFilename)';
}


}

/// @nodoc
abstract mixin class _$CodexBackupEntryDtoCopyWith<$Res> implements $CodexBackupEntryDtoCopyWith<$Res> {
  factory _$CodexBackupEntryDtoCopyWith(_CodexBackupEntryDto value, $Res Function(_CodexBackupEntryDto) _then) = __$CodexBackupEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String threadId, String title, String cwd, int updatedAtMs, String originalProvider, String jsonlFilename
});




}
/// @nodoc
class __$CodexBackupEntryDtoCopyWithImpl<$Res>
    implements _$CodexBackupEntryDtoCopyWith<$Res> {
  __$CodexBackupEntryDtoCopyWithImpl(this._self, this._then);

  final _CodexBackupEntryDto _self;
  final $Res Function(_CodexBackupEntryDto) _then;

/// Create a copy of CodexBackupEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? threadId = null,Object? title = null,Object? cwd = null,Object? updatedAtMs = null,Object? originalProvider = null,Object? jsonlFilename = null,}) {
  return _then(_CodexBackupEntryDto(
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
