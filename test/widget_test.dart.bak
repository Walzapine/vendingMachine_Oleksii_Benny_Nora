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

  testWidgets('Adminsymbol zeigt nur einen Arbeitshinweis', (tester) async {
    final service = MockVendingMachineService();
    await tester.pumpWidget(SnackautomatApp(vendingService: service));

    // Der Tooltip ist stabiler als die Suche nach einem bestimmten Icon und
    // verbessert gleichzeitig die Barrierefreiheit der echten Oberfläche.
    await tester.tap(find.byTooltip('Adminbereich'));
    await tester.pump();

    // Bis zur späteren Admin-Implementierung darf nur dieser Hinweis erscheinen.
    expect(find.text('Der Adminbereich ist noch in Arbeit.'), findsOneWidget);
  });
}
