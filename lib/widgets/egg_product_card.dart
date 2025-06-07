// egg_product_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/egg_product.dart';

class EggProductCard extends StatelessWidget {
  final EggProduct product;
  final VoidCallback onTap;

  const EggProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar produk dengan badge diskon
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        image: DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {},
                        ),
                        color: Colors.green.shade100,
                      ),
                      child: product.imageUrl.isEmpty
                          ? Center(
                              child: Icon(
                                Icons.egg_outlined,
                                size: 40,
                                color: Colors.green.shade400,
                              ),
                            )
                          : null,
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.green.shade900.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Diskon badge
                    if (product.isOnDiscount)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
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
              // Info produk
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama produk
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Harga
                      Row(
                        children: [
                          if (product.isOnDiscount)
                            Text(
                              currencyFormat.format(product.price),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            currencyFormat.format(product.discountedPrice),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Organic & Rating
                      Row(
                        children: [
                          Icon(
                            product.isOrganic ? Icons.eco : Icons.eco_outlined,
                            size: 14,
                            color: product.isOrganic ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.isOrganic ? 'Organik' : 'Non-organik',
                            style: TextStyle(
                              fontSize: 12,
                              color: product.isOrganic ? Colors.green.shade700 : Colors.black54,
                            ),
                          ),
                          const Spacer(),
                          if (product.rating != null)
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  '${product.rating?.toStringAsFixed(1)}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Stok
                      Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text(
                            product.isLowStock ? 'Stok Hampir Habis' : 'Stok: ${product.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: product.isLowStock ? Colors.red : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
