import '../models/machine_state.dart';
import '../models/product.dart';
import '../models/purchase_result.dart';
import '../services/vending_machine_service.dart';
import 'mock_products.dart';

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
  /// teilen. Die Produkte selbst bleiben unveränderlich; Änderungen erfolgen
  /// später durch [Product.copyWith].
  MockVendingMachineService()
    : _products = mockProducts.map((product) => product.copyWith()).toList();

  /// Interne, veränderbare Produktliste. Sie darf nicht direkt an die UI gehen.
  final List<Product> _products;

  /// Internes Guthaben in Cent. Geldwerte werden nie als `double` berechnet.
  int _creditInCents = 0;

  /// ID des aktuell gewählten Produkts; `null` bedeutet keine Auswahl.
  String? _selectedProductId;

  /// Text, der unter dem Ausgabefach angezeigt wird.
  String _statusMessage = 'Bereit. Bitte Produkt auswählen.';

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

  /// Sucht ein Produkt über seine Fachnummer und merkt seine technische ID.
  ///
  /// Nach der Auswahl werden Statuszeile und Tastenmarkierung aktualisiert.
  /// Die echte Implementierung sollte unbekannte Fachnummern kontrolliert
  /// behandeln; `firstWhere` reicht hier für die festen Mockdaten aus.
  @override
  void selectProductBySlot(String slotCode) {
    final product = _products.firstWhere((item) => item.slotCode == slotCode);
    _selectedProductId = product.id;
    _statusMessage = '${product.name} ausgewählt.';
    notifyListeners();
  }

  /// Führt die vollständige Demo-Kaufprüfung in definierter Reihenfolge aus.
  ///
  /// Reihenfolge:
  ///
  /// 1. Existiert eine Produktauswahl?
  /// 2. Ist das Produkt noch vorrätig?
  /// 3. Reicht das eingeworfene Guthaben?
  /// 4. Bestand um eins reduzieren.
  /// 5. Rückgeld berechnen, Guthaben und Auswahl zurücksetzen.
  /// 6. UI benachrichtigen und [PurchaseResult] zurückgeben.
  ///
  /// In einem echten Backend sollten Bestandsprüfung und Bestandsänderung
  /// atomar erfolgen, damit nicht zwei gleichzeitige Käufe dasselbe letzte
  /// Produkt erhalten.
  @override
  Future<PurchaseResult> purchase() async {
    final selectedId = _selectedProductId;
    if (selectedId == null) {
      return const PurchaseResult(
        status: PurchaseStatus.noSelection,
        message: 'Bitte zuerst ein Produkt auswählen.',
      );
    }

    final index = _products.indexWhere((item) => item.id == selectedId);
    final product = _products[index];
    if (product.stock <= 0) {
      return const PurchaseResult(
        status: PurchaseStatus.outOfStock,
        message: 'Dieses Produkt ist ausverkauft.',
      );
    }
    if (_creditInCents < product.priceInCents) {
      return const PurchaseResult(
        status: PurchaseStatus.insufficientCredit,
        message: 'Das Guthaben reicht nicht aus.',
      );
    }

    // Rückgeld wird vor dem Zurücksetzen des Guthabens berechnet.
    final change = _creditInCents - product.priceInCents;

    // Da Product unveränderlich ist, ersetzen wir den Listeneintrag durch eine
    // Kopie mit reduziertem Bestand.
    _products[index] = product.copyWith(stock: product.stock - 1);
    _creditInCents = 0;
    _selectedProductId = null;
    _statusMessage = '${product.name} liegt im Ausgabefach.';
    notifyListeners();

    return PurchaseResult(
      status: PurchaseStatus.success,
      message: _statusMessage,
      changeInCents: change,
    );
  }

  /// Bricht den aktuellen Vorgang ab und gibt das komplette Guthaben zurück.
  ///
  /// Der Rückgabewert ist der Betrag vor dem Zurücksetzen. Die UI kann ihn für
  /// eine Rückgabemeldung verwenden.
  @override
  int returnMoney() {
    final returnedMoney = _creditInCents;
    _creditInCents = 0;
    _selectedProductId = null;
    _statusMessage = 'Geld wurde zurückgegeben.';
    notifyListeners();
    return returnedMoney;
  }
}
