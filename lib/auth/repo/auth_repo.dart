import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menesis_app/auth/entities/app_user.dart';

// ============================================================
// AutoRepo — abstract contract
// ============================================================
abstract class AutoRepo {
  Future<AppUser?> loginWithEmailPassword(String email, String password);
  Future<AppUser?> registerWithEmailPassword(
      String fname, String mi, String lname, String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<String> sendPasswordResetEmail(String email);

  /// Soft-delete: marks the account as deleted in Firestore,
  /// then signs out. Does NOT call user.delete().
  Future<void> softDeleteAccount();

  /// Permanently deletes all Firestore data and the Auth account.
  /// Called after the 30-day window expires, or when the user
  /// explicitly confirms they don't want to recover.
  Future<void> permanentlyDeleteAccount();

  /// Checks whether the currently-signed-in account has been
  /// soft-deleted and, if so, returns how many days remain in
  /// the recovery window. Returns null when the account is fine.
  /// Returns 0 when the window has expired (caller should
  /// proceed with permanentlyDeleteAccount).
  Future<int?> getDaysUntilPermanentDeletion();

  /// Removes the deleted flag so the account is fully restored.
  Future<void> recoverAccount();

  Future<void> sendEmailVerification();
}

// ============================================================
// FirebaseAuthRepo — concrete implementation
// ============================================================
class FirebaseAuthRepo implements AutoRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ----------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------
  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  // ----------------------------------------------------------
  // Login
  // ----------------------------------------------------------
  @override
  Future<AppUser?> loginWithEmailPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return AppUser(uid: cred.user!.uid, email: email);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // ----------------------------------------------------------
  // Register
  // ----------------------------------------------------------
  @override
  Future<AppUser?> registerWithEmailPassword(String fname, String mi,
      String lname, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await sendEmailVerification();
      return AppUser(uid: cred.user!.uid, email: email);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // ----------------------------------------------------------
  // Logout
  // ----------------------------------------------------------
  @override
  Future<void> logout() => _auth.signOut();

  // ----------------------------------------------------------
  // Current user
  // ----------------------------------------------------------
  @override
  Future<AppUser?> getCurrentUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return AppUser(uid: u.uid, email: u.email!);
  }

  // ----------------------------------------------------------
  // Password reset
  // ----------------------------------------------------------
  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (_) {
      return 'error';
    }
  }

  // ----------------------------------------------------------
  // Email verification
  // ----------------------------------------------------------
  @override
  Future<void> sendEmailVerification() async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('No user found to verify.');
    await u.sendEmailVerification();
  }

  // ----------------------------------------------------------
  // Soft delete
  // Sets deleted=true + deletedAt timestamp, then signs out.
  // ----------------------------------------------------------
  @override
  Future<void> softDeleteAccount() async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('No user logged in.');

    await _userDoc(u.uid).set({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await logout();
  }

  // ----------------------------------------------------------
  // Permanent delete
  // Erases Firestore collections and the Auth account.
  // Requires a recent login; caller must handle
  // requires-recent-login FirebaseAuthException if needed.
  // ----------------------------------------------------------
  @override
  Future<void> permanentlyDeleteAccount() async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('No user logged in.');
    final uid = u.uid;

    await Future.wait([
      _db.collection('cycle').doc(uid).delete(),
      _db.collection('settings').doc(uid).delete(),
      _userDoc(uid).delete(),
      // Add more collections here as needed.
    ]);

    await u.delete();
  }

  // ----------------------------------------------------------
  // getDaysUntilPermanentDeletion()
  //
  // Returns null  → account is not soft-deleted (all good).
  // Returns n > 0 → soft-deleted, n days remain.
  // Returns 0     → window expired; call permanentlyDeleteAccount.
  // ----------------------------------------------------------
  @override
  Future<int?> getDaysUntilPermanentDeletion() async {
    final u = _auth.currentUser;
    if (u == null) return null;

    final snap = await _userDoc(u.uid).get();
    if (!snap.exists) return null;

    final data = snap.data() as Map<String, dynamic>?;
    if (data == null) return null;

    final deleted = data['deleted'] as bool? ?? false;
    if (!deleted) return null;

    final deletedAt = data['deletedAt'] as Timestamp?;
    if (deletedAt == null) return null; // Corrupt doc — treat as not deleted.

    const kWindowDays = 30;
    final expiresAt =
    deletedAt.toDate().add(const Duration(days: kWindowDays));
    final remaining = expiresAt.difference(DateTime.now()).inDays;

    return remaining > 0 ? remaining : 0;
  }

  // ----------------------------------------------------------
  // recoverAccount() — clears the deletion flags.
  // ----------------------------------------------------------
  @override
  Future<void> recoverAccount() async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('No user logged in.');

    await _userDoc(u.uid).update({
      'deleted': false,
      'deletedAt': FieldValue.delete(),
    });
  }
}