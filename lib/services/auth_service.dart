// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Firestore'a erişim için

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<List<QueryDocumentSnapshot>> getLoginLogsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snapshot = await _db
        .collection('login_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getDailyLoginLogs() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('login_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfToday))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs;
  }

  Future<void> logLoginEvent(String email) {
    return _db.collection('login_logs').add({
      'email': email,
      'timestamp': FieldValue.serverTimestamp(), // Sunucu zamanı
    });
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}