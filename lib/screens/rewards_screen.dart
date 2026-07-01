import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk fitur Copy kode voucher
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  bool isLoading = true;
  int userPoints = 0;
  String errorMessage = '';
  
  List<dynamic> _vouchersKatalog = [];
  List<dynamic> _myVouchers = []; // Variabel baru untuk Dompet Voucher

  @override
  void initState() {
    super.initState();
    _fetchInitialLoyaltyData();
  }

  // --- AMBIL SEMUA DATA (USER, KATALOG, & DOMPET VOUCHER) ---
  Future<void> _fetchInitialLoyaltyData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final userUrl = Uri.parse('https://vivalavida.kotapintar.my.id/api/user');
      final rewardsUrl = Uri.parse('https://vivalavida.kotapintar.my.id/api/rewards');
      final myVouchersUrl = Uri.parse('https://vivalavida.kotapintar.my.id/api/vouchers/me');

      // Tembak 3 API sekaligus agar hemat waktu loading
      final responses = await Future.wait([
        http.get(userUrl, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'}),
        http.get(rewardsUrl, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'}),
        http.get(myVouchersUrl, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'}),
      ]);

      if (responses[0].statusCode == 200) {
        final userData = json.decode(responses[0].body);
        final user = userData['data'] ?? userData;
        // PENGAMAN 1: Tangani nilai poin jika null dari database
        userPoints = int.tryParse(user['poin']?.toString() ?? '0') ?? 0;
      }

      if (responses[1].statusCode == 200) {
        final rewardsData = json.decode(responses[1].body);
        _vouchersKatalog = rewardsData['data'] ?? [];
      }

      if (responses[2].statusCode == 200) {
        final myVouchersData = json.decode(responses[2].body);
        _myVouchers = myVouchersData['data'] ?? [];
      }

      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Gagal memuat data rewards.';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _redeemVoucher(int voucherId, int poinDibutuhkan) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/rewards/redeem');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'reward_id': voucherId}),
      );

      if (mounted) Navigator.pop(context);

      final resData = json.decode(response.body);

      if (response.statusCode == 200 && resData['success'] == true) {
        // Refresh semua data (poin dan dompet voucher) setelah sukses klaim
        _fetchInitialLoyaltyData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voucher berhasil diklaim!'), backgroundColor: Color(0xFF046A41)),
          );
        }
      } else {
        throw Exception(resData['message'] ?? 'Gagal menukar voucher.');
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }

  // PENGAMAN 2: Format angka yang kebal crash locale
  String formatPoin(int points) {
    return NumberFormat('#,##0').format(points).replaceAll(',', '.');
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
        title: Text('Rewards', style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary, fontSize: 22)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetchInitialLoyaltyData, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchInitialLoyaltyData,
                  color: theme.colorScheme.primary,
                  child: _buildRewardsContent(theme),
                ),
    );
  }

  Widget _buildRewardsContent(ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. KARTU MEMBER ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vivalavida Rewards', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatPoin(userPoints), style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontSize: 36)),
                    const SizedBox(width: 4),
                    const Padding(padding: EdgeInsets.only(bottom: 6.0), child: Text('pts', style: TextStyle(color: Colors.white, fontSize: 16))),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(userPoints >= 1000 ? 'Gold Member' : 'Silver Member', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- 2. DOMPET VOUCHER SAYA ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(theme, 'Voucher Saya'),
              if (_myVouchers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFBDCCE), borderRadius: BorderRadius.circular(8)),
                  child: Text('${_myVouchers.length} Tersedia', style: const TextStyle(color: Color(0xFF705A4F), fontSize: 10, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          const SizedBox(height: 12),
          
          if (_myVouchers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: const Center(
                child: Text('Dompet kosong. Yuk, tukarkan poinmu!', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            )
          else
            // Render Daftar Voucher Secara Horizontal agar tidak memakan ruang ke bawah
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _myVouchers.length,
                itemBuilder: (context, index) {
                  final v = _myVouchers[index];
                  return _buildMyVoucherCard(theme, v);
                },
              ),
            ),
          const SizedBox(height: 32),

          // --- 3. DAFTAR TUKAR POIN ---
          _buildSectionTitle(theme, 'Tukar Poin dengan Voucher'),
          const SizedBox(height: 12),
          
          if (_vouchersKatalog.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: const Center(child: Text('Belum ada voucher yang dapat ditukar saat ini.', style: TextStyle(color: Colors.grey, fontSize: 13))),
            )
          else
            ..._vouchersKatalog.map((voucher) {
              final int id = voucher['id'] ?? 0;
              final String title = voucher['nama'] ?? 'Voucher Diskon';
              final String desc = voucher['deskripsi'] ?? 'Klik klaim untuk menukar poin.';
              // PENGAMAN 3: Tangani nilai poin_dibutuhkan jika null
              final int pointsNeeded = int.tryParse(voucher['poin_dibutuhkan']?.toString() ?? '0') ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildRedeemCard(
                  theme: theme,
                  title: title,
                  subtitle: desc,
                  points: '$pointsNeeded pts',
                  canClaim: userPoints >= pointsNeeded,
                  onClaim: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Tukar Poin?'),
                        content: Text('Apakah Anda yakin ingin menukar $pointsNeeded poin dengan "$title"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _redeemVoucher(id, pointsNeeded);
                            },
                            child: const Text('Tukar', style: TextStyle(color: Color(0xFF046A41), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18));
  }

  // Desain Card Khusus Dompet Voucher
  Widget _buildMyVoucherCard(ThemeData theme, dynamic voucher) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_activity, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(voucher['judul'] ?? 'Voucher', style: theme.textTheme.labelSmall?.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Text(voucher['deskripsi'] ?? '', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: Colors.grey[600])),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE5E7EB))),
                // PENGAMAN 4: Tangani teks kode voucher jika null
                child: Text(voucher['kode'] ?? 'TIDAK-ADA-KODE', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
              ),
              InkWell(
                onTap: () {
                  // PENGAMAN 5: Tangani clipboard jika kode null
                  Clipboard.setData(ClipboardData(text: voucher['kode'] ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode voucher disalin!')));
                },
                child: Text('Salin', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRedeemCard({required ThemeData theme, required String title, required String subtitle, required String points, required bool canClaim, required VoidCallback onClaim}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFE6F0EB), shape: BoxShape.circle),
            child: Icon(Icons.confirmation_number_outlined, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(points, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                    ElevatedButton(
                      onPressed: canClaim ? onClaim : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        disabledBackgroundColor: Colors.grey[200],
                        minimumSize: const Size(80, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text('Claim', style: TextStyle(color: canClaim ? Colors.white : Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
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
}