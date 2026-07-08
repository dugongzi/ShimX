// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_update_release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppUpdateRelease {

 int get id; String get version; int get versionCode; AppUpdateSystem get system; String get changelog; String get downloadUrl; bool get forceUpdate; String get minSupportedVersion; int get fileSize; String get sha256; String get status; DateTime get publishedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of AppUpdateRelease
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUpdateReleaseCopyWith<AppUpdateRelease> get copyWith => _$AppUpdateReleaseCopyWithImpl<AppUpdateRelease>(this as AppUpdateRelease, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUpdateRelease&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.versionCode, versionCode) || other.versionCode == versionCode)&&(identical(other.system, system) || other.system == system)&&(identical(other.changelog, changelog) || other.changelog == changelog)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.forceUpdate, forceUpdate) || other.forceUpdate == forceUpdate)&&(identical(other.minSupportedVersion, minSupportedVersion) || other.minSupportedVersion == minSupportedVersion)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.status, status) || other.status == status)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,version,versionCode,system,changelog,downloadUrl,forceUpdate,minSupportedVersion,fileSize,sha256,status,publishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'AppUpdateRelease(id: $id, version: $version, versionCode: $versionCode, system: $system, changelog: $changelog, downloadUrl: $downloadUrl, forceUpdate: $forceUpdate, minSupportedVersion: $minSupportedVersion, fileSize: $fileSize, sha256: $sha256, status: $status, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AppUpdateReleaseCopyWith<$Res>  {
  factory $AppUpdateReleaseCopyWith(AppUpdateRelease value, $Res Function(AppUpdateRelease) _then) = _$AppUpdateReleaseCopyWithImpl;
@useResult
$Res call({
 int id, String version, int versionCode, AppUpdateSystem system, String changelog, String downloadUrl, bool forceUpdate, String minSupportedVersion, int fileSize, String sha256, String status, DateTime publishedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$AppUpdateReleaseCopyWithImpl<$Res>
    implements $AppUpdateReleaseCopyWith<$Res> {
  _$AppUpdateReleaseCopyWithImpl(this._self, this._then);

  final AppUpdateRelease _self;
  final $Res Function(AppUpdateRelease) _then;

/// Create a copy of AppUpdateRelease
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? version = null,Object? versionCode = null,Object? system = null,Object? changelog = null,Object? downloadUrl = null,Object? forceUpdate = null,Object? minSupportedVersion = null,Object? fileSize = null,Object? sha256 = null,Object? status = null,Object? publishedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,versionCode: null == versionCode ? _self.versionCode : versionCode // ignore: cast_nullable_to_non_nullable
as int,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as AppUpdateSystem,changelog: null == changelog ? _self.changelog : changelog // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,forceUpdate: null == forceUpdate ? _self.forceUpdate : forceUpdate // ignore: cast_nullable_to_non_nullable
as bool,minSupportedVersion: null == minSupportedVersion ? _self.minSupportedVersion : minSupportedVersion // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUpdateRelease].
extension AppUpdateReleasePatterns on AppUpdateRelease {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUpdateRelease value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUpdateRelease() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUpdateRelease value)  $default,){
final _that = this;
switch (_that) {
case _AppUpdateRelease():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUpdateRelease value)?  $default,){
final _that = this;
switch (_that) {
case _AppUpdateRelease() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String version,  int versionCode,  AppUpdateSystem system,  String changelog,  String downloadUrl,  bool forceUpdate,  String minSupportedVersion,  int fileSize,  String sha256,  String status,  DateTime publishedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUpdateRelease() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String version,  int versionCode,  AppUpdateSystem system,  String changelog,  String downloadUrl,  bool forceUpdate,  String minSupportedVersion,  int fileSize,  String sha256,  String status,  DateTime publishedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppUpdateRelease():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String version,  int versionCode,  AppUpdateSystem system,  String changelog,  String downloadUrl,  bool forceUpdate,  String minSupportedVersion,  int fileSize,  String sha256,  String status,  DateTime publishedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppUpdateRelease() when $default != null:
return $default(_that.id,_that.version,_that.versionCode,_that.system,_that.changelog,_that.downloadUrl,_that.forceUpdate,_that.minSupportedVersion,_that.fileSize,_that.sha256,_that.status,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AppUpdateRelease extends AppUpdateRelease {
  const _AppUpdateRelease({required this.id, required this.version, required this.versionCode, required this.system, required this.changelog, required this.downloadUrl, required this.forceUpdate, required this.minSupportedVersion, required this.fileSize, required this.sha256, required this.status, required this.publishedAt, required this.createdAt, required this.updatedAt}): super._();
  

@override final  int id;
@override final  String version;
@override final  int versionCode;
@override final  AppUpdateSystem system;
@override final  String changelog;
@override final  String downloadUrl;
@override final  bool forceUpdate;
@override final  String minSupportedVersion;
@override final  int fileSize;
@override final  String sha256;
@override final  String status;
@override final  DateTime publishedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of AppUpdateRelease
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUpdateReleaseCopyWith<_AppUpdateRelease> get copyWith => __$AppUpdateReleaseCopyWithImpl<_AppUpdateRelease>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUpdateRelease&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.versionCode, versionCode) || other.versionCode == versionCode)&&(identical(other.system, system) || other.system == system)&&(identical(other.changelog, changelog) || other.changelog == changelog)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.forceUpdate, forceUpdate) || other.forceUpdate == forceUpdate)&&(identical(other.minSupportedVersion, minSupportedVersion) || other.minSupportedVersion == minSupportedVersion)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.status, status) || other.status == status)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,version,versionCode,system,changelog,downloadUrl,forceUpdate,minSupportedVersion,fileSize,sha256,status,publishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'AppUpdateRelease(id: $id, version: $version, versionCode: $versionCode, system: $system, changelog: $changelog, downloadUrl: $downloadUrl, forceUpdate: $forceUpdate, minSupportedVersion: $minSupportedVersion, fileSize: $fileSize, sha256: $sha256, status: $status, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppUpdateReleaseCopyWith<$Res> implements $AppUpdateReleaseCopyWith<$Res> {
  factory _$AppUpdateReleaseCopyWith(_AppUpdateRelease value, $Res Function(_AppUpdateRelease) _then) = __$AppUpdateReleaseCopyWithImpl;
@override @useResult
$Res call({
 int id, String version, int versionCode, AppUpdateSystem system, String changelog, String downloadUrl, bool forceUpdate, String minSupportedVersion, int fileSize, String sha256, String status, DateTime publishedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$AppUpdateReleaseCopyWithImpl<$Res>
    implements _$AppUpdateReleaseCopyWith<$Res> {
  __$AppUpdateReleaseCopyWithImpl(this._self, this._then);

  final _AppUpdateRelease _self;
  final $Res Function(_AppUpdateRelease) _then;

/// Create a copy of AppUpdateRelease
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? version = null,Object? versionCode = null,Object? system = null,Object? changelog = null,Object? downloadUrl = null,Object? forceUpdate = null,Object? minSupportedVersion = null,Object? fileSize = null,Object? sha256 = null,Object? status = null,Object? publishedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AppUpdateRelease(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,versionCode: null == versionCode ? _self.versionCode : versionCode // ignore: cast_nullable_to_non_nullable
as int,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as AppUpdateSystem,changelog: null == changelog ? _self.changelog : changelog // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,forceUpdate: null == forceUpdate ? _self.forceUpdate : forceUpdate // ignore: cast_nullable_to_non_nullable
as bool,minSupportedVersion: null == minSupportedVersion ? _self.minSupportedVersion : minSupportedVersion // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
