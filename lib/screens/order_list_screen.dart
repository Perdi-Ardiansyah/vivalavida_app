import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  bool _isLoading = true;
  List<dynamic> _activeOrders = [];
  List<dynamic> _historyOrders = [];
  
  // --- VARIABEL UNTUK MENYIMPAN ID PESANAN YANG DIHAPUS LOKAL ---
  List<String> _hiddenOrderIds = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // Fungsi inisialisasi: memuat ID tersembunyi dulu, baru fetch dari Laravel
  Future<void> _initData() async {
    await _loadHiddenOrderIds();
    await _fetchOrders();
  }

  // 1. Memuat daftar ID tersembunyi dari memori internal HP
  Future<void> _loadHiddenOrderIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _hiddenOrderIds = prefs.getStringList('hidden_order_ids') ?? [];
      });
    }
  }

  // 2. Fungsi hapus lokal (Menyembunyikan pesanan dari UI)
  Future<void> _deleteOrderLocally(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _hiddenOrderIds.add(orderId); // Tambah ID ke daftar hitam lokal
      // Langsung hapus dari list riwayat di UI agar instan tanpa loading
      _historyOrders.removeWhere((order) => order['id'].toString() == orderId);
    });

    // Simpan daftar hitam terbaru ke memori internal HP
    await prefs.setStringList('hidden_order_ids', _hiddenOrderIds);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat pesanan berhasil dihapus.'),
          backgroundColor: Colors.black87,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 3. Ambil data dari server
  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('https://vivalavidacoffeshop.rf.gd/api/orders');
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> allOrders = data['data'] ?? [];

        List<dynamic> active = [];
        List<dynamic> history = [];

        for (var order in allOrders) {
          String orderIdStr = order['id']?.toString() ?? '';
          
          // FILTER: Jika ID pesanan ada di daftar hitam lokal, LEWATKAN (jangan tampilkan)
          if (_hiddenOrderIds.contains(orderIdStr)) {
            continue; 
          }

          String status = order['status'].toString().toLowerCase();
          if (status == 'selesai' || status == 'completed' || status == 'batal' || status == 'cancelled') {
            history.add(order);
          } else {
            active.add(order);
          }
        }

        if (mounted) {
          setState(() {
            _activeOrders = active;
            _historyOrders = history;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2, 
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
        
        body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : TabBarView(
              children: [
                RefreshIndicator(
                  onRefresh: _fetchOrders,
                  color: theme.colorScheme.primary,
                  child: _buildOrderList(theme, _activeOrders, true),
                ),
                RefreshIndicator(
                  onRefresh: _fetchOrders,
                  color: theme.colorScheme.primary,
                  child: _buildOrderList(theme, _historyOrders, false),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildOrderList(ThemeData theme, List<dynamic> orders, bool isActiveTab) {
    if (orders.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFFF2F4F8), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF6D7A73), size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                isActiveTab ? 'Belum ada pesanan aktif.' : 'Belum ada riwayat pesanan.',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Haus? Yuk pesan kopi sekarang!',
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20.0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        // Kirim parameter isActiveTab ke card generator
        return _buildDynamicOrderCard(theme, order, isActiveTab);
      },
    );
  }

  Widget _buildDynamicOrderCard(ThemeData theme, dynamic order, bool isActiveCard) {
    String rawStatus = order['status']?.toString().toLowerCase() ?? 'new';
    String statusText = 'MENUNGGU';
    Color statusColor = const Color(0xFFD97706); 
    Color statusBgColor = const Color(0xFFFEF3C7);

    if (rawStatus == 'new' || rawStatus == 'pending') {
      statusText = 'SEDANG DISIAPKAN';
      statusColor = const Color(0xFFD97706);
      statusBgColor = const Color(0xFFFEF3C7);
    } else if (rawStatus == 'ready') {
      statusText = 'SIAP DIAMBIL';
      statusColor = const Color(0xFF2563EB); 
      statusBgColor = const Color(0xFFDBEAFE);
    } else if (rawStatus == 'completed') {
      statusText = 'SELESAI';
      statusColor = const Color(0xFF046A41); 
      statusBgColor = const Color(0xFFE8F5E9);
    } else if (rawStatus == 'cancelled' || rawStatus == 'batal') {
      statusText = 'DIBATALKAN';
      statusColor = const Color(0xFFDC2626); 
      statusBgColor = const Color(0xFFFEE2E2);
    }

    String rawHarga = order['total_akhir']?.toString() ?? order['total_harga']?.toString() ?? '0';
    rawHarga = rawHarga.split('.')[0]; 
    int totalHarga = int.tryParse(rawHarga) ?? 0;

    List<dynamic> items = order['pesanan_items'] ?? order['items'] ?? [];
    List<String> imageUrls = [];
    List<String> itemNames = [];
    
    for (var item in items) {
      String name = 'Menu';
      if (item['menu'] != null && item['menu']['nama'] != null) {
        name = item['menu']['nama'].toString();
      } else if (item['nama_menu'] != null) {
        name = item['nama_menu'].toString();
      }
      itemNames.add(name);

      dynamic imgData = item['menu'] != null ? item['menu']['gambar'] : item['gambar'];
      if (imgData != null && imgData.toString().trim().isNotEmpty) {
        String imgStr = imgData.toString();
        String finalUrl = imgStr.startsWith('http') ? imgStr : 'https://vivalavidacoffeshop.rf.gd/storage/$imgStr';
        imageUrls.add(finalUrl);
      }
    }

    if (imageUrls.isEmpty) {
      imageUrls.add('https://images.unsplash.com/photo-1551030173-122aabc4489c?q=90&w=400&auto=format&fit=crop');
    }

    String itemNamesString = itemNames.join(', ');
    if (itemNamesString.isEmpty) itemNamesString = 'Pesanan Vivalavida';

    String databaseId = order['id']?.toString() ?? '';
    String orderId = '#VLV-$databaseId';

    String timeStr = '-';
    if (order['created_at'] != null) {
      String rawTime = order['created_at'].toString();
      if (rawTime.length >= 16) {
        timeStr = '${rawTime.substring(11, 16)} WIB';
      } else {
        timeStr = rawTime;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  Text('ID Pesanan', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, color: const Color(0xFF6D7A73))),
                  const SizedBox(height: 2),
                  Text(orderId, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                ],
              ),
              
              // --- LOGIKA TOMBOL HAPUS / LABEL STATUS ---
              // Jika ini Tab Riwayat (bukan pesanan aktif), tampilkan tombol ikon sampah di pojok kanan kartu
              !isActiveCard 
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                    onPressed: () {
                      // Munculkan dialog konfirmasi sebelum menghapus secara lokal
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Hapus Riwayat?'),
                            content: const Text('Pesanan ini akan dihapus dari daftar tampilan Anda.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteOrderLocally(databaseId); // Sembunyikan
                                },
                                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(6)),
                    child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: imageUrls.length > 1 ? 60 : 40,
                height: 40,
                child: Stack(
                  children: [
                    if (imageUrls.length > 1)
                      Positioned(left: 20, child: _buildItemImage(imageUrls[1])),
                    _buildItemImage(imageUrls[0]),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemNamesString, style: theme.textTheme.labelSmall?.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${items.length} Item', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: const Color(0xFF6D7A73))),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Divider(color: Color(0xFFE5E7EB), height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rawStatus == 'completed' ? 'SELESAI PADA' : 'WAKTU PESANAN', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 9, color: const Color(0xFF6D7A73))),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(timeStr, style: theme.textTheme.labelSmall?.copyWith(fontSize: 12, color: theme.colorScheme.primary)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('TOTAL PEMBAYARAN', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 9, color: const Color(0xFF6D7A73))),
                  const SizedBox(height: 2),
                  Text('Rp ${totalHarga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16, color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(String url) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white, width: 2)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          url, width: 36, height: 36, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
        ),
      ),
    );
  }
}