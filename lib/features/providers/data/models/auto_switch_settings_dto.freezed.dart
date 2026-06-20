// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_switch_settings_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AutoSwitchSettingsDto {

 String get strategy; String get scope; int get failureThreshold; int get fastestMarginMs; int get cooldownSeconds; int get probeIntervalSeconds; int get slowRequestTimeoutSeconds; int get slowRequestSwitchThreshold;
/// Create a copy of AutoSwitchSettingsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoSwitchSettingsDtoCopyWith<AutoSwitchSettingsDto> get copyWith => _$AutoSwitchSettingsDtoCopyWithImpl<AutoSwitchSettingsDto>(this as AutoSwitchSettingsDto, _$identity);

  /// Serializes this AutoSwitchSettingsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoSwitchSettingsDto&&(identical(other.strategy, strategy) || other.strategy == strategy)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.failureThreshold, failureThreshold) || other.failureThreshold == failureThreshold)&&(identical(other.fastestMarginMs, fastestMarginMs) || other.fastestMarginMs == fastestMarginMs)&&(identical(other.cooldownSeconds, cooldownSeconds) || other.cooldownSeconds == cooldownSeconds)&&(identical(other.probeIntervalSeconds, probeIntervalSeconds) || other.probeIntervalSeconds == probeIntervalSeconds)&&(identical(other.slowRequestTimeoutSeconds, slowRequestTimeoutSeconds) || other.slowRequestTimeoutSeconds == slowRequestTimeoutSeconds)&&(identical(other.slowRequestSwitchThreshold, slowRequestSwitchThreshold) || other.slowRequestSwitchThreshold == slowRequestSwitchThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,strategy,scope,failureThreshold,fastestMarginMs,cooldownSeconds,probeIntervalSeconds,slowRequestTimeoutSeconds,slowRequestSwitchThreshold);

@override
String toString() {
  return 'AutoSwitchSettingsDto(strategy: $strategy, scope: $scope, failureThreshold: $failureThreshold, fastestMarginMs: $fastestMarginMs, cooldownSeconds: $cooldownSeconds, probeIntervalSeconds: $probeIntervalSeconds, slowRequestTimeoutSeconds: $slowRequestTimeoutSeconds, slowRequestSwitchThreshold: $slowRequestSwitchThreshold)';
}


}

/// @nodoc
abstract mixin class $AutoSwitchSettingsDtoCopyWith<$Res>  {
  factory $AutoSwitchSettingsDtoCopyWith(AutoSwitchSettingsDto value, $Res Function(AutoSwitchSettingsDto) _then) = _$AutoSwitchSettingsDtoCopyWithImpl;
@useResult
$Res call({
 String strategy, String scope, int failureThreshold, int fastestMarginMs, int cooldownSeconds, int probeIntervalSeconds, int slowRequestTimeoutSeconds, int slowRequestSwitchThreshold
});




}
/// @nodoc
class _$AutoSwitchSettingsDtoCopyWithImpl<$Res>
    implements $AutoSwitchSettingsDtoCopyWith<$Res> {
  _$AutoSwitchSettingsDtoCopyWithImpl(this._self, this._then);

  final AutoSwitchSettingsDto _self;
  final $Res Function(AutoSwitchSettingsDto) _then;

/// Create a copy of AutoSwitchSettingsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? strategy = null,Object? scope = null,Object? failureThreshold = null,Object? fastestMarginMs = null,Object? cooldownSeconds = null,Object? probeIntervalSeconds = null,Object? slowRequestTimeoutSeconds = null,Object? slowRequestSwitchThreshold = null,}) {
  return _then(_self.copyWith(
strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,failureThreshold: null == failureThreshold ? _self.failureThreshold : failureThreshold // ignore: cast_nullable_to_non_nullable
as int,fastestMarginMs: null == fastestMarginMs ? _self.fastestMarginMs : fastestMarginMs // ignore: cast_nullable_to_non_nullable
as int,cooldownSeconds: null == cooldownSeconds ? _self.cooldownSeconds : cooldownSeconds // ignore: cast_nullable_to_non_nullable
as int,probeIntervalSeconds: null == probeIntervalSeconds ? _self.probeIntervalSeconds : probeIntervalSeconds // ignore: cast_nullable_to_non_nullable
as int,slowRequestTimeoutSeconds: null == slowRequestTimeoutSeconds ? _self.slowRequestTimeoutSeconds : slowRequestTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,slowRequestSwitchThreshold: null == slowRequestSwitchThreshold ? _self.slowRequestSwitchThreshold : slowRequestSwitchThreshold // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoSwitchSettingsDto].
extension AutoSwitchSettingsDtoPatterns on AutoSwitchSettingsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutoSwitchSettingsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutoSwitchSettingsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutoSwitchSettingsDto value)  $default,){
final _that = this;
switch (_that) {
case _AutoSwitchSettingsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutoSwitchSettingsDto value)?  $default,){
final _that = this;
switch (_that) {
case _AutoSwitchSettingsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String strategy,  String scope,  int failureThreshold,  int fastestMarginMs,  int cooldownSeconds,  int probeIntervalSeconds,  int slowRequestTimeoutSeconds,  int slowRequestSwitchThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutoSwitchSettingsDto() when $default != null:
return $default(_that.strategy,_that.scope,_that.failureThreshold,_that.fastestMarginMs,_that.cooldownSeconds,_that.probeIntervalSeconds,_that.slowRequestTimeoutSeconds,_that.slowRequestSwitchThreshold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String strategy,  String scope,  int failureThreshold,  int fastestMarginMs,  int cooldownSeconds,  int probeIntervalSeconds,  int slowRequestTimeoutSeconds,  int slowRequestSwitchThreshold)  $default,) {final _that = this;
switch (_that) {
case _AutoSwitchSettingsDto():
return $default(_that.strategy,_that.scope,_that.failureThreshold,_that.fastestMarginMs,_that.cooldownSeconds,_that.probeIntervalSeconds,_that.slowRequestTimeoutSeconds,_that.slowRequestSwitchThreshold);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String strategy,  String scope,  int failureThreshold,  int fastestMarginMs,  int cooldownSeconds,  int probeIntervalSeconds,  int slowRequestTimeoutSeconds,  int slowRequestSwitchThreshold)?  $default,) {final _that = this;
switch (_that) {
case _AutoSwitchSettingsDto() when $default != null:
return $default(_that.strategy,_that.scope,_that.failureThreshold,_that.fastestMarginMs,_that.cooldownSeconds,_that.probeIntervalSeconds,_that.slowRequestTimeoutSeconds,_that.slowRequestSwitchThreshold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AutoSwitchSettingsDto extends AutoSwitchSettingsDto {
  const _AutoSwitchSettingsDto({this.strategy = 'manual', this.scope = 'same-type', this.failureThreshold = 3, this.fastestMarginMs = 200, this.cooldownSeconds = 10, this.probeIntervalSeconds = 300, this.slowRequestTimeoutSeconds = 20, this.slowRequestSwitchThreshold = 1}): super._();
  factory _AutoSwitchSettingsDto.fromJson(Map<String, dynamic> json) => _$AutoSwitchSettingsDtoFromJson(json);

@override@JsonKey() final  String strategy;
@override@JsonKey() final  String scope;
@override@JsonKey() final  int failureThreshold;
@override@JsonKey() final  int fastestMarginMs;
@override@JsonKey() final  int cooldownSeconds;
@override@JsonKey() final  int probeIntervalSeconds;
@override@JsonKey() final  int slowRequestTimeoutSeconds;
@override@JsonKey() final  int slowRequestSwitchThreshold;

/// Create a copy of AutoSwitchSettingsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutoSwitchSettingsDtoCopyWith<_AutoSwitchSettingsDto> get copyWith => __$AutoSwitchSettingsDtoCopyWithImpl<_AutoSwitchSettingsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutoSwitchSettingsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutoSwitchSettingsDto&&(identical(other.strategy, strategy) || other.strategy == strategy)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.failureThreshold, failureThreshold) || other.failureThreshold == failureThreshold)&&(identical(other.fastestMarginMs, fastestMarginMs) || other.fastestMarginMs == fastestMarginMs)&&(identical(other.cooldownSeconds, cooldownSeconds) || other.cooldownSeconds == cooldownSeconds)&&(identical(other.probeIntervalSeconds, probeIntervalSeconds) || other.probeIntervalSeconds == probeIntervalSeconds)&&(identical(other.slowRequestTimeoutSeconds, slowRequestTimeoutSeconds) || other.slowRequestTimeoutSeconds == slowRequestTimeoutSeconds)&&(identical(other.slowRequestSwitchThreshold, slowRequestSwitchThreshold) || other.slowRequestSwitchThreshold == slowRequestSwitchThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,strategy,scope,failureThreshold,fastestMarginMs,cooldownSeconds,probeIntervalSeconds,slowRequestTimeoutSeconds,slowRequestSwitchThreshold);

@override
String toString() {
  return 'AutoSwitchSettingsDto(strategy: $strategy, scope: $scope, failureThreshold: $failureThreshold, fastestMarginMs: $fastestMarginMs, cooldownSeconds: $cooldownSeconds, probeIntervalSeconds: $probeIntervalSeconds, slowRequestTimeoutSeconds: $slowRequestTimeoutSeconds, slowRequestSwitchThreshold: $slowRequestSwitchThreshold)';
}


}

/// @nodoc
abstract mixin class _$AutoSwitchSettingsDtoCopyWith<$Res> implements $AutoSwitchSettingsDtoCopyWith<$Res> {
  factory _$AutoSwitchSettingsDtoCopyWith(_AutoSwitchSettingsDto value, $Res Function(_AutoSwitchSettingsDto) _then) = __$AutoSwitchSettingsDtoCopyWithImpl;
@override @useResult
$Res call({
 String strategy, String scope, int failureThreshold, int fastestMarginMs, int cooldownSeconds, int probeIntervalSeconds, int slowRequestTimeoutSeconds, int slowRequestSwitchThreshold
});




}
/// @nodoc
class __$AutoSwitchSettingsDtoCopyWithImpl<$Res>
    implements _$AutoSwitchSettingsDtoCopyWith<$Res> {
  __$AutoSwitchSettingsDtoCopyWithImpl(this._self, this._then);

  final _AutoSwitchSettingsDto _self;
  final $Res Function(_AutoSwitchSettingsDto) _then;

/// Create a copy of AutoSwitchSettingsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? strategy = null,Object? scope = null,Object? failureThreshold = null,Object? fastestMarginMs = null,Object? cooldownSeconds = null,Object? probeIntervalSeconds = null,Object? slowRequestTimeoutSeconds = null,Object? slowRequestSwitchThreshold = null,}) {
  return _then(_AutoSwitchSettingsDto(
strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,failureThreshold: null == failureThreshold ? _self.failureThreshold : failureThreshold // ignore: cast_nullable_to_non_nullable
as int,fastestMarginMs: null == fastestMarginMs ? _self.fastestMarginMs : fastestMarginMs // ignore: cast_nullable_to_non_nullable
as int,cooldownSeconds: null == cooldownSeconds ? _self.cooldownSeconds : cooldownSeconds // ignore: cast_nullable_to_non_nullable
as int,probeIntervalSeconds: null == probeIntervalSeconds ? _self.probeIntervalSeconds : probeIntervalSeconds // ignore: cast_nullable_to_non_nullable
as int,slowRequestTimeoutSeconds: null == slowRequestTimeoutSeconds ? _self.slowRequestTimeoutSeconds : slowRequestTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,slowRequestSwitchThreshold: null == slowRequestSwitchThreshold ? _self.slowRequestSwitchThreshold : slowRequestSwitchThreshold // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
