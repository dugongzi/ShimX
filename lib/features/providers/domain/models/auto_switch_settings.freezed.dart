// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_switch_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AutoSwitchSettings {

 String get strategy; String get scope;/// failover: 连续失败几次后触发切换
 int get failureThreshold;/// fastest: 候选比当前快多少 ms 才切，防止抖动
 int get fastestMarginMs;/// 切换后冷却秒数，防止反复横跳
 int get cooldownSeconds;/// 后台测速周期秒数。默认 5 分钟,避免给上游中转造成压力。
/// strategy=manual 时此值不生效(完全不跑后台周期)。
 int get probeIntervalSeconds;
/// Create a copy of AutoSwitchSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoSwitchSettingsCopyWith<AutoSwitchSettings> get copyWith => _$AutoSwitchSettingsCopyWithImpl<AutoSwitchSettings>(this as AutoSwitchSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoSwitchSettings&&(identical(other.strategy, strategy) || other.strategy == strategy)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.failureThreshold, failureThreshold) || other.failureThreshold == failureThreshold)&&(identical(other.fastestMarginMs, fastestMarginMs) || other.fastestMarginMs == fastestMarginMs)&&(identical(other.cooldownSeconds, cooldownSeconds) || other.cooldownSeconds == cooldownSeconds)&&(identical(other.probeIntervalSeconds, probeIntervalSeconds) || other.probeIntervalSeconds == probeIntervalSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,strategy,scope,failureThreshold,fastestMarginMs,cooldownSeconds,probeIntervalSeconds);

@override
String toString() {
  return 'AutoSwitchSettings(strategy: $strategy, scope: $scope, failureThreshold: $failureThreshold, fastestMarginMs: $fastestMarginMs, cooldownSeconds: $cooldownSeconds, probeIntervalSeconds: $probeIntervalSeconds)';
}


}

/// @nodoc
abstract mixin class $AutoSwitchSettingsCopyWith<$Res>  {
  factory $AutoSwitchSettingsCopyWith(AutoSwitchSettings value, $Res Function(AutoSwitchSettings) _then) = _$AutoSwitchSettingsCopyWithImpl;
@useResult
$Res call({
 String strategy, String scope, int failureThreshold, int fastestMarginMs, int cooldownSeconds, int probeIntervalSeconds
});




}
/// @nodoc
class _$AutoSwitchSettingsCopyWithImpl<$Res>
    implements $AutoSwitchSettingsCopyWith<$Res> {
  _$AutoSwitchSettingsCopyWithImpl(this._self, this._then);

  final AutoSwitchSettings _self;
  final $Res Function(AutoSwitchSettings) _then;

/// Create a copy of AutoSwitchSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? strategy = null,Object? scope = null,Object? failureThreshold = null,Object? fastestMarginMs = null,Object? cooldownSeconds = null,Object? probeIntervalSeconds = null,}) {
  return _then(_self.copyWith(
strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,failureThreshold: null == failureThreshold ? _self.failureThreshold : failureThreshold // ignore: cast_nullable_to_non_nullable
as int,fastestMarginMs: null == fastestMarginMs ? _self.fastestMarginMs : fastestMarginMs // ignore: cast_nullable_to_non_nullable
as int,cooldownSeconds: null == cooldownSeconds ? _self.cooldownSeconds : cooldownSeconds // ignore: cast_nullable_to_non_nullable
as int,probeIntervalSeconds: null == probeIntervalSeconds ? _self.probeIntervalSeconds : probeIntervalSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoSwitchSettings].
extension AutoSwitchSettingsPatterns on AutoSwitchSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutoSwitchSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutoSwitchSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutoSwitchSettings value)  $default,){
final _that = this;
switch (_that) {
case _AutoSwitchSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutoSwitchSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AutoSwitchSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String strategy,  String scope,  int failureThreshold,  int fastestMarginMs,  int cooldownSeconds,  int probeIntervalSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutoSwitchSettings() when $default != null:
return $default(_that.strategy,_that.scope,_that.failureThreshold,_that.fastestMarginMs,_that.cooldownSeconds,_that.probeIntervalSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String strategy,  String scope,  int failureThreshold,  int fastestMarginMs,  int cooldownSeconds,  int probeIntervalSeconds)  $default,) {final _that = this;
switch (_that) {
case _AutoSwitchSettings():
return $default(_that.strategy,_that.scope,_that.failureThreshold,_that.fastestMarginMs,_that.cooldownSeconds,_that.probeIntervalSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String strategy,  String scope,  int failureThreshold,  int fastestMarginMs,  int cooldownSeconds,  int probeIntervalSeconds)?  $default,) {final _that = this;
switch (_that) {
case _AutoSwitchSettings() when $default != null:
return $default(_that.strategy,_that.scope,_that.failureThreshold,_that.fastestMarginMs,_that.cooldownSeconds,_that.probeIntervalSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _AutoSwitchSettings extends AutoSwitchSettings {
  const _AutoSwitchSettings({this.strategy = 'manual', this.scope = 'same-type', this.failureThreshold = 3, this.fastestMarginMs = 200, this.cooldownSeconds = 10, this.probeIntervalSeconds = 300}): super._();
  

@override@JsonKey() final  String strategy;
@override@JsonKey() final  String scope;
/// failover: 连续失败几次后触发切换
@override@JsonKey() final  int failureThreshold;
/// fastest: 候选比当前快多少 ms 才切，防止抖动
@override@JsonKey() final  int fastestMarginMs;
/// 切换后冷却秒数，防止反复横跳
@override@JsonKey() final  int cooldownSeconds;
/// 后台测速周期秒数。默认 5 分钟,避免给上游中转造成压力。
/// strategy=manual 时此值不生效(完全不跑后台周期)。
@override@JsonKey() final  int probeIntervalSeconds;

/// Create a copy of AutoSwitchSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutoSwitchSettingsCopyWith<_AutoSwitchSettings> get copyWith => __$AutoSwitchSettingsCopyWithImpl<_AutoSwitchSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutoSwitchSettings&&(identical(other.strategy, strategy) || other.strategy == strategy)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.failureThreshold, failureThreshold) || other.failureThreshold == failureThreshold)&&(identical(other.fastestMarginMs, fastestMarginMs) || other.fastestMarginMs == fastestMarginMs)&&(identical(other.cooldownSeconds, cooldownSeconds) || other.cooldownSeconds == cooldownSeconds)&&(identical(other.probeIntervalSeconds, probeIntervalSeconds) || other.probeIntervalSeconds == probeIntervalSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,strategy,scope,failureThreshold,fastestMarginMs,cooldownSeconds,probeIntervalSeconds);

@override
String toString() {
  return 'AutoSwitchSettings(strategy: $strategy, scope: $scope, failureThreshold: $failureThreshold, fastestMarginMs: $fastestMarginMs, cooldownSeconds: $cooldownSeconds, probeIntervalSeconds: $probeIntervalSeconds)';
}


}

/// @nodoc
abstract mixin class _$AutoSwitchSettingsCopyWith<$Res> implements $AutoSwitchSettingsCopyWith<$Res> {
  factory _$AutoSwitchSettingsCopyWith(_AutoSwitchSettings value, $Res Function(_AutoSwitchSettings) _then) = __$AutoSwitchSettingsCopyWithImpl;
@override @useResult
$Res call({
 String strategy, String scope, int failureThreshold, int fastestMarginMs, int cooldownSeconds, int probeIntervalSeconds
});




}
/// @nodoc
class __$AutoSwitchSettingsCopyWithImpl<$Res>
    implements _$AutoSwitchSettingsCopyWith<$Res> {
  __$AutoSwitchSettingsCopyWithImpl(this._self, this._then);

  final _AutoSwitchSettings _self;
  final $Res Function(_AutoSwitchSettings) _then;

/// Create a copy of AutoSwitchSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? strategy = null,Object? scope = null,Object? failureThreshold = null,Object? fastestMarginMs = null,Object? cooldownSeconds = null,Object? probeIntervalSeconds = null,}) {
  return _then(_AutoSwitchSettings(
strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,failureThreshold: null == failureThreshold ? _self.failureThreshold : failureThreshold // ignore: cast_nullable_to_non_nullable
as int,fastestMarginMs: null == fastestMarginMs ? _self.fastestMarginMs : fastestMarginMs // ignore: cast_nullable_to_non_nullable
as int,cooldownSeconds: null == cooldownSeconds ? _self.cooldownSeconds : cooldownSeconds // ignore: cast_nullable_to_non_nullable
as int,probeIntervalSeconds: null == probeIntervalSeconds ? _self.probeIntervalSeconds : probeIntervalSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
