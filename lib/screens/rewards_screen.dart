import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Digunakan untuk memformat angka poin (misal 1500 jadi 1.500)

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  bool isLoading = true;
  int userPoints = 0; // Variabel untuk menyimpan poin dari database
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUserPoints();
  }

  // --- MESIN PENYEDOT DATA POIN DARI LARAVEL ---
  Future<void> fetchUserPoints() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      // Memanggil endpoint standar Laravel untuk mengambil data user login saat ini
      // (Pastikan endpoint /api/user ini ada di routes/api.php kamu)
      final url = Uri.parse('http://10.0.2.2:8000/api/user');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          // Laravel bawaan biasanya mengembalikan object user langsung,
          // tapi jika kamu membungkusnya dalam 'data', kita handle keduanya:
          final userData = data['data'] ?? data; 
          
          // Konversi aman untuk memastikan poin selalu menjadi angka
          userPoints = int.tryParse(userData['poin'].toString()) ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat profil (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error koneksi:\n$e';
        isLoading = false;
      });
    }
  }

  // Helper untuk memformat angka (1500 -> 1.500)
  String formatPoin(int points) {
    return NumberFormat.decimalPattern('id').format(points);
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
        title: Text(
          'Rewards',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      // Tampilkan Loading / Error / Konten
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center))
              : _buildRewardsContent(theme),
    );
  }

  // --- KONTEN DESAIN REWARD ASLI MILIKMU ---
  Widget _buildRewardsContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. KARTU MEMBER (HEADER) ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vivalavida Rewards',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // MENGGUNAKAN DATA POIN DINAMIS DARI DATABASE
                    Text(
                      formatPoin(userPoints),
                      style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontSize: 36),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text('pts', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Badge Member (Bisa dibuat dinamis jika mau, misal: userPoints > 1000 = Gold)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        userPoints >= 1000 ? 'Gold Member' : 'Silver Member', // Logika sederhana
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Expiring Soon Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Expiring Soon', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    const Text('0 pts', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1.0, 
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('No points expiring soon', style: TextStyle(color: Colors.white70, fontSize: 10, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- 2. VOUCHER SAYA ---
          _buildSectionTitle(theme, 'Voucher Saya'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBDCCE).withOpacity(0.5), // Light Orange
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_activity_outlined, color: Color(0xFF705A4F)),
              ),
              title: Text('2 Voucher Tersedia', style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
              subtitle: Text('Gunakan sebelum kedaluwarsa', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF6D7A73)),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 32),

          // --- 3. TUKAR POIN ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(theme, 'Tukar Poin'),
              TextButton(
                onPressed: () {},
                child: Text('Lihat Semua', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          _buildRedeemCard(
            theme: theme,
            icon: Icons.percent,
            iconBgColor: const Color(0xFFFBDCCE),
            iconColor: const Color(0xFF705A4F),
            title: '15% Off Total Bill',
            subtitle: 'Valid for all menu items',
            points: '450 pts',
          ),
          const SizedBox(height: 12),
          _buildRedeemCard(
            theme: theme,
            icon: Icons.cake_outlined,
            iconBgColor: const Color(0xFFE6F0EB),
            iconColor: theme.colorScheme.primary,
            title: 'Free Seasonal Pastry',
            subtitle: 'Choice of Croissant or Muffin',
            points: '600 pts',
          ),
          const SizedBox(height: 32),

          // --- 4. RIWAYAT TRANSAKSI & POIN ---
          _buildSectionTitle(theme, 'Riwayat Transaksi & Poin'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildHistoryItem(
                  theme: theme,
                  icon: Icons.coffee,
                  title: 'Caramel Macchiato',
                  date: 'Hari ini',
                  points: '+15 pts',
                  price: 'Rp 45.000',
                  isPositive: true,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFE5E7EB), height: 1)),
                _buildHistoryItem(
                  theme: theme,
                  icon: Icons.cake,
                  title: 'Birthday Bonus',
                  date: 'Bulan lalu',
                  points: '+100 pts',
                  price: 'System',
                  isPositive: true,
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Lihat Riwayat Lengkap >', style: TextStyle(color: Color(0xFF6D7A73), fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
    );
  }

  Widget _buildRedeemCard({
    required ThemeData theme,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String points,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(points, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.primary),
                        minimumSize: const Size(80, 32),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Claim', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String date,
    required String points,
    required String price,
    required bool isPositive,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFF2F4F8), 
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6D7A73), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelSmall?.copyWith(fontSize: 13)),
              const SizedBox(height: 4),
              Text(date, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              points,
              style: TextStyle(
                color: isPositive ? theme.colorScheme.primary : theme.colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(price, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}