// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_update_check_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUpdateCheckDto {

 bool get hasUpdate; String get currentVersion; String get latestVersion; AppUpdateReleaseDto get item;
/// Create a copy of AppUpdateCheckDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUpdateCheckDtoCopyWith<AppUpdateCheckDto> get copyWith => _$AppUpdateCheckDtoCopyWithImpl<AppUpdateCheckDto>(this as AppUpdateCheckDto, _$identity);

  /// Serializes this AppUpdateCheckDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUpdateCheckDto&&(identical(other.hasUpdate, hasUpdate) || other.hasUpdate == hasUpdate)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.item, item) || other.item == item));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hasUpdate,currentVersion,latestVersion,item);

@override
String toString() {
  return 'AppUpdateCheckDto(hasUpdate: $hasUpdate, currentVersion: $currentVersion, latestVersion: $latestVersion, item: $item)';
}


}

/// @nodoc
abstract mixin class $AppUpdateCheckDtoCopyWith<$Res>  {
  factory $AppUpdateCheckDtoCopyWith(AppUpdateCheckDto value, $Res Function(AppUpdateCheckDto) _then) = _$AppUpdateCheckDtoCopyWithImpl;
@useResult
$Res call({
 bool hasUpdate, String currentVersion, String latestVersion, AppUpdateReleaseDto item
});


$AppUpdateReleaseDtoCopyWith<$Res> get item;

}
/// @nodoc
class _$AppUpdateCheckDtoCopyWithImpl<$Res>
    implements $AppUpdateCheckDtoCopyWith<$Res> {
  _$AppUpdateCheckDtoCopyWithImpl(this._self, this._then);

  final AppUpdateCheckDto _self;
  final $Res Function(AppUpdateCheckDto) _then;

/// Create a copy of AppUpdateCheckDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasUpdate = null,Object? currentVersion = null,Object? latestVersion = null,Object? item = null,}) {
  return _then(_self.copyWith(
hasUpdate: null == hasUpdate ? _self.hasUpdate : hasUpdate // ignore: cast_nullable_to_non_nullable
as bool,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as AppUpdateReleaseDto,
  ));
}
/// Create a copy of AppUpdateCheckDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUpdateReleaseDtoCopyWith<$Res> get item {
  
  return $AppUpdateReleaseDtoCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppUpdateCheckDto].
extension AppUpdateCheckDtoPatterns on AppUpdateCheckDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUpdateCheckDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUpdateCheckDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUpdateCheckDto value)  $default,){
final _that = this;
switch (_that) {
case _AppUpdateCheckDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUpdateCheckDto value)?  $default,){
final _that = this;
switch (_that) {
case _AppUpdateCheckDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasUpdate,  String currentVersion,  String latestVersion,  AppUpdateReleaseDto item)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUpdateCheckDto() when $default != null:
return $default(_that.hasUpdate,_that.currentVersion,_that.latestVersion,_that.item);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasUpdate,  String currentVersion,  String latestVersion,  AppUpdateReleaseDto item)  $default,) {final _that = this;
switch (_that) {
case _AppUpdateCheckDto():
return $default(_that.hasUpdate,_that.currentVersion,_that.latestVersion,_that.item);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasUpdate,  String currentVersion,  String latestVersion,  AppUpdateReleaseDto item)?  $default,) {final _that = this;
switch (_that) {
case _AppUpdateCheckDto() when $default != null:
return $default(_that.hasUpdate,_that.currentVersion,_that.latestVersion,_that.item);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUpdateCheckDto extends AppUpdateCheckDto {
  const _AppUpdateCheckDto({this.hasUpdate = false, this.currentVersion = '', this.latestVersion = '', this.item = const AppUpdateReleaseDto()}): super._();
  factory _AppUpdateCheckDto.fromJson(Map<String, dynamic> json) => _$AppUpdateCheckDtoFromJson(json);

@override@JsonKey() final  bool hasUpdate;
@override@JsonKey() final  String currentVersion;
@override@JsonKey() final  String latestVersion;
@override@JsonKey() final  AppUpdateReleaseDto item;

/// Create a copy of AppUpdateCheckDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUpdateCheckDtoCopyWith<_AppUpdateCheckDto> get copyWith => __$AppUpdateCheckDtoCopyWithImpl<_AppUpdateCheckDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUpdateCheckDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUpdateCheckDto&&(identical(other.hasUpdate, hasUpdate) || other.hasUpdate == hasUpdate)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.item, item) || other.item == item));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hasUpdate,currentVersion,latestVersion,item);

@override
String toString() {
  return 'AppUpdateCheckDto(hasUpdate: $hasUpdate, currentVersion: $currentVersion, latestVersion: $latestVersion, item: $item)';
}


}

/// @nodoc
abstract mixin class _$AppUpdateCheckDtoCopyWith<$Res> implements $AppUpdateCheckDtoCopyWith<$Res> {
  factory _$AppUpdateCheckDtoCopyWith(_AppUpdateCheckDto value, $Res Function(_AppUpdateCheckDto) _then) = __$AppUpdateCheckDtoCopyWithImpl;
@override @useResult
$Res call({
 bool hasUpdate, String currentVersion, String latestVersion, AppUpdateReleaseDto item
});


@override $AppUpdateReleaseDtoCopyWith<$Res> get item;

}
/// @nodoc
class __$AppUpdateCheckDtoCopyWithImpl<$Res>
    implements _$AppUpdateCheckDtoCopyWith<$Res> {
  __$AppUpdateCheckDtoCopyWithImpl(this._self, this._then);

  final _AppUpdateCheckDto _self;
  final $Res Function(_AppUpdateCheckDto) _then;

/// Create a copy of AppUpdateCheckDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasUpdate = null,Object? currentVersion = null,Object? latestVersion = null,Object? item = null,}) {
  return _then(_AppUpdateCheckDto(
hasUpdate: null == hasUpdate ? _self.hasUpdate : hasUpdate // ignore: cast_nullable_to_non_nullable
as bool,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as AppUpdateReleaseDto,
  ));
}

/// Create a copy of AppUpdateCheckDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUpdateReleaseDtoCopyWith<$Res> get item {
  
  return $AppUpdateReleaseDtoCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}

// dart format on
