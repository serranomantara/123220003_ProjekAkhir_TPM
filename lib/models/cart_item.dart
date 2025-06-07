import 'egg_product.dart';

class CartItem {
  final EggProduct product;
  final int quantity;
  final String timezone;
  final String currency;

  CartItem({
    required this.product,
    required this.quantity,
    required this.timezone,
    required this.currency,
  });

  double get totalPrice => product.discountedPrice * quantity;
}