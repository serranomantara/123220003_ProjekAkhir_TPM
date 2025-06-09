import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/egg_product.dart';

class CurrencyHelper {
  static String formatPrice(double price, String currency) {
    // Handle potential NaN or infinity
    if (price.isNaN || price.isInfinite) {
      if (kDebugMode) {
        print(
          'Warning: Attempting to format NaN/Infinity price: $price for $currency',
        );
      }
      return 'N/A'; // Or some other appropriate error indicator
    }

    final format = NumberFormat.currency(
      locale: currency == 'IDR' ? 'id_ID' : 'en_US',
      symbol: _getCurrencySymbol(currency),
      decimalDigits: currency == 'IDR' ? 0 : 2,
    );
    return format.format(price);
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default: // IDR
        return 'Rp';
    }
  }
}

class CartItem {
  final EggProduct product;
  int quantity;
  final String currency; // The currency this item's price is stored in
  final String timezone;

  // totalPrice is now calculated dynamically, assuming product.discountedPrice is in IDR
  double get totalPrice {
    // If currency is IDR, no conversion needed for product price
    if (currency == 'IDR') {
      return product.discountedPrice * quantity;
    } else {
      // Convert product.discountedPrice (assumed IDR) to this CartItem's currency
      return CartService.convertPriceStatic(
            product.discountedPrice,
            'IDR',
            currency,
          ) *
          quantity;
    }
  }

  String get formattedTotal => CurrencyHelper.formatPrice(totalPrice, currency);

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
          currency == other.currency &&
          timezone == other.timezone;

  @override
  int get hashCode =>
      product.id.hashCode ^ currency.hashCode ^ timezone.hashCode;
}

class CartService extends ChangeNotifier {
  final List<CartItem> _cartItems = [];
  final List<Order> _orders = [];
  String? _lockedCurrency;
  String? _lockedTimezone;

  List<CartItem> get cartItems => _cartItems;
  List<Order> get orders => _orders;
  String? get lockedCurrency => _lockedCurrency;
  String? get lockedTimezone => _lockedTimezone;

  // Exchange rates: How many units of OTHER currency equals 1 IDR.
  // This makes IDR our explicit pivot.
  static const Map<String, double> _exchangeRates = {
    'IDR': 1.0, // 1 IDR = 1 IDR
    'USD': 0.000067, // 1 IDR = 0.000067 USD (approx. 1 USD = 15000 IDR)
    'EUR': 0.000061, // 1 IDR = 0.000061 EUR (approx. 1 EUR = 16500 IDR)
    'GBP': 0.000053, // 1 IDR = 0.000053 GBP (approx. 1 GBP = 19000 IDR)
  };

  // Static method for currency conversion, accessible by CartItem and OrderPage
  static double convertPriceStatic(
    double price,
    String sourceCurrency,
    String targetCurrency,
  ) {
    if (sourceCurrency == targetCurrency) {
      return price; // No conversion needed if currencies are the same
    }

    double priceInIDR;
    // Step 1: Convert the price from sourceCurrency to IDR
    if (sourceCurrency == 'IDR') {
      priceInIDR = price;
    } else {
      double sourceRate = _exchangeRates[sourceCurrency] ?? 0.0;
      if (sourceRate == 0) {
        if (kDebugMode) {
          print('Error: Exchange rate for $sourceCurrency is 0 or not found.');
        }
        return 0.0; // Prevent division by zero or invalid calculation
      }
      // If 1 IDR = X USD, then 1 USD = 1/X IDR
      priceInIDR = price / sourceRate;
    }

    // Step 2: Convert the price from IDR to targetCurrency
    if (targetCurrency == 'IDR') {
      return priceInIDR;
    } else {
      double targetRate = _exchangeRates[targetCurrency] ?? 0.0;
      if (targetRate == 0) {
        if (kDebugMode) {
          print('Error: Exchange rate for $targetCurrency is 0 or not found.');
        }
        return 0.0; // Prevent division by zero or invalid calculation
      }
      // If 1 IDR = Y USD, then price in IDR * Y = price in USD
      return priceInIDR * targetRate;
    }
  }

  void addToCartWithQuantity(
    EggProduct product,
    int quantity,
    String currency, // The currency selected by the user for the cart
    String timezone,
  ) {
    if (quantity <= 0) {
      throw CartException('Jumlah harus lebih dari 0');
    }

    if (_cartItems.isEmpty) {
      _lockedCurrency = currency;
      _lockedTimezone = timezone;
    } else {
      if (_lockedCurrency != currency) {
        throw CartException(
          'Keranjang sudah menggunakan mata uang $_lockedCurrency.\n'
          'Tidak bisa menambahkan item dengan mata uang berbeda.',
        );
      }

      if (_lockedTimezone != timezone) {
        throw CartException(
          'Keranjang sudah menggunakan zona waktu $_lockedTimezone.\n'
          'Tidak bisa menambahkan item dengan zona waktu berbeda.',
        );
      }
    }

    // Before adding/updating, check stock
    final existingQuantityInCart = _cartItems
        .where((item) => item.product.id == product.id)
        .fold(0, (sum, item) => sum + item.quantity);

    if (existingQuantityInCart + quantity > product.stock) {
      throw CartException(
        'Stok tidak mencukupi!\n'
        'Stok tersedia: ${product.stock}\n'
        'Sudah di keranjang: $existingQuantityInCart\n'
        'Jumlah yang akan ditambahkan: $quantity',
      );
    }

    final existingItemIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.currency == currency &&
          item.timezone == timezone,
    );

    if (existingItemIndex >= 0) {
      _cartItems[existingItemIndex].quantity += quantity;
    } else {
      _cartItems.add(
        CartItem(
          product: product,
          quantity: quantity,
          currency: currency, // This currency will dictate CartItem.totalPrice
          timezone: timezone,
        ),
      );
    }

    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(index);
      return;
    }

    final product = _cartItems[index].product;
    final existingQuantity =
        _cartItems
            .where((item) => item.product.id == product.id)
            .fold(0, (sum, item) => sum + item.quantity) -
        _cartItems[index]
            .quantity; // Exclude current item's quantity from existing

    if (existingQuantity + newQuantity > product.stock) {
      throw CartException(
        'Stok tidak mencukupi!\n'
        'Stok tersedia: ${product.stock}\n'
        'Sudah di keranjang: $existingQuantity\n'
        'Jumlah yang akan diubah: $newQuantity',
      );
    }

    _cartItems[index].quantity = newQuantity;
    notifyListeners();
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    if (_cartItems.isEmpty) {
      _lockedCurrency = null;
      _lockedTimezone = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _lockedCurrency = null;
    _lockedTimezone = null;
    notifyListeners();
  }

  void checkoutSingleItem(int index) {
    if (index < 0 || index >= _cartItems.length) return;

    final item = _cartItems[index];
    _checkoutItems([item]);
    _cartItems.removeAt(index);

    if (_cartItems.isEmpty) {
      _lockedCurrency = null;
      _lockedTimezone = null;
    }
    notifyListeners();
  }

  void checkoutAllItems() {
    if (_cartItems.isEmpty) return;

    _checkoutItems(List.from(_cartItems));
    _cartItems.clear();
    _lockedCurrency = null;
    _lockedTimezone = null;
    notifyListeners();
  }

  void _checkoutItems(List<CartItem> items) {
    final now = DateTime.now();
    final firstItem = items.first;

    // totalPrice in Order is already in the _lockedCurrency due to CartItem.totalPrice logic
    _orders.add(
      Order(
        items: List.from(items),
        checkoutTime: now,
        totalPrice: items.fold(0, (sum, item) => sum + item.totalPrice),
        currency: firstItem.currency, // This is the _lockedCurrency of the cart
        timezone: firstItem.timezone,
      ),
    );
  }

  // This will return total price in the _lockedCurrency of the cart
  double getTotalPrice() {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  String getFormattedTotalPrice() {
    if (_cartItems.isEmpty) {
      // If cart is empty, return 0 formatted in the currently selected app currency (if any)
      // or default to IDR if no currency was ever locked.
      // This ensures we always return a string.
      return CurrencyHelper.formatPrice(0, _lockedCurrency ?? 'IDR');
    }
    // Return total price in the _lockedCurrency of the cart
    return CurrencyHelper.formatPrice(
      getTotalPrice(),
      _cartItems.first.currency,
    );
  }

  String getFormattedPrice(double price) {
    if (_cartItems.isEmpty) {
      // Similar to getFormattedTotalPrice, provide a default if cart is empty
      return CurrencyHelper.formatPrice(price, _lockedCurrency ?? 'IDR');
    }
    // Format the given price using the _lockedCurrency of the cart
    return CurrencyHelper.formatPrice(price, _cartItems.first.currency);
  }

  int getTotalQuantity() {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  List<Order> getFilteredOrders(
    String filter, {
    Duration timezoneOffset = const Duration(hours: 7),
  }) {
    final now = DateTime.now().toUtc().add(timezoneOffset);

    return _orders.where((order) {
      final localOrderTime = order.checkoutTime.toUtc().add(timezoneOffset);

      switch (filter) {
        case 'Hari Ini':
          return localOrderTime.year == now.year &&
              localOrderTime.month == now.month &&
              localOrderTime.day == now.day;

        case 'Minggu Ini':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          return localOrderTime.isAfter(startOfWeek) &&
              localOrderTime.isBefore(endOfWeek.add(const Duration(days: 1)));

        case 'Bulan Ini':
          return localOrderTime.year == now.year &&
              localOrderTime.month == now.month;

        case 'Tahun Ini':
          return localOrderTime.year == now.year;

        default:
          return true;
      }
    }).toList();
  }

  bool isProductInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getProductQuantity(String productId) {
    return _cartItems
        .where((item) => item.product.id == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }
}

class CartException implements Exception {
  final String message;
  CartException(this.message);

  @override
  String toString() => message;
}

class Order {
  final List<CartItem> items;
  final DateTime checkoutTime;
  final double totalPrice; // This totalPrice is already in the order's currency
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

  String get formattedTotal => CurrencyHelper.formatPrice(totalPrice, currency);

  String get itemCountText {
    final totalItems = items.fold(0, (sum, item) => sum + item.quantity);
    return '$totalItems item${totalItems > 1 ? 's' : ''}';
  }
}
