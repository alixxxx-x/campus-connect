import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'student_providers.dart';

class StudentGradesTab extends ConsumerWidget {
  const StudentGradesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradesAsync = ref.watch(studentGradesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'My Grades',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentGradesProvider);
          await ref.read(studentGradesProvider.future);
        },
        child: gradesAsync.when(
          data: (grades) {
            if (grades.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: grades.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final grade = grades[index];
                return _buildGradeCard(grade);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                TextButton(
                  onPressed: () => ref.refresh(studentGradesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No grades recorded yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(Grade grade) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header: Code, Name, Average
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF), // Indigo 50
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          grade.courseCode,
                          style: const TextStyle(
                            color: Color(0xFF6366F1), // Indigo 500
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        grade.courseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getAverageColor(grade.average),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        grade.average?.toStringAsFixed(2) ?? '--',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'AVG',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            // Details: TD, TP, Exam
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMarkColumn('TD', grade.tdMark),
                _buildMarkColumn('TP', grade.tpMark),
                _buildMarkColumn('Exam', grade.examMark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkColumn(String label, double? mark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          mark?.toStringAsFixed(1) ?? '--',
          style: TextStyle(
            color: mark != null ? const Color(0xFF374151) : Colors.grey[300],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getAverageColor(double? average) {
    if (average == null) return Colors.grey;
    if (average >= 15) return const Color(0xFF10B981); // Green
    if (average >= 10) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }
}
