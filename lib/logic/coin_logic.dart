import '../models/coin.dart';

/// Reine Logik für das Auffüllen und Verringern des Münzbestands.
///
/// Arbeitet auf dem gemeinsamen [Coin]-Modell (von der Datenbank-Seite
/// definiert: `id`, `currency`, `value`, `quantity`), statt einem eigenen
/// Modell. Genau wie [PurchaseLogic] kennt diese Klasse weder Flutter noch
/// eine Datenbank - sie bekommt die aktuelle Münzliste übergeben und liefert
/// nur ein Ergebnis zurück, ohne selbst etwas zu speichern.
class CoinLogic {
  const CoinLogic._();

  /// Erhöht den Bestand einer Münze um genau 1 (ein Klick auf "+").
  ///
  /// [coinId] ist die technische ID der Münze in der übergebenen Liste
  /// (entspricht [Coin.id], nicht dem Geldwert). Ein Erhöhen kann fachlich
  /// nicht fehlschlagen, außer die ID existiert gar nicht in der Liste.
  static CoinAdjustment increase({
    required List<Coin> coins,
    required int coinId,
  }) {
    final index = coins.indexWhere((coin) => coin.id == coinId);
    if (index == -1) {
      return const CoinAdjustment.failure(
        message: 'Diese Münzsorte existiert nicht.',
      );
    }

    final coin = coins[index];
    final updatedCoin = coin.copyWith(quantity: coin.quantity + 1);

    return CoinAdjustment.success(
      updatedCoin: updatedCoin,
      coinIndex: index,
      message: 'Bestand erhöht.',
    );
  }

  /// Verringert den Bestand einer Münze um genau 1 (ein Klick auf "-").
  ///
  /// Schlägt fehl, wenn die Münzsorte nicht existiert oder ihr Bestand
  /// bereits 0 ist - eine negative Stückzahl ergibt fachlich keinen Sinn.
  static CoinAdjustment decrease({
    required List<Coin> coins,
    required int coinId,
  }) {
    final index = coins.indexWhere((coin) => coin.id == coinId);
    if (index == -1) {
      return const CoinAdjustment.failure(
        message: 'Diese Münzsorte existiert nicht.',
      );
    }

    final coin = coins[index];
    if (coin.quantity <= 0) {
      return const CoinAdjustment.failure(
        message: 'Bestand dieser Münzsorte ist bereits leer.',
      );
    }

    final updatedCoin = coin.copyWith(quantity: coin.quantity - 1);

    return CoinAdjustment.success(
      updatedCoin: updatedCoin,
      coinIndex: index,
      message: 'Bestand verringert.',
    );
  }
}

/// Ergebnis einer Bestandsänderung (Erhöhen oder Verringern).
///
/// Gleiches Muster wie [PurchaseAttempt]: benannte Konstruktoren für Erfolg
/// und Fehlschlag, plus - bei Erfolg - die aktualisierte Münze und ihre
/// Position in der Liste, damit der Aufrufer sie an der richtigen Stelle
/// ersetzen kann.
class CoinAdjustment {
  const CoinAdjustment.success({
    required Coin updatedCoin,
    required int coinIndex,
    required this.message,
  }) : _updatedCoin = updatedCoin,
       _coinIndex = coinIndex;

  const CoinAdjustment.failure({required this.message})
    : _updatedCoin = null,
      _coinIndex = null;

  final Coin? _updatedCoin;
  final int? _coinIndex;

  /// Für Menschen lesbare Meldung, z. B. für eine kurze Bestätigung oder
  /// Fehlermeldung im Adminbereich.
  final String message;

  /// Bequeme Prüfung, ob die Änderung geglückt ist.
  bool get isSuccess => _updatedCoin != null;

  /// Die aktualisierte Münze nach erfolgreicher Änderung.
  /// Darf nur bei [isSuccess] == true gelesen werden.
  Coin get updatedCoin {
    final coin = _updatedCoin;
    if (coin == null) {
      throw StateError('updatedCoin darf nur bei isSuccess == true gelesen werden.');
    }
    return coin;
  }

  /// Position der aktualisierten Münze in der übergebenen Liste.
  /// Darf nur bei [isSuccess] == true gelesen werden.
  int get coinIndex {
    final index = _coinIndex;
    if (index == null) {
      throw StateError('coinIndex darf nur bei isSuccess == true gelesen werden.');
    }
    return index;
  }
}