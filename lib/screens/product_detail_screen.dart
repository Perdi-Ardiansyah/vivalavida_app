import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  // 1. Definisikan variabel untuk menampung data yang dikirim dari MenuScreen
  final int menuId;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final bool isAvailable;

  const ProductDetailScreen({
    super.key,
    required this.menuId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  // Fungsi helper untuk memformat Rupiah
  String _formatRp(int number) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. GAMBAR PRODUK ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.network(
              widget.imageUrl, // Menggunakan data gambar dinamis
              fit: BoxFit.cover,
            ),
          ),

          // --- 2. TOMBOL BACK ---
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),

          // --- 3. KONTEN DETAIL (BOTTOM SHEET STYLE) ---
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Produk
                    Text(
                      widget.name, // Menggunakan data nama dinamis
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF191C1F),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Harga Produk
                    Text(
                      _formatRp(widget.price), // Menggunakan data harga dinamis
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 16),

                    // Deskripsi
                    Text(
                      'Deskripsi',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF6D7A73),
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description.isEmpty
                          ? 'Tidak ada deskripsi untuk menu ini.'
                          : widget.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF3D4943),
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Kuantitas Stepper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jumlah Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F8),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                              ),
                              Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100), // Beri space untuk bottom bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // --- 4. BOTTOM BAR (TOMBOL ADD TO CART) ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: widget.isAvailable
                ? () {
                    // Panggil provider untuk menyimpan data
                    Provider.of<CartProvider>(context, listen: false).addItem(
                      widget.menuId,
                      widget.name,
                      widget.price,
                      widget.imageUrl,
                      _quantity, // Mengambil dari jumlah stepper di layar
                    );

                    // Munculkan notifikasi sukses
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$_quantity x ${widget.name} masuk keranjang!',
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 1),
                      ),
                    );

                    // Opsional: Tutup halaman detail dan kembali ke menu setelah berhasil
                    Navigator.pop(context);
                  }
                : null, // Tombol disable jika stok habis
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isAvailable
                  ? theme.colorScheme.primary
                  : Colors.grey,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              widget.isAvailable ? 'Tambah ke Keranjang' : 'Stok Habis',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
