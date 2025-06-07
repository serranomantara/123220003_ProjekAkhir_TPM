import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/egg_product.dart';
import '../services/cart_service.dart';
import 'cart_page.dart';

class EggProductDetailPage extends StatefulWidget {
  final EggProduct product;

  const EggProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<EggProductDetailPage> createState() => _EggProductDetailPageState();
}

class _EggProductDetailPageState extends State<EggProductDetailPage> {
  int quantity = 1;
  String selectedCurrency = 'IDR';
  String selectedTimezone = 'WIB';
  String? previousCurrency;
  
  // Exchange rates (dalam praktik nyata, ini harus diambil dari API)
  final Map<String, double> exchangeRates = {
    'IDR': 1.0,
    'USD': 0.000067, // 1 IDR = 0.000067 USD (contoh)
    'EUR': 0.000061, // 1 IDR = 0.000061 EUR (contoh)
    'GBP': 0.000053, // 1 IDR = 0.000053 GBP (contoh)
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
    // Inisialisasi previousCurrency
    previousCurrency = selectedCurrency;
  }

  double convertPrice(double priceInIDR) {
    try {
      String currency = getCurrentCurrency();
      double rate = exchangeRates[currency] ?? 1.0;
      return priceInIDR * rate;
    } catch (e) {
      // Fallback jika ada error
      return priceInIDR;
    }
  }

  String getCurrentCurrency() {
    if (selectedTimezone == 'London') {
      return 'GBP';
    }
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
      // Fallback jika ada error dengan format
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = getCurrencyFormat();
    final product = widget.product;
    final convertedPrice = convertPrice(product.discountedPrice);
    final convertedOriginalPrice = convertPrice(product.price);
    final totalPrice = convertedPrice * quantity;

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
              colors: [
                Colors.green.shade800,
                Colors.green.shade600,
              ],
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
              Color(0xFF2E7D32), // Hijau gelap (Green-800)
              Color(0xFF4CAF50), // Hijau sedang (Green-600)
              Color(0xFF81C784), // Hijau muda (Green-300)
              Color(0xFFE8F5E9), // Hijau sangat muda (Green-50)
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
                // Product Image Section
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
                          colors: [
                            Colors.white,
                            Colors.green.shade50,
                          ],
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
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

                // Product Details Section
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
                          colors: [
                            Colors.white,
                            Colors.green.shade50,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Header
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

                            // Currency and Timezone Selection
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
                                  
                                  // Timezone Selection
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.blue.shade300),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedTimezone,
                                            isExpanded: true,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            items: timezones.entries.map((entry) {
                                              return DropdownMenuItem(
                                                value: entry.key,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      entry.key == 'London' 
                                                        ? Icons.location_city 
                                                        : Icons.access_time,
                                                      size: 16,
                                                      color: Colors.blue.shade600,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      entry.value,
                                                      style: TextStyle(
                                                        color: Colors.blue.shade800,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                // Simpan currency sebelumnya jika bukan London
                                                if (selectedTimezone != 'London') {
                                                  previousCurrency = selectedCurrency;
                                                }
                                                
                                                selectedTimezone = value!;
                                                
                                                if (value == 'London') {
                                                  // Auto set currency to GBP for London
                                                  selectedCurrency = 'GBP';
                                                } else {
                                                  // Restore previous currency or default to IDR
                                                  selectedCurrency = previousCurrency ?? 'IDR';
                                                  // Pastikan currency yang dipilih valid untuk non-London
                                                  if (!['IDR', 'USD', 'EUR'].contains(selectedCurrency)) {
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
                                  
                                  // Currency Selection (only if not London)
                                  if (selectedTimezone != 'London') ...[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.blue.shade300),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: selectedCurrency,
                                              isExpanded: true,
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              items: ['IDR', 'USD', 'EUR'].map((currency) {
                                                return DropdownMenuItem(
                                                  value: currency,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        currencySymbols[currency]!,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.blue.shade600,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        currency,
                                                        style: TextStyle(
                                                          color: Colors.blue.shade800,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    selectedCurrency = value;
                                                    previousCurrency = value;
                                                  });
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
                                        border: Border.all(color: Colors.orange.shade200),
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

                            // Price Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (product.isOnDiscount) ...[
                                        Text(
                                          currencyFormat.format(convertedOriginalPrice),
                                          style: TextStyle(
                                            fontSize: 16,
                                            decoration: TextDecoration.lineThrough,
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

                            // Rating Section
                            if (product.rating != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, color: Colors.orange.shade600, size: 20),
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

                            // Description
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
                                border: Border.all(color: Colors.green.shade200),
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

                            // Product Information
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
                            _buildInfoCard('Stok', product.stock.toString()),
                            _buildInfoCard('Berat', product.weight != null ? '${product.weight} gram' : '-'),
                            _buildInfoCard('Asal Peternakan', product.farmOrigin),
                            _buildInfoCard(
                              'Tanggal Panen',
                              product.harvestDate != null
                                  ? DateFormat.yMMMMd('id_ID').format(product.harvestDate!)
                                  : '-',
                            ),
                            _buildInfoCard('Organik', product.isOrganic ? 'Ya' : 'Tidak'),

                            const SizedBox(height: 32),

                            // Quantity Section
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.green.shade300),
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
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                if (quantity < product.stock) {
                                                  setState(() => quantity++);
                                                }
                                              },
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: Colors.green.shade600,
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                            // Add to Cart Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Bisa menambahkan logic untuk menyimpan currency dan timezone ke cart item
                                  CartService.addToCartWithQuantity(product, quantity, selectedCurrency, selectedTimezone);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Berhasil menambahkan $quantity ${product.name} ke keranjang\n'
                                        'Tujuan: ${timezones[selectedTimezone]}\n'
                                        'Mata Uang: ${getCurrentCurrency()}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.green.shade600,
                                      duration: const Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.green.withOpacity(0.4),
                                ),
                                label: const Text(
                                  "Tambahkan ke Keranjang",
                                  style: TextStyle(
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