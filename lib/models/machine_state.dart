import 'product.dart';

/// Vollständiger, nur lesbarer Zustand des normalen Automaten-Frontends.
///
/// Das Frontend erhält immer ein zusammenhängendes Zustandsobjekt. Es muss
/// dadurch keine einzelnen Werte aus verschiedenen Backendklassen zusammensuchen.
/// Jede Service-Implementierung muss diesen Zustand nach Änderungen aktuell
/// bereitstellen und anschließend ihre Listener informieren.
class MachineState {
  /// Erstellt einen neuen Schnappschuss des Automatenzustands.
  const MachineState({
    required this.products,
    this.creditInCents = 0,
    this.selectedProductId,
    this.statusMessage = 'Bereit. Bitte Produkt auswählen.',
    this.dispensedProduct,
  });

  /// Produkte in der Reihenfolge, in der sie im Raster erscheinen sollen.
  final List<Product> products;

  /// Aktuell verfügbares Guthaben in Cent.
  ///
  /// Wichtig: Dieses Feld wird nach einem Kauf NICHT mehr auf 0 gesetzt,
  /// sondern enthält den verbleibenden Restbetrag (das Rückgeld). Es zeigt
  /// also immer den kompletten Betrag, den der Kunde gerade "im Automaten
  /// stehen" hat - egal ob frisch eingeworfen oder als Rückgeld übrig.
  final int creditInCents;

  /// ID des ausgewählten Produkts oder `null`, wenn nichts gewählt wurde.
  ///
  /// Entspricht [Product.id] (int).
  final int? selectedProductId;

  /// Kurzer Text für die Statuszeile, beispielsweise eine Auswahlbestätigung.
  final String statusMessage;

  /// Produkt, das gerade physisch im Ausgabefach liegt, oder `null`, wenn das
  /// Fach leer ist.
  ///
  /// Wird bei einem erfolgreichen Kauf gesetzt und bleibt so lange bestehen,
  /// bis der Kunde per Klick auf das Fach abholt (siehe
  /// [VendingMachineService.collectProduct]). Solange dieses Feld nicht
  /// `null` ist, sollte kein weiterer Kauf gestartet werden können - das
  /// Guthaben selbst ist davon aber unabhängig und bleibt jederzeit nutzbar.
  final Product? dispensedProduct;

  /// Bequeme Prüfung für die UI, ob im Produktfach etwas Unabgeholtes liegt.
  /// Wird u. a. genutzt, um weitere Käufe zu sperren.
  bool get trayHasProduct => dispensedProduct != null;

  /// Bequeme Prüfung für die UI, ob im Rückgeld-Fach etwas zum Abholen liegt.
  bool get hasChangeToCollect => creditInCents > 0;

  /// Formatiert das aktuelle Guthaben für die deutsche Oberfläche.
  /// Berechnungen erfolgen weiterhin ausschließlich mit [creditInCents].
  String get formattedCredit =>
      '${(creditInCents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';
}