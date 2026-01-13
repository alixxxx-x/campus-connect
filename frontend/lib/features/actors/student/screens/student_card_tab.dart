import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'student_providers.dart';

class StudentCardTab extends ConsumerWidget {
  const StudentCardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(studentFreshProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Student ID Card',
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
          ref.invalidate(studentFreshProfileProvider);
          await ref.read(studentFreshProfileProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: profileAsync.when(
            data: (profile) {
              if (profile == null) return _buildErrorState(ref);
              return Column(
                children: [
                  _buildDigitalIDCard(profile),
                  const SizedBox(height: 48),
                  _buildSecurityNotice(),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => _buildErrorState(ref),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalIDCard(StudentProfile profile) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.58, // Standard credit card ratio
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  right: -40,
                  top: -40,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Card Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Logo and Contactless
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'CAMPUS CONNECT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.contactless_outlined,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Middle Section: Chip and Photo
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Golden Chip
                          Container(
                            width: 40,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    width: 30,
                                    height: 1,
                                    color: Colors.black12,
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 1,
                                    height: 20,
                                    color: Colors.black12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Program and Group Info (Small Labels)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PROGRAM: ${profile.program ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'GROUP: ${profile.groupName ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Small Photo Placeholder on Card
                          Container(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                profile.firstName.isNotEmpty
                                    ? profile.firstName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white24,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Student ID (Credit Card Style)
                      Text(
                        profile.studentId != null
                            ? profile.studentId!
                                  .toString()
                                  .padLeft(16, '0')
                                  .replaceAllMapped(
                                    RegExp(r".{4}"),
                                    (match) => "${match.group(0)} ",
                                  )
                            : '0000 0000 0000 0000',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Courier',
                          letterSpacing: 2,
                        ),
                      ),

                      const Spacer(),

                      // Bottom Row: Name, Role, Validity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STUDENT NAME',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.fullName.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'ROLE',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.role,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'VALID THRU',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '06/26',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'This digital ID is official. Use the QR code at campus gates or the library for quick access.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load card data'),
          TextButton(
            onPressed: () => ref.refresh(studentFreshProfileProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
