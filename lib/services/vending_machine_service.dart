import 'package:flutter/foundation.dart';

import '../models/coin.dart';
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

  /// Wählt das Produkt mit der ID [productId] aus.
  ///
  /// Hinweis: Hieß früher `selectProductBySlot(String slotCode)` - da das
  /// Product-Modell kein `slotCode`-Feld mehr hat, wird jetzt direkt über die
  /// technische ID ausgewählt (entspricht [Product.id]).
  ///
  /// Bei einer unbekannten ID sollte die echte Implementierung einen
  /// kontrollierten Fehlerstatus setzen, statt unkontrolliert abzustürzen.
  void selectProduct(int productId);

  /// Versucht, das ausgewählte Produkt mit dem Guthaben zu kaufen.
  ///
  /// Die Methode ist asynchron, damit später Datenbankzugriffe oder API-Aufrufe
  /// möglich sind.
  ///
  /// Bei Erfolg passiert Folgendes:
  ///
  /// * Das Produkt landet im Ausgabefach (siehe [MachineState.dispensedProduct])
  ///   und muss über [collectProduct] separat abgeholt werden.
  /// * Das Guthaben wird NICHT auf 0 gesetzt, sondern auf den Restbetrag
  ///   (das Rückgeld) reduziert. Der Kunde kann diesen Restbetrag entweder für
  ///   den nächsten Kauf verwenden oder über [returnMoney] auszahlen lassen.
  ///
  /// Liegt noch ein unabgeholtes Produkt im Fach, sollte die Implementierung
  /// einen weiteren Kauf mit [PurchaseStatus.trayOccupied] ablehnen.
  Future<PurchaseResult> purchase();

  /// Setzt das Guthaben auf 0 zurück und liefert den ausgezahlten Betrag in
  /// Cent zurück.
  ///
  /// Wird sowohl vom RÜCKGABE-Button als auch von einem Klick auf das
  /// Rückgeld-Fach in der UI aufgerufen - beides bedeutet fachlich dasselbe:
  /// der Kunde nimmt sein aktuelles Guthaben als Münzen mit.
  int returnMoney();

  /// Entfernt das Produkt aus dem Ausgabefach.
  ///
  /// Wird aufgerufen, wenn der Kunde in der UI auf das Ausgabefach klickt.
  /// Betrifft ausschließlich [MachineState.dispensedProduct] - das Guthaben
  /// bleibt davon komplett unberührt, da beide Fächer unabhängig voneinander
  /// entnommen werden können. Die Implementierung muss anschließend
  /// `notifyListeners()` aufrufen.
  void collectProduct();

  // ---------------------------------------------------------------------
  // Ab hier: Adminbereich (Münzbestand). Diese Methoden gehören fachlich
  // zum "Backoffice" des Automaten, nicht zum normalen Kundenbetrieb, und
  // werden deshalb bewusst nicht in MachineState mitgeführt.
  // ---------------------------------------------------------------------

  /// Liefert einen aktuellen, nur lesbaren Schnappschuss aller Münzsorten
  /// samt Bestand. Wird vom Adminbereich benötigt, um für jede Münzsorte die
  /// aktuelle Stückzahl neben den +/- Buttons anzuzeigen.
  List<Coin> get coins;

  /// Erhöht den Bestand der Münze mit der ID [coinId] um 1.
  ///
  /// [coinId] entspricht [Coin.id] (nicht dem Geldwert). Wird vom "+"-Button
  /// im Adminbereich aufgerufen. Die Implementierung muss anschließend
  /// `notifyListeners()` aufrufen.
  void increaseCoinQuantity(int coinId);

  /// Verringert den Bestand der Münze mit der ID [coinId] um 1, sofern dieser
  /// bereits größer als 0 ist.
  ///
  /// Wird vom "-"-Button im Adminbereich aufgerufen. Die Implementierung muss
  /// anschließend `notifyListeners()` aufrufen.
  void decreaseCoinQuantity(int coinId);
}