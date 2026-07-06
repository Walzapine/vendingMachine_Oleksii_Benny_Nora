/// Mögliche fachliche Ergebnisse eines Kaufversuchs.
///
/// Das Frontend kann damit Entscheidungen treffen, ohne Fehlermeldungstexte
/// analysieren zu müssen. Neue Fälle können später als weitere Enum-Werte
/// ergänzt werden.
enum PurchaseStatus {
  success,
  noSelection,
  insufficientCredit,
  outOfStock,
  // NEU: Verhindert einen weiteren Kauf, solange noch ein Produkt (und/oder
  // Rückgeld) im Ausgabefach liegt und nicht abgeholt wurde. Ohne diese
  // Sperre könnte ein zweiter Kauf das erste, noch nicht abgeholte Produkt
  // im Fach "überschreiben" bzw. dessen Rückgeld verloren gehen.
  trayOccupied,
}

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
  ///
  /// Hinweis: Dieser Betrag landet nach der neuen Logik zusätzlich im
  /// Ausgabefach (siehe [MachineState.pendingChangeInCents]) und wird erst
  /// beim Abholen tatsächlich "ausgezahlt". Das Feld hier bleibt trotzdem
  /// erhalten, damit z. B. eine SnackBar direkt nach dem Kauf den Betrag
  /// anzeigen kann, ohne extra im MachineState nachschauen zu müssen.
  final int changeInCents;

  /// Bequeme Prüfung, ob der Kauf erfolgreich abgeschlossen wurde.
  bool get isSuccess => status == PurchaseStatus.success;
}