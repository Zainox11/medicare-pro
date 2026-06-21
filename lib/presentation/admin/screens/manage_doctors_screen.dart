import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../../providers/auth_provider.dart';

class ManageDoctorsScreen extends ConsumerWidget {
  const ManageDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(
      StreamProvider((ref) => ref.read(firestoreServiceProvider).getDoctors()),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Doctors'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: doctorsAsync.when(
        data: (doctors) {
          if (doctors.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services_outlined, size: 64, color: AppTheme.textGrey),
                  SizedBox(height: 16),
                  Text('No doctors registered yet', style: TextStyle(color: AppTheme.textGrey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, i) {
              final d = doctors[i] as DoctorModel;
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
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              d.name.isNotEmpty ? d.name[0].toUpperCase() : 'D',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Dr. ${d.name}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  ),
                                  if (d.isVerified)
                                    const Icon(Icons.verified_rounded,
                                        color: AppTheme.primaryBlue, size: 16)
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningOrange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Pending',
                                          style: TextStyle(fontSize: 10, color: AppTheme.warningOrange,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                ],
                              ),
                              Text(d.specialization,
                                  style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 13)),
                              Text(d.hospital,
                                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(d.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Text('(${d.totalReviews} reviews)',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                        const Spacer(),
                        Text('PKR ${d.consultationFee.toStringAsFixed(0)}/visit',
                            style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (!d.isVerified) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await ref.read(firestoreServiceProvider)
                                    .createOrUpdateDoctor(DoctorModel(
                                  uid: d.uid, name: d.name, email: d.email, phone: d.phone,
                                  specialization: d.specialization, qualification: d.qualification,
                                  hospital: d.hospital, consultationFee: d.consultationFee,
                                  onlineConsultationFee: d.onlineConsultationFee,
                                  experience: d.experience, about: d.about,
                                  availableDays: d.availableDays, availableTimeSlots: d.availableTimeSlots,
                                  isAvailableOnline: d.isAvailableOnline, isVerified: false,
                                  isActive: false, createdAt: d.createdAt,
                                ));
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.errorRed,
                                side: const BorderSide(color: AppTheme.errorRed),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Reject', style: TextStyle(fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await ref.read(firestoreServiceProvider)
                                    .createOrUpdateDoctor(DoctorModel(
                                  uid: d.uid, name: d.name, email: d.email, phone: d.phone,
                                  specialization: d.specialization, qualification: d.qualification,
                                  hospital: d.hospital, consultationFee: d.consultationFee,
                                  onlineConsultationFee: d.onlineConsultationFee,
                                  experience: d.experience, about: d.about,
                                  availableDays: d.availableDays, availableTimeSlots: d.availableTimeSlots,
                                  isAvailableOnline: d.isAvailableOnline, isVerified: true,
                                  isActive: true, createdAt: d.createdAt,
                                ));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Doctor verified!')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                              child: const Text('Verify', style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ],
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
