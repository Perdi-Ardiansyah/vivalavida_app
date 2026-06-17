import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; 

import 'complete_profile_screen.dart';
import 'account_security_screen.dart';
import 'notification_settings_screen.dart';
import 'saved_addresses_screen.dart';
// TODO: Jangan lupa import halaman Login kamu di sini, contohnya:
// import 'login_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  bool isUploadingPhoto = false; 
  String errorMessage = '';
  
  String userName = '';
  String userEmail = '';
  int userPoints = 0;
  String profilePicUrl = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop'; 

  File? _imageFile; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // --- 1. AMBIL DATA PROFIL ---
  Future<void> fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

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
        final userData = data['data'] ?? data;

        setState(() {
          userName = userData['name'] ?? 'Pengguna';
          userEmail = userData['email'] ?? 'email@belumdiatur.com';
          userPoints = int.tryParse(userData['poin'].toString()) ?? 0;
          
          if (userData['foto_profil'] != null) {
            profilePicUrl = 'http://10.0.2.2:8000/storage/' + userData['foto_profil']; 
          }
          
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

  // --- 2. MUNCULKAN MENU PILIH FOTO ---
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 3. AMBIL FOTO & UPLOAD ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, 
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path); 
        });
        
        await _uploadProfilePicture(File(pickedFile.path));
      }
    } catch (e) {
      _showSnackBar('Gagal memilih foto: $e');
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    setState(() => isUploadingPhoto = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:8000/api/user/upload-photo'));
      
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      
      request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _showSnackBar('Foto profil berhasil diubah!', isSuccess: true);
        fetchUserProfile(); 
      } else {
        _showSnackBar('Gagal mengupload foto. Cek API Laravel-mu.');
      }
    } catch (e) {
      _showSnackBar('Error koneksi saat upload: $e');
    } finally {
      setState(() => isUploadingPhoto = false);
    }
  }

  // --- 4. FUNGSI LOGOUT ---
  Future<void> _logout() async {
    // 1. Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Aplikasi'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Tampilkan loading screen transparan
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      // 2. Beri tahu Laravel untuk menghapus token ini
      final url = Uri.parse('http://10.0.2.2:8000/api/logout');
      await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 3. Hapus token dari memori HP
      await prefs.remove('auth_token');

      if (!mounted) return;
      
      // Tutup loading dialog
      Navigator.pop(context);

      // 4. Tendang ke halaman Login dan hapus semua riwayat rute di belakangnya
      // GANTI 'LoginScreen()' DENGAN NAMA CLASS HALAMAN LOGIN MILIKMU!
      /* Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), 
        (Route<dynamic> route) => false,
      );
      */
      
      // Catatan sementara: Agar kodenya tidak error sebelum kamu mengimport LoginScreen,
      // saya arahkan kembali ke rute '/' (biasanya ini mengarah ke splash/login screen).
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      
    } catch (e) {
      Navigator.pop(context); // Tutup loading jika error
      _showSnackBar('Gagal memproses logout. Periksa koneksi Anda.');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
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
        title: Text(
          'Vivalavida Coffee',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontSize: 20,
          ),
        ),
        centerTitle: false, 
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center))
              : _buildProfileContent(theme, context),
    );
  }

  // --- KONTEN PROFIL ---
  Widget _buildProfileContent(ThemeData theme, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // FOTO PROFIL
          Center(
            child: GestureDetector(
              onTap: () => _showPicker(context),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider
                        : NetworkImage(profilePicUrl),
                    child: isUploadingPhoto 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : null,
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
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // NAMA & EMAIL
          Text(userName, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22, color: const Color(0xFF191C1F))),
          const SizedBox(height: 4),
          Text(userEmail, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73))),
          const SizedBox(height: 12),

          // BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE6F0EB), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: theme.colorScheme.primary, size: 14),
                const SizedBox(width: 6),
                Text(
                  userPoints >= 1000 ? 'Gold Member' : 'Silver Member',
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          OutlinedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
              );
              if (result == true) {
                fetchUserProfile();
              }
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFF705A4F)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Edit Profile', style: TextStyle(color: Color(0xFF3C2A21), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 32),

          Align(alignment: Alignment.centerLeft, child: Text('Account Settings', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18))),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(
              children: [
                _buildSettingsItem(theme: theme, icon: Icons.shield_outlined, title: 'Account Security', subtitle: 'Password, 2FA, and login history', onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSecurityScreen())); }),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                _buildSettingsItem(theme: theme, icon: Icons.notifications_none_outlined, title: 'Notification Settings', subtitle: 'Order updates and promotional offers', onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())); }),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                _buildSettingsItem(theme: theme, icon: Icons.location_on_outlined, title: 'Saved Addresses', subtitle: 'Home and Office locations', onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedAddressesScreen())); }),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- TOMBOL LOGOUT SEKARANG MEMANGGIL _logout() ---
          OutlinedButton.icon(
            onPressed: _logout, // <-- Fungsi dipanggil di sini
            icon: const Icon(Icons.logout, color: Color(0xFFBA1A1A), size: 20),
            label: const Text('Logout of all devices', style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: const Color(0xFFFFDAD6).withOpacity(0.3), 
              side: const BorderSide(color: Color(0xFFFFDAD6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({required ThemeData theme, required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: Color(0xFFF2F4F8), shape: BoxShape.circle),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
      subtitle: Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: const Color(0xFF6D7A73))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF6D7A73)),
      onTap: onTap, 
    );
  }
}