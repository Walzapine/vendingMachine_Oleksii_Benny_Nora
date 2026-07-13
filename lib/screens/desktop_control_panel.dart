import 'package:flutter/material.dart';
import 'package:snackautomat/models/machine_state.dart';
import '../services/vending_machine_service.dart';
import '../widgets/coin_options.dart';
import '../widgets/coin_button.dart';
import '../widgets/product_select_button.dart';
import '../widgets/purchase_actions.dart';

/// Rechtes Bedienfeld für Geld, Fachauswahl und Kaufaktionen (Desktop).
///
/// Nur für Desktop-Breiten - siehe `MobileControlPanel` in
/// `lib/widgets/mobile_control_panel.dart` für die schmale Variante mit
/// `Wrap` statt fester `GridView`-Höhen.
class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key, required this.state, required this.service});

  final MachineState state;
  final VendingMachineService service;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Guthaben'),
            Text(
              state.formattedCredit,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text('Geld einwerfen'),
            const SizedBox(height: 6),
            SizedBox(
              height: 82,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.8,
                children: coinButtons.entries.map((coin) {
                  return CoinButton(
                    label: coin.key,
                    valueInCents: coin.value,
                    service: service,
                    compact: true,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Produktauswahl'),
            const SizedBox(height: 6),
            SizedBox(
              height: 132,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.2,
                children: state.products.map((product) {
                  return ProductSelectButton(
                    product: product,
                    isSelected: state.selectedProductId == product.id,
                    service: service,
                    compact: true,
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => performPurchase(context, service),
              child: const Text('KAUFEN'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => performReturnMoney(context, service),
              child: const Text('RÜCKGABE'),
            ),
          ],
        ),
      ),
    );
  }
}