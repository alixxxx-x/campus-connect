import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'teacher_overview_tab.dart';

import 'teacher_messages_tab.dart';

import 'teacher_profile_tab.dart';

import 'teacher_schedule_tab.dart';

import 'teacher_attendance_tab.dart';
import 'teacher_grading_tab.dart';

class TeacherScreen extends ConsumerStatefulWidget {
  const TeacherScreen({super.key});

  @override
  ConsumerState<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends ConsumerState<TeacherScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const TeacherOverviewTab(),
    const TeacherAttendanceTab(),
    const TeacherGradingTab(),
    const TeacherScheduleTab(),
    const TeacherMessagesTab(),
    const TeacherProfileTab(),
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
              color: Colors.black.withValues(alpha: 0.05),
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
              selectedItemColor: const Color(0xFF6366F1),
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
                  icon: Icon(Icons.check_circle_outline_rounded),
                  activeIcon: Icon(Icons.check_circle_rounded),
                  label: 'Attendance',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grade_outlined),
                  activeIcon: Icon(Icons.grade_rounded),
                  label: 'Grades',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today_rounded),
                  label: 'Schedule',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  activeIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
