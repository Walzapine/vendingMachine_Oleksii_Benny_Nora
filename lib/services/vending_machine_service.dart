import 'package:flutter/foundation.dart';

import '../models/machine_state.dart';
import '../models/purchase_result.dart';

/// Vertrag zwischen Kunden-Frontend und Automatenlogik beziehungsweise Backend.
///
/// Nora und Oleksii können eine neue Klasse erstellen, die diesen Vertrag
/// implementiert. Das Frontend in `product_screen.dart` muss dabei nicht
/// verändert werden. Eine Implementierung ist für Validierung, Bestandsänderung,
/// Geldberechnung und gegebenenfalls dauerhafte Speicherung verantwortlich.
///
/// Die Klasse erweitert [ChangeNotifier]. Nach jeder sichtbaren Zustandsänderung
/// muss die Implementierung `notifyListeners()` aufrufen. Der ProductScreen
/// verwendet einen `AnimatedBuilder` und wird dadurch automatisch neu aufgebaut.
abstract class VendingMachineService extends ChangeNotifier {
  /// Liefert einen aktuellen, nur lesbaren Schnappschuss des Automatenzustands.
  MachineState get state;

  /// Fügt dem Guthaben [cents] Cent hinzu.
  ///
  /// Gültigkeit und erlaubte Münzwerte sollten von der echten Logik geprüft
  /// werden. Negative Werte dürfen nicht angenommen werden.
  void insertMoney(int cents);

  /// Wählt das Produkt mit der sichtbaren Fachnummer [slotCode] aus.
  ///
  /// Bei einer unbekannten Fachnummer sollte die echte Implementierung einen
  /// kontrollierten Fehlerstatus setzen, statt unkontrolliert abzustürzen.
  void selectProductBySlot(String slotCode);

  /// Versucht, das ausgewählte Produkt mit dem Guthaben zu kaufen.
  ///
  /// Die Methode ist asynchron, damit später Datenbankzugriffe oder API-Aufrufe
  /// möglich sind. Ein erfolgreicher Kauf sollte mindestens Bestand und
  /// Guthaben aktualisieren, die Auswahl zurücksetzen und Listener informieren.
  Future<PurchaseResult> purchase();

  /// Setzt Guthaben und Auswahl zurück und liefert den Rückgabebetrag in Cent.
  int returnMoney();
}
