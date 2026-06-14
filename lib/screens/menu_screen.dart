import 'package:flutter/material.dart';
import '../widgets/coffee_item_card.dart';
import 'product_detail_screen.dart';
import 'checkout_screen.dart';
import 'order_list_screen.dart';
// Import card yang sudah kita buat

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: const Color(0xFF6D7A73),
              ),
            ),
            Text(
              'Halo, Perdi!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // --- 1. IKON SHOPPING BAG (Baru) ---
          Center(
            child: GestureDetector(
              onTap: () {
                // Menuju halaman Daftar Pesanan
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderListScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined, // Ikon tas belanja
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12), // Jarak antara tas belanja dan keranjang
          // --- 2. IKON KERANJANG (Yang sudah ada sebelumnya) ---
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                },
                child: Badge(
                  label: const Text(
                    '2',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  backgroundColor: theme.colorScheme.error,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined, // Ikon keranjang
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // --- KATEGORI CHIPS ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildCategoryChip(theme, 'Semua', isActive: true),
                const SizedBox(width: 12),
                _buildCategoryChip(theme, 'Espresso Based'),
                const SizedBox(width: 12),
                _buildCategoryChip(theme, 'Manual Brew'),
                const SizedBox(width: 12),
                _buildCategoryChip(theme, 'Non-Coffee'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- GRID PRODUK ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 Kolom
                childAspectRatio:
                    0.58, // Rasio agar tinggi card cukup menampung semua teks
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4, // Menyesuaikan dummy data
              itemBuilder: (context, index) {
                // Dummy Data Logic untuk meniru desain
                if (index == 0) {
                  return CoffeeItemCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1572442388796-11668a67e53d?q=80&w=400&auto=format&fit=crop',
                    name: 'Aren Latte',
                    description: 'Espresso, milk, palm sugar.',
                    price: 'Rp 28.000',
                    originalPrice: 'Rp 35.000',
                    isPromo: true,
                    onAddPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductDetailScreen(),
                        ),
                      );
                    },
                  );
                } else if (index == 1) {
                  return CoffeeItemCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1551030173-122aabc4489c?q=80&w=400&auto=format&fit=crop',
                    name: 'Classic Americano',
                    description: 'Double shot espresso & water.',
                    price: 'Rp 22.000',
                    onAddPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductDetailScreen(),
                        ),
                      );
                    },
                  );
                } else if (index == 2) {
                  return CoffeeItemCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1534778101976-62847782c213?q=80&w=400&auto=format&fit=crop',
                    name: 'Cappuccino',
                    description: 'Espresso with thick milk foam.',
                    price: 'Rp 28.000',
                    isAvailable: false, // Stok Habis
                    onAddPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductDetailScreen(),
                        ),
                      );
                    },
                  );
                } else {
                  return CoffeeItemCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1558403194-611308249627?q=80&w=400&auto=format&fit=crop',
                    name: 'Caramel Macchiato',
                    description: 'Vanilla, milk, espresso, caramel.',
                    price: 'Rp 32.000',
                    originalPrice: 'Rp 40.000',
                    isPromo: true,
                    onAddPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductDetailScreen(),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk Category Chip
  Widget _buildCategoryChip(
    ThemeData theme,
    String label, {
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary : const Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF3D4943),
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
