import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'qris_payment_screen.dart';
import '../services/transaction_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // --- State Variables ---
  String selectedMethod = 'Dine-In';
  String selectedPayment = 'QRIS';

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

  // Fungsi untuk memunculkan pop-up pembayaran tunai
  void _showCashPaymentDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F0EB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pembayaran di Kasir',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Silakan melunasi pembayaran di kasir untuk menyelesaikan pesanan Anda.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6D7A73),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    // Bersihkan keranjang setelah sukses
                    Provider.of<CartProvider>(context, listen: false).clear();
                    // Kembali ke halaman utama (Menu)
                    Navigator.popUntil(context, (route) => route.isFirst);
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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

    // Mengambil data dari CartProvider
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    // Kalkulasi Total Dinamis
    final int subtotal = cart.totalAmount;
    final int tax = (subtotal * taxRate).round();
    // Pastikan grand total tidak minus jika diskon lebih besar dari subtotal
    int grandTotal = subtotal + tax - discount;
    if (grandTotal < 0) grandTotal = 0;

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
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Keranjang masih kosong',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text(
                      'Kembali ke Menu',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
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
                        // Looping daftar pesanan dari Provider
                        ...cartItems.asMap().entries.map((entry) {
                          int index = entry.key;
                          CartItem item = entry.value;

                          return Column(
                            children: [
                              _buildOrderItem(
                                theme: theme,
                                imageUrl: item.imageUrl,
                                name: item.name,
                                price: item.price * item.quantity,
                                qty: item.quantity,
                                onMinus: () {
                                  cart.reduceQuantity(item.menuId);
                                },
                                onPlus: () {
                                  cart.addItem(
                                    item.menuId,
                                    item.name,
                                    item.price,
                                    item.imageUrl,
                                    1,
                                  );
                                },
                              ),
                              // Beri garis pembatas antar item (kecuali item terakhir)
                              if (index < cartItems.length - 1)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(
                                    color: Color(0xFFE5E7EB),
                                    height: 1,
                                  ),
                                ),
                            ],
                          );
                        }),

                        const SizedBox(height: 16),

                        // Tombol Tambah Pesanan Lagi
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Kembali ke menu
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          label: Text(
                            'Tambah Pesanan Lagi',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF3D4943),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                          onTap: () =>
                              setState(() => selectedMethod = 'Dine-In'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSelectableCard(
                          theme: theme,
                          title: 'Takeaway',
                          icon: Icons.shopping_bag_outlined,
                          isSelected: selectedMethod == 'Takeaway',
                          onTap: () =>
                              setState(() => selectedMethod = 'Takeaway'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nomor Meja
                  if (selectedMethod == 'Dine-In') ...[
                    _buildSectionLabel(theme, 'Nomor Meja', isNormalCase: true),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.table_restaurant_outlined,
                            color: Color(0xFF6D7A73),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Pilih Meja',
                            style: TextStyle(
                              color: Color(0xFF3D4943),
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF6D7A73),
                          ),
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
                        Icon(
                          Icons.local_activity_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Voucher COFFEE10 Terpakai',
                                style: theme.textTheme.labelSmall,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Hemat Rp 10.000',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Ubah >',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                            Text(
                              'Total',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              formatRp(grandTotal),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: 18,
                                color: theme.colorScheme.primary,
                              ),
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
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // 1. Tampilkan loading untuk SEMUA metode pembayaran
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      // 2. Siapkan Data untuk API
                      final cartItems = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).items.values.toList();

                      final List<Map<String, dynamic>>
                      itemsList = cartItems.map((item) {
                        return {
                          'menu_id': item.menuId,
                          'jumlah': item.quantity,
                          'harga_satuan': item.price,
                          // Pastikan format list opsi_tambahan dikirim dengan benar jika ada
                          'opsi_tambahan': null,
                        };
                      }).toList();

                      // Format nama metode pembayaran agar sesuai dengan validasi Laravel (huruf kecil)
                      String metodePembayaranApi = selectedPayment == 'Cash'
                          ? 'cash'
                          : 'qris';

                      final payload = {
                        'tipe_pesanan': selectedMethod == 'Dine-In'
                            ? 'dine_in'
                            : 'takeaway',
                        'meja_id': null,
                        'alamat_pengiriman_id': null,
                        'items': itemsList,
                        'voucher_id': null,
                        'diskon_voucher': discount,
                        'metode_pembayaran':
                            metodePembayaranApi, // 'cash' atau 'qris'
                      };

                      // 3. Tembak API KE LARAVEL
                      final TransactionService service = TransactionService();
                      final response = await service.checkout(payload);

                      // Tutup loading
                      if (mounted) Navigator.pop(context);

                      // 4. Cek Balasan dari Laravel
                      if (response['success'] == true) {
                        // Bersihkan Keranjang karena pesanan sudah sukses masuk database
                        if (mounted) {
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).clear();
                        }

                        // 5. Pisahkan Alur Layar Berdasarkan Metode Pembayaran
                        if (selectedPayment == 'QRIS') {
                          // Jika QRIS, pindah ke halaman bayar
                          final orderId = response['data']['order_id'];
                          final qrUrl = response['data']['qr_url'] ?? '';

                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QrisPaymentScreen(
                                  totalAmount: grandTotal,
                                  orderId: orderId,
                                  qrUrl: qrUrl,
                                ),
                              ),
                            );
                          }
                        } else {
                          // Jika CASH, munculkan dialog "Pembayaran di Kasir"
                          if (mounted) {
                            _showCashPaymentDialog(context, theme);
                          }
                        }
                      } else {
                        // Jika Laravel menolak (sukses == false)
                        throw Exception(
                          response['message'] ?? 'Terjadi kesalahan',
                        );
                      }
                    } catch (e) {
                      // Jika terjadi error jaringan / validasi Laravel
                      if (mounted) {
                        // Jika loading masih muter, tutup
                        if (Navigator.canPop(context)) Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Konfirmasi & Pesan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
  Widget _buildSectionLabel(
    ThemeData theme,
    String text, {
    bool isNormalCase = false,
  }) {
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
            errorBuilder: (context, error, stackTrace) => Container(
              width: 48,
              height: 48,
              color: Colors.grey[300],
              child: const Icon(
                Icons.image_not_supported,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                formatRp(price),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
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
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.remove, size: 14, color: Color(0xFF3D4943)),
                ),
              ),
              SizedBox(
                width: 20,
                child: Text(
                  '$qty',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                onTap: onPlus,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.add, size: 14, color: Color(0xFF3D4943)),
                ),
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
            color: isSelected
                ? theme.colorScheme.primary
                : const Color(0xFFE5E7EB),
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
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : const Color(0xFFF2F4F8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : const Color(0xFF6D7A73),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF3D4943),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (isSelected && showCheckmark)
              Positioned(
                top: -8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    IconData? icon,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor ?? const Color(0xFF6D7A73),
                fontSize: 13,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor ?? const Color(0xFF191C1F),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
