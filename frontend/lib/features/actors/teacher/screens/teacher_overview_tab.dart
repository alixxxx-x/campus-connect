import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/auth_service.dart';
import 'teacher_providers.dart';
import 'notification_providers.dart';
import 'notifications_screen.dart';

class TeacherOverviewTab extends ConsumerWidget {
  const TeacherOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(teacherFreshProfileProvider);
    final coursesAsync = ref.watch(teacherCoursesProvider);
    final stats = ref.watch(teacherStatsProvider);
    final unreadCount = ref.watch(unreadTeacherNotificationsCountProvider);
    final recentNotifications = ref.watch(recentTeacherNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.refresh(teacherFreshProfileProvider.future),
              ref.refresh(teacherCoursesProvider.future),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                profileAsync.when(
                  data: (profile) =>
                      _buildHeader(context, profile, ref, unreadCount),
                  loading: () => const Center(child: LinearProgressIndicator()),
                  error: (_, __) =>
                      _buildHeader(context, null, ref, unreadCount),
                ),

                const SizedBox(height: 32),

                // --- DASHBOARD STATS ---
                const Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Courses',
                        stats['totalCourses'].toString(),
                        'Active',
                        const Color(0xFF6366F1),
                        Icons.book_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Groups',
                        stats['totalGroups'].toString(),
                        'Assigned',
                        const Color(0xFF10B981),
                        Icons.groups_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- ACTIVE ASSIGNMENTS ---
                const Text(
                  'My Active Assignments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                coursesAsync.when(
                  data: (courses) {
                    if (courses.isEmpty) {
                      return _buildEmptyAssignments();
                    }
                    return Column(
                      children: courses
                          .map((c) => _buildAssignmentCard(c))
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, __) =>
                      Center(child: Text('Error loading courses: $err')),
                ),

                const SizedBox(height: 32),

                // --- RECENT NOTIFICATIONS ---
                _buildRecentNotifications(context, recentNotifications),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    TeacherProfile? profile,
    WidgetRef ref,
    int unreadCount,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile?.firstName ?? 'Teacher',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TeacherNotificationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.grey,
                  ),
                  tooltip: 'Notifications',
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              onPressed: () {
                ref.read(authServiceProvider).logout();
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.grey),
              tooltip: 'Logout',
            ),
            const SizedBox(width: 8),
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[200]!, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Colors.grey,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(TeacherCourseAssignment assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.class_rounded,
              color: Color(0xFF6366F1),
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.courseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        assignment.courseCode,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Group: ${assignment.groupName}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildRecentNotifications(
    BuildContext context,
    List<TeacherAppNotification> notifications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherNotificationsScreen(),
                  ),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(color: Color(0xFF6366F1)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (notifications.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: const Center(
              child: Text(
                'No recent notifications',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...notifications.map((n) => _buildRecentNotificationItem(n)),
      ],
    );
  }

  Widget _buildRecentNotificationItem(TeacherAppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: notification.isRead
              ? Colors.grey[100]!
              : const Color(0xFFC7D2FE),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFF6366F1),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAssignments() {
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No Course Assignments',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t been assigned to any courses yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
