import 'package:flutter/material.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

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
            color: theme.colorScheme.primary, // Warna hijau utama
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF6D7A73)),
            onPressed: () {
              // Aksi pencarian alamat
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. TEKS DESKRIPSI ---
            Text(
              'Manage your delivery locations for faster checkouts and hot brews.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF3D4943),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. DAFTAR ALAMAT TERSIMPAN ---
            _buildAddressCard(
              theme: theme,
              icon: Icons.home_outlined,
              title: 'Rumah',
              address: 'Jl. Senopati No. 45, Kebayoran Baru, Jakarta Selatan, 12190',
            ),
            const SizedBox(height: 16),
            
            _buildAddressCard(
              theme: theme,
              icon: Icons.work_outline,
              title: 'Kantor',
              address: 'Sudirman Central Business District (SCBD), Treasury Tower Lt. 18, Jakarta Selatan',
            ),
            const SizedBox(height: 16),
            
            _buildAddressCard(
              theme: theme,
              icon: Icons.apartment_outlined,
              title: 'Apartemen',
              address: 'Taman Anggrek Residences, Tower B, Unit 22C, Jakarta Barat',
            ),
            const SizedBox(height: 24),

            // --- 3. TOMBOL PIN LOKASI BARU ---
            // Menggunakan border solid abu-abu terang sebagai alternatif dashed border
            InkWell(
              onTap: () {
                // Aksi membuka peta
              },
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
      
      // --- 4. TOMBOL TAMBAH ALAMAT BAWAH ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // Aksi tambah alamat baru secara manual
            },
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
    required String title,
    required String address,
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
          // Header (Ikon, Judul, Tombol Opsi)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F0EB), // Hijau sangat pudar
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16)),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: Color(0xFF6D7A73)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Alamat Lengkap
          Text(
            address,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF3D4943),
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          
          // Tombol Aksi (Ubah & Hapus)
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Text('Ubah', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('|', style: TextStyle(color: Color(0xFFE5E7EB), fontSize: 13)),
              ),
              InkWell(
                onTap: () {},
                child: const Text('Hapus', style: TextStyle(color: Color(0xFFBA1A1A), fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}