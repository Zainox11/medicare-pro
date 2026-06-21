// prescription_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';

class PrescriptionScreen extends ConsumerWidget {
  const PrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();
        return _PrescriptionView(patientId: user.uid);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _PrescriptionView extends ConsumerWidget {
  final String patientId;
  const _PrescriptionView({required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presAsync = ref.watch(patientPrescriptionsProvider(patientId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
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
              return GestureDetector(
                onTap: () => _showPrescriptionDetail(context, p),
                child: Container(
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
                      Row(
                        children: [
                          const Icon(Icons.local_hospital_outlined, size: 14, color: AppTheme.textGrey),
                          const SizedBox(width: 6),
                          Text('Diagnosis: ${p.diagnosis}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${p.medicines.length} medicine(s)',
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    ],
                  ),
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

  void _showPrescriptionDetail(BuildContext context, dynamic p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  const Text('Prescription Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 20),
              _DetailRow('Doctor', 'Dr. ${p.doctorName}'),
              _DetailRow('Specialization', p.doctorSpecialization),
              _DetailRow('Date', '${p.prescribedAt.day}/${p.prescribedAt.month}/${p.prescribedAt.year}'),
              _DetailRow('Diagnosis', p.diagnosis),
              if (p.advice != null) _DetailRow('Advice', p.advice!),
              if (p.followUpDate != null) _DetailRow('Follow-up', p.followUpDate!),
              const SizedBox(height: 16),
              const Text('Medicines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ...p.medicines.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${m.dosage} • ${m.frequency} • ${m.duration}',
                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                    if (m.instructions != null)
                      Text(m.instructions!,
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
