import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key});

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
          'Detail Berita',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {
              // Logika untuk membagikan berita
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HERO IMAGE & KATEGORI ---
            Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=800&auto=format&fit=crop', // Gambar yang sama dengan di beranda
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Promo & Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- 2. KONTEN BERITA ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tanggal
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6D7A73)),
                      const SizedBox(width: 8),
                      Text(
                        '24 Okt 2024',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF6D7A73),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Judul Berita
                  Text(
                    'Cabang Baru di Kemang!',
                    style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 20),

                  // Isi Berita (Paragraf)
                  Text(
                    'Kabar gembira bagi para pecinta kopi di Jakarta Selatan! Vivalavida Coffee kini resmi membuka pintu untuk outlet terbaru kami di jantung kawasan Kemang. Menghadirkan konsep Sophisticated Minimalism, cabang ini dirancang sebagai oase tenang di tengah hiruk-pikuk kota.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Arsitektur outlet Kemang menggabungkan elemen material mentah seperti beton ekspos dengan kehangatan kayu jati pilihan, menciptakan suasana yang intim namun profesional. Area semi-outdoor kami yang dipenuhi tanaman hijau menjadi spot favorit baru bagi mereka yang ingin menikmati manual brew sambil merasakan semilir angin Jakarta.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak hanya menawarkan tempat yang estetis, cabang Kemang juga menjadi rumah bagi limited seasonal beans yang dipanggang khusus oleh roaster internal kami. Kami mengundang Anda untuk merasakan pengalaman minum kopi yang lebih bermakna di Vivalavida Coffee Kemang.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Buka setiap hari mulai pukul 07:00 hingga 22:00 WIB. Mari rayakan awal baru ini bersama kami!',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}