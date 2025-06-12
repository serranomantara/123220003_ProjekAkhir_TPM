import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/egg_product.dart';
import '../services/cart_service.dart';
import '../pages/cart_page.dart';
import '../helpers/database_helper.dart';

class EggProductDetailPage extends StatefulWidget {
  final EggProduct product;

  const EggProductDetailPage({super.key, required this.product});

  @override
  State<EggProductDetailPage> createState() => _EggProductDetailPageState();
}

class _EggProductDetailPageState extends State<EggProductDetailPage> {
  int quantity = 1;
  String selectedCurrency = 'IDR';
  String selectedTimezone = 'WIB';
  String? previousCurrency;

  final Map<String, double> exchangeRates = {
    'IDR': 1.0,
    'USD': 0.000067,
    'EUR': 0.000061,
    'GBP': 0.000053,
  };

  final Map<String, String> currencySymbols = {
    'IDR': 'Rp',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
  };

  final Map<String, String> timezones = {
    'WIB': 'Waktu Indonesia Barat (WIB)',
    'WITA': 'Waktu Indonesia Tengah (WITA)',
    'WIT': 'Waktu Indonesia Timur (WIT)',
    'London': 'London Time (GMT)',
  };

  @override
  void initState() {
    super.initState();
    final cartService = Provider.of<CartService>(context, listen: false);

    // Initialize with cart service values if they exist
    selectedTimezone = cartService.lockedTimezone ?? 'WIB';

    // Handle currency initialization carefully
    if (cartService.lockedCurrency != null) {
      selectedCurrency = cartService.lockedCurrency!;
    } else {
      selectedCurrency = selectedTimezone == 'London' ? 'GBP' : 'IDR';
    }

    // Store the previous currency (excluding GBP if not in London)
    previousCurrency = selectedTimezone == 'London' ? 'IDR' : selectedCurrency;
  }

  double convertPrice(double priceInIDR) {
    try {
      String currency = getCurrentCurrency();
      double rate = exchangeRates[currency] ?? 1.0;
      return priceInIDR * rate;
    } catch (e) {
      return priceInIDR;
    }
  }

  String getCurrentCurrency() {
    return selectedCurrency;
  }

  NumberFormat getCurrencyFormat() {
    String currency = getCurrentCurrency();
    String symbol = currencySymbols[currency] ?? 'Rp';

    try {
      if (currency == 'IDR') {
        return NumberFormat.currency(locale: 'id_ID', symbol: symbol);
      } else {
        return NumberFormat.currency(locale: 'en_US', symbol: symbol);
      }
    } catch (e) {
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    }
  }

  int _getItemsInCart() {
    final cartService = Provider.of<CartService>(context, listen: false);
    return cartService.cartItems
        .where((item) => item.product.id == widget.product.id)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  int _getAvailableStock() {
    return widget.product.stock - _getItemsInCart();
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final currencyFormat = getCurrencyFormat();
    final product = widget.product;
    final convertedPrice = convertPrice(product.discountedPrice);
    final convertedOriginalPrice = convertPrice(product.price);
    final totalPrice = convertedPrice * quantity;
    final availableStock = _getAvailableStock();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          product.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.green.shade800.withOpacity(0.95),
        foregroundColor: Colors.white,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
              tooltip: 'Keranjang',
            ),
          ),
        ],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade800, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
              Color(0xFF81C784),
              Color(0xFFE8F5E9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 12,
                    shadowColor: Colors.green.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.green.shade50],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.asset(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.green.shade100,
                                      child: Center(
                                        child: Icon(
                                          Icons.egg_rounded,
                                          size: 64,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          if (product.isOnDiscount)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${product.discount?.toStringAsFixed(0)}% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 12,
                    shadowColor: Colors.green.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.green.shade50],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.egg_rounded,
                                    size: 24,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pengaturan Pesanan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  if (cartService.cartItems.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.orange.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: Colors.orange.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Mata uang terkunci ke ${cartService.lockedCurrency} karena ada item di keranjang',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tujuan Pesanan:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.shade300,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedTimezone,
                                            isExpanded: true,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            items: timezones.entries.map((
                                              entry,
                                            ) {
                                              return DropdownMenuItem(
                                                value: entry.key,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      entry.key == 'London'
                                                          ? Icons.location_city
                                                          : Icons.access_time,
                                                      size: 16,
                                                      color:
                                                          Colors.blue.shade600,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      entry.value,
                                                      style: TextStyle(
                                                        color: Colors
                                                            .blue
                                                            .shade800,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                if (selectedTimezone !=
                                                    'London') {
                                                  previousCurrency =
                                                      selectedCurrency;
                                                }

                                                selectedTimezone = value!;

                                                if (value == 'London') {
                                                  selectedCurrency = 'GBP';
                                                } else {
                                                  selectedCurrency =
                                                      previousCurrency ?? 'IDR';
                                                  if (![
                                                    'IDR',
                                                    'USD',
                                                    'EUR',
                                                  ].contains(
                                                    selectedCurrency,
                                                  )) {
                                                    selectedCurrency = 'IDR';
                                                  }
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  if (selectedTimezone != 'London') ...[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mata Uang:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.shade300,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: selectedCurrency,
                                              isExpanded: true,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              items: ['IDR', 'USD', 'EUR'].map((
                                                currency,
                                              ) {
                                                bool isLockedCurrency =
                                                    cartService
                                                        .lockedCurrency ==
                                                    currency;
                                                bool isSelected =
                                                    selectedCurrency ==
                                                    currency;
                                                bool isAllowed =
                                                    cartService
                                                        .cartItems
                                                        .isEmpty ||
                                                    isLockedCurrency ||
                                                    isSelected;

                                                return DropdownMenuItem(
                                                  value: currency,
                                                  enabled: isAllowed,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        currencySymbols[currency]!,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .blue
                                                              .shade600,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        currency,
                                                        style: TextStyle(
                                                          color: isAllowed
                                                              ? Colors
                                                                    .blue
                                                                    .shade800
                                                              : Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      if (cartService
                                                              .cartItems
                                                              .isNotEmpty &&
                                                          !isLockedCurrency &&
                                                          !isSelected)
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: 8,
                                                              ),
                                                          child: Icon(
                                                            Icons.lock,
                                                            size: 14,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  if (cartService
                                                          .cartItems
                                                          .isEmpty ||
                                                      value ==
                                                          cartService
                                                              .lockedCurrency) {
                                                    setState(() {
                                                      selectedCurrency = value;
                                                      previousCurrency = value;
                                                    });
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Mata uang sudah dipilih sebagai ${cartService.lockedCurrency}. '
                                                          'Tidak bisa mengubah mata uang setelah ada item di keranjang.',
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.red.shade600,
                                                        duration:
                                                            const Duration(
                                                              seconds: 3,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.orange.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.orange.shade600,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Untuk pengiriman ke London, mata uang otomatis dikonversi ke GBP (£)',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (product.isOnDiscount) ...[
                                        Text(
                                          currencyFormat.format(
                                            convertedOriginalPrice,
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Text(
                                        currencyFormat.format(convertedPrice),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (getCurrentCurrency() != 'IDR') ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Harga asli: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(product.discountedPrice)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (product.rating != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.orange.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${product.rating?.toStringAsFixed(1)} (${product.reviewCount ?? 0} ulasan)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 20),

                            Text(
                              'Deskripsi Produk',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Text(
                                product.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              'Informasi Produk',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard('Kategori', product.category),
                            _buildInfoCard(
                              'Stok',
                              '$availableStock tersedia dari ${product.stock}',
                            ),
                            _buildInfoCard(
                              'Berat',
                              product.weight != null
                                  ? '${product.weight} gram'
                                  : '-',
                            ),
                            _buildInfoCard(
                              'Asal Peternakan',
                              product.farmOrigin,
                            ),
                            _buildInfoCard(
                              'Tanggal Panen',
                              product.harvestDate != null
                                  ? DateFormat.yMMMMd(
                                      'id_ID',
                                    ).format(product.harvestDate!)
                                  : '-',
                            ),
                            _buildInfoCard(
                              'Organik',
                              product.isOrganic ? 'Ya' : 'Tidak',
                            ),

                            const SizedBox(height: 32),

                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Jumlah:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.green.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                if (quantity > 1) {
                                                  setState(() => quantity--);
                                                }
                                              },
                                              icon: Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.green.shade600,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              child: Text(
                                                quantity.toString(),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade800,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                if (quantity < availableStock) {
                                                  setState(() => quantity++);
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Stok tidak mencukupi! Stok tersedia: $availableStock',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.red.shade600,
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: quantity < availableStock
                                                    ? Colors.green.shade600
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Harga:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        Text(
                                          currencyFormat.format(totalPrice),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: availableStock > 0
                                    ? () {
                                        try {
                                          cartService.addToCartWithQuantity(
                                            product,
                                            quantity,
                                            getCurrentCurrency(),
                                            selectedTimezone,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Berhasil menambahkan $quantity ${product.name} ke keranjang\n'
                                                'Tujuan: ${timezones[selectedTimezone]}\n'
                                                'Mata Uang: ${getCurrentCurrency()}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor:
                                                  Colors.green.shade600,
                                              duration: const Duration(
                                                seconds: 3,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                          setState(() {});
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                e.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor:
                                                  Colors.red.shade600,
                                              duration: const Duration(
                                                seconds: 3,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                icon: const Icon(
                                  Icons.shopping_cart_rounded,
                                  color: Colors.white,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: availableStock > 0
                                      ? Colors.green.shade600
                                      : Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.green.withOpacity(0.4),
                                ),
                                label: Text(
                                  availableStock > 0
                                      ? "Tambahkan ke Keranjang"
                                      : "Stok Habis",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
