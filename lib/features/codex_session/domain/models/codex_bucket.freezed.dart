// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_bucket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodexBucket {

 String get bucket; int get sessionCount; int get lastActiveMs;
/// Create a copy of CodexBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexBucketCopyWith<CodexBucket> get copyWith => _$CodexBucketCopyWithImpl<CodexBucket>(this as CodexBucket, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexBucket&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.lastActiveMs, lastActiveMs) || other.lastActiveMs == lastActiveMs));
}


@override
int get hashCode => Object.hash(runtimeType,bucket,sessionCount,lastActiveMs);

@override
String toString() {
  return 'CodexBucket(bucket: $bucket, sessionCount: $sessionCount, lastActiveMs: $lastActiveMs)';
}


}

/// @nodoc
abstract mixin class $CodexBucketCopyWith<$Res>  {
  factory $CodexBucketCopyWith(CodexBucket value, $Res Function(CodexBucket) _then) = _$CodexBucketCopyWithImpl;
@useResult
$Res call({
 String bucket, int sessionCount, int lastActiveMs
});




}
/// @nodoc
class _$CodexBucketCopyWithImpl<$Res>
    implements $CodexBucketCopyWith<$Res> {
  _$CodexBucketCopyWithImpl(this._self, this._then);

  final CodexBucket _self;
  final $Res Function(CodexBucket) _then;

/// Create a copy of CodexBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bucket = null,Object? sessionCount = null,Object? lastActiveMs = null,}) {
  return _then(_self.copyWith(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,lastActiveMs: null == lastActiveMs ? _self.lastActiveMs : lastActiveMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexBucket].
extension CodexBucketPatterns on CodexBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexBucket value)  $default,){
final _that = this;
switch (_that) {
case _CodexBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexBucket value)?  $default,){
final _that = this;
switch (_that) {
case _CodexBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bucket,  int sessionCount,  int lastActiveMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexBucket() when $default != null:
return $default(_that.bucket,_that.sessionCount,_that.lastActiveMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bucket,  int sessionCount,  int lastActiveMs)  $default,) {final _that = this;
switch (_that) {
case _CodexBucket():
return $default(_that.bucket,_that.sessionCount,_that.lastActiveMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bucket,  int sessionCount,  int lastActiveMs)?  $default,) {final _that = this;
switch (_that) {
case _CodexBucket() when $default != null:
return $default(_that.bucket,_that.sessionCount,_that.lastActiveMs);case _:
  return null;

}
}

}

/// @nodoc


class _CodexBucket extends CodexBucket {
  const _CodexBucket({required this.bucket, required this.sessionCount, required this.lastActiveMs}): super._();
  

@override final  String bucket;
@override final  int sessionCount;
@override final  int lastActiveMs;

/// Create a copy of CodexBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexBucketCopyWith<_CodexBucket> get copyWith => __$CodexBucketCopyWithImpl<_CodexBucket>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexBucket&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.lastActiveMs, lastActiveMs) || other.lastActiveMs == lastActiveMs));
}


@override
int get hashCode => Object.hash(runtimeType,bucket,sessionCount,lastActiveMs);

@override
String toString() {
  return 'CodexBucket(bucket: $bucket, sessionCount: $sessionCount, lastActiveMs: $lastActiveMs)';
}


}

/// @nodoc
abstract mixin class _$CodexBucketCopyWith<$Res> implements $CodexBucketCopyWith<$Res> {
  factory _$CodexBucketCopyWith(_CodexBucket value, $Res Function(_CodexBucket) _then) = __$CodexBucketCopyWithImpl;
@override @useResult
$Res call({
 String bucket, int sessionCount, int lastActiveMs
});




}
/// @nodoc
class __$CodexBucketCopyWithImpl<$Res>
    implements _$CodexBucketCopyWith<$Res> {
  __$CodexBucketCopyWithImpl(this._self, this._then);

  final _CodexBucket _self;
  final $Res Function(_CodexBucket) _then;

/// Create a copy of CodexBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bucket = null,Object? sessionCount = null,Object? lastActiveMs = null,}) {
  return _then(_CodexBucket(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,lastActiveMs: null == lastActiveMs ? _self.lastActiveMs : lastActiveMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
