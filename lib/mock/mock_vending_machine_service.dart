import '../models/machine_state.dart';
import '../models/product.dart';
import '../models/purchase_result.dart';
import '../services/vending_machine_service.dart';
import 'mock_products.dart';
import '../logic/purchase_logic.dart';

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
  ///
  /// Wichtig: Nach einem erfolgreichen Kauf wird dieser Wert NICHT auf 0
  /// gesetzt, sondern auf das Rückgeld reduziert. Er repräsentiert also immer
  /// den kompletten Betrag, den der Kunde gerade "im Automaten stehen" hat.
  int _creditInCents = 0;

  /// ID des aktuell gewählten Produkts; `null` bedeutet keine Auswahl.
  String? _selectedProductId;

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

  /// Sucht ein Produkt über seine Fachnummer und merkt seine technische ID.
  ///
  /// Nach der Auswahl werden Statuszeile und Tastenmarkierung aktualisiert.
  /// Die echte Implementierung sollte unbekannte Fachnummern kontrolliert
  /// behandeln; `firstWhere` reicht hier für die festen Mockdaten aus.
  @override
  void selectProductBySlot(int productID) {
    // final product = _products.firstWhere((item) => item.id == productID);
    // _selectedProductId = product.id;
    // _statusMessage = '${product.name} ausgewählt.';
    // notifyListeners();
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
  ///
  /// Eine spätere SQLite- oder API-Implementierung würde exakt dieselbe
  /// `PurchaseLogic.evaluatePurchase(...)`-Prüfung aufrufen, im Erfolgsfall
  /// aber z. B. einen `UPDATE`-Befehl an die Datenbank schicken statt die
  /// Liste im RAM zu verändern.
  @override
  Future<PurchaseResult> purchase() async {
    // Die reine Prüfung: bekommt den aktuellen Zustand als einfache Werte
    // übergeben und liefert zurück, ob und wie der Kauf ausgeführt werden
    // darf. Wichtig: An dieser Stelle wurde noch NICHTS verändert.
    final attempt = PurchaseLogic.evaluatePurchase(
      products: _products,
      selectedProductId: _selectedProductId,
      creditInCents: _creditInCents,
      // Nur ein unabgeholtes PRODUKT blockiert einen neuen Kauf. Übriges
      // Guthaben tut das nicht mehr - der Kunde darf es jederzeit für den
      // nächsten Kauf weiterverwenden oder sich auszahlen lassen.
      trayOccupied: _dispensedProduct != null,
    );

    // Nur bei Erfolg wird der interne Zustand tatsächlich übernommen. Bei
    // einem Fehlschlag (z. B. ausverkauft) bleiben Guthaben und Auswahl
    // unverändert, damit der Kunde es erneut versuchen kann.
    if (attempt.isSuccess) {
      // Das alte Produkt an der ermittelten Position durch die Kopie mit
      // reduziertem Bestand ersetzen.
      _products[attempt.productIndex!] = attempt.updatedProduct!;

      // Das Produkt wandert physisch ins Ausgabefach.
      _dispensedProduct = attempt.updatedProduct;

      // WICHTIG: Guthaben wird NICHT auf 0 gesetzt, sondern auf den
      // Restbetrag (das Rückgeld). Dadurch zeigt "Guthaben" oben in der UI
      // automatisch den Restwert an, ganz ohne ein zweites Datenfeld.
      _creditInCents = attempt.changeInCents;

      _selectedProductId = null;
    }

    // Die Statusmeldung kommt in beiden Fällen (Erfolg oder Fehlschlag)
    // direkt aus der Prüfung, damit UI und Logik immer denselben Text zeigen.
    _statusMessage = attempt.message;

    // Pflicht laut VendingMachineService-Vertrag: nach jeder sichtbaren
    // Änderung müssen Listener (hier: der AnimatedBuilder im ProductScreen)
    // informiert werden, damit die UI sich automatisch neu aufbaut.
    notifyListeners();

    // Die UI kennt nur PurchaseResult, nicht die internen Details wie
    // productIndex oder updatedProduct – deshalb hier die Umwandlung.
    return attempt.toPurchaseResult();
  }

  /// Entfernt das Produkt aus dem Ausgabefach.
  ///
  /// Betrifft ausschließlich [_dispensedProduct]. Das Guthaben bleibt davon
  /// komplett unberührt - für dessen Entnahme ist [returnMoney] zuständig.
  /// Ist das Fach schon leer, passiert einfach nichts Sichtbares.
  @override
  void collectProduct() {
    _dispensedProduct = null;
    _statusMessage = 'Bereit. Bitte Produkt auswählen.';
    notifyListeners();
  }

  /// Setzt das Guthaben auf 0 zurück und liefert den Betrag, der ausgezahlt
  /// wurde.
  ///
  /// Wird sowohl vom RÜCKGABE-Button als auch von einem Klick auf das
  /// Rückgeld-Fach in der UI aufgerufen. Betrifft ausschließlich das
  /// Guthaben - ein eventuell noch nicht abgeholtes Produkt im Ausgabefach
  /// bleibt davon unberührt.
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
