/// Table names
class DatabaseConstants {
  // Products table
  static const String tableProducts = 'products';
  static const String columnProductId = 'id';
  static const String columnProductName = 'name';
  static const String columnProductPrice = 'price';
  static const String columnProductStock = 'stock';

  // Coins table
  static const String tableCoins = 'coins';
  static const String columnCoinId = 'id';
  static const String columnCoinCurrency = 'currency';
  static const String columnCoinValue = 'value';
  static const String columnCoinQuantity = 'quantity';

  // DB version
  static const int databaseVersion = 1;
  static const String databaseName = 'snackautomat.db';
}
