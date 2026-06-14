import 'package:flutter/material.dart';
import 'qris_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // --- State Variables ---
  String selectedMethod = 'Dine-In';
  String selectedPayment = 'QRIS';
  int qtyLatte = 1;
  int qtyCroissant = 2;

  // Harga Statis untuk simulasi
  final int priceLatte = 45000;
  final int priceCroissant = 35000; // Harga per item, total 70k untuk 2
  final int discount = 10000;
  final double taxRate = 0.11; // Pajak 11%

  // Fungsi helper untuk memformat Rupiah
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

  // Kalkulasi Total
  int get subtotal => (priceLatte * qtyLatte) + (priceCroissant * qtyCroissant);
  int get tax => (subtotal * taxRate).round();
  int get grandTotal => subtotal + tax - discount;

  // Fungsi untuk memunculkan pop-up pembayaran tunai
  void _showCashPaymentDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus menekan tombol "Mengerti" untuk menutup
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Agar tinggi kotak menyesuaikan isi
              children: [
                // Ikon Uang Tunai
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F0EB), // Hijau sangat pudar
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Judul
                Text(
                  'Pembayaran di Kasir',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Deskripsi
                Text(
                  'Silakan melunasi pembayaran di kasir untuk menyelesaikan pesanan Anda.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6D7A73),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                
                // Tombol Mengerti
                ElevatedButton(
                  onPressed: () {
                    // 1. Tutup dialog ini
                    Navigator.pop(context); 
                    
                    // 2. Opsi: Langsung kembali ke Beranda setelah pesan terkirim
                    // Navigator.popUntil(context, (route) => route.isFirst); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. PESANAN ANDA ---
            _buildSectionLabel(theme, 'PESANAN ANDA'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildOrderItem(
                    theme: theme,
                    // Ganti link yang lama dengan link baru ini
                    imageUrl: 'https://images.unsplash.com/photo-1623334044303-241021148842?q=80&w=200&auto=format&fit=crop',
                    name: 'Almond Croissant',
                    price: priceCroissant * qtyCroissant, 
                    qty: qtyCroissant,
                    onMinus: () {
                      if (qtyCroissant > 1) setState(() => qtyCroissant--);
                    },
                    onPlus: () => setState(() => qtyCroissant++),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFE5E7EB), height: 1),
                  ),
                  _buildOrderItem(
                    theme: theme,
                    imageUrl: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?q=80&w=400&auto=format&fit=crop',
                    name: 'Almond Croissant',
                    price: priceCroissant * qtyCroissant, // Menampilkan harga total item
                    qty: qtyCroissant,
                    onMinus: () {
                      if (qtyCroissant > 1) setState(() => qtyCroissant--);
                    },
                    onPlus: () => setState(() => qtyCroissant++),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tombol Tambah Pesanan Lagi
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke menu
                    },
                    icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary, size: 18),
                    label: Text(
                      'Tambah Pesanan Lagi',
                      style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF3D4943)),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. PILIH METODE ---
            _buildSectionLabel(theme, 'PILIH METODE'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSelectableCard(
                    theme: theme,
                    title: 'Dine-In',
                    icon: Icons.restaurant,
                    isSelected: selectedMethod == 'Dine-In',
                    onTap: () => setState(() => selectedMethod = 'Dine-In'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSelectableCard(
                    theme: theme,
                    title: 'Takeaway',
                    icon: Icons.shopping_bag_outlined,
                    isSelected: selectedMethod == 'Takeaway',
                    onTap: () => setState(() => selectedMethod = 'Takeaway'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nomor Meja (Tampil jika Dine-In dipilih)
            if (selectedMethod == 'Dine-In') ...[
              _buildSectionLabel(theme, 'Nomor Meja', isNormalCase: true),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.table_restaurant_outlined, color: Color(0xFF6D7A73), size: 20),
                    SizedBox(width: 12),
                    Text('Pilih Meja', style: TextStyle(color: Color(0xFF3D4943), fontSize: 14)),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF6D7A73)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // --- 3. PILIH PEMBAYARAN ---
            _buildSectionLabel(theme, 'PILIH PEMBAYARAN'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSelectableCard(
                    theme: theme,
                    title: 'Cash',
                    icon: Icons.payments_outlined,
                    isSelected: selectedPayment == 'Cash',
                    onTap: () => setState(() => selectedPayment = 'Cash'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSelectableCard(
                    theme: theme,
                    title: 'QRIS',
                    icon: Icons.qr_code_scanner,
                    isSelected: selectedPayment == 'QRIS',
                    showCheckmark: true,
                    onTap: () => setState(() => selectedPayment = 'QRIS'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 4. PILIH VOUCHER ---
            _buildSectionLabel(theme, 'PILIH VOUCHER'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_activity_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Voucher COFFEE10 Terpakai', style: theme.textTheme.labelSmall),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 12),
                            const SizedBox(width: 4),
                            Text('Hemat Rp 10.000', style: TextStyle(color: theme.colorScheme.primary, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text('Ubah >', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lihat Voucher Tersedia', style: TextStyle(color: Color(0xFF3D4943), fontSize: 12)),
                  Icon(Icons.chevron_right, size: 18, color: Color(0xFF6D7A73)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 5. RINGKASAN PEMBAYARAN ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', formatRp(subtotal)),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Pajak (11%)', formatRp(tax)),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Diskon Voucher', 
                    '- ${formatRp(discount)}', 
                    icon: Icons.local_offer, 
                    textColor: theme.colorScheme.error,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFE5E7EB), height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18)),
                      Text(
                        formatRp(grandTotal),
                        style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // --- 6. TOMBOL KONFIRMASI ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              // --- Logika Navigasi Pembayaran ---
              if (selectedPayment == 'QRIS') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Kita kirimkan nilai grandTotal ke halaman QRIS
                    builder: (context) => QrisPaymentScreen(totalAmount: grandTotal),
                  ),
                );
              } else {
                // Tampilkan pesan atau navigasi jika metode pembayarannya Cash
                _showCashPaymentDialog(context, theme);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Konfirmasi & Pesan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionLabel(ThemeData theme, String text, {bool isNormalCase = false}) {
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: const Color(0xFF6D7A73),
        letterSpacing: isNormalCase ? 0 : 1.2,
      ),
    );
  }

  Widget _buildOrderItem({
    required ThemeData theme,
    required String imageUrl,
    required String name,
    required int price,
    required int qty,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl, 
            width: 48, 
            height: 48, 
            fit: BoxFit.cover,
            // --- Tambahkan kode ini untuk mencegah overflow jika gambar mati ---
            errorBuilder: (context, error, stackTrace) => Container(
              width: 48,
              height: 48,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
            ),
            // ------------------------------------------------------------------
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.labelSmall?.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(formatRp(price), style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        // Stepper
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onMinus,
                child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.remove, size: 14, color: Color(0xFF3D4943))),
              ),
              SizedBox(
                width: 20,
                child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              InkWell(
                onTap: onPlus,
                child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.add, size: 14, color: Color(0xFF3D4943))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool showCheckmark = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : const Color(0xFFF2F4F8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: isSelected ? theme.colorScheme.primary : const Color(0xFF6D7A73), size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF3D4943),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (isSelected && showCheckmark)
              Positioned(
                top: -8,
                right: 8,
                child: Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {IconData? icon, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(label, style: TextStyle(color: textColor ?? const Color(0xFF6D7A73), fontSize: 13)),
          ],
        ),
        Text(value, style: TextStyle(color: textColor ?? const Color(0xFF191C1F), fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}