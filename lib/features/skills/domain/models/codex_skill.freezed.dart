// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_skill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodexSkill {

 String get id; String get name; String get description; String get path; bool get managedByShim; bool get readOnly; bool get hasSkillFile; int get installedAt; String get contentHash;
/// Create a copy of CodexSkill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexSkillCopyWith<CodexSkill> get copyWith => _$CodexSkillCopyWithImpl<CodexSkill>(this as CodexSkill, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexSkill&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.path, path) || other.path == path)&&(identical(other.managedByShim, managedByShim) || other.managedByShim == managedByShim)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.hasSkillFile, hasSkillFile) || other.hasSkillFile == hasSkillFile)&&(identical(other.installedAt, installedAt) || other.installedAt == installedAt)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,path,managedByShim,readOnly,hasSkillFile,installedAt,contentHash);

@override
String toString() {
  return 'CodexSkill(id: $id, name: $name, description: $description, path: $path, managedByShim: $managedByShim, readOnly: $readOnly, hasSkillFile: $hasSkillFile, installedAt: $installedAt, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class $CodexSkillCopyWith<$Res>  {
  factory $CodexSkillCopyWith(CodexSkill value, $Res Function(CodexSkill) _then) = _$CodexSkillCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String path, bool managedByShim, bool readOnly, bool hasSkillFile, int installedAt, String contentHash
});




}
/// @nodoc
class _$CodexSkillCopyWithImpl<$Res>
    implements $CodexSkillCopyWith<$Res> {
  _$CodexSkillCopyWithImpl(this._self, this._then);

  final CodexSkill _self;
  final $Res Function(CodexSkill) _then;

/// Create a copy of CodexSkill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? path = null,Object? managedByShim = null,Object? readOnly = null,Object? hasSkillFile = null,Object? installedAt = null,Object? contentHash = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,managedByShim: null == managedByShim ? _self.managedByShim : managedByShim // ignore: cast_nullable_to_non_nullable
as bool,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,hasSkillFile: null == hasSkillFile ? _self.hasSkillFile : hasSkillFile // ignore: cast_nullable_to_non_nullable
as bool,installedAt: null == installedAt ? _self.installedAt : installedAt // ignore: cast_nullable_to_non_nullable
as int,contentHash: null == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexSkill].
extension CodexSkillPatterns on CodexSkill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexSkill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexSkill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexSkill value)  $default,){
final _that = this;
switch (_that) {
case _CodexSkill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexSkill value)?  $default,){
final _that = this;
switch (_that) {
case _CodexSkill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String path,  bool managedByShim,  bool readOnly,  bool hasSkillFile,  int installedAt,  String contentHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexSkill() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.path,_that.managedByShim,_that.readOnly,_that.hasSkillFile,_that.installedAt,_that.contentHash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String path,  bool managedByShim,  bool readOnly,  bool hasSkillFile,  int installedAt,  String contentHash)  $default,) {final _that = this;
switch (_that) {
case _CodexSkill():
return $default(_that.id,_that.name,_that.description,_that.path,_that.managedByShim,_that.readOnly,_that.hasSkillFile,_that.installedAt,_that.contentHash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String path,  bool managedByShim,  bool readOnly,  bool hasSkillFile,  int installedAt,  String contentHash)?  $default,) {final _that = this;
switch (_that) {
case _CodexSkill() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.path,_that.managedByShim,_that.readOnly,_that.hasSkillFile,_that.installedAt,_that.contentHash);case _:
  return null;

}
}

}

/// @nodoc


class _CodexSkill extends CodexSkill {
  const _CodexSkill({required this.id, required this.name, required this.description, required this.path, required this.managedByShim, required this.readOnly, required this.hasSkillFile, required this.installedAt, required this.contentHash}): super._();
  

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String path;
@override final  bool managedByShim;
@override final  bool readOnly;
@override final  bool hasSkillFile;
@override final  int installedAt;
@override final  String contentHash;

/// Create a copy of CodexSkill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexSkillCopyWith<_CodexSkill> get copyWith => __$CodexSkillCopyWithImpl<_CodexSkill>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexSkill&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.path, path) || other.path == path)&&(identical(other.managedByShim, managedByShim) || other.managedByShim == managedByShim)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.hasSkillFile, hasSkillFile) || other.hasSkillFile == hasSkillFile)&&(identical(other.installedAt, installedAt) || other.installedAt == installedAt)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,path,managedByShim,readOnly,hasSkillFile,installedAt,contentHash);

@override
String toString() {
  return 'CodexSkill(id: $id, name: $name, description: $description, path: $path, managedByShim: $managedByShim, readOnly: $readOnly, hasSkillFile: $hasSkillFile, installedAt: $installedAt, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class _$CodexSkillCopyWith<$Res> implements $CodexSkillCopyWith<$Res> {
  factory _$CodexSkillCopyWith(_CodexSkill value, $Res Function(_CodexSkill) _then) = __$CodexSkillCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String path, bool managedByShim, bool readOnly, bool hasSkillFile, int installedAt, String contentHash
});




}
/// @nodoc
class __$CodexSkillCopyWithImpl<$Res>
    implements _$CodexSkillCopyWith<$Res> {
  __$CodexSkillCopyWithImpl(this._self, this._then);

  final _CodexSkill _self;
  final $Res Function(_CodexSkill) _then;

/// Create a copy of CodexSkill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? path = null,Object? managedByShim = null,Object? readOnly = null,Object? hasSkillFile = null,Object? installedAt = null,Object? contentHash = null,}) {
  return _then(_CodexSkill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,managedByShim: null == managedByShim ? _self.managedByShim : managedByShim // ignore: cast_nullable_to_non_nullable
as bool,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,hasSkillFile: null == hasSkillFile ? _self.hasSkillFile : hasSkillFile // ignore: cast_nullable_to_non_nullable
as bool,installedAt: null == installedAt ? _self.installedAt : installedAt // ignore: cast_nullable_to_non_nullable
as int,contentHash: null == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
