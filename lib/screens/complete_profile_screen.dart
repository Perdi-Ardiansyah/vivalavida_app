import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  bool isLoading = true;
  bool isSaving = false;

  // Controllers untuk text input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _igController = TextEditingController();

  // State untuk dropdown dan chip
  String? _selectedGender;
  List<String> _selectedCoffees = [];

  // Daftar opsi kopi
  final List<String> coffeeOptions = ['Espresso', 'Arabica Blend', 'Robusta', 'Milk-based'];

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _igController.dispose();
    super.dispose();
  }

  // --- 1. AMBIL DATA PROFIL ---
  Future<void> fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/user');
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data'] ?? data;

        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          
          // Asumsi data ini ada di database, jika belum ada biarkan kosong
          _dobController.text = userData['tanggal_lahir'] ?? '';
          _igController.text = userData['instagram'] ?? '';
          _selectedGender = userData['jenis_kelamin'];
          
          // Contoh menangani tipe kopi dari database (misal disimpan sebagai string dipisah koma)
          if (userData['kopi_favorit'] != null) {
            _selectedCoffees = userData['kopi_favorit'].split(',').map((e) => e.toString().trim()).toList();
          }
          
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showSnackBar('Gagal memuat data profil.');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Terjadi kesalahan jaringan.');
    }
  }

  // --- 2. SIMPAN DATA PROFIL ---
  Future<void> saveUserProfile() async {
    setState(() => isSaving = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      // CATATAN: Pastikan Anda membuat rute PUT /api/user/profile di file api.php Laravel
      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/user/profile');
      
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'tanggal_lahir': _dobController.text,
          'jenis_kelamin': _selectedGender,
          'instagram': _igController.text,
          'kopi_favorit': _selectedCoffees.join(', '),
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Profil berhasil diperbarui!', isSuccess: true);
        Navigator.pop(context, true); // Kembali dan bawa nilai true (berhasil)
      } else {
        _showSnackBar('Gagal menyimpan profil. Cek rute API Laravel-mu.');
      }
    } catch (e) {
      _showSnackBar('Error: Koneksi ke server gagal.');
    } finally {
      setState(() => isSaving = false);
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

  // Helper Toggle Pilihan Kopi
  void _toggleCoffeeSelection(String coffee) {
    setState(() {
      if (_selectedCoffees.contains(coffee)) {
        _selectedCoffees.remove(coffee);
      } else {
        _selectedCoffees.add(coffee);
      }
    });
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
        title: Text(
          'Lengkapi Profil',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF6D7A73),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. KARTU PROGRES (DINAMIS - Contoh 80%) ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
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
                                  '80% Selesai',
                                  style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 22),
                                ),
                              ],
                            ),
                            const Icon(Icons.verified, color: Colors.white, size: 36),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.80, 
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF86F8C9)),
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
                  _buildTextField(controller: _nameController, hint: 'Contoh: Budi Santoso'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel(theme, 'Tanggal Lahir'),
                            _buildTextField(controller: _dobController, hint: 'dd/mm/tttt', trailingIcon: Icons.calendar_month_outlined),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel(theme, 'Jenis Kelamin'),
                            _buildDropdownField(theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- 3. INFORMASI KONTAK ---
                  _buildSectionTitle(theme, Icons.contact_mail_outlined, 'INFORMASI KONTAK'),
                  const SizedBox(height: 16),
                  _buildInputLabel(theme, 'Email (Tidak bisa diubah)'),
                  _buildTextField(controller: _emailController, hint: 'budi.s@email.com', trailingIcon: Icons.check_circle, iconColor: theme.colorScheme.primary, readOnly: true),
                  const SizedBox(height: 16),
                  _buildInputLabel(theme, 'Nomor Telepon'),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E2E6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Text('+62', style: TextStyle(color: Color(0xFF3D4943), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(controller: _phoneController, hint: '812 3456 7890', keyboardType: TextInputType.phone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInputLabel(theme, 'Instagram'),
                  _buildTextField(controller: _igController, hint: 'Contoh: username', trailingText: '@'),
                  const SizedBox(height: 32),

                  // --- 4. PREFERENSI KOPI FAVORIT ---
                  _buildSectionTitle(theme, Icons.favorite_border, 'PREFERENSI'),
                  const SizedBox(height: 16),
                  _buildInputLabel(theme, 'Tipe Kopi Favorit'),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: coffeeOptions.map((coffee) {
                      final isSelected = _selectedCoffees.contains(coffee);
                      return _buildChoiceChip(theme, coffee, isSelected);
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      // --- 5. TOMBOL SIMPAN ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : saveUserProfile,
            iconAlignment: IconAlignment.end,
            icon: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_outlined, size: 20),
            label: Text(isSaving ? 'Menyimpan...' : 'Simpan Profil', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS --- 

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
    required TextEditingController controller,
    required String hint, 
    IconData? trailingIcon, 
    String? trailingText,
    Color? iconColor,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(color: readOnly ? Colors.grey[700] : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: readOnly,
        fillColor: readOnly ? const Color(0xFFF2F4F8) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: readOnly ? Colors.transparent : const Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: readOnly ? Colors.transparent : const Color(0xFFE5E7EB)),
        ),
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

  Widget _buildDropdownField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          hint: const Text('Pilih', style: TextStyle(color: Colors.black38, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: <String>['Laki-laki', 'Perempuan'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildChoiceChip(ThemeData theme, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleCoffeeSelection(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.primary, 
            fontSize: 12, 
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}