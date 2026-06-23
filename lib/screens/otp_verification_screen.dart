import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_config.dart'; // Pastikan path import ini sesuai
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email; 
  
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  int _secondsRemaining = 60; 
  Timer? _timer;
  bool _isLoading = false;
  
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    startTimer();
  }

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
    _timer?.cancel(); 
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- FUNGSI VERIFIKASI OTP ---
  Future<void> _verifyOtp() async {
    String otpCode = _controllers.map((c) => c.text).join();
    
    if (otpCode.length != 6) {
      _showSnackBar('Harap masukkan 6 digit kode OTP secara lengkap.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/forgot-password/verify-otp');
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'email': widget.email,
          'otp': otpCode,
        },
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _showSnackBar('Kode OTP berhasil diverifikasi!', isError: false);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: widget.email), // Kirim email ke layar reset
            ),
          );
        }
      } else {
        final data = json.decode(response.body);
        _showSnackBar(data['message'] ?? 'Kode OTP salah atau kadaluarsa.', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal terhubung ke server.', isError: true);
    }
  }

  // --- FUNGSI KIRIM ULANG OTP ---
  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/forgot-password/send-otp');
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {'email': widget.email},
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        _showSnackBar('Kode OTP baru telah dikirim ke email Anda.', isError: false);
        startTimer(); // Mulai ulang timer jika sukses
      } else {
        _showSnackBar('Gagal mengirim ulang OTP.', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal terhubung ke server.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0EB).withOpacity(0.5),
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
                color: Color(0xFFE6F0EB),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
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
                      const SizedBox(width: 48), 
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F0EB), 
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) => _buildOtpBox(index, theme)),
                        ),
                        const SizedBox(height: 32),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text(
                                'Verifikasi',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'Tidak menerima kode?',
                          style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6D7A73), fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: (_secondsRemaining == 0 && !_isLoading) ? _resendOtp : null,
                          child: Text(
                            _secondsRemaining > 0 ? 'Kirim ulang dalam $formattedTime' : 'Kirim ulang kode sekarang',
                            style: TextStyle(
                              color: (_secondsRemaining == 0 && !_isLoading) ? theme.colorScheme.primary : Colors.grey,
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

  Widget _buildOtpBox(int index, ThemeData theme) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1, 
        enabled: !_isLoading,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '', 
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
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}