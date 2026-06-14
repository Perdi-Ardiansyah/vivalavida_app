import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- State Variables ---
  String selectedSize = 'Regular';
  String selectedTemp = 'Iced';
  int quantity = 1;
  final int basePrice = 45000;
  final int largeAddonPrice = 8000; // Asumsi biaya tambahan untuk ukuran Large

  // Fungsi sederhana untuk memformat angka menjadi format Rupiah
  String formatRp(int number) {
    String str = number.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count == 3 && i != 0) {
        result = '.$result';
        count = 0;
      }
    }
    return 'Rp $result';
  }

  // Menghitung total harga dinamis
  int get totalPrice {
    int currentPrice = basePrice;
    if (selectedSize == 'Large') {
      currentPrice += largeAddonPrice;
    }
    return currentPrice * quantity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // SingleChildScrollView agar seluruh konten bisa digulir
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HERO IMAGE & TOMBOL MENGAMBANG ---
            Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1558403194-611308249627?q=80&w=800&auto=format&fit=crop',
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Tombol Back
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: _buildFloatingButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                // Tombol Share
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: _buildFloatingButton(
                    icon: Icons.share_outlined,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            // --- 2. INFORMASI PRODUK ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul dan Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Vanilla Bean Latte',
                          style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                        ),
                      ),
                      Text(
                        formatRp(basePrice),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Chips (Tags)
                  Row(
                    children: [
                      _buildTagChip(label: 'Signature', bgColor: const Color(0xFFE6F0EB), textColor: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      _buildTagChip(label: 'Contains Dairy', bgColor: const Color(0xFFE0E2E6), textColor: const Color(0xFF3D4943)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi
                  Text(
                    'Our signature blend pulled as a perfect ristretto, poured over ice and mixed with homemade Madagascar vanilla bean syrup and creamy oat milk. A refreshing classic with a sophisticated twist.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73), height: 1.5),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Divider(color: Color(0xFFE5E7EB)),
                  ),

                  // --- 3. SIZE SELECTION ---
                  _buildSectionTitle(theme, 'SIZE'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectionCard(
                          theme: theme,
                          title: 'Regular',
                          icon: Icons.coffee,
                          isSelected: selectedSize == 'Regular',
                          onTap: () => setState(() => selectedSize = 'Regular'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSelectionCard(
                          theme: theme,
                          title: 'Large',
                          icon: Icons.coffee_maker_outlined, // Ikon beda sebagai variasi
                          isSelected: selectedSize == 'Large',
                          onTap: () => setState(() => selectedSize = 'Large'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- 4. TEMPERATURE SELECTION ---
                  _buildSectionTitle(theme, 'TEMPERATURE'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectionCardHorizontal(
                          theme: theme,
                          title: 'Iced',
                          icon: Icons.ac_unit,
                          isSelected: selectedTemp == 'Iced',
                          onTap: () => setState(() => selectedTemp = 'Iced'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSelectionCardHorizontal(
                          theme: theme,
                          title: 'Hot',
                          icon: Icons.local_fire_department_outlined,
                          isSelected: selectedTemp == 'Hot',
                          onTap: () => setState(() => selectedTemp = 'Hot'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- 5. CATATAN TAMBAHAN ---
                  _buildSectionTitle(theme, 'CATATAN TAMBAHAN'),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Kurangi gula, ekstra es...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Jarak ekstra di bawah
                ],
              ),
            ),
          ],
        ),
      ),

      // --- 6. BOTTOM ACTION BAR ---
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20, 
          right: 20, 
          top: 16, 
          bottom: MediaQuery.of(context).padding.bottom + 16, // Aman untuk layar berponi
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            // Pengatur Kuantitas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    color: quantity > 1 ? Colors.black87 : Colors.grey,
                    onPressed: () {
                      if (quantity > 1) setState(() => quantity--);
                    },
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$quantity',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () => setState(() => quantity++),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Tombol Tambah ke Keranjang
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Aksi masukkan ke keranjang
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Tambahkan\nke Pesanan',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        formatRp(totalPrice),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildFloatingButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }

  Widget _buildTagChip({required String label, required Color bgColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF3D4943), letterSpacing: 1.2),
    );
  }

  // Card untuk Size (Vertikal)
  Widget _buildSelectionCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : const Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? theme.colorScheme.primary : const Color(0xFF6D7A73)),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? theme.colorScheme.primary : const Color(0xFF3D4943),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card untuk Temperature (Horizontal)
  Widget _buildSelectionCardHorizontal({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : const Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? theme.colorScheme.primary : const Color(0xFF3D4943),
              ),
            ),
            Icon(icon, color: isSelected ? theme.colorScheme.primary : const Color(0xFF6D7A73), size: 20),
          ],
        ),
      ),
    );
  }
}