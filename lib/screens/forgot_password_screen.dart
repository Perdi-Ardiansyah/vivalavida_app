import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_verification_screen.dart';
import '../services/api_config.dart'; // Sesuaikan titik-titik jika letak foldernya berbeda
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- FUNGSI MENGIRIM PERMINTAAN OTP KE LARAVEL ---
  // --- FUNGSI MENGIRIM PERMINTAAN OTP KE LARAVEL ---
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Mohon masukkan alamat email Anda.', isError: true);
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      _showSnackBar('Format email tidak valid.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // SILAKAN SESUAIKAN: Ganti 'Config.baseUrl' dengan nama class konfigurasi asli di proyekmu
      // Contoh: ApiConfig.baseUrl atau AppConfig.url
      final url = Uri.parse('${ApiConfig.baseUrl}/forgot-password/send-otp');
      
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {'email': email},
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showSnackBar(data['message'] ?? 'OTP berhasil dikirim!', isError: false);
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(email: email),
            ),
          );
        }
      } else {
        final data = json.decode(response.body);
        _showSnackBar(data['message'] ?? 'Email tidak ditemukan.', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal terhubung ke server. Periksa koneksi internet Anda.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 1. LOGO ICON ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B2E), 
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco, 
                      color: Color(0xFF705A4F), 
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- 2. JUDUL & DESKRIPSI ---
                Text(
                  'Lupa Kata Sandi?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF191C1F),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Masukkan email terdaftar Anda untuk\nmenerima instruksi pengaturan ulang.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6D7A73),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // --- 3. INPUT EMAIL ---
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading, // Kunci input saat loading
                  decoration: InputDecoration(
                    hintText: 'Alamat Email',
                    hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                    prefixIcon: const Icon(Icons.mail_outline, color: Colors.black54, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- 4. TOMBOL KIRIM INSTRUKSI ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.5),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kirim Instruksi OTP',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.send, color: Colors.white, size: 18),
                        ],
                      ),
                ),
                const SizedBox(height: 40),

                // --- 5. KEMBALI KE LOGIN ---
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Kembali ke Login',
                    style: TextStyle(
                      color: _isLoading ? Colors.grey : theme.colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}