// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_health.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProviderHealth {

 String get providerId; String get status;/// 测速延迟毫秒。null 表示没拿到有效延迟（测速失败 / 未测过）。
 int? get latencyMs;/// 上次测速时间（ISO 8601 UTC）。null 表示从未测过。
 String? get measuredAt;/// 连续失败次数，用于触发故障转移阈值判定。
 int get failureStreak;
/// Create a copy of ProviderHealth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderHealthCopyWith<ProviderHealth> get copyWith => _$ProviderHealthCopyWithImpl<ProviderHealth>(this as ProviderHealth, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderHealth&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.failureStreak, failureStreak) || other.failureStreak == failureStreak));
}


@override
int get hashCode => Object.hash(runtimeType,providerId,status,latencyMs,measuredAt,failureStreak);

@override
String toString() {
  return 'ProviderHealth(providerId: $providerId, status: $status, latencyMs: $latencyMs, measuredAt: $measuredAt, failureStreak: $failureStreak)';
}


}

/// @nodoc
abstract mixin class $ProviderHealthCopyWith<$Res>  {
  factory $ProviderHealthCopyWith(ProviderHealth value, $Res Function(ProviderHealth) _then) = _$ProviderHealthCopyWithImpl;
@useResult
$Res call({
 String providerId, String status, int? latencyMs, String? measuredAt, int failureStreak
});




}
/// @nodoc
class _$ProviderHealthCopyWithImpl<$Res>
    implements $ProviderHealthCopyWith<$Res> {
  _$ProviderHealthCopyWithImpl(this._self, this._then);

  final ProviderHealth _self;
  final $Res Function(ProviderHealth) _then;

/// Create a copy of ProviderHealth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providerId = null,Object? status = null,Object? latencyMs = freezed,Object? measuredAt = freezed,Object? failureStreak = null,}) {
  return _then(_self.copyWith(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int?,measuredAt: freezed == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as String?,failureStreak: null == failureStreak ? _self.failureStreak : failureStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderHealth].
extension ProviderHealthPatterns on ProviderHealth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderHealth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderHealth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderHealth value)  $default,){
final _that = this;
switch (_that) {
case _ProviderHealth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderHealth value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderHealth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String providerId,  String status,  int? latencyMs,  String? measuredAt,  int failureStreak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderHealth() when $default != null:
return $default(_that.providerId,_that.status,_that.latencyMs,_that.measuredAt,_that.failureStreak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String providerId,  String status,  int? latencyMs,  String? measuredAt,  int failureStreak)  $default,) {final _that = this;
switch (_that) {
case _ProviderHealth():
return $default(_that.providerId,_that.status,_that.latencyMs,_that.measuredAt,_that.failureStreak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String providerId,  String status,  int? latencyMs,  String? measuredAt,  int failureStreak)?  $default,) {final _that = this;
switch (_that) {
case _ProviderHealth() when $default != null:
return $default(_that.providerId,_that.status,_that.latencyMs,_that.measuredAt,_that.failureStreak);case _:
  return null;

}
}

}

/// @nodoc


class _ProviderHealth extends ProviderHealth {
  const _ProviderHealth({required this.providerId, required this.status, required this.latencyMs, required this.measuredAt, required this.failureStreak}): super._();
  

@override final  String providerId;
@override final  String status;
/// 测速延迟毫秒。null 表示没拿到有效延迟（测速失败 / 未测过）。
@override final  int? latencyMs;
/// 上次测速时间（ISO 8601 UTC）。null 表示从未测过。
@override final  String? measuredAt;
/// 连续失败次数，用于触发故障转移阈值判定。
@override final  int failureStreak;

/// Create a copy of ProviderHealth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderHealthCopyWith<_ProviderHealth> get copyWith => __$ProviderHealthCopyWithImpl<_ProviderHealth>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderHealth&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.failureStreak, failureStreak) || other.failureStreak == failureStreak));
}


@override
int get hashCode => Object.hash(runtimeType,providerId,status,latencyMs,measuredAt,failureStreak);

@override
String toString() {
  return 'ProviderHealth(providerId: $providerId, status: $status, latencyMs: $latencyMs, measuredAt: $measuredAt, failureStreak: $failureStreak)';
}


}

/// @nodoc
abstract mixin class _$ProviderHealthCopyWith<$Res> implements $ProviderHealthCopyWith<$Res> {
  factory _$ProviderHealthCopyWith(_ProviderHealth value, $Res Function(_ProviderHealth) _then) = __$ProviderHealthCopyWithImpl;
@override @useResult
$Res call({
 String providerId, String status, int? latencyMs, String? measuredAt, int failureStreak
});




}
/// @nodoc
class __$ProviderHealthCopyWithImpl<$Res>
    implements _$ProviderHealthCopyWith<$Res> {
  __$ProviderHealthCopyWithImpl(this._self, this._then);

  final _ProviderHealth _self;
  final $Res Function(_ProviderHealth) _then;

/// Create a copy of ProviderHealth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? status = null,Object? latencyMs = freezed,Object? measuredAt = freezed,Object? failureStreak = null,}) {
  return _then(_ProviderHealth(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int?,measuredAt: freezed == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as String?,failureStreak: null == failureStreak ? _self.failureStreak : failureStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
