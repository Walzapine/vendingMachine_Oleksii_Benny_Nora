import 'package:flutter_test/flutter_test.dart';
import 'package:snackautomat/logic/coin_logic.dart';
import 'package:snackautomat/models/coin.dart';

/// Tests für die reine Münzbestand-Logik (Adminbereich).
///
/// Gleiches Muster wie bei purchase_logic_test.dart: CoinLogic braucht kein
/// Flutter und keine Datenbank, deshalb lässt sie sich direkt mit
/// selbstgebauten Testdaten prüfen.
void main() {
  group('CoinLogic.increase', () {
    const testCoin = Coin(
      id: 1,
      currency: 'EUR',
      valueInCents: 100,
      quantity: 5,
    );

    test('Erhöht den Bestand einer existierenden Münze um 1', () {
      final result = CoinLogic.increase(coins: [testCoin], coinId: 1);

      expect(result.isSuccess, true);
      expect(result.updatedCoin.quantity, 6);
      expect(result.coinIndex, 0);
      // Andere Felder bleiben unverändert.
      expect(result.updatedCoin.id, 1);
      expect(result.updatedCoin.valueInCents, 100);
    });

    test('Schlägt fehl, wenn die Münz-ID nicht existiert', () {
      final result = CoinLogic.increase(coins: [testCoin], coinId: 999);

      expect(result.isSuccess, false);
    });

    test('Original-Liste bleibt unverändert (reine Funktion)', () {
      final coins = [testCoin];

      CoinLogic.increase(coins: coins, coinId: 1);

      expect(coins[0].quantity, 5);
    });
  });

  group('CoinLogic.decrease', () {
    const testCoin = Coin(
      id: 1,
      currency: 'EUR',
      valueInCents: 100,
      quantity: 5,
    );
    const emptyCoin = Coin(
      id: 2,
      currency: 'EUR',
      valueInCents: 200,
      quantity: 0,
    );

    test('Verringert den Bestand einer existierenden Münze um 1', () {
      final result = CoinLogic.decrease(coins: [testCoin], coinId: 1);

      expect(result.isSuccess, true);
      expect(result.updatedCoin.quantity, 4);
      expect(result.coinIndex, 0);
    });

    test('Schlägt fehl, wenn der Bestand bereits 0 ist', () {
      final result = CoinLogic.decrease(coins: [emptyCoin], coinId: 2);

      expect(result.isSuccess, false);
    });

    test('Schlägt fehl, wenn die Münz-ID nicht existiert', () {
      final result = CoinLogic.decrease(coins: [testCoin], coinId: 999);

      expect(result.isSuccess, false);
    });

    test('Original-Liste bleibt unverändert (reine Funktion)', () {
      final coins = [testCoin];

      CoinLogic.decrease(coins: coins, coinId: 1);

      expect(coins[0].quantity, 5);
    });
  });

  group('CoinAdjustment', () {
    test('updatedCoin wirft StateError bei Fehlschlag', () {
      const result = CoinAdjustment.failure(message: 'Test');

      expect(() => result.updatedCoin, throwsStateError);
    });

    test('coinIndex wirft StateError bei Fehlschlag', () {
      const result = CoinAdjustment.failure(message: 'Test');

      expect(() => result.coinIndex, throwsStateError);
    });
  });
}