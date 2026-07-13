import 'package:flutter/material.dart';
import '../services/vending_machine_service.dart';

/// Ein einzelner "Geld einwerfen"-Button für eine Münzsorte.
///
/// War vorher in `ControlPanel` (Desktop, in einem `GridView`) und
/// `MobileControlPanel` (Mobile, in einem `Wrap`) inhaltlich identisch
/// dupliziert - nur der äußere Container unterschied sich. Diese Klasse
/// enthält nur den Button selbst; wie er angeordnet wird (Grid oder Wrap),
/// entscheidet weiterhin der jeweilige Aufrufer.
class CoinButton extends StatelessWidget {
  const CoinButton({
    super.key,
    required this.label,
    required this.valueInCents,
    required this.service,
    this.compact = false,
  });

  /// Sichtbare Beschriftung, z. B. `'2 €'`.
  final String label;

  /// An [VendingMachineService.insertMoney] übergebener Centbetrag.
  final int valueInCents;

  final VendingMachineService service;

  /// `true` in engen Grid-Zellen (Desktop) - entfernt das Innen-Padding,
  /// damit der Button in kleine, feste Zellen passt. Im `Wrap` (Mobile)
  /// bleibt das Standard-Padding, weil dort kein Platzmangel herrscht.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => service.insertMoney(valueInCents),
      style: compact
          ? OutlinedButton.styleFrom(padding: EdgeInsets.zero)
          : null,
      child: Text(label),
    );
  }
}