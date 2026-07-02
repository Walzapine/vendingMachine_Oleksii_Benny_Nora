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
  });

  /// Produkte in der Reihenfolge, in der sie im Raster erscheinen sollen.
  final List<Product> products;

  /// Aktuell eingeworfenes Guthaben als ganze Centzahl.
  final int creditInCents;

  /// ID des ausgewählten Produkts oder `null`, wenn nichts gewählt wurde.
  ///
  /// Es wird die stabile Produkt-ID und nicht der Produktname gespeichert.
  final String? selectedProductId;

  /// Kurzer Text für die Statuszeile, beispielsweise eine Auswahlbestätigung.
  final String statusMessage;

  /// Formatiert das aktuelle Guthaben für die deutsche Oberfläche.
  /// Berechnungen erfolgen weiterhin ausschließlich mit [creditInCents].
  String get formattedCredit =>
      '${(creditInCents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';
}
