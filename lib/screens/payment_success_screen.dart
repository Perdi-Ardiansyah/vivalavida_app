import 'package:flutter/material.dart';
import 'receipt_screen.dart'; // Import halaman receipt

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // SafeArea agar konten tidak tertutup notch/status bar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(), // Mendorong konten ke tengah

              // --- 1. IKON SUKSES ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary, // Warna hijau utama
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),

              // --- 2. PESAN SUKSES ---
              Text(
                'Pembayaran Berhasil!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF191C1F),
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pesanan Anda sedang kami siapkan\ndengan sepenuh hati.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6D7A73),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // --- 3. KARTU RINGKASAN SINGKAT ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(theme, 'ORDER ID', '#VV-20231012'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFFF2F4F8), height: 1), // Garis pemisah samar
                    ),
                    _buildSummaryRow(
                      theme, 
                      'TOTAL PEMBAYARAN', 
                      'Rp 48.000',
                      valueColor: theme.colorScheme.primary,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFFF2F4F8), height: 1), // Garis pemisah samar
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('METODE PEMBAYARAN', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73), fontSize: 12)),
                        Row(
                          children: [
                            Text('QRIS', style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                            const SizedBox(width: 8),
                            Icon(Icons.qr_code, size: 16, color: theme.colorScheme.primary),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(), // Mendorong tombol ke bawah

              // --- 4. TOMBOL AKSI ---
              ElevatedButton.icon(
                onPressed: () {
                  // Navigasi ke halaman detail struk
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReceiptScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined, size: 20),
                label: const Text('Lihat Struk', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // Kembali ke beranda
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6D7A73),
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk baris ringkasan di dalam kartu
  Widget _buildSummaryRow(ThemeData theme, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73), fontSize: 12),
        ),
        Text(
          value,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 14,
            color: valueColor ?? const Color(0xFF191C1F),
          ),
        ),
      ],
    );
  }
}