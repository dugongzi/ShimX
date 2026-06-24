// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mcp_server_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$McpServerInfo {

/// 唯一 key,例如 'shim_claude'(也是 ~/.codex/config.toml 里 [mcp_servers.<id>] 的 id)
 String get id;/// 人类可读名称,UI 显示用
 String get name;/// 一句话描述这个 server 干什么
 String get description;/// 本地 HTTP MCP 地址,例如 http://127.0.0.1:18787/mcp
 String get url;/// running / stopped / error
 String get status;/// status 为 error 时的额外说明,其它情况空
 String get statusDetail;/// 暴露的工具数(用于一眼看出 server 是否健康)
 int get toolCount;/// 是否已写到 ~/.codex/config.toml 里
 bool get registeredInCodex;
/// Create a copy of McpServerInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$McpServerInfoCopyWith<McpServerInfo> get copyWith => _$McpServerInfoCopyWithImpl<McpServerInfo>(this as McpServerInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is McpServerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusDetail, statusDetail) || other.statusDetail == statusDetail)&&(identical(other.toolCount, toolCount) || other.toolCount == toolCount)&&(identical(other.registeredInCodex, registeredInCodex) || other.registeredInCodex == registeredInCodex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,url,status,statusDetail,toolCount,registeredInCodex);

@override
String toString() {
  return 'McpServerInfo(id: $id, name: $name, description: $description, url: $url, status: $status, statusDetail: $statusDetail, toolCount: $toolCount, registeredInCodex: $registeredInCodex)';
}


}

/// @nodoc
abstract mixin class $McpServerInfoCopyWith<$Res>  {
  factory $McpServerInfoCopyWith(McpServerInfo value, $Res Function(McpServerInfo) _then) = _$McpServerInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String url, String status, String statusDetail, int toolCount, bool registeredInCodex
});




}
/// @nodoc
class _$McpServerInfoCopyWithImpl<$Res>
    implements $McpServerInfoCopyWith<$Res> {
  _$McpServerInfoCopyWithImpl(this._self, this._then);

  final McpServerInfo _self;
  final $Res Function(McpServerInfo) _then;

/// Create a copy of McpServerInfo
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


/// Adds pattern-matching-related methods to [McpServerInfo].
extension McpServerInfoPatterns on McpServerInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _McpServerInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _McpServerInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _McpServerInfo value)  $default,){
final _that = this;
switch (_that) {
case _McpServerInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _McpServerInfo value)?  $default,){
final _that = this;
switch (_that) {
case _McpServerInfo() when $default != null:
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
case _McpServerInfo() when $default != null:
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
case _McpServerInfo():
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
case _McpServerInfo() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.url,_that.status,_that.statusDetail,_that.toolCount,_that.registeredInCodex);case _:
  return null;

}
}

}

/// @nodoc


class _McpServerInfo extends McpServerInfo {
  const _McpServerInfo({required this.id, required this.name, required this.description, required this.url, required this.status, this.statusDetail = '', this.toolCount = 0, this.registeredInCodex = false}): super._();
  

/// 唯一 key,例如 'shim_claude'(也是 ~/.codex/config.toml 里 [mcp_servers.<id>] 的 id)
@override final  String id;
/// 人类可读名称,UI 显示用
@override final  String name;
/// 一句话描述这个 server 干什么
@override final  String description;
/// 本地 HTTP MCP 地址,例如 http://127.0.0.1:18787/mcp
@override final  String url;
/// running / stopped / error
@override final  String status;
/// status 为 error 时的额外说明,其它情况空
@override@JsonKey() final  String statusDetail;
/// 暴露的工具数(用于一眼看出 server 是否健康)
@override@JsonKey() final  int toolCount;
/// 是否已写到 ~/.codex/config.toml 里
@override@JsonKey() final  bool registeredInCodex;

/// Create a copy of McpServerInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$McpServerInfoCopyWith<_McpServerInfo> get copyWith => __$McpServerInfoCopyWithImpl<_McpServerInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _McpServerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusDetail, statusDetail) || other.statusDetail == statusDetail)&&(identical(other.toolCount, toolCount) || other.toolCount == toolCount)&&(identical(other.registeredInCodex, registeredInCodex) || other.registeredInCodex == registeredInCodex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,url,status,statusDetail,toolCount,registeredInCodex);

@override
String toString() {
  return 'McpServerInfo(id: $id, name: $name, description: $description, url: $url, status: $status, statusDetail: $statusDetail, toolCount: $toolCount, registeredInCodex: $registeredInCodex)';
}


}

/// @nodoc
abstract mixin class _$McpServerInfoCopyWith<$Res> implements $McpServerInfoCopyWith<$Res> {
  factory _$McpServerInfoCopyWith(_McpServerInfo value, $Res Function(_McpServerInfo) _then) = __$McpServerInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String url, String status, String statusDetail, int toolCount, bool registeredInCodex
});




}
/// @nodoc
class __$McpServerInfoCopyWithImpl<$Res>
    implements _$McpServerInfoCopyWith<$Res> {
  __$McpServerInfoCopyWithImpl(this._self, this._then);

  final _McpServerInfo _self;
  final $Res Function(_McpServerInfo) _then;

/// Create a copy of McpServerInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? url = null,Object? status = null,Object? statusDetail = null,Object? toolCount = null,Object? registeredInCodex = null,}) {
  return _then(_McpServerInfo(
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
