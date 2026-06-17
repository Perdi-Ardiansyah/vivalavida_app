import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart'; 

import 'notification_screen.dart';
import 'news_detail_screen.dart'; 
import 'complete_profile_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'Memuat...';
  int userPoints = 0;
  bool isLoading = true;
  bool isProfileComplete = false; 

  // --- Variabel State untuk Slider Dinamis ---
  int _currentBannerIndex = 0; 
  List<dynamic> promoBanners = []; // Sekarang menjadi List kosong yang akan diisi dari database
  bool isLoadingPromos = true;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
    _fetchPromos(); // Panggil fungsi tarik promo saat layar dibuka
  }

  // --- 1. Fungsi Penarik Data User ---
  Future<void> _fetchHomeData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('http://10.0.2.2:8000/api/user');
      final response = await http.get(url, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data'] ?? data;

        String fullName = userData['name'] ?? 'Sobat Vivalavida';
        String firstName = fullName.split(' ')[0];

        bool phoneFilled = userData['phone'] != null && userData['phone'].toString().trim().isNotEmpty;
        bool tglLahirFilled = userData['tanggal_lahir'] != null && userData['tanggal_lahir'].toString().trim().isNotEmpty;
        bool genderFilled = userData['jenis_kelamin'] != null && userData['jenis_kelamin'].toString().trim().isNotEmpty;
        
        setState(() {
          userName = firstName;
          userPoints = int.tryParse(userData['poin'].toString()) ?? 0;
          isProfileComplete = phoneFilled && tglLahirFilled && genderFilled; 
          isLoading = false;
        });
      } else {
        setState(() { userName = 'Tamu'; isLoading = false; });
      }
    } catch (e) {
      setState(() { userName = 'Sobat'; isLoading = false; });
    }
  }

  // --- 2. Fungsi Penarik Data Promo dari Database ---
  // --- 2. Fungsi Penarik Data Promo dari Database ---
  Future<void> _fetchPromos() async {
    setState(() => isLoadingPromos = true);
    try {
      // 1. Ambil token dari memori HP
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('http://10.0.2.2:8000/api/promos');
      final response = await http.get(
        url, 
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // 2. Sertakan token di sini!
        }
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          promoBanners = data['data'] ?? [];
          isLoadingPromos = false;
        });
      } else {
        debugPrint('Gagal ambil promo: ${response.statusCode} - ${response.body}');
        setState(() => isLoadingPromos = false);
      }
    } catch (e) {
      debugPrint('Error jaringan promo: $e');
      setState(() => isLoadingPromos = false);
    }
  }

  // Fungsi khusus saat layar ditarik ke bawah (Pull-to-refresh)
  Future<void> _refreshAllData() async {
    await _fetchHomeData();
    await _fetchPromos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const colorSecondary = Color(0xFF705A4F); 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, 
        elevation: 0, 
        scrolledUnderElevation: 0, 
        toolbarHeight: 70, 
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vivalavida Coffee', style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary, fontSize: 22)),
            Text('Halo, $userName!', style: theme.textTheme.bodyMedium),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
                child: Badge(smallSize: 10, backgroundColor: theme.colorScheme.error, child: const Icon(Icons.notifications_none_outlined, size: 28, color: Colors.black87)),
              ),
            ),
          ),
        ],
      ),
      
      body: RefreshIndicator(
        onRefresh: _refreshAllData, // Memperbarui User & Promo
        color: theme.colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              if (!isProfileComplete) ...[
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteProfileScreen())).then((_) => _fetchHomeData()); 
                    },
                    leading: const Icon(Icons.person_outline, color: Colors.black87),
                    title: Text('Lengkapi Profil Anda', style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                    subtitle: Text('Dapatkan Poin Sobat & keuntungan ulang tahun dengan melengkapi profil', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: Color(0xFFFBDCCE), shape: BoxShape.circle),
                              child: const Icon(Icons.star_border, color: colorSecondary),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('REWARDS BALANCE', style: theme.textTheme.labelSmall?.copyWith(color: colorSecondary, fontSize: 10)),
                                isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text('$userPoints Pts', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20, color: Colors.black)),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: colorSecondary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0), minimumSize: const Size(0, 36)),
                          child: const Text('Redeem', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFE5E7EB), height: 1)),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('0 Voucher Tersedia', style: theme.textTheme.bodyMedium), const Icon(Icons.chevron_right, size: 20)]),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 4. SLIDER PROMO DINAMIS ---
              if (isLoadingPromos)
                const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
              else if (promoBanners.isEmpty)
                // Muncul jika tabel promos kosong
                Container(
                  height: 160, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('Belum ada promo saat ini', style: TextStyle(color: Colors.grey))),
                )
              else
                Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 160.0,
                        autoPlay: true, 
                        autoPlayInterval: const Duration(seconds: 4),
                        enlargeCenterPage: true, 
                        viewportFraction: 1.0, 
                        onPageChanged: (index, reason) {
                          setState(() { _currentBannerIndex = index; });
                        },
                      ),
                      items: promoBanners.map((promo) {
                        return Builder(
                          builder: (BuildContext context) {
                            // Menentukan URL Gambar. Asumsi disimpan di storage folder promos
                            // GANTI 'gambar' DENGAN NAMA KOLOM GAMBAR DI TABEL PROMOS KAMU
                            String imageUrl = promo['gambar'] != null && promo['gambar'].toString().startsWith('http')
                                ? promo['gambar'] 
                                : 'http://10.0.2.2:8000/storage/${promo['gambar']}';

                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey[300], // Warna dasar jika gambar telat dimuat
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                  // Menambahkan error builder bawaan jika gambar gagal dimuat
                                  onError: (exception, stackTrace) => const Icon(Icons.broken_image),
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
                                    if (promo['tag'] != null) // GANTI 'tag' DENGAN NAMA KOLOM TABELMU JIKA BEDA
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(4)),
                                        child: Text(promo['tag'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    const SizedBox(height: 8),
                                    // GANTI 'judul' DENGAN NAMA KOLOM JUDUL DI TABELMU
                                    Text(promo['judul'] ?? 'Promo Spesial', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                    // GANTI 'deskripsi' DENGAN NAMA KOLOM DESKRIPSI DI TABELMU
                                    Text(promo['deskripsi'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: promoBanners.asMap().entries.map((entry) {
                        return Container(
                          width: _currentBannerIndex == entry.key ? 20.0 : 8.0, 
                          height: 8.0, margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: theme.colorScheme.primary.withOpacity(_currentBannerIndex == entry.key ? 1.0 : 0.3),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // --- 5. BERITA SECTION (Ini juga bisa dibuat dinamis nanti) ---
              Text('Berita', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22)),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsDetailScreen())); },
                      child: Container(
                        width: 240, margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network('https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=400&auto=format&fit=crop', height: 100, width: double.infinity, fit: BoxFit.cover),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cabang Baru di Kemang!', style: theme.textTheme.labelSmall?.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('Kunjungi outlet terbaru kami dan dapatkan promo BOGO...', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
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
      ),
    );
  }
}