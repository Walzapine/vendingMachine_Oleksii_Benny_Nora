import 'package:flutter/material.dart';
import 'package:snackautomat/models/machine_state.dart';
import '../services/vending_machine_service.dart';
import '../widgets/product_card.dart';
import '../widgets/tray_button.dart';
import '../widgets/coin_options.dart';
import 'admin_screen.dart';

/// Zweite Stufe innerhalb des Mobile-Layouts: Unterhalb dieser Breite gilt
/// ein Bildschirm als "sehr schmal" (z. B. iPhone SE, kleine Android-Handys).
/// Dort werden Spaltenzahl, Abstände und Schriftgrößen nochmal verkleinert,
/// statt bei jeder Breite unterhalb des Mobile-Breakpoints (siehe
/// `product_screen.dart`) gleich auszusehen.
const double compactMobileBreakpoint = 420;

/// Layout für schmale Bildschirme (z. B. Smartphone im Hochformat).
///
/// Anders als [DesktopMachine] hat dieses Layout KEINE feste Pixelgröße
/// und wird nicht per FittedBox skaliert. Stattdessen:
///
/// * ordnen sich Produktraster, Fächer und Bedienfeld UNTEREINANDER an
///   (statt nebeneinander wie am Desktop),
/// * scrollt die ganze Seite bei Bedarf (`SingleChildScrollView`), statt
///   alles in eine feste Höhe zu zwängen,
/// * werden Münz- und Produktauswahl-Buttons über `Wrap` statt über
///   `GridView` mit fester Pixelhöhe angeordnet - das umgeht die Art von
///   Rundungsfehlern, die uns beim Desktop-Layout schon Kopfzerbrechen
///   bereitet haben (feste SizedBox-Höhe reicht knapp nicht für den Inhalt).
///
/// Enthält bewusst eigenen Code statt `ProductArea`/`ControlPanel` (aus
/// `desktop_machine.dart`) wiederzuverwenden: Beide setzen intern `Expanded`
/// ein, was einen begrenzten Elternhöhen-Kontext braucht. Innerhalb eines
/// `SingleChildScrollView` ist die Höhe aber unbegrenzt - `Expanded` würde
/// dort einen Laufzeitfehler auslösen.
class MobileMachine extends StatelessWidget {
  const MobileMachine({
    super.key,
    required this.state,
    required this.service,
    required this.width,
  });

  final MachineState state;
  final VendingMachineService service;

  /// Tatsächlich verfügbare Breite, vom LayoutBuilder in `product_screen.dart`
  /// durchgereicht. Steuert die feineren Anpassungen innerhalb des
  /// Mobile-Layouts (Spaltenzahl, Abstände, Schriftgröße).
  final double width;

  Future<void> _purchase(BuildContext context) async {
    final result = await service.purchase();
    if (!context.mounted || result.isSuccess) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  void _returnMoney(BuildContext context) {
    final cents = service.returnMoney();
    if (cents == 0) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$cents Cent zurückgegeben.')));
  }

  @override
  Widget build(BuildContext context) {
    // Unterhalb von compactMobileBreakpoint gilt der Bildschirm als "sehr
    // schmal" (z. B. iPhone SE) - dort wird nochmal enger/kleiner gebaut als
    // im "normalen" Mobile-Bereich (z. B. Pixel, größere Handys).
    final isCompact = width < compactMobileBreakpoint;

    // Spaltenzahl: bei sehr schmalen Screens 2 Spalten (mehr Platz pro
    // Karte), bei etwas breiteren Handys 3 Spalten (mehr Übersicht).
    final crossAxisCount = isCompact ? 2 : 3;

    // Außenabstand und Abstände zwischen Abschnitten schrumpfen ebenfalls,
    // damit auf sehr kleinen Screens nicht unnötig viel Platz durch Padding
    // verloren geht.
    final outerPadding = isCompact ? 12.0 : 16.0;
    final sectionSpacing = isCompact ? 12.0 : 16.0;

    // Etwas kleinere Schrift für Titel und Guthaben auf sehr schmalen
    // Screens, damit z. B. "SNACKAUTOMAT" nicht zu dominant wirkt.
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Theme.of(context).colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
      fontSize: isCompact ? 16 : 18,
    );
    final creditStyle = isCompact
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.headlineSmall;

    return SingleChildScrollView(
      padding: EdgeInsets.all(outerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kopfzeile - inhaltlich identisch zum Desktop-Header, nur ohne
          // die feste 64px-Höhe (hier reicht die natürliche Höhe des Inhalts).
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 16,
              vertical: isCompact ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text('SNACKAUTOMAT', style: titleStyle),
                const Spacer(),
                IconButton(
                  // Gleiche Navigation wie im Desktop-Header - siehe dort
                  // für die Begründung.
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminScreen(vendingService: service),
                      ),
                    );
                  },
                  tooltip: 'Adminbereich',
                  color: Theme.of(context).colorScheme.onPrimary,
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                ),
              ],
            ),
          ),
          SizedBox(height: sectionSpacing),

          // Produktraster: shrinkWrap + NeverScrollableScrollPhysics, weil
          // die ganze Seite bereits über das äußere SingleChildScrollView
          // scrollt - ein zweites, geschachteltes Scrollen würde zu Konflikten
          // führen ("Scroll-in-Scroll"-Problem).
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isCompact ? 6 : 8,
              mainAxisSpacing: isCompact ? 6 : 8,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductCard(
                product: product,
                slotCode: product.id.toString(),
                onTap: () => service.selectProduct(product.id),
              );
            },
          ),
          SizedBox(height: isCompact ? 8 : 12),

          // Ausgabefach + Rückgeld-Fach nebeneinander - beide sind flexibel
          // (Expanded), das passt auch bei schmaler Breite noch gut.
          Row(
            children: [
              Expanded(
                child: TrayButton(
                  isFilled: state.trayHasProduct,
                  filledColor: Colors.green.shade100,
                  emptyColor: Colors.grey.shade300,
                  label: state.trayHasProduct
                      ? '${state.dispensedProduct?.emoji ?? ''} '
                            '${state.dispensedProduct?.name ?? ''}'
                            ' – antippen'
                      : 'AUSGABEFACH',
                  onTap: state.trayHasProduct
                      ? () => service.collectProduct()
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TrayButton(
                  isFilled: state.hasChangeToCollect,
                  filledColor: Colors.amber.shade100,
                  emptyColor: Colors.grey.shade300,
                  label: state.hasChangeToCollect
                      ? '🪙 ${state.formattedCredit} – antippen'
                      : 'RÜCKGELD',
                  onTap: state.hasChangeToCollect
                      ? () => service.returnMoney()
                      : null,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 12),

          // Statuszeile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(state.statusMessage),
          ),
          SizedBox(height: sectionSpacing),

          // Guthaben, Münzen, Produktauswahl in einer Karte - inhaltlich wie
          // im Desktop-ControlPanel, aber mit Wrap statt festen GridView-
          // Höhen, damit sich die Buttons flexibel an die Breite anpassen.
          Card(
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
                      return OutlinedButton(
                        onPressed: () => service.insertMoney(coin.value),
                        child: Text(coin.key),
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
                      final selected = state.selectedProductId == product.id;
                      return OutlinedButton(
                        onPressed: () => service.selectProduct(product.id),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                        ),
                        child: Text(product.id.toString()),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: sectionSpacing),

          FilledButton(
            onPressed: () => _purchase(context),
            child: const Text('KAUFEN'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _returnMoney(context),
            child: const Text('RÜCKGABE'),
          ),
        ],
      ),
    );
  }
}