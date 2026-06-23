import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: Pastikan mengimpor halaman utama/home kamu setelah berhasil login
// import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // State variables
  bool _isAgreed = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // Untuk animasi loading di tombol

  // Controllers untuk mengambil input dari pengguna
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- FUNGSI DAFTAR KE LARAVEL ---
  Future<void> _register() async {
    // 1. Validasi Input Dasar
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Nama, Email, dan Kata Sandi wajib diisi!');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Konfirmasi kata sandi tidak cocok!');
      return;
    }
    if (_passwordController.text.length < 8) {
      _showSnackBar('Kata sandi minimal 8 karakter!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('https://vivalavidacoffeshop.rf.gd/api/register');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text, // Standar validasi Laravel
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Jika sukses, simpan token ke memori HP
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['token'] ?? responseData['access_token']);

        _showSnackBar('Pendaftaran berhasil!', isSuccess: true);
        
        if (!mounted) return;
        
        // Pindah ke Halaman Home dan hapus riwayat kembali
        // GANTI '/home' DENGAN RUTE HALAMAN UTAMAMU!
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        
      } else {
        // Tampilkan pesan error dari Laravel (misal: Email sudah terdaftar)
        String errorMsg = 'Pendaftaran gagal.';
        if (responseData['errors'] != null) {
          // Mengambil pesan error pertama dari validasi Laravel
          errorMsg = responseData['errors'].values.first[0];
        } else if (responseData['message'] != null) {
          errorMsg = responseData['message'];
        }
        _showSnackBar(errorMsg);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan jaringan. Cek koneksi Anda.');
    } finally {
      setState(() => _isLoading = false);
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
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- 1. HEADER ---
                  Text(
                    'Vivalavida',
                    style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Buat Akun Baru', style: theme.textTheme.headlineMedium?.copyWith(color: const Color(0xFF191C1F), fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(
                    'Bergabunglah untuk menikmati pengalaman kopi premium kami.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73), fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // --- 2. INPUT FIELDS ---
                  _buildLabel(theme, 'Nama Lengkap'),
                  _buildTextField(hint: 'Masukkan nama lengkap Anda', icon: Icons.person_outline, controller: _nameController),
                  
                  const SizedBox(height: 16),
                  _buildLabel(theme, 'Email'),
                  _buildTextField(hint: 'contoh@email.com', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress, controller: _emailController),
                  
                  const SizedBox(height: 16),
                  _buildLabel(theme, 'Nomor WhatsApp'),
                  _buildTextField(hint: '081234567890', icon: Icons.phone_iphone_outlined, keyboardType: TextInputType.phone, controller: _phoneController),
                  
                  const SizedBox(height: 16),
                  _buildLabel(theme, 'Kata Sandi'),
                  _buildPasswordField(
                    hint: 'Minimal 8 karakter', 
                    obscure: _obscurePassword,
                    controller: _passwordController,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  
                  const SizedBox(height: 16),
                  _buildLabel(theme, 'Konfirmasi Kata Sandi'),
                  _buildPasswordField(
                    hint: 'Ulangi kata sandi Anda', 
                    obscure: _obscureConfirmPassword,
                    controller: _confirmPasswordController,
                    onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),

                  const SizedBox(height: 16),

                  // --- 3. CHECKBOX PERSETUJUAN ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24, width: 24,
                        child: Checkbox(
                          value: _isAgreed,
                          activeColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => setState(() => _isAgreed = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Color(0xFF6D7A73), fontSize: 12, height: 1.4),
                            children: [
                              const TextSpan(text: 'Saya setuju dengan '),
                              TextSpan(text: 'Syarat & Ketentuan', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' serta '),
                              TextSpan(text: 'Kebijakan Privasi', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' Vivalavida Coffee.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- 4. TOMBOL DAFTAR ---
                  ElevatedButton(
                    onPressed: _isAgreed && !_isLoading ? _register : null, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Daftar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 24),

                  // --- 5. FOOTER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? ', style: TextStyle(color: Color(0xFF6D7A73), fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), 
                        child: Text('Masuk di sini', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildLabel(ThemeData theme, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3D4943))),
      ),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, TextInputType? keyboardType, required TextEditingController controller}) {
    return TextField(
      controller: controller, // Controller ditambahkan di sini
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black38, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }

  Widget _buildPasswordField({required String hint, required bool obscure, required VoidCallback onToggle, required TextEditingController controller}) {
    return TextField(
      controller: controller, // Controller ditambahkan di sini
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14, letterSpacing: 0),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black38, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black38, size: 20),
          onPressed: onToggle,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }
}