// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_provider_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiProviderDto {

 String get id; String get name; String get baseUrl; String get apiKey; List<String> get models; String? get selectedModel; String get wireApi;
/// Create a copy of ApiProviderDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiProviderDtoCopyWith<ApiProviderDto> get copyWith => _$ApiProviderDtoCopyWithImpl<ApiProviderDto>(this as ApiProviderDto, _$identity);

  /// Serializes this ApiProviderDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiProviderDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&const DeepCollectionEquality().equals(other.models, models)&&(identical(other.selectedModel, selectedModel) || other.selectedModel == selectedModel)&&(identical(other.wireApi, wireApi) || other.wireApi == wireApi));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseUrl,apiKey,const DeepCollectionEquality().hash(models),selectedModel,wireApi);

@override
String toString() {
  return 'ApiProviderDto(id: $id, name: $name, baseUrl: $baseUrl, apiKey: $apiKey, models: $models, selectedModel: $selectedModel, wireApi: $wireApi)';
}


}

/// @nodoc
abstract mixin class $ApiProviderDtoCopyWith<$Res>  {
  factory $ApiProviderDtoCopyWith(ApiProviderDto value, $Res Function(ApiProviderDto) _then) = _$ApiProviderDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String baseUrl, String apiKey, List<String> models, String? selectedModel, String wireApi
});




}
/// @nodoc
class _$ApiProviderDtoCopyWithImpl<$Res>
    implements $ApiProviderDtoCopyWith<$Res> {
  _$ApiProviderDtoCopyWithImpl(this._self, this._then);

  final ApiProviderDto _self;
  final $Res Function(ApiProviderDto) _then;

/// Create a copy of ApiProviderDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? apiKey = null,Object? models = null,Object? selectedModel = freezed,Object? wireApi = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<String>,selectedModel: freezed == selectedModel ? _self.selectedModel : selectedModel // ignore: cast_nullable_to_non_nullable
as String?,wireApi: null == wireApi ? _self.wireApi : wireApi // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiProviderDto].
extension ApiProviderDtoPatterns on ApiProviderDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiProviderDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiProviderDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiProviderDto value)  $default,){
final _that = this;
switch (_that) {
case _ApiProviderDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiProviderDto value)?  $default,){
final _that = this;
switch (_that) {
case _ApiProviderDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String apiKey,  List<String> models,  String? selectedModel,  String wireApi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiProviderDto() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey,_that.models,_that.selectedModel,_that.wireApi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String apiKey,  List<String> models,  String? selectedModel,  String wireApi)  $default,) {final _that = this;
switch (_that) {
case _ApiProviderDto():
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey,_that.models,_that.selectedModel,_that.wireApi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String baseUrl,  String apiKey,  List<String> models,  String? selectedModel,  String wireApi)?  $default,) {final _that = this;
switch (_that) {
case _ApiProviderDto() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey,_that.models,_that.selectedModel,_that.wireApi);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiProviderDto extends ApiProviderDto {
  const _ApiProviderDto({this.id = '', this.name = '', this.baseUrl = '', this.apiKey = '', final  List<String> models = const [], this.selectedModel, this.wireApi = 'responses'}): _models = models,super._();
  factory _ApiProviderDto.fromJson(Map<String, dynamic> json) => _$ApiProviderDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String baseUrl;
@override@JsonKey() final  String apiKey;
 final  List<String> _models;
@override@JsonKey() List<String> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}

@override final  String? selectedModel;
@override@JsonKey() final  String wireApi;

/// Create a copy of ApiProviderDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiProviderDtoCopyWith<_ApiProviderDto> get copyWith => __$ApiProviderDtoCopyWithImpl<_ApiProviderDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiProviderDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiProviderDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&const DeepCollectionEquality().equals(other._models, _models)&&(identical(other.selectedModel, selectedModel) || other.selectedModel == selectedModel)&&(identical(other.wireApi, wireApi) || other.wireApi == wireApi));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseUrl,apiKey,const DeepCollectionEquality().hash(_models),selectedModel,wireApi);

@override
String toString() {
  return 'ApiProviderDto(id: $id, name: $name, baseUrl: $baseUrl, apiKey: $apiKey, models: $models, selectedModel: $selectedModel, wireApi: $wireApi)';
}


}

/// @nodoc
abstract mixin class _$ApiProviderDtoCopyWith<$Res> implements $ApiProviderDtoCopyWith<$Res> {
  factory _$ApiProviderDtoCopyWith(_ApiProviderDto value, $Res Function(_ApiProviderDto) _then) = __$ApiProviderDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String baseUrl, String apiKey, List<String> models, String? selectedModel, String wireApi
});




}
/// @nodoc
class __$ApiProviderDtoCopyWithImpl<$Res>
    implements _$ApiProviderDtoCopyWith<$Res> {
  __$ApiProviderDtoCopyWithImpl(this._self, this._then);

  final _ApiProviderDto _self;
  final $Res Function(_ApiProviderDto) _then;

/// Create a copy of ApiProviderDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? apiKey = null,Object? models = null,Object? selectedModel = freezed,Object? wireApi = null,}) {
  return _then(_ApiProviderDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<String>,selectedModel: freezed == selectedModel ? _self.selectedModel : selectedModel // ignore: cast_nullable_to_non_nullable
as String?,wireApi: null == wireApi ? _self.wireApi : wireApi // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
