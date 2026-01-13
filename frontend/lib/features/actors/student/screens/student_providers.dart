import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/student_service.dart';
import '../../../../shared/providers/auth_provider.dart';

// ==================== Data Models ====================

class StudentProfile {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String role;
  final String? studentId;
  final String? program;
  final String? groupName;

  StudentProfile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.studentId,
    this.program,
    this.groupName,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'STUDENT',
      studentId: json['student_id'],
      program: json['program'],
      groupName: json['group_name'],
    );
  }
}

class Grade {
  final String courseCode;
  final String courseName;
  final double? tdMark;
  final double? tpMark;
  final double? examMark;
  final double? average;

  Grade({
    required this.courseCode,
    required this.courseName,
    this.tdMark,
    this.tpMark,
    this.examMark,
    this.average,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      courseCode: json['course_code'] ?? '',
      courseName: json['course_name'] ?? '',
      tdMark: json['td_mark'] != null
          ? double.tryParse(json['td_mark'].toString())
          : null,
      tpMark: json['tp_mark'] != null
          ? double.tryParse(json['tp_mark'].toString())
          : null,
      examMark: json['exam_mark'] != null
          ? double.tryParse(json['exam_mark'].toString())
          : null,
      average: json['average'] != null
          ? double.tryParse(json['average'].toString())
          : null,
    );
  }
}

class AttendanceRecord {
  final String status;

  AttendanceRecord({required this.status});

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(status: json['status'] ?? 'PRESENT');
  }
}

class ScheduleSession {
  final int id;
  final String day;
  final String startTime;
  final String endTime;
  final String room;
  final String type;

  ScheduleSession({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.type,
  });

  factory ScheduleSession.fromJson(Map<String, dynamic> json) {
    return ScheduleSession(
      id: json['id'] is int ? json['id'] : 0,
      day: json['day'] ?? 'MONDAY',
      startTime: json['start_time'] ?? '00:00:00',
      endTime: json['end_time'] ?? '00:00:00',
      room: json['room'] ?? 'N/A',
      type: json['session_type'] ?? 'LECTURE',
    );
  }

  // Helper to format time (08:30:00 -> 08:30)
  String get formattedStartTime => startTime.split(':').take(2).join(':');
  String get formattedEndTime => endTime.split(':').take(2).join(':');
}

class CourseAssignment {
  final int id;
  final String courseCode;
  final String courseName;
  final String teacherName;
  final List<ScheduleSession> sessions;

  CourseAssignment({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.teacherName,
    required this.sessions,
  });

  factory CourseAssignment.fromJson(Map<String, dynamic> json) {
    var sessionList = json['sessions'] as List? ?? [];
    return CourseAssignment(
      id: json['id'],
      courseCode: json['course_code'] ?? '',
      courseName: json['course_name'] ?? '',
      teacherName: json['teacher_name'] ?? 'Unknown Teacher',
      sessions: sessionList
          .map((s) => ScheduleSession.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ==================== Providers ====================

final studentServiceProvider = Provider((ref) => StudentService());

final studentProfileProvider = Provider<StudentProfile?>((ref) {
  final appUser = ref.watch(authProvider);
  if (appUser == null) {
    return null;
  }
  return StudentProfile.fromJson(appUser.toJson());
});

final studentGradesProvider = FutureProvider<List<Grade>>((ref) async {
  final service = ref.read(studentServiceProvider);
  final data = await service.getMyGrades();
  return data.map((json) => Grade.fromJson(json)).toList();
});

final studentAttendanceProvider = FutureProvider<List<AttendanceRecord>>((
  ref,
) async {
  final service = ref.read(studentServiceProvider);
  final data = await service.getMyAttendance();
  return data.map((json) => AttendanceRecord.fromJson(json)).toList();
});

final studentCoursesProvider = FutureProvider<List<CourseAssignment>>((
  ref,
) async {
  final service = ref.read(studentServiceProvider);
  final data = await service.getMyCourses();
  return data.map((json) => CourseAssignment.fromJson(json)).toList();
});

final studentFreshProfileProvider = FutureProvider<StudentProfile?>((
  ref,
) async {
  final service = ref.read(studentServiceProvider);
  final json = await service.getProfile();
  if (json == null) return null;
  return StudentProfile.fromJson(json);
});
