import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'teacher_providers.dart';
import '../../../../shared/services/auth_service.dart';

class TeacherProfileTab extends ConsumerWidget {
  const TeacherProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(teacherFreshProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authServiceProvider).logout();
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teacherFreshProfileProvider);
          await ref.read(teacherFreshProfileProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: profileAsync.when(
            data: (profile) {
              if (profile == null) return _buildErrorState(ref);
              return Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar and Name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              profile.firstName.isNotEmpty
                                  ? profile.firstName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${profile.username}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Info Cards
                  _buildInfoSection('Teacher Info', [
                    _buildInfoTile(Icons.person_outline, 'Role', profile.role),
                    _buildInfoTile(
                      Icons.email_outlined,
                      'Email',
                      profile.email ?? 'N/A',
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildInfoSection('Personal Details', [
                    _buildInfoTile(
                      Icons.phone_outlined,
                      'Phone',
                      profile.phone ?? 'N/A',
                    ),
                    _buildInfoTile(
                      Icons.location_on_outlined,
                      'Address',
                      profile.address ?? 'N/A',
                    ),
                    _buildInfoTile(
                      Icons.cake_outlined,
                      'Birth Date',
                      profile.birthDate ?? 'N/A',
                    ),
                  ]),
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

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load profile'),
          TextButton(
            onPressed: () => ref.refresh(teacherFreshProfileProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF4B5563)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
