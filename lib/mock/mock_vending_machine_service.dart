import '../models/coin.dart';
import '../models/machine_state.dart';
import '../models/product.dart';
import '../models/purchase_result.dart';
import '../services/vending_machine_service.dart';
import 'mock_products.dart';
import 'mock_coins.dart';
import '../logic/purchase_logic.dart';
import '../logic/coin_logic.dart';

/// In-Memory-Implementierung der Automatenlogik für Entwicklung und Tests.
///
/// Diese Klasse speichert alles nur im Arbeitsspeicher. Beim Neustart der App
/// werden Guthaben, Auswahl und Bestände auf die Beispieldaten zurückgesetzt.
/// Sie zeigt den Backendentwicklern, welches Verhalten das Frontend erwartet,
/// ist aber ausdrücklich kein dauerhafter Datenspeicher.
///
/// Austausch gegen das echte Backend:
///
/// 1. Neue Klasse erstellen, die [VendingMachineService] erweitert.
/// 2. Dieselben Methoden fachlich korrekt implementieren.
/// 3. Nach sichtbaren Änderungen `notifyListeners()` aufrufen.
/// 4. In `main.dart` nur die erzeugte Serviceinstanz austauschen.
class MockVendingMachineService extends VendingMachineService {
  /// Erstellt eine veränderbare Arbeitskopie der konstanten Beispieldaten.
  ///
  /// Ohne Kopien würden mehrere Tests oder Serviceinstanzen dieselben Objekte
  /// teilen. Produkte und Münzen selbst bleiben unveränderlich; Änderungen
  /// erfolgen später über die jeweiligen `copyWith`-Methoden.
  MockVendingMachineService()
    : _products = mockProducts.map((product) => product.copyWith()).toList(),
      _coins = mockCoins.map((coin) => coin.copyWith()).toList();

  /// Interne, veränderbare Produktliste. Sie darf nicht direkt an die UI gehen.
  final List<Product> _products;

  /// Interne, veränderbare Münzliste für den Adminbereich.
  final List<Coin> _coins;

  /// Internes Guthaben in Cent. Geldwerte werden nie als `double` berechnet.
  ///
  /// Wichtig: Nach einem erfolgreichen Kauf wird dieser Wert NICHT auf 0
  /// gesetzt, sondern auf das Rückgeld reduziert. Er repräsentiert also immer
  /// den kompletten Betrag, den der Kunde gerade "im Automaten stehen" hat.
  int _creditInCents = 0;

  /// ID des aktuell gewählten Produkts; `null` bedeutet keine Auswahl.
  /// Entspricht [Product.id] (int).
  int? _selectedProductId;

  /// Text, der unter dem Ausgabefach angezeigt wird.
  String _statusMessage = 'Bereit. Bitte Produkt auswählen.';

  /// Produkt, das aktuell physisch im Ausgabefach liegt.
  ///
  /// `null` bedeutet: Fach ist leer. Wird bei einem erfolgreichen Kauf
  /// gesetzt und erst in [collectProduct] wieder auf `null` zurückgesetzt.
  /// Unabhängig vom Guthaben - beide werden getrennt entnommen.
  Product? _dispensedProduct;

  /// Baut bei jedem Zugriff einen unveränderlichen Zustand für das Frontend.
  ///
  /// [List.unmodifiable] verhindert, dass UI-Code versehentlich Bestände direkt
  /// verändert und dadurch die Geschäftslogik umgeht.
  @override
  MachineState get state => MachineState(
    products: List.unmodifiable(_products),
    creditInCents: _creditInCents,
    selectedProductId: _selectedProductId,
    statusMessage: _statusMessage,
    dispensedProduct: _dispensedProduct,
  );

  /// Erhöht das Guthaben und informiert die UI über den neuen Zustand.
  ///
  /// Die Demo vertraut dem übergebenen Wert. Eine Produktionsimplementierung
  /// sollte positive Werte und erlaubte Münzen prüfen.
  @override
  void insertMoney(int cents) {
    _creditInCents += cents;
    _statusMessage = 'Geld eingeworfen.';
    notifyListeners();
  }

  /// Wählt das Produkt mit der ID [productId] aus.
  ///
  /// Vorher hieß diese Methode `selectProductBySlot(String slotCode)` - da
  /// das Product-Modell inzwischen kein `slotCode`-Feld mehr hat, läuft die
  /// Auswahl jetzt direkt über die technische ID.
  ///
  /// `firstWhere` wirft eine Exception, wenn die ID nicht existiert. Für die
  /// festen Mockdaten ist das ausreichend; eine echte Implementierung sollte
  /// das kontrollierter abfangen (z. B. mit `firstWhereOrNull`).
  @override
  void selectProduct(int productId) {
    final product = _products.firstWhere((item) => item.id == productId);
    _selectedProductId = product.id;
    _statusMessage = '${product.name} ausgewählt.';
    notifyListeners();
  }

  /// Führt einen Kaufversuch für das aktuell ausgewählte Produkt aus.
  ///
  /// Die eigentliche fachliche Prüfung (Ausgabefach frei? Auswahl vorhanden?
  /// vorrätig? Guthaben ausreichend?) übernimmt komplett
  /// [PurchaseLogic.evaluatePurchase]. Diese Methode hier ist bewusst schlank
  /// gehalten und kümmert sich nur noch um zwei Dinge, die spezifisch für
  /// DIESE Implementierung sind:
  ///
  /// 1. Das Ergebnis der Prüfung in den eigenen Arbeitsspeicher übernehmen
  ///    (Produktliste, Ausgabefach, Guthaben, Auswahl aktualisieren).
  /// 2. Die UI über `notifyListeners()` benachrichtigen.
  @override
  Future<PurchaseResult> purchase() async {
    final attempt = PurchaseLogic.evaluatePurchase(
      products: _products,
      selectedProductId: _selectedProductId,
      creditInCents: _creditInCents,
      trayOccupied: _dispensedProduct != null,
    );

    if (attempt.isSuccess) {
      _products[attempt.productIndex!] = attempt.updatedProduct!;
      _dispensedProduct = attempt.updatedProduct;
      _creditInCents = attempt.changeInCents;
      _selectedProductId = null;
    }

    _statusMessage = attempt.message;
    notifyListeners();

    return attempt.toPurchaseResult();
  }

  /// Entfernt das Produkt aus dem Ausgabefach.
  ///
  /// Betrifft ausschließlich [_dispensedProduct]. Das Guthaben bleibt davon
  /// komplett unberührt - für dessen Entnahme ist [returnMoney] zuständig.
  @override
  void collectProduct() {
    _dispensedProduct = null;
    _statusMessage = 'Bereit. Bitte Produkt auswählen.';
    notifyListeners();
  }

  /// Setzt das Guthaben auf 0 zurück und liefert den Betrag, der ausgezahlt
  /// wurde.
  @override
  int returnMoney() {
    final returnedMoney = _creditInCents;
    _creditInCents = 0;
    _selectedProductId = null;
    _statusMessage = 'Geld wurde zurückgegeben.';
    notifyListeners();
    return returnedMoney;
  }

  // ---------------------------------------------------------------------
  // Adminbereich (Münzbestand, gemeinsames Coin-Modell)
  // ---------------------------------------------------------------------

  @override
  List<Coin> get coins => List.unmodifiable(_coins);

  /// Erhöht den Bestand einer Münze um 1.
  ///
  /// Die eigentliche Berechnung übernimmt [CoinLogic.increase]. Diese
  /// Methode übernimmt nur das Ergebnis in den eigenen Arbeitsspeicher und
  /// benachrichtigt die UI - exakt dasselbe Muster wie bei [purchase].
  @override
  void increaseCoinQuantity(int coinId) {
    final adjustment = CoinLogic.increase(coins: _coins, coinId: coinId);
    if (adjustment.isSuccess) {
      _coins[adjustment.coinIndex] = adjustment.updatedCoin;
      notifyListeners();
    }
  }

  /// Verringert den Bestand einer Münze um 1, sofern möglich.
  @override
  void decreaseCoinQuantity(int coinId) {
    final adjustment = CoinLogic.decrease(coins: _coins, coinId: coinId);
    if (adjustment.isSuccess) {
      _coins[adjustment.coinIndex] = adjustment.updatedCoin;
      notifyListeners();
    }
  }
}