import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';

// ==================== Data Models ====================

class AdminNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['notification_type'] ?? 'INFO',
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }
}

// ==================== Providers ====================

final adminNotificationsProvider = FutureProvider<List<AdminNotification>>((
  ref,
) async {
  final service = ref.read(adminServiceProvider);
  final response = await service.getNotifications();
  return response.map((json) => AdminNotification.fromJson(json)).toList();
});
