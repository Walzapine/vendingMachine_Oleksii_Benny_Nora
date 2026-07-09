import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const Product._();

  const factory Product({
    required int id,
    required String name,
    required double price,
    required int stock,
    required String emoji,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  String get formattedPrice =>
      '${price.toStringAsFixed(2).replaceAll('.', ',')} €';
}