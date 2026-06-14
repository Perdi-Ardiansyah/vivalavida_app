import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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
          'Notifikasi',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.checklist, color: theme.colorScheme.primary),
            onPressed: () {
              // Logika tandai semua sudah dibaca
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION: BELUM DIBACA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Belum Dibaca',
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '2 Baru',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildNotificationCard(
              context: context,
              isRead: false,
              icon: Icons.coffee,
              iconColor: theme.colorScheme.primary,
              iconBgColor: const Color(0xFFE6F0EB), // Light primary tint
              title: 'Pesanan Sedang Disiapkan',
              time: '2 mnt',
              description: 'Espresso Macchiato kamu sedang diracik oleh barista kami.',
            ),
            _buildNotificationCard(
              context: context,
              isRead: false,
              icon: Icons.star,
              iconColor: const Color(0xFF705A4F), // Secondary color
              iconBgColor: const Color(0xFFFBDCCE).withOpacity(0.5), // Light secondary tint
              title: '+50 Poin Vivalavida',
              time: '15 mnt',
              description: 'Selamat! Kamu baru saja mendapatkan 50 poin dari transaksi terakhir.',
            ),

            const SizedBox(height: 24),

            // --- SECTION: SUDAH DIBACA ---
            Text(
              'Sudah Dibaca',
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),

            _buildNotificationCard(
              context: context,
              isRead: true,
              icon: Icons.campaign_outlined,
              iconColor: Colors.grey,
              iconBgColor: Colors.transparent,
              title: 'Promo Akhir Pekan!',
              time: 'Kemarin',
              description: 'Nikmati Buy 1 Get 1 untuk semua varian Nitro Cold Brew hari ini.',
            ),
            _buildNotificationCard(
              context: context,
              isRead: true,
              icon: Icons.check_circle_outline,
              iconColor: Colors.grey,
              iconBgColor: Colors.transparent,
              title: 'Pesanan Selesai',
              time: '2 Hari Lalu',
              description: 'Terima kasih telah memesan. Bagaimana rasa kopimu hari ini?',
            ),
          ],
        ),
      ),
    );
  }

  // Widget kustom untuk item notifikasi agar kode lebih bersih
  Widget _buildNotificationCard({
    required BuildContext context,
    required bool isRead,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String time,
    required String description,
  }) {
    final theme = Theme.of(context);
    // Menggunakan warna surface-container-low (#f2f4f8) jika sudah dibaca
    final bgColor = isRead ? const Color(0xFFF2F4F8) : Colors.white; 
    final textColor = isRead ? const Color(0xFF6D7A73) : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isRead
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Garis aksen hijau di kiri untuk notifikasi baru
            if (!isRead)
              Container(
                width: 4,
                color: theme.colorScheme.primary,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kotak Ikon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isRead ? const Color(0xFFE0E2E6) : iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    // Teks Notifikasi
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                time,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF6D7A73),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: isRead ? const Color(0xFF6D7A73) : const Color(0xFF3D4943),
                            ),
                          ),
                        ],
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
}