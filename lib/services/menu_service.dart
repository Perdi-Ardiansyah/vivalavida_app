import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class MenuService {
  // Tambahkan fungsi ini di dalam class MenuService
  Future<List<dynamic>> getCategories() async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/categories');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  // Fungsi untuk mengambil Bearer Token
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Fungsi mengambil daftar menu
  Future<List<dynamic>> getMenus() async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/menus');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Memasukkan token Sanctum
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Mengembalikan List JSON
      } else {
        throw Exception('Gagal memuat menu');
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }
}