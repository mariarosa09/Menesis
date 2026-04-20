import 'package:firebase_auth/firebase_auth.dart';
import 'package:menesis_app/auth/entities/app_user.dart';

abstract class AutoRepo {
  Future<AppUser?> loginWithEmailPassword(String email, String password);
  Future<AppUser?> registerWithEmailPassword(String fname, String mi, String lname, String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<String> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
  Future<void> sendEmailVerification();
}

class FirebaseAuthRepo implements AutoRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in.');
      await user.delete();
      await logout();
    }
    catch (e) {
      throw Exception("Failed to delete account: $e");
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) return null;

    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!);
  }

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        
      );
      return user;
    }
    /*on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else if (e.code == 'invalid-credential') {
        print('Invalid email or password.');
    }*/
    catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> registerWithEmailPassword(String fname, String mi, String lname, String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await sendEmailVerification();
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);
      return user;
    }
    catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "success";
    }
    on FirebaseAuthException catch (e) {
      return e.code;
    }
    catch (e) {
      return "error";
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        print("Success email sent");
      } else {
        throw Exception("No user found to verify.");
      }
    } catch (e) { 
      throw Exception("Failed to send verification email: $e"); 
    }
  }
}