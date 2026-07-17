import '../models/coin.dart';
import '../models/machine_state.dart';
import '../models/product.dart';
import '../models/purchase_result.dart';
import '../logic/purchase_logic.dart';
import '../repositories/product_repository.dart';
import '../repositories/coin_repository.dart';
import '../database/database_helper.dart';
import 'vending_machine_service.dart';

/// Echte Implementierung der Automatenlogik mit SQLite-Persistanz.
///
/// Im Unterschied zu [MockVendingMachineService] speichert diese Klasse
/// alle Änderungen sofort in der Datenbank. Beim nächsten App-Start
/// sind die Bestände erhalten.
///
/// Initialisierung:
/// ```dart
/// final service = VendingMachineServiceImpl(
///   productRepository: ProductRepository(DatabaseHelper()),
///   coinRepository: CoinRepository(DatabaseHelper()),
///   databaseHelper: DatabaseHelper(),
/// );
/// await service.initialize();  // ← WICHTIG!
/// ```
class VendingMachineServiceImpl extends VendingMachineService {
  /// Repositories für Datenbankzugriff.
  final ProductRepository productRepository;
  final CoinRepository coinRepository;
  final DatabaseHelper databaseHelper;

  /// Interne, veränderbare Listen (im RAM für Performance).
  /// Sie werden mit Werten aus der DB initialisiert.
  late List<Product> _products;
  late List<Coin> _coins;

  /// Guthaben, Auswahl und Zustand (wie in MockService).
  int _creditInCents = 0;
  int? _selectedProductId;
  String _statusMessage = 'Bereit. Bitte Produkt auswählen.';
  Product? _dispensedProduct;

  /// Constructor mit Dependency Injection.
  VendingMachineServiceImpl({
    required this.productRepository,
    required this.coinRepository,
    required this.databaseHelper,
  });

  /// WICHTIG: Muss nach dem Constructor aufgerufen werden!
  /// Lädt Produkte und Münzen aus der Datenbank.
  Future<void> initialize() async {
    _products = await productRepository.getAllProducts();
    _coins = await coinRepository.getAllCoins();
    notifyListeners();
  }

  /// Liefert unveränderlichen Zustand an UI.
  @override
  MachineState get state => MachineState(
    products: List.unmodifiable(_products),
    creditInCents: _creditInCents,
    selectedProductId: _selectedProductId,
    statusMessage: _statusMessage,
    dispensedProduct: _dispensedProduct,
  );

  /// Münzen-Liste für Admin-Bereich.
  @override
  List<Coin> get coins => List.unmodifiable(_coins);

  /// Fügt Guthaben hinzu (wie MockService).
  @override
  void insertMoney(int cents) {
    _creditInCents += cents;
    _statusMessage = 'Geld eingeworfen.';
    notifyListeners();
  }

  /// Wählt Produkt aus.
  @override
  void selectProduct(int productId) {
    final product = _products.firstWhere((item) => item.id == productId);
    _selectedProductId = product.id;
    _statusMessage = '${product.name} ausgewählt.';
    notifyListeners();
  }

  /// Kauft Produkt und speichert SOFORT in DB!
  /// Das ist der große Unterschied zu MockService.
  @override
  Future<PurchaseResult> purchase() async {
    final attempt = PurchaseLogic.evaluatePurchase(
      products: _products,
      selectedProductId: _selectedProductId,
      creditInCents: _creditInCents,
      trayOccupied: _dispensedProduct != null,
    );

    if (attempt.isSuccess) {
      // Ersetze Produkt in RAM-Liste
      _products[attempt.productIndex!] = attempt.updatedProduct!;
      _dispensedProduct = attempt.updatedProduct;
      _creditInCents = attempt.changeInCents;
      _selectedProductId = null;

      // 🔴 WICHTIG: Speichere SOFORT in DB!
      await productRepository.updateProductStock(
        attempt.updatedProduct!.id,
        attempt.updatedProduct!.stock,
      );
    }

    _statusMessage = attempt.message;
    notifyListeners();

    return attempt.toPurchaseResult();
  }

  /// Gibt Produkt aus dem Fach zurück.
  @override
  void collectProduct() {
    _dispensedProduct = null;
    _statusMessage = 'Bereit. Bitte Produkt auswählen.';
    notifyListeners();
  }

  /// Gibt Guthaben zurück.
  @override
  int returnMoney() {
    final returnedMoney = _creditInCents;
    _creditInCents = 0;
    _selectedProductId = null;
    _statusMessage = 'Geld wurde zurückgegeben.';
    notifyListeners();
    return returnedMoney;
  }

  /// Erhöht Münz-Bestand und speichert in DB.
  @override
  void increaseCoinQuantity(int coinId) {
    print('🔵 DEBUG: increaseCoinQuantity($coinId) aufgerufen');

    try {
      // Finde die Münze
      final coinIndex = _coins.indexWhere((c) => c.id == coinId);
      if (coinIndex == -1) {
        print('❌ Münze nicht gefunden: $coinId');
        return;
      }

      final oldCoin = _coins[coinIndex];
      print('🔵 DEBUG: Old coin: $oldCoin');

      // Erhöhe um 1
      final newCoin = oldCoin.copyWith(quantity: oldCoin.quantity + 1);

      // Update in RAM
      _coins[coinIndex] = newCoin;
      print('✅ DEBUG: New coin in RAM: $newCoin');

      // Speichere in DB (asynchron, kein await)
      coinRepository.updateCoinQuantity(coinId, newCoin.quantity).catchError((
        e,
      ) {
        print('❌ DB Error: $e');
      });

      // Benachrichtige UI!
      notifyListeners();
      print('✅ DEBUG: notifyListeners() aufgerufen');
    } catch (e) {
      print('❌ Exception in increaseCoinQuantity: $e');
    }
  }

  /// Vermindert Münz-Bestand und speichert in DB.
  @override
  void decreaseCoinQuantity(int coinId) {
    print('🔵 DEBUG: decreaseCoinQuantity($coinId) aufgerufen');

    try {
      // Finde die Münze
      final coinIndex = _coins.indexWhere((c) => c.id == coinId);
      if (coinIndex == -1) {
        print('❌ Münze nicht gefunden: $coinId');
        return;
      }

      final oldCoin = _coins[coinIndex];
      print('🔵 DEBUG: Old coin: $oldCoin');

      // Prüfe ob Bestand > 0
      if (oldCoin.quantity <= 0) {
        print('❌ Bestand ist 0, kann nicht verringern!');
        return;
      }

      // Vermindere um 1
      final newCoin = oldCoin.copyWith(quantity: oldCoin.quantity - 1);

      // Update in RAM
      _coins[coinIndex] = newCoin;
      print('✅ DEBUG: New coin in RAM: $newCoin');

      // Speichere in DB (asynchron, kein await)
      coinRepository.updateCoinQuantity(coinId, newCoin.quantity).catchError((
        e,
      ) {
        print('❌ DB Error: $e');
      });

      // Benachrichtige UI!
      notifyListeners();
      print('✅ DEBUG: notifyListeners() aufgerufen');
    } catch (e) {
      print('❌ Exception in decreaseCoinQuantity: $e');
    }
  }
}
