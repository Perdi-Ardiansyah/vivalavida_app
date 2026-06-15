import 'package:flutter/material.dart';
import '../widgets/coffee_item_card.dart';
import 'product_detail_screen.dart';
import 'checkout_screen.dart';
import 'order_list_screen.dart';
import '../services/menu_service.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart'; // Pastikan path ini sesuai dengan file MenuService kamu

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // --- STATE VARIABLES ---
  List<dynamic> _categories = [];
  List<dynamic> _menus = [];
  bool _isLoading = true;
  int _selectedCategoryId = 0; // 0 artinya 'Semua'

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // --- FUNGSI MENGAMBIL DATA DARI LARAVEL ---
  Future<void> _fetchData() async {
    try {
      MenuService menuService = MenuService();

      // Panggil API kategori dan menu secara bersamaan agar lebih cepat
      final results = await Future.wait([
        menuService.getCategories(),
        menuService.getMenus(),
      ]);

      if (mounted) {
        setState(() {
          _categories = results[0];
          _menus = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- FUNGSI FILTER MENU BERDASARKAN KATEGORI ---
  List<dynamic> get _filteredMenus {
    if (_selectedCategoryId == 0) return _menus;
    return _menus
        .where((menu) => menu['kategori_id'] == _selectedCategoryId)
        .toList();
  }

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
          // IKON SHOPPING BAG
          Center(
            child: GestureDetector(
              onTap: () {
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
                  Icons.shopping_bag_outlined,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // IKON KERANJANG
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
                // --- KODE YANG BERUBAH MULAI DARI SINI ---
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Badge(
                      label: Text(
                        '${cart.itemCount}', // Angka akan berubah otomatis
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      backgroundColor: theme.colorScheme.error,
                      // Badge merah akan disembunyikan jika keranjang masih 0
                      isLabelVisible: cart.itemCount > 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black87,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
                // --- SAMPAI SINI ---
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 16),

                // --- KATEGORI CHIPS (DINAMIS DARI DATABASE) ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Chip 'Semua' sebagai default
                      _buildCategoryChip(
                        theme: theme,
                        label: 'Semua',
                        isActive: _selectedCategoryId == 0,
                        onTap: () => setState(() => _selectedCategoryId = 0),
                      ),
                      const SizedBox(width: 12),

                      // Looping data kategori dari API
                      ..._categories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: _buildCategoryChip(
                            theme: theme,
                            label: cat['nama'] ?? 'Kategori',
                            isActive: _selectedCategoryId == cat['id'],
                            onTap: () =>
                                setState(() => _selectedCategoryId = cat['id']),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- GRID PRODUK (DINAMIS DARI DATABASE) ---
                Expanded(
                  child: _filteredMenus.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada menu di kategori ini.',
                            style: TextStyle(color: Color(0xFF6D7A73)),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.58,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: _filteredMenus.length,
                          itemBuilder: (context, index) {
                            final menu = _filteredMenus[index];

                            // Parsing harga menggunakan double.tryParse agar tidak FormatException
                            final hargaFormat =
                                double.tryParse(
                                  menu['harga'].toString(),
                                )?.toInt() ??
                                0;

                            return CoffeeItemCard(
                              // Jika gambar null, gunakan placeholder dari Unsplash
                              imageUrl:
                                  menu['gambar'] ??
                                  'https://images.unsplash.com/photo-1551030173-122aabc4489c?q=80&w=400&auto=format&fit=crop',
                              name: menu['nama'] ?? 'Menu Tanpa Nama',
                              description: menu['deskripsi'] ?? '',
                              price: 'Rp $hargaFormat',
                              originalPrice:
                                  null, // Siapkan untuk logika diskon nanti
                              isPromo: false,
                              // Cek ketersediaan dari database (misal menggunakan angka 1 untuk true)
                              isAvailable:
                                  menu['tersedia'] == 1 ||
                                  menu['tersedia'] == true,
                              // Ganti blok onAddPressed lama dengan ini:
                              onAddPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      menuId: menu['id'],
                                      name: menu['nama'] ?? 'Menu',
                                      description: menu['deskripsi'] ?? '',
                                      price: hargaFormat,
                                      imageUrl:
                                          menu['gambar'] ??
                                          'https://images.unsplash.com/photo-1551030173-122aabc4489c?q=80&w=400&auto=format&fit=crop',
                                      isAvailable:
                                          menu['tersedia'] == 1 ||
                                          menu['tersedia'] == true,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // --- HELPER WIDGET CATEGORY CHIP ---
  Widget _buildCategoryChip({
    required ThemeData theme,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
