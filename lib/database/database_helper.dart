import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'constants.dart';
import 'tables/product_table.dart';
import 'tables/coins_table.dart';

/// DatabaseHelper macht DB beim App-Start sichtbar
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database?> get database async {
    _database ??= await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    // Für Windows desktop nötig FFI
    sqflite_ffi.sqfliteFfiInit();

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    // 🔴 WICHTIG: Zeige den Pfad!
    log('📁 Datenbank-Pfad: $path');
    print('📁 Datenbank-Pfad: $path'); // Auch in Console sichtbar

    return openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    log('🔧 Creating database tables...');

    await ProductsTable.create(db);
    await CoinsTable.create(db);

    await ProductsTable.insertInitialData(db);
    await CoinsTable.insertInitialData(db);

    log('✅ Database initialized successfully!');
  }

  Future<void> close() async {
    _database!.close();
  }
}
