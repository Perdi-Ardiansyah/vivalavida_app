import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  // Menambahkan parameter untuk menerima data dari HomeScreen
  final Map<String, dynamic> article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Ekstrak data dari map article
    String title = article['judul'] ?? 'Tanpa Judul';
    String content = article['konten'] ?? 'Tidak ada konten pada artikel ini.';
    String category = article['kategori'] ?? 'Berita';
    
    // Format tanggal sederhana (memotong format YYYY-MM-DDTHH:MM:SSZ dari Laravel)
    String rawDate = article['created_at'] ?? '';
    String formattedDate = rawDate.isNotEmpty ? rawDate.split('T')[0] : 'Baru saja';

    // 2. Format URL Gambar
    String imageUrl = '';
    if (article['gambar'] != null) {
      imageUrl = article['gambar'].toString().startsWith('http')
          ? article['gambar']
          : 'https://vivalavidacoffeshop.rf.gd/storage/${article['gambar']}';
    }

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
          'Detail Konten',
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
              // TODO: Tambahkan fungsi share nanti menggunakan package share_plus
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur bagikan segera hadir!')),
              );
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
                imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
                
                // Lencana Kategori
                Positioned(
                  bottom: 16,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      // Beda warna tergantung kategori
                      color: category == 'Promo' 
                          ? Colors.orange 
                          : (category == 'Event' ? Colors.red : theme.colorScheme.primary),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
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
                  // Tanggal & Penulis
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6D7A73)),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF6D7A73),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.person_outline, size: 14, color: Color(0xFF6D7A73)),
                      const SizedBox(width: 4),
                      Text(
                        article['penulis'] ?? 'Admin',
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
                    title,
                    style: theme.textTheme.headlineLarge?.copyWith(fontSize: 26, height: 1.2),
                  ),
                  const SizedBox(height: 24),

                  // Isi Berita
                  // Karena dari database biasanya berupa satu string panjang dengan enter (\n),
                  // Text widget secara otomatis akan membaca \n sebagai paragraf baru.
                  Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.8, 
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Gambar Default jika artikel tidak punya gambar
  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.newspaper, size: 80, color: Colors.grey),
      ),
    );
  }
}