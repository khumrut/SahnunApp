import '../../core/api/api_client.dart';
import '../../core/auth/auth_service.dart';

class RestaurantService {
  static Future<String> _token() async {
    final token = await AuthService.readToken();

    if (token == null || token.isEmpty) {
      throw Exception('กรุณาเข้าสู่ระบบใหม่');
    }

    return token;
  }

  static Future<List<Map<String, dynamic>>> getMenu(int organizationId) async {
    final response = await ApiClient.get(
      '/api/restaurant/menu/manage?organization_id=$organizationId',
      token: await _token(),
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'ไม่สามารถโหลดเมนูอาหารได้');
    }

    final data = Map<String, dynamic>.from(response['data'] ?? {});

    return (data['items'] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> updatePrice({
    required int organizationId,
    required int menuId,
    required double price,
  }) async {
    final response = await ApiClient.post(
      '/api/restaurant/menu/update-price',
      token: await _token(),
      body: {
        'organization_id': organizationId,
        'menu_id': menuId,
        'price': price.toStringAsFixed(2),
      },
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'แก้ไขราคาไม่สำเร็จ');
    }
  }

  static Future<void> setAvailability({
    required int organizationId,
    required int menuId,
    required bool available,
  }) async {
    final response = await ApiClient.post(
      '/api/restaurant/menu/availability',
      token: await _token(),
      body: {
        'organization_id': organizationId,
        'menu_id': menuId,
        'is_available': available ? 1 : 0,
      },
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'เปลี่ยนสถานะเมนูไม่สำเร็จ');
    }
  }
}
