import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class OnlineConsultationScreen extends StatelessWidget {
  const OnlineConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Consultation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accentTeal, Color(0xFF00838F)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.videocam_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Consult Anytime, Anywhere',
                    style: TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Get expert medical advice from the comfort of your home. Available 24/7.',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // How it works
            const Text('How it Works',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const _StepTile(
              step: '1',
              icon: Icons.search_rounded,
              title: 'Choose a Doctor',
              desc: 'Browse and select a doctor with online consultation enabled.',
            ),
            const _StepTile(
              step: '2',
              icon: Icons.calendar_today_rounded,
              title: 'Book a Slot',
              desc: 'Pick a date and time that works for you.',
            ),
            const _StepTile(
              step: '3',
              icon: Icons.videocam_rounded,
              title: 'Join the Call',
              desc: 'Get a video link before your appointment. Join at the scheduled time.',
            ),
            const _StepTile(
              step: '4',
              icon: Icons.receipt_long_rounded,
              title: 'Receive Prescription',
              desc: 'Doctor sends digital prescription right after consultation.',
            ),
            const SizedBox(height: 24),

            // Specializations available online
            const Text('Available Online Specializations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.specializationList.take(8).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s,
                    style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              )).toList(),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/doctors'),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Find Online Doctors'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/my-appointments'),
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('My Consultations'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String step, title, desc;
  final IconData icon;
  const _StepTile({required this.step, required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(
              color: AppTheme.lightBlue, shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(step,
                  style: const TextStyle(
                      color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: AppTheme.primaryBlue),
                    const SizedBox(width: 6),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
