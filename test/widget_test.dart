import 'package:flutter_test/flutter_test.dart';
import 'package:snackautomat/main.dart';
import 'package:snackautomat/mock/mock_vending_machine_service.dart';

/// Widgettests für die wichtigsten sichtbaren Frontend-Verträge.
///
/// Es werden absichtlich keine Pixel oder exakten Farben geprüft. Die Tests
/// bleiben dadurch gültig, wenn Benni das einfache Design weiterentwickelt,
/// solange die wesentlichen Bedienbereiche erhalten bleiben.
void main() {
  testWidgets('zeigt die Automatenansicht', (tester) async {
    // Für Widgettests wird dieselbe Service-Schnittstelle wie in der echten App
    // injiziert. So benötigt der Screen keine versteckten globalen Abhängigkeiten.
    final service = MockVendingMachineService();
    await tester.pumpWidget(SnackautomatApp(vendingService: service));

    // Diese Texte stehen stellvertretend für Kopfzeile, Produktbereich,
    // Bedienfeld, Ausgabefach und den Ausverkauft-Zustand.
    expect(find.text('SNACKAUTOMAT'), findsOneWidget);
    expect(find.text('Chips'), findsOneWidget);
    expect(find.text('Guthaben'), findsOneWidget);
    expect(find.text('AUSGABEFACH'), findsOneWidget);
    expect(find.text('Ausverkauft'), findsOneWidget);
  });

  testWidgets('Adminsymbol navigiert zum Admin-Bereich', (tester) async {
    final service = MockVendingMachineService();
    await tester.pumpWidget(SnackautomatApp(vendingService: service));

    // Der Tooltip ist stabiler als die Suche nach einem bestimmten Icon und
    // verbessert gleichzeitig die Barrierefreiheit der echten Oberfläche.
    await tester.tap(find.byTooltip('Adminbereich'));
    // pumpAndSettle statt pump: Navigator.push löst eine Übergangsanimation
    // aus, die erst vollständig abgeschlossen sein muss, bevor der neue
    // Screen (mit seinem eigenen AppBar-Titel) im Widget-Baum zu finden ist.
    await tester.pumpAndSettle();

    // Der AdminScreen hat den AppBar-Titel "Admin-Bereich" - taucht er auf,
    // hat die Navigation tatsächlich stattgefunden (statt nur eine SnackBar
    // zu zeigen, wie es früher der Fall war).
    expect(find.text('Admin-Bereich'), findsOneWidget);
  });

  testWidgets('Zurück-Button im Admin-Bereich führt zum Verkaufsbildschirm zurück', (
    tester,
  ) async {
    final service = MockVendingMachineService();
    await tester.pumpWidget(SnackautomatApp(vendingService: service));

    await tester.tap(find.byTooltip('Adminbereich'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zurück zum Verkauf'));
    await tester.pumpAndSettle();

    // Nach dem Zurücknavigieren sollte wieder der Verkaufsbildschirm sichtbar
    // sein - ein einfacher Rundweg-Test (hin und zurück).
    expect(find.text('SNACKAUTOMAT'), findsOneWidget);
  });
}