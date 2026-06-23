import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class ReceiptScreen extends StatefulWidget {
  final String orderId; // Menerima Order ID dari halaman sebelumnya

  const ReceiptScreen({super.key, required this.orderId});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool isLoading = true;
  Map<String, dynamic>? receiptData;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchReceipt();
  }

  // --- MESIN PENYEDOT DATA DARI LARAVEL ---
  Future<void> fetchReceipt() async {
    try {
      final parts = widget.orderId.split('-');
      if (parts.length < 2) throw Exception("Format Order ID salah");
      final String pesananId = parts[1];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Pastikan nama kunci token ini SAMA dengan saat kamu proses Login!
      String? token = prefs.getString('auth_token');
      // PENTING: Ganti 10.0.2.2 dengan IP WiFi laptopmu jika kamu pakai HP Fisik!
      final url = Uri.parse(
        'https://vivalavidacoffeshop.rf.gd/api/transaksi/struk/$pesananId',
      );

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("DATA DARI LARAVEL: $data"); // <--- TAMBAHKAN INI
        setState(() {
          receiptData = data['data'];
          isLoading = false;
        });
      } else {
        // TANGKAP ERROR DARI SERVER LARAVEL
        setState(() {
          errorMessage =
              'Error Server (${response.statusCode}):\n${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      // TANGKAP ERROR DARI FLUTTER / JARINGAN
      setState(() {
        errorMessage = 'Error Sistem:\n$e';
        isLoading = false;
      });
    }
  }

  // Helper untuk format Rupiah
  String formatRp(dynamic number) {
    // Jika data adalah String, ubah paksa jadi Integer. Jika gagal, gunakan 0.
    int val = 0;
    if (number is String) {
      val = int.tryParse(number) ?? 0;
    } else if (number is num) {
      val = number.toInt();
    }
    
    // Sekarang lanjut ke logika format Rupiah-mu
    String str = val.toString();
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

  // Helper untuk format Tanggal
  String formatTanggal(String? rawDate) {
    if (rawDate == null) return '-';
    try {
      final DateTime dt = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt) + ' WIB';
    } catch (e) {
      return rawDate;
    }
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
          'Receipt',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: theme.colorScheme.primary),
            onPressed: () {
              // Logika membagikan struk (share)
            },
          ),
        ],
      ),
      // Tampilkan loading saat data belum datang
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : receiptData == null
          ? const Center(child: Text('Gagal memuat struk pesanan.'))
          : _buildReceiptContent(theme),

      // Tombol Aksi Bawah
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Aksi menyimpan ke galeri atau download PDF
                },
                icon: const Icon(Icons.download_outlined, size: 20),
                label: const Text(
                  'Simpan Bukti Pembayaran',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- KONTEN DESAIN STRUK ASLI MILIKMU ---
  // --- KONTEN DESAIN STRUK YANG SUDAH DIPERBAIKI ---
  Widget _buildReceiptContent(ThemeData theme) {
    // Mengekstrak data dengan aman
    final items = (receiptData!['items'] as List?) ?? [];
    final tanggal = receiptData!['created_at'];
    final metodeBayar = (receiptData!['pembayaran'] != null && (receiptData!['pembayaran'] as List).isNotEmpty) 
        ? receiptData!['pembayaran'][0]['metode'] ?? 'qris' 
        : 'qris';
    
    // Konversi angka secara paksa agar tidak lagi bernilai 0
    double totalHargaBeli = double.tryParse(receiptData!['total_harga'].toString()) ?? 0.0;
    double diskon = double.tryParse(receiptData!['diskon_voucher'].toString()) ?? 0.0;
    double totalAkhir = double.tryParse(receiptData!['total_akhir'].toString()) ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. STATUS BERHASIL ---
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text('Pembayaran Berhasil', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text('Terima kasih atas pesanan Anda!', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73))),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. INFORMASI ORDER ---
            _buildInfoRow(theme, 'Order ID', widget.orderId),
            const SizedBox(height: 12),
            _buildInfoRow(theme, 'Date', formatTanggal(tanggal)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Method', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73))),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: metodeBayar.toString().toLowerCase() == 'gopay' ? Colors.blue.shade600 : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(metodeBayar.toString().toLowerCase() == 'qris' ? Icons.qr_code : Icons.account_balance_wallet, color: Colors.white, size: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(metodeBayar.toString().toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                  ],
                ),
              ],
            ),
            
            _buildDashedLine(),

            // --- 3. DAFTAR ITEM ---
            ...items.map((item) {
              final menu = item['menu'] ?? {};
              String namaMenu = menu['nama'] ?? menu['nama_menu'] ?? 'Item Menu';
              int qty = int.tryParse(item['jumlah'].toString()) ?? 1;
              double hargaSatuan = double.tryParse(item['harga_satuan'].toString()) ?? 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildItemRow(theme, namaMenu, qty, formatRp(hargaSatuan)),
              );
            }),
            
            _buildDashedLine(),

            // --- 4. RINGKASAN BIAYA ---
            _buildSummaryRow(theme, 'Subtotal', formatRp(totalHargaBeli.toInt())),
            
            if (diskon > 0) ...[
              const SizedBox(height: 12),
              _buildSummaryRow(theme, 'Diskon Voucher', '- ${formatRp(diskon.toInt())}', valueColor: theme.colorScheme.primary),
            ],
            
            _buildDashedLine(),

            // --- 5. TOTAL ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20)),
                Text(
                  formatRp(totalAkhir.toInt()),
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22, color: theme.colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6D7A73),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(ThemeData theme, String name, int qty, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Qty: $qty',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6D7A73),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Text(
          price,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6D7A73),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 14,
            color: valueColor ?? const Color(0xFF191C1F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 6.0;
          const dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();

          return Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return const SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFE5E7EB)),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
