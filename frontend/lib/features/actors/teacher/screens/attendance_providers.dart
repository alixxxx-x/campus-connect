import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/attendance_service.dart';

// ==================== Data Model ====================

class AttendanceStudent {
  final int id;
  final int userId;
  final String studentId;
  final String name;
  String status; // 'PRESENT', 'ABSENT', 'LATE'
  String? notes;

  AttendanceStudent({
    required this.id,
    required this.userId,
    required this.studentId,
    required this.name,
    this.status = 'PRESENT',
    this.notes,
  });

  factory AttendanceStudent.fromGradeJson(Map<String, dynamic> json) {
    return AttendanceStudent(
      id: json['id'], // Grade ID, but we mainly need userId/studentId
      userId: json['student'],
      studentId: json['student_id'] ?? 'N/A',
      name: json['student_name'] ?? 'Unknown Student',
    );
  }

  AttendanceStudent copyWith({String? status, String? notes}) {
    return AttendanceStudent(
      id: id,
      userId: userId,
      studentId: studentId,
      name: name,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

// ==================== Providers ====================

final attendanceServiceProvider = Provider((ref) => AttendanceService());

// Simplified state for marking attendance
final attendanceMarkingProvider =
    StateProvider.family<List<AttendanceStudent>, int>((ref, courseId) {
      return []; // Initial empty list, will be populated by a fetcher
    });

final studentsInCourseProvider =
    FutureProvider.family<List<AttendanceStudent>, int>((ref, courseId) async {
      final service = ref.read(attendanceServiceProvider);
      final json = await service.getStudentsInCourse(courseId);
      final students = json
          .map((s) => AttendanceStudent.fromGradeJson(s))
          .toList();

      // Also update the state provider for interactive marking
      ref.read(attendanceMarkingProvider(courseId).notifier).state = students;

      return students;
    });
