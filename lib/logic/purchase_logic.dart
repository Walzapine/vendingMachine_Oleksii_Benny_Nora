import '../models/product.dart';
import '../models/purchase_result.dart';

/// Reine Kauflogik für den Snackautomaten.
///
/// Diese Klasse kennt weder eine Datenbank noch die Flutter-UI. Sie arbeitet
/// ausschließlich mit den Werten, die ihr übergeben werden (Produktliste,
/// Guthaben, ausgewähltes Produkt), und liefert nur ein Ergebnis zurück. Sie
/// verändert dabei nichts selbst und speichert nichts dauerhaft – das bleibt
/// Aufgabe des jeweiligen Service (Mock, SQLite, API, ...).
///
/// Warum diese Trennung wichtig ist:
///
/// * **Backend-unabhängig**: Ob die Produktdaten aus dem RAM, aus SQLite oder
///   später aus einer API kommen, ist für diese Klasse egal. Sie bekommt eine
///   Liste von [Product]-Objekten übergeben und weiß nicht, woher sie stammt.
/// * **Testbar ohne Flutter**: Da hier keine Widgets, kein `BuildContext` und
///   kein `ChangeNotifier` vorkommen, lässt sich jede Methode mit einem ganz
///   normalen Dart-Unit-Test prüfen – ohne dass die App überhaupt starten muss.
/// * **Keine doppelte Pflege im Team**: Der Kollege, der später das echte
///   Backend baut, muss diese fachlichen Regeln (Bestand? Guthaben? welches
///   Rückgeld?) nicht erneut schreiben, sondern ruft einfach diese Klasse auf.
class PurchaseLogic {
  // Privater Konstruktor: Diese Klasse wird nie als Objekt erzeugt
  // (`PurchaseLogic()`), sondern nur über ihre statische Methode aufgerufen,
  // ähnlich wie z. B. `math.max(a, b)`. Der Unterstrich macht den Konstruktor
  // dateiprivat und verhindert versehentliche Instanzen von außen.
  const PurchaseLogic._();

  /// Prüft einen Kaufversuch und berechnet das Ergebnis, OHNE etwas zu
  /// verändern oder zu speichern.
  ///
  /// Diese Methode ist bewusst "seiteneffektfrei" (auch *pure function*
  /// genannt): Sie liest nur die übergebenen Parameter und gibt ein neues
  /// Ergebnisobjekt zurück. Die übergebene [products]-Liste selbst wird nicht
  /// verändert. Das macht das Verhalten vorhersagbar: bei gleichen Eingaben
  /// kommt immer dasselbe Ergebnis heraus, unabhängig davon, wie oft man die
  /// Methode aufruft.
  ///
  /// Ablauf der Prüfung (in dieser festen Reihenfolge, weil jede Stufe eine
  /// eigene, klar unterscheidbare Fehlermeldung für den Kunden liefert):
  ///
  /// 1. Wurde überhaupt ein Produkt ausgewählt?
  /// 2. Existiert dieses Produkt noch in der übergebenen Liste?
  /// 3. Ist das Produkt noch vorrätig (`stock > 0`)?
  /// 4. Reicht das eingeworfene Guthaben für den Preis?
  /// 5. Wenn alle Prüfungen bestanden sind: Rückgeld berechnen und eine Kopie
  ///    des Produkts mit reduziertem Bestand erzeugen.
  ///
  /// Der Aufrufer (typischerweise ein `VendingMachineService`) entscheidet
  /// danach selbst, WIE er das Ergebnis übernimmt – z. B. das Produkt in einer
  /// Liste im Arbeitsspeicher ersetzen oder einen `UPDATE`-Befehl in SQLite
  /// ausführen. Diese Methode weiß davon nichts und muss es auch nicht wissen.
  ///
  /// Zusätzlicher Parameter [trayOccupied]: `true`, wenn im Ausgabefach noch
  /// ein Produkt oder Rückgeld auf Abholung wartet. Ein neuer Kauf ist dann
  /// nicht erlaubt, damit das bereits ausgegebene Produkt nicht durch einen
  /// zweiten Kauf "überschrieben" wird, bevor der Kunde es entnommen hat.
  static PurchaseAttempt evaluatePurchase({
    required List<Product> products,
    required int? selectedProductId,
    required int creditInCents,
    bool trayOccupied = false,
  }) {
    // Schritt 0: Ausgabefach zuerst prüfen, noch vor der Produktauswahl -
    // ein belegtes Fach blockiert JEDEN Kauf, unabhängig davon, was sonst
    // ausgewählt oder eingeworfen wurde.
    if (trayOccupied) {
      return const PurchaseAttempt.failure(
        status: PurchaseStatus.trayOccupied,
        message: 'Bitte zuerst das Ausgabefach leeren.',
      );
    }

    // Schritt 1: Wurde überhaupt etwas ausgewählt? `selectedProductId` ist
    // `null`, solange der Kunde noch kein Fach angetippt hat.
    if (selectedProductId == null) {
      return const PurchaseAttempt.failure(
        status: PurchaseStatus.noSelection,
        message: 'Bitte zuerst ein Produkt auswählen.',
      );
    }

    // Schritt 2: Das ausgewählte Produkt in der übergebenen Liste suchen.
    // `indexWhere` gibt -1 zurück, wenn nichts gefunden wird. Das schützt vor
    // einer veralteten oder ungültigen ID, z. B. wenn ein Produkt
    // zwischenzeitlich vom Admin gelöscht wurde, der Kunde aber noch die alte
    // Auswahl "gemerkt" hat.
    final index = products.indexWhere((item) => item.id == selectedProductId);
    if (index == -1) {
      return const PurchaseAttempt.failure(
        status: PurchaseStatus.noSelection,
        message: 'Das ausgewählte Produkt existiert nicht mehr.',
      );
    }

    final product = products[index];
    // Product.price ist ein double (Euro-Betrag, z. B. 1.8 für 1,80 €), keine
    // ganze Centzahl. Wichtig: NICHT einfach .toInt() verwenden - das würde
    // nur abschneiden, nicht runden. Da Fließkommazahlen intern minimal
    // ungenau gespeichert werden (1.8 kann z. B. als 1.7999999999999998
    // vorliegen), würde .toInt() daraus fälschlich 179 statt 180 machen.
    // (product.price * 100).round() rundet dagegen korrekt auf den nächsten
    // ganzen Centbetrag. Das behebt den akuten Bug, ändert aber nichts daran,
    // dass Geld grundsätzlich besser als Cent-int in der DB gespeichert
    // werden sollte - das bleibt ein offener Punkt fürs Team.
    final productPriceInCents = (product.price * 100).round();

    // Schritt 3: Bestandsprüfung. `stock` wird nie negativ, aber `<= 0` ist
    // trotzdem robuster als `== 0`, falls doch einmal ein fehlerhafter Wert
    // durchrutscht.
    if (product.stock <= 0) {
      return const PurchaseAttempt.failure(
        status: PurchaseStatus.outOfStock,
        message: 'Dieses Produkt ist ausverkauft.',
      );
    }

    // Schritt 4: Guthabenprüfung. Der Vergleich erfolgt ausschließlich mit
    // ganzen Centbeträgen (int), nie mit `double`, um Rundungsfehler bei
    // Geldbeträgen zu vermeiden.
    if (creditInCents < productPriceInCents) {
      return const PurchaseAttempt.failure(
        status: PurchaseStatus.insufficientCredit,
        message: 'Das Guthaben reicht nicht aus.',
      );
    }

    // Schritt 5: Alle Prüfungen bestanden – Kauf ist gültig.
    // Rückgeld = eingeworfenes Guthaben minus Produktpreis.
    final change = creditInCents - productPriceInCents;

    // Da `Product` unveränderlich (immutable) ist, kann der Bestand nicht
    // direkt verringert werden. Stattdessen entsteht über `copyWith` eine neue
    // Produktinstanz mit `stock - 1`. Der Aufrufer ersetzt später an Position
    // [index] das alte Produkt durch dieses aktualisierte.
    final updatedProduct = product.copyWith(stock: product.stock - 1);

    return PurchaseAttempt.success(
      updatedProduct: updatedProduct,
      productIndex: index,
      changeInCents: change,
      message: '${product.name} liegt im Ausgabefach.',
    );
  }
}

/// Ergebnis einer reinen Kaufberechnung, BEVOR irgendetwas gespeichert wurde.
///
/// Dieses Objekt ist bewusst von [PurchaseResult] getrennt: [PurchaseResult]
/// ist das, was am Ende bei der UI ankommt (Status, Meldung, Rückgeld) – die
/// UI muss nicht wissen, welches Produkt sich intern geändert hat oder an
/// welcher Listenposition es stand.
///
/// [PurchaseAttempt] enthält dagegen zusätzlich genau die Informationen, die
/// ein Service braucht, um den neuen Zustand zu übernehmen:
/// [updatedProduct] (das Produkt mit reduziertem Bestand) und [productIndex]
/// (an welcher Stelle in der Liste es ersetzt werden muss).
///
/// Es gibt zwei Wege, ein `PurchaseAttempt` zu erzeugen, über die benannten
/// Konstruktoren `.failure(...)` und `.success(...)`. Das macht im Aufrufcode
/// sofort lesbar, welcher Fall gemeint ist, statt z. B. mit einem `bool`-Flag
/// zu arbeiten.
class PurchaseAttempt {
  /// Erzeugt ein fehlgeschlagenes Ergebnis.
  ///
  /// Bei einem Fehlschlag gibt es weder ein aktualisiertes Produkt noch ein
  /// Rückgeld, deshalb werden diese Felder hier fest auf `null` bzw. `0`
  /// gesetzt und müssen beim Aufruf nicht angegeben werden.
  const PurchaseAttempt.failure({required this.status, required this.message})
    : updatedProduct = null,
      productIndex = null,
      changeInCents = 0;

  /// Erzeugt ein erfolgreiches Ergebnis.
  ///
  /// Der `status` wird hier fest auf [PurchaseStatus.success] gesetzt, weil
  /// dieser Konstruktor ausschließlich für den Erfolgsfall gedacht ist – er
  /// muss deshalb nicht als Parameter übergeben werden.
  const PurchaseAttempt.success({
    required Product updatedProduct,
    required int productIndex,
    required int changeInCents,
    required String message,
  }) : status = PurchaseStatus.success,
       updatedProduct = updatedProduct,
       productIndex = productIndex,
       changeInCents = changeInCents,
       message = message;

  /// Maschinenlesbarer Ausgang der Prüfung (Erfolg oder welcher Fehlerfall).
  final PurchaseStatus status;

  /// Für Menschen lesbare Meldung, z. B. für Statuszeile oder SnackBar.
  final String message;

  /// Rückzugebender Betrag in Cent. Bei einem Fehlschlag immer `0`.
  final int changeInCents;

  /// Nur bei Erfolg gesetzt: das Produkt mit bereits reduziertem Bestand.
  /// Der Aufrufer muss dieses Produkt noch selbst an Stelle [productIndex]
  /// in seiner eigenen Datenquelle speichern (Liste, Datenbank, ...).
  final Product? updatedProduct;

  /// Nur bei Erfolg gesetzt: Position des ursprünglichen Produkts in der
  /// Liste, die an [PurchaseLogic.evaluatePurchase] übergeben wurde.
  final int? productIndex;

  /// Bequeme Prüfung für den Aufrufer, ob der Kauf geglückt ist, ohne jedes
  /// Mal `status == PurchaseStatus.success` ausschreiben zu müssen.
  bool get isSuccess => status == PurchaseStatus.success;

  /// Wandelt dieses interne Ergebnis in das [PurchaseResult] um, das die UI
  /// über den `VendingMachineService`-Vertrag erwartet. So bekommt die UI nur
  /// die Informationen, die sie wirklich braucht.
  PurchaseResult toPurchaseResult() {
    return PurchaseResult(
      status: status,
      message: message,
      changeInCents: changeInCents,
    );
  }
}