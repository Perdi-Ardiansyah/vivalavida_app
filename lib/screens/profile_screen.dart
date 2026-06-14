import 'package:flutter/material.dart';
import 'complete_profile_screen.dart';
import 'account_security_screen.dart'; // Import halaman edit profil
import 'notification_settings_screen.dart';
import 'saved_addresses_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          'Vivalavida Coffee',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontSize: 20,
          ),
        ),
        centerTitle: false, // Rata kiri sesuai desain
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- 1. FOTO PROFIL & IKON EDIT ---
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 46,
                    // Menggunakan gambar placeholder profesional
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. NAMA & EMAIL ---
            Text(
              'Perdi Ardiansyah',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                color: const Color(0xFF191C1F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'perdi.ardiansyah@example.com',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6D7A73),
              ),
            ),
            const SizedBox(height: 12),

            // --- 3. BADGE GOLD MEMBER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0EB), // Hijau sangat pudar
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: theme.colorScheme.primary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Gold Member',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 4. TOMBOL EDIT PROFILE ---
            OutlinedButton(
              onPressed: () {
                // Navigasi ke halaman form profil
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompleteProfileScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(
                  color: Color(0xFF705A4F),
                ), // Warna coklat sekunder
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Color(0xFF3C2A21),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- 5. PENGATURAN AKUN (ACCOUNT SETTINGS) ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Settings',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),

            // Membuat kotak besar berisi list pengaturan
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    theme: theme,
                    icon: Icons.shield_outlined,
                    title: 'Account Security',
                    subtitle: 'Password, 2FA, and login history',
                    // TAMBAHKAN BARIS ONTAP INI:
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSecurityScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE5E7EB),
                  ), // Garis pemisah
                  _buildSettingsItem(
                    theme: theme,
                    icon: Icons.notifications_none_outlined,
                    title: 'Notification Settings',
                    subtitle: 'Order updates and promotional offers',
                    // TAMBAHKAN BAGIAN INI:
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  _buildSettingsItem(
                    theme: theme,
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: 'Home and Office locations',
                    // TAMBAHKAN BAGIAN INI:
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedAddressesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 6. TOMBOL LOGOUT ---
            OutlinedButton.icon(
              onPressed: () {
                // Logika untuk logout
              },
              icon: const Icon(
                Icons.logout,
                color: Color(0xFFBA1A1A),
                size: 20,
              ), // Warna merah error
              label: const Text(
                'Logout of all devices',
                style: TextStyle(
                  color: Color(0xFFBA1A1A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: const Color(
                  0xFFFFDAD6,
                ).withOpacity(0.3), // Latar merah sangat transparan
                side: const BorderSide(
                  color: Color(0xFFFFDAD6),
                ), // Outline merah muda
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  // Membuat item list untuk di dalam kotak pengaturan
  Widget _buildSettingsItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap, // <--- 1. Tambahkan parameter ini di sini
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F4F8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 12,
          color: const Color(0xFF6D7A73),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF6D7A73)),
      onTap: onTap, // <--- 2. Pasang parameter tersebut di sini
    );
  }
}
