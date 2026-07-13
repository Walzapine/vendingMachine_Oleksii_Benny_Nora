import 'package:flutter/material.dart';
import 'package:snackautomat/models/machine_state.dart';
import '../services/vending_machine_service.dart';
import 'coin_options.dart';
import 'coin_button.dart';
import 'product_select_button.dart';

/// Guthaben-Anzeige, Münz-Buttons und Produktauswahl als eine Karte.
///
/// Inhaltlich das Gegenstück zu `ControlPanel` (Desktop, in
/// `desktop_control_panel.dart`), aber mit `Wrap` statt fester `GridView`-
/// Höhen, damit sich die Buttons flexibel an unterschiedliche Handy-Breiten
/// anpassen. Die einzelnen Buttons selbst ([CoinButton],
/// [ProductSelectButton]) sind mit der Desktop-Variante geteilt.
class MobileControlPanel extends StatelessWidget {
  const MobileControlPanel({
    super.key,
    required this.state,
    required this.service,
    required this.isCompact,
  });

  final MachineState state;
  final VendingMachineService service;

  /// `true` unterhalb von `compactMobileBreakpoint` (siehe
  /// `mobile_machine.dart`) - steuert Abstände und Schriftgröße innerhalb
  /// dieser Karte.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final sectionSpacing = isCompact ? 12.0 : 16.0;
    final creditStyle = isCompact
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.headlineSmall;

    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Guthaben'),
            Text(state.formattedCredit, style: creditStyle),
            SizedBox(height: sectionSpacing),
            const Text('Geld einwerfen'),
            const SizedBox(height: 8),
            Wrap(
              spacing: isCompact ? 6 : 8,
              runSpacing: isCompact ? 6 : 8,
              children: coinButtons.entries.map((coin) {
                return CoinButton(
                  label: coin.key,
                  valueInCents: coin.value,
                  service: service,
                );
              }).toList(),
            ),
            SizedBox(height: sectionSpacing),
            const Text('Produktauswahl'),
            const SizedBox(height: 8),
            Wrap(
              spacing: isCompact ? 6 : 8,
              runSpacing: isCompact ? 6 : 8,
              children: state.products.map((product) {
                return ProductSelectButton(
                  product: product,
                  isSelected: state.selectedProductId == product.id,
                  service: service,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}