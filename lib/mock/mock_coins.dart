import '../models/coin.dart';

/// Statische Beispieldaten für den Münzbestand der Kasse.
///
/// Simuliert das, was später aus der `coins`-Tabelle geladen wird (siehe
/// `constants.dart`). `valueInCents` ist der Geldwert in ganzen Cent
/// (z. B. `200` für eine 2-Euro-Münze, `50` für 50 Cent).
const mockCoins = <Coin>[
  Coin(id: 1, currency: 'EUR', valueInCents: 200, quantity: 10),
  Coin(id: 2, currency: 'EUR', valueInCents: 100, quantity: 10),
  Coin(id: 3, currency: 'EUR', valueInCents: 50, quantity: 10),
  Coin(id: 4, currency: 'EUR', valueInCents: 20, quantity: 10),
  Coin(id: 5, currency: 'EUR', valueInCents: 10, quantity: 10),
];