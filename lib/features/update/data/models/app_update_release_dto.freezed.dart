// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_update_release_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUpdateReleaseDto {

 int get id; String get version; int get versionCode; String get system; String get changelog; String get downloadUrl; bool get forceUpdate; String get minSupportedVersion; int get fileSize; String get sha256; String get status; String get publishedAt; String get createdAt; String get updatedAt;
/// Create a copy of AppUpdateReleaseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUpdateReleaseDtoCopyWith<AppUpdateReleaseDto> get copyWith => _$AppUpdateReleaseDtoCopyWithImpl<AppUpdateReleaseDto>(this as AppUpdateReleaseDto, _$identity);

  /// Serializes this AppUpdateReleaseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUpdateReleaseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.versionCode, versionCode) || other.versionCode == versionCode)&&(identical(other.system, system) || other.system == system)&&(identical(other.changelog, changelog) || other.changelog == changelog)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.forceUpdate, forceUpdate) || other.forceUpdate == forceUpdate)&&(identical(other.minSupportedVersion, minSupportedVersion) || other.minSupportedVersion == minSupportedVersion)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.status, status) || other.status == status)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,version,versionCode,system,changelog,downloadUrl,forceUpdate,minSupportedVersion,fileSize,sha256,status,publishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'AppUpdateReleaseDto(id: $id, version: $version, versionCode: $versionCode, system: $system, changelog: $changelog, downloadUrl: $downloadUrl, forceUpdate: $forceUpdate, minSupportedVersion: $minSupportedVersion, fileSize: $fileSize, sha256: $sha256, status: $status, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AppUpdateReleaseDtoCopyWith<$Res>  {
  factory $AppUpdateReleaseDtoCopyWith(AppUpdateReleaseDto value, $Res Function(AppUpdateReleaseDto) _then) = _$AppUpdateReleaseDtoCopyWithImpl;
@useResult
$Res call({
 int id, String version, int versionCode, String system, String changelog, String downloadUrl, bool forceUpdate, String minSupportedVersion, int fileSize, String sha256, String status, String publishedAt, String createdAt, String updatedAt
});




}
/// @nodoc
class _$AppUpdateReleaseDtoCopyWithImpl<$Res>
    implements $AppUpdateReleaseDtoCopyWith<$Res> {
  _$AppUpdateReleaseDtoCopyWithImpl(this._self, this._then);

  final AppUpdateReleaseDto _self;
  final $Res Function(AppUpdateReleaseDto) _then;

/// Create a copy of AppUpdateReleaseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? version = null,Object? versionCode = null,Object? system = null,Object? changelog = null,Object? downloadUrl = null,Object? forceUpdate = null,Object? minSupportedVersion = null,Object? fileSize = null,Object? sha256 = null,Object? status = null,Object? publishedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,versionCode: null == versionCode ? _self.versionCode : versionCode // ignore: cast_nullable_to_non_nullable
as int,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as String,changelog: null == changelog ? _self.changelog : changelog // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,forceUpdate: null == forceUpdate ? _self.forceUpdate : forceUpdate // ignore: cast_nullable_to_non_nullable
as bool,minSupportedVersion: null == minSupportedVersion ? _self.minSupportedVersion : minSupportedVersion // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUpdateReleaseDto].
extension AppUpdateReleaseDtoPatterns on AppUpdateReleaseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUpdateReleaseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUpdateReleaseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUpdateReleaseDto value)  $default,){
final _that = this;
switch (_that) {
case _AppUpdateReleaseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUpdateReleaseDto value)?  $default,){
final _that = this;
switch (_that) {
case _AppUpdateReleaseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String version,  int versionCode,  String system,  String changelog,  String downloadUrl,  bool forceUpdate,  String minSupportedVersion,  int fileSize,  String sha256,  String status,  String publishedAt,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUpdateReleaseDto() when $default != null:
return $default(_that.id,_that.version,_that.versionCode,_that.system,_that.changelog,_that.downloadUrl,_that.forceUpdate,_that.minSupportedVersion,_that.fileSize,_that.sha256,_that.status,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String version,  int versionCode,  String system,  String changelog,  String downloadUrl,  bool forceUpdate,  String minSupportedVersion,  int fileSize,  String sha256,  String status,  String publishedAt,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppUpdateReleaseDto():
return $default(_that.id,_that.version,_that.versionCode,_that.system,_that.changelog,_that.downloadUrl,_that.forceUpdate,_that.minSupportedVersion,_that.fileSize,_that.sha256,_that.status,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String version,  int versionCode,  String system,  String changelog,  String downloadUrl,  bool forceUpdate,  String minSupportedVersion,  int fileSize,  String sha256,  String status,  String publishedAt,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppUpdateReleaseDto() when $default != null:
return $default(_that.id,_that.version,_that.versionCode,_that.system,_that.changelog,_that.downloadUrl,_that.forceUpdate,_that.minSupportedVersion,_that.fileSize,_that.sha256,_that.status,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUpdateReleaseDto extends AppUpdateReleaseDto {
  const _AppUpdateReleaseDto({this.id = 0, this.version = '', this.versionCode = 0, this.system = '', this.changelog = '', this.downloadUrl = '', this.forceUpdate = false, this.minSupportedVersion = '', this.fileSize = 0, this.sha256 = '', this.status = '', this.publishedAt = '', this.createdAt = '', this.updatedAt = ''}): super._();
  factory _AppUpdateReleaseDto.fromJson(Map<String, dynamic> json) => _$AppUpdateReleaseDtoFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String version;
@override@JsonKey() final  int versionCode;
@override@JsonKey() final  String system;
@override@JsonKey() final  String changelog;
@override@JsonKey() final  String downloadUrl;
@override@JsonKey() final  bool forceUpdate;
@override@JsonKey() final  String minSupportedVersion;
@override@JsonKey() final  int fileSize;
@override@JsonKey() final  String sha256;
@override@JsonKey() final  String status;
@override@JsonKey() final  String publishedAt;
@override@JsonKey() final  String createdAt;
@override@JsonKey() final  String updatedAt;

/// Create a copy of AppUpdateReleaseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUpdateReleaseDtoCopyWith<_AppUpdateReleaseDto> get copyWith => __$AppUpdateReleaseDtoCopyWithImpl<_AppUpdateReleaseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUpdateReleaseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUpdateReleaseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.versionCode, versionCode) || other.versionCode == versionCode)&&(identical(other.system, system) || other.system == system)&&(identical(other.changelog, changelog) || other.changelog == changelog)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.forceUpdate, forceUpdate) || other.forceUpdate == forceUpdate)&&(identical(other.minSupportedVersion, minSupportedVersion) || other.minSupportedVersion == minSupportedVersion)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.status, status) || other.status == status)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,version,versionCode,system,changelog,downloadUrl,forceUpdate,minSupportedVersion,fileSize,sha256,status,publishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'AppUpdateReleaseDto(id: $id, version: $version, versionCode: $versionCode, system: $system, changelog: $changelog, downloadUrl: $downloadUrl, forceUpdate: $forceUpdate, minSupportedVersion: $minSupportedVersion, fileSize: $fileSize, sha256: $sha256, status: $status, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppUpdateReleaseDtoCopyWith<$Res> implements $AppUpdateReleaseDtoCopyWith<$Res> {
  factory _$AppUpdateReleaseDtoCopyWith(_AppUpdateReleaseDto value, $Res Function(_AppUpdateReleaseDto) _then) = __$AppUpdateReleaseDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String version, int versionCode, String system, String changelog, String downloadUrl, bool forceUpdate, String minSupportedVersion, int fileSize, String sha256, String status, String publishedAt, String createdAt, String updatedAt
});




}
/// @nodoc
class __$AppUpdateReleaseDtoCopyWithImpl<$Res>
    implements _$AppUpdateReleaseDtoCopyWith<$Res> {
  __$AppUpdateReleaseDtoCopyWithImpl(this._self, this._then);

  final _AppUpdateReleaseDto _self;
  final $Res Function(_AppUpdateReleaseDto) _then;

/// Create a copy of AppUpdateReleaseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? version = null,Object? versionCode = null,Object? system = null,Object? changelog = null,Object? downloadUrl = null,Object? forceUpdate = null,Object? minSupportedVersion = null,Object? fileSize = null,Object? sha256 = null,Object? status = null,Object? publishedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AppUpdateReleaseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,versionCode: null == versionCode ? _self.versionCode : versionCode // ignore: cast_nullable_to_non_nullable
as int,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as String,changelog: null == changelog ? _self.changelog : changelog // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,forceUpdate: null == forceUpdate ? _self.forceUpdate : forceUpdate // ignore: cast_nullable_to_non_nullable
as bool,minSupportedVersion: null == minSupportedVersion ? _self.minSupportedVersion : minSupportedVersion // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
