// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApiProvider {

 String get id; String get name;/// 例：https://api.muxueai.pro/v1
 String get baseUrl; String get apiKey;
/// Create a copy of ApiProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiProviderCopyWith<ApiProvider> get copyWith => _$ApiProviderCopyWithImpl<ApiProvider>(this as ApiProvider, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiProvider&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,baseUrl,apiKey);

@override
String toString() {
  return 'ApiProvider(id: $id, name: $name, baseUrl: $baseUrl, apiKey: $apiKey)';
}


}

/// @nodoc
abstract mixin class $ApiProviderCopyWith<$Res>  {
  factory $ApiProviderCopyWith(ApiProvider value, $Res Function(ApiProvider) _then) = _$ApiProviderCopyWithImpl;
@useResult
$Res call({
 String id, String name, String baseUrl, String apiKey
});




}
/// @nodoc
class _$ApiProviderCopyWithImpl<$Res>
    implements $ApiProviderCopyWith<$Res> {
  _$ApiProviderCopyWithImpl(this._self, this._then);

  final ApiProvider _self;
  final $Res Function(ApiProvider) _then;

/// Create a copy of ApiProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? apiKey = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiProvider].
extension ApiProviderPatterns on ApiProvider {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiProvider() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiProvider value)  $default,){
final _that = this;
switch (_that) {
case _ApiProvider():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiProvider value)?  $default,){
final _that = this;
switch (_that) {
case _ApiProvider() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String apiKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiProvider() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String apiKey)  $default,) {final _that = this;
switch (_that) {
case _ApiProvider():
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String baseUrl,  String apiKey)?  $default,) {final _that = this;
switch (_that) {
case _ApiProvider() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey);case _:
  return null;

}
}

}

/// @nodoc


class _ApiProvider extends ApiProvider {
  const _ApiProvider({required this.id, required this.name, required this.baseUrl, required this.apiKey}): super._();
  

@override final  String id;
@override final  String name;
/// 例：https://api.muxueai.pro/v1
@override final  String baseUrl;
@override final  String apiKey;

/// Create a copy of ApiProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiProviderCopyWith<_ApiProvider> get copyWith => __$ApiProviderCopyWithImpl<_ApiProvider>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiProvider&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,baseUrl,apiKey);

@override
String toString() {
  return 'ApiProvider(id: $id, name: $name, baseUrl: $baseUrl, apiKey: $apiKey)';
}


}

/// @nodoc
abstract mixin class _$ApiProviderCopyWith<$Res> implements $ApiProviderCopyWith<$Res> {
  factory _$ApiProviderCopyWith(_ApiProvider value, $Res Function(_ApiProvider) _then) = __$ApiProviderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String baseUrl, String apiKey
});




}
/// @nodoc
class __$ApiProviderCopyWithImpl<$Res>
    implements _$ApiProviderCopyWith<$Res> {
  __$ApiProviderCopyWithImpl(this._self, this._then);

  final _ApiProvider _self;
  final $Res Function(_ApiProvider) _then;

/// Create a copy of ApiProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? apiKey = null,}) {
  return _then(_ApiProvider(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
