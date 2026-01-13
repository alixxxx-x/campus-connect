import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/auth_service.dart';
import 'student_providers.dart';
import 'notification_providers.dart';
import 'notifications_screen.dart';

class StudentOverviewTab extends ConsumerWidget {
  const StudentOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch Data Providers
    final freshProfileAsync = ref.watch(studentFreshProfileProvider);
    final gradesAsync = ref.watch(studentGradesProvider);
    final attendanceAsync = ref.watch(studentAttendanceProvider);
    final recentNotifications = ref.watch(recentNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Soft gray background
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh data from backend
            await Future.wait([
              ref.refresh(studentGradesProvider.future),
              ref.refresh(studentAttendanceProvider.future),
              ref.refresh(studentFreshProfileProvider.future),
              ref.refresh(notificationsProvider.future),
            ]);
            // Note: refresh returns a Future, so we wait for it.
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER SECTION ---
                freshProfileAsync.when(
                  data: (profile) =>
                      _buildHeader(context, profile, ref, unreadCount),
                  loading: () => const Center(child: LinearProgressIndicator()),
                  error: (_, __) => _buildHeader(context, null, ref, 0),
                ),

                const SizedBox(height: 32),

                // --- ACADEMIC STATS ---
                const Text(
                  'Academic Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    // GPA/Average Card
                    Expanded(
                      child: gradesAsync.when(
                        data: (grades) {
                          final validGrades = grades
                              .where((g) => g.average != null)
                              .toList();
                          final avg = validGrades.isNotEmpty
                              ? validGrades
                                        .map((g) => g.average!)
                                        .reduce((a, b) => a + b) /
                                    validGrades.length
                              : 0.0;
                          return _buildStatCard(
                            'Average Grade',
                            avg.toStringAsFixed(2),
                            '/20',
                            const Color(0xFF6366F1), // Indigo
                            Icons.insights_rounded,
                          );
                        },
                        loading: () => _buildLoadingCard(),
                        error: (_, __) => _buildStatCard(
                          'Average',
                          '--',
                          '',
                          Colors.grey,
                          Icons.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Attendance Card
                    Expanded(
                      child: attendanceAsync.when(
                        data: (records) {
                          final total = records.length;
                          final present = records
                              .where((r) => r.status == 'PRESENT')
                              .length;
                          final percentage = total > 0
                              ? ((present / total) * 100).toInt()
                              : 0;
                          return _buildStatCard(
                            'Attendance',
                            '$percentage%',
                            'Present',
                            const Color(0xFF10B981), // Emerald
                            Icons.check_circle_rounded,
                          );
                        },
                        loading: () => _buildLoadingCard(),
                        error: (_, __) => _buildStatCard(
                          'Attendance',
                          '--',
                          '',
                          Colors.grey,
                          Icons.error,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- QUICK STATUS / INFO ---
                freshProfileAsync.when(
                  data: (profile) => _buildInfoCard(profile),
                  loading: () => _buildLoadingCard(),
                  error: (_, __) => const SizedBox.shrink(),
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
    StudentProfile? profile,
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
                profile?.firstName ?? 'Student',
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
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.grey,
                    size: 28,
                  ),
                  tooltip: 'Notifications',
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                // Using AuthService for logout
                ref.read(authServiceProvider).logout();
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.grey),
              tooltip: 'Logout',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentNotifications(
    BuildContext context,
    List<AppNotification> notifications,
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
                    builder: (context) => const NotificationsScreen(),
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

  Widget _buildRecentNotificationItem(AppNotification notification) {
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

  Widget _buildLoadingCard() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildInfoCard(StudentProfile? profile) {
    if (profile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Student ID',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile.groupName ?? 'No Group',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            profile.studentId ?? 'Not Assigned',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROGRAM',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.program ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
