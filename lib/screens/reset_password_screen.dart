import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // State untuk visibilitas kata sandi
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // State untuk indikator (bisa dibuat dinamis nanti saat dihubungkan dengan controller)
  final bool _hasMinLength = true; // Skenario sudah memenuhi 8 karakter
  final bool _hasSymbolOrNumber = false; // Skenario belum ada simbol/angka

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
                    // --- 1. LOGO TEKS DI TENGAH ---
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

                    // --- 2. JUDUL & DESKRIPSI ---
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

                    // --- 3. INPUT KATA SANDI BARU ---
                    _buildLabel(theme, 'Kata Sandi Baru'),
                    _buildPasswordField(
                      theme: theme,
                      hint: 'Masukkan kata sandi baru',
                      obscure: _obscureNewPassword,
                      onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    ),
                    const SizedBox(height: 20),

                    // --- 4. INPUT KONFIRMASI KATA SANDI ---
                    _buildLabel(theme, 'Konfirmasi Kata Sandi Baru'),
                    _buildPasswordField(
                      theme: theme,
                      hint: 'Ulangi kata sandi baru',
                      obscure: _obscureConfirmPassword,
                      onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    const SizedBox(height: 16),

                    // --- 5. INDIKATOR SYARAT KATA SANDI ---
                    Row(
                      children: [
                        _buildRequirementChip(
                          theme: theme,
                          text: 'MIN. 8 KARAKTER',
                          isMet: _hasMinLength,
                        ),
                        const SizedBox(width: 8),
                        _buildRequirementChip(
                          theme: theme,
                          text: 'SIMBOL & ANGKA',
                          isMet: _hasSymbolOrNumber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // --- 6. TOMBOL SIMPAN ---
                    ElevatedButton(
                      onPressed: () {
                        // Aksi simpan kata sandi baru
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Kata sandi berhasil diubah!'),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        );
                        // Kembali ke halaman Login dengan menghapus tumpukan history
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Simpan Kata Sandi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- 7. TOMBOL KEMBALI ---
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF6D7A73), size: 18),
                        label: const Text(
                          'Kembali ke Keamanan', // Teks ini bisa disesuaikan apakah kembali ke Keamanan atau Login
                          style: TextStyle(color: Color(0xFF6D7A73), fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // --- 8. FOOTER COPYRIGHT ---
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

  // --- HELPER WIDGETS ---

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
    required ThemeData theme,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.black54,
            size: 20,
          ),
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

  // Widget untuk membuat Chip Indikator Syarat Kata Sandi
  Widget _buildRequirementChip({
    required ThemeData theme,
    required String text,
    required bool isMet,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMet ? const Color(0xFFE6F0EB) : const Color(0xFFF2F4F8), // Hijau pudar vs Abu-abu pudar
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