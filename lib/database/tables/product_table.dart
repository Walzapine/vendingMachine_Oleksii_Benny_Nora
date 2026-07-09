import 'package:sqflite/sqflite.dart';
import '../constants.dart';

class ProductsTable {
  /// Products Tabele wird erstellt
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableProducts} (
        ${DatabaseConstants.columnProductId} INTEGER PRIMARY KEY,
        ${DatabaseConstants.columnProductName} TEXT NOT NULL,
        ${DatabaseConstants.columnProductPrice} REAL NOT NULL,
        ${DatabaseConstants.columnProductStock} INTEGER NOT NULL,
        ${DatabaseConstants.columnProductEmoji} TEXT NOT NULL

      );
    ''');
  }

  /// Fügt Produktdaten hinzu
  static Future<void> insertInitialData(Database db) async {
    final products = [
      {'id': 1, 'name': 'Chips', 'price': 1.80, 'stock': 8, 'emoji': '🥔'},
      {'id': 2, 'name': 'Schokolade', 'price': 1.50, 'stock': 5, 'emoji': '🍫'},
      {'id': 3, 'name': 'Cracker', 'price': 1.30, 'stock': 6, 'emoji': '🍘'},
      {'id': 4, 'name': 'Nüsse', 'price': 1.60, 'stock': 4, 'emoji': '🥜'},
      {'id': 5, 'name': 'Keks', 'price': 1.10, 'stock': 9, 'emoji': '🍪'},
      {'id': 6, 'name': 'Bonbons', 'price': 1.00, 'stock': 7, 'emoji': '🍬'},
      {'id': 7, 'name': 'Apfel', 'price': 0.90, 'stock': 5, 'emoji': '🍎'},
      {'id': 8, 'name': 'Riegel', 'price': 1.40, 'stock': 3, 'emoji': '🍫'},
      {'id': 9, 'name': 'Wasser', 'price': 1.20, 'stock': 10, 'emoji': '💧'},
      {'id': 10, 'name': 'Cola', 'price': 2.00, 'stock': 0, 'emoji': '🥤'},
      {'id': 11, 'name': 'Saft', 'price': 1.70, 'stock': 5, 'emoji': '🧃'},
      {'id': 12, 'name': 'Eistee', 'price': 180, 'stock': 6, 'emoji': '🧋'},
    ];

    for (var product in products) {
      await db.insert(
        DatabaseConstants.tableProducts,
        product,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
