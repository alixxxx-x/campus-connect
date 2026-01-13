import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'attendance_providers.dart';
import 'teacher_providers.dart';

class AttendanceMarkingScreen extends ConsumerStatefulWidget {
  final TeacherCourseAssignment assignment;
  const AttendanceMarkingScreen({super.key, required this.assignment});

  @override
  ConsumerState<AttendanceMarkingScreen> createState() =>
      _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState
    extends ConsumerState<AttendanceMarkingScreen> {
  int weekNumber = 1;

  @override
  void initState() {
    super.initState();
    // Fetch existing attendance after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchExistingAttendance();
    });
  }

  Future<void> _fetchExistingAttendance() async {
    final service = ref.read(attendanceServiceProvider);

    // 1. Reset state to default (everything PRESENT) before fetching
    final notifier = ref.read(
      attendanceMarkingProvider(widget.assignment.id).notifier,
    );

    // Wait for studentsInCourseProvider to have data
    final studentsInCourse = ref.read(
      studentsInCourseProvider(widget.assignment.id),
    );

    studentsInCourse.whenData((students) {
      // Reset all to PRESENT
      notifier.state = students
          .map((s) => s.copyWith(status: 'PRESENT'))
          .toList();

      // 2. Fetch from backend
      service
          .getExistingAttendance(widget.assignment.courseId, weekNumber)
          .then((existing) {
            if (existing.isNotEmpty) {
              final currentStudents = notifier.state;
              final updatedStudents = currentStudents.map((s) {
                final record = existing.firstWhere(
                  (r) => r['student'] == s.userId,
                  orElse: () => null,
                );
                if (record != null) {
                  return s.copyWith(
                    status: record['status'],
                    notes: record['notes'],
                  );
                }
                return s;
              }).toList();

              notifier.state = updatedStudents;
            }
          })
          .catchError((e) {
            debugPrint('Error fetching existing attendance: $e');
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(
      studentsInCourseProvider(widget.assignment.id),
    );
    final markingList = ref.watch(
      attendanceMarkingProvider(widget.assignment.id),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.assignment.courseName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Group: ${widget.assignment.groupName}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton.icon(
            onPressed: markingList.isEmpty ? null : _saveAttendance,
            icon: const Icon(Icons.save_rounded, color: Color(0xFF6366F1)),
            label: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: studentsAsync.when(
        data: (_) => _buildContent(markingList),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildContent(List<AttendanceStudent> students) {
    return Column(
      children: [
        _buildControls(),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildStudentTile(students[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: weekNumber,
            isExpanded: true,
            hint: const Text('Select Week'),
            items: List.generate(15, (i) => i + 1)
                .map(
                  (w) => DropdownMenuItem(
                    value: w,
                    child: Text('Academic Week $w'),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() => weekNumber = val!);
              _fetchExistingAttendance();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStudentTile(AttendanceStudent student) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
              child: Text(
                student.name[0],
                style: const TextStyle(color: Color(0xFF6366F1)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    student.studentId,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            _buildStatusToggle(student),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusToggle(AttendanceStudent student) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statusButton(
          student,
          'PRESENT',
          Colors.green,
          Icons.check_circle_outline_rounded,
        ),
        const SizedBox(width: 8),
        _statusButton(student, 'ABSENT', Colors.red, Icons.cancel_outlined),
        const SizedBox(width: 8),
        _statusButton(
          student,
          'LATE',
          Colors.orange,
          Icons.access_time_rounded,
        ),
      ],
    );
  }

  Widget _statusButton(
    AttendanceStudent student,
    String status,
    Color color,
    IconData icon,
  ) {
    final isSelected = student.status == status;
    return InkWell(
      onTap: () => _updateStudentStatus(student, status),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.grey[200]!),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }

  void _updateStudentStatus(AttendanceStudent student, String status) {
    final notifier = ref.read(
      attendanceMarkingProvider(widget.assignment.id).notifier,
    );
    notifier.state = [
      for (final s in notifier.state)
        if (s.userId == student.userId) s.copyWith(status: status) else s,
    ];
  }

  Future<void> _saveAttendance() async {
    final service = ref.read(attendanceServiceProvider);
    final markingList = ref.read(
      attendanceMarkingProvider(widget.assignment.id),
    );

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Prepare bulk data (no date used now, weekNumber is primary)
      final records = markingList
          .map(
            (s) => {
              'student': s.userId,
              'course': widget.assignment.courseId,
              'week_number': weekNumber,
              'status': s.status,
              'notes': s.notes ?? '',
            },
          )
          .toList();

      await service.bulkMarkAttendance(records);

      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved successfully')),
        );
        Navigator.pop(context); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
