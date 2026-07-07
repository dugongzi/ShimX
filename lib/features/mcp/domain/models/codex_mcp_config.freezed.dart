// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'codex_mcp_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodexMcpConfig {

 String get id; String get kind; String get bodyText; bool get enabled; bool get managedByShimX; bool get readOnly; String get name; String get description;
/// Create a copy of CodexMcpConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodexMcpConfigCopyWith<CodexMcpConfig> get copyWith => _$CodexMcpConfigCopyWithImpl<CodexMcpConfig>(this as CodexMcpConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodexMcpConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.managedByShimX, managedByShimX) || other.managedByShimX == managedByShimX)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,bodyText,enabled,managedByShimX,readOnly,name,description);

@override
String toString() {
  return 'CodexMcpConfig(id: $id, kind: $kind, bodyText: $bodyText, enabled: $enabled, managedByShimX: $managedByShimX, readOnly: $readOnly, name: $name, description: $description)';
}


}

/// @nodoc
abstract mixin class $CodexMcpConfigCopyWith<$Res>  {
  factory $CodexMcpConfigCopyWith(CodexMcpConfig value, $Res Function(CodexMcpConfig) _then) = _$CodexMcpConfigCopyWithImpl;
@useResult
$Res call({
 String id, String kind, String bodyText, bool enabled, bool managedByShimX, bool readOnly, String name, String description
});




}
/// @nodoc
class _$CodexMcpConfigCopyWithImpl<$Res>
    implements $CodexMcpConfigCopyWith<$Res> {
  _$CodexMcpConfigCopyWithImpl(this._self, this._then);

  final CodexMcpConfig _self;
  final $Res Function(CodexMcpConfig) _then;

/// Create a copy of CodexMcpConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? bodyText = null,Object? enabled = null,Object? managedByShimX = null,Object? readOnly = null,Object? name = null,Object? description = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,bodyText: null == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,managedByShimX: null == managedByShimX ? _self.managedByShimX : managedByShimX // ignore: cast_nullable_to_non_nullable
as bool,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CodexMcpConfig].
extension CodexMcpConfigPatterns on CodexMcpConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodexMcpConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodexMcpConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodexMcpConfig value)  $default,){
final _that = this;
switch (_that) {
case _CodexMcpConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodexMcpConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CodexMcpConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  String bodyText,  bool enabled,  bool managedByShimX,  bool readOnly,  String name,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodexMcpConfig() when $default != null:
return $default(_that.id,_that.kind,_that.bodyText,_that.enabled,_that.managedByShimX,_that.readOnly,_that.name,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  String bodyText,  bool enabled,  bool managedByShimX,  bool readOnly,  String name,  String description)  $default,) {final _that = this;
switch (_that) {
case _CodexMcpConfig():
return $default(_that.id,_that.kind,_that.bodyText,_that.enabled,_that.managedByShimX,_that.readOnly,_that.name,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  String bodyText,  bool enabled,  bool managedByShimX,  bool readOnly,  String name,  String description)?  $default,) {final _that = this;
switch (_that) {
case _CodexMcpConfig() when $default != null:
return $default(_that.id,_that.kind,_that.bodyText,_that.enabled,_that.managedByShimX,_that.readOnly,_that.name,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _CodexMcpConfig extends CodexMcpConfig {
  const _CodexMcpConfig({required this.id, required this.kind, required this.bodyText, required this.enabled, required this.managedByShimX, required this.readOnly, this.name = '', this.description = ''}): super._();
  

@override final  String id;
@override final  String kind;
@override final  String bodyText;
@override final  bool enabled;
@override final  bool managedByShimX;
@override final  bool readOnly;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;

/// Create a copy of CodexMcpConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodexMcpConfigCopyWith<_CodexMcpConfig> get copyWith => __$CodexMcpConfigCopyWithImpl<_CodexMcpConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodexMcpConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.managedByShimX, managedByShimX) || other.managedByShimX == managedByShimX)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,bodyText,enabled,managedByShimX,readOnly,name,description);

@override
String toString() {
  return 'CodexMcpConfig(id: $id, kind: $kind, bodyText: $bodyText, enabled: $enabled, managedByShimX: $managedByShimX, readOnly: $readOnly, name: $name, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CodexMcpConfigCopyWith<$Res> implements $CodexMcpConfigCopyWith<$Res> {
  factory _$CodexMcpConfigCopyWith(_CodexMcpConfig value, $Res Function(_CodexMcpConfig) _then) = __$CodexMcpConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, String bodyText, bool enabled, bool managedByShimX, bool readOnly, String name, String description
});




}
/// @nodoc
class __$CodexMcpConfigCopyWithImpl<$Res>
    implements _$CodexMcpConfigCopyWith<$Res> {
  __$CodexMcpConfigCopyWithImpl(this._self, this._then);

  final _CodexMcpConfig _self;
  final $Res Function(_CodexMcpConfig) _then;

/// Create a copy of CodexMcpConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? bodyText = null,Object? enabled = null,Object? managedByShimX = null,Object? readOnly = null,Object? name = null,Object? description = null,}) {
  return _then(_CodexMcpConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,bodyText: null == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,managedByShimX: null == managedByShimX ? _self.managedByShimX : managedByShimX // ignore: cast_nullable_to_non_nullable
as bool,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
