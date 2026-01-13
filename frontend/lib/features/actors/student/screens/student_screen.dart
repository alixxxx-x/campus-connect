import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'student_overview_tab.dart';
import 'student_schedule_tab.dart';
import 'student_courses_tab.dart';
import 'student_grades_tab.dart';
import 'student_profile_tab.dart';
import 'student_card_tab.dart';
import 'student_messages_tab.dart';

class StudentScreen extends ConsumerStatefulWidget {
  const StudentScreen({super.key});

  @override
  ConsumerState<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends ConsumerState<StudentScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const StudentOverviewTab(),
    const StudentMessagesTab(),
    const StudentScheduleTab(),
    const StudentCoursesTab(),
    const StudentGradesTab(),
    const StudentProfileTab(),
    const StudentCardTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: const Color(0xFF6366F1), // Indigo
              unselectedItemColor: Colors.grey[400],
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Overview',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  activeIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today_rounded),
                  label: 'Schedule',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_outlined),
                  activeIcon: Icon(Icons.book_rounded),
                  label: 'Courses',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'Grades',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.badge_outlined),
                  activeIcon: Icon(Icons.badge_rounded),
                  label: 'ID Card',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
