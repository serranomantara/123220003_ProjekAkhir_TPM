import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
    'US': 'United States (US)',
    'GERMANY': 'Germany (DE)',
    'London': 'London Time (GMT)',
  };

  // Data lokasi toko di Jogja
  List<Map<String, dynamic>> get storeLocations {
    // Return only stores that carry this specific product
    switch (widget.product.id) {
      case 1: // Product ID 1
        return [
          {
            'name': 'Toko Telur Seturan',
            'address': 'Jl. Seturan Raya No. 5, Depok, Sleman',
            'lat': -7.7619,
            'lng': 110.4081,
            'phone': '081234567890',
            'hours': '08:00 - 20:00 (Setiap Hari)',
          },
          {
            'name': 'Toko Telur Condongcatur',
            'address': 'Jl. Ringroad Utara No. 12, Condongcatur, Sleman',
            'lat': -7.7478,
            'lng': 110.4029,
            'phone': '081234567891',
            'hours': '07:30 - 19:30 (Setiap Hari)',
          },
        ];
      case 2: // Product ID 2
        return [
          {
            'name': 'Toko Telur Babarsari',
            'address': 'Jl. Babarsari No. 8, Caturtunggal, Depok, Sleman',
            'lat': -7.7714,
            'lng': 110.4142,
            'phone': '081234567892',
            'hours': '08:00 - 21:00 (Setiap Hari)',
          },
        ];
      case 3: // Product ID 3
        return [
          {
            'name': 'Toko Telur Demangan',
            'address': 'Jl. Demangan Baru No. 15, Gondokusuman, Yogyakarta',
            'lat': -7.7825,
            'lng': 110.3858,
            'phone': '081234567893',
            'hours': '09:00 - 20:00 (Senin-Sabtu)',
          },
          {
            'name': 'Toko Telur Pujokusuman',
            'address':
                'Jl. Pujokusuman No. 3, Sorosutan, Umbulharjo, Yogyakarta',
            'lat': -7.8156,
            'lng': 110.3689,
            'phone': '081234567894',
            'hours': '08:30 - 19:30 (Setiap Hari)',
          },
          {
            'name': 'Toko Telur Seturan',
            'address': 'Jl. Seturan Raya No. 5, Depok, Sleman',
            'lat': -7.7619,
            'lng': 110.4081,
            'phone': '081234567890',
            'hours': '08:00 - 20:00 (Setiap Hari)',
          },
        ];
      default: // Default case
        return [
          {
            'name': 'Toko Telur Pusat',
            'address': 'Jl. Solo No. 10, Yogyakarta',
            'lat': -7.7828,
            'lng': 110.3671,
            'phone': '081234567895',
            'hours': '08:00 - 21:00 (Setiap Hari)',
          },
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    final cartService = Provider.of<CartService>(context, listen: false);

    // Initialize with cart service values if they exist
    selectedTimezone = cartService.lockedTimezone ?? 'WIB';

    // Handle currency initialization based on timezone
    if (cartService.lockedCurrency != null) {
      selectedCurrency = cartService.lockedCurrency!;
    } else {
      selectedCurrency = _getCurrencyForTimezone(selectedTimezone);
    }

    // Store the previous currency (excluding locked currencies)
    previousCurrency = selectedCurrency;
  }

  String _getCurrencyForTimezone(String timezone) {
    switch (timezone) {
      case 'WIB':
      case 'WITA':
      case 'WIT':
        return 'IDR';
      case 'US':
        return 'USD';
      case 'GERMANY':
        return 'EUR';
      case 'London':
        return 'GBP';
      default:
        return 'IDR';
    }
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

  Future<void> _launchMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
                                                          : entry.key == 'US' ||
                                                                entry.key ==
                                                                    'GERMANY'
                                                          ? Icons.flag
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
                                              if (value != null) {
                                                setState(() {
                                                  // Store previous currency only if not in cart
                                                  if (cartService
                                                      .cartItems
                                                      .isEmpty) {
                                                    previousCurrency =
                                                        selectedCurrency;
                                                  }

                                                  selectedTimezone = value;
                                                  // Automatically set currency based on timezone
                                                  selectedCurrency =
                                                      _getCurrencyForTimezone(
                                                        value,
                                                      );
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  if (cartService.cartItems.isEmpty) ...[
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
                                              items: ['IDR', 'USD', 'EUR', 'GBP']
                                                  .where((currency) {
                                                    // Only show currencies that match the timezone
                                                    switch (selectedTimezone) {
                                                      case 'WIB':
                                                      case 'WITA':
                                                      case 'WIT':
                                                        return currency ==
                                                            'IDR';
                                                      case 'US':
                                                        return currency ==
                                                            'USD';
                                                      case 'GERMANY':
                                                        return currency ==
                                                            'EUR';
                                                      case 'London':
                                                        return currency ==
                                                            'GBP';
                                                      default:
                                                        return true;
                                                    }
                                                  })
                                                  .map((currency) {
                                                    return DropdownMenuItem(
                                                      value: currency,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            currencySymbols[currency]!,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .blue
                                                                  .shade600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            currency,
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
                                                  })
                                                  .toList(),
                                              onChanged: (value) {
                                                if (value != null &&
                                                    cartService
                                                        .cartItems
                                                        .isEmpty) {
                                                  setState(() {
                                                    selectedCurrency = value;
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
                                              'Mata uang terkunci ke $selectedCurrency karena ada item di keranjang',
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

                            const SizedBox(height: 24),

                            // Bagian untuk menampilkan lokasi toko yang menjual produk ini
                            Text(
                              'Lokasi Toko Offline',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Anda dapat membeli produk ini langsung di toko kami di daerah Jogja:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (storeLocations.isNotEmpty)
                              ...storeLocations
                                  .map((store) => _buildStoreCard(store))
                                  .toList()
                            else
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Produk ini saat ini tidak tersedia di toko offline',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
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

  Widget _buildStoreCard(Map<String, dynamic> store) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.asset(
              'assets/store_placeholder.jpg', // Ganti dengan gambar toko jika ada
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: Colors.grey.shade200,
                child: Center(
                  child: Icon(
                    Icons.store,
                    size: 40,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        store['address'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      store['hours'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.map, size: 16),
                        label: const Text('Buka di Maps'),
                        onPressed: () =>
                            _launchMaps(store['lat'], store['lng']),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                          side: BorderSide(color: Colors.green.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Hubungi'),
                        onPressed: () => _makePhoneCall(store['phone']),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                          side: BorderSide(color: Colors.blue.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}