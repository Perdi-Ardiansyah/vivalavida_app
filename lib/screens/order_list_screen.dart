import 'package:flutter/material.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2, // Jumlah tab
      child: Scaffold(
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
            'Daftar Pesanan',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          // --- TAB BAR CONFIGURATION ---
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: const Color(0xFF6D7A73),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: 'Pesanan Aktif'),
              Tab(text: 'Riwayat Pesanan'),
            ],
          ),
        ),
        
        // --- ISI DARI TAB ---
        body: TabBarView(
          children: [
            // Konten Tab 1: Pesanan Aktif
            _buildActiveOrders(theme),
            
            // Konten Tab 2: Riwayat Pesanan (Bisa dikembangkan nanti)
            const Center(child: Text('Belum ada riwayat pesanan.')),
          ],
        ),
      ),
    );
  }

  // --- WIDGET LIST PESANAN AKTIF ---
  Widget _buildActiveOrders(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Kartu 1: Sedang Disiapkan
          _buildOrderCard(
            theme: theme,
            orderId: '#VLV-8829',
            statusText: 'SEDANG DISIAPKAN',
            statusColor: const Color(0xFFD97706), // Warna teks oranye
            statusBgColor: const Color(0xFFFEF3C7), // Warna background oranye muda
            itemNames: 'Aren Latte, Almond Croissant',
            itemCount: '2 Items',
            imageUrls: [
              'https://images.unsplash.com/photo-1558403194-611308249627?q=80&w=100&auto=format&fit=crop',
              'https://images.unsplash.com/photo-1623334044303-241021148842?q=80&w=100&auto=format&fit=crop',
            ],
            estimationTime: '10:45 WIB',
            totalPrice: 'Rp 68.000',
          ),
          const SizedBox(height: 16),
          
          // Kartu 2: Menunggu Antrian
          _buildOrderCard(
            theme: theme,
            orderId: '#VLV-8832',
            statusText: 'MENUNGGU ANTRIAN',
            statusColor: const Color(0xFF2563EB), // Warna teks biru
            statusBgColor: const Color(0xFFDBEAFE), // Warna background biru muda
            itemNames: 'Long Black (Hot)',
            itemCount: '1 Item',
            imageUrls: [
              'https://images.unsplash.com/photo-1551030173-122aabc4489c?q=80&w=100&auto=format&fit=crop',
            ],
            estimationTime: '11:05 WIB',
            totalPrice: 'Rp 32.000',
          ),
          
          const SizedBox(height: 40),
          
          // --- ILUSTRASI KOSONG / AJAKAN PESAN ---
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F4F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF6D7A73), size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'Haus? Yuk pesan kopi lagi!',
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET KARTU PESANAN ---
  Widget _buildOrderCard({
    required ThemeData theme,
    required String orderId,
    required String statusText,
    required Color statusColor,
    required Color statusBgColor,
    required String itemNames,
    required String itemCount,
    required List<String> imageUrls,
    required String estimationTime,
    required String totalPrice,
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
          // 1. Header (ID Pesanan & Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID Pesanan', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, color: const Color(0xFF6D7A73))),
                  const SizedBox(height: 2),
                  Text(orderId, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 2. Info Item (Gambar & Nama)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tumpukan Gambar (Maksimal tampilkan 2 untuk preview)
              SizedBox(
                width: imageUrls.length > 1 ? 60 : 40,
                height: 40,
                child: Stack(
                  children: [
                    if (imageUrls.length > 1)
                      Positioned(
                        left: 20,
                        child: _buildItemImage(imageUrls[1]),
                      ),
                    _buildItemImage(imageUrls[0]),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemNames,
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(itemCount, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: const Color(0xFF6D7A73))),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Color(0xFFE5E7EB), height: 1),
          ),
          
          // 3. Footer (Estimasi & Total Harga)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESTIMASI SELESAI', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 9, color: const Color(0xFF6D7A73))),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(estimationTime, style: theme.textTheme.labelSmall?.copyWith(fontSize: 12, color: theme.colorScheme.primary)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('TOTAL PEMBAYARAN', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 9, color: const Color(0xFF6D7A73))),
                  const SizedBox(height: 2),
                  Text(totalPrice, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16, color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat gambar kotak kecil dengan rounded corner
  Widget _buildItemImage(String url) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2), // Efek border putih agar tumpukan terlihat jelas
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          url,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}