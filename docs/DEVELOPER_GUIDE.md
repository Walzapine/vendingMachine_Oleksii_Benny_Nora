# Entwicklerleitfaden – Snackautomat

## 1. Ziel des aktuellen Stands

Das Projekt trennt das Flutter-Frontend von der Automatenlogik. Die Oberfläche
zeigt Produkte, Guthaben, Münztasten, Fachauswahl, Kaufen, Rückgabe, Ausgabefach
und Statusmeldungen. Ein In-Memory-Service simuliert das Backend, damit das
Frontend bereits ausgeführt und getestet werden kann.

Der Adminbereich gehört ausdrücklich noch nicht zum aktuellen Umfang. Sein Icon
ist als Platzhalter sichtbar und zeigt nur eine Meldung.

## 2. Architektur

```text
Benutzereingabe
      │
      ▼
ProductScreen / ProductCard
      │ ruft ausschließlich Methoden auf
      ▼
VendingMachineService (abstrakter Vertrag)
      │
      ├── aktuell: MockVendingMachineService
      └── später: echte Backend-Implementierung
                    │
                    └── Datenbank / Datei / API

Service ändert Zustand
      │
      ▼
notifyListeners()
      │
      ▼
AnimatedBuilder baut die Ansicht mit MachineState neu
```

Die UI darf Daten nicht direkt speichern oder Bestände selbst berechnen. Der
Service darf umgekehrt keine Widgets, Dialoge oder Farben kennen.

## 3. Zuständigkeit der Dateien

### Einstieg

- `lib/main.dart`: Erstellt den konkreten Service, konfiguriert das App-Theme und
  startet den ProductScreen. Für die Backendintegration wird hier später die
  Mock-Instanz ersetzt.

### Modelle

- `lib/models/product.dart`: Produkt-ID, Fachnummer, Name, Preis, Bestand und
  vorläufiges Emoji.
- `lib/models/machine_state.dart`: Gesamter sichtbarer Zustand des normalen
  Automaten.
- `lib/models/purchase_result.dart`: Fachliches Ergebnis eines Kaufversuchs.

Modelle sind unveränderlich. Änderungen werden als neue Instanzen bereitgestellt.
Das verhindert unkontrollierte Seiteneffekte zwischen UI, Logik und Tests.

### Servicevertrag

- `lib/services/vending_machine_service.dart`: Einzige Schnittstelle, die das
  normale Frontend von der Automatenlogik benötigt.

Die echte Implementierung muss `VendingMachineService` erweitern. Nach jeder
sichtbaren Zustandsänderung muss `notifyListeners()` aufgerufen werden.

### Demo statt Backend

- `lib/mock/mock_products.dart`: Beispieldaten für zwölf Fächer.
- `lib/mock/mock_vending_machine_service.dart`: Flüchtige Demo-Logik ohne
  Datenbank. Alle Daten gehen beim Neustart verloren.

Der Ordner `mock` kann entfernt werden, sobald eine vollständig getestete echte
Implementierung verwendet wird.

### Frontend

- `lib/screens/product_screen.dart`: Gesamtanordnung des Automaten und Übergabe
  aller Aktionen an den Service.
- `lib/widgets/product_card.dart`: Wiederverwendbare Karte eines Produktfachs.

## 4. Servicevertrag im Detail

### `MachineState get state`

Muss jederzeit den aktuellen Zustand liefern. Die Produktliste sollte nach außen
nicht veränderbar sein, beispielsweise durch `List.unmodifiable`.

### `void insertMoney(int cents)`

Addiert eine erlaubte, positive Centzahl. Die echte Logik sollte ungültige Werte
ablehnen und anschließend Status sowie Guthaben aktualisieren.

### `void selectProductBySlot(String slotCode)`

Wählt ein Produkt anhand seiner sichtbaren Fachnummer. Unbekannte Fächer dürfen
nicht zu einem unkontrollierten Absturz führen.

### `Future<PurchaseResult> purchase()`

Prüft mindestens:

1. Wurde ein Produkt gewählt?
2. Existiert es und ist es vorrätig?
3. Reicht das Guthaben?
4. Kann der Bestand sicher reduziert werden?
5. Wie hoch ist das Rückgeld?

Bei Erfolg werden Bestand, Guthaben, Auswahl und Status gemeinsam aktualisiert.
Bei Datenbankeinsatz sollte die Bestandsprüfung mit der Bestandsänderung in einer
Transaktion erfolgen.

### `int returnMoney()`

Gibt das aktuelle Guthaben zurück und setzt Guthaben sowie Auswahl zurück.

## 5. Geldwerte

Alle Geldbeträge werden als `int` in Cent gespeichert:

```text
1,80 €  -> 180
2,00 €  -> 200
0,50 €  -> 50
```

`double` ist für Geldberechnungen ungeeignet, weil binäre Gleitkommazahlen
Rundungsabweichungen erzeugen können. Formatierte Eurotexte sind nur für die
Anzeige gedacht und dürfen nicht als Berechnungsgrundlage verwendet werden.

## 6. Backend einbauen

1. Eine Klasse wie `DatabaseVendingMachineService` erstellen.
2. `VendingMachineService` erweitern.
3. Alle fünf Vertragsbestandteile implementieren.
4. Produkte aus der gewünschten Datenquelle laden.
5. Für jede sichtbare Änderung einen neuen Zustand liefern.
6. Danach `notifyListeners()` aufrufen.
7. In `main.dart` `MockVendingMachineService()` durch die neue Klasse ersetzen.
8. Bestehende Tests gegen die neue Implementierung übernehmen und erweitern.

Das Frontend sollte für diesen Austausch nicht verändert werden müssen.

## 7. Erwartete Regeln der Geschäftslogik

- Preise und Guthaben sind niemals negativ.
- Bestand ist niemals negativ.
- Ein Kauf ohne Auswahl schlägt kontrolliert fehl.
- Ein ausverkauftes Produkt kann nicht gekauft werden.
- Unzureichendes Guthaben reduziert den Bestand nicht.
- Ein erfolgreicher Kauf reduziert den Bestand genau um eins.
- Rückgeld entspricht `Guthaben - Preis`.
- Nach Kauf oder Rückgabe wird das Guthaben auf null gesetzt.
- Produkt-IDs und Fachnummern müssen eindeutig sein.

## 8. Tests

`test/vending_machine_service_test.dart` prüft den fachlichen Kaufablauf.
`test/widget_test.dart` prüft die wesentlichen sichtbaren Bereiche und den
Admin-Platzhalter.

Vor jeder gemeinsamen Übergabe sollten beide Befehle erfolgreich sein:

```powershell
flutter analyze
flutter test
```

Sinnvolle nächste Servicetests sind Käufe ohne Auswahl, zu wenig Guthaben,
ausverkaufte Produkte, Rückgabe und ungültige Fachnummern.

## 9. Erweiterung des Adminbereichs

Der Adminbereich ist noch nicht implementiert. Wenn er später begonnen wird,
sollte er einen eigenen Servicevertrag erhalten. So vermischen sich Kundenkauf,
Authentifizierung, Bestandsverwaltung und Statistik nicht in einer großen Klasse.
Das vorhandene Icon in `product_screen.dart` ist der vorgesehene Einstiegspunkt.
