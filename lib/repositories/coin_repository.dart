import '../models/coin.dart';
import '../database/database_helper.dart';
import '../database/constants.dart';

/// Repositories bilden eine Schicht zwischen DatabaseHelper und Providern. Sie lesen/schreiben DB

class CoinRepository {
  final DatabaseHelper _databaseHelper;

  CoinRepository(this._databaseHelper);

  Future<List<Coin>> getAllCoins() async {
    final db = await _databaseHelper.database;
    final result = await db?.query(DatabaseConstants.tableCoins);
    return result!.map((json) => Coin.fromJson(json)).toList();
  }

  Future<Coin?> getCoinById(int id) async {
    final db = await _databaseHelper.database;
    final result = await db?.query(
      DatabaseConstants.tableCoins,
      where: '${DatabaseConstants.columnCoinId} = ?',
      whereArgs: [id],
    );
    if (result!.isEmpty) return null;
    return Coin.fromJson(result.first);
  }

  Future<void> updateCoinQuantity(int coinId, int newQuantity) async {
    final db = await _databaseHelper.database;
    await db?.update(
      DatabaseConstants.tableCoins,
      {DatabaseConstants.columnCoinQuantity: newQuantity},
      where: '${DatabaseConstants.columnCoinId} = ?',
      whereArgs: [coinId],
    );
  }

  Future<void> updateCoin(Coin coin) async {
    final db = await _databaseHelper.database;
    await db?.update(
      DatabaseConstants.tableCoins,
      coin.toJson(),
      where: '${DatabaseConstants.columnCoinId} = ?',
      whereArgs: [coin.id],
    );
  }

  Future<void> deleteCoin(int coinId) async {
    final db = await _databaseHelper.database;
    await db?.delete(
      DatabaseConstants.tableCoins,
      where: '${DatabaseConstants.columnCoinId} = ?',
      whereArgs: [coinId],
    );
  }
}
