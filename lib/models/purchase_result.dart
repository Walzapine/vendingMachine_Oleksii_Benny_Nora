/// Mögliche fachliche Ergebnisse eines Kaufversuchs.
///
/// Das Frontend kann damit Entscheidungen treffen, ohne Fehlermeldungstexte
/// analysieren zu müssen. Neue Fälle können später als weitere Enum-Werte
/// ergänzt werden.
enum PurchaseStatus { success, noSelection, insufficientCredit, outOfStock }

/// Ergebnisobjekt, das [VendingMachineService.purchase] zurückgibt.
///
/// Auch fehlgeschlagene Käufe werden als normales Ergebnis geliefert und nicht
/// als Exception. Exceptions sind für unerwartete technische Fehler gedacht,
/// beispielsweise eine nicht erreichbare Datenbank.
class PurchaseResult {
  /// Erstellt das Ergebnis eines Kaufversuchs.
  const PurchaseResult({
    required this.status,
    required this.message,
    this.changeInCents = 0,
  });

  /// Maschinenlesbarer Status des Versuchs.
  final PurchaseStatus status;

  /// Benutzerfreundliche Meldung für Statuszeile oder SnackBar.
  final String message;

  /// Zurückzugebender Betrag in Cent; bei keinem Rückgeld standardmäßig `0`.
  final int changeInCents;

  /// Bequeme Prüfung, ob der Kauf erfolgreich abgeschlossen wurde.
  bool get isSuccess => status == PurchaseStatus.success;
}
