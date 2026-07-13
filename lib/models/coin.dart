import 'package:freezed_annotation/freezed_annotation.dart';

part 'coin.freezed.dart';
part 'coin.g.dart';

@freezed
abstract class Coin with _$Coin {
  const Coin._();

  const factory Coin({
    required int id,
    required String currency,
    // War vorher `double value` (Euro-Betrag, z. B. 2.0). Jetzt `int` in
    // ganzen Cent - gleicher Grund wie bei Product.priceInCents
    // (Rundungsfehler bei Geldbeträgen grundsätzlich ausschließen).
    //
    // @JsonKey(name: 'value') hält die DB-Spalte weiterhin 'value' (siehe
    // coins_table.dart), obwohl das Dart-Feld jetzt `valueInCents` heißt.
    @JsonKey(name: 'value') required int valueInCents,
    required int quantity,
  }) = _Coin;

  factory Coin.fromJson(Map<String, dynamic> json) => _$CoinFromJson(json);

  /// Formatiert [valueInCents] für die deutsche Oberfläche,
  /// z. B. `200` -> `2,00 €`.
  String get formattedValue =>
      '${(valueInCents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';
}