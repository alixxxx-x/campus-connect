import 'dart:convert';
import '../../../../shared/services/api_client.dart';

class GradingService {
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

  // Get students and their grades for a specific course assignment
  Future<List<dynamic>> getCourseStudents(int assignmentId) async {
    final response = await _apiClient.get(
      '/grades/course/$assignmentId/students/',
    );
    return _extractList(jsonDecode(response.body));
  }

  // Update a student's grade
  Future<void> updateGrade({
    required int gradeId,
    double? tdMark,
    double? tpMark,
    double? examMark,
    String? comments,
  }) async {
    final Map<String, dynamic> data = {};
    if (tdMark != null) data['td_mark'] = tdMark;
    if (tpMark != null) data['tp_mark'] = tpMark;
    if (examMark != null) data['exam_mark'] = examMark;
    if (comments != null) data['comments'] = comments;

    await _apiClient.put('/grades/$gradeId/', data);
  }
}
