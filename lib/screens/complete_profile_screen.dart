import 'package:flutter/material.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

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
          'Lengkapi Profil',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF6D7A73), // Mengikuti warna teks di desain
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      // Konten Formulir bisa di-scroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. KARTU PROGRES (65%) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary, // Forest Green
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'STATUS KELENGKAPAN',
                            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '65% Selesai',
                            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 22),
                          ),
                        ],
                      ),
                      const Icon(Icons.verified, color: Colors.white, size: 36),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.65, // 65%
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF86F8C9)), // primary-fixed color
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dapatkan Poin Sobat & keuntungan ulang tahun dengan melengkapi profil',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. DATA PRIBADI ---
            _buildSectionTitle(theme, Icons.person_outline, 'DATA PRIBADI'),
            const SizedBox(height: 16),
            _buildInputLabel(theme, 'Nama Lengkap'),
            _buildTextField(hint: 'Contoh: Budi Santoso'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel(theme, 'Tanggal Lahir'),
                      _buildTextField(hint: 'dd/mm/tttt', trailingIcon: Icons.calendar_month_outlined),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel(theme, 'Jenis Kelamin'),
                      // Dropdown buatan untuk meniru desain
                      _buildTextField(hint: 'Pilih', trailingIcon: Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 3. INFORMASI KONTAK ---
            _buildSectionTitle(theme, Icons.contact_mail_outlined, 'INFORMASI KONTAK'),
            const SizedBox(height: 16),
            _buildInputLabel(theme, 'Email'),
            _buildTextField(hint: 'budi.s@email.com', trailingIcon: Icons.check_circle, iconColor: theme.colorScheme.primary),
            const SizedBox(height: 16),
            _buildInputLabel(theme, 'Nomor Telepon'),
            Row(
              children: [
                // Kotak +62
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E2E6), // surface-variant
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Text('+62', style: TextStyle(color: Color(0xFF3D4943), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(hint: '812 3456 7890', keyboardType: TextInputType.phone),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInputLabel(theme, 'Instagram'),
            _buildTextField(hint: 'Contoh: @username', trailingText: '@'),
            const SizedBox(height: 32),

            // --- 4. PREFERENSI ---
            _buildSectionTitle(theme, Icons.favorite_border, 'PREFERENSI'),
            const SizedBox(height: 16),
            _buildInputLabel(theme, 'Tipe Kopi Favorit'),
            // Widget Wrap agar chips otomatis turun ke baris bawah jika tidak muat
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildChoiceChip(theme, 'Espresso'),
                _buildChoiceChip(theme, 'Arabica Blend'),
                _buildChoiceChip(theme, 'Robusta'),
                _buildChoiceChip(theme, 'Milk-based'),
              ],
            ),
            const SizedBox(height: 40), 
          ],
        ),
      ),
      // --- 5. TOMBOL SIMPAN (Sticky di bawah) ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: () {},
            iconAlignment: IconAlignment.end, // Memindahkan ikon ke kanan (membutuhkan Flutter 3.22+)
            icon: const Icon(Icons.save_outlined, size: 20),
            label: const Text('Simpan Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56), // Tombol penuh
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS --- 
  // Memisahkan widget kecil agar kode utama tidak terlalu panjang

  Widget _buildSectionTitle(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildInputLabel(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: const Color(0xFF3D4943)),
      ),
    );
  }

  Widget _buildTextField({
    required String hint, 
    IconData? trailingIcon, 
    String? trailingText,
    Color? iconColor,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: trailingIcon != null 
            ? Icon(trailingIcon, color: iconColor ?? Colors.black54, size: 20)
            : trailingText != null
                ? Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(trailingText, style: const TextStyle(color: Colors.black38, fontSize: 16)),
                  )
                : null,
      ),
    );
  }

  Widget _buildChoiceChip(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Text(
        label,
        style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}