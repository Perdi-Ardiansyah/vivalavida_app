import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart'; // Import halaman utama (Bottom Navigation)
import '../services/auth_service.dart'; // PASTIKAN IMPORT INI SESUAI DENGAN LOKASI FOLDERMU

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // State untuk mengatur visibilitas kata sandi
  bool _obscurePassword = true;

  // --- 1. DEKLARASI CONTROLLER ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- 2. FUNGSI LOGIC LOGIN ---
  void _handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    // Validasi input kosong
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password tidak boleh kosong!'), backgroundColor: Colors.red),
      );
      return;
    }

    AuthService authService = AuthService();
    var result = await authService.login(email, password);

    // Mencegah error context jika halaman sudah ditutup saat proses await
    if (!mounted) return; 

    if (result['success']) {
      // Jika sukses, pindah ke HomeScreen / MainScreen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'], style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } else {
      // Jika gagal, tampilkan pesan error dari Laravel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'], style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }

  // --- 3. DISPOSE CONTROLLER UNTUK MENCEGAH MEMORY LEAK ---
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(
        0xFFF9FAFB,
      ), // Latar belakang abu-abu sangat terang
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- HEADER (JUDUL) ---
                  Text(
                    'Vivalavida',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selamat Datang\nKembali',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF191C1F),
                      fontSize: 22,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan masuk ke akun Anda.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6D7A73),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- FORM EMAIL ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF3D4943),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController, // --- 4. SAMBUNGKAN CONTROLLER ---
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'nama@email.com',
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.mail_outline,
                        color: Colors.black38,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- FORM PASSWORD ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Password',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF3D4943),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman Lupa Kata Sandi
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController, // --- 5. SAMBUNGKAN CONTROLLER ---
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                        letterSpacing: 2,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.black38,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black38,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- TOMBOL MASUK ---
                  ElevatedButton(
                    onPressed: _handleLogin, // --- 6. PANGGIL FUNGSI LOGIN ---
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- DIVIDER ATAU ---
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Atau lanjutkan dengan',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF6D7A73),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- TOMBOL GOOGLE ---
                  // OutlinedButton.icon(
                  //   onPressed: () {
                  //     // Aksi login dengan Google
                  //   },
                  //   // Menggunakan gambar logo Google dari URL internet (sebagai dummy)
                  //   icon: Image.network(
                  //     'https://img.icons8.com/color/48/000000/google-logo.png',
                  //     height: 24,
                  //     width: 24,
                  //   ),
                  //   label: const Text(
                  //     'Masuk dengan Google',
                  //     style: TextStyle(
                  //       color: Color(0xFF3D4943),
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  //   style: OutlinedButton.styleFrom(
                  //     minimumSize: const Size(double.infinity, 50),
                  //     side: const BorderSide(color: Color(0xFFE5E7EB)),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 32),

                  // --- DAFTAR AKUN BARU ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: const Color(0xFF6D7A73),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman Register
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Daftar di sini',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}