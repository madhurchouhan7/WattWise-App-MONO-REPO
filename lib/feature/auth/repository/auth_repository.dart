import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wattwise_app/feature/auth/models/user_model.dart';
import 'package:wattwise_app/feature/auth/services/auth_service.dart';

/// Key used in SharedPreferences to persist onboarding status.
const String _kOnboardingCompleteKey = 'onboarding_complete';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  // ─── Streams ──────────────────────────────────────────────────────────────

  /// Emits a [UserModel] when signed in, or null when signed out.
  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _mapFirebaseUser(firebaseUser);
    });
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  Future<UserModel> _mapFirebaseUser(User firebaseUser) async {
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingComplete =
        prefs.getBool('${_kOnboardingCompleteKey}_${firebaseUser.uid}') ??
        false;

    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isOnboardingComplete: isOnboardingComplete,
    );
  }

  // ─── Auth actions ─────────────────────────────────────────────────────────

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapFirebaseUser(credential.user!);
  }

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    return _mapFirebaseUser(credential.user!);
  }

  Future<UserModel?> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    if (credential == null) return null;
    return _mapFirebaseUser(credential.user!);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _authService.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  // ─── Onboarding persistence ───────────────────────────────────────────────

  /// Call this after the user completes the onboarding flow.
  Future<void> markOnboardingComplete(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_kOnboardingCompleteKey}_$uid', true);
  }

  /// Check if the current user has completed onboarding.
  Future<bool> isOnboardingComplete(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_kOnboardingCompleteKey}_$uid') ?? false;
  }
}
