import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MedicineModel {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  const MedicineModel({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? '',
      instructions: map['instructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }
}

class PrescriptionModel extends Equatable {
  final String id;
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String diagnosis;
  final List<MedicineModel> medicines;
  final String? labTests;
  final String? advice;
  final String? followUpDate;
  final DateTime prescribedAt;

  const PrescriptionModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.diagnosis,
    required this.medicines,
    this.labTests,
    this.advice,
    this.followUpDate,
    required this.prescribedAt,
  });

  factory PrescriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrescriptionModel(
      id: doc.id,
      appointmentId: data['appointmentId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorSpecialization: data['doctorSpecialization'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      medicines: (data['medicines'] as List<dynamic>? ?? [])
          .map((m) => MedicineModel.fromMap(m as Map<String, dynamic>))
          .toList(),
      labTests: data['labTests'],
      advice: data['advice'],
      followUpDate: data['followUpDate'],
      prescribedAt: (data['prescribedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'diagnosis': diagnosis,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'labTests': labTests,
      'advice': advice,
      'followUpDate': followUpDate,
      'prescribedAt': Timestamp.fromDate(prescribedAt),
    };
  }

  @override
  List<Object?> get props => [id, appointmentId, patientId];
}
