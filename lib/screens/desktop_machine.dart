import 'package:flutter/material.dart';
import 'package:snackautomat/models/machine_state.dart';
import '../services/vending_machine_service.dart';
import '../widgets/product_card.dart';
import '../widgets/tray_button.dart';
import '../widgets/coin_options.dart';
import 'admin_screen.dart';

/// Zusammensetzung des sichtbaren Automatenrahmens für Desktop-Breiten.
///
/// Wird ausschließlich von [ProductScreen] verwendet (in dessen
/// Desktop-Zweig, gewrappt in `FittedBox` + feste `SizedBox`-Größe). Andere
/// Dateien sollten diese Klasse nicht direkt verwenden.
class DesktopMachine extends StatelessWidget {
  const DesktopMachine({super.key, required this.state, required this.service});

  /// Aktueller, unveränderlicher Zustand für die Darstellung.
  final MachineState state;

  /// Service für alle vom Benutzer ausgelösten Aktionen.
  final VendingMachineService service;

  @override
  Widget build(BuildContext context) {
    return Card(
      // Clip verhindert, dass die farbige Kopfzeile über die abgerundeten
      // Außenkanten der Card hinausragt.
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 64,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'SNACKAUTOMAT',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  // Öffnet den fertigen AdminScreen zur Verwaltung des
                  // Münzbestands. `service` wird direkt weitergereicht, damit
                  // der AdminScreen auf denselben Service-Zustand zugreift
                  // wie der Verkaufsbildschirm.
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    // Verhältnis 3:1: Produktbereich erhält drei Viertel der
                    // verfügbaren Breite, das Bedienfeld ein Viertel.
                    flex: 3,
                    child: ProductArea(state: state, service: service),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ControlPanel(state: state, service: service),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linker Automatenbereich mit Produkten, Ausgabe und Statuszeile.
///
/// Nur für Desktop-Breiten gedacht (nutzt `Expanded` und setzt damit einen
/// begrenzten Elternhöhen-Kontext voraus). Für schmale Bildschirme siehe
/// stattdessen [MobileMachine].
class ProductArea extends StatelessWidget {
  const ProductArea({super.key, required this.state, required this.service});

  final MachineState state;
  final VendingMachineService service;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          // Die Produktreihenfolge kommt vollständig aus MachineState. Das
          // Frontend enthält keine eigene, zweite Produktliste.
          child: GridView.builder(
            // Das gesamte Automatenlayout wird skaliert; deshalb soll innerhalb
            // des Produktrasters nicht zusätzlich gescrollt werden.
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              // War vorher 1.08 (fast quadratisch) - bei 3 Reihen reichte der
              // verfügbare Platz rechnerisch nur knapp, sodass die unterste
              // Reihe teilweise abgeschnitten wurde. 1.3 macht jede Karte
              // flacher (breiter im Verhältnis zur Höhe) und schafft damit
              // spürbaren Puffer, unabhängig von kleinen Rundungsfehlern.
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductCard(
                product: product,
                slotCode: product.id.toString(),
                // Die Karte meldet nur die Fachnummer. Suchen, Validieren und
                // Speichern der Auswahl übernimmt der Service.
                onTap: () => service.selectProduct(product.id),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Produkt-Fach (links): zeigt entweder den leeren Platzhalter
            // oder, sobald ein Kauf erfolgreich war, das liegende Produkt.
            // Ein Klick ruft service.collectProduct() auf und leert NUR
            // dieses Fach - das Guthaben bleibt davon unberührt.
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
            // Rückgeld-Fach (rechts): zeigt das aktuelle Guthaben, sobald es
            // größer als 0 ist - egal ob frisch eingeworfen oder Rückgeld aus
            // einem Kauf. Ein Klick ruft dieselbe returnMoney()-Logik auf wie
            // der RÜCKGABE-Button, nur eben als Fach statt als Button.
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
        const SizedBox(height: 8),
        Container(
          // Die Statuszeile zeigt exakt die Meldung aus MachineState. Dadurch
          // entscheidet die Logik, welcher fachliche Zustand kommuniziert wird.
          height: 44,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.grey.shade200,
          child: Text(state.statusMessage),
        ),
      ],
    );
  }
}

/// Rechtes Bedienfeld für Geld, Fachauswahl und Kaufaktionen (Desktop).
///
/// Diese Klasse übersetzt Klicks in Methodenaufrufe am Service. Sie führt keine
/// Preis- oder Bestandsberechnungen selbst durch. Nur für Desktop-Breiten -
/// siehe [MobileMachine] für die schmale Variante mit `Wrap` statt fester
/// `GridView`-Höhen.
class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key, required this.state, required this.service});

  /// Zustand für Guthaben und ausgewählte Produkttaste.
  final MachineState state;

  /// Geschäftslogik, an die sämtliche Eingaben weitergegeben werden.
  final VendingMachineService service;

  /// Startet einen Kauf und zeigt fachliche Fehler als SnackBar an.
  ///
  /// Erfolgreiche Käufe benötigen keine zusätzliche SnackBar, weil der Service
  /// die Statuszeile im [MachineState] aktualisiert. `context.mounted` schützt
  /// davor, nach einem asynchronen Aufruf einen bereits entfernten Screen zu
  /// verwenden.
  Future<void> _purchase(BuildContext context) async {
    final result = await service.purchase();
    if (!context.mounted || result.isSuccess) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  /// Bricht den Vorgang ab und informiert über tatsächlich zurückgegebenes Geld.
  /// Bei einem Rückgabebetrag von null ist keine Meldung nötig.
  void _returnMoney(BuildContext context) {
    final cents = service.returnMoney();
    if (cents == 0) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$cents Cent zurückgegeben.')));
  }

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
              // Nur die Darstellung ist formatiert. Der Service verwaltet den
              // zugrunde liegenden Betrag weiterhin als int in Cent.
              state.formattedCredit,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text('Geld einwerfen'),
            const SizedBox(height: 6),
            SizedBox(
              // War 72 - reichte rechnerisch nicht ganz für 2 Zeilen mit
              // 5 Münzsorten (3+2 pro Zeile), sodass der untere Rand der
              // Buttons hauchdünn abgeschnitten wurde.
              height: 82,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.8,
                children: coinButtons.entries.map((coin) {
                  return OutlinedButton(
                    // Das Frontend übergibt nur den gewählten Münzwert. Prüfung
                    // und Addition sind Aufgabe des Services.
                    onPressed: () => service.insertMoney(coin.value),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(coin.key),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Produktauswahl'),
            const SizedBox(height: 6),
            SizedBox(
              // War 120 - reichte rechnerisch nicht ganz für 3 Zeilen mit
              // 12 Produkten (4 pro Zeile), gleicher Grund wie beim
              // Münzraster oben.
              height: 132,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.2,
                children: state.products.map((product) {
                  // Der Vergleich erfolgt über die stabile technische ID und
                  // markiert genau eine aktuell gewählte Fachnummer.
                  final selected = state.selectedProductId == product.id;
                  return OutlinedButton(
                    onPressed: () => service.selectProduct(product.id),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                    ),
                    child: Text(product.id.toString()),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            FilledButton(
              // Der asynchrone Ablauf bleibt in _purchase gebündelt, damit der
              // Widgetbaum übersichtlich bleibt.
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
      ),
    );
  }
}