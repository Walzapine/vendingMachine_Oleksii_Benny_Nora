/// Unveränderliches Datenmodell eines Produkts im Snackautomaten.
///
/// Ein Produkt enthält nur Daten und keine Kauf- oder Speicherlogik. Dadurch
/// kann dasselbe Modell im Frontend, in Services, Tests und später in einem
/// Repository verwendet werden.
class Product {
  /// Erstellt ein vollständig definiertes Produkt.
  ///
  /// Alle Felder sind Pflichtfelder. So kann das Frontend davon ausgehen, dass
  /// jedes geladene Produkt eine Kennung, ein Automatenfach, einen Namen, einen
  /// Preis, einen Bestand und eine einfache Darstellung besitzt.
  const Product({
    required this.id,
    required this.slotCode,
    required this.name,
    required this.priceInCents,
    required this.stock,
    required this.emoji,
  });

  /// Technische, eindeutige Kennung für Datenbank und Backend.
  ///
  /// Die ID sollte stabil bleiben, selbst wenn Name, Preis oder Fach geändert
  /// werden. Sie ist nicht zwingend für Benutzer sichtbar.
  final String id;

  /// Sichtbare Fachnummer des Automaten, beispielsweise `A1` oder `C4`.
  final String slotCode;

  /// Anzeigename des Produkts.
  final String name;

  /// Preis als ganze Centzahl, beispielsweise `180` für 1,80 Euro.
  ///
  /// Geld wird absichtlich nicht als `double` gespeichert, damit keine
  /// Gleitkomma- und Rundungsfehler entstehen.
  final int priceInCents;

  /// Aktuell verfügbare Stückzahl. `0` bedeutet ausverkauft.
  final int stock;

  /// Einfache visuelle Darstellung für den aktuellen Frontend-Prototyp.
  /// Später kann dieses Feld durch einen Bildpfad oder eine Bild-URL ersetzt
  /// beziehungsweise ergänzt werden.
  final String emoji;

  /// Formatiert den Centwert für die deutsche Anzeige, z. B. `1,80 €`.
  ///
  /// Diese Hilfsfunktion dient nur der Darstellung. Berechnungen müssen immer
  /// mit [priceInCents] durchgeführt werden.
  String get formattedPrice =>
      '${(priceInCents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';

  /// Erzeugt eine neue Produktinstanz mit geändertem Preis oder Bestand.
  ///
  /// [Product] ist unveränderlich. Statt Felder direkt zu verändern, erzeugt
  /// das Backend daher eine Kopie. Nicht übergebene Werte werden vom aktuellen
  /// Produkt übernommen.
  Product copyWith({int? priceInCents, int? stock}) {
    return Product(
      id: id,
      slotCode: slotCode,
      name: name,
      priceInCents: priceInCents ?? this.priceInCents,
      stock: stock ?? this.stock,
      emoji: emoji,
    );
  }
}
