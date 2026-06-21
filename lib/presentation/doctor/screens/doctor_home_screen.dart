import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/services/firestore_service.dart';

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DoctorHomeTab(),
          _DoctorAppointmentsTab(),
          _DoctorPatientsTab(),
          _DoctorProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today_rounded), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people_rounded), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DoctorHomeTab extends ConsumerWidget {
  const _DoctorHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return SafeArea(
      child: userAsync.when(
        data: (user) {
          if (user == null) return const SizedBox();
          final apptAsync = ref.watch(doctorAppointmentsProvider(user.uid));

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr. ${user.name.split(' ').first} 👨‍⚕️',
                                  style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('Manage your appointments & patients',
                                    style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.push('/notifications'),
                            icon: const Icon(Icons.notifications_outlined),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats
                      apptAsync.when(
                        data: (appts) {
                          final list = appts as List<AppointmentModel>;
                          final today = list.where((a) {
                            final now = DateTime.now();
                            return a.appointmentDate.year == now.year &&
                                a.appointmentDate.month == now.month &&
                                a.appointmentDate.day == now.day;
                          }).length;
                          final pending = list.where((a) => a.status == AppConstants.statusPending).length;
                          final completed = list.where((a) => a.status == AppConstants.statusCompleted).length;

                          return Row(
                            children: [
                              _StatBox(value: '$today', label: "Today's", color: AppTheme.primaryBlue),
                              const SizedBox(width: 12),
                              _StatBox(value: '$pending', label: 'Pending', color: AppTheme.warningOrange),
                              const SizedBox(width: 12),
                              _StatBox(value: '$completed', label: 'Completed', color: AppTheme.successGreen),
                            ],
                          );
                        },
                        loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                        error: (_, __) => const SizedBox(),
                      ),
                      const SizedBox(height: 20),

                      // Quick Actions
                      const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _QuickAction(
                            icon: Icons.calendar_today_rounded,
                            label: 'Schedule',
                            color: AppTheme.lightBlue,
                            iconColor: AppTheme.primaryBlue,
                            onTap: () => context.push('/doctor-appointments'),
                          ),
                          const SizedBox(width: 12),
                          _QuickAction(
                            icon: Icons.people_alt_rounded,
                            label: 'Patients',
                            color: const Color(0xFFE8F5E9),
                            iconColor: AppTheme.successGreen,
                            onTap: () => context.push('/patient-records'),
                          ),
                          const SizedBox(width: 12),
                          _QuickAction(
                            icon: Icons.person_rounded,
                            label: 'Profile',
                            color: const Color(0xFFFFF3E0),
                            iconColor: AppTheme.warningOrange,
                            onTap: () => context.push('/doctor-profile'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text("Today's Appointments",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              apptAsync.when(
                data: (appts) {
                  final list = appts as List<AppointmentModel>;
                  final now = DateTime.now();
                  final todayAppts = list.where((a) =>
                    a.appointmentDate.year == now.year &&
                    a.appointmentDate.month == now.month &&
                    a.appointmentDate.day == now.day &&
                    a.status != AppConstants.statusCancelled).toList();

                  if (todayAppts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.event_available_rounded, size: 56, color: AppTheme.textGrey),
                              SizedBox(height: 12),
                              Text('No appointments today', style: TextStyle(color: AppTheme.textGrey)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _AppointmentCard(
                          appointment: todayAppts[i],
                          onAction: (appt, status) async {
                            await ref.read(firestoreServiceProvider)
                                .updateAppointmentStatus(appt.id, status);
                          },
                        ),
                        childCount: todayAppts.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBox({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, iconColor;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 11, color: iconColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final void Function(AppointmentModel, String) onAction;
  const _AppointmentCard({required this.appointment, required this.onAction});

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
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppTheme.lightBlue, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    appointment.patientName.isNotEmpty ? appointment.patientName[0].toUpperCase() : 'P',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patientName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text('${appointment.timeSlot} • ${appointment.isOnline ? "Online" : "In-Person"}',
                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                  ],
                ),
              ),
              _StatusBadge(status: appointment.status),
            ],
          ),
          if (appointment.symptoms != null && appointment.symptoms!.isNotEmpty) ...[
            const Divider(height: 16),
            Text('Symptoms: ${appointment.symptoms}',
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
          ],
          if (appointment.status == AppConstants.statusPending) ...[
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onAction(appointment, AppConstants.statusCancelled),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: const BorderSide(color: AppTheme.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Decline', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAction(appointment, AppConstants.statusConfirmed),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                    child: const Text('Confirm', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
          if (appointment.status == AppConstants.statusConfirmed) ...[
            const Divider(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/write-prescription/${appointment.id}'),
                icon: const Icon(Icons.receipt_long_rounded, size: 16),
                label: const Text('Write Prescription', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get color {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// Doctor Appointments Tab
class _DoctorAppointmentsTab extends ConsumerWidget {
  const _DoctorAppointmentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();
        return DoctorAppointmentsScreen(doctorId: user.uid, embedded: true);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// Doctor Patients Tab
class _DoctorPatientsTab extends ConsumerWidget {
  const _DoctorPatientsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PatientRecordsScreen(embedded: true);
  }
}

// Doctor Profile Tab
class _DoctorProfileTab extends ConsumerWidget {
  const _DoctorProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();
        return Scaffold(
          appBar: AppBar(title: const Text('My Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.lightBlue,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'D',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Dr. ${user.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                Text(user.email, style: const TextStyle(color: AppTheme.textGrey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue, borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Doctor', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 24),
                _MenuItem(icon: Icons.person_outline, label: 'Edit Profile', onTap: () => context.push('/doctor-profile')),
                _MenuItem(icon: Icons.calendar_today_outlined, label: 'My Appointments', onTap: () => context.push('/doctor-appointments')),
                _MenuItem(icon: Icons.people_outline, label: 'Patient Records', onTap: () => context.push('/patient-records')),
                _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => context.push('/notifications')),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authServiceProvider).logout();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: const BorderSide(color: AppTheme.errorRed),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});

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

// Placeholder imports for embedded screens
class DoctorAppointmentsScreen extends ConsumerWidget {
  final String? doctorId;
  final bool embedded;
  const DoctorAppointmentsScreen({super.key, this.doctorId, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final id = doctorId;
    if (id == null) {
      return userAsync.when(
        data: (u) => u == null ? const SizedBox() : _Body(doctorId: u.uid),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      );
    }
    return _Body(doctorId: id);
  }
}

class _Body extends ConsumerStatefulWidget {
  final String doctorId;
  const _Body({required this.doctorId});

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apptAsync = ref.watch(doctorAppointmentsProvider(widget.doctorId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'Confirmed'), Tab(text: 'Completed')],
          indicatorColor: AppTheme.primaryBlue,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textGrey,
          isScrollable: true,
        ),
      ),
      body: apptAsync.when(
        data: (appts) {
          final list = appts as List<AppointmentModel>;
          final pending = list.where((a) => a.status == 'pending').toList();
          final confirmed = list.where((a) => a.status == 'confirmed').toList();
          final completed = list.where((a) => a.status == 'completed').toList();
          return TabBarView(
            controller: _tab,
            children: [
              _ApptList(appts: pending),
              _ApptList(appts: confirmed),
              _ApptList(appts: completed),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _ApptList extends StatelessWidget {
  final List<AppointmentModel> appts;
  const _ApptList({required this.appts});

  @override
  Widget build(BuildContext context) {
    if (appts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_rounded, size: 56, color: AppTheme.textGrey),
            SizedBox(height: 12),
            Text('No appointments here', style: TextStyle(color: AppTheme.textGrey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appts.length,
      itemBuilder: (context, i) {
        final a = appts[i];
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
              Text(a.patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              Text('${a.appointmentDate.day}/${a.appointmentDate.month}/${a.appointmentDate.year} • ${a.timeSlot}',
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
              Text('${a.isOnline ? "Online" : "In-Person"} • PKR ${a.fee.toStringAsFixed(0)}',
                  style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 13)),
              if (a.symptoms != null && a.symptoms!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Symptoms: ${a.symptoms}', style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              ],
              if (a.status == 'confirmed') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/write-prescription/${a.id}'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                    child: const Text('Write Prescription', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class PatientRecordsScreen extends ConsumerWidget {
  final bool embedded;
  const PatientRecordsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(
      StreamProvider((ref) => ref.read(firestoreServiceProvider).getAllPatients())
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Records'),
        automaticallyImplyLeading: !embedded,
        leading: embedded ? null : IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: patientsAsync.when(
        data: (patients) {
          if (patients.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: AppTheme.textGrey),
                  SizedBox(height: 16),
                  Text('No patients yet', style: TextStyle(color: AppTheme.textGrey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (context, i) {
              final p = patients[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.lightBlue,
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text(p.email, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                          if (p.bloodGroup != null)
                            Text('Blood: ${p.bloodGroup}',
                                style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.textGrey),
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
