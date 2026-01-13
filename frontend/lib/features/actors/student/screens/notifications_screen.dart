import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
        onRefresh: () => ref.refresh(notificationsProvider.future),
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationItem(
                  context,
                  ref,
                  notifications[index],
                );
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
            'All caught up!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('You have no new notifications.'),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey[200]!
              : const Color(0xFFC7D2FE),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getTypeColor(notification.type).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
            size: 20,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead
                    ? FontWeight.w600
                    : FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              notification.message,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM d, h:mm a').format(notification.createdAt),
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
        onTap: () async {
          if (!notification.isRead) {
            await ref
                .read(notificationServiceProvider)
                .markAsRead(notification.id);
            ref.invalidate(notificationsProvider);
          }
        },
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'GRADE':
        return Icons.grade_rounded;
      case 'ATTENDANCE':
        return Icons.how_to_reg_rounded;
      case 'ANNOUNCEMENT':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'GRADE':
        return Colors.amber[700]!;
      case 'ATTENDANCE':
        return Colors.teal[600]!;
      case 'ANNOUNCEMENT':
        return Colors.indigo[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
