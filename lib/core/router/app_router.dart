import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../presentation/auth/screens/splash_screen.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/register_screen.dart';
import '../../presentation/auth/screens/onboarding_screen.dart';
import '../../presentation/patient/screens/patient_home_screen.dart';
import '../../presentation/patient/screens/doctor_list_screen.dart';
import '../../presentation/patient/screens/doctor_detail_screen.dart';
import '../../presentation/patient/screens/book_appointment_screen.dart';
import '../../presentation/patient/screens/my_appointments_screen.dart';
import '../../presentation/patient/screens/prescription_screen.dart';
import '../../presentation/patient/screens/patient_profile_screen.dart';
import '../../presentation/patient/screens/notifications_screen.dart';
import '../../presentation/patient/screens/online_consultation_screen.dart';
import '../../presentation/doctor/screens/doctor_home_screen.dart';
import '../../presentation/doctor/screens/doctor_appointments_screen.dart';
import '../../presentation/doctor/screens/doctor_profile_screen.dart';
import '../../presentation/doctor/screens/write_prescription_screen.dart';
import '../../presentation/doctor/screens/patient_records_screen.dart';
import '../../presentation/admin/screens/admin_dashboard_screen.dart';
import '../../presentation/admin/screens/manage_doctors_screen.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Patient Routes
      GoRoute(path: '/patient-home', builder: (_, __) => const PatientHomeScreen()),
      GoRoute(path: '/doctors', builder: (_, __) => const DoctorListScreen()),
      GoRoute(
        path: '/doctor/:id',
        builder: (_, state) => DoctorDetailScreen(doctorId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/book-appointment/:doctorId',
        builder: (_, state) => BookAppointmentScreen(
          doctorId: state.pathParameters['doctorId']!,
        ),
      ),
      GoRoute(path: '/my-appointments', builder: (_, __) => const MyAppointmentsScreen()),
      GoRoute(path: '/prescriptions', builder: (_, __) => const PrescriptionScreen()),
      GoRoute(path: '/patient-profile', builder: (_, __) => const PatientProfileScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/online-consultation', builder: (_, __) => const OnlineConsultationScreen()),

      // Doctor Routes
      GoRoute(path: '/doctor-home', builder: (_, __) => const DoctorHomeScreen()),
      GoRoute(path: '/doctor-appointments', builder: (_, __) => const DoctorAppointmentsScreen()),
      GoRoute(path: '/doctor-profile', builder: (_, __) => const DoctorProfileScreen()),
      GoRoute(
        path: '/write-prescription/:appointmentId',
        builder: (_, state) => WritePrescriptionScreen(
          appointmentId: state.pathParameters['appointmentId']!,
        ),
      ),
      GoRoute(path: '/patient-records', builder: (_, __) => const PatientRecordsScreen()),

      // Admin Routes
      GoRoute(path: '/admin-dashboard', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: '/manage-doctors', builder: (_, __) => const ManageDoctorsScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
