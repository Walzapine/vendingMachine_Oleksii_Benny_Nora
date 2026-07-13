import 'package:flutter/material.dart';
import 'package:snackautomat/models/machine_state.dart';
import '../services/vending_machine_service.dart';
import '../widgets/product_card.dart';
import 'admin_screen.dart';

/// Ab dieser Breite (in logischen Pixeln) wird das Desktop-Layout mit der
/// festen, skalierten Automatenfläche verwendet. Darunter (z. B. Smartphone
/// im Hochformat) greift stattdessen das gestapelte Mobile-Layout.
const double _mobileBreakpoint = 700;

/// Zweite Stufe innerhalb des Mobile-Layouts: Unterhalb dieser Breite gilt
/// ein Bildschirm als "sehr schmal" (z. B. iPhone SE, kleine Android-Handys).
/// Dort werden Spaltenzahl, Abstände und Schriftgrößen nochmal verkleinert,
/// statt bei jeder Breite unterhalb von [_mobileBreakpoint] gleich auszusehen.
const double _compactMobileBreakpoint = 420;

/// Verfügbare Münzwerte für die "Geld einwerfen"-Buttons.
///
/// Zentral hier auf Modulebene definiert (statt lokal in einem Widget),
/// damit Desktop- ([_ControlPanel]) und Mobile-Layout ([_MobileMachine])
/// dieselbe Liste verwenden und sie nicht zweimal gepflegt werden muss.
const _coinButtons = {
  '2 €': 200,
  '1 €': 100,
  '50 ct': 50,
  '20 ct': 20,
  '10 ct': 10,
};

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
        // LayoutBuilder gibt uns die tatsächlich verfügbare Breite. Damit
        // entscheiden wir, welches der beiden Layouts gebaut wird - das ist
        // der eigentliche "Layoutwechsel" (zusätzlich zur Skalierung, die
        // weiterhin innerhalb des Desktop-Zweigs passiert).
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < _mobileBreakpoint;

            if (isMobile) {
              // Mobile: KEIN FittedBox, KEINE feste Pixelgröße. Die Bereiche
              // ordnen sich natürlich untereinander an, die Seite scrollt bei
              // Bedarf. Das verhindert, dass auf schmalen Bildschirmen alles
              // nur winzig klein skaliert würde.
              //
              // Die tatsächliche Breite wird durchgereicht, damit
              // _MobileMachine selbst zwischen "normal" und "sehr schmal"
              // unterscheiden und sich fein abgestuft anpassen kann (statt
              // eines einzigen harten Schnitts bei _mobileBreakpoint).
              return AnimatedBuilder(
                animation: vendingService,
                builder: (context, _) => _MobileMachine(
                  state: vendingService.state,
                  service: vendingService,
                  width: constraints.maxWidth,
                ),
              );
            }

            // Desktop: wie bisher - feste Automatenfläche, die per FittedBox
            // proportional auf die verfügbare Fenstergröße skaliert wird.
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 940,
                    height: 630,
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
            );
          },
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
              child: _TrayButton(
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
              child: _TrayButton(
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

/// Ein einzelnes, antippbares Fach (Produkt- oder Rückgeld-Fach).
///
/// Beide Fächer sehen gleich aus und verhalten sich gleich (gefüllt = bunt
/// und antippbar, leer = grau und nicht antippbar), unterscheiden sich nur in
/// Inhalt und Aktion. Deshalb dieses eine gemeinsame Widget statt Duplikat.
class _TrayButton extends StatelessWidget {
  const _TrayButton({
    required this.isFilled,
    required this.filledColor,
    required this.emptyColor,
    required this.label,
    required this.onTap,
  });

  /// Ob gerade etwas im Fach liegt (Produkt bzw. abholbares Guthaben).
  final bool isFilled;

  /// Hintergrundfarbe, wenn das Fach gefüllt ist.
  final Color filledColor;

  /// Hintergrundfarbe, wenn das Fach leer ist.
  final Color emptyColor;

  /// Anzuzeigender Text.
  final String label;

  /// Aktion bei Klick. `null`, wenn das Fach leer ist - dadurch reagiert
  /// InkWell gar nicht erst auf Taps und braucht keine eigene Prüfung.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Material(
        color: isFilled ? filledColor : emptyColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Layout für schmale Bildschirme (z. B. Smartphone im Hochformat).
///
/// Anders als [_Machine] (Desktop) hat dieses Layout KEINE feste Pixelgröße
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
/// Enthält bewusst eigenen Code statt [_ProductArea]/[_ControlPanel]
/// wiederzuverwenden: Beide setzen intern `Expanded` ein, was einen
/// begrenzten Elternhöhen-Kontext braucht. Innerhalb eines
/// `SingleChildScrollView` ist die Höhe aber unbegrenzt - `Expanded` würde
/// dort einen Laufzeitfehler auslösen.
class _MobileMachine extends StatelessWidget {
  const _MobileMachine({
    required this.state,
    required this.service,
    required this.width,
  });

  final MachineState state;
  final VendingMachineService service;

  /// Tatsächlich verfügbare Breite, vom LayoutBuilder in [ProductScreen]
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
    // Unterhalb von _compactMobileBreakpoint gilt der Bildschirm als "sehr
    // schmal" (z. B. iPhone SE) - dort wird nochmal enger/kleiner gebaut als
    // im "normalen" Mobile-Bereich (z. B. Pixel, größere Handys).
    final isCompact = width < _compactMobileBreakpoint;

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
                child: _TrayButton(
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
                child: _TrayButton(
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
          // im Desktop-_ControlPanel, aber mit Wrap statt festen GridView-
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
                    children: _coinButtons.entries.map((coin) {
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
                children: _coinButtons.entries.map((coin) {
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