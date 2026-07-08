// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_update_check.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppUpdateCheck {

 bool get hasUpdate; String get currentVersion; String get latestVersion; AppUpdateSystem get system; AppUpdateRelease get item;
/// Create a copy of AppUpdateCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUpdateCheckCopyWith<AppUpdateCheck> get copyWith => _$AppUpdateCheckCopyWithImpl<AppUpdateCheck>(this as AppUpdateCheck, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUpdateCheck&&(identical(other.hasUpdate, hasUpdate) || other.hasUpdate == hasUpdate)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.system, system) || other.system == system)&&(identical(other.item, item) || other.item == item));
}


@override
int get hashCode => Object.hash(runtimeType,hasUpdate,currentVersion,latestVersion,system,item);

@override
String toString() {
  return 'AppUpdateCheck(hasUpdate: $hasUpdate, currentVersion: $currentVersion, latestVersion: $latestVersion, system: $system, item: $item)';
}


}

/// @nodoc
abstract mixin class $AppUpdateCheckCopyWith<$Res>  {
  factory $AppUpdateCheckCopyWith(AppUpdateCheck value, $Res Function(AppUpdateCheck) _then) = _$AppUpdateCheckCopyWithImpl;
@useResult
$Res call({
 bool hasUpdate, String currentVersion, String latestVersion, AppUpdateSystem system, AppUpdateRelease item
});


$AppUpdateReleaseCopyWith<$Res> get item;

}
/// @nodoc
class _$AppUpdateCheckCopyWithImpl<$Res>
    implements $AppUpdateCheckCopyWith<$Res> {
  _$AppUpdateCheckCopyWithImpl(this._self, this._then);

  final AppUpdateCheck _self;
  final $Res Function(AppUpdateCheck) _then;

/// Create a copy of AppUpdateCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasUpdate = null,Object? currentVersion = null,Object? latestVersion = null,Object? system = null,Object? item = null,}) {
  return _then(_self.copyWith(
hasUpdate: null == hasUpdate ? _self.hasUpdate : hasUpdate // ignore: cast_nullable_to_non_nullable
as bool,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as AppUpdateSystem,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as AppUpdateRelease,
  ));
}
/// Create a copy of AppUpdateCheck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUpdateReleaseCopyWith<$Res> get item {
  
  return $AppUpdateReleaseCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppUpdateCheck].
extension AppUpdateCheckPatterns on AppUpdateCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUpdateCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUpdateCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUpdateCheck value)  $default,){
final _that = this;
switch (_that) {
case _AppUpdateCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUpdateCheck value)?  $default,){
final _that = this;
switch (_that) {
case _AppUpdateCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasUpdate,  String currentVersion,  String latestVersion,  AppUpdateSystem system,  AppUpdateRelease item)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUpdateCheck() when $default != null:
return $default(_that.hasUpdate,_that.currentVersion,_that.latestVersion,_that.system,_that.item);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasUpdate,  String currentVersion,  String latestVersion,  AppUpdateSystem system,  AppUpdateRelease item)  $default,) {final _that = this;
switch (_that) {
case _AppUpdateCheck():
return $default(_that.hasUpdate,_that.currentVersion,_that.latestVersion,_that.system,_that.item);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasUpdate,  String currentVersion,  String latestVersion,  AppUpdateSystem system,  AppUpdateRelease item)?  $default,) {final _that = this;
switch (_that) {
case _AppUpdateCheck() when $default != null:
return $default(_that.hasUpdate,_that.currentVersion,_that.latestVersion,_that.system,_that.item);case _:
  return null;

}
}

}

/// @nodoc


class _AppUpdateCheck extends AppUpdateCheck {
  const _AppUpdateCheck({required this.hasUpdate, required this.currentVersion, required this.latestVersion, required this.system, required this.item}): super._();
  

@override final  bool hasUpdate;
@override final  String currentVersion;
@override final  String latestVersion;
@override final  AppUpdateSystem system;
@override final  AppUpdateRelease item;

/// Create a copy of AppUpdateCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUpdateCheckCopyWith<_AppUpdateCheck> get copyWith => __$AppUpdateCheckCopyWithImpl<_AppUpdateCheck>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUpdateCheck&&(identical(other.hasUpdate, hasUpdate) || other.hasUpdate == hasUpdate)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.system, system) || other.system == system)&&(identical(other.item, item) || other.item == item));
}


@override
int get hashCode => Object.hash(runtimeType,hasUpdate,currentVersion,latestVersion,system,item);

@override
String toString() {
  return 'AppUpdateCheck(hasUpdate: $hasUpdate, currentVersion: $currentVersion, latestVersion: $latestVersion, system: $system, item: $item)';
}


}

/// @nodoc
abstract mixin class _$AppUpdateCheckCopyWith<$Res> implements $AppUpdateCheckCopyWith<$Res> {
  factory _$AppUpdateCheckCopyWith(_AppUpdateCheck value, $Res Function(_AppUpdateCheck) _then) = __$AppUpdateCheckCopyWithImpl;
@override @useResult
$Res call({
 bool hasUpdate, String currentVersion, String latestVersion, AppUpdateSystem system, AppUpdateRelease item
});


@override $AppUpdateReleaseCopyWith<$Res> get item;

}
/// @nodoc
class __$AppUpdateCheckCopyWithImpl<$Res>
    implements _$AppUpdateCheckCopyWith<$Res> {
  __$AppUpdateCheckCopyWithImpl(this._self, this._then);

  final _AppUpdateCheck _self;
  final $Res Function(_AppUpdateCheck) _then;

/// Create a copy of AppUpdateCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasUpdate = null,Object? currentVersion = null,Object? latestVersion = null,Object? system = null,Object? item = null,}) {
  return _then(_AppUpdateCheck(
hasUpdate: null == hasUpdate ? _self.hasUpdate : hasUpdate // ignore: cast_nullable_to_non_nullable
as bool,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as AppUpdateSystem,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as AppUpdateRelease,
  ));
}

/// Create a copy of AppUpdateCheck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUpdateReleaseCopyWith<$Res> get item {
  
  return $AppUpdateReleaseCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}

// dart format on
