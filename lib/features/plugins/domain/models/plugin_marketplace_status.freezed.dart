// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plugin_marketplace_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PluginMarketplaceStatus {

 bool get installed; bool get configured; int get pluginCount; String get codexHome;
/// Create a copy of PluginMarketplaceStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PluginMarketplaceStatusCopyWith<PluginMarketplaceStatus> get copyWith => _$PluginMarketplaceStatusCopyWithImpl<PluginMarketplaceStatus>(this as PluginMarketplaceStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PluginMarketplaceStatus&&(identical(other.installed, installed) || other.installed == installed)&&(identical(other.configured, configured) || other.configured == configured)&&(identical(other.pluginCount, pluginCount) || other.pluginCount == pluginCount)&&(identical(other.codexHome, codexHome) || other.codexHome == codexHome));
}


@override
int get hashCode => Object.hash(runtimeType,installed,configured,pluginCount,codexHome);

@override
String toString() {
  return 'PluginMarketplaceStatus(installed: $installed, configured: $configured, pluginCount: $pluginCount, codexHome: $codexHome)';
}


}

/// @nodoc
abstract mixin class $PluginMarketplaceStatusCopyWith<$Res>  {
  factory $PluginMarketplaceStatusCopyWith(PluginMarketplaceStatus value, $Res Function(PluginMarketplaceStatus) _then) = _$PluginMarketplaceStatusCopyWithImpl;
@useResult
$Res call({
 bool installed, bool configured, int pluginCount, String codexHome
});




}
/// @nodoc
class _$PluginMarketplaceStatusCopyWithImpl<$Res>
    implements $PluginMarketplaceStatusCopyWith<$Res> {
  _$PluginMarketplaceStatusCopyWithImpl(this._self, this._then);

  final PluginMarketplaceStatus _self;
  final $Res Function(PluginMarketplaceStatus) _then;

/// Create a copy of PluginMarketplaceStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? installed = null,Object? configured = null,Object? pluginCount = null,Object? codexHome = null,}) {
  return _then(_self.copyWith(
installed: null == installed ? _self.installed : installed // ignore: cast_nullable_to_non_nullable
as bool,configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,pluginCount: null == pluginCount ? _self.pluginCount : pluginCount // ignore: cast_nullable_to_non_nullable
as int,codexHome: null == codexHome ? _self.codexHome : codexHome // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PluginMarketplaceStatus].
extension PluginMarketplaceStatusPatterns on PluginMarketplaceStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PluginMarketplaceStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PluginMarketplaceStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PluginMarketplaceStatus value)  $default,){
final _that = this;
switch (_that) {
case _PluginMarketplaceStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PluginMarketplaceStatus value)?  $default,){
final _that = this;
switch (_that) {
case _PluginMarketplaceStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool installed,  bool configured,  int pluginCount,  String codexHome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PluginMarketplaceStatus() when $default != null:
return $default(_that.installed,_that.configured,_that.pluginCount,_that.codexHome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool installed,  bool configured,  int pluginCount,  String codexHome)  $default,) {final _that = this;
switch (_that) {
case _PluginMarketplaceStatus():
return $default(_that.installed,_that.configured,_that.pluginCount,_that.codexHome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool installed,  bool configured,  int pluginCount,  String codexHome)?  $default,) {final _that = this;
switch (_that) {
case _PluginMarketplaceStatus() when $default != null:
return $default(_that.installed,_that.configured,_that.pluginCount,_that.codexHome);case _:
  return null;

}
}

}

/// @nodoc


class _PluginMarketplaceStatus extends PluginMarketplaceStatus {
  const _PluginMarketplaceStatus({required this.installed, required this.configured, required this.pluginCount, required this.codexHome}): super._();
  

@override final  bool installed;
@override final  bool configured;
@override final  int pluginCount;
@override final  String codexHome;

/// Create a copy of PluginMarketplaceStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PluginMarketplaceStatusCopyWith<_PluginMarketplaceStatus> get copyWith => __$PluginMarketplaceStatusCopyWithImpl<_PluginMarketplaceStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PluginMarketplaceStatus&&(identical(other.installed, installed) || other.installed == installed)&&(identical(other.configured, configured) || other.configured == configured)&&(identical(other.pluginCount, pluginCount) || other.pluginCount == pluginCount)&&(identical(other.codexHome, codexHome) || other.codexHome == codexHome));
}


@override
int get hashCode => Object.hash(runtimeType,installed,configured,pluginCount,codexHome);

@override
String toString() {
  return 'PluginMarketplaceStatus(installed: $installed, configured: $configured, pluginCount: $pluginCount, codexHome: $codexHome)';
}


}

/// @nodoc
abstract mixin class _$PluginMarketplaceStatusCopyWith<$Res> implements $PluginMarketplaceStatusCopyWith<$Res> {
  factory _$PluginMarketplaceStatusCopyWith(_PluginMarketplaceStatus value, $Res Function(_PluginMarketplaceStatus) _then) = __$PluginMarketplaceStatusCopyWithImpl;
@override @useResult
$Res call({
 bool installed, bool configured, int pluginCount, String codexHome
});




}
/// @nodoc
class __$PluginMarketplaceStatusCopyWithImpl<$Res>
    implements _$PluginMarketplaceStatusCopyWith<$Res> {
  __$PluginMarketplaceStatusCopyWithImpl(this._self, this._then);

  final _PluginMarketplaceStatus _self;
  final $Res Function(_PluginMarketplaceStatus) _then;

/// Create a copy of PluginMarketplaceStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? installed = null,Object? configured = null,Object? pluginCount = null,Object? codexHome = null,}) {
  return _then(_PluginMarketplaceStatus(
installed: null == installed ? _self.installed : installed // ignore: cast_nullable_to_non_nullable
as bool,configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,pluginCount: null == pluginCount ? _self.pluginCount : pluginCount // ignore: cast_nullable_to_non_nullable
as int,codexHome: null == codexHome ? _self.codexHome : codexHome // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
