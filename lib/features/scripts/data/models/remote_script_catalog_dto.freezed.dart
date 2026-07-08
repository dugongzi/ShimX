// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_script_catalog_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RemoteScriptCatalogDto {

 int get version; String get updatedAt; List<RemoteScriptDto> get items;
/// Create a copy of RemoteScriptCatalogDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteScriptCatalogDtoCopyWith<RemoteScriptCatalogDto> get copyWith => _$RemoteScriptCatalogDtoCopyWithImpl<RemoteScriptCatalogDto>(this as RemoteScriptCatalogDto, _$identity);

  /// Serializes this RemoteScriptCatalogDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteScriptCatalogDto&&(identical(other.version, version) || other.version == version)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,updatedAt,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'RemoteScriptCatalogDto(version: $version, updatedAt: $updatedAt, items: $items)';
}


}

/// @nodoc
abstract mixin class $RemoteScriptCatalogDtoCopyWith<$Res>  {
  factory $RemoteScriptCatalogDtoCopyWith(RemoteScriptCatalogDto value, $Res Function(RemoteScriptCatalogDto) _then) = _$RemoteScriptCatalogDtoCopyWithImpl;
@useResult
$Res call({
 int version, String updatedAt, List<RemoteScriptDto> items
});




}
/// @nodoc
class _$RemoteScriptCatalogDtoCopyWithImpl<$Res>
    implements $RemoteScriptCatalogDtoCopyWith<$Res> {
  _$RemoteScriptCatalogDtoCopyWithImpl(this._self, this._then);

  final RemoteScriptCatalogDto _self;
  final $Res Function(RemoteScriptCatalogDto) _then;

/// Create a copy of RemoteScriptCatalogDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? updatedAt = null,Object? items = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RemoteScriptDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteScriptCatalogDto].
extension RemoteScriptCatalogDtoPatterns on RemoteScriptCatalogDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteScriptCatalogDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteScriptCatalogDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteScriptCatalogDto value)  $default,){
final _that = this;
switch (_that) {
case _RemoteScriptCatalogDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteScriptCatalogDto value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteScriptCatalogDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  String updatedAt,  List<RemoteScriptDto> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteScriptCatalogDto() when $default != null:
return $default(_that.version,_that.updatedAt,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  String updatedAt,  List<RemoteScriptDto> items)  $default,) {final _that = this;
switch (_that) {
case _RemoteScriptCatalogDto():
return $default(_that.version,_that.updatedAt,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  String updatedAt,  List<RemoteScriptDto> items)?  $default,) {final _that = this;
switch (_that) {
case _RemoteScriptCatalogDto() when $default != null:
return $default(_that.version,_that.updatedAt,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteScriptCatalogDto extends RemoteScriptCatalogDto {
  const _RemoteScriptCatalogDto({this.version = 1, this.updatedAt = '', final  List<RemoteScriptDto> items = const []}): _items = items,super._();
  factory _RemoteScriptCatalogDto.fromJson(Map<String, dynamic> json) => _$RemoteScriptCatalogDtoFromJson(json);

@override@JsonKey() final  int version;
@override@JsonKey() final  String updatedAt;
 final  List<RemoteScriptDto> _items;
@override@JsonKey() List<RemoteScriptDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of RemoteScriptCatalogDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteScriptCatalogDtoCopyWith<_RemoteScriptCatalogDto> get copyWith => __$RemoteScriptCatalogDtoCopyWithImpl<_RemoteScriptCatalogDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteScriptCatalogDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteScriptCatalogDto&&(identical(other.version, version) || other.version == version)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,updatedAt,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'RemoteScriptCatalogDto(version: $version, updatedAt: $updatedAt, items: $items)';
}


}

/// @nodoc
abstract mixin class _$RemoteScriptCatalogDtoCopyWith<$Res> implements $RemoteScriptCatalogDtoCopyWith<$Res> {
  factory _$RemoteScriptCatalogDtoCopyWith(_RemoteScriptCatalogDto value, $Res Function(_RemoteScriptCatalogDto) _then) = __$RemoteScriptCatalogDtoCopyWithImpl;
@override @useResult
$Res call({
 int version, String updatedAt, List<RemoteScriptDto> items
});




}
/// @nodoc
class __$RemoteScriptCatalogDtoCopyWithImpl<$Res>
    implements _$RemoteScriptCatalogDtoCopyWith<$Res> {
  __$RemoteScriptCatalogDtoCopyWithImpl(this._self, this._then);

  final _RemoteScriptCatalogDto _self;
  final $Res Function(_RemoteScriptCatalogDto) _then;

/// Create a copy of RemoteScriptCatalogDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? updatedAt = null,Object? items = null,}) {
  return _then(_RemoteScriptCatalogDto(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RemoteScriptDto>,
  ));
}


}

// dart format on
