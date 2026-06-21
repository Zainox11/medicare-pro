import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../../providers/auth_provider.dart';

class DoctorDetailScreen extends ConsumerWidget {
  final String doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<DoctorModel?>(
      future: ref.read(firestoreServiceProvider).getDoctorById(doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Doctor not found')),
          );
        }
        final doctor = snapshot.data!;
        return _DoctorDetailView(doctor: doctor);
      },
    );
  }
}

class _DoctorDetailView extends StatelessWidget {
  final DoctorModel doctor;
  const _DoctorDetailView({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_rounded, size: 18),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildAvatar(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Dr. ${doctor.name}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (doctor.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded,
                                          color: Colors.white, size: 18),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(doctor.specialization,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.85), fontSize: 14)),
                                Text(doctor.hospital,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7), fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      _StatCard(
                        value: '${doctor.experience}+',
                        label: 'Years Exp.',
                        icon: Icons.work_outline_rounded,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        value: doctor.rating.toStringAsFixed(1),
                        label: 'Rating',
                        icon: Icons.star_outline_rounded,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        value: '${doctor.totalReviews}',
                        label: 'Reviews',
                        icon: Icons.reviews_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // About
                  const Text('About',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(doctor.about,
                      style: const TextStyle(
                          color: AppTheme.textGrey, height: 1.6, fontSize: 14)),
                  const SizedBox(height: 20),

                  // Consultation Info
                  const Text('Consultation Info',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.local_hospital_outlined,
                    label: 'In-Person Fee',
                    value: 'PKR ${doctor.consultationFee.toStringAsFixed(0)}',
                  ),
                  if (doctor.isAvailableOnline) ...[
                    const SizedBox(height: 8),
                    _InfoTile(
                      icon: Icons.videocam_outlined,
                      label: 'Online Fee',
                      value: 'PKR ${doctor.onlineConsultationFee.toStringAsFixed(0)}',
                    ),
                  ],
                  const SizedBox(height: 8),
                  _InfoTile(
                    icon: Icons.school_outlined,
                    label: 'Qualification',
                    value: doctor.qualification,
                  ),
                  const SizedBox(height: 20),

                  // Available Days
                  const Text('Available Days',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: doctor.availableDays.map((day) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(day,
                            style: const TextStyle(
                                color: AppTheme.primaryBlue, fontWeight: FontWeight.w500,
                                fontSize: 13)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BookingBar(doctor: doctor),
    );
  }

  Widget _buildAvatar() {
    if (doctor.profileImage != null && doctor.profileImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: doctor.profileImage!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatCard({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  final DoctorModel doctor;
  const _BookingBar({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (doctor.isAvailableOnline) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/book-appointment/${doctor.uid}',
                    extra: 'online'),
                icon: const Icon(Icons.videocam_outlined, size: 18),
                label: const Text('Online'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/book-appointment/${doctor.uid}'),
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: const Text('Book Visit'),
            ),
          ),
        ],
      ),
    );
  }
}
