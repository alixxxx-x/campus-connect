import 'dart:convert';
import '../../../../shared/services/api_client.dart';

class NotificationService {
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

  // Get all notifications for user
  Future<List<dynamic>> getNotifications() async {
    final response = await _apiClient.get('/notifications/');
    return _extractList(jsonDecode(response.body));
  }

  // Mark notification as read
  Future<void> markAsRead(int id) async {
    await _apiClient.post('/notifications/$id/read/', {});
  }
}
