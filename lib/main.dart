import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'package:provider/provider.dart'; // Wajib import ini
import 'providers/cart_provider.dart';  // Import file provider yang baru dibuat
import 'screens/login_screen.dart';
 // 1. Jangan lupa import file main_screen.dart

void main() {
  runApp(
    // Bungkus aplikasimu di sini
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const CoffeeShopApp(), // Sesuaikan dengan nama class utama aplikasi kamu
    ),
  );
}

class CoffeeShopApp extends StatelessWidget {
  const CoffeeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vivalavida Coffee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, 
      
      // 2. Ubah bagian home ini untuk memanggil MainScreen
      home: const LoginScreen(),
    );
  }
}