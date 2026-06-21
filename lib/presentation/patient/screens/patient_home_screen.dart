import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/services/firestore_service.dart';
import '../widgets/doctor_card.dart';

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> {
  int _currentIndex = 0;
  String? _selectedSpec;

  final List<Map<String, dynamic>> _specializations = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Cardiologist', 'icon': Icons.favorite_outlined},
    {'name': 'Dermatologist', 'icon': Icons.face_outlined},
    {'name': 'Neurologist', 'icon': Icons.psychology_outlined},
    {'name': 'Orthopedic', 'icon': Icons.accessibility_new_outlined},
    {'name': 'Pediatrician', 'icon': Icons.child_care_outlined},
    {'name': 'General Physician', 'icon': Icons.medical_services_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            selectedSpec: _selectedSpec,
            specializations: _specializations,
            onSpecChanged: (s) => setState(() => _selectedSpec = s),
            userAsync: userAsync,
          ),
          const _AppointmentsTab(),
          const _PrescriptionsTab(),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  final String? selectedSpec;
  final List<Map<String, dynamic>> specializations;
  final void Function(String?) onSpecChanged;
  final AsyncValue userAsync;

  const _HomeTab({
    required this.selectedSpec,
    required this.specializations,
    required this.onSpecChanged,
    required this.userAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(
      doctorsProvider(selectedSpec == 'All' ? null : selectedSpec),
    );

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            userAsync.when(
                              data: (user) => Text(
                                'Hello, ${user?.name.split(' ').first ?? 'Patient'} 👋',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              loading: () => const SizedBox(height: 28, width: 120,
                                  child: LinearProgressIndicator()),
                              error: (_, __) => const Text('Hello!'),
                            ),
                            const SizedBox(height: 4),
                            const Text('Find your doctor & book appointment',
                                style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: const Icon(Icons.notifications_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  GestureDetector(
                    onTap: () => context.push('/doctors'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: AppTheme.textGrey),
                          SizedBox(width: 10),
                          Text('Search doctors, specializations...',
                              style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Online Consultation',
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('Consult from home. Available 24/7.',
                                  style: TextStyle(color: Colors.white.withOpacity(0.85),
                                      fontSize: 12)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => context.push('/online-consultation'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Book Now', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.video_call_rounded, color: Colors.white, size: 64),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Actions
                  const Text('Quick Actions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickAction(icon: Icons.calendar_today_rounded,
                          label: 'My Appointments',
                          color: const Color(0xFFE8F5E9),
                          iconColor: AppTheme.successGreen,
                          onTap: () => context.push('/my-appointments')),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.receipt_long_rounded,
                          label: 'Prescriptions',
                          color: const Color(0xFFFFF3E0),
                          iconColor: AppTheme.warningOrange,
                          onTap: () => context.push('/prescriptions')),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.people_alt_rounded,
                          label: 'All Doctors',
                          color: AppTheme.lightBlue,
                          iconColor: AppTheme.primaryBlue,
                          onTap: () => context.push('/doctors')),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Specializations
                  const Text('Specializations',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Specialization chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: specializations.length,
                itemBuilder: (context, i) {
                  final spec = specializations[i];
                  final name = spec['name'] as String;
                  final isSelected = (selectedSpec == null && name == 'All') ||
                      selectedSpec == name;
                  return GestureDetector(
                    onTap: () => onSpecChanged(name == 'All' ? null : name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(spec['icon'] as IconData,
                              size: 14,
                              color: isSelected ? Colors.white : AppTheme.textGrey),
                          const SizedBox(width: 5),
                          Text(name,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected ? Colors.white : AppTheme.textGrey,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Available Doctors',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () => context.push('/doctors'),
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          // Doctor list
          doctorsAsync.when(
            data: (doctors) {
              final list = doctors as List<DoctorModel>;
              if (list.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No doctors found.',
                          style: TextStyle(color: AppTheme.textGrey)),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => DoctorCard(
                      doctor: list[i],
                      onTap: () => context.push('/doctor/${list[i].uid}'),
                    ),
                    childCount: list.length > 10 ? 10 : list.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon, required this.label,
    required this.color, required this.iconColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: iconColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentsTab extends ConsumerWidget {
  const _AppointmentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MyAppointmentsTabContent();
  }
}

class MyAppointmentsTabContent extends ConsumerWidget {
  const MyAppointmentsTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();
        return _AppointmentList(patientId: user.uid);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _AppointmentList extends ConsumerWidget {
  final String patientId;
  const _AppointmentList({required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apptAsync = ref.watch(patientAppointmentsProvider(patientId));
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: apptAsync.when(
        data: (appts) {
          if (appts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: AppTheme.textGrey),
                  SizedBox(height: 16),
                  Text('No appointments yet', style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appts.length,
            itemBuilder: (context, i) {
              final appt = appts[i];
              return _AppointmentTile(appointment: appt);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final dynamic appointment;
  const _AppointmentTile({required this.appointment});

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return AppTheme.successGreen;
      case 'pending': return AppTheme.warningOrange;
      case 'cancelled': return AppTheme.errorRed;
      case 'completed': return AppTheme.primaryBlue;
      default: return AppTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dr. ${appointment.doctorName}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(appointment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: _statusColor(appointment.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(appointment.doctorSpecialization,
              style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 13)),
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 6),
              Text(
                '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined, size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 6),
              Text(appointment.timeSlot,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
              const Spacer(),
              Icon(
                appointment.isOnline ? Icons.videocam_outlined : Icons.local_hospital_outlined,
                size: 14, color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 4),
              Text(appointment.isOnline ? 'Online' : 'In-Person',
                  style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrescriptionsTab extends ConsumerWidget {
  const _PrescriptionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();
        return _PrescriptionList(patientId: user.uid);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _PrescriptionList extends ConsumerWidget {
  final String patientId;
  const _PrescriptionList({required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presAsync = ref.watch(patientPrescriptionsProvider(patientId));
    return Scaffold(
      appBar: AppBar(title: const Text('My Prescriptions')),
      body: presAsync.when(
        data: (prescriptions) {
          if (prescriptions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textGrey),
                  SizedBox(height: 16),
                  Text('No prescriptions yet', style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prescriptions.length,
            itemBuilder: (context, i) {
              final p = prescriptions[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dr. ${p.doctorName}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(
                          '${p.prescribedAt.day}/${p.prescribedAt.month}/${p.prescribedAt.year}',
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                    Text(p.doctorSpecialization,
                        style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 13)),
                    const Divider(height: 16),
                    Text('Diagnosis: ${p.diagnosis}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('${p.medicines.length} medicine(s) prescribed',
                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const SizedBox();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.lightBlue,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                Text(user.email, style: const TextStyle(color: AppTheme.textGrey)),
                const SizedBox(height: 24),
                _ProfileItem(icon: Icons.person_outline, label: 'Edit Profile',
                    onTap: () => context.push('/patient-profile')),
                _ProfileItem(icon: Icons.calendar_today_outlined, label: 'My Appointments',
                    onTap: () => context.push('/my-appointments')),
                _ProfileItem(icon: Icons.receipt_long_outlined, label: 'My Prescriptions',
                    onTap: () => context.push('/prescriptions')),
                _ProfileItem(icon: Icons.notifications_outlined, label: 'Notifications',
                    onTap: () => context.push('/notifications')),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authServiceProvider).logout();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today_rounded), label: 'Appointments'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: 'Prescriptions'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}
