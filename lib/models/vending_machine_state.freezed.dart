// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vending_machine_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VendingMachineState {

 double get currentMoney; int? get selectedProduct;
/// Create a copy of VendingMachineState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendingMachineStateCopyWith<VendingMachineState> get copyWith => _$VendingMachineStateCopyWithImpl<VendingMachineState>(this as VendingMachineState, _$identity);

  /// Serializes this VendingMachineState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendingMachineState&&(identical(other.currentMoney, currentMoney) || other.currentMoney == currentMoney)&&(identical(other.selectedProduct, selectedProduct) || other.selectedProduct == selectedProduct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentMoney,selectedProduct);

@override
String toString() {
  return 'VendingMachineState(currentMoney: $currentMoney, selectedProduct: $selectedProduct)';
}


}

/// @nodoc
abstract mixin class $VendingMachineStateCopyWith<$Res>  {
  factory $VendingMachineStateCopyWith(VendingMachineState value, $Res Function(VendingMachineState) _then) = _$VendingMachineStateCopyWithImpl;
@useResult
$Res call({
 double currentMoney, int? selectedProduct
});




}
/// @nodoc
class _$VendingMachineStateCopyWithImpl<$Res>
    implements $VendingMachineStateCopyWith<$Res> {
  _$VendingMachineStateCopyWithImpl(this._self, this._then);

  final VendingMachineState _self;
  final $Res Function(VendingMachineState) _then;

/// Create a copy of VendingMachineState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentMoney = null,Object? selectedProduct = freezed,}) {
  return _then(_self.copyWith(
currentMoney: null == currentMoney ? _self.currentMoney : currentMoney // ignore: cast_nullable_to_non_nullable
as double,selectedProduct: freezed == selectedProduct ? _self.selectedProduct : selectedProduct // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendingMachineState].
extension VendingMachineStatePatterns on VendingMachineState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendingMachineState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendingMachineState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendingMachineState value)  $default,){
final _that = this;
switch (_that) {
case _VendingMachineState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendingMachineState value)?  $default,){
final _that = this;
switch (_that) {
case _VendingMachineState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double currentMoney,  int? selectedProduct)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendingMachineState() when $default != null:
return $default(_that.currentMoney,_that.selectedProduct);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double currentMoney,  int? selectedProduct)  $default,) {final _that = this;
switch (_that) {
case _VendingMachineState():
return $default(_that.currentMoney,_that.selectedProduct);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double currentMoney,  int? selectedProduct)?  $default,) {final _that = this;
switch (_that) {
case _VendingMachineState() when $default != null:
return $default(_that.currentMoney,_that.selectedProduct);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendingMachineState implements VendingMachineState {
  const _VendingMachineState({required this.currentMoney, this.selectedProduct});
  factory _VendingMachineState.fromJson(Map<String, dynamic> json) => _$VendingMachineStateFromJson(json);

@override final  double currentMoney;
@override final  int? selectedProduct;

/// Create a copy of VendingMachineState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendingMachineStateCopyWith<_VendingMachineState> get copyWith => __$VendingMachineStateCopyWithImpl<_VendingMachineState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendingMachineStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendingMachineState&&(identical(other.currentMoney, currentMoney) || other.currentMoney == currentMoney)&&(identical(other.selectedProduct, selectedProduct) || other.selectedProduct == selectedProduct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentMoney,selectedProduct);

@override
String toString() {
  return 'VendingMachineState(currentMoney: $currentMoney, selectedProduct: $selectedProduct)';
}


}

/// @nodoc
abstract mixin class _$VendingMachineStateCopyWith<$Res> implements $VendingMachineStateCopyWith<$Res> {
  factory _$VendingMachineStateCopyWith(_VendingMachineState value, $Res Function(_VendingMachineState) _then) = __$VendingMachineStateCopyWithImpl;
@override @useResult
$Res call({
 double currentMoney, int? selectedProduct
});




}
/// @nodoc
class __$VendingMachineStateCopyWithImpl<$Res>
    implements _$VendingMachineStateCopyWith<$Res> {
  __$VendingMachineStateCopyWithImpl(this._self, this._then);

  final _VendingMachineState _self;
  final $Res Function(_VendingMachineState) _then;

/// Create a copy of VendingMachineState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentMoney = null,Object? selectedProduct = freezed,}) {
  return _then(_VendingMachineState(
currentMoney: null == currentMoney ? _self.currentMoney : currentMoney // ignore: cast_nullable_to_non_nullable
as double,selectedProduct: freezed == selectedProduct ? _self.selectedProduct : selectedProduct // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
