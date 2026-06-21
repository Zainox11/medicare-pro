import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../models/prescription_model.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── DOCTORS ────────────────────────────────────────────────
  Stream<List<DoctorModel>> getDoctors({String? specialization}) {
    Query query = _db
        .collection(AppConstants.doctorsCollection)
        .where('isActive', isEqualTo: true)
        .where('isVerified', isEqualTo: true);

    if (specialization != null && specialization.isNotEmpty) {
      query = query.where('specialization', isEqualTo: specialization);
    }

    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList());
  }

  Future<DoctorModel?> getDoctorById(String uid) async {
    final doc = await _db
        .collection(AppConstants.doctorsCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return DoctorModel.fromFirestore(doc);
  }

  Future<void> createOrUpdateDoctor(DoctorModel doctor) async {
    await _db
        .collection(AppConstants.doctorsCollection)
        .doc(doctor.uid)
        .set(doctor.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateDoctorRating(String doctorId, double newRating) async {
    final doc = await _db
        .collection(AppConstants.doctorsCollection)
        .doc(doctorId)
        .get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final totalReviews = (data['totalReviews'] ?? 0) as int;
    final currentRating = (data['rating'] ?? 0.0) as double;
    final updatedRating =
        ((currentRating * totalReviews) + newRating) / (totalReviews + 1);

    await _db.collection(AppConstants.doctorsCollection).doc(doctorId).update({
      'rating': updatedRating,
      'totalReviews': totalReviews + 1,
    });
  }

  // ─── APPOINTMENTS ────────────────────────────────────────────
  Future<String> createAppointment(AppointmentModel appointment) async {
    final docRef = await _db
        .collection(AppConstants.appointmentsCollection)
        .add(appointment.toFirestore());
    return docRef.id;
  }

  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return _db
        .collection(AppConstants.appointmentsCollection)
        .where('patientId', isEqualTo: patientId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return _db
        .collection(AppConstants.appointmentsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDate', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status, {String? reason}) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': Timestamp.now(),
    };
    if (reason != null) data['cancellationReason'] = reason;

    await _db
        .collection(AppConstants.appointmentsCollection)
        .doc(appointmentId)
        .update(data);
  }

  Future<bool> isSlotAvailable(
      String doctorId, DateTime date, String timeSlot) async {
    final snap = await _db
        .collection(AppConstants.appointmentsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .where('appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(
                DateTime(date.year, date.month, date.day)))
        .where('appointmentDate',
            isLessThan: Timestamp.fromDate(
                DateTime(date.year, date.month, date.day + 1)))
        .where('timeSlot', isEqualTo: timeSlot)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();
    return snap.docs.isEmpty;
  }

  // ─── PRESCRIPTIONS ───────────────────────────────────────────
  Future<String> createPrescription(PrescriptionModel prescription) async {
    final docRef = await _db
        .collection(AppConstants.prescriptionsCollection)
        .add(prescription.toFirestore());

    // Link prescription to appointment
    await _db
        .collection(AppConstants.appointmentsCollection)
        .doc(prescription.appointmentId)
        .update({
      'prescriptionId': docRef.id,
      'status': AppConstants.statusCompleted,
    });

    return docRef.id;
  }

  Stream<List<PrescriptionModel>> getPatientPrescriptions(String patientId) {
    return _db
        .collection(AppConstants.prescriptionsCollection)
        .where('patientId', isEqualTo: patientId)
        .orderBy('prescribedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PrescriptionModel.fromFirestore(doc))
            .toList());
  }

  Future<PrescriptionModel?> getPrescriptionById(String id) async {
    final doc = await _db
        .collection(AppConstants.prescriptionsCollection)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return PrescriptionModel.fromFirestore(doc);
  }

  // ─── USERS / PATIENTS ───────────────────────────────────────
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  // Get all patients (admin)
  Stream<List<UserModel>> getAllPatients() {
    return _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: 'patient')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // ─── ADMIN STATS ────────────────────────────────────────────
  Future<Map<String, int>> getAdminStats() async {
    final futures = await Future.wait([
      _db.collection(AppConstants.usersCollection)
          .where('role', isEqualTo: 'patient').count().get(),
      _db.collection(AppConstants.doctorsCollection).count().get(),
      _db.collection(AppConstants.appointmentsCollection).count().get(),
      _db.collection(AppConstants.appointmentsCollection)
          .where('status', isEqualTo: 'completed').count().get(),
    ]);

    return {
      'patients': futures[0].count ?? 0,
      'doctors': futures[1].count ?? 0,
      'appointments': futures[2].count ?? 0,
      'completed': futures[3].count ?? 0,
    };
  }
}
