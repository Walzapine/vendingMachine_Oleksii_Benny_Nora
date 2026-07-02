# Arbeitsanleitung für Nora und Oleksii

## Ziel

Benni erstellt und pflegt das Flutter-Frontend. Nora entwickelt die
Geschäftslogik des Snackautomaten. Oleksii entwickelt die Datenhaltung. Beide
Backendteile werden über feste Schnittstellen verbunden, damit niemand direkt in
den Dateien einer anderen Person arbeiten muss.

## Aufgabenverteilung

### Benni – Frontend

Benni arbeitet hauptsächlich in:

```text
lib/screens/
lib/widgets/
lib/main.dart
```

Benni verändert keine Kaufberechnung und speichert keine Produkte direkt.

### Nora – Geschäftslogik

Nora ist verantwortlich für:

- Münzen und Guthaben prüfen,
- Produkt auswählen,
- Kaufbedingungen prüfen,
- Bestand nach erfolgreichem Kauf reduzieren,
- Rückgeld berechnen,
- Geldrückgabe,
- Statusmeldungen,
- Tests der Geschäftsregeln.

Nora arbeitet hauptsächlich in:

```text
lib/services/
test/services/
```

### Oleksii – Datenhaltung

Oleksii ist verantwortlich für:

- Produkte laden,
- Produkte dauerhaft speichern,
- Bestand aktualisieren,
- Datenquelle einrichten,
- Fehler beim Lesen und Speichern behandeln,
- Tests der Datenhaltung.

Oleksii arbeitet hauptsächlich in:

```text
lib/repositories/
lib/data/
test/repositories/
```

## Vorhandene Dateien, die nicht neu erfunden werden müssen

```text
lib/models/product.dart
lib/models/machine_state.dart
lib/models/purchase_result.dart
lib/services/vending_machine_service.dart
```

`Product`, `MachineState` und `PurchaseResult` werden gemeinsam verwendet. Das
Frontend erwartet eine Implementierung von `VendingMachineService`.

Die Datei

```text
lib/mock/mock_vending_machine_service.dart
```

ist nur eine funktionierende Demo. Sie kann als Beispiel gelesen werden, soll
aber nicht zur dauerhaften Datenhaltung erweitert werden.

## Empfohlene Reihenfolge

1. Oleksii erstellt zuerst den Repository-Vertrag.
2. Nora kann parallel ihre Logik mit einem Fake-Repository entwickeln.
3. Oleksii implementiert die echte lokale Speicherung.
4. Nora verbindet ihre Logik mit Oleksiis Repository.
5. In `main.dart` wird die Mock-Implementierung durch die echte Implementierung
   ersetzt.
6. Das Team prüft gemeinsam Kauf, Bestand, Rückgeld und Neustart der App.

---

# Teil 1: Oleksii – Datenhaltung bauen

## Schritt 1: Repository-Ordner erstellen

Neue Datei:

```text
lib/repositories/product_repository.dart
```

Inhalt als gemeinsamer Vertrag:

```dart
import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();

  Future<Product?> getProductById(String id);

  Future<void> updateProduct(Product product);

  Future<void> updateStock(String productId, int newStock);
}
```

Warum ein Repository? Nora muss dadurch nicht wissen, ob Oleksii SQLite, eine
JSON-Datei oder eine andere Speicherung verwendet.

## Schritt 2: Zuerst ein einfaches In-Memory-Repository erstellen

Neue Datei:

```text
lib/repositories/in_memory_product_repository.dart
```

Diese erste Implementierung speichert eine veränderbare Produktliste im
Arbeitsspeicher. Sie hilft Nora beim Entwickeln und Testen. Oleksii kann dabei die
Methoden des Repository-Vertrags prüfen, bevor eine Datenbank hinzukommt.

Wichtige Regeln:

- Nach außen Kopien oder unveränderbare Listen liefern.
- Produkte über `id` suchen.
- Bei unbekannter ID kontrolliert reagieren.
- Bestand niemals unter null speichern.
- Keine Widgets oder Flutter-Dialoge im Repository verwenden.

## Schritt 3: Dauerhafte Speicherung auswählen

Für ein Schulprojekt genügt eine lokale Lösung. Sinnvolle Möglichkeiten sind:

- SQLite für eine klassische Datenbank,
- Hive oder Isar für eine einfachere lokale Speicherung,
- JSON nur für eine sehr einfache Demonstration.

Vor dem Hinzufügen eines Pakets soll das Team gemeinsam entscheiden, welche
Variante verwendet wird. Abhängigkeiten werden anschließend in `pubspec.yaml`
eingetragen.

## Schritt 4: Datenquelle getrennt halten

Bei SQLite kann die Struktur so aussehen:

```text
lib/data/local/app_database.dart
lib/data/local/product_table.dart
lib/repositories/sqlite_product_repository.dart
```

Das Repository übersetzt Datenbankzeilen in `Product`-Objekte. SQL und
Datenbankbefehle gehören nicht in `ProductScreen` oder `ProductCard`.

## Schritt 5: Anfangsdaten bereitstellen

Beim ersten Start muss die Datenbank Produkte erhalten. Die vorhandenen Daten aus

```text
lib/mock/mock_products.dart
```

können als Vorlage dienen. Diese Startdaten werden nur eingefügt, wenn die
Produkttabelle noch leer ist.

## Schritt 6: Repository testen

Neue Testdatei:

```text
test/repositories/product_repository_test.dart
```

Mindestens prüfen:

- zwölf Produkte können geladen werden,
- Suche nach ID funktioniert,
- Bestand kann reduziert werden,
- geänderter Bestand wird erneut korrekt geladen,
- unbekannte Produkt-ID wird kontrolliert behandelt,
- negativer Bestand wird verhindert.

---

# Teil 2: Nora – Geschäftslogik bauen

## Schritt 1: Echten Service erstellen

Neue Datei:

```text
lib/services/vending_machine_service_impl.dart
```

Die Klasse erweitert den vorhandenen Vertrag:

```dart
class VendingMachineServiceImpl extends VendingMachineService {
  VendingMachineServiceImpl(this._productRepository);

  final ProductRepository _productRepository;

  // Hier werden MachineState und die Vertragsmethoden implementiert.
}
```

Nora verwendet ausschließlich `ProductRepository`. Sie importiert keine
SQLite-Klasse direkt. Dadurch kann die Datenhaltung später ausgetauscht werden.

## Schritt 2: Internen Zustand verwalten

Der Service benötigt mindestens:

```dart
List<Product> _products = [];
int _creditInCents = 0;
String? _selectedProductId;
String _statusMessage = 'Bereit. Bitte Produkt auswählen.';
```

Der Getter `state` baut daraus einen `MachineState`. Die Produktliste soll als
unveränderbare Liste ausgegeben werden.

## Schritt 3: Produkte initial laden

Da ein Repository asynchron arbeitet, benötigt die Implementierung beispielsweise
eine Methode:

```dart
Future<void> initialize() async {
  _products = await _productRepository.getProducts();
  notifyListeners();
}
```

Diese Methode kann vor `runApp` oder direkt nach dem Erstellen des Services
aufgerufen werden. Das Team muss sich auf eine Variante einigen. Optional kann
`MachineState` später um `isLoading` und `errorMessage` erweitert werden.

## Schritt 4: Münzeinwurf implementieren

In `insertMoney`:

1. Nur positive Werte erlauben.
2. Optional nur 10, 20, 50, 100 und 200 Cent akzeptieren.
3. Wert zu `_creditInCents` addieren.
4. Statusmeldung setzen.
5. `notifyListeners()` aufrufen.

## Schritt 5: Produktauswahl implementieren

In `selectProductBySlot`:

1. Produkt anhand `slotCode` suchen.
2. Bei unbekanntem Fach kontrollierte Statusmeldung setzen.
3. Bei gültigem Fach `_selectedProductId` setzen.
4. `notifyListeners()` aufrufen.

Ein ausverkauftes Produkt kann entweder schon bei der Auswahl abgewiesen oder
spätestens beim Kauf geprüft werden. Das Verhalten sollte durch einen Test
festgelegt werden.

## Schritt 6: Kauf implementieren

Die Reihenfolge ist wichtig:

1. Prüfen, ob ein Produkt ausgewählt wurde.
2. Produkt anhand der ID finden.
3. Prüfen, ob `stock > 0` ist.
4. Prüfen, ob das Guthaben reicht.
5. Rückgeld berechnen.
6. Neuen Bestand `stock - 1` bilden.
7. Bestand über das Repository speichern.
8. Lokale Produktliste aktualisieren.
9. Guthaben und Auswahl zurücksetzen.
10. Statusmeldung setzen.
11. `notifyListeners()` aufrufen.
12. Passendes `PurchaseResult` zurückgeben.

Wenn das Speichern fehlschlägt, darf der Service nicht so tun, als wäre der Kauf
erfolgreich gewesen. Für technische Fehler kann später ein zusätzlicher
`PurchaseStatus` ergänzt werden.

## Schritt 7: Rückgabe implementieren

In `returnMoney`:

1. Aktuelles Guthaben merken.
2. Guthaben auf null setzen.
3. Auswahl löschen.
4. Status aktualisieren.
5. `notifyListeners()` aufrufen.
6. Gemerkten Centbetrag zurückgeben.

## Schritt 8: Servicelogik testen

Neue oder erweiterte Tests unter:

```text
test/services/vending_machine_service_impl_test.dart
```

Mindestens prüfen:

- Kauf ohne Auswahl,
- unbekannte Fachnummer,
- Kauf mit zu wenig Guthaben,
- Kauf eines ausverkauften Produkts,
- erfolgreicher Kauf,
- Bestand sinkt genau um eins,
- korrektes Rückgeld,
- Rückgabe ohne Kauf,
- Guthaben ist nach Kauf oder Rückgabe null,
- Repository-Fehler erzeugt keinen scheinbar erfolgreichen Kauf.

---

# Teil 3: Gemeinsame Integration

## Schritt 1: Echte Klassen in `main.dart` erzeugen

Der aktuelle Code verwendet:

```dart
final service = MockVendingMachineService();
```

Später wird daraus sinngemäß:

```dart
final repository = SqliteProductRepository(/* Datenbank */);
final service = VendingMachineServiceImpl(repository);
await service.initialize();
runApp(SnackautomatApp(vendingService: service));
```

Wenn `await` in `main` verwendet wird:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Repository und Service erstellen und initialisieren.
}
```

Benni muss am `ProductScreen` nichts ändern, solange der Vertrag eingehalten wird.

## Schritt 2: Gemeinsam manuell prüfen

1. App starten.
2. Produkt A1 auswählen.
3. Zu wenig Geld einwerfen und kaufen.
4. Fehlermeldung kontrollieren.
5. Genug Geld einwerfen und kaufen.
6. Rückgeld und Bestand kontrollieren.
7. App vollständig schließen und neu starten.
8. Prüfen, ob der reduzierte Bestand gespeichert geblieben ist.
9. Geld einwerfen und Rückgabe drücken.

## Schritt 3: Automatische Prüfung

Vor dem Zusammenführen:

```powershell
flutter analyze
flutter test
```

Beide Befehle müssen ohne Fehler abgeschlossen werden.

---

# Git-Arbeitsweise

Empfohlene Branches:

```text
dev
frontend-benni
logic-nora
data-oleksii
```

`dev` ist der gemeinsame Hauptarbeitsbranch. Persönliche Aufgabenbranches werden
von `dev` abgezweigt und nach erfolgreicher Prüfung wieder in `dev` integriert.

Jede Person verändert möglichst nur ihre Ordner. Gemeinsame Dateien wie
`pubspec.yaml`, Modelle, Serviceverträge und `main.dart` sollten vor Änderungen
kurz im Team abgesprochen werden, weil dort leicht Merge-Konflikte entstehen.

Sinnvolle kleine Commits:

```text
Produkt-Repository-Vertrag hinzufügen
Lokale Produktdaten laden
Kaufprüfung implementieren
Rückgeldberechnung testen
Echten Service in main.dart verbinden
```

Keine generierten Buildordner oder IDE-Zwischendateien committen.

---

# Übergabepunkte zwischen Nora und Oleksii

Oleksii liefert Nora:

- den fertigen `ProductRepository`-Vertrag,
- eine getestete Repository-Implementierung,
- Information darüber, welche Fehler auftreten können.

Nora liefert Benni:

- eine fertige `VendingMachineService`-Implementierung,
- dokumentierte Status- und Fehlerfälle,
- bestandene Servicetests.

Benni meldet beiden:

- welche Zustände das Frontend anzeigen muss,
- ob weitere Werte im `MachineState` benötigt werden,
- welche Bedienabläufe noch fehlen.

Änderungen an gemeinsamen Verträgen werden immer zuerst gemeinsam beschlossen.
