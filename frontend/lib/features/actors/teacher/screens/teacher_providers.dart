import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/teacher_service.dart';
import '../../../../shared/providers/auth_provider.dart';

// ==================== Data Models ====================

class TeacherProfile {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String role;
  final String? email;
  final String? phone;
  final String? address;
  final String? birthDate;

  TeacherProfile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.email,
    this.phone,
    this.address,
    this.birthDate,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'TEACHER',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      birthDate: json['birth_date'],
    );
  }
}

class TeacherScheduleSession {
  final int id;
  final String day;
  final String startTime;
  final String endTime;
  final String room;
  final String type;

  TeacherScheduleSession({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.type,
  });

  factory TeacherScheduleSession.fromJson(Map<String, dynamic> json) {
    return TeacherScheduleSession(
      id: json['id'] is int ? json['id'] : 0,
      day: json['day'] ?? 'MONDAY',
      startTime: json['start_time'] ?? '00:00:00',
      endTime: json['end_time'] ?? '00:00:00',
      room: json['room'] ?? 'N/A',
      type: json['session_type'] ?? 'LECTURE',
    );
  }

  String get formattedStartTime => startTime.split(':').take(2).join(':');
  String get formattedEndTime => endTime.split(':').take(2).join(':');
}

class TeacherCourseAssignment {
  final int id;
  final int courseId;
  final String courseCode;
  final String courseName;
  final String groupName;
  final int groupId;
  final List<TeacherScheduleSession> sessions;

  TeacherCourseAssignment({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.groupName,
    required this.groupId,
    required this.sessions,
  });

  factory TeacherCourseAssignment.fromJson(Map<String, dynamic> json) {
    var sessionList = json['sessions'] as List? ?? [];
    return TeacherCourseAssignment(
      id: json['id'] is int ? json['id'] : 0,
      courseId: json['course'] is int ? json['course'] : 0,
      courseCode: json['course_code'] ?? '',
      courseName: json['course_name'] ?? '',
      groupName: json['group_name'] ?? '',
      groupId: json['group_id'] is int
          ? json['group_id']
          : int.tryParse(json['group_id'].toString()) ?? 0,
      sessions: sessionList
          .map(
            (s) => TeacherScheduleSession.fromJson(s as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

// ==================== Providers ====================

final teacherServiceProvider = Provider((ref) => TeacherService());

final teacherProfileProvider = Provider<TeacherProfile?>((ref) {
  final appUser = ref.watch(authProvider);
  if (appUser == null) return null;
  return TeacherProfile.fromJson(appUser.toJson());
});

final teacherFreshProfileProvider = FutureProvider<TeacherProfile?>((
  ref,
) async {
  final service = ref.read(teacherServiceProvider);
  final json = await service.getProfile();
  return TeacherProfile.fromJson(json);
});

final teacherCoursesProvider = FutureProvider<List<TeacherCourseAssignment>>((
  ref,
) async {
  final service = ref.read(teacherServiceProvider);
  final data = await service.getMyCourses();
  return data.map((json) => TeacherCourseAssignment.fromJson(json)).toList();
});

final teacherStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final coursesAsync = ref.watch(teacherCoursesProvider);

  return coursesAsync.when(
    data: (courses) {
      final uniqueCourses = courses.map((c) => c.courseCode).toSet().length;
      final uniqueGroups = courses.map((c) => c.groupName).toSet().length;

      return {
        'totalCourses': uniqueCourses,
        'totalGroups': uniqueGroups,
        'totalAssignments': courses.length,
      };
    },
    loading: () => {'totalCourses': 0, 'totalGroups': 0, 'totalAssignments': 0},
    error: (_, __) => {
      'totalCourses': 0,
      'totalGroups': 0,
      'totalAssignments': 0,
    },
  );
});
