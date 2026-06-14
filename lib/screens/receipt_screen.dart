import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

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
            // Hapus kata 'const' sehingga menjadi seperti ini
            icon: Icon(Icons.share_outlined, color: theme.colorScheme.primary), 
            onPressed: () {
              // Logika membagikan struk (share)
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pembayaran Berhasil',
                      style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terima kasih atas pesanan Anda!',
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- 2. INFORMASI ORDER ---
              _buildInfoRow(theme, 'Order ID', '#VLV-8829'),
              const SizedBox(height: 12),
              _buildInfoRow(theme, 'Date', '24 Oct 2024, 10:30 WIB'),
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
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 12),
                      ),
                      const SizedBox(width: 8),
                      Text('Gopay', style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                    ],
                  ),
                ],
              ),
              
              _buildDashedLine(),

              // --- 3. DAFTAR ITEM ---
              _buildItemRow(theme, 'Aren Latte', 1, 'Rp 28.000'),
              const SizedBox(height: 16),
              _buildItemRow(theme, 'Almond Croissant', 1, 'Rp 35.000'),
              
              _buildDashedLine(),

              // --- 4. RINGKASAN BIAYA ---
              _buildSummaryRow(theme, 'Subtotal', 'Rp 63.000'),
              const SizedBox(height: 12),
              _buildSummaryRow(theme, 'Pajak (11%)', 'Rp 6.930'),
              const SizedBox(height: 12),
              _buildSummaryRow(
                theme, 
                'Diskon Voucher', 
                'Rp -1.930', 
                valueColor: theme.colorScheme.primary, // Warna hijau sesuai desain
              ),
              
              _buildDashedLine(),

              // --- 5. TOTAL ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20)),
                  Text(
                    'Rp 68.000',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 22,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // --- 6. TOMBOL AKSI BAWAH ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Simpan Bukti
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), // Lebih bulat
                ),
              ),
              const SizedBox(height: 12),
              
              // Tombol Kembali ke Beranda
              OutlinedButton(
                onPressed: () {
                  // Menghapus semua riwayat halaman (checkout, menu, dll) dan kembali ke MainScreen (Beranda)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
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

  // --- HELPER WIDGETS ---

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73))),
        Text(value, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
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
            Text(name, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
            const SizedBox(height: 4),
            Text('Qty: $qty', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73), fontSize: 12)),
          ],
        ),
        Text(price, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
      ],
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73))),
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

  // Widget Kustom untuk Garis Putus-putus (Dashed Line)
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