import 'package:flutter_test/flutter_test.dart';
import 'package:snackautomat/logic/purchase_logic.dart';
import 'package:snackautomat/models/product.dart';
import 'package:snackautomat/models/purchase_result.dart';

void main() {
  group('PurchaseLogic', () {
    // Test-Daten — WICHTIG: priceInCents statt price!
    final testProducts = [
      const Product(
        id: 1,
        name: 'Chips',
        priceInCents: 150, // ← 1.50€ = 150¢
        stock: 10,
        emoji: '🥔',
      ),
      const Product(
        id: 2,
        name: 'Cola',
        priceInCents: 200, // ← 2.00€ = 200¢
        stock: 0,
        emoji: '🥤',
      ),
    ];

    // TEST 1: Tray ist besetzt
    test('evaluatePurchase returns trayOccupied when tray has product', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: testProducts,
        selectedProductId: 1,
        creditInCents: 200,
        trayOccupied: true,
      );

      expect(result.status, equals(PurchaseStatus.trayOccupied));
      expect(result.isSuccess, isFalse);
    });

    // TEST 2: Keine Auswahl
    test('evaluatePurchase returns noSelection when no product selected', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: testProducts,
        selectedProductId: null,
        creditInCents: 200,
        trayOccupied: false,
      );

      expect(result.status, equals(PurchaseStatus.noSelection));
      expect(result.isSuccess, isFalse);
    });

    // TEST 3: Produkt existiert nicht
    test('evaluatePurchase returns noSelection when product not found', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: testProducts,
        selectedProductId: 999,
        creditInCents: 200,
        trayOccupied: false,
      );

      expect(result.status, equals(PurchaseStatus.noSelection));
      expect(result.isSuccess, isFalse);
    });

    // TEST 4: Bestand = 0
    test('evaluatePurchase returns outOfStock when product stock is 0', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: testProducts,
        selectedProductId: 2, // Cola mit stock: 0
        creditInCents: 300,
        trayOccupied: false,
      );

      expect(result.status, equals(PurchaseStatus.outOfStock));
      expect(result.isSuccess, isFalse);
    });

    // TEST 5: Guthaben reicht nicht
    test('evaluatePurchase returns insufficientCredit when credit too low', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: testProducts,
        selectedProductId: 1, // Chips = 150¢
        creditInCents: 100, // Nur 100¢!
        trayOccupied: false,
      );

      expect(result.status, equals(PurchaseStatus.insufficientCredit));
      expect(result.isSuccess, isFalse);
    });

    // TEST 6: Erfolgreich!
    test('evaluatePurchase returns success when all checks pass', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: testProducts,
        selectedProductId: 1, // Chips = 150¢
        creditInCents: 200, // 200¢ → Rückgeld: 50¢
        trayOccupied: false,
      );

      expect(result.status, equals(PurchaseStatus.success));
      expect(result.isSuccess, isTrue);
      expect(result.changeInCents, equals(50));
    });

    // TEST 7: Exakter Betrag
    test('evaluatePurchase returns 0 change when exact amount paid', () {
      final result = PurchaseLogic.evaluatePurchase(
        products: testProducts,
        selectedProductId: 1, // Chips = 150¢
        creditInCents: 150, // Exakt!
        trayOccupied: false,
      );

      expect(result.status, equals(PurchaseStatus.success));
      expect(result.changeInCents, equals(0));
    });
  });
}
