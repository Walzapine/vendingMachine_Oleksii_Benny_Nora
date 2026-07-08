import '../models/coin.dart';

/// Statische Beispieldaten für den Münzbestand der Kasse.
///
/// Simuliert das, was später aus der `coins`-Tabelle geladen wird (siehe
/// `constants.dart`). `value` ist der Geldwert in Euro als Münzbezeichnung
/// (z. B. `2.0` für eine 2-Euro-Münze, `0.5` für 50 Cent).
const mockCoins = <Coin>[
  Coin(id: 1, currency: 'EUR', value: 2.0, quantity: 10),
  Coin(id: 2, currency: 'EUR', value: 1.0, quantity: 10),
  Coin(id: 3, currency: 'EUR', value: 0.5, quantity: 10),
  Coin(id: 4, currency: 'EUR', value: 0.2, quantity: 10),
  Coin(id: 5, currency: 'EUR', value: 0.1, quantity: 10),
];