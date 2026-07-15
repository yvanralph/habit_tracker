import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles all login/register/logout logic using Firebase Auth,
/// and saves extra profile info (name, phone, reason) to Firestore.
///
/// Keeping this logic in one place means the screens only need to
/// call a simple method and show the result - they don't need to
/// know anything about Firebase.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The currently logged in user, or null if nobody is logged in.
  User? get currentUser => _auth.currentUser;

  /// Fires every time the user logs in or out.
  /// main.dart listens to this to decide which screen to show.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Tries to log in with email and password.
  /// Returns null on success, or an error message to show the user.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _messageForError(e);
    }
  }

  /// Creates a new account, then saves the extra profile fields
  /// (full name, phone, reason for quitting) to Firestore.
  /// Returns null on success, or an error message to show the user.
  Future<String?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String reason,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return 'Something went wrong creating your account. Please try again.';
      }

      // Save the extra details that Firebase Auth doesn't store by itself.
      // streakStartDate/longestStreakDays power the Home screen tracker -
      // a brand new account starts its streak the moment it's created.
      // streakStartDate uses the device's own clock (Timestamp.now())
      // rather than FieldValue.serverTimestamp(), so it's available
      // immediately instead of showing as null until the server confirms it.
      await _firestore.collection('users').doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'streakStartDate': Timestamp.now(),
        'longestStreakDays': 0,
      });

      await user.updateDisplayName(fullName);

      return null;
    } on FirebaseAuthException catch (e) {
      return _messageForError(e);
    }
  }

  /// Logs the current user out.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Turns Firebase's error codes into simple messages a user can understand.
  String _messageForError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
