import 'package:flutter/material.dart';
import 'dart:async';
import 'payment_success_screen.dart'; // Dibutuhkan untuk fitur Timer

class QrisPaymentScreen extends StatefulWidget {
  final int totalAmount; // Menerima total harga dari halaman checkout

  const QrisPaymentScreen({super.key, required this.totalAmount});

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  // Waktu mundur (misal: 5 menit = 300 detik)
  int secondsRemaining = 300; 
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  // Fungsi untuk menjalankan timer setiap 1 detik
  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        // Logika ketika waktu habis (misal: kembali ke home atau tampilkan dialog)
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Pastikan timer dimatikan saat pindah halaman agar tidak error (memory leak)
    super.dispose();
  }

  // Helper untuk mengubah format detik menjadi MM:SS
  String get formattedTime {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Helper memformat Rupiah
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
          'Pembayaran QRIS',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- 1. KOTAK QR CODE & TOTAL ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  // Gambar QR Code dinamis
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Vivalavida_Order_VV240901',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // --- TAMBAHAN: Tombol Unduh QRIS ---
                  OutlinedButton.icon(
                    onPressed: () {
                      // Nanti di sini kita pasang logika untuk menyimpan gambar ke galeri
                      // Untuk sementara, kita tampilkan notifikasi pop-up bawah
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Kode QRIS berhasil disimpan ke Galeri!'),
                          backgroundColor: theme.colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(Icons.download_outlined, size: 18, color: theme.colorScheme.primary),
                    label: Text(
                      'Unduh Kode QR',
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                  // ------------------------------------
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Divider(color: Color(0xFFE5E7EB), height: 1),
                  ),
                  Text(
                    'Total Pembayaran',
                    style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRp(widget.totalAmount),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. TIMER & INSTRUKSI ---
            Text(
              'Selesaikan pembayaran dalam',
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF3D4943)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: theme.colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  formattedTime,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.error, // Warna merah
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Pindai kode QR di atas menggunakan\naplikasi e-wallet atau mobile banking favorit\nAnda.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6D7A73),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // --- 3. DETAIL MERCHANT (Order ID) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F8), // surface-container-low
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Merchant', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73))),
                      Text('Vivalavida Coffee', style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order ID', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73))),
                      Text('#VV240901', style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // --- 4. TOMBOL CEK STATUS ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              // Simulasi sukses: Pindah ke layar Payment Success
              // Menggunakan pushReplacement agar user tidak bisa 'back' ke QRIS setelah sukses
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentSuccessScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Cek Status Pembayaran',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}