import 'package:intl/intl.dart';
import 'egg_product.dart';

class Order {
  final String id;
  final String userId;
  final String orderNumber;
  final double totalAmount;
  final String status;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? shippingAddress;
  final String? notes;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.shippingAddress,
    this.notes,
    required this.orderDate,
    this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'orderNumber': orderNumber,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'shippingAddress': shippingAddress,
      'notes': notes,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      userId: map['userId'] as String,
      orderNumber: map['orderNumber'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: map['status'] as String,
      paymentMethod: map['paymentMethod'] as String?,
      paymentStatus: map['paymentStatus'] as String?,
      shippingAddress: map['shippingAddress'] as String?,
      notes: map['notes'] as String?,
      orderDate: DateTime.parse(map['orderDate'] as String),
      deliveryDate: map['deliveryDate'] != null
          ? DateTime.parse(map['deliveryDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      items: [], // Items will be loaded separately
    );
  }

  factory Order.fromCartItems({
    required String userId,
    required List<CartItem> cartItems,
    required String orderNumber,
    String? paymentMethod,
    String? shippingAddress,
    String? notes,
  }) {
    final now = DateTime.now();
    final generatedId = now.millisecondsSinceEpoch.toString();

    return Order(
      id: generatedId,
      userId: userId,
      orderNumber: orderNumber,
      totalAmount: cartItems.fold(
        0,
        (sum, item) => sum + (item.product.discountedPrice * item.quantity),
      ),
      status: 'pending',
      paymentMethod: paymentMethod,
      paymentStatus: 'unpaid',
      shippingAddress: shippingAddress,
      notes: notes,
      orderDate: now,
      deliveryDate: null,
      createdAt: now,
      updatedAt: now,
      items: cartItems
          .map((item) => OrderItem.fromCartItem(item, generatedId))
          .toList(),
    );
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy HH:mm').format(orderDate);
  }

  String get formattedTotal {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(totalAmount);
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String,
      orderId: map['orderId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  factory OrderItem.fromCartItem(CartItem cartItem, String orderId) {
    return OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: orderId,
      productId: cartItem.product.id,
      productName: cartItem.product.name,
      quantity: cartItem.quantity,
      price: cartItem.product.discountedPrice,
      subtotal: cartItem.product.discountedPrice * cartItem.quantity,
    );
  }

  String get formattedPrice {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(price);
  }

  String get formattedSubtotal {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(subtotal);
  }
}

class CartItem {
  final String id;
  final String userId;
  final String productId;
  final EggProduct product;
  final int quantity;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, EggProduct product) {
    return CartItem(
      id: map['id'] as String,
      userId: map['userId'] as String,
      productId: map['productId'] as String,
      product: product,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  double get totalPrice => product.discountedPrice * quantity;
}
