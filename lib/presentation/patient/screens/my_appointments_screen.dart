// my_appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import 'patient_home_screen.dart';

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();
        return _AppointmentsView(patientId: user.uid);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _AppointmentsView extends ConsumerStatefulWidget {
  final String patientId;
  const _AppointmentsView({required this.patientId});

  @override
  ConsumerState<_AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends ConsumerState<_AppointmentsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apptAsync = ref.watch(patientAppointmentsProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
          indicatorColor: AppTheme.primaryBlue,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textGrey,
        ),
      ),
      body: apptAsync.when(
        data: (appts) {
          final upcoming = appts.where((a) => a.isUpcoming).toList();
          final past = appts.where((a) => !a.isUpcoming).toList();
          return TabBarView(
            controller: _tabController,
            children: [
              _AppointmentsList(appointments: upcoming),
              _AppointmentsList(appointments: past),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  final List appointments;
  const _AppointmentsList({required this.appointments});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: AppTheme.textGrey),
            SizedBox(height: 16),
            Text('No appointments here', style: TextStyle(color: AppTheme.textGrey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, i) => _AppointmentTile(appt: appointments[i]),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final dynamic appt;
  const _AppointmentTile({required this.appt});

  Color get _statusColor {
    switch (appt.status) {
      case 'confirmed': return AppTheme.successGreen;
      case 'pending': return AppTheme.warningOrange;
      case 'cancelled': return AppTheme.errorRed;
      default: return AppTheme.primaryBlue;
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
              Text('Dr. ${appt.doctorName}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(appt.status.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: _statusColor)),
              ),
            ],
          ),
          Text(appt.doctorSpecialization,
              style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 13)),
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 6),
              Text('${appt.appointmentDate.day}/${appt.appointmentDate.month}/${appt.appointmentDate.year}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined, size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 6),
              Text(appt.timeSlot, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
              const Spacer(),
              Text('PKR ${appt.fee.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
