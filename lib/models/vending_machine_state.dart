import 'package:freezed_annotation/freezed_annotation.dart';

part 'vending_machine_state.freezed.dart';
part 'vending_machine_state.g.dart';

@freezed
abstract class VendingMachineState with _$VendingMachineState {
  const factory VendingMachineState({
    required double currentMoney,
    int? selectedProduct,
  }) = _VendingMachineState;

  factory VendingMachineState.fromJson(Map<String, dynamic> json) =>
      _$VendingMachineStateFromJson(json);
}
