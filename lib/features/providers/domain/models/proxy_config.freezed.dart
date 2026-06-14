// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proxy_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProxyConfig {

 bool get enabled; int get port;
/// Create a copy of ProxyConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyConfigCopyWith<ProxyConfig> get copyWith => _$ProxyConfigCopyWithImpl<ProxyConfig>(this as ProxyConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyConfig&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.port, port) || other.port == port));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,port);

@override
String toString() {
  return 'ProxyConfig(enabled: $enabled, port: $port)';
}


}

/// @nodoc
abstract mixin class $ProxyConfigCopyWith<$Res>  {
  factory $ProxyConfigCopyWith(ProxyConfig value, $Res Function(ProxyConfig) _then) = _$ProxyConfigCopyWithImpl;
@useResult
$Res call({
 bool enabled, int port
});




}
/// @nodoc
class _$ProxyConfigCopyWithImpl<$Res>
    implements $ProxyConfigCopyWith<$Res> {
  _$ProxyConfigCopyWithImpl(this._self, this._then);

  final ProxyConfig _self;
  final $Res Function(ProxyConfig) _then;

/// Create a copy of ProxyConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? port = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxyConfig].
extension ProxyConfigPatterns on ProxyConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxyConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxyConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxyConfig value)  $default,){
final _that = this;
switch (_that) {
case _ProxyConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxyConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ProxyConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int port)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyConfig() when $default != null:
return $default(_that.enabled,_that.port);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int port)  $default,) {final _that = this;
switch (_that) {
case _ProxyConfig():
return $default(_that.enabled,_that.port);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int port)?  $default,) {final _that = this;
switch (_that) {
case _ProxyConfig() when $default != null:
return $default(_that.enabled,_that.port);case _:
  return null;

}
}

}

/// @nodoc


class _ProxyConfig extends ProxyConfig {
  const _ProxyConfig({this.enabled = false, this.port = 8787}): super._();
  

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  int port;

/// Create a copy of ProxyConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyConfigCopyWith<_ProxyConfig> get copyWith => __$ProxyConfigCopyWithImpl<_ProxyConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyConfig&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.port, port) || other.port == port));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,port);

@override
String toString() {
  return 'ProxyConfig(enabled: $enabled, port: $port)';
}


}

/// @nodoc
abstract mixin class _$ProxyConfigCopyWith<$Res> implements $ProxyConfigCopyWith<$Res> {
  factory _$ProxyConfigCopyWith(_ProxyConfig value, $Res Function(_ProxyConfig) _then) = __$ProxyConfigCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int port
});




}
/// @nodoc
class __$ProxyConfigCopyWithImpl<$Res>
    implements _$ProxyConfigCopyWith<$Res> {
  __$ProxyConfigCopyWithImpl(this._self, this._then);

  final _ProxyConfig _self;
  final $Res Function(_ProxyConfig) _then;

/// Create a copy of ProxyConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? port = null,}) {
  return _then(_ProxyConfig(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
