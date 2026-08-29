import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../models/app_bootstrap.dart';

class AuthResult {
  final String token;
  final AppBootstrap bootstrap;

  const AuthResult({required this.token, required this.bootstrap});
}

class AuthService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'sahnun_access_token';

  static Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/api/app/login',
      body: {
        'username': username,
        'password': password,
        'device_name': Platform.localHostname,
        'platform': _platformName(),
      },
    );

    final success = response['success'] == true;

    if (!success) {
      throw Exception(response['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ');
    }

    final data = Map<String, dynamic>.from(response['data'] ?? {});

    final token = (data['token'] ?? '').toString();

    if (token.isEmpty) {
      throw Exception('Server ไม่ได้ส่ง Access Token');
    }

    final bootstrapJson = Map<String, dynamic>.from(data['bootstrap'] ?? {});

    await _storage.write(key: _tokenKey, value: token);

    return AuthResult(
      token: token,
      bootstrap: AppBootstrap.fromJson(bootstrapJson),
    );
  }

  static Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  static Future<AppBootstrap?> restoreSession() async {
    final token = await readToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await ApiClient.get('/api/app/bootstrap', token: token);

      if (response['success'] != true) {
        await clearToken();
        return null;
      }

      return AppBootstrap.fromJson(
        Map<String, dynamic>.from(response['data'] ?? {}),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> logout() async {
    final token = await readToken();

    if (token != null && token.isNotEmpty) {
      try {
        await ApiClient.post('/api/app/logout', token: token);
      } catch (_) {
        // ถึง Server ติดต่อไม่ได้
        // ก็ยังล้าง token ฝั่งเครื่อง
      }
    }

    await clearToken();
  }

  static Future<void> clearToken() {
    return _storage.delete(key: _tokenKey);
  }

  static String _platformName() {
    if (Platform.isWindows) {
      return 'windows';
    }

    if (Platform.isAndroid) {
      return 'android';
    }

    if (Platform.isIOS) {
      return 'ios';
    }

    if (Platform.isLinux) {
      return 'linux';
    }

    if (Platform.isMacOS) {
      return 'macos';
    }

    return 'unknown';
  }
}
