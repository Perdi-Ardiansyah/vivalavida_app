import 'package:flutter/material.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  // State untuk Toggle Switches
  bool isAuthenticatorEnabled = true;
  bool isNewLoginAlertEnabled = true;
  bool isSecurityRecommendationEnabled = false;

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
          'Keamanan Akun',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF6D7A73),
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100&auto=format&fit=crop'),
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1497935586351-b67a49e012bf?q=80&w=600&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Lindungi Akun Anda',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola keamanan dan akses login\nAnda.',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4),
                    ),
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
                _buildPasswordField(theme, 'Kata Sandi Saat Ini'),
                const SizedBox(height: 12),
                _buildPasswordField(theme, 'Kata Sandi Baru'),
                const SizedBox(height: 12),
                _buildPasswordField(theme, 'Konfirmasi Kata Sandi Baru'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F0EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Aktif', style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
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
                          Text('Terakhir disinkronkan 2 hari\nyang lalu', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: const Color(0xFF6D7A73))),
                        ],
                      ),
                    ),
                    Switch(
                      value: isAuthenticatorEnabled,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) => setState(() => isAuthenticatorEnabled = val),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: Color(0xFFBCCAC1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Konfigurasi Ulang Aplikasi', style: TextStyle(color: Color(0xFF3D4943), fontWeight: FontWeight.bold)),
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: Color(0xFFE5E7EB), height: 1),
                ),
                _buildSwitchRow(
                  theme: theme,
                  title: 'Rekomendasi Keamanan',
                  subtitle: 'Saran mingguan untuk memperkuat akun\nAnda.',
                  value: isSecurityRecommendationEnabled,
                  onChanged: (val) => setState(() => isSecurityRecommendationEnabled = val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 5. RIWAYAT SESI LOGIN ---
            _buildSectionCard(
              children: [
                _buildSectionHeader(theme, Icons.history, 'Riwayat Sesi Login'),
                const SizedBox(height: 16),
                _buildDeviceHistoryItem(
                  theme: theme,
                  icon: Icons.laptop_mac,
                  deviceName: 'MacBook Pro 14"',
                  location: 'Jakarta, Indonesia • Aktif\nSekarang',
                  isActive: true,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(color: Color(0xFFE5E7EB), height: 1)),
                _buildDeviceHistoryItem(
                  theme: theme,
                  icon: Icons.phone_iphone,
                  deviceName: 'iPhone 15 Pro',
                  location: 'Bandung, Indonesia • 12 Okt, 18:30',
                  isActive: false,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(color: Color(0xFFE5E7EB), height: 1)),
                _buildDeviceHistoryItem(
                  theme: theme,
                  icon: Icons.tablet_mac,
                  deviceName: 'Samsung Tab S9',
                  location: 'Yogyakarta, Indonesia • 08 Okt,\n09:15',
                  isActive: false,
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {},
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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

  Widget _buildPasswordField(ThemeData theme, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: const Color(0xFF3D4943))),
        const SizedBox(height: 6),
        TextField(
          obscureText: true, // Menyembunyikan teks sandi
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: Colors.black38, letterSpacing: 2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
        Switch(
          value: value,
          activeColor: theme.colorScheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDeviceHistoryItem({
    required ThemeData theme,
    required IconData icon,
    required String deviceName,
    required String location,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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