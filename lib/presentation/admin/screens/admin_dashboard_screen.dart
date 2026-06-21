import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/firestore_service.dart';
import '../../../providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text('Admin Panel',
                          style: TextStyle(color: Colors.white, fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Manage doctors, patients, and appointments.',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            const Text('Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, int>>(
              future: ref.read(firestoreServiceProvider).getAdminStats(),
              builder: (context, snap) {
                final stats = snap.data ?? {'patients': 0, 'doctors': 0, 'appointments': 0, 'completed': 0};
                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StatCard(
                      value: '${stats['patients']}',
                      label: 'Total Patients',
                      icon: Icons.people_rounded,
                      color: AppTheme.primaryBlue,
                    ),
                    _StatCard(
                      value: '${stats['doctors']}',
                      label: 'Total Doctors',
                      icon: Icons.medical_services_rounded,
                      color: AppTheme.accentTeal,
                    ),
                    _StatCard(
                      value: '${stats['appointments']}',
                      label: 'Appointments',
                      icon: Icons.calendar_today_rounded,
                      color: AppTheme.warningOrange,
                    ),
                    _StatCard(
                      value: '${stats['completed']}',
                      label: 'Completed',
                      icon: Icons.check_circle_rounded,
                      color: AppTheme.successGreen,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text('Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.medical_services_rounded,
              title: 'Manage Doctors',
              subtitle: 'View, verify, and manage doctors',
              color: AppTheme.primaryBlue,
              onTap: () => context.push('/manage-doctors'),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.people_rounded,
              title: 'Manage Patients',
              subtitle: 'View and manage patient records',
              color: AppTheme.accentTeal,
              onTap: () => context.push('/patient-records'),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.calendar_month_rounded,
              title: 'All Appointments',
              subtitle: 'Monitor all bookings',
              color: AppTheme.warningOrange,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.notifications_rounded,
              title: 'Send Notification',
              subtitle: 'Broadcast messages to users',
              color: AppTheme.successGreen,
              onTap: () {},
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textGrey),
          ],
        ),
      ),
    );
  }
}
