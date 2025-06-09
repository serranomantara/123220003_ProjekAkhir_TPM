import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../helpers/database_helper.dart';

class OrderPage extends StatefulWidget {
  final String selectedCurrency;
  final String selectedTimezone;

  const OrderPage({
    super.key,
    required this.selectedCurrency,
    required this.selectedTimezone,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String _selectedFilter = 'Hari Ini';
  final List<String> _filterOptions = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Tahun Ini',
    'Semua',
  ];

  static const Map<String, String> _currencySymbols = {
    'IDR': 'Rp',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
  };

  static const Map<String, Duration> _zoneOffsets = {
    'WIB': Duration(hours: 7),
    'WITA': Duration(hours: 8),
    'WIT': Duration(hours: 9),
    'London': Duration(hours: 0),
  };

  // Use the same exchange rates as detail_page.dart
  // These rates convert FROM IDR to the target currency
  static const Map<String, double> _exchangeRates = {
    'IDR': 1.0, // 1 IDR = 1 IDR
    'USD': 0.000067, // 1 IDR = 0.000067 USD
    'EUR': 0.000061, // 1 IDR = 0.000061 EUR
    'GBP': 0.000053, // 1 IDR = 0.000053 GBP
  };

  // Convert price from IDR to target currency (same logic as detail_page.dart)
  double _convertPriceFromIDR(double priceInIDR, String targetCurrency) {
    try {
      double rate = _exchangeRates[targetCurrency] ?? 1.0;
      return priceInIDR * rate;
    } catch (e) {
      return priceInIDR;
    }
  }

  // Convert price from any currency to target currency via IDR
  double _convertPrice(
    double price,
    String sourceCurrency,
    String targetCurrency,
  ) {
    if (sourceCurrency == targetCurrency) {
      return price; // No conversion needed if currencies are the same
    }

    // Step 1: Convert source currency to IDR
    double priceInIDR;
    if (sourceCurrency == 'IDR') {
      priceInIDR = price;
    } else {
      // Convert from source currency back to IDR
      double sourceRate = _exchangeRates[sourceCurrency] ?? 1.0;
      if (sourceRate == 0) sourceRate = 1.0; // Prevent division by zero
      priceInIDR = price / sourceRate;
    }

    // Step 2: Convert from IDR to target currency
    return _convertPriceFromIDR(priceInIDR, targetCurrency);
  }

  // Get currency format for the selected currency (same logic as detail_page.dart)
  NumberFormat _getCurrencyFormat(String currency) {
    String symbol = _currencySymbols[currency] ?? 'Rp';

    try {
      if (currency == 'IDR') {
        return NumberFormat.currency(
          locale: 'id_ID',
          symbol: symbol,
          decimalDigits: 0,
        );
      } else {
        return NumberFormat.currency(
          locale: 'en_US',
          symbol: symbol,
          decimalDigits: 2,
        );
      }
    } catch (e) {
      // Fallback to IDR format if there's an error
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final filteredOrders = cartService.getFilteredOrders(
          _selectedFilter,
          timezoneOffset:
              _zoneOffsets[widget.selectedTimezone] ?? const Duration(hours: 7),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Riwayat Pesanan'),
            backgroundColor: Colors.green[800],
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _buildCurrencyInfo(),
                      const SizedBox(width: 8),
                      _buildTimezoneInfo(),
                    ],
                  ),
                ),
                _buildFilterDropdown(),
                Expanded(
                  child: filteredOrders.isEmpty
                      ? _buildEmptyOrder()
                      : _buildOrderList(filteredOrders),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.currency_exchange, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Default: ${_currencySymbols[widget.selectedCurrency]} ${widget.selectedCurrency}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTimezoneInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.selectedTimezone == 'London'
                ? Icons.location_city
                : Icons.access_time,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            'Zona Waktu: ${widget.selectedTimezone}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 8,
        shadowColor: Colors.green.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.green.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFilter,
              items: _filterOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedFilter = value!),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.green.shade600,
              ),
              dropdownColor: Colors.green.shade50,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOrder() {
    return Center(
      child: Text(
        'Belum ada riwayat pesanan',
        style: TextStyle(
          color: Colors.green.shade800,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    final currencyFormat = _getCurrencyFormat(widget.selectedCurrency);

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final adjustedTime = order.checkoutTime.toUtc().add(
          _zoneOffsets[widget.selectedTimezone] ?? const Duration(hours: 7),
        );

        // Convert order total from its original currency to selected currency
        double convertedTotal = _convertPrice(
          order.totalPrice,
          order.currency,
          widget.selectedCurrency,
        );

        return Card(
          elevation: 8,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pesanan #${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Show original currency of the order
                            Text(
                              '${_currencySymbols[order.currency]} ${order.currency}',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            // Indicate conversion if target currency is different
                            if (order.currency != widget.selectedCurrency) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 12,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_currencySymbols[widget.selectedCurrency]} ${widget.selectedCurrency}',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        // Display order time adjusted to widget.selectedTimezone
                        DateFormat(
                          'EEEE, d MMMM y - HH:mm',
                          'id_ID',
                        ).format(adjustedTime),
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (order.timezone != widget.selectedTimezone) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pesanan dibuat di zona waktu: ${order.timezone}',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Column(
                    // Pass the order's original currency to the item builder for correct conversion context
                    children: order.items
                        .map((item) => _buildOrderItem(item, order.currency))
                        .toList(),
                  ),
                  const Divider(thickness: 1, height: 24),
                  Column(
                    children: [
                      // Always show the total in original currency (more prominent)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            order
                                .formattedTotal, // This uses CurrencyHelper from cart_service.dart
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      // Show converted total if the order's currency is different from the displayed currency
                      if (order.currency != widget.selectedCurrency) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total (${widget.selectedCurrency})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                              currencyFormat.format(convertedTotal),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(CartItem item, String orderOriginalCurrency) {
    // Use the original currency format for item display
    final originalCurrencyFormat = _getCurrencyFormat(item.currency);

    // Convert item total from its original currency to the user's selected display currency (only for secondary display)
    double convertedItemTotal = _convertPrice(
      item.totalPrice,
      item.currency,
      widget.selectedCurrency,
    );

    final selectedCurrencyFormat = _getCurrencyFormat(widget.selectedCurrency);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.egg_alt, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.product.name} x${item.quantity}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              // Display the item price in its original currency (bold)
              Text(
                originalCurrencyFormat.format(item.totalPrice),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Show converted price if different currency is selected
          if (item.currency != widget.selectedCurrency) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const SizedBox(width: 28), // Align with the text above
                Expanded(
                  child: Text(
                    '(${widget.selectedCurrency})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Text(
                  selectedCurrencyFormat.format(convertedItemTotal),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
