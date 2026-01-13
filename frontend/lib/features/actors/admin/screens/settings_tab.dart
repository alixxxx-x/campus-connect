import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/providers/auth_provider.dart';
import 'admin_style.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  static const primaryBlue = Color(0xFF4A80F0);

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(adminSettingsProvider);
    final settingsNotifier = ref.read(adminSettingsProvider.notifier);
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        children: [
          _buildHeading('Account Identity'),
          _buildCard(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminStyle.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AdminStyle.primary,
                  size: 22,
                ),
              ),
              title: Text(
                user?.name ?? 'Admin Authority',
                style: AdminStyle.subHeader.copyWith(fontSize: 15),
              ),
              subtitle: Text(
                user?.email ?? 'admin@campus.edu',
                style: AdminStyle.body.copyWith(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.verified_rounded,
                color: Colors.green,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 32),

          _buildHeading('System Preferences'),
          _buildCard(
            child: Column(
              children: [
                _buildToggle(
                  'Push Notifications',
                  'Real-time alerts for system events',
                  settings.pushNotifications,
                  (v) {
                    settingsNotifier.togglePushNotifications();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'Push notifications enabled'
                              : 'Push notifications disabled',
                        ),
                        backgroundColor: AdminStyle.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 60),
                _buildToggle(
                  'Cloud Sync',
                  'Automatic data backup to cloud',
                  settings.cloudSync,
                  (v) {
                    settingsNotifier.toggleCloudSync();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          v ? 'Cloud sync enabled' : 'Cloud sync disabled',
                        ),
                        backgroundColor: AdminStyle.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 60),
                _buildToggle(
                  'New Student Alerts',
                  'Notify when students register',
                  settings.newStudentAlerts,
                  (v) {
                    settingsNotifier.toggleNewStudentAlerts();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'Student alerts enabled'
                              : 'Student alerts disabled',
                        ),
                        backgroundColor: AdminStyle.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildHeading('Quick Actions'),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.blue,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'System Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'View app version and details',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () => _showSystemInfo(),
                ),
                const Divider(height: 1, indent: 60),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Colors.purple,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Help & Support',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Get assistance and documentation',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () => _showHelp(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          _buildActionCard(
            'Secure Sign Out',
            'Disconnect current admin session',
            Icons.power_settings_new_rounded,
            Colors.red[400]!,
            () => _confirmLogout(),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authServiceProvider).logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showSystemInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AdminStyle.primary),
            SizedBox(width: 12),
            Text(
              'System Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('App Name', 'Campus Connect'),
            _buildInfoRow('Version', '1.0.0'),
            _buildInfoRow('Platform', 'Flutter'),
            _buildInfoRow('Role', 'Administrator'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Colors.purple),
            SizedBox(width: 12),
            Text(
              'Help & Support',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '• Manage courses and groups from the Courses tab\n'
              '• Approve students from the Users tab\n'
              '• Create schedules from the Schedule tab\n'
              '• Message users from the Messages tab',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: AdminStyle.subHeader.copyWith(
          fontSize: 14,
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildToggle(
    String title,
    String subtitle,
    bool val,
    Function(bool)? onChanged,
  ) {
    return SwitchListTile(
      value: val,
      onChanged: onChanged,
      activeColor: primaryBlue,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withAlpha(26)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: color.withAlpha(178), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
