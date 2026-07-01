import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  bool isLoading = true;

  // State untuk Data Keamanan
  bool isAuthenticatorEnabled = false;
  bool isNewLoginAlertEnabled = true;
  bool isSecurityRecommendationEnabled = false;
  List<dynamic> loginHistory = [];

  // Controller untuk input password
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _fetchSecurityData();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- 1. AMBIL DATA 2FA & RIWAYAT LOGIN ---
  Future<void> _fetchSecurityData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      // Ambil Profil (untuk status 2FA)
      final userRes = await http.get(Uri.parse('https://vivalavida.kotapintar.my.id/api/user'),
          headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
      
      // Ambil Riwayat Login
      final historyRes = await http.get(Uri.parse('https://vivalavida.kotapintar.my.id/api/user/login-history'),
          headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});

      if (userRes.statusCode == 200 && historyRes.statusCode == 200) {
        final userData = json.decode(userRes.body)['data'] ?? json.decode(userRes.body);
        final historyData = json.decode(historyRes.body)['data'] ?? [];

        setState(() {
          // Konversi dari database (1/0) ke bool (true/false)
          isAuthenticatorEnabled = userData['is_2fa_enabled'] == 1 || userData['is_2fa_enabled'] == true;
          loginHistory = historyData;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // --- 2. TOGGLE 2FA ---
  Future<void> _toggle2FA(bool value) async {
    // Simpan perubahan secara visual dulu agar UI responsif
    setState(() => isAuthenticatorEnabled = value);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/user/toggle-2fa');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'is_enabled': value}),
      );

      if (response.statusCode != 200) {
        // Jika gagal, kembalikan posisi switch
        setState(() => isAuthenticatorEnabled = !value);
        _showSnackBar('Gagal menyimpan pengaturan 2FA');
      }
    } catch (e) {
      setState(() => isAuthenticatorEnabled = !value);
      _showSnackBar('Terjadi kesalahan jaringan.');
    }
  }

  // --- 3. KELUAR DARI SEMUA PERANGKAT ---
  Future<void> _logoutOtherDevices() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/user/logout-other-devices');
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _showSnackBar('Berhasil keluar dari perangkat lain', isSuccess: true);
        _fetchSecurityData(); // Refresh list riwayat login
      } else {
        _showSnackBar('Gagal memutus sesi perangkat lain');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan jaringan.');
    }
  }

  // --- 4. UBAH KATA SANDI ---
  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Semua kolom kata sandi harus diisi.');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Konfirmasi kata sandi baru tidak cocok.');
      return;
    }
    if (_newPasswordController.text.length < 8) {
      _showSnackBar('Kata sandi baru minimal 8 karakter.');
      return;
    }

    setState(() => isChangingPassword = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/user/change-password');
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
          'new_password_confirmation': _confirmPasswordController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar('Kata sandi berhasil diubah!', isSuccess: true);
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        String errorMsg = responseData['message'] ?? 'Gagal mengubah kata sandi.';
        _showSnackBar(errorMsg);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan jaringan.');
    } finally {
      setState(() => isChangingPassword = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isSuccess ? Colors.green : Colors.red, behavior: SnackBarBehavior.floating),
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Keamanan Akun', style: theme.textTheme.headlineMedium?.copyWith(color: const Color(0xFF6D7A73), fontSize: 20)),
        centerTitle: false,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HERO BANNER ---
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1497935586351-b67a49e012bf?q=80&w=600&auto=format&fit=crop'), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.2)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Lindungi Akun Anda', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Kelola keamanan dan akses login\nAnda.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. UBAH KATA SANDI ---
            _buildSectionCard(
              children: [
                _buildSectionHeader(theme, Icons.lock_outline, 'Ubah Kata Sandi'),
                const SizedBox(height: 16),
                _buildPasswordField(theme, 'Kata Sandi Saat Ini', _currentPasswordController),
                const SizedBox(height: 12),
                _buildPasswordField(theme, 'Kata Sandi Baru', _newPasswordController),
                const SizedBox(height: 12),
                _buildPasswordField(theme, 'Konfirmasi Kata Sandi Baru', _confirmPasswordController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isChangingPassword ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isChangingPassword
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 3. AUTENTIKASI DUA FAKTOR (2FA) ---
            _buildSectionCard(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader(theme, Icons.verified_user_outlined, 'Autentikasi Dua Faktor'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: isAuthenticatorEnabled ? const Color(0xFFE6F0EB) : Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Text(isAuthenticatorEnabled ? 'Aktif' : 'Nonaktif', style: TextStyle(color: isAuthenticatorEnabled ? theme.colorScheme.primary : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tambahkan lapisan keamanan ekstra dengan kode verifikasi setiap kali Anda login dari perangkat baru.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73), fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.smartphone, color: Color(0xFF705A4F), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Aplikasi Autentikator', style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                          Text('Dikontrol dari server', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: const Color(0xFF6D7A73))),
                        ],
                      ),
                    ),
                    Switch(
                      value: isAuthenticatorEnabled,
                      activeColor: theme.colorScheme.primary,
                      onChanged: _toggle2FA, // Terhubung dengan fungsi API
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 4. PERINGATAN KEAMANAN ---
            _buildSectionCard(
              children: [
                _buildSectionHeader(theme, Icons.notifications_active_outlined, 'Peringatan Keamanan'),
                const SizedBox(height: 16),
                _buildSwitchRow(
                  theme: theme,
                  title: 'Login Baru Terdeteksi',
                  subtitle: 'Terima email jika akun diakses dari\nperangkat lain.',
                  value: isNewLoginAlertEnabled,
                  onChanged: (val) => setState(() => isNewLoginAlertEnabled = val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 5. RIWAYAT SESI LOGIN ---
            _buildSectionCard(
              children: [
                _buildSectionHeader(theme, Icons.history, 'Riwayat Sesi Login'),
                const SizedBox(height: 16),
                if (loginHistory.isEmpty)
                  const Text('Belum ada riwayat login tercatat.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                
                // Looping data riwayat login dari database
                ...loginHistory.map((history) {
                  return Column(
                    children: [
                      _buildDeviceHistoryItem(
                        theme: theme,
                        icon: Icons.laptop_mac, // Bisa dinamis jika ada deteksi tipe device
                        deviceName: history['device_name'] ?? 'Perangkat Tidak Dikenal',
                        location: history['location'] ?? 'Lokasi Tidak Dikenal',
                        isActive: history['is_active'] == 1 || history['is_active'] == true,
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(color: Color(0xFFE5E7EB), height: 1)),
                    ],
                  );
                }),
                
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _logoutOtherDevices,
                    child: const Text(
                      'Keluar dari Semua Sesi Lainnya',
                      style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6D7A73), size: 20),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16, color: const Color(0xFF6D7A73))),
      ],
    );
  }

  Widget _buildPasswordField(ThemeData theme, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: const Color(0xFF3D4943))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: true, 
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: Colors.black38, letterSpacing: 2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.colorScheme.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({required ThemeData theme, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelSmall?.copyWith(fontSize: 13)),
              const SizedBox(height: 2),
              Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: const Color(0xFF6D7A73))),
            ],
          ),
        ),
        Switch(value: value, activeColor: theme.colorScheme.primary, onChanged: onChanged),
      ],
    );
  }

  Widget _buildDeviceHistoryItem({required ThemeData theme, required IconData icon, required String deviceName, required String location, required bool isActive}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Color(0xFFF2F4F8), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF6D7A73), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(deviceName, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
              const SizedBox(height: 2),
              Text(location, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: const Color(0xFF6D7A73))),
            ],
          ),
        ),
        if (isActive)
          Text('Saat\nIni', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold))
        else
          const Icon(Icons.more_vert, color: Color(0xFF6D7A73), size: 18),
      ],
    );
  }
}