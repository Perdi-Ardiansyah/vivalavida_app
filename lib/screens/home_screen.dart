import 'package:flutter/material.dart';
import 'notification_screen.dart';
import 'news_detail_screen.dart'; // Pastikan untuk mengimpor halaman notifikasi
import 'complete_profile_screen.dart'; // Pastikan untuk mengimpor halaman lengkapi profil

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const colorSecondary = Color(0xFF705A4F); 

    return Scaffold(
      // --- KUNCI: Pindahkan header ke properti appBar di sini ---
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, // Menyatu dengan warna background
        elevation: 0, 
        scrolledUnderElevation: 0, // Mencegah AppBar berubah warna saat konten di-scroll (Material 3)
        toolbarHeight: 70, // Memberikan ruang cukup untuk dua baris teks
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vivalavida Coffee',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 22,
              ),
            ),
            Text(
              'Halo, Perdi!', 
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              // Tambahkan GestureDetector di sini
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationScreen()), // Navigasi ke halaman Notifikasi
                  );
                },
                child: Badge(
                  smallSize: 10,
                  backgroundColor: theme.colorScheme.error,
                  child: const Icon(
                    Icons.notifications_none_outlined, 
                    size: 28, 
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Konten di bawahnya tetap bisa di-scroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 2. KARTU LENGKAPI PROFIL ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)), 
              ),
              child: ListTile(
                // --- TAMBAHKAN FUNGSI ONTAP DI SINI ---
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompleteProfileScreen(),
                    ),
                  );
                },
                
                leading: const Icon(Icons.person_outline, color: Colors.black87),
                title: Text(
                  'Lengkapi Profil Anda',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 14),
                ),
                subtitle: Text(
                  'Dapatkan Poin Sobat & keuntungan ulang tahun dengan melengkapi profil',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            // --- 3. KARTU REWARDS ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBDCCE), 
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.star_border, color: colorSecondary),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'REWARDS BALANCE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorSecondary,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '1,250 Pts',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Redeem', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFE5E7EB), height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0 Voucher Tersedia', style: theme.textTheme.bodyMedium),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 4. BANNER PROMO ---
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1511920170033-f8396924c348?q=80&w=600&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIMITED TIME',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Match Day Specials',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Fuel your passion with our signature game-day brews.',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- 5. BERITA SECTION ---
            Text(
              'Berita',
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  // Di sini kita mulai membungkusnya dengan GestureDetector
                  return GestureDetector(
                    onTap: () {
                      // Fungsi untuk berpindah ke halaman NewsDetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewsDetailScreen(),
                        ),
                      );
                    },
                    // Container kartu berita ditaruh di dalam properti child
                    child: Container(
                      width: 240,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=400&auto=format&fit=crop',
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cabang Baru di Kemang!',
                                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kunjungi outlet terbaru kami dan dapatkan promo BOGO...',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}