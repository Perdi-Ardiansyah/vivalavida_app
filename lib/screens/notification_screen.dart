import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isLoading = true;
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // --- 1. AMBIL DATA NOTIFIKASI DARI LARAVEL ---
  Future<void> _fetchNotifications() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('http://10.0.2.2:8000/api/user/notifications');
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notifications = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Gagal memuat notifikasi. Periksa jaringan Anda.');
    }
  }

  // --- 2. TANDAI SEMUA SUDAH DIBACA ---
  Future<void> _markAllAsRead() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final url = Uri.parse('http://10.0.2.2:8000/api/user/notifications/read');
      final response = await http.put(
        url,
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _showSnackBar('Semua notifikasi ditandai sudah dibaca', isSuccess: true);
        _fetchNotifications(); // Refresh data
      }
    } catch (e) {
      _showSnackBar('Gagal menandai notifikasi.');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isSuccess ? Colors.green : Colors.red, behavior: SnackBarBehavior.floating),
    );
  }

  // --- HELPER UNTUK IKON & WARNA BERDASARKAN TIPE ---
  Map<String, dynamic> _getStyleForType(String type, bool isRead, ThemeData theme) {
    IconData icon;
    Color iconColor;
    Color iconBgColor;

    switch (type.toLowerCase()) {
      case 'pesanan':
        icon = Icons.coffee;
        iconColor = theme.colorScheme.primary;
        iconBgColor = const Color(0xFFE6F0EB);
        break;
      case 'poin':
        icon = Icons.star;
        iconColor = const Color(0xFF705A4F);
        iconBgColor = const Color(0xFFFBDCCE).withOpacity(0.5);
        break;
      case 'promo':
        icon = Icons.campaign_outlined;
        iconColor = Colors.orange;
        iconBgColor = Colors.orange.withOpacity(0.1);
        break;
      default:
        icon = Icons.notifications_active_outlined;
        iconColor = theme.colorScheme.primary;
        iconBgColor = const Color(0xFFE6F0EB);
    }

    // Jika sudah dibaca, ubah warna menjadi abu-abu pudar
    if (isRead) {
      iconColor = Colors.grey;
      iconBgColor = Colors.transparent;
    }

    return {'icon': icon, 'color': iconColor, 'bgColor': iconBgColor};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Memisahkan notifikasi berdasarkan status baca
    final unreadNotifs = notifications.where((n) => n['is_read'] == 0 || n['is_read'] == false).toList();
    final readNotifs = notifications.where((n) => n['is_read'] == 1 || n['is_read'] == true).toList();

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
          'Notifikasi',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          if (unreadNotifs.isNotEmpty) // Tombol hanya muncul jika ada yang belum dibaca
            IconButton(
              icon: Icon(Icons.checklist, color: theme.colorScheme.primary),
              tooltip: 'Tandai semua dibaca',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchNotifications,
            color: theme.colorScheme.primary,
            child: notifications.isEmpty 
            ? ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey)),
                  const SizedBox(height: 16),
                  const Center(child: Text('Belum ada notifikasi saat ini', style: TextStyle(color: Colors.grey))),
                ],
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECTION: BELUM DIBACA ---
                    if (unreadNotifs.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Belum Dibaca', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              '${unreadNotifs.length} Baru',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      ...unreadNotifs.map((notif) {
                        final style = _getStyleForType(notif['tipe'] ?? 'umum', false, theme);
                        return _buildNotificationCard(
                          context: context,
                          isRead: false,
                          icon: style['icon'],
                          iconColor: style['color'],
                          iconBgColor: style['bgColor'],
                          title: notif['judul'] ?? 'Pemberitahuan',
                          time: 'Baru', // Idealnya diformat dari notif['created_at']
                          description: notif['deskripsi'] ?? '',
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // --- SECTION: SUDAH DIBACA ---
                    if (readNotifs.isNotEmpty) ...[
                      Text('Sudah Dibaca', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18)),
                      const SizedBox(height: 16),

                      ...readNotifs.map((notif) {
                        final style = _getStyleForType(notif['tipe'] ?? 'umum', true, theme);
                        return _buildNotificationCard(
                          context: context,
                          isRead: true,
                          icon: style['icon'],
                          iconColor: style['color'],
                          iconBgColor: style['bgColor'],
                          title: notif['judul'] ?? 'Pemberitahuan',
                          time: 'Selesai', 
                          description: notif['deskripsi'] ?? '',
                        );
                      }),
                    ],
                  ],
                ),
              ),
        ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required bool isRead,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String time,
    required String description,
  }) {
    final theme = Theme.of(context);
    final bgColor = isRead ? const Color(0xFFF2F4F8) : Colors.white; 
    final textColor = isRead ? const Color(0xFF6D7A73) : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isRead ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isRead) Container(width: 4, color: theme.colorScheme.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isRead ? const Color(0xFFE0E2E6) : iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(title, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              Text(time, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, color: const Color(0xFF6D7A73))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: isRead ? const Color(0xFF6D7A73) : const Color(0xFF3D4943),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}