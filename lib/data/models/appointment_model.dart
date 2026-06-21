import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AppointmentModel extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String? doctorImage;
  final DateTime appointmentDate;
  final String timeSlot;
  final String consultationType; // online / in_person
  final String status; // pending, confirmed, completed, cancelled
  final String? symptoms;
  final String? notes;
  final double fee;
  final bool isPaid;
  final String? prescriptionId;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    this.doctorImage,
    required this.appointmentDate,
    required this.timeSlot,
    required this.consultationType,
    required this.status,
    this.symptoms,
    this.notes,
    required this.fee,
    this.isPaid = false,
    this.prescriptionId,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientPhone: data['patientPhone'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorSpecialization: data['doctorSpecialization'] ?? '',
      doctorImage: data['doctorImage'],
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      consultationType: data['consultationType'] ?? 'in_person',
      status: data['status'] ?? 'pending',
      symptoms: data['symptoms'],
      notes: data['notes'],
      fee: (data['fee'] ?? 0).toDouble(),
      isPaid: data['isPaid'] ?? false,
      prescriptionId: data['prescriptionId'],
      cancellationReason: data['cancellationReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'doctorImage': doctorImage,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'consultationType': consultationType,
      'status': status,
      'symptoms': symptoms,
      'notes': notes,
      'fee': fee,
      'isPaid': isPaid,
      'prescriptionId': prescriptionId,
      'cancellationReason': cancellationReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  AppointmentModel copyWith({
    String? status,
    String? notes,
    String? prescriptionId,
    String? cancellationReason,
    bool? isPaid,
  }) {
    return AppointmentModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialization: doctorSpecialization,
      doctorImage: doctorImage,
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      consultationType: consultationType,
      status: status ?? this.status,
      symptoms: symptoms,
      notes: notes ?? this.notes,
      fee: fee,
      isPaid: isPaid ?? this.isPaid,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isUpcoming =>
      appointmentDate.isAfter(DateTime.now()) && status != 'cancelled';
  bool get isPast => appointmentDate.isBefore(DateTime.now());
  bool get isOnline => consultationType == 'online';

  @override
  List<Object?> get props => [id, patientId, doctorId, appointmentDate];
}
