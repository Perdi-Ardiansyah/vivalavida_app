import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // --- State Variables untuk Switch ---
  bool isOrderUpdatesOn = true;
  bool isVouchersOn = true;
  bool isNewsOn = false;
  bool isLoginAlertsOn = true;
  bool isAccountActivityOn = true;

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
          'Notification Settings',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary, // Warna hijau utama
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HERO BANNER ---
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  // Gambar orang menuang susu ke kopi (Latte Art)
                  image: NetworkImage('https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=600&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stay Updated',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tailor your Brew & Pitch experience',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. PESAN & PROMO ---
            _buildSectionLabel(theme, 'Pesan & Promo'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildSwitchItem(
                    theme: theme,
                    title: 'Order updates',
                    subtitle: 'Get notified about your coffee brewing and delivery status.',
                    value: isOrderUpdatesOn,
                    onChanged: (val) => setState(() => isOrderUpdatesOn = val),
                  ),
                  _buildSwitchItem(
                    theme: theme,
                    title: 'Vouchers',
                    subtitle: 'Never miss an exclusive discount or loyalty reward.',
                    value: isVouchersOn,
                    onChanged: (val) => setState(() => isVouchersOn = val),
                  ),
                  _buildSwitchItem(
                    theme: theme,
                    title: 'News',
                    subtitle: 'Be the first to know about new seasonal blends and events.',
                    value: isNewsOn,
                    onChanged: (val) => setState(() => isNewsOn = val),
                    showDivider: false, // Item terakhir tidak perlu garis bawah
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 3. KEAMANAN & AKUN ---
            _buildSectionLabel(theme, 'Keamanan & Akun'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildSwitchItem(
                    theme: theme,
                    title: 'Login alerts',
                    subtitle: 'Security notifications for new login attempts.',
                    value: isLoginAlertsOn,
                    onChanged: (val) => setState(() => isLoginAlertsOn = val),
                  ),
                  _buildSwitchItem(
                    theme: theme,
                    title: 'Account activity',
                    subtitle: 'Alerts for changes in your profile or settings.',
                    value: isAccountActivityOn,
                    onChanged: (val) => setState(() => isAccountActivityOn = val),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- 4. FOOTER TEXT ---
            const Center(
              child: Text(
                'Changes are saved automatically.',
                style: TextStyle(
                  color: Color(0xFF6D7A73),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF6D7A73),
        fontSize: 14,
      ),
    );
  }

  Widget _buildSwitchItem({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: const Color(0xFF6D7A73), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: value,
                activeColor: theme.colorScheme.primary,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: Color(0xFFE5E7EB), indent: 16, endIndent: 16),
      ],
    );
  }
}