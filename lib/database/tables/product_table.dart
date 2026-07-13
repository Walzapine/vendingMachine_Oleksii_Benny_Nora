import 'package:sqflite/sqflite.dart';
import '../constants.dart';

class ProductsTable {
  /// Products Tabelle wird erstellt.
  ///
  /// price ist jetzt INTEGER (ganze Cent) statt REAL (Euro als Kommazahl) -
  /// siehe product.dart für die Begründung (Rundungsfehler bei Geldbeträgen
  /// vermeiden).
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableProducts} (
        ${DatabaseConstants.columnProductId} INTEGER PRIMARY KEY,
        ${DatabaseConstants.columnProductName} TEXT NOT NULL,
        ${DatabaseConstants.columnProductPrice} INTEGER NOT NULL,
        ${DatabaseConstants.columnProductStock} INTEGER NOT NULL,
        ${DatabaseConstants.columnProductEmoji} TEXT NOT NULL

      );
    ''');
  }

  /// Fügt Produktdaten hinzu. Preise jetzt in ganzen Cent (180 statt 1.80).
  static Future<void> insertInitialData(Database db) async {
    final products = [
      {'id': 1, 'name': 'Chips', 'price': 180, 'stock': 8, 'emoji': '🥔'},
      {'id': 2, 'name': 'Schokolade', 'price': 150, 'stock': 5, 'emoji': '🍫'},
      {'id': 3, 'name': 'Cracker', 'price': 130, 'stock': 6, 'emoji': '🍘'},
      {'id': 4, 'name': 'Nüsse', 'price': 160, 'stock': 4, 'emoji': '🥜'},
      {'id': 5, 'name': 'Keks', 'price': 110, 'stock': 9, 'emoji': '🍪'},
      {'id': 6, 'name': 'Bonbons', 'price': 100, 'stock': 7, 'emoji': '🍬'},
      {'id': 7, 'name': 'Apfel', 'price': 90, 'stock': 5, 'emoji': '🍎'},
      {'id': 8, 'name': 'Riegel', 'price': 140, 'stock': 3, 'emoji': '🍫'},
      {'id': 9, 'name': 'Wasser', 'price': 120, 'stock': 10, 'emoji': '💧'},
      {'id': 10, 'name': 'Cola', 'price': 200, 'stock': 0, 'emoji': '🥤'},
      {'id': 11, 'name': 'Saft', 'price': 170, 'stock': 5, 'emoji': '🧃'},
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