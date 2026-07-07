// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_skill_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CodexSkillDto {

 String get id; String get name; String get description; String get path; bool get managedByShimX; bool get readOnly; bool get hasSkillFile; int get installedAt; String get contentHash;
/// Create a copy of CodexSkillDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexSkillDtoCopyWith<CodexSkillDto> get copyWith => _$CodexSkillDtoCopyWithImpl<CodexSkillDto>(this as CodexSkillDto, _$identity);

  /// Serializes this CodexSkillDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexSkillDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.path, path) || other.path == path)&&(identical(other.managedByShimX, managedByShimX) || other.managedByShimX == managedByShimX)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.hasSkillFile, hasSkillFile) || other.hasSkillFile == hasSkillFile)&&(identical(other.installedAt, installedAt) || other.installedAt == installedAt)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,path,managedByShimX,readOnly,hasSkillFile,installedAt,contentHash);

@override
String toString() {
  return 'CodexSkillDto(id: $id, name: $name, description: $description, path: $path, managedByShimX: $managedByShimX, readOnly: $readOnly, hasSkillFile: $hasSkillFile, installedAt: $installedAt, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class $CodexSkillDtoCopyWith<$Res>  {
  factory $CodexSkillDtoCopyWith(CodexSkillDto value, $Res Function(CodexSkillDto) _then) = _$CodexSkillDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String path, bool managedByShimX, bool readOnly, bool hasSkillFile, int installedAt, String contentHash
});




}
/// @nodoc
class _$CodexSkillDtoCopyWithImpl<$Res>
    implements $CodexSkillDtoCopyWith<$Res> {
  _$CodexSkillDtoCopyWithImpl(this._self, this._then);

  final CodexSkillDto _self;
  final $Res Function(CodexSkillDto) _then;

/// Create a copy of CodexSkillDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? path = null,Object? managedByShimX = null,Object? readOnly = null,Object? hasSkillFile = null,Object? installedAt = null,Object? contentHash = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,managedByShimX: null == managedByShimX ? _self.managedByShimX : managedByShimX // ignore: cast_nullable_to_non_nullable
as bool,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,hasSkillFile: null == hasSkillFile ? _self.hasSkillFile : hasSkillFile // ignore: cast_nullable_to_non_nullable
as bool,installedAt: null == installedAt ? _self.installedAt : installedAt // ignore: cast_nullable_to_non_nullable
as int,contentHash: null == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexSkillDto].
extension CodexSkillDtoPatterns on CodexSkillDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexSkillDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexSkillDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexSkillDto value)  $default,){
final _that = this;
switch (_that) {
case _CodexSkillDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexSkillDto value)?  $default,){
final _that = this;
switch (_that) {
case _CodexSkillDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String path,  bool managedByShimX,  bool readOnly,  bool hasSkillFile,  int installedAt,  String contentHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexSkillDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.path,_that.managedByShimX,_that.readOnly,_that.hasSkillFile,_that.installedAt,_that.contentHash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String path,  bool managedByShimX,  bool readOnly,  bool hasSkillFile,  int installedAt,  String contentHash)  $default,) {final _that = this;
switch (_that) {
case _CodexSkillDto():
return $default(_that.id,_that.name,_that.description,_that.path,_that.managedByShimX,_that.readOnly,_that.hasSkillFile,_that.installedAt,_that.contentHash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String path,  bool managedByShimX,  bool readOnly,  bool hasSkillFile,  int installedAt,  String contentHash)?  $default,) {final _that = this;
switch (_that) {
case _CodexSkillDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.path,_that.managedByShimX,_that.readOnly,_that.hasSkillFile,_that.installedAt,_that.contentHash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CodexSkillDto extends CodexSkillDto {
  const _CodexSkillDto({this.id = '', this.name = '', this.description = '', this.path = '', this.managedByShimX = false, this.readOnly = true, this.hasSkillFile = false, this.installedAt = 0, this.contentHash = ''}): super._();
  factory _CodexSkillDto.fromJson(Map<String, dynamic> json) => _$CodexSkillDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  String path;
@override@JsonKey() final  bool managedByShimX;
@override@JsonKey() final  bool readOnly;
@override@JsonKey() final  bool hasSkillFile;
@override@JsonKey() final  int installedAt;
@override@JsonKey() final  String contentHash;

/// Create a copy of CodexSkillDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexSkillDtoCopyWith<_CodexSkillDto> get copyWith => __$CodexSkillDtoCopyWithImpl<_CodexSkillDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodexSkillDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexSkillDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.path, path) || other.path == path)&&(identical(other.managedByShimX, managedByShimX) || other.managedByShimX == managedByShimX)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.hasSkillFile, hasSkillFile) || other.hasSkillFile == hasSkillFile)&&(identical(other.installedAt, installedAt) || other.installedAt == installedAt)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,path,managedByShimX,readOnly,hasSkillFile,installedAt,contentHash);

@override
String toString() {
  return 'CodexSkillDto(id: $id, name: $name, description: $description, path: $path, managedByShimX: $managedByShimX, readOnly: $readOnly, hasSkillFile: $hasSkillFile, installedAt: $installedAt, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class _$CodexSkillDtoCopyWith<$Res> implements $CodexSkillDtoCopyWith<$Res> {
  factory _$CodexSkillDtoCopyWith(_CodexSkillDto value, $Res Function(_CodexSkillDto) _then) = __$CodexSkillDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String path, bool managedByShimX, bool readOnly, bool hasSkillFile, int installedAt, String contentHash
});




}
/// @nodoc
class __$CodexSkillDtoCopyWithImpl<$Res>
    implements _$CodexSkillDtoCopyWith<$Res> {
  __$CodexSkillDtoCopyWithImpl(this._self, this._then);

  final _CodexSkillDto _self;
  final $Res Function(_CodexSkillDto) _then;

/// Create a copy of CodexSkillDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? path = null,Object? managedByShimX = null,Object? readOnly = null,Object? hasSkillFile = null,Object? installedAt = null,Object? contentHash = null,}) {
  return _then(_CodexSkillDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,managedByShimX: null == managedByShimX ? _self.managedByShimX : managedByShimX // ignore: cast_nullable_to_non_nullable
as bool,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,hasSkillFile: null == hasSkillFile ? _self.hasSkillFile : hasSkillFile // ignore: cast_nullable_to_non_nullable
as bool,installedAt: null == installedAt ? _self.installedAt : installedAt // ignore: cast_nullable_to_non_nullable
as int,contentHash: null == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
