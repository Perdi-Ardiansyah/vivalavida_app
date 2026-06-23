import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? selectedTableId;

  // Variabel Pajak Dinamis
  double taxRate = 0.11; // Default 11%, akan tertimpa oleh data dari API
  int taxPercentage = 11; // Untuk tampilan teks (contoh: "11")

  // --- Variabel Baru untuk Voucher Dinamis ---
  List<dynamic> _myVouchers = []; // Menampung isi dompet voucher
  bool _isLoadingVouchers = true;

  // Data voucher yang sedang aktif digunakan saat checkout
  int? selectedVoucherId;
  String? selectedVoucherTitle;
  String? selectedVoucherType; // 'nominal' atau 'persen'
  int selectedVoucherValue = 0; // Nilai potongannya

  @override
  void initState() {
    super.initState();
    _fetchMyWalletVouchers(); // Ambil voucher pas layar dibuka
    _fetchTaxRate(); // Ambil persentase pajak dari Laravel
  }

  // --- AMBIL DATA PAJAK DARI DATABASE ---
  // --- AMBIL DATA PAJAK DARI DATABASE ---
  Future<void> _fetchTaxRate() async {
    try {
      // 1. Ambil token dari penyimpanan HP
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      // 2. Sertakan token di dalam Headers
      final response = await http.get(
        Uri.parse('https://vivalavidacoffeshop.rf.gd/api/tax-rate'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // <- Ini yang sebelumnya tertinggal
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            taxRate = double.parse(data['tax_rate'].toString());
            taxPercentage = (taxRate * 100).round();
          });
        }
      } else {
        debugPrint("Gagal API Pajak, Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Gagal ambil pajak dari API: $e");
    }
  }

  // --- AMBIL VOUCHER YANG BELUM DIPAKAI DARI DATABASE ---
  Future<void> _fetchMyWalletVouchers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      final url = Uri.parse('https://vivalavidacoffeshop.rf.gd/api/vouchers/me');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        if (mounted) {
          setState(() {
            _myVouchers = resData['data'] ?? [];
            _isLoadingVouchers = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error ambil voucher di checkout: $e");
      if (mounted) setState(() => _isLoadingVouchers = false);
    }
  }

  // --- MODAL POP-UP UNTUK MEMILIH VOUCHER ---
  void _showVoucherSelectionBottomSheet(
    BuildContext context,
    int subtotal,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pilih Voucher Tersedia',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingVouchers)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_myVouchers.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: const Center(
                        child: Text(
                          'Kamu tidak memiliki voucher unused saat ini.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _myVouchers.length,
                        itemBuilder: (context, index) {
                          final v = _myVouchers[index];
                          final bool isSelected = selectedVoucherId == v['id'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.local_activity,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                v['judul'] ?? 'Voucher Diskon',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                v['deskripsi'] ?? '',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primary,
                                    )
                                  : const Icon(
                                      Icons.circle_outlined,
                                      color: Colors.grey,
                                    ),
                              onTap: () {
                                setState(() {
                                  selectedVoucherId = v['id'];
                                  selectedVoucherTitle = v['judul'];
                                  selectedVoucherType = v['tipe_diskon'];
                                  selectedVoucherValue =
                                      int.tryParse(
                                        v['nilai_diskon'].toString(),
                                      ) ??
                                      0;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                  // Tombol batalkan penggunaan voucher
                  if (selectedVoucherId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            selectedVoucherId = null;
                            selectedVoucherTitle = null;
                            selectedVoucherType = null;
                            selectedVoucherValue = 0;
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Batalkan Penggunaan Voucher',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
                    Provider.of<CartProvider>(context, listen: false).clear();
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
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    // Kalkulasi Angka Dasar
    final int subtotal = cart.totalAmount;
    final int tax = (subtotal * taxRate).round();

    // --- LOGIKA MENGHITUNG DISKON SECARA DINAMIS ---
    int calculatedDiscount = 0;
    if (selectedVoucherType == 'persen') {
      calculatedDiscount = (subtotal * (selectedVoucherValue / 100)).round();
    } else if (selectedVoucherType == 'nominal') {
      calculatedDiscount = selectedVoucherValue;
    }

    int grandTotal = subtotal + tax - calculatedDiscount;
    if (grandTotal < 0) grandTotal = 0;

    // Logika deteksi makanan
    bool hasFood = cartItems.any((item) {
      final name = item.name.toLowerCase();
      return name.contains('croissant') ||
          name.contains('cake') ||
          name.contains('roti') ||
          name.contains('pastry') ||
          name.contains('snack') ||
          name.contains('makanan');
    });

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
                        ...cartItems.asMap().entries.map((entry) {
                          int index = entry.key;
                          CartItem item = entry.value;
                          return Column(
                            children: [
                              _buildOrderItem(
                                theme: theme,
                                imageUrl: item.imageUrl,
                                name: item.name,
                                catatan: item.catatan, // 1. Tambahkan ini
                                price: item.price * item.quantity,
                                qty: item.quantity,
                                onMinus: () => cart.reduceQuantity(
                                  item.id,
                                ), // 2. Ubah item.menuId jadi item.id
                                onPlus: () => cart.addItem(
                                  item.menuId,
                                  item.name,
                                  item.price,
                                  item.imageUrl,
                                  1,
                                  catatan: item
                                      .catatan, // 3. Pastikan plus menambah dengan catatan yang sama
                                ),
                              ),
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
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
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
                          onTap: () => setState(() {
                            selectedMethod = 'Dine-In';
                            selectedTableId = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSelectableCard(
                          theme: theme,
                          title: 'Takeaway',
                          icon: Icons.shopping_bag_outlined,
                          isSelected: selectedMethod == 'Takeaway',
                          onTap: () => setState(() {
                            selectedMethod = 'Takeaway';
                            selectedTableId = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- SYARAT MEJA DINE-IN ---
                  if (selectedMethod == 'Dine-In' && hasFood) ...[
                    _buildSectionLabel(theme, 'Nomor Meja', isNormalCase: true),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final scannedData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRScannerScreen(),
                          ),
                        );
                        if (scannedData != null &&
                            scannedData.toString().startsWith('VLV-MEJA-')) {
                          setState(() {
                            selectedTableId = scannedData.toString().replaceAll(
                              'VLV-MEJA-',
                              '',
                            );
                          });
                        } else if (scannedData != null) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'QR Code salah! Gunakan QR meja resmi Vivalavida.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: selectedTableId != null
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedTableId != null
                                ? theme.colorScheme.primary
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              color: selectedTableId != null
                                  ? theme.colorScheme.primary
                                  : const Color(0xFF6D7A73),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedTableId != null
                                  ? 'Meja Terpilih (ID: $selectedTableId)'
                                  : 'Scan QR Meja',
                              style: TextStyle(
                                color: selectedTableId != null
                                    ? theme.colorScheme.primary
                                    : const Color(0xFF3D4943),
                                fontSize: 14,
                                fontWeight: selectedTableId != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            if (selectedTableId != null)
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 20,
                              )
                            else
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF6D7A73),
                              ),
                          ],
                        ),
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
                      border: Border.all(
                        color: selectedVoucherId != null
                            ? theme.colorScheme.primary
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_activity_outlined,
                          color: selectedVoucherId != null
                              ? theme.colorScheme.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedVoucherId != null
                                    ? selectedVoucherTitle!
                                    : 'Gunakan Voucher Diskon',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: selectedVoucherId != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (selectedVoucherId != null) ...[
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
                                      'Hemat ${formatRp(calculatedDiscount)}',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showVoucherSelectionBottomSheet(
                            context,
                            subtotal,
                            theme,
                          ),
                          child: Text(
                            selectedVoucherId != null ? 'Ubah >' : 'Pilih >',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
                        // Teks Pajak sekarang tampil dinamis berdasarkan data dari Laravel
                        _buildSummaryRow(
                          'Pajak ($taxPercentage%)',
                          formatRp(tax),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Diskon Voucher',
                          '- ${formatRp(calculatedDiscount)}',
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

      // --- 6. TOMBOL KONFIRMASI & KIRIM KE LARAVEL ---
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedMethod == 'Dine-In' &&
                        hasFood &&
                        selectedTableId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Mohon Scan QR Meja Anda terlebih dahulu.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      final cartItems = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).items.values.toList();
                      final List<Map<String, dynamic>>
                      itemsList = cartItems.map((item) {
                        // 1. Kita bungkus catatannya ke dalam sebuah Array (List di Dart)
                        List<String> formatOpsiArray = [];
                        if (item.catatan != null &&
                            item.catatan!.trim().isNotEmpty) {
                          formatOpsiArray.add(item.catatan!);
                        }

                        return {
                          'menu_id': item.menuId,
                          'jumlah': item.quantity,
                          'harga_satuan': item.price,
                          // 2. Jika tidak ada catatan, kirim null (seperti kode awalmu yang berhasil).
                          // Jika ada catatan, kirim formatOpsiArray yang sudah berupa Array [ "Less sugar" ]
                          'opsi_tambahan': formatOpsiArray.isNotEmpty
                              ? formatOpsiArray
                              : null,
                        };
                      }).toList();
                      String metodePembayaranApi = selectedPayment == 'Cash'
                          ? 'cash'
                          : 'qris';

                      final payload = {
                        'tipe_pesanan': selectedMethod == 'Dine-In'
                            ? 'dine_in'
                            : 'takeaway',
                        'meja_id': selectedTableId != null
                            ? int.tryParse(selectedTableId!)
                            : null,
                        'alamat_pengiriman_id': null,
                        'items': itemsList,
                        'voucher_id': selectedVoucherId,
                        'diskon_voucher': calculatedDiscount,
                        'metode_pembayaran': metodePembayaranApi,
                      };

                      final TransactionService service = TransactionService();
                      final response = await service.checkout(payload);

                      if (mounted) Navigator.pop(context);

                      if (response['success'] == true) {
                        if (mounted)
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).clear();
                        if (selectedPayment == 'QRIS') {
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
                          if (mounted) _showCashPaymentDialog(context, theme);
                        }
                      } else {
                        throw Exception(
                          response['message'] ?? 'Terjadi kesalahan',
                        );
                      }
                    } catch (e) {
                      if (mounted) {
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
    String? catatan, // Tambahkan parameter catatan di sini
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
              // MEMUNCULKAN TEKS CATATAN JIKA ADA
              if (catatan != null && catatan.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Catatan: $catatan',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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

// ============================================================================
// WIDGET SCREEN KAMERA SCANNER QR MEJA
// ============================================================================
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Meja'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => isScanned = true);
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Arahkan kamera ke QR Code yang ada di atas meja Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
