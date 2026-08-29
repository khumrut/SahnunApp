import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://sahnun.local';

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 15));

    return _decode(response);
  }

  static Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl$path'),
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    return _decode(response);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw const FormatException();
    } catch (_) {
      throw HttpException(
        'Server ส่งข้อมูลไม่ถูกต้อง '
        '(HTTP ${response.statusCode})',
      );
    }
  }
}
