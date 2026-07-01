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
  // --- STATE DATA ---
  String userName = 'Sobat';
  int userPoints = 0;
  bool isProfileComplete = false; 
  int _currentBannerIndex = 0; 
  List<dynamic> promoBanners = [];
  List<dynamic> newsList = [];
  int unreadNotifCount = 0;

  // --- HANYA ADA SATU VARIABEL LOADING GLOBAL ---
  bool _isPageLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllHomeData(); // Panggil fungsi master loading tunggal
  }

  // --- FUNGSI MASTER: MEMUAT SEMUA DATA SEKALIGUS ---
  Future<void> _fetchAllHomeData() async {
    if (!mounted) return;
    setState(() => _isPageLoading = true); // Aktifkan loading utama

    try {
      // Menjalankan semua request API secara pararel (bersamaan)
      await Future.wait([
        _fetchHomeDataSilently(),
        _fetchPromosSilently(),
        _fetchNewsSilently(),
        _fetchNotificationsSilently(),
      ]);
    } catch (e) {
      debugPrint('Error master fetch data beranda: $e');
    } finally {
      if (mounted) {
        setState(() => _isPageLoading = false); // Matikan loading jika semua sudah selesai
      }
    }
  }

  // --- 1. Request Data User ---
  Future<void> _fetchHomeDataSilently() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/user');
      final response = await http.get(url, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data'] ?? data;

        String fullName = userData['name'] ?? 'Sobat Vivalavida';
        String firstName = fullName.split(' ')[0];

        bool phoneFilled = userData['phone'] != null && userData['phone'].toString().trim().isNotEmpty;
        bool tglLahirFilled = userData['tanggal_lahir'] != null && userData['tanggal_lahir'].toString().trim().isNotEmpty;
        bool genderFilled = userData['jenis_kelamin'] != null && userData['jenis_kelamin'].toString().trim().isNotEmpty;
        
        userName = firstName;
        userPoints = int.tryParse(userData['poin'].toString()) ?? 0;
        isProfileComplete = phoneFilled && tglLahirFilled && genderFilled; 
      }
    } catch (e) {
      debugPrint('Error silent user data: $e');
    }
  }

  // --- 2. Request Data Banner Promo ---
  Future<void> _fetchPromosSilently() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/promos');
      final response = await http.get(url, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        promoBanners = data['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Error silent promo data: $e');
    }
  }

  // --- 3. Request Data Berita ---
  Future<void> _fetchNewsSilently() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/articles');
      final response = await http.get(url, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        newsList = data['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Error silent news data: $e');
    }
  }

  // --- 4. Request Data Notifikasi ---
  Future<void> _fetchNotificationsSilently() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/user/notifications');
      final response = await http.get(url, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List notifs = data['data'] ?? [];
        
        unreadNotifCount = notifs.where((n) {
          if (n['read_at'] != null) return false;
          if (n['is_read'] != null) return n['is_read'] == 0 || n['is_read'] == false || n['is_read'] == '0';
          return n['read_at'] == null;
        }).length;
      }
    } catch (e) {
      debugPrint('Error silent notification data: $e');
    }
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
            // userName sudah pasti siap saat halaman lolos dari loading screen
            Text('Halo, $userName!', style: theme.textTheme.bodyMedium),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()))
                      .then((_) => _fetchAllHomeData()); // Panggil master refresh jika kembali
                },
                child: Badge(
                  isLabelVisible: unreadNotifCount > 0, 
                  smallSize: 10, 
                  backgroundColor: theme.colorScheme.error, 
                  child: const Icon(Icons.notifications_none_outlined, size: 28, color: Colors.black87)
                ),
              ),
            ),
          ),
        ],
      ),
      
      // KONDISI LOADING UTAMA: Cukup buat percabangan tunggal di body
      body: _isPageLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchAllHomeData, // Pull-to-refresh akan menyegarkan seluruh data sekaligus
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteProfileScreen())).then((_) => _fetchAllHomeData()); 
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
                                      Text('$userPoints Pts', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20, color: Colors.black)),
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

                    if (promoBanners.isEmpty)
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
                                  String imageUrl = promo['gambar'] != null && promo['gambar'].toString().startsWith('http')
                                      ? promo['gambar'] 
                                      : 'https://vivalavida.kotapintar.my.id/storage/${promo['gambar']}';

                                  return Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey[300], 
                                      image: DecorationImage(
                                        image: NetworkImage(imageUrl),
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
                                          if (promo['tag'] != null && promo['tag'].toString().isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(4)),
                                              child: Text(promo['tag'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                          const SizedBox(height: 8),
                                          Text(promo['judul'] ?? 'Promo Spesial', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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

                    Text('Berita & Artikel', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22)),
                    const SizedBox(height: 16),
                    
                    if (newsList.isEmpty)
                      Container(
                        height: 150, width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                        child: const Center(child: Text('Belum ada berita terbaru.', style: TextStyle(color: Colors.grey))),
                      )
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: newsList.length,
                          itemBuilder: (context, index) {
                            final article = newsList[index];

                            String imageUrl = '';
                            if (article['gambar'] != null) {
                              imageUrl = article['gambar'].toString().startsWith('http') 
                                ? article['gambar'] 
                                : 'https://vivalavida.kotapintar.my.id/storage/${article['gambar']}';
                            }
                            
                            return GestureDetector(
                              onTap: () { 
                                Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailScreen(article: article))); 
                              },
                              child: Container(
                                width: 240, margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl, 
                                            height: 100, 
                                            width: double.infinity, 
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                                          )
                                        : _buildPlaceholderImage(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(article['judul'] ?? 'Tanpa Judul', style: theme.textTheme.labelSmall?.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Text(article['konten'] ?? 'Tidak ada deskripsi singkat.', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
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

  Widget _buildPlaceholderImage() {
    return Container(
      height: 100, 
      width: double.infinity, 
      color: Colors.grey[300], 
      child: const Icon(Icons.newspaper, color: Colors.grey, size: 40)
    );
  }
}