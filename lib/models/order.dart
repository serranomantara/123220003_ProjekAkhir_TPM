import 'package:intl/intl.dart';
import 'egg_product.dart'; // Pastikan ini mengimport model produk yang benar

class Order {
  final String id;
  final List<OrderItem> items;
  final DateTime checkoutTime;
  final double totalPrice;
  final String currency;
  final String timezone;

  Order({
    required this.id,
    required this.items,
    required this.checkoutTime,
    required this.totalPrice,
    required this.currency,
    required this.timezone,
  });

  factory Order.fromCartItems({
    required List<CartItem> cartItems,
    required String currency,
    required String timezone,
  }) {
    return Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: cartItems.map((item) => OrderItem.fromCartItem(item)).toList(),
      checkoutTime: DateTime.now(),
      totalPrice: cartItems.fold(0, (sum, item) => sum + (item.product.discountedPrice * item.quantity)),
      currency: currency,
      timezone: timezone,
    );
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy HH:mm').format(checkoutTime);
  }

  String get formattedTotal {
    final format = NumberFormat.currency(
      locale: currency == 'IDR' ? 'id_ID' : 'en_US',
      symbol: currency == 'IDR' ? 'Rp' : currency == 'USD' ? '\$' : '€',
    );
    return format.format(totalPrice);
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.imageUrl,
  });

  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      productId: cartItem.product.id,
      productName: cartItem.product.name,
      productPrice: cartItem.product.discountedPrice,
      quantity: cartItem.quantity,
      imageUrl: cartItem.product.imageUrl,
    );
  }

  double get totalPrice => productPrice * quantity;

  String get formattedPrice {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
    ).format(productPrice);
  }
}

// Tambahkan model CartItem jika belum ada di file terpisah
class CartItem {
  final EggProduct product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.discountedPrice * quantity;
}