import 'package:sqflite/sqflite.dart';
import '../constants.dart';

class CoinsTable {
  /// Coins Tabele wird erstellt
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCoins} (
        ${DatabaseConstants.columnCoinId} INTEGER PRIMARY KEY,
        ${DatabaseConstants.columnCoinCurrency} TEXT NOT NULL,
        ${DatabaseConstants.columnCoinValue} REAL NOT NULL,
        ${DatabaseConstants.columnCoinQuantity} INTEGER NOT NULL
      );
    ''');
  }

  /// Fügt Coinsdaten hinzu
  static Future<void> insertInitialData(Database db) async {
    final coins = [
      {'id': 1, 'currency': 'EUR', 'value': 0.05, 'quantity': 100},
      {'id': 2, 'currency': 'EUR', 'value': 0.10, 'quantity': 80},
      {'id': 3, 'currency': 'EUR', 'value': 0.20, 'quantity': 60},
      {'id': 4, 'currency': 'EUR', 'value': 0.50, 'quantity': 50},
      {'id': 5, 'currency': 'EUR', 'value': 1.00, 'quantity': 40},
      {'id': 6, 'currency': 'EUR', 'value': 2.00, 'quantity': 20},
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
