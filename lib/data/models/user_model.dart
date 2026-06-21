import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // patient, doctor, admin
  final String? profileImage;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final List<String> allergies;
  final List<String> medicalHistory;
  final DateTime createdAt;
  final bool isActive;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.address,
    this.allergies = const [],
    this.medicalHistory = const [],
    required this.createdAt,
    this.isActive = true,
    this.fcmToken,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'patient',
      profileImage: data['profileImage'],
      dateOfBirth: data['dateOfBirth'],
      gender: data['gender'],
      bloodGroup: data['bloodGroup'],
      address: data['address'],
      allergies: List<String>.from(data['allergies'] ?? []),
      medicalHistory: List<String>.from(data['medicalHistory'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'address': address,
      'allergies': allergies,
      'medicalHistory': medicalHistory,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? profileImage,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? address,
    List<String>? allergies,
    List<String>? medicalHistory,
    bool? isActive,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      allergies: allergies ?? this.allergies,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  List<Object?> get props => [uid, email, role];
}
