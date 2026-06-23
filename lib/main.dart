import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'package:provider/provider.dart'; // Wajib import ini
import 'providers/cart_provider.dart';  // Import file provider yang baru dibuat
import 'screens/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

void susunKonfigurasiNotifikasi(BuildContext context) {
  // Ketika notifikasi masuk saat aplikasi sedang aktif dibuka (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.coffee, color: Color(0xFF046A41)),
              const SizedBox(width: 8),
              Text(message.notification!.title ?? 'Info Vivalavida'),
            ],
          ),
          content: Text(message.notification!.body ?? ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFF046A41), fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }
  });
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