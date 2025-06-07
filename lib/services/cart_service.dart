import 'package:intl/intl.dart';
import '../models/egg_product.dart';

class CartItem {
  final EggProduct product;
  int quantity;
  final String currency;
  final String timezone;
  
  double get totalPrice => product.discountedPrice * quantity;

  CartItem({
    required this.product,
    required this.currency,
    required this.timezone,
    this.quantity = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id &&
          timezone == other.timezone;

  @override
  int get hashCode => product.id.hashCode ^ timezone.hashCode;
}

class Order {
  final List<CartItem> items;
  final DateTime checkoutTime;
  final double totalPrice;
  final String currency;
  final String timezone;

  Order({
    required this.items,
    required this.checkoutTime,
    required this.totalPrice,
    required this.currency,
    required this.timezone,
  });

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

class CartService {
  static final List<CartItem> _cartItems = [];
  static final List<Order> _orders = [];

  static List<CartItem> get cartItems => _cartItems;
  static List<Order> get orders => _orders;

  static void addToCartWithQuantity(EggProduct product, int quantity, String currency, String timezone) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id && item.timezone == timezone,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        currency: currency,
        timezone: timezone,
      ));
    }
  }

  static void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      _cartItems[index].quantity = newQuantity;
    } else {
      _cartItems.removeAt(index);
    }
  }

  static void removeItem(int index) {
    _cartItems.removeAt(index);
  }

  static void clearCart() {
    _cartItems.clear();
  }

  static void checkoutSingleItem(int index, String currency, String timezone) {
    final item = _cartItems[index];
    _checkoutItems([item], currency, timezone);
    _cartItems.removeAt(index);
  }

  static void checkoutAllItems(String currency, String timezone) {
    if (_cartItems.isEmpty) return;
    _checkoutItems(List.from(_cartItems), currency, timezone);
    _cartItems.clear();
  }

  static void _checkoutItems(List<CartItem> items, String currency, String timezone) {
    final now = DateTime.now();
    _orders.add(Order(
      items: List.from(items),
      checkoutTime: now,
      totalPrice: items.fold(0, (sum, item) => sum + item.totalPrice),
      currency: currency,
      timezone: timezone,
    ));
  }

  static double getTotalPrice() {
    return _cartItems.fold(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  static int getTotalQuantity() {
    return _cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  static List<Order> getFilteredOrders(String filter) {
    final now = DateTime.now();
    switch (filter) {
      case 'Hari Ini':
        return _orders.where((order) {
          return order.checkoutTime.year == now.year &&
              order.checkoutTime.month == now.month &&
              order.checkoutTime.day == now.day;
        }).toList();
      case 'Minggu Ini':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return _orders.where((order) {
          return order.checkoutTime.isAfter(startOfWeek);
        }).toList();
      case 'Bulan Ini':
        return _orders.where((order) {
          return order.checkoutTime.year == now.year &&
              order.checkoutTime.month == now.month;
        }).toList();
      case 'Tahun Ini':
        return _orders.where((order) {
          return order.checkoutTime.year == now.year;
        }).toList();
      default:
        return _orders;
    }
  }
}