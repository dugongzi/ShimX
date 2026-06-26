// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_mcp_config_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CodexMcpConfigDto {

 String get id; String get kind; String get bodyText; bool get enabled; bool get managedByShim; bool get readOnly; String get name; String get description;
/// Create a copy of CodexMcpConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexMcpConfigDtoCopyWith<CodexMcpConfigDto> get copyWith => _$CodexMcpConfigDtoCopyWithImpl<CodexMcpConfigDto>(this as CodexMcpConfigDto, _$identity);

  /// Serializes this CodexMcpConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexMcpConfigDto&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.managedByShim, managedByShim) || other.managedByShim == managedByShim)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,bodyText,enabled,managedByShim,readOnly,name,description);

@override
String toString() {
  return 'CodexMcpConfigDto(id: $id, kind: $kind, bodyText: $bodyText, enabled: $enabled, managedByShim: $managedByShim, readOnly: $readOnly, name: $name, description: $description)';
}


}

/// @nodoc
abstract mixin class $CodexMcpConfigDtoCopyWith<$Res>  {
  factory $CodexMcpConfigDtoCopyWith(CodexMcpConfigDto value, $Res Function(CodexMcpConfigDto) _then) = _$CodexMcpConfigDtoCopyWithImpl;
@useResult
$Res call({
 String id, String kind, String bodyText, bool enabled, bool managedByShim, bool readOnly, String name, String description
});




}
/// @nodoc
class _$CodexMcpConfigDtoCopyWithImpl<$Res>
    implements $CodexMcpConfigDtoCopyWith<$Res> {
  _$CodexMcpConfigDtoCopyWithImpl(this._self, this._then);

  final CodexMcpConfigDto _self;
  final $Res Function(CodexMcpConfigDto) _then;

/// Create a copy of CodexMcpConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? bodyText = null,Object? enabled = null,Object? managedByShim = null,Object? readOnly = null,Object? name = null,Object? description = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,bodyText: null == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,managedByShim: null == managedByShim ? _self.managedByShim : managedByShim // ignore: cast_nullable_to_non_nullable
as bool,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexMcpConfigDto].
extension CodexMcpConfigDtoPatterns on CodexMcpConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexMcpConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexMcpConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexMcpConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _CodexMcpConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexMcpConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _CodexMcpConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  String bodyText,  bool enabled,  bool managedByShim,  bool readOnly,  String name,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexMcpConfigDto() when $default != null:
return $default(_that.id,_that.kind,_that.bodyText,_that.enabled,_that.managedByShim,_that.readOnly,_that.name,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  String bodyText,  bool enabled,  bool managedByShim,  bool readOnly,  String name,  String description)  $default,) {final _that = this;
switch (_that) {
case _CodexMcpConfigDto():
return $default(_that.id,_that.kind,_that.bodyText,_that.enabled,_that.managedByShim,_that.readOnly,_that.name,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  String bodyText,  bool enabled,  bool managedByShim,  bool readOnly,  String name,  String description)?  $default,) {final _that = this;
switch (_that) {
case _CodexMcpConfigDto() when $default != null:
return $default(_that.id,_that.kind,_that.bodyText,_that.enabled,_that.managedByShim,_that.readOnly,_that.name,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CodexMcpConfigDto extends CodexMcpConfigDto {
  const _CodexMcpConfigDto({this.id = '', this.kind = CodexMcpConfigKind.mcpServer, this.bodyText = '', this.enabled = true, this.managedByShim = false, this.readOnly = true, this.name = '', this.description = ''}): super._();
  factory _CodexMcpConfigDto.fromJson(Map<String, dynamic> json) => _$CodexMcpConfigDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String kind;
@override@JsonKey() final  String bodyText;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool managedByShim;
@override@JsonKey() final  bool readOnly;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;

/// Create a copy of CodexMcpConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexMcpConfigDtoCopyWith<_CodexMcpConfigDto> get copyWith => __$CodexMcpConfigDtoCopyWithImpl<_CodexMcpConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodexMcpConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexMcpConfigDto&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.managedByShim, managedByShim) || other.managedByShim == managedByShim)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,bodyText,enabled,managedByShim,readOnly,name,description);

@override
String toString() {
  return 'CodexMcpConfigDto(id: $id, kind: $kind, bodyText: $bodyText, enabled: $enabled, managedByShim: $managedByShim, readOnly: $readOnly, name: $name, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CodexMcpConfigDtoCopyWith<$Res> implements $CodexMcpConfigDtoCopyWith<$Res> {
  factory _$CodexMcpConfigDtoCopyWith(_CodexMcpConfigDto value, $Res Function(_CodexMcpConfigDto) _then) = __$CodexMcpConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, String bodyText, bool enabled, bool managedByShim, bool readOnly, String name, String description
});




}
/// @nodoc
class __$CodexMcpConfigDtoCopyWithImpl<$Res>
    implements _$CodexMcpConfigDtoCopyWith<$Res> {
  __$CodexMcpConfigDtoCopyWithImpl(this._self, this._then);

  final _CodexMcpConfigDto _self;
  final $Res Function(_CodexMcpConfigDto) _then;

/// Create a copy of CodexMcpConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? bodyText = null,Object? enabled = null,Object? managedByShim = null,Object? readOnly = null,Object? name = null,Object? description = null,}) {
  return _then(_CodexMcpConfigDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,bodyText: null == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,managedByShim: null == managedByShim ? _self.managedByShim : managedByShim // ignore: cast_nullable_to_non_nullable
as bool,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
