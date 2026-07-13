import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/vending_machine_service.dart';

/// Ein einzelner Produktauswahl-Button (zeigt nur die ID, z. B. `'3'`).
///
/// War vorher in `ControlPanel` (Desktop) und `MobileControlPanel` (Mobile)
/// inhaltlich identisch dupliziert - inklusive der "ausgewählt"-Markierung
/// über `colorScheme.primaryContainer`.
class ProductSelectButton extends StatelessWidget {
  const ProductSelectButton({
    super.key,
    required this.product,
    required this.isSelected,
    required this.service,
    this.compact = false,
  });

  final Product product;

  /// Ob dieses Produkt gerade das ausgewählte ist (Vergleich über die
  /// stabile technische ID, nicht den Namen).
  final bool isSelected;

  final VendingMachineService service;

  /// `true` in engen Grid-Zellen (Desktop) - entfernt das Innen-Padding.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => service.selectProduct(product.id),
      style: OutlinedButton.styleFrom(
        padding: compact ? EdgeInsets.zero : null,
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
      child: Text(product.id.toString()),
    );
  }
}