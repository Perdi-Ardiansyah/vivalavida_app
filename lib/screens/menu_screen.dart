import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../widgets/coffee_item_card.dart';
import 'product_detail_screen.dart';
import 'checkout_screen.dart';
import 'order_list_screen.dart';
import '../services/menu_service.dart';
import '../providers/cart_provider.dart'; 

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

  // --- VARIABEL BARU UNTUK JUMLAH PESANAN AKTIF ---
  int _activeOrderCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // --- MASTER FUNGSI: MEMUAT KATEGORI, MENU, & JUMLAH PESANAN SEKALIGUS ---
  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      MenuService menuService = MenuService();

      // Menjalankan penarikan data kategori, menu, dan jumlah pesanan secara pararel
      final results = await Future.wait([
        menuService.getCategories(),
        menuService.getMenus(),
        _fetchActiveOrdersCountSilently(),
      ]);

      if (mounted) {
        setState(() {
          _categories = results[0] as List<dynamic>;
          _menus = results[1] as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data menu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- FUNGSI SILENT FETCH: MENGHITUNG PESANAN AKTIF DARI DATABASE ---
  Future<void> _fetchActiveOrdersCountSilently() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('http://10.0.2.2:8000/api/orders');
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> allOrders = data['data'] ?? [];

        // Menghitung pesanan yang statusnya BUKAN selesai / batal
        int count = allOrders.where((order) {
          String status = order['status'].toString().toLowerCase();
          return status != 'completed' && status != 'selesai' && status != 'cancelled' && status != 'batal';
        }).length;

        if (mounted) {
          setState(() {
            _activeOrderCount = count;
          });
        }
      }
    } catch (e) {
      debugPrint('Error hitung pesanan aktif di menu: $e');
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
    const colorSecondary = Color(0xFF705A4F);

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
          // --- IKON SHOPPING BAG DENGAN TITIK INDIKATOR DINAMIS ---
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderListScreen(),
                  ),
                ).then((_) => _fetchActiveOrdersCountSilently()); // Refresh jumlah saat kembali ke halaman menu
              },
              child: Badge(
                // Titik merah kecil hanya muncul jika ada pesanan aktif (> 0)
                isLabelVisible: _activeOrderCount > 0,
                smallSize: 10,
                backgroundColor: theme.colorScheme.error,
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
          ),
          const SizedBox(width: 12),

          // IKON KERANJANG BELANJA
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
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Badge(
                      label: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      backgroundColor: theme.colorScheme.error,
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

                // --- KATEGORI CHIPS ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildCategoryChip(
                        theme: theme,
                        label: 'Semua',
                        isActive: _selectedCategoryId == 0,
                        onTap: () => setState(() => _selectedCategoryId = 0),
                      ),
                      const SizedBox(width: 12),
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

                // --- GRID PRODUK MENU ---
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
                            final hargaFormat = double.tryParse(menu['harga'].toString())?.toInt() ?? 0;

                            // Formatter gambar anti-pecah dan anti-crash
                            String imageUrl = 'https://images.unsplash.com/photo-1551030173-122aabc4489c?q=90&w=800&auto=format&fit=crop';
                            if (menu['gambar'] != null && menu['gambar'].toString().isNotEmpty) {
                              imageUrl = menu['gambar'].toString().startsWith('http')
                                  ? menu['gambar']
                                  : 'http://10.0.2.2:8000/storage/${menu['gambar']}';
                            }

                            return CoffeeItemCard(
                              imageUrl: imageUrl,
                              name: menu['nama'] ?? 'Menu Tanpa Nama',
                              description: menu['deskripsi'] ?? '',
                              price: 'Rp $hargaFormat',
                              originalPrice: null,
                              isPromo: false,
                              isAvailable: menu['tersedia'] == 1 || menu['tersedia'] == true,
                              onAddPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      menuId: menu['id'],
                                      name: menu['nama'] ?? 'Menu',
                                      description: menu['deskripsi'] ?? '',
                                      price: hargaFormat,
                                      imageUrl: imageUrl,
                                      isAvailable: menu['tersedia'] == 1 || menu['tersedia'] == true,
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