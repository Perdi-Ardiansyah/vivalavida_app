import 'package:flutter/material.dart';

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
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- 1. HEADER ---
                  Text(
                    'Vivalavida',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat Akun Baru',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF191C1F),
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bergabunglah untuk menikmati pengalaman kopi premium kami.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6D7A73),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- 2. INPUT FIELDS ---
                  _buildLabel(theme, 'Nama Lengkap'),
                  _buildTextField(hint: 'Masukkan nama lengkap Anda', icon: Icons.person_outline),
                  
                  const SizedBox(height: 16),
                  _buildLabel(theme, 'Email'),
                  _buildTextField(hint: 'contoh@email.com', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
                  
                  const SizedBox(height: 16),
                  _buildLabel(theme, 'Nomor WhatsApp'),
                  _buildTextField(hint: '081234567890', icon: Icons.phone_iphone_outlined, keyboardType: TextInputType.phone),
                  
                  const SizedBox(height: 16),
                  _buildLabel(theme, 'Kata Sandi'),
                  _buildPasswordField(
                    hint: 'Minimal 8 karakter', 
                    obscure: _obscurePassword,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  
                  const SizedBox(height: 16),
                  _buildLabel(theme, 'Konfirmasi Kata Sandi'),
                  _buildPasswordField(
                    hint: 'Ulangi kata sandi Anda', 
                    obscure: _obscureConfirmPassword,
                    onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),

                  const SizedBox(height: 16),

                  // --- 3. CHECKBOX PERSETUJUAN ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
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
                              TextSpan(
                                text: 'Syarat & Ketentuan',
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' serta '),
                              TextSpan(
                                text: 'Kebijakan Privasi',
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
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
                    onPressed: _isAgreed ? () {} : null, // Tombol mati jika belum centang
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 5. FOOTER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: Color(0xFF6D7A73), fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // Kembali ke Login
                        child: Text(
                          'Masuk di sini',
                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
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

  Widget _buildTextField({required String hint, required IconData icon, TextInputType? keyboardType}) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black38, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPasswordField({required String hint, required bool obscure, required VoidCallback onToggle}) {
    return TextField(
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
      ),
    );
  }
}