import 'package:flutter/material.dart';
import '../services/vending_machine_service.dart';

/// Startet einen Kauf und zeigt fachliche Fehler als SnackBar an.
///
/// War vorher in `ControlPanel` (Desktop) und `MobileMachine` (Mobile)
/// wortwörtlich dupliziert. Jetzt eine einzige, geteilte Funktion.
///
/// Erfolgreiche Käufe benötigen keine zusätzliche SnackBar, weil der Service
/// die Statuszeile im `MachineState` aktualisiert. `context.mounted` schützt
/// davor, nach einem asynchronen Aufruf einen bereits entfernten Screen zu
/// verwenden.
Future<void> performPurchase(
  BuildContext context,
  VendingMachineService service,
) async {
  final result = await service.purchase();
  if (!context.mounted || result.isSuccess) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(result.message)));
}

/// Bricht den Vorgang ab und informiert über tatsächlich zurückgegebenes Geld.
///
/// Bei einem Rückgabebetrag von 0 ist keine Meldung nötig (nichts stand zur
/// Rückgabe bereit).
void performReturnMoney(BuildContext context, VendingMachineService service) {
  final cents = service.returnMoney();
  if (cents == 0) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$cents Cent zurückgegeben.')));
}