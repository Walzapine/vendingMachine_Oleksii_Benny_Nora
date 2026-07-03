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
        ${DatabaseConstants.columnProductStock} INTEGER NOT NULL
      );
    ''');
  }

  /// Fügt Produktdaten hinzu
  static Future<void> insertInitialData(Database db) async {
    final products = [
      {
        'id': 1,
        'name': 'Chips',
        'price': 2.50,
        'stock': 20,
      },
      {
        'id': 2,
        'name': 'Cola',
        'price': 2.00,
        'stock': 15,
      },
      {
        'id': 3,
        'name': 'Cookies',
        'price': 1.50,
        'stock': 25,
      },
      {
        'id': 4,
        'name': 'Chocolate',
        'price': 3.50,
        'stock': 10,
      },
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