// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'claude_bridge_binding_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClaudeBridgeBindingDto {

 String get codexThreadId; String get sessionId; String get jsonlPath; String? get title;
/// Create a copy of ClaudeBridgeBindingDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeBridgeBindingDtoCopyWith<ClaudeBridgeBindingDto> get copyWith => _$ClaudeBridgeBindingDtoCopyWithImpl<ClaudeBridgeBindingDto>(this as ClaudeBridgeBindingDto, _$identity);

  /// Serializes this ClaudeBridgeBindingDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeBridgeBindingDto&&(identical(other.codexThreadId, codexThreadId) || other.codexThreadId == codexThreadId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.jsonlPath, jsonlPath) || other.jsonlPath == jsonlPath)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,codexThreadId,sessionId,jsonlPath,title);

@override
String toString() {
  return 'ClaudeBridgeBindingDto(codexThreadId: $codexThreadId, sessionId: $sessionId, jsonlPath: $jsonlPath, title: $title)';
}


}

/// @nodoc
abstract mixin class $ClaudeBridgeBindingDtoCopyWith<$Res>  {
  factory $ClaudeBridgeBindingDtoCopyWith(ClaudeBridgeBindingDto value, $Res Function(ClaudeBridgeBindingDto) _then) = _$ClaudeBridgeBindingDtoCopyWithImpl;
@useResult
$Res call({
 String codexThreadId, String sessionId, String jsonlPath, String? title
});




}
/// @nodoc
class _$ClaudeBridgeBindingDtoCopyWithImpl<$Res>
    implements $ClaudeBridgeBindingDtoCopyWith<$Res> {
  _$ClaudeBridgeBindingDtoCopyWithImpl(this._self, this._then);

  final ClaudeBridgeBindingDto _self;
  final $Res Function(ClaudeBridgeBindingDto) _then;

/// Create a copy of ClaudeBridgeBindingDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? codexThreadId = null,Object? sessionId = null,Object? jsonlPath = null,Object? title = freezed,}) {
  return _then(_self.copyWith(
codexThreadId: null == codexThreadId ? _self.codexThreadId : codexThreadId // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,jsonlPath: null == jsonlPath ? _self.jsonlPath : jsonlPath // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClaudeBridgeBindingDto].
extension ClaudeBridgeBindingDtoPatterns on ClaudeBridgeBindingDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClaudeBridgeBindingDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClaudeBridgeBindingDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClaudeBridgeBindingDto value)  $default,){
final _that = this;
switch (_that) {
case _ClaudeBridgeBindingDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClaudeBridgeBindingDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClaudeBridgeBindingDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String codexThreadId,  String sessionId,  String jsonlPath,  String? title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClaudeBridgeBindingDto() when $default != null:
return $default(_that.codexThreadId,_that.sessionId,_that.jsonlPath,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String codexThreadId,  String sessionId,  String jsonlPath,  String? title)  $default,) {final _that = this;
switch (_that) {
case _ClaudeBridgeBindingDto():
return $default(_that.codexThreadId,_that.sessionId,_that.jsonlPath,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String codexThreadId,  String sessionId,  String jsonlPath,  String? title)?  $default,) {final _that = this;
switch (_that) {
case _ClaudeBridgeBindingDto() when $default != null:
return $default(_that.codexThreadId,_that.sessionId,_that.jsonlPath,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClaudeBridgeBindingDto extends ClaudeBridgeBindingDto {
  const _ClaudeBridgeBindingDto({required this.codexThreadId, this.sessionId = '', this.jsonlPath = '', this.title}): super._();
  factory _ClaudeBridgeBindingDto.fromJson(Map<String, dynamic> json) => _$ClaudeBridgeBindingDtoFromJson(json);

@override final  String codexThreadId;
@override@JsonKey() final  String sessionId;
@override@JsonKey() final  String jsonlPath;
@override final  String? title;

/// Create a copy of ClaudeBridgeBindingDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudeBridgeBindingDtoCopyWith<_ClaudeBridgeBindingDto> get copyWith => __$ClaudeBridgeBindingDtoCopyWithImpl<_ClaudeBridgeBindingDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClaudeBridgeBindingDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudeBridgeBindingDto&&(identical(other.codexThreadId, codexThreadId) || other.codexThreadId == codexThreadId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.jsonlPath, jsonlPath) || other.jsonlPath == jsonlPath)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,codexThreadId,sessionId,jsonlPath,title);

@override
String toString() {
  return 'ClaudeBridgeBindingDto(codexThreadId: $codexThreadId, sessionId: $sessionId, jsonlPath: $jsonlPath, title: $title)';
}


}

/// @nodoc
abstract mixin class _$ClaudeBridgeBindingDtoCopyWith<$Res> implements $ClaudeBridgeBindingDtoCopyWith<$Res> {
  factory _$ClaudeBridgeBindingDtoCopyWith(_ClaudeBridgeBindingDto value, $Res Function(_ClaudeBridgeBindingDto) _then) = __$ClaudeBridgeBindingDtoCopyWithImpl;
@override @useResult
$Res call({
 String codexThreadId, String sessionId, String jsonlPath, String? title
});




}
/// @nodoc
class __$ClaudeBridgeBindingDtoCopyWithImpl<$Res>
    implements _$ClaudeBridgeBindingDtoCopyWith<$Res> {
  __$ClaudeBridgeBindingDtoCopyWithImpl(this._self, this._then);

  final _ClaudeBridgeBindingDto _self;
  final $Res Function(_ClaudeBridgeBindingDto) _then;

/// Create a copy of ClaudeBridgeBindingDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? codexThreadId = null,Object? sessionId = null,Object? jsonlPath = null,Object? title = freezed,}) {
  return _then(_ClaudeBridgeBindingDto(
codexThreadId: null == codexThreadId ? _self.codexThreadId : codexThreadId // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,jsonlPath: null == jsonlPath ? _self.jsonlPath : jsonlPath // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
