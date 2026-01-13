import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'student_providers.dart';

class StudentScheduleTab extends ConsumerWidget {
  const StudentScheduleTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(studentCoursesProvider);

    // Get current day in UPPERCASE (e.g., "MONDAY")
    final String today = DateFormat(
      'EEEE',
    ).format(DateTime.now()).toUpperCase();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(studentCoursesProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildHeader(context, today),
            coursesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error loading schedule: $err')),
              ),
              data: (assignments) {
                // Flat list of sessions for today
                final todaySessions = assignments
                    .expand(
                      (a) => a.sessions.map((s) => _SessionWithCourse(a, s)),
                    )
                    .where((item) => item.session.day == today)
                    .toList();

                // Sort by start time
                todaySessions.sort(
                  (a, b) => a.session.startTime.compareTo(b.session.startTime),
                );

                if (todaySessions.isEmpty) {
                  return _buildEmptyState();
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildTimelineStep(
                        context,
                        todaySessions[index],
                        isLast: index == todaySessions.length - 1,
                      );
                    }, childCount: todaySessions.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String today) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODAY\'S SCHEDULE',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 64,
                color: Colors.indigo[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No classes today!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enjoy your free time or catch up on studies.",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context,
    _SessionWithCourse item, {
    bool isLast = false,
  }) {
    final session = item.session;
    final assignment = item.assignment;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time sidebar
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  session.formattedStartTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  session.formattedEndTime,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Stepper Line and Dot
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.indigo[100]!, width: 4),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: Colors.indigo[100])),
            ],
          ),

          const SizedBox(width: 20),

          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(session.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            session.type,
                            style: TextStyle(
                              color: _getTypeColor(session.type),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Colors.indigo[300],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              session.room,
                              style: TextStyle(
                                color: Colors.indigo[300],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      assignment.courseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment.teacherName,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'LECTURE':
        return Colors.blue;
      case 'LAB':
        return Colors.green;
      case 'TUTORIAL':
        return Colors.amber[700]!;
      default:
        return Colors.indigo;
    }
  }
}

class _SessionWithCourse {
  final CourseAssignment assignment;
  final ScheduleSession session;

  _SessionWithCourse(this.assignment, this.session);
}
