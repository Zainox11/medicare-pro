// notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotifData(
        icon: Icons.check_circle_rounded,
        color: AppTheme.successGreen,
        title: 'Appointment Confirmed',
        body: 'Your appointment with Dr. Ahmed has been confirmed for tomorrow at 10:00 AM.',
        time: '2 hours ago',
      ),
      _NotifData(
        icon: Icons.access_time_rounded,
        color: AppTheme.warningOrange,
        title: 'Appointment Reminder',
        body: 'You have an appointment with Dr. Sara in 1 hour.',
        time: '5 hours ago',
      ),
      _NotifData(
        icon: Icons.receipt_long_rounded,
        color: AppTheme.primaryBlue,
        title: 'New Prescription',
        body: 'Dr. Ahmed has issued a new prescription for you.',
        time: '1 day ago',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: AppTheme.textGrey),
                  SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: AppTheme.textGrey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, i) {
                final n = notifications[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: n.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(n.icon, color: n.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(n.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(n.time,
                                    style: const TextStyle(
                                        color: AppTheme.textGrey, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(n.body,
                                style: const TextStyle(
                                    color: AppTheme.textGrey, fontSize: 13, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _NotifData {
  final IconData icon;
  final Color color;
  final String title, body, time;
  const _NotifData({
    required this.icon, required this.color,
    required this.title, required this.body, required this.time,
  });
}
