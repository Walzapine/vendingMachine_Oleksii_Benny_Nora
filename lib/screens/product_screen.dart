import 'package:flutter/material.dart';

import '../models/machine_state.dart';
import '../services/vending_machine_service.dart';
import '../widgets/product_card.dart';

/// Hauptscreen für den normalen Kundenbetrieb des Snackautomaten.
///
/// Der Screen ist bewusst nur für Darstellung und Benutzereingaben zuständig.
/// Er kennt keine konkrete Datenbank und enthält keine Kaufberechnung. Alle
/// Aktionen werden an [vendingService] delegiert.
///
/// Aufbau der Ansicht:
///
/// * Kopfzeile mit Titel und vorbereitetem Adminsymbol,
/// * linke Seite mit Produktraster, Ausgabefach und Status,
/// * rechte Seite mit Guthaben, Münzen, Auswahl und Kaufaktionen.
class ProductScreen extends StatelessWidget {
  /// Erstellt den Screen mit einer injizierten Automatenlogik.
  const ProductScreen({super.key, required this.vendingService});

  /// Abstrakte Verbindung zur Geschäftslogik.
  ///
  /// Der konkrete Typ kann Mock, lokale Datenbank oder API-Backend sein.
  final VendingMachineService vendingService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            // FittedBox skaliert die feste Automatenfläche proportional auf die
            // verfügbare Fenstergröße. Dadurch bleibt die gewünschte Anordnung
            // auf Desktop und kleineren Displays erhalten.
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 940,
                height: 650,
                // AnimatedBuilder hört auf ChangeNotifier-Ereignisse des
                // Services. Nach notifyListeners() wird nur dieser Teil der UI
                // mit dem aktuellen MachineState neu gebaut.
                child: AnimatedBuilder(
                  animation: vendingService,
                  builder: (context, _) => _Machine(
                    state: vendingService.state,
                    service: vendingService,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Zusammensetzung des sichtbaren Automatenrahmens.
///
/// Der führende Unterstrich macht die Klasse dateiprivat. Andere Dateien sollen
/// ausschließlich [ProductScreen] verwenden und nicht dessen interne
/// Layoutbausteine direkt ansprechen.
class _Machine extends StatelessWidget {
  const _Machine({required this.state, required this.service});

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
                  // Der Adminbereich ist absichtlich noch nicht implementiert.
                  // Das Symbol bleibt als sichtbarer Platzhalter erhalten.
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Der Adminbereich ist noch in Arbeit.'),
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
                    child: _ProductArea(state: state, service: service),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ControlPanel(state: state, service: service),
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
class _ProductArea extends StatelessWidget {
  const _ProductArea({required this.state, required this.service});

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
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductCard(
                product: product,
                slotCode: product.slotCode,
                // Die Karte meldet nur die Fachnummer. Suchen, Validieren und
                // Speichern der Auswahl übernimmt der Service.
                onTap: () => service.selectProductBySlot(product.slotCode),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Container(
          // Dies ist zunächst nur die visuelle Position des Ausgabefachs. Eine
          // spätere Animation kann hier ergänzt werden, ohne Kaufcode einzubauen.
          height: 58,
          alignment: Alignment.center,
          color: Colors.grey.shade300,
          child: const Text('AUSGABEFACH'),
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

/// Rechtes Bedienfeld für Geld, Fachauswahl und Kaufaktionen.
///
/// Diese Klasse übersetzt Klicks in Methodenaufrufe am Service. Sie führt keine
/// Preis- oder Bestandsberechnungen selbst durch.
class _ControlPanel extends StatelessWidget {
  const _ControlPanel({required this.state, required this.service});

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
    // Schlüssel sind die sichtbaren Beschriftungen, Werte die an das Backend
    // übergebenen Centbeträge. Neue Münzen können hier zentral ergänzt werden.
    const coins = {
      '2 €': 200,
      '1 €': 100,
      '50 ct': 50,
      '20 ct': 20,
      '10 ct': 10,
    };

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
              height: 72,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.8,
                children: coins.entries.map((coin) {
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
              height: 120,
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
                    onPressed: () =>
                        service.selectProductBySlot(product.slotCode),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                    ),
                    child: Text(product.slotCode),
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
