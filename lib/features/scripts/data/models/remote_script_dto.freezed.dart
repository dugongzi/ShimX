// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_script_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RemoteScriptDto {

 String get id; String get name; String get description; String get version; String get author; String get fileName; String get downloadUrl; String get sha256;
/// Create a copy of RemoteScriptDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteScriptDtoCopyWith<RemoteScriptDto> get copyWith => _$RemoteScriptDtoCopyWithImpl<RemoteScriptDto>(this as RemoteScriptDto, _$identity);

  /// Serializes this RemoteScriptDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteScriptDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.version, version) || other.version == version)&&(identical(other.author, author) || other.author == author)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,version,author,fileName,downloadUrl,sha256);

@override
String toString() {
  return 'RemoteScriptDto(id: $id, name: $name, description: $description, version: $version, author: $author, fileName: $fileName, downloadUrl: $downloadUrl, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class $RemoteScriptDtoCopyWith<$Res>  {
  factory $RemoteScriptDtoCopyWith(RemoteScriptDto value, $Res Function(RemoteScriptDto) _then) = _$RemoteScriptDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String version, String author, String fileName, String downloadUrl, String sha256
});




}
/// @nodoc
class _$RemoteScriptDtoCopyWithImpl<$Res>
    implements $RemoteScriptDtoCopyWith<$Res> {
  _$RemoteScriptDtoCopyWithImpl(this._self, this._then);

  final RemoteScriptDto _self;
  final $Res Function(RemoteScriptDto) _then;

/// Create a copy of RemoteScriptDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? version = null,Object? author = null,Object? fileName = null,Object? downloadUrl = null,Object? sha256 = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteScriptDto].
extension RemoteScriptDtoPatterns on RemoteScriptDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteScriptDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteScriptDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteScriptDto value)  $default,){
final _that = this;
switch (_that) {
case _RemoteScriptDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteScriptDto value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteScriptDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String version,  String author,  String fileName,  String downloadUrl,  String sha256)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteScriptDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.version,_that.author,_that.fileName,_that.downloadUrl,_that.sha256);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String version,  String author,  String fileName,  String downloadUrl,  String sha256)  $default,) {final _that = this;
switch (_that) {
case _RemoteScriptDto():
return $default(_that.id,_that.name,_that.description,_that.version,_that.author,_that.fileName,_that.downloadUrl,_that.sha256);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String version,  String author,  String fileName,  String downloadUrl,  String sha256)?  $default,) {final _that = this;
switch (_that) {
case _RemoteScriptDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.version,_that.author,_that.fileName,_that.downloadUrl,_that.sha256);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteScriptDto extends RemoteScriptDto {
  const _RemoteScriptDto({this.id = '', this.name = '', this.description = '', this.version = '', this.author = '', this.fileName = '', this.downloadUrl = '', this.sha256 = ''}): super._();
  factory _RemoteScriptDto.fromJson(Map<String, dynamic> json) => _$RemoteScriptDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  String version;
@override@JsonKey() final  String author;
@override@JsonKey() final  String fileName;
@override@JsonKey() final  String downloadUrl;
@override@JsonKey() final  String sha256;

/// Create a copy of RemoteScriptDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteScriptDtoCopyWith<_RemoteScriptDto> get copyWith => __$RemoteScriptDtoCopyWithImpl<_RemoteScriptDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteScriptDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteScriptDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.version, version) || other.version == version)&&(identical(other.author, author) || other.author == author)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,version,author,fileName,downloadUrl,sha256);

@override
String toString() {
  return 'RemoteScriptDto(id: $id, name: $name, description: $description, version: $version, author: $author, fileName: $fileName, downloadUrl: $downloadUrl, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class _$RemoteScriptDtoCopyWith<$Res> implements $RemoteScriptDtoCopyWith<$Res> {
  factory _$RemoteScriptDtoCopyWith(_RemoteScriptDto value, $Res Function(_RemoteScriptDto) _then) = __$RemoteScriptDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String version, String author, String fileName, String downloadUrl, String sha256
});




}
/// @nodoc
class __$RemoteScriptDtoCopyWithImpl<$Res>
    implements _$RemoteScriptDtoCopyWith<$Res> {
  __$RemoteScriptDtoCopyWithImpl(this._self, this._then);

  final _RemoteScriptDto _self;
  final $Res Function(_RemoteScriptDto) _then;

/// Create a copy of RemoteScriptDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? version = null,Object? author = null,Object? fileName = null,Object? downloadUrl = null,Object? sha256 = null,}) {
  return _then(_RemoteScriptDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
