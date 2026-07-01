import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  bool isLoading = true;
  List<dynamic> addresses = [];

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  // --- 1. AMBIL DAFTAR ALAMAT DARI API ---
  Future<void> _fetchAddresses() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/user/addresses');
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          addresses = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Terjadi kesalahan jaringan.');
    }
  }

  // --- 2. HAPUS ALAMAT ---
  Future<void> _deleteAddress(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavida.kotapintar.my.id/api/user/addresses/$id');
      final response = await http.delete(
        url,
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _showSnackBar('Alamat berhasil dihapus', isSuccess: true);
        _fetchAddresses(); 
      } else {
        _showSnackBar('Gagal menghapus alamat');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan jaringan.');
    }
  }

  // --- 3. FORM TAMBAH / EDIT ALAMAT (BOTTOM SHEET) ---
  void _showAddressForm({Map<String, dynamic>? addressToEdit}) {
    final isEditing = addressToEdit != null;
    
    // NAMA VARIABEL SUDAH DISESUAIKAN DENGAN DATABASE-MU
    final labelController = TextEditingController(text: isEditing ? addressToEdit['label_alamat'] : '');
    final alamatLengkapController = TextEditingController(text: isEditing ? addressToEdit['alamat_lengkap'] : '');
    final catatanController = TextEditingController(text: isEditing ? addressToEdit['catatan_kurir'] : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Alamat' : 'Tambah Alamat Baru',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18, color: const Color(0xFF3D4943)),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputField('Label (Contoh: Rumah, Kantor)', labelController),
                _buildInputField('Alamat Lengkap', alamatLengkapController, maxLines: 3),
                _buildInputField('Catatan untuk Kurir (Opsional)', catatanController),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (labelController.text.isEmpty || alamatLengkapController.text.isEmpty) {
                      _showSnackBar('Label dan Alamat Lengkap wajib diisi!');
                      return;
                    }

                    Navigator.pop(context); // Tutup form
                    _saveAddress(
                      id: isEditing ? addressToEdit['id'] : null,
                      data: {
                        'label_alamat': labelController.text, 
                        'alamat_lengkap': alamatLengkapController.text,
                        'catatan_kurir': catatanController.text, 
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEditing ? 'Simpan Perubahan' : 'Simpan Alamat', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 4. KIRIM DATA ALAMAT KE SERVER ---
  Future<void> _saveAddress({int? id, required Map<String, dynamic> data}) async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = id == null 
          ? Uri.parse('https://vivalavida.kotapintar.my.id/api/user/addresses')
          : Uri.parse('https://vivalavida.kotapintar.my.id/api/user/addresses/$id');

      final response = id == null 
          ? await http.post(url, headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: json.encode(data))
          : await http.put(url, headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: json.encode(data));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(id == null ? 'Alamat berhasil ditambahkan' : 'Alamat berhasil diperbarui', isSuccess: true);
        _fetchAddresses(); 
      } else {
        setState(() => isLoading = false);
        _showSnackBar('Gagal menyimpan alamat.');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Terjadi kesalahan jaringan.');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isSuccess ? Colors.green : Colors.red, behavior: SnackBarBehavior.floating),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Addresses',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary, 
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF6D7A73)),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage your delivery locations for faster checkouts and hot brews.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF3D4943),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            if (addresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Belum ada alamat tersimpan', style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF6D7A73))),
                    ],
                  ),
                ),
              )
            else
              ...addresses.map((address) {
                // Menentukan ikon berdasarkan label alamat (SUDAH DIUBAH KE label_alamat)
                IconData cardIcon = Icons.apartment_outlined;
                final labelStr = address['label_alamat']?.toString().toLowerCase() ?? '';
                if (labelStr.contains('rumah')) cardIcon = Icons.home_outlined;
                if (labelStr.contains('kantor')) cardIcon = Icons.work_outline;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildAddressCard(
                    theme: theme,
                    icon: cardIcon,
                    addressData: address, 
                  ),
                );
              }),
            
            const SizedBox(height: 8),

            InkWell(
              onTap: () => _showAddressForm(), 
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFF6D7A73), size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'Pin more locations on the map',
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddressForm(), 
            icon: const Icon(Icons.add_location_alt_outlined, size: 20),
            label: const Text(
              'Tambah Alamat Baru',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildAddressCard({
    required ThemeData theme,
    required IconData icon,
    required Map<String, dynamic> addressData,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F0EB), 
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                // SUDAH DIUBAH KE label_alamat
                child: Text(addressData['label_alamat'] ?? 'Alamat', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            addressData['alamat_lengkap'] ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF3D4943),
              height: 1.5,
              fontSize: 13,
            ),
          ),
          
          // SUDAH DIUBAH KE catatan_kurir
          if (addressData['catatan_kurir'] != null && addressData['catatan_kurir'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
              child: Text('Catatan: ${addressData['catatan_kurir']}', style: const TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic)),
            ),
          ],
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              InkWell(
                onTap: () => _showAddressForm(addressToEdit: addressData),
                child: Text('Ubah', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('|', style: TextStyle(color: Color(0xFFE5E7EB), fontSize: 13)),
              ),
              InkWell(
                onTap: () {
                   showDialog(
                     context: context,
                     builder: (ctx) => AlertDialog(
                       title: const Text('Hapus Alamat?'),
                       content: const Text('Alamat ini akan dihapus permanen.'),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                         TextButton(
                           onPressed: () {
                             Navigator.pop(ctx);
                             _deleteAddress(addressData['id']);
                           }, 
                           child: const Text('Hapus', style: TextStyle(color: Colors.red))
                         ),
                       ],
                     )
                   );
                },
                child: const Text('Hapus', style: TextStyle(color: Color(0xFFBA1A1A), fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isPhone = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A73), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: Colors.grey[50],
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF4C735B))),
            ),
          ),
        ],
      ),
    );
  }
}