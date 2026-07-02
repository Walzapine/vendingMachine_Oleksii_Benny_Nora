import 'package:flutter_test/flutter_test.dart';
import 'package:snackautomat/mock/mock_vending_machine_service.dart';
import 'package:snackautomat/models/purchase_result.dart';

/// Tests der Verbindung zwischen Servicevertrag und Demo-Geschäftslogik.
///
/// Diese Tests sind besonders für den Austausch des Mock-Backends wichtig. Die
/// gleiche fachliche Erwartung sollte auch gegen die echte Implementierung
/// getestet werden.
void main() {
  test('Auswahl, Bezahlung und Kauf sind verbunden', () async {
    // Arrange: Jede Prüfung erhält eine neue Instanz, damit kein Zustand aus
    // anderen Tests übernommen wird.
    final service = MockVendingMachineService();

    // Act: Fach A1 kostet 180 Cent. Mit 200 Cent müssen 20 Cent Rückgeld
    // entstehen und der Bestand muss um genau ein Stück sinken.
    service.selectProductBySlot('A1');
    service.insertMoney(200);
    final result = await service.purchase();

    // Assert: Ergebnis, Geldzustand und Bestand werden gemeinsam geprüft. So
    // erkennt der Test auch unvollständige Kaufimplementierungen.
    expect(result.status, PurchaseStatus.success);
    expect(result.changeInCents, 20);
    expect(service.state.creditInCents, 0);
    expect(service.state.products.first.stock, 7);
  });
}
