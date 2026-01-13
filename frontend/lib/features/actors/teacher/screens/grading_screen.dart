import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'grading_providers.dart';
import 'teacher_providers.dart';

class GradingScreen extends ConsumerStatefulWidget {
  final TeacherCourseAssignment assignment;
  const GradingScreen({super.key, required this.assignment});

  @override
  ConsumerState<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends ConsumerState<GradingScreen> {
  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(
      studentsInCourseGradingProvider(widget.assignment.id),
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
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.assignment.groupName} • Grade Entry',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: studentsAsync.when(
        data: (students) => _buildStudentList(students),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStudentList(List<GradingStudent> students) {
    if (students.isEmpty) {
      return const Center(child: Text('No students found in this course.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildGradeCard(students[index]),
    );
  }

  Widget _buildGradeCard(GradingStudent student) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(
                    0xFF6366F1,
                  ).withValues(alpha: 0.1),
                  child: Text(
                    student.name[0],
                    style: const TextStyle(color: Color(0xFF6366F1)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        student.studentId,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (student.average != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getAverageColor(
                        student.average!,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Avg: ${student.average!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _getAverageColor(student.average!),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildGradeField(
                  'TD',
                  student.tdMark,
                  (val) => _updateMark(student, 'TD', val),
                ),
                const SizedBox(width: 12),
                _buildGradeField(
                  'TP',
                  student.tpMark,
                  (val) => _updateMark(student, 'TP', val),
                ),
                const SizedBox(width: 12),
                _buildGradeField(
                  'Exam',
                  student.examMark,
                  (val) => _updateMark(student, 'Exam', val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeField(
    String label,
    double? value,
    Function(double?) onChanged,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _showEditDialog(label, value, onChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Text(
                  value?.toStringAsFixed(2) ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAverageColor(double average) {
    if (average >= 10) return Colors.green;
    return Colors.red;
  }

  void _showEditDialog(
    String label,
    double? currentValue,
    Function(double?) onSave,
  ) {
    final controller = TextEditingController(
      text: currentValue?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit $label Mark',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a value between 0.00 and 20.00',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  prefixIcon: const Icon(
                    Icons.edit_note,
                    color: Color(0xFF6366F1),
                  ),
                  hintText: '0.00',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF6366F1),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final val = double.tryParse(controller.text);
                        if (val != null && (val < 0 || val > 20)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mark must be between 0 and 20'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        onSave(val);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateMark(
    GradingStudent student,
    String type,
    double? newValue,
  ) async {
    final service = ref.read(gradingServiceProvider);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await service.updateGrade(
        gradeId: student.gradeId,
        tdMark: type == 'TD' ? newValue : student.tdMark,
        tpMark: type == 'TP' ? newValue : student.tpMark,
        examMark: type == 'Exam' ? newValue : student.examMark,
      );

      // Refresh data
      ref.invalidate(studentsInCourseGradingProvider(widget.assignment.id));

      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$type mark updated for ${student.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update mark: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
