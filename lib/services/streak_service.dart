import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads and writes the streak info stored on each user's Firestore
/// document: when their current streak started, and their longest
/// streak ever recorded.
///
/// The day/hour/minute math itself happens locally on the Home screen
/// using the device's own clock - this service only persists the
/// result so it's still there next time the app opens.
class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  /// Fetches the user's document once (not a live stream). The Home
  /// screen calls this a single time when it first loads, then keeps
  /// the clock ticking on-device from there.
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchUserDoc(String uid) {
    return _userDoc(uid).get();
  }

  /// Saves a new streak start time and longest-streak record.
  /// Used both when logging a relapse and when doing a full reset -
  /// the caller decides what values to save.
  Future<void> updateStreak({
    required String uid,
    required DateTime streakStart,
    required int longestStreakDays,
  }) {
    return _userDoc(uid).set({
      'streakStartDate': Timestamp.fromDate(streakStart),
      'longestStreakDays': longestStreakDays,
    }, SetOptions(merge: true));
  }
}
