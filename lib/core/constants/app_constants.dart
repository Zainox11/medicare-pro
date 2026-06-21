class AppConstants {
  // App Info
  static const String appName = 'MediCare Pro';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String doctorsCollection = 'doctors';
  static const String appointmentsCollection = 'appointments';
  static const String prescriptionsCollection = 'prescriptions';
  static const String notificationsCollection = 'notifications';
  static const String specializations = 'specializations';
  static const String reviewsCollection = 'reviews';
  static const String consultationsCollection = 'consultations';

  // User Roles
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleAdmin = 'admin';

  // Appointment Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusRescheduled = 'rescheduled';

  // Consultation Types
  static const String consultationOnline = 'online';
  static const String consultationInPerson = 'in_person';

  // Shared Pref Keys
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboarded = 'onboarded';

  // Specializations List
  static const List<String> specializationList = [
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedic',
    'Pediatrician',
    'Psychiatrist',
    'Radiologist',
    'General Physician',
    'Gynecologist',
    'Ophthalmologist',
    'ENT Specialist',
    'Oncologist',
    'Urologist',
    'Endocrinologist',
    'Gastroenterologist',
  ];

  // Consultation Fees Range
  static const double minFee = 500;
  static const double maxFee = 5000;

  // Time Slots
  static const List<String> timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '12:00 PM', '02:00 PM',
    '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM',
    '04:30 PM', '05:00 PM', '05:30 PM', '06:00 PM',
  ];
}
