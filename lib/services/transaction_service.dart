import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  final Dio _dio = Dio(
    BaseOptions(
      // GANTI DENGAN IP LARAVEL KAMU, misal: http://192.168.1.5:8000/api
      baseUrl: 'https://vivalavidacoffeshop.rf.gd/api', 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  Future<Map<String, dynamic>> checkout(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _dio.post(
        '/checkout',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data;
   } on DioException catch (e) {
      // Kita bongkar pesan error asli dari backend Laravel
      String errorMessage = 'Gagal memproses pesanan.';
      
      if (e.response != null && e.response?.data is Map) {
        // Ambil detail 'error' yang dikirim dari controller Laravel
        errorMessage = e.response?.data['error'] ?? e.response?.data['message'] ?? errorMessage;
      } else {
        errorMessage = 'Server Error: ${e.response?.statusCode}';
      }
      
      throw Exception(errorMessage);
    }
  }
}