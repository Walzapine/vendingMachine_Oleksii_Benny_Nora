import '../models/coin.dart';

/// Statische Beispieldaten für den Münzbestand der Kasse.
///
/// Simuliert das, was später aus der `coins`-Tabelle geladen wird (siehe
/// `constants.dart`). `valueInCents` ist der Geldwert in ganzen Cent.
///
/// IDs und Werte sind bewusst identisch zu
/// `CoinsTable.insertInitialData` in `coins_table.dart` gehalten, damit Mock-
/// und echte DB-Daten nicht auseinanderlaufen (vorher hatte der Mock nur 5,
/// die DB aber 6 Münzsorten inklusive 5 Cent).
const mockCoins = <Coin>[
  Coin(id: 1, currency: 'EUR', valueInCents: 5, quantity: 100),
  Coin(id: 2, currency: 'EUR', valueInCents: 10, quantity: 80),
  Coin(id: 3, currency: 'EUR', valueInCents: 20, quantity: 60),
  Coin(id: 4, currency: 'EUR', valueInCents: 50, quantity: 50),
  Coin(id: 5, currency: 'EUR', valueInCents: 100, quantity: 40),
  Coin(id: 6, currency: 'EUR', valueInCents: 200, quantity: 20),
];