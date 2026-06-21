import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final String doctorId;
  const BookAppointmentScreen({super.key, required this.doctorId});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  DoctorModel? _doctor;
  DateTime _selectedDay = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  String _consultationType = AppConstants.consultationInPerson;
  bool _isLoading = false;
  bool _isLoadingSlots = false;
  final _symptomsCtrl = TextEditingController();
  Set<String> _bookedSlots = {};

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    final doctor = await ref.read(firestoreServiceProvider).getDoctorById(widget.doctorId);
    setState(() => _doctor = doctor);
    _loadBookedSlots(_selectedDay);
  }

  Future<void> _loadBookedSlots(DateTime date) async {
    if (_doctor == null) return;
    setState(() => _isLoadingSlots = true);
    final booked = <String>{};
    for (final slot in AppConstants.timeSlots) {
      final available = await ref
          .read(firestoreServiceProvider)
          .isSlotAvailable(_doctor!.uid, date, slot);
      if (!available) booked.add(slot);
    }
    setState(() {
      _bookedSlots = booked;
      _isLoadingSlots = false;
      _selectedSlot = null;
    });
  }

  Future<void> _bookAppointment() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    final user = await ref.read(authServiceProvider).getCurrentUserData();
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final fee = _consultationType == AppConstants.consultationOnline
          ? _doctor!.onlineConsultationFee
          : _doctor!.consultationFee;

      final appointment = AppointmentModel(
        id: const Uuid().v4(),
        patientId: user.uid,
        patientName: user.name,
        patientPhone: user.phone,
        doctorId: _doctor!.uid,
        doctorName: _doctor!.name,
        doctorSpecialization: _doctor!.specialization,
        doctorImage: _doctor!.profileImage,
        appointmentDate: _selectedDay,
        timeSlot: _selectedSlot!,
        consultationType: _consultationType,
        status: AppConstants.statusPending,
        symptoms: _symptomsCtrl.text.trim().isEmpty ? null : _symptomsCtrl.text.trim(),
        fee: fee,
        createdAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).createAppointment(appointment);

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.successGreen, size: 72),
            const SizedBox(height: 16),
            const Text('Appointment Booked!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Your appointment with Dr. ${_doctor?.name} on '
              '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year} '
              'at $_selectedSlot has been booked.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textGrey, height: 1.5),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/patient-home');
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_doctor == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
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
            // Doctor Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _doctor!.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. ${_doctor!.name}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(_doctor!.specialization,
                            style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 13)),
                        Text(_doctor!.hospital,
                            style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Consultation Type
            const Text('Consultation Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _TypeButton(
                  icon: Icons.local_hospital_outlined,
                  label: 'In-Person',
                  fee: 'PKR ${_doctor!.consultationFee.toStringAsFixed(0)}',
                  selected: _consultationType == AppConstants.consultationInPerson,
                  onTap: () => setState(() => _consultationType = AppConstants.consultationInPerson),
                ),
                const SizedBox(width: 12),
                if (_doctor!.isAvailableOnline)
                  _TypeButton(
                    icon: Icons.videocam_outlined,
                    label: 'Online',
                    fee: 'PKR ${_doctor!.onlineConsultationFee.toStringAsFixed(0)}',
                    selected: _consultationType == AppConstants.consultationOnline,
                    onTap: () => setState(() => _consultationType = AppConstants.consultationOnline),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Calendar
            const Text('Select Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() => _selectedDay = selectedDay);
                  _loadBookedSlots(selectedDay);
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.primaryBlue, shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.lightBlue, shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: AppTheme.primaryBlue),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Time Slots
            const Text('Select Time Slot',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (_isLoadingSlots)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.timeSlots.map((slot) {
                  final isBooked = _bookedSlots.contains(slot);
                  final isSelected = _selectedSlot == slot;
                  return GestureDetector(
                    onTap: isBooked ? null : () => setState(() => _selectedSlot = slot),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isBooked
                            ? const Color(0xFFF3F4F6)
                            : isSelected
                                ? AppTheme.primaryBlue
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isBooked
                              ? AppTheme.dividerColor
                              : isSelected
                                  ? AppTheme.primaryBlue
                                  : AppTheme.dividerColor,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 13,
                          color: isBooked
                              ? AppTheme.textGrey
                              : isSelected
                                  ? Colors.white
                                  : AppTheme.textDark,
                          decoration: isBooked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),

            // Symptoms
            const Text('Symptoms / Reason (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _symptomsCtrl,
              label: 'Describe your symptoms',
              hint: 'e.g., Fever, headache for 3 days...',
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _bookAppointment,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Confirm Booking • PKR ${(_consultationType == AppConstants.consultationOnline ? _doctor!.onlineConsultationFee : _doctor!.consultationFee).toStringAsFixed(0)}',
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String label, fee;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.icon, required this.label, required this.fee,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primaryBlue : AppTheme.dividerColor,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : AppTheme.textGrey, size: 24),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppTheme.textDark)),
              Text(fee,
                  style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white.withOpacity(0.85) : AppTheme.textGrey)),
            ],
          ),
        ),
      ),
    );
  }
}
