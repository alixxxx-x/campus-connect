import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

// ==================== Data Model ====================

class TeacherAppNotification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type; // 'GRADE', 'ATTENDANCE', 'ANNOUNCEMENT', 'MESSAGE'
  final DateTime createdAt;
  final bool isRead;

  TeacherAppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory TeacherAppNotification.fromJson(Map<String, dynamic> json) {
    return TeacherAppNotification(
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

final teacherNotificationServiceProvider = Provider(
  (ref) => TeacherNotificationService(),
);

final teacherNotificationsProvider =
    FutureProvider<List<TeacherAppNotification>>((ref) async {
      final service = ref.read(teacherNotificationServiceProvider);
      final json = await service.getNotifications();
      return json.map((n) => TeacherAppNotification.fromJson(n)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

final unreadTeacherNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(teacherNotificationsProvider);
  return notificationsAsync.when(
    data: (list) => list.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final recentTeacherNotificationsProvider =
    Provider<List<TeacherAppNotification>>((ref) {
      final notificationsAsync = ref.watch(teacherNotificationsProvider);
      return notificationsAsync.when(
        data: (list) => list.take(3).toList(),
        loading: () => [],
        error: (_, __) => [],
      );
    });
