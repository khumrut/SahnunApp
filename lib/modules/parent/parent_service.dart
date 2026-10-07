import '../../core/api/api_client.dart';
import '../../core/auth/auth_service.dart';
import 'parent_student.dart';

class ParentService {
  static Future<List<ParentStudent>> getStudents() async {
    final token = await AuthService.readToken();

    if (token == null || token.isEmpty) {
      throw Exception('ไม่พบ Access Token');
    }

    final response = await ApiClient.get(
      '/api/app/parent/students',
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'โหลดข้อมูลนักเรียนไม่สำเร็จ');
    }

    final data = Map<String, dynamic>.from(response['data'] ?? {});

    final rows = List<dynamic>.from(data['students'] ?? []);

    return rows
        .map((row) => ParentStudent.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  static Future<void> linkStudent({
    required int organizationId,
    required String studentId,
  }) async {
    final token = await AuthService.readToken();

    if (token == null || token.isEmpty) {
      throw Exception('ไม่พบ Access Token');
    }

    final response = await ApiClient.post(
      '/api/app/parent/link-student',
      token: token,
      body: {
        'organization_id': organizationId,
        'student_id': studentId,
        'relationship': 'parent',
      },
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'เชื่อมโยงนักเรียนไม่สำเร็จ');
    }
  }

  static Future<void> unlinkStudent({
    required int organizationId,
    required String studentId,
  }) async {
    final token = await AuthService.readToken();

    if (token == null || token.isEmpty) {
      throw Exception('ไม่พบ Access Token');
    }

    final response = await ApiClient.post(
      '/api/app/parent/unlink-student',
      token: token,
      body: {'organization_id': organizationId, 'student_id': studentId},
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'ยกเลิกการเชื่อมโยงไม่สำเร็จ');
    }
  }

  static Future<Map<String, dynamic>> getAttendance({
    required int organizationId,
    required String studentId,
  }) async {
    final token = await AuthService.readToken();

    if (token == null || token.isEmpty) {
      throw Exception('ไม่พบ Access Token');
    }

    final response = await ApiClient.post(
      '/api/app/parent/attendance',
      token: token,
      body: {'organization_id': organizationId, 'student_id': studentId},
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'โหลดข้อมูลเวลาเข้า-ออกไม่สำเร็จ');
    }

    final data = Map<String, dynamic>.from(response['data'] ?? {});

    return Map<String, dynamic>.from(data['attendance'] ?? {});
  }
}
