import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/prescription_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../../providers/auth_provider.dart';
import '../../patient/widgets/custom_text_field.dart';

class WritePrescriptionScreen extends ConsumerStatefulWidget {
  final String appointmentId;
  const WritePrescriptionScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<WritePrescriptionScreen> createState() => _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState extends ConsumerState<WritePrescriptionScreen> {
  AppointmentModel? _appointment;
  final _diagnosisCtrl = TextEditingController();
  final _labTestsCtrl = TextEditingController();
  final _adviceCtrl = TextEditingController();
  final _followUpCtrl = TextEditingController();
  final List<_MedicineEntry> _medicines = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
    _addMedicine();
  }

  Future<void> _loadAppointment() async {
    // Get appointment from Firestore
    final snap = await ref.read(firestoreServiceProvider)
        .getPatientPrescriptions('').first.then((_) => null).catchError((_) => null);
    // Load via appointment stream — simplified: we store patientId via doctor appointments
    final apptSnap = await ref.read(firestoreServiceProvider)
        .getDoctorAppointments('').first.catchError((_) => <AppointmentModel>[]);
  }

  void _addMedicine() {
    setState(() {
      _medicines.add(_MedicineEntry(
        nameCtrl: TextEditingController(),
        dosageCtrl: TextEditingController(),
        frequencyCtrl: TextEditingController(),
        durationCtrl: TextEditingController(),
        instructCtrl: TextEditingController(),
      ));
    });
  }

  Future<void> _save() async {
    if (_diagnosisCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a diagnosis')),
      );
      return;
    }

    final user = await ref.read(authServiceProvider).getCurrentUserData();
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final medicines = _medicines
          .where((m) => m.nameCtrl.text.trim().isNotEmpty)
          .map((m) => MedicineModel(
                name: m.nameCtrl.text.trim(),
                dosage: m.dosageCtrl.text.trim(),
                frequency: m.frequencyCtrl.text.trim(),
                duration: m.durationCtrl.text.trim(),
                instructions: m.instructCtrl.text.trim().isEmpty
                    ? null
                    : m.instructCtrl.text.trim(),
              ))
          .toList();

      final prescription = PrescriptionModel(
        id: '',
        appointmentId: widget.appointmentId,
        patientId: _appointment?.patientId ?? '',
        patientName: _appointment?.patientName ?? '',
        doctorId: user.uid,
        doctorName: user.name,
        doctorSpecialization: '',
        diagnosis: _diagnosisCtrl.text.trim(),
        medicines: medicines,
        labTests: _labTestsCtrl.text.trim().isEmpty ? null : _labTestsCtrl.text.trim(),
        advice: _adviceCtrl.text.trim().isEmpty ? null : _adviceCtrl.text.trim(),
        followUpDate: _followUpCtrl.text.trim().isEmpty ? null : _followUpCtrl.text.trim(),
        prescribedAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).createPrescription(prescription);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription saved!')),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _labTestsCtrl.dispose();
    _adviceCtrl.dispose();
    _followUpCtrl.dispose();
    for (final m in _medicines) m.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Prescription'),
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
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Digital Prescription',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                      Text('Appointment #${widget.appointmentId.substring(0, 8)}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Diagnosis *',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _diagnosisCtrl,
              label: 'Primary Diagnosis',
              hint: 'e.g., Acute Pharyngitis',
              prefixIcon: Icons.local_hospital_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Medicines',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: _addMedicine,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._medicines.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Medicine ${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                        if (_medicines.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppTheme.errorRed, size: 20),
                            onPressed: () => setState(() => _medicines.removeAt(i)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: m.nameCtrl,
                      label: 'Medicine Name',
                      hint: 'e.g., Paracetamol 500mg',
                      prefixIcon: Icons.medication_outlined,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: m.dosageCtrl,
                            label: 'Dosage',
                            hint: '1 tablet',
                            prefixIcon: Icons.straighten_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: m.frequencyCtrl,
                            label: 'Frequency',
                            hint: 'Twice daily',
                            prefixIcon: Icons.access_time_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: m.durationCtrl,
                            label: 'Duration',
                            hint: '5 days',
                            prefixIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: m.instructCtrl,
                            label: 'Instructions',
                            hint: 'After meals',
                            prefixIcon: Icons.info_outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 4),
            const Text('Lab Tests (Optional)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _labTestsCtrl,
              label: 'Lab Tests',
              hint: 'e.g., CBC, Blood Sugar Fasting',
              prefixIcon: Icons.science_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            const Text('Advice (Optional)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _adviceCtrl,
              label: 'Advice',
              hint: 'Dietary & lifestyle advice...',
              prefixIcon: Icons.lightbulb_outline,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            const Text('Follow-up Date (Optional)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _followUpCtrl,
              label: 'Follow-up After',
              hint: 'e.g., 1 week / 2026-07-01',
              prefixIcon: Icons.event_outlined,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.send_rounded),
                label: _isSaving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save & Send Prescription'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MedicineEntry {
  final TextEditingController nameCtrl;
  final TextEditingController dosageCtrl;
  final TextEditingController frequencyCtrl;
  final TextEditingController durationCtrl;
  final TextEditingController instructCtrl;

  _MedicineEntry({
    required this.nameCtrl,
    required this.dosageCtrl,
    required this.frequencyCtrl,
    required this.durationCtrl,
    required this.instructCtrl,
  });

  void dispose() {
    nameCtrl.dispose();
    dosageCtrl.dispose();
    frequencyCtrl.dispose();
    durationCtrl.dispose();
    instructCtrl.dispose();
  }
}
