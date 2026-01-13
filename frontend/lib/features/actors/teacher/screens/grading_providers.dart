import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/grading_service.dart';

class GradingStudent {
  final int gradeId;
  final int userId;
  final String name;
  final String studentId;
  final double? tdMark;
  final double? tpMark;
  final double? examMark;
  final double? average;
  final String comments;

  GradingStudent({
    required this.gradeId,
    required this.userId,
    required this.name,
    required this.studentId,
    this.tdMark,
    this.tpMark,
    this.examMark,
    this.average,
    required this.comments,
  });

  factory GradingStudent.fromJson(Map<String, dynamic> json) {
    return GradingStudent(
      gradeId: json['id'] ?? 0,
      userId: json['student'] ?? 0,
      name: json['student_name'] ?? 'Unknown Student',
      studentId: json['student_id'] ?? '',
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
      comments: json['comments'] ?? '',
    );
  }

  // To avoid naming confusion with backend 'exam_mark' but frontend 'examMark'
  GradingStudent copyWith({
    double? tdMark,
    double? tpMark,
    double? examMark,
    String? comments,
  }) {
    return GradingStudent(
      gradeId: gradeId,
      userId: userId,
      name: name,
      studentId: studentId,
      tdMark: tdMark ?? this.tdMark,
      tpMark: tpMark ?? this.tpMark,
      examMark: examMark ?? this.examMark,
      average: average, // Typically calculated by backend
      comments: comments ?? this.comments,
    );
  }
}

final gradingServiceProvider = Provider((ref) => GradingService());

final studentsInCourseGradingProvider =
    FutureProvider.family<List<GradingStudent>, int>((ref, assignmentId) async {
      final service = ref.read(gradingServiceProvider);
      final data = await service.getCourseStudents(assignmentId);
      return data.map((json) => GradingStudent.fromJson(json)).toList();
    });

// A state provider to hold the currently being edited marks
final gradingMarkingProvider = StateProvider.family<List<GradingStudent>, int>((
  ref,
  assignmentId,
) {
  final studentsAsync = ref.watch(
    studentsInCourseGradingProvider(assignmentId),
  );
  return studentsAsync.when(
    data: (students) => students,
    loading: () => [],
    error: (_, __) => [],
  );
});
