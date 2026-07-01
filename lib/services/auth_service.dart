import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  // Fungsi Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Jika sukses, simpan token ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['data']['token']);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan: $e'};
    }
  }

  Future<void> updateFcmTokenToServer(String authToken) async {
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  
  if (fcmToken != null) {
    await http.post(
      Uri.parse('https://vivalavida.kotapintar.my.id/api/user/update-fcm'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: {'fcm_token': fcmToken},
    );
  }
}

  // Fungsi Logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null) {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      // Hapus token dari memori HP
      await prefs.remove('auth_token');
    }
  }
}