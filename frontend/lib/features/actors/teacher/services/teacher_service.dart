import 'dart:convert';
import '../../../../shared/services/api_client.dart';

class TeacherService {
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

  // Get teacher profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get('/auth/profile/');
    return jsonDecode(response.body);
  }

  // Get courses assigned to teacher
  Future<List<dynamic>> getMyCourses() async {
    final response = await _apiClient.get('/courses/my-courses/');
    return _extractList(jsonDecode(response.body));
  }
}
