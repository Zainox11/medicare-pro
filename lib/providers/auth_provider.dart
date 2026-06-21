import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/firestore_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return null;
  return ref.read(authServiceProvider).getCurrentUserData();
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<UserModel?> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(email: email, password: password);
      state = AsyncValue.data(user);
      return user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<UserModel?> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.registerPatient(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      state = AsyncValue.data(user);
      return user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle({String? role}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithGoogle(role: role);
      state = AsyncValue.data(user);
      return user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// Doctor provider
final doctorsProvider = StreamProvider.family<List<dynamic>, String?>((ref, specialization) {
  return ref.read(firestoreServiceProvider).getDoctors(specialization: specialization);
});

// Patient appointments provider
final patientAppointmentsProvider = StreamProvider.family<List<dynamic>, String>((ref, patientId) {
  return ref.read(firestoreServiceProvider).getPatientAppointments(patientId);
});

// Doctor appointments provider
final doctorAppointmentsProvider = StreamProvider.family<List<dynamic>, String>((ref, doctorId) {
  return ref.read(firestoreServiceProvider).getDoctorAppointments(doctorId);
});

// Patient prescriptions provider
final patientPrescriptionsProvider = StreamProvider.family<List<dynamic>, String>((ref, patientId) {
  return ref.read(firestoreServiceProvider).getPatientPrescriptions(patientId);
});
