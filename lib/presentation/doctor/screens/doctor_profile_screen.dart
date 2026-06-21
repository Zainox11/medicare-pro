import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../../providers/auth_provider.dart';
import '../../patient/widgets/custom_text_field.dart';

class DoctorProfileScreen extends ConsumerStatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  ConsumerState<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _qualCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _onlineFeeCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  String? _selectedSpec;
  List<String> _selectedDays = [];
  bool _isOnline = true;
  bool _isSaving = false;
  bool _loaded = false;

  final List<String> _days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _hospitalCtrl, _qualCtrl, _aboutCtrl,
      _licenseCtrl, _feeCtrl, _onlineFeeCtrl, _expCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadData(DoctorModel doc) {
    if (_loaded) return;
    _loaded = true;
    _nameCtrl.text = doc.name;
    _phoneCtrl.text = doc.phone;
    _hospitalCtrl.text = doc.hospital;
    _qualCtrl.text = doc.qualification;
    _aboutCtrl.text = doc.about;
    _licenseCtrl.text = doc.licenseNumber ?? '';
    _feeCtrl.text = doc.consultationFee.toStringAsFixed(0);
    _onlineFeeCtrl.text = doc.onlineConsultationFee.toStringAsFixed(0);
    _expCtrl.text = doc.experience.toString();
    _selectedSpec = doc.specialization;
    _selectedDays = List.from(doc.availableDays);
    _isOnline = doc.isAvailableOnline;
  }

  Future<void> _save(String uid) async {
    setState(() => _isSaving = true);
    try {
      final doctor = DoctorModel(
        uid: uid,
        name: _nameCtrl.text.trim(),
        email: '',
        phone: _phoneCtrl.text.trim(),
        specialization: _selectedSpec ?? '',
        qualification: _qualCtrl.text.trim(),
        hospital: _hospitalCtrl.text.trim(),
        consultationFee: double.tryParse(_feeCtrl.text) ?? 0,
        onlineConsultationFee: double.tryParse(_onlineFeeCtrl.text) ?? 0,
        experience: int.tryParse(_expCtrl.text) ?? 0,
        about: _aboutCtrl.text.trim(),
        availableDays: _selectedDays,
        availableTimeSlots: AppConstants.timeSlots,
        isAvailableOnline: _isOnline,
        licenseNumber: _licenseCtrl.text.trim().isEmpty ? null : _licenseCtrl.text.trim(),
        createdAt: DateTime.now(),
        isVerified: false,
        isActive: true,
      );
      await ref.read(firestoreServiceProvider).createOrUpdateDoctor(doctor);
      // Also update users collection name/phone
      await ref.read(firestoreServiceProvider).updateUser(uid, {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
      }
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
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();
        return FutureBuilder<DoctorModel?>(
          future: ref.read(firestoreServiceProvider).getDoctorById(user.uid),
          builder: (context, snap) {
            if (snap.hasData && snap.data != null) _loadData(snap.data!);
            return Scaffold(
              appBar: AppBar(
                title: const Text('Doctor Profile'),
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
                    Center(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppTheme.lightBlue,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'D',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(controller: _nameCtrl, label: 'Full Name', hint: 'Your name', prefixIcon: Icons.person_outline),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _phoneCtrl, label: 'Phone', hint: 'Phone number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedSpec,
                      decoration: const InputDecoration(labelText: 'Specialization', prefixIcon: Icon(Icons.medical_services_outlined, size: 20)),
                      items: AppConstants.specializationList.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (v) => setState(() => _selectedSpec = v),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _qualCtrl, label: 'Qualification', hint: 'e.g. MBBS, MD', prefixIcon: Icons.school_outlined),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _hospitalCtrl, label: 'Hospital / Clinic', hint: 'Where you practice', prefixIcon: Icons.local_hospital_outlined),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _licenseCtrl, label: 'License Number', hint: 'Medical license #', prefixIcon: Icons.badge_outlined),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(controller: _feeCtrl, label: 'In-Person Fee (PKR)', hint: '1500', prefixIcon: Icons.attach_money, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: CustomTextField(controller: _expCtrl, label: 'Experience (Yrs)', hint: '5', prefixIcon: Icons.work_outline, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _onlineFeeCtrl, label: 'Online Consultation Fee (PKR)', hint: '1000', prefixIcon: Icons.videocam_outlined, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _aboutCtrl, label: 'About', hint: 'Brief bio...', prefixIcon: Icons.info_outline, maxLines: 3),
                    const SizedBox(height: 20),
                    const Text('Available Days', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _days.map((day) {
                        final sel = _selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (sel) _selectedDays.remove(day);
                            else _selectedDays.add(day);
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? AppTheme.primaryBlue : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: sel ? AppTheme.primaryBlue : AppTheme.dividerColor),
                            ),
                            child: Text(day.substring(0, 3),
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: sel ? Colors.white : AppTheme.textGrey)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: _isOnline,
                      onChanged: (v) => setState(() => _isOnline = v),
                      title: const Text('Available for Online Consultation'),
                      activeColor: AppTheme.primaryBlue,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : () => _save(user.uid),
                        child: _isSaving
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Save Profile'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
