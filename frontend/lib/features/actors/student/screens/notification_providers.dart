import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

// ==================== Data Model ====================

class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type; // 'GRADE', 'ATTENDANCE', 'ANNOUNCEMENT'
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['notification_type'] ?? 'ANNOUNCEMENT',
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }
}

// ==================== Providers ====================

final notificationServiceProvider = Provider((ref) => NotificationService());

final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final service = ref.read(notificationServiceProvider);
  final json = await service.getNotifications();
  return json.map((n) => AppNotification.fromJson(n)).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.when(
    data: (list) => list.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final recentNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.when(
    data: (list) => list.take(3).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
