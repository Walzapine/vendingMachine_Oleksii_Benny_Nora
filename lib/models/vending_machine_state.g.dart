// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vending_machine_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VendingMachineState _$VendingMachineStateFromJson(Map<String, dynamic> json) =>
    _VendingMachineState(
      currentMoney: (json['currentMoney'] as num).toDouble(),
      selectedProduct: (json['selectedProduct'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VendingMachineStateToJson(
  _VendingMachineState instance,
) => <String, dynamic>{
  'currentMoney': instance.currentMoney,
  'selectedProduct': instance.selectedProduct,
};
