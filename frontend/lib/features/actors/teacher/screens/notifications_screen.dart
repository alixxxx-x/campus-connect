import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'notification_providers.dart';

class TeacherNotificationsScreen extends ConsumerWidget {
  const TeacherNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(teacherNotificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(teacherNotificationsProvider.future),
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(context, ref, notification);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('We\'ll notify you when something important happens.'),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    WidgetRef ref,
    TeacherAppNotification notification,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: _getTypeColor(
          notification.type,
        ).withValues(alpha: 0.1),
        child: Icon(
          _getTypeIcon(notification.type),
          color: _getTypeColor(notification.type),
          size: 24,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.message,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            _formatTimestamp(notification.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
      trailing: !notification.isRead
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: () async {
        if (!notification.isRead) {
          await ref
              .read(teacherNotificationServiceProvider)
              .markAsRead(notification.id);
          ref.invalidate(teacherNotificationsProvider);
        }
      },
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'GRADE':
        return Icons.grade_rounded;
      case 'ATTENDANCE':
        return Icons.calendar_today_rounded;
      case 'MESSAGE':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'GRADE':
        return Colors.amber[700]!;
      case 'ATTENDANCE':
        return Colors.green;
      case 'MESSAGE':
        return const Color(0xFF6366F1);
      default:
        return Colors.blue;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays == 0) {
      return DateFormat.Hm().format(timestamp);
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(timestamp);
    } else {
      return DateFormat.yMd().format(timestamp);
    }
  }
}
