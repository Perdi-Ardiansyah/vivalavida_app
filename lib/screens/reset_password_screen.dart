import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_config.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  bool _hasMinLength = false; 
  bool _hasSymbolOrNumber = false; 

  @override
  void initState() {
    super.initState();
    // Memantau setiap ketikan untuk meng-update indikator Chip secara real-time!
    _passwordController.addListener(() {
      final text = _passwordController.text;
      setState(() {
        _hasMinLength = text.length >= 8;
        _hasSymbolOrNumber = RegExp(r'[0-9!@#\$&*~.]').hasMatch(text);
      });
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- FUNGSI MENGUBAH PASSWORD DI LARAVEL ---
  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (!_hasMinLength || !_hasSymbolOrNumber) {
      _showSnackBar('Harap penuhi syarat keamanan kata sandi.', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Konfirmasi kata sandi tidak cocok.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/forgot-password/reset-password');
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'email': widget.email,
          'password': password,
          'password_confirmation': confirmPassword, 
        },
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _showSnackBar('Kata sandi berhasil diubah! Silakan login.', isError: false);
        if (mounted) {
          // Kembali ke halaman Login paling depan
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        final data = json.decode(response.body);
        _showSnackBar(data['message'] ?? 'Gagal memperbarui kata sandi.', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal terhubung ke server.', isError: true);
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'VIVALAVIDA COFFEE',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 3,
                            width: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    Text(
                      'Ganti Kata Sandi',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF191C1F),
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Silakan masukkan kata sandi baru Anda untuk\nmengamankan akun.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6D7A73),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildLabel(theme, 'Kata Sandi Baru'),
                    _buildPasswordField(
                      controller: _passwordController,
                      theme: theme,
                      hint: 'Masukkan kata sandi baru',
                      obscure: _obscureNewPassword,
                      onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel(theme, 'Konfirmasi Kata Sandi Baru'),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      theme: theme,
                      hint: 'Ulangi kata sandi baru',
                      obscure: _obscureConfirmPassword,
                      onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _buildRequirementChip(theme: theme, text: 'MIN. 8 KARAKTER', isMet: _hasMinLength),
                        const SizedBox(width: 8),
                        _buildRequirementChip(theme: theme, text: 'SIMBOL & ANGKA', isMet: _hasSymbolOrNumber),
                      ],
                    ),
                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                      ),
                      child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'Simpan Kata Sandi',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                    ),
                    const SizedBox(height: 32),

                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF6D7A73), size: 18),
                        label: const Text(
                          'Kembali ke Login',
                          style: TextStyle(color: Color(0xFF6D7A73), fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                '© 2024 Vivalavida Coffee Admin Dashboard',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6D7A73),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(fontSize: 12, color: const Color(0xFF3D4943)),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required ThemeData theme,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: !_isLoading,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black54, size: 20),
          onPressed: onToggle,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildRequirementChip({required ThemeData theme, required String text, required bool isMet}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMet ? const Color(0xFFE6F0EB) : const Color(0xFFF2F4F8), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? theme.colorScheme.primary : const Color(0xFF9CA3AF),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: isMet ? theme.colorScheme.primary : const Color(0xFF6D7A73),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}