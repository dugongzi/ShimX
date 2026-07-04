// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plugin_marketplace_status_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PluginMarketplaceStatusDto {

 bool get installed; bool get configured; int get pluginCount; String get codexHome;
/// Create a copy of PluginMarketplaceStatusDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PluginMarketplaceStatusDtoCopyWith<PluginMarketplaceStatusDto> get copyWith => _$PluginMarketplaceStatusDtoCopyWithImpl<PluginMarketplaceStatusDto>(this as PluginMarketplaceStatusDto, _$identity);

  /// Serializes this PluginMarketplaceStatusDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PluginMarketplaceStatusDto&&(identical(other.installed, installed) || other.installed == installed)&&(identical(other.configured, configured) || other.configured == configured)&&(identical(other.pluginCount, pluginCount) || other.pluginCount == pluginCount)&&(identical(other.codexHome, codexHome) || other.codexHome == codexHome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,installed,configured,pluginCount,codexHome);

@override
String toString() {
  return 'PluginMarketplaceStatusDto(installed: $installed, configured: $configured, pluginCount: $pluginCount, codexHome: $codexHome)';
}


}

/// @nodoc
abstract mixin class $PluginMarketplaceStatusDtoCopyWith<$Res>  {
  factory $PluginMarketplaceStatusDtoCopyWith(PluginMarketplaceStatusDto value, $Res Function(PluginMarketplaceStatusDto) _then) = _$PluginMarketplaceStatusDtoCopyWithImpl;
@useResult
$Res call({
 bool installed, bool configured, int pluginCount, String codexHome
});




}
/// @nodoc
class _$PluginMarketplaceStatusDtoCopyWithImpl<$Res>
    implements $PluginMarketplaceStatusDtoCopyWith<$Res> {
  _$PluginMarketplaceStatusDtoCopyWithImpl(this._self, this._then);

  final PluginMarketplaceStatusDto _self;
  final $Res Function(PluginMarketplaceStatusDto) _then;

/// Create a copy of PluginMarketplaceStatusDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? installed = null,Object? configured = null,Object? pluginCount = null,Object? codexHome = null,}) {
  return _then(_self.copyWith(
installed: null == installed ? _self.installed : installed // ignore: cast_nullable_to_non_nullable
as bool,configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,pluginCount: null == pluginCount ? _self.pluginCount : pluginCount // ignore: cast_nullable_to_non_nullable
as int,codexHome: null == codexHome ? _self.codexHome : codexHome // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PluginMarketplaceStatusDto].
extension PluginMarketplaceStatusDtoPatterns on PluginMarketplaceStatusDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PluginMarketplaceStatusDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PluginMarketplaceStatusDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PluginMarketplaceStatusDto value)  $default,){
final _that = this;
switch (_that) {
case _PluginMarketplaceStatusDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PluginMarketplaceStatusDto value)?  $default,){
final _that = this;
switch (_that) {
case _PluginMarketplaceStatusDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool installed,  bool configured,  int pluginCount,  String codexHome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PluginMarketplaceStatusDto() when $default != null:
return $default(_that.installed,_that.configured,_that.pluginCount,_that.codexHome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool installed,  bool configured,  int pluginCount,  String codexHome)  $default,) {final _that = this;
switch (_that) {
case _PluginMarketplaceStatusDto():
return $default(_that.installed,_that.configured,_that.pluginCount,_that.codexHome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool installed,  bool configured,  int pluginCount,  String codexHome)?  $default,) {final _that = this;
switch (_that) {
case _PluginMarketplaceStatusDto() when $default != null:
return $default(_that.installed,_that.configured,_that.pluginCount,_that.codexHome);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PluginMarketplaceStatusDto extends PluginMarketplaceStatusDto {
  const _PluginMarketplaceStatusDto({this.installed = false, this.configured = false, this.pluginCount = 0, this.codexHome = ''}): super._();
  factory _PluginMarketplaceStatusDto.fromJson(Map<String, dynamic> json) => _$PluginMarketplaceStatusDtoFromJson(json);

@override@JsonKey() final  bool installed;
@override@JsonKey() final  bool configured;
@override@JsonKey() final  int pluginCount;
@override@JsonKey() final  String codexHome;

/// Create a copy of PluginMarketplaceStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PluginMarketplaceStatusDtoCopyWith<_PluginMarketplaceStatusDto> get copyWith => __$PluginMarketplaceStatusDtoCopyWithImpl<_PluginMarketplaceStatusDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PluginMarketplaceStatusDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PluginMarketplaceStatusDto&&(identical(other.installed, installed) || other.installed == installed)&&(identical(other.configured, configured) || other.configured == configured)&&(identical(other.pluginCount, pluginCount) || other.pluginCount == pluginCount)&&(identical(other.codexHome, codexHome) || other.codexHome == codexHome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,installed,configured,pluginCount,codexHome);

@override
String toString() {
  return 'PluginMarketplaceStatusDto(installed: $installed, configured: $configured, pluginCount: $pluginCount, codexHome: $codexHome)';
}


}

/// @nodoc
abstract mixin class _$PluginMarketplaceStatusDtoCopyWith<$Res> implements $PluginMarketplaceStatusDtoCopyWith<$Res> {
  factory _$PluginMarketplaceStatusDtoCopyWith(_PluginMarketplaceStatusDto value, $Res Function(_PluginMarketplaceStatusDto) _then) = __$PluginMarketplaceStatusDtoCopyWithImpl;
@override @useResult
$Res call({
 bool installed, bool configured, int pluginCount, String codexHome
});




}
/// @nodoc
class __$PluginMarketplaceStatusDtoCopyWithImpl<$Res>
    implements _$PluginMarketplaceStatusDtoCopyWith<$Res> {
  __$PluginMarketplaceStatusDtoCopyWithImpl(this._self, this._then);

  final _PluginMarketplaceStatusDto _self;
  final $Res Function(_PluginMarketplaceStatusDto) _then;

/// Create a copy of PluginMarketplaceStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? installed = null,Object? configured = null,Object? pluginCount = null,Object? codexHome = null,}) {
  return _then(_PluginMarketplaceStatusDto(
installed: null == installed ? _self.installed : installed // ignore: cast_nullable_to_non_nullable
as bool,configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,pluginCount: null == pluginCount ? _self.pluginCount : pluginCount // ignore: cast_nullable_to_non_nullable
as int,codexHome: null == codexHome ? _self.codexHome : codexHome // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
