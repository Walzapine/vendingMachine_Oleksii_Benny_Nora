import 'package:sqflite/sqflite.dart';
import '../constants.dart';

class CoinsTable {
  /// Coins Tabelle wird erstellt.
  ///
  /// value ist jetzt INTEGER (ganze Cent) statt REAL (Euro als Kommazahl) -
  /// gleicher Grund wie bei der Products-Tabelle (Rundungsfehler bei
  /// Geldbeträgen vermeiden).
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCoins} (
        ${DatabaseConstants.columnCoinId} INTEGER PRIMARY KEY,
        ${DatabaseConstants.columnCoinCurrency} TEXT NOT NULL,
        ${DatabaseConstants.columnCoinValue} INTEGER NOT NULL,
        ${DatabaseConstants.columnCoinQuantity} INTEGER NOT NULL
      );
    ''');
  }

  /// Fügt Coinsdaten hinzu. Werte jetzt in ganzen Cent (5 statt 0.05).
  static Future<void> insertInitialData(Database db) async {
    final coins = [
      {'id': 1, 'currency': 'EUR', 'value': 5, 'quantity': 100},
      {'id': 2, 'currency': 'EUR', 'value': 10, 'quantity': 80},
      {'id': 3, 'currency': 'EUR', 'value': 20, 'quantity': 60},
      {'id': 4, 'currency': 'EUR', 'value': 50, 'quantity': 50},
      {'id': 5, 'currency': 'EUR', 'value': 100, 'quantity': 40},
      {'id': 6, 'currency': 'EUR', 'value': 200, 'quantity': 20},
    ];

    for (var coin in coins) {
      await db.insert(
        DatabaseConstants.tableCoins,
        coin,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}