import 'package:flutter/material.dart';
import 'dart:async';
import 'reset_password_screen.dart'; // Diperlukan untuk fitur Timer

class OtpVerificationScreen extends StatefulWidget {
  final String email; // Menerima email dari halaman sebelumnya
  
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // --- State Variables ---
  int _secondsRemaining = 60; // Mulai dari 60 detik
  Timer? _timer;
  
  // List untuk mengontrol 6 kotak input OTP
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  // Fungsi untuk menjalankan hitung mundur
  void startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Pastikan timer mati saat keluar halaman
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Helper untuk mengubah detik menjadi format MM:SS
  String get formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      // Menggunakan Stack agar bisa menaruh elemen dekoratif di latar belakang
      body: Stack(
        children: [
          // --- 1. ELEMEN DEKORATIF SUDUT KANAN BAWAH ---
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0EB).withOpacity(0.5), // Hijau sangat pudar
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F0EB), // Hijau pudar
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --- 2. KONTEN UTAMA ---
          SafeArea(
            child: Column(
              children: [
                // AppBar transparan buatan manual (karena di dalam Stack)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Verifikasi Kode',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF191C1F),
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Penyeimbang IconButton agar teks pas di tengah
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // --- 3. IKON SURAT BERPENDAR ---
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F0EB), // Latar ikon
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE6F0EB).withOpacity(0.8),
                                blurRadius: 40,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mark_email_read_rounded,
                            color: theme.colorScheme.primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- 4. JUDUL & DESKRIPSI ---
                        Text(
                          'Masukkan Kode OTP',
                          style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6D7A73),
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'Kami telah mengirimkan 6-digit kode\nverifikasi ke email Anda: '),
                              TextSpan(
                                text: widget.email,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C1F)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // --- 5. KOTAK INPUT OTP (6 Digit) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) => _buildOtpBox(index, theme)),
                        ),
                        const SizedBox(height: 32),

                        // --- 6. TOMBOL VERIFIKASI ---
                        ElevatedButton(
                          onPressed: () {
                            String otpCode = _controllers.map((c) => c.text).join();
                            
                            if (otpCode.length == 6) {
                              // --- TAMBAHKAN NAVIGASI KE SINI ---
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResetPasswordScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Harap masukkan 6 digit kode OTP.')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Verifikasi',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- 7. TEKS KIRIM ULANG & TIMER ---
                        Text(
                          'Tidak menerima kode?',
                          style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73), fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _secondsRemaining == 0 
                              ? () {
                                  // Logika memanggil ulang API kirim OTP di sini
                                  startTimer(); // Mulai ulang timer
                                } 
                              : null, // Nonaktifkan klik jika timer masih berjalan
                          child: Text(
                            _secondsRemaining > 0 ? 'Kirim ulang dalam $formattedTime' : 'Kirim ulang kode sekarang',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  // Fungsi untuk membuat 1 kotak input OTP
  Widget _buildOtpBox(int index, ThemeData theme) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1, // Dibatasi 1 karakter per kotak
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '', // Menghilangkan teks hitungan "0/1" di bawah
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
        onChanged: (value) {
          // Logika pemindahan kursor otomatis
          if (value.isNotEmpty && index < 5) {
            // Pindah ke kotak selanjutnya jika diisi
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Pindah ke kotak sebelumnya jika dihapus
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}