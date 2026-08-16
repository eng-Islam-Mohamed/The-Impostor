import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).userChanges();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});

class AuthRepository {
  const AuthRepository(this._auth);

  final FirebaseAuth _auth;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    await credential.user?.sendEmailVerification();
  }

  Future<void> login({required String email, required String password}) {
    return _auth
        .signInWithEmailAndPassword(
          email: email.trim().toLowerCase(),
          password: password,
        )
        .then((_) {});
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  Future<void> resendVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> refreshUser() async {
    await _auth.currentUser?.reload();
    await _auth.currentUser?.getIdToken(true);
  }

  Future<void> logout() => _auth.signOut();
}

String friendlyAuthError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'email-already-in-use' => 'An account already uses that email.',
      'invalid-email' => 'Enter a valid email address.',
      'invalid-credential' => 'The email or password is incorrect.',
      'weak-password' => 'Use a password with at least 8 characters.',
      'too-many-requests' => 'Too many attempts. Please wait and try again.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }
  return 'Something went wrong. Please try again.';
}
