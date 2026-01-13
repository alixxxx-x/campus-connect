import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../shared/services/api_client.dart';

class StudentService {
  final ApiClient _api = ApiClient();

  // Helper to safely extract list from response
  List<dynamic> _extractList(dynamic responseBody) {
    if (responseBody is List) {
      return responseBody;
    } else if (responseBody is Map && responseBody.containsKey('results')) {
      return responseBody['results'] as List<dynamic>;
    }
    return [];
  }

  // GET MY GRADES
  Future<List<dynamic>> getMyGrades() async {
    try {
      final response = await _api.get('/grades/my-grades/');
      if (response.statusCode == 200) {
        return _extractList(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching grades: $e');
      return [];
    }
  }

  // GET MY ATTENDANCE
  Future<List<dynamic>> getMyAttendance() async {
    try {
      final response = await _api.get('/attendance/my-attendance/');
      if (response.statusCode == 200) {
        return _extractList(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
      return [];
    }
  }

  // GET MY COURSES
  Future<List<dynamic>> getMyCourses() async {
    try {
      final response = await _api.get('/courses/student-courses/');
      if (response.statusCode == 200) {
        return _extractList(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      return [];
    }
  }

  // GET TIMETABLE
  Future<Map<String, dynamic>?> getMyTimetable() async {
    try {
      final response = await _api.get('/timetables/my-timetable/');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching timetable: $e');
      return null;
    }
  }

  // GET FILES
  Future<List<dynamic>> getCourseFiles({int? courseId}) async {
    try {
      final url = courseId != null ? '/files/?course_id=$courseId' : '/files/';
      final response = await _api.get(url);
      if (response.statusCode == 200) {
        return _extractList(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching files: $e');
      return [];
    }
  }

  // GET PROFILE
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _api.get('/auth/profile/');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }
}
