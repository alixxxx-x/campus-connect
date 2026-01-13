import 'dart:convert';
import '../../../../shared/services/api_client.dart';

class MessagingService {
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

  // Get conversation list (all messages involving user)
  Future<List<dynamic>> getConversations() async {
    final response = await _apiClient.get('/messages/');
    return _extractList(jsonDecode(response.body));
  }

  // Get chat history with specific user
  Future<List<dynamic>> getMessagesWithUser(int otherUserId) async {
    final response = await _apiClient.get('/messages/?with_user=$otherUserId');
    return _extractList(jsonDecode(response.body));
  }

  // Send message
  Future<Map<String, dynamic>> sendMessage(
    int receiverId,
    String content,
  ) async {
    final response = await _apiClient.post('/messages/', {
      'receiver': receiverId,
      'content': content,
    });
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Search for users
  Future<List<dynamic>> searchUsers(String query) async {
    final response = await _apiClient.get(
      '/users/search/',
      queryParams: {'search': query},
    );
    return _extractList(jsonDecode(response.body));
  }
}
