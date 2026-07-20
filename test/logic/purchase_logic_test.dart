import 'package:flutter_test/flutter_test.dart';
import 'package:snackautomat/logic/purchase_logic.dart';
import 'package:snackautomat/models/product.dart';
import 'package:snackautomat/models/purchase_result.dart';

/// Tests für die reine Kauflogik.
///
/// Da PurchaseLogic weder Flutter-Widgets noch eine Datenbank braucht, kann
/// jeder Testfall die Methode direkt mit selbst gebauten Testdaten aufrufen -
/// ohne die App zu starten. Muster pro Test: Arrange (Testdaten vorbereiten),
/// Act (evaluatePurchase aufrufen), Assert (Ergebnis prüfen).
void main() {
  group('PurchaseLogic.evaluatePurchase', () {
    // Wiederverwendete Testprodukte für mehrere Fälle.
    const testProduct = Product(
      id: 1,
      name: 'Testkeks',
      priceInCents: 150,
      stock: 3,
      emoji: '🍪',
    );
    const soldOutProduct = Product(
      id: 2,
      name: 'Ausverkauft',
      priceInCents: 100,
      stock: 0,
      emoji: '🥤',
    );

    test('Erfolgreicher Kauf berechnet Rückgeld korrekt', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: [testProduct],
        selectedProductId: 1,
        creditInCents: 200,
      );

      expect(result.isSuccess, true);
      expect(result.status, PurchaseStatus.success);
      expect(result.changeInCents, 50);
      expect(result.productIndex, 0);
      // Bestand des zurückgegebenen (aktualisierten) Produkts ist um 1
      // reduziert - das Original bleibt aber unverändert (siehe Test weiter
      // unten).
      expect(result.updatedProduct?.stock, 2);
    });

    test('Erfolgreicher Kauf mit exaktem Betrag hat kein Rückgeld', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: [testProduct],
        selectedProductId: 1,
        creditInCents: 150,
      );

      expect(result.isSuccess, true);
      expect(result.changeInCents, 0);
    });

    test('Kein Produkt ausgewählt (selectedProductId ist null)', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: [testProduct],
        selectedProductId: null,
        creditInCents: 200,
      );

      expect(result.isSuccess, false);
      expect(result.status, PurchaseStatus.noSelection);
    });

    test('Ausgewähltes Produkt existiert nicht mehr (ungültige ID)', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: [testProduct],
        selectedProductId: 999, // kommt in der Liste nicht vor
        creditInCents: 200,
      );

      expect(result.isSuccess, false);
      expect(result.status, PurchaseStatus.noSelection);
    });

    test('Ausverkauftes Produkt kann nicht gekauft werden', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: [soldOutProduct],
        selectedProductId: 2,
        creditInCents: 200,
      );

      expect(result.isSuccess, false);
      expect(result.status, PurchaseStatus.outOfStock);
    });

    test('Guthaben reicht nicht aus', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: [testProduct],
        selectedProductId: 1,
        creditInCents: 100, // Preis ist 150
      );

      expect(result.isSuccess, false);
      expect(result.status, PurchaseStatus.insufficientCredit);
    });

    test('Belegtes Ausgabefach blockiert jeden Kauf', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: [testProduct],
        selectedProductId: 1,
        creditInCents: 200, // Guthaben würde reichen
        trayOccupied: true,
      );

      expect(result.isSuccess, false);
      expect(result.status, PurchaseStatus.trayOccupied);
    });

    test('Ausgabefach-Prüfung hat Vorrang vor allen anderen Prüfungen', () {
      // Selbst wenn ZUSÄTZLICH keine Auswahl getroffen wurde, muss
      // trayOccupied als Grund gemeldet werden (Schritt 0 vor Schritt 1).
      final result = PurchaseLogic.evaluatePurchase(
        products: [testProduct],
        selectedProductId: null,
        creditInCents: 0,
        trayOccupied: true,
      );

      expect(result.status, PurchaseStatus.trayOccupied);
    });

    test('Original-Produktliste bleibt unverändert (reine Funktion)', () {
      final products = [testProduct];

      PurchaseLogic.evaluatePurchase(
        products: products,
        selectedProductId: 1,
        creditInCents: 200,
      );

      // evaluatePurchase darf die übergebene Liste nicht verändert haben -
      // der Aufrufer entscheidet selbst, ob/wie er das Ergebnis übernimmt.
      expect(products[0].stock, 3);
    });

    test('toPurchaseResult wandelt einen erfolgreichen Versuch korrekt um', () {
      final attempt = PurchaseLogic.evaluatePurchase(
        products: [testProduct],
        selectedProductId: 1,
        creditInCents: 200,
      );

      final result = attempt.toPurchaseResult();

      expect(result, isA<PurchaseResult>());
      expect(result.status, PurchaseStatus.success);
      expect(result.changeInCents, 50);
    });

    test('toPurchaseResult wandelt einen Fehlschlag korrekt um', () {
      final attempt = PurchaseLogic.evaluatePurchase(
        products: [testProduct],
        selectedProductId: null,
        creditInCents: 200,
      );

      final result = attempt.toPurchaseResult();

      expect(result.isSuccess, false);
      expect(result.changeInCents, 0);
    });
  });
}