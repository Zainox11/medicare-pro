import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DoctorModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final String qualification;
  final String hospital;
  final String? profileImage;
  final double consultationFee;
  final double onlineConsultationFee;
  final double rating;
  final int totalReviews;
  final int experience; // years
  final String about;
  final List<String> availableDays;
  final List<String> availableTimeSlots;
  final bool isAvailableOnline;
  final bool isVerified;
  final bool isActive;
  final String? licenseNumber;
  final DateTime createdAt;

  const DoctorModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.qualification,
    required this.hospital,
    this.profileImage,
    required this.consultationFee,
    required this.onlineConsultationFee,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.experience,
    required this.about,
    required this.availableDays,
    required this.availableTimeSlots,
    this.isAvailableOnline = true,
    this.isVerified = false,
    this.isActive = true,
    this.licenseNumber,
    required this.createdAt,
  });

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      specialization: data['specialization'] ?? '',
      qualification: data['qualification'] ?? '',
      hospital: data['hospital'] ?? '',
      profileImage: data['profileImage'],
      consultationFee: (data['consultationFee'] ?? 0).toDouble(),
      onlineConsultationFee: (data['onlineConsultationFee'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      experience: data['experience'] ?? 0,
      about: data['about'] ?? '',
      availableDays: List<String>.from(data['availableDays'] ?? []),
      availableTimeSlots: List<String>.from(data['availableTimeSlots'] ?? []),
      isAvailableOnline: data['isAvailableOnline'] ?? true,
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      licenseNumber: data['licenseNumber'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'qualification': qualification,
      'hospital': hospital,
      'profileImage': profileImage,
      'consultationFee': consultationFee,
      'onlineConsultationFee': onlineConsultationFee,
      'rating': rating,
      'totalReviews': totalReviews,
      'experience': experience,
      'about': about,
      'availableDays': availableDays,
      'availableTimeSlots': availableTimeSlots,
      'isAvailableOnline': isAvailableOnline,
      'isVerified': isVerified,
      'isActive': isActive,
      'licenseNumber': licenseNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'role': 'doctor',
    };
  }

  @override
  List<Object?> get props => [uid, email, specialization];
}
