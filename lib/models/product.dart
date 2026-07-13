import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const Product._();

  const factory Product({
    required int id,
    required String name,
    // War vorher `double price` (Euro-Betrag, z. B. 1.8). Jetzt `int` in
    // ganzen Cent, um Rundungsfehler bei Geldbeträgen grundsätzlich
    // auszuschließen - nicht mehr nur in PurchaseLogic notdürftig
    // abgesichert, sondern direkt im Modell erzwungen.
    //
    // @JsonKey(name: 'price') sorgt dafür, dass die Datenbank-Spalte
    // weiterhin 'price' heißen darf (siehe product_table.dart), obwohl das
    // Dart-Feld jetzt aussagekräftiger `priceInCents` heißt. Ohne dieses
    // JsonKey würde fromJson() nach einem Schlüssel 'priceInCents' suchen,
    // den es in der DB-Tabelle gar nicht gibt.
    @JsonKey(name: 'price') required int priceInCents,
    required int stock,
    required String emoji,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  /// Formatiert [priceInCents] für die deutsche Oberfläche,
  /// z. B. `180` -> `1,80 €`.
  String get formattedPrice =>
      '${(priceInCents / 100).toStringAsFixed(2).replaceAll('.', ',')} €';
}