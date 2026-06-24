// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mcp_server_info_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$McpServerInfoDto {

 String get id; String get name; String get description; String get url; String get status; String get statusDetail; int get toolCount; bool get registeredInCodex;
/// Create a copy of McpServerInfoDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$McpServerInfoDtoCopyWith<McpServerInfoDto> get copyWith => _$McpServerInfoDtoCopyWithImpl<McpServerInfoDto>(this as McpServerInfoDto, _$identity);

  /// Serializes this McpServerInfoDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is McpServerInfoDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusDetail, statusDetail) || other.statusDetail == statusDetail)&&(identical(other.toolCount, toolCount) || other.toolCount == toolCount)&&(identical(other.registeredInCodex, registeredInCodex) || other.registeredInCodex == registeredInCodex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,url,status,statusDetail,toolCount,registeredInCodex);

@override
String toString() {
  return 'McpServerInfoDto(id: $id, name: $name, description: $description, url: $url, status: $status, statusDetail: $statusDetail, toolCount: $toolCount, registeredInCodex: $registeredInCodex)';
}


}

/// @nodoc
abstract mixin class $McpServerInfoDtoCopyWith<$Res>  {
  factory $McpServerInfoDtoCopyWith(McpServerInfoDto value, $Res Function(McpServerInfoDto) _then) = _$McpServerInfoDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String url, String status, String statusDetail, int toolCount, bool registeredInCodex
});




}
/// @nodoc
class _$McpServerInfoDtoCopyWithImpl<$Res>
    implements $McpServerInfoDtoCopyWith<$Res> {
  _$McpServerInfoDtoCopyWithImpl(this._self, this._then);

  final McpServerInfoDto _self;
  final $Res Function(McpServerInfoDto) _then;

/// Create a copy of McpServerInfoDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? url = null,Object? status = null,Object? statusDetail = null,Object? toolCount = null,Object? registeredInCodex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusDetail: null == statusDetail ? _self.statusDetail : statusDetail // ignore: cast_nullable_to_non_nullable
as String,toolCount: null == toolCount ? _self.toolCount : toolCount // ignore: cast_nullable_to_non_nullable
as int,registeredInCodex: null == registeredInCodex ? _self.registeredInCodex : registeredInCodex // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [McpServerInfoDto].
extension McpServerInfoDtoPatterns on McpServerInfoDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _McpServerInfoDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _McpServerInfoDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _McpServerInfoDto value)  $default,){
final _that = this;
switch (_that) {
case _McpServerInfoDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _McpServerInfoDto value)?  $default,){
final _that = this;
switch (_that) {
case _McpServerInfoDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String url,  String status,  String statusDetail,  int toolCount,  bool registeredInCodex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _McpServerInfoDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.url,_that.status,_that.statusDetail,_that.toolCount,_that.registeredInCodex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String url,  String status,  String statusDetail,  int toolCount,  bool registeredInCodex)  $default,) {final _that = this;
switch (_that) {
case _McpServerInfoDto():
return $default(_that.id,_that.name,_that.description,_that.url,_that.status,_that.statusDetail,_that.toolCount,_that.registeredInCodex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String url,  String status,  String statusDetail,  int toolCount,  bool registeredInCodex)?  $default,) {final _that = this;
switch (_that) {
case _McpServerInfoDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.url,_that.status,_that.statusDetail,_that.toolCount,_that.registeredInCodex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _McpServerInfoDto extends McpServerInfoDto {
  const _McpServerInfoDto({this.id = '', this.name = '', this.description = '', this.url = '', this.status = 'stopped', this.statusDetail = '', this.toolCount = 0, this.registeredInCodex = false}): super._();
  factory _McpServerInfoDto.fromJson(Map<String, dynamic> json) => _$McpServerInfoDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  String url;
@override@JsonKey() final  String status;
@override@JsonKey() final  String statusDetail;
@override@JsonKey() final  int toolCount;
@override@JsonKey() final  bool registeredInCodex;

/// Create a copy of McpServerInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$McpServerInfoDtoCopyWith<_McpServerInfoDto> get copyWith => __$McpServerInfoDtoCopyWithImpl<_McpServerInfoDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$McpServerInfoDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _McpServerInfoDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusDetail, statusDetail) || other.statusDetail == statusDetail)&&(identical(other.toolCount, toolCount) || other.toolCount == toolCount)&&(identical(other.registeredInCodex, registeredInCodex) || other.registeredInCodex == registeredInCodex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,url,status,statusDetail,toolCount,registeredInCodex);

@override
String toString() {
  return 'McpServerInfoDto(id: $id, name: $name, description: $description, url: $url, status: $status, statusDetail: $statusDetail, toolCount: $toolCount, registeredInCodex: $registeredInCodex)';
}


}

/// @nodoc
abstract mixin class _$McpServerInfoDtoCopyWith<$Res> implements $McpServerInfoDtoCopyWith<$Res> {
  factory _$McpServerInfoDtoCopyWith(_McpServerInfoDto value, $Res Function(_McpServerInfoDto) _then) = __$McpServerInfoDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String url, String status, String statusDetail, int toolCount, bool registeredInCodex
});




}
/// @nodoc
class __$McpServerInfoDtoCopyWithImpl<$Res>
    implements _$McpServerInfoDtoCopyWith<$Res> {
  __$McpServerInfoDtoCopyWithImpl(this._self, this._then);

  final _McpServerInfoDto _self;
  final $Res Function(_McpServerInfoDto) _then;

/// Create a copy of McpServerInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? url = null,Object? status = null,Object? statusDetail = null,Object? toolCount = null,Object? registeredInCodex = null,}) {
  return _then(_McpServerInfoDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusDetail: null == statusDetail ? _self.statusDetail : statusDetail // ignore: cast_nullable_to_non_nullable
as String,toolCount: null == toolCount ? _self.toolCount : toolCount // ignore: cast_nullable_to_non_nullable
as int,registeredInCodex: null == registeredInCodex ? _self.registeredInCodex : registeredInCodex // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
