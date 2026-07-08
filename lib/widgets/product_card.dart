import 'package:flutter/material.dart';

import '../models/product.dart';

/// Wiederverwendbare Darstellung eines einzelnen Automatenfachs.
///
/// Das Widget enthält ausschließlich Präsentationslogik. Es verändert weder
/// Guthaben noch Bestand. Bei einer gültigen Auswahl ruft es nur [onTap] auf;
/// die eigentliche Reaktion wird vom übergeordneten Screen beziehungsweise
/// Service festgelegt.
class ProductCard extends StatelessWidget {
  /// Erstellt eine Produktkarte für ein konkretes Produkt und Fach.
  const ProductCard({
    super.key,
    required this.product,
    required this.slotCode,
    required this.onTap,
  });

  /// Darzustellende Produktdaten.
  final Product product;

  /// Für Kunden sichtbare Fachnummer, beispielsweise `A1`.
  final String slotCode;

  /// Callback, der bei Auswahl eines verfügbaren Produkts ausgeführt wird.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Die Verfügbarkeit wird aus dem Bestand abgeleitet. Dadurch gibt es keinen
    // zweiten booleschen Wert, der dem tatsächlichen Bestand widersprechen kann.
    final isAvailable = product.stock > 0;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        // Ein ausverkauftes Produkt erhält keinen Tap-Callback und ist damit
        // automatisch deaktiviert.
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Align(alignment: Alignment.topLeft, child: Text(slotCode)),
              Expanded(
                // Expanded reserviert den flexiblen Mittelbereich für das
                // vorläufige Emoji. Spätere Produktbilder passen an diese Stelle.
                child: Center(
                  child: Text(
                    product.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                // Preis und Ausverkauft-Hinweis teilen denselben festen Bereich,
                // damit alle Karten gleich hoch bleiben.
                isAvailable ? product.price.toString() : 'Ausverkauft',
                style: TextStyle(
                  color: isAvailable ? null : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
