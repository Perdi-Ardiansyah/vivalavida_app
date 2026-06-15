import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'payment_success_screen.dart';

class QrisPaymentScreen extends StatefulWidget {
  final int totalAmount;
  final String orderId;
  final String qrUrl; // Menerima URL QR asli

  const QrisPaymentScreen({
    super.key,
    required this.totalAmount,
    required this.orderId,
    required this.qrUrl,
  });

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  int secondsRemaining = 300;
  Timer? _countdownTimer;
  Timer? _pollingTimer;
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    startTimer();
    startPolling(); // Memulai pengecekan otomatis di background
  }

  // Timer untuk hitung mundur UI (5 menit)
  void startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        _countdownTimer?.cancel();
        _pollingTimer?.cancel(); // Hentikan polling jika waktu habis
      }
    });
  }

  // Timer untuk mengecek status ke server otomatis setiap 5 detik
  void startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _cekStatusOtomatis();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel(); // Wajib dimatikan agar tidak bocor di memori
    super.dispose();
  }

  // Fungsi pengecekan senyap di latar belakang
  Future<void> _cekStatusOtomatis() async {
    if (isChecking) return;

    try {
      // Ganti IP dengan URL server produksimu nanti jika sudah online
      final url = Uri.parse(
        'http://10.0.2.2:8000/api/transaksi/status/${widget.orderId}',
      );
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'paid') {
          _countdownTimer?.cancel();
          _pollingTimer?.cancel();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pembayaran Otomatis Diterima!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessScreen(
                  orderId: widget.orderId,
                  totalAmount: widget.totalAmount, // Mengoper total biaya
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Abaikan error jaringan saat polling otomatis agar tidak mengganggu UI
    }
  }

  // Fungsi pengecekan manual (saat tombol ditekan)
  Future<void> cekStatusManual() async {
    if (isChecking) return;

    setState(() {
      isChecking = true;
    });

    try {
      final url = Uri.parse(
        'http://10.0.2.2:8000/api/transaksi/status/${widget.orderId}',
      );
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      final data = json.decode(response.body);

      if (data['status'] == 'paid') {
        _countdownTimer?.cancel();
        _pollingTimer?.cancel();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembayaran Lunas! Memproses pesanan...'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                orderId: widget.orderId,
                totalAmount: widget.totalAmount, // Mengoper total biaya
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // SEKARANG FLUTTER AKAN MENAMPILKAN PESAN ASLI DARI LARAVEL
              content: Text(data['message'] ?? 'Status tidak diketahui'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan koneksi ke server.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isChecking = false;
        });
      }
    }
  }

  String get formattedTime {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.qrUrl.isNotEmpty
                        ? QrImageView(
                            data: widget.qrUrl,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                          )
                        : const SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Pembayaran',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6D7A73),
                    ),
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
            Text(
              'Selesaikan pembayaran dalam',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF3D4943),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  formattedTime,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.error,
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Merchant',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6D7A73),
                        ),
                      ),
                      Text(
                        'Vivalavida Coffee',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order ID',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6D7A73),
                        ),
                      ),
                      Text(
                        widget.orderId,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: isChecking ? null : cekStatusManual,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isChecking
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Cek Status Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
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
