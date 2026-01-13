import 'dart:convert';
import '../../../../shared/services/api_client.dart';

class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  // Helper to safely extract list from response
  List<dynamic> _extractList(dynamic responseBody) {
    if (responseBody is List) {
      return responseBody;
    } else if (responseBody is Map && responseBody.containsKey('results')) {
      return responseBody['results'] as List<dynamic>;
    }
    return [];
  }

  // Get students for a specific course (using the grades endpoint which populates student lists)
  Future<List<dynamic>> getStudentsInCourse(int courseId) async {
    final response = await _apiClient.get('/grades/course/$courseId/students/');
    return _extractList(jsonDecode(response.body));
  }

  // Get existing attendance for a course on a specific week
  Future<List<dynamic>> getExistingAttendance(
    int courseId,
    int weekNumber,
  ) async {
    final response = await _apiClient.get(
      '/attendance/?course_id=$courseId&week=$weekNumber',
    );
    return _extractList(jsonDecode(response.body));
  }

  // Bulk mark attendance for multiple students (Preferred)
  Future<void> bulkMarkAttendance(List<Map<String, dynamic>> records) async {
    await _apiClient.post('/attendance/bulk/', {'attendance': records});
  }

  // Mark attendance for a single student (Fallback)
  Future<void> markAttendance({
    required int studentId,
    required int courseId,
    required int weekNumber,
    required String status,
    String? notes,
  }) async {
    await _apiClient.post('/attendance/', {
      'student': studentId,
      'course': courseId,
      'week_number': weekNumber,
      'status': status,
      'notes': notes ?? '',
    });
  }
}
