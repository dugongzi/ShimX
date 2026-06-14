// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProviderListState {

 List<ApiProvider> get providers; String? get selectedId;
/// Create a copy of ProviderListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderListStateCopyWith<ProviderListState> get copyWith => _$ProviderListStateCopyWithImpl<ProviderListState>(this as ProviderListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderListState&&const DeepCollectionEquality().equals(other.providers, providers)&&(identical(other.selectedId, selectedId) || other.selectedId == selectedId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(providers),selectedId);

@override
String toString() {
  return 'ProviderListState(providers: $providers, selectedId: $selectedId)';
}


}

/// @nodoc
abstract mixin class $ProviderListStateCopyWith<$Res>  {
  factory $ProviderListStateCopyWith(ProviderListState value, $Res Function(ProviderListState) _then) = _$ProviderListStateCopyWithImpl;
@useResult
$Res call({
 List<ApiProvider> providers, String? selectedId
});




}
/// @nodoc
class _$ProviderListStateCopyWithImpl<$Res>
    implements $ProviderListStateCopyWith<$Res> {
  _$ProviderListStateCopyWithImpl(this._self, this._then);

  final ProviderListState _self;
  final $Res Function(ProviderListState) _then;

/// Create a copy of ProviderListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providers = null,Object? selectedId = freezed,}) {
  return _then(_self.copyWith(
providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<ApiProvider>,selectedId: freezed == selectedId ? _self.selectedId : selectedId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderListState].
extension ProviderListStatePatterns on ProviderListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderListState value)  $default,){
final _that = this;
switch (_that) {
case _ProviderListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderListState value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ApiProvider> providers,  String? selectedId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderListState() when $default != null:
return $default(_that.providers,_that.selectedId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ApiProvider> providers,  String? selectedId)  $default,) {final _that = this;
switch (_that) {
case _ProviderListState():
return $default(_that.providers,_that.selectedId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ApiProvider> providers,  String? selectedId)?  $default,) {final _that = this;
switch (_that) {
case _ProviderListState() when $default != null:
return $default(_that.providers,_that.selectedId);case _:
  return null;

}
}

}

/// @nodoc


class _ProviderListState extends ProviderListState {
  const _ProviderListState({final  List<ApiProvider> providers = const [], this.selectedId}): _providers = providers,super._();
  

 final  List<ApiProvider> _providers;
@override@JsonKey() List<ApiProvider> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}

@override final  String? selectedId;

/// Create a copy of ProviderListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderListStateCopyWith<_ProviderListState> get copyWith => __$ProviderListStateCopyWithImpl<_ProviderListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderListState&&const DeepCollectionEquality().equals(other._providers, _providers)&&(identical(other.selectedId, selectedId) || other.selectedId == selectedId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_providers),selectedId);

@override
String toString() {
  return 'ProviderListState(providers: $providers, selectedId: $selectedId)';
}


}

/// @nodoc
abstract mixin class _$ProviderListStateCopyWith<$Res> implements $ProviderListStateCopyWith<$Res> {
  factory _$ProviderListStateCopyWith(_ProviderListState value, $Res Function(_ProviderListState) _then) = __$ProviderListStateCopyWithImpl;
@override @useResult
$Res call({
 List<ApiProvider> providers, String? selectedId
});




}
/// @nodoc
class __$ProviderListStateCopyWithImpl<$Res>
    implements _$ProviderListStateCopyWith<$Res> {
  __$ProviderListStateCopyWithImpl(this._self, this._then);

  final _ProviderListState _self;
  final $Res Function(_ProviderListState) _then;

/// Create a copy of ProviderListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providers = null,Object? selectedId = freezed,}) {
  return _then(_ProviderListState(
providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<ApiProvider>,selectedId: freezed == selectedId ? _self.selectedId : selectedId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
