import '../models/product.dart';
import '../database/database_helper.dart';
import '../database/constants.dart';

/// Repositories bilden eine Schicht zwischen DatabaseHelper und Providern. Sie lesen/schreiben DB

class ProductRepository {
  final DatabaseHelper _databaseHelper;

  ProductRepository(this._databaseHelper);

  get database => null;

  Future<List<Product>> getAllProducts() async {
    final db = await _databaseHelper.database;
    final result = await db?.query(DatabaseConstants.tableProducts);
    return result!.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await _databaseHelper.database;
    final result = await db?.query(
      DatabaseConstants.tableProducts,
      where: '${DatabaseConstants.columnProductId} = ?',
      whereArgs: [id],
    );
    if (result!.isEmpty) return null;
    return Product.fromJson(result.first);
  }

  Future<void> updateProductStock(int productId, int newStock) async {
    final db = await _databaseHelper.database;
    await db?.update(
      DatabaseConstants.tableProducts,
      {DatabaseConstants.columnProductStock: newStock},
      where: '${DatabaseConstants.columnProductId} = ?',
      whereArgs: [productId],
    );
  }

  Future<void> updateProduct(Product product) async {
    final db = await _databaseHelper.database;
    await db?.update(
      DatabaseConstants.tableProducts,
      product.toJson(),
      where: '${DatabaseConstants.columnProductId} = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(int productId) async {
    final db = await _databaseHelper.database;
    await db?.delete(
      DatabaseConstants.tableProducts,
      where: '${DatabaseConstants.columnProductId} = ?',
      whereArgs: [productId],
    );
  }
}
