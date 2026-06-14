import 'package:flutter/material.dart';

class CoffeeItemCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final String? originalPrice; // Harga sebelum diskon (opsional)
  final bool isPromo;
  final bool isAvailable;
  final VoidCallback onAddPressed;

  const CoffeeItemCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.isPromo = false,
    this.isAvailable = true,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      surfaceTintColor: Colors.white, // Mencegah warna berubah menjadi sedikit ungu/kuning di Material 3
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1), // Outline tipis
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gambar & Badges
          Stack(
            children: [
              // Gambar Kopi
              Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                // Efek abu-abu jika stok habis
                color: isAvailable ? null : Colors.white.withOpacity(0.5),
                colorBlendMode: isAvailable ? null : BlendMode.lighten,
              ),
              // Label Tersedia / Habis
              Positioned(
                top: 8,
                left: 8,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable ? const Color(0xFFE6F0EB) : const Color(0xFFF2F4F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAvailable ? 'Tersedia' : 'Habis',
                        style: TextStyle(
                          color: isAvailable ? theme.colorScheme.primary : const Color(0xFF6D7A73),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Label Promo (Hanya muncul jika isPromo true)
                    if (isPromo)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error, // Merah untuk promo
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Promo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          // 2. Detail Produk
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 14, color: const Color(0xFF191C1F)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, color: const Color(0xFF3D4943)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(), // Mendorong harga & tombol ke bawah
                  
                  // Baris Harga & Tombol Add
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (originalPrice != null)
                            Text(
                              originalPrice!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.error,
                                decoration: TextDecoration.lineThrough, // Efek coret
                              ),
                            ),
                          Text(
                            price,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: isAvailable ? onAddPressed : null, // Matikan klik jika habis
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isAvailable ? theme.colorScheme.primary : const Color(0xFFE0E2E6),
                            borderRadius: BorderRadius.circular(10), // rounded-lg
                          ),
                          child: Icon(
                            Icons.add,
                            color: isAvailable ? Colors.white : const Color(0xFFBCCAC1),
                            size: 18,
                          ),
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
    );
  }
}