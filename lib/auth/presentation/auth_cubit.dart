import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menesis_app/auth/entities/app_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menesis_app/auth/repo/auth_repo.dart';

// ============================================================
// States
// ============================================================
abstract class AuthState {}

class NeedVerification extends AuthState {
  final AppUser user;
  NeedVerification(this.user);
}

class NeedVerificationLogin extends AuthState {
  final AppUser user;
  NeedVerificationLogin(this.user);
}

class Verified extends AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// ============================================================
// AuthCubit
// ============================================================
class AuthCubit extends Cubit<AuthState> {
  final AutoRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  AppUser? get currentUser => _currentUser;

  // ----------------------------------------------------------
  // checkAuth
  // ----------------------------------------------------------
  void checkAuth() async {
    emit(AuthLoading());
    final user = await authRepo.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  // ----------------------------------------------------------
  // login
  // ----------------------------------------------------------
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user =
      await authRepo.loginWithEmailPassword(email, password);
      if (user != null) {
        _currentUser = user;
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null && !firebaseUser.emailVerified) {
          await firebaseUser.sendEmailVerification();
          emit(NeedVerificationLogin(user));
          _startVerificationCheck();
        } else {
          emit(Authenticated(user));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // ----------------------------------------------------------
  // register
  // ----------------------------------------------------------
  Future<void> register(String fname, String mi, String lname,
      String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(
          fname, mi, lname, email, password);
      if (user != null) {
        _currentUser = user;
        emit(NeedVerification(user));
        _startVerificationCheck();
      } else {
        emit(Unauthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Registration failed. Please try again.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ----------------------------------------------------------
  // _startVerificationCheck
  // ----------------------------------------------------------
  void _startVerificationCheck() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        emit(Verified());
        emit(VerifiedNeedsSetup(AppUser(uid: user!.uid, email: user.email!)));
      }
    });
  }

  // ----------------------------------------------------------
  // logout
  // ----------------------------------------------------------
  Future<void> logout() async {
    emit(AuthLoading());
    await authRepo.logout();
    emit(Unauthenticated());
  }

  // ----------------------------------------------------------
  // forgotPassword
  // ----------------------------------------------------------
  Future<String> forgotPassword(String email) async {
    try {
      return await authRepo.sendPasswordResetEmail(email);
    } catch (e) {
      return e.toString();
    }
  }

  // ----------------------------------------------------------
  // getDaysUntilPermanentDeletion
  // Delegates to the repo. Returns:
  //   null  → account is active (not soft-deleted)
  //   n > 0 → soft-deleted, n days left in recovery window
  //   0     → window expired, should permanently delete
  // ----------------------------------------------------------
  Future<int?> getDaysUntilPermanentDeletion() =>
      authRepo.getDaysUntilPermanentDeletion();

  // ----------------------------------------------------------
  // recoverAccount
  // Clears the soft-delete flag so the account is fully restored.
  // ----------------------------------------------------------
  Future<void> recoverAccount() async {
    try {
      await authRepo.recoverAccount();
      // _currentUser is still set from the login call; no re-emit needed.
    } catch (e) {
      emit(AuthError(e.toString()));
      rethrow; // Let the UI handle the SnackBar.
    }
  }

  // ----------------------------------------------------------
  // permanentlyDeleteAccount
  // Erases all Firestore data + the Firebase Auth account.
  // ----------------------------------------------------------
  Future<void> permanentlyDeleteAccount() async {
    try {
      emit(AuthLoading());
      await authRepo.permanentlyDeleteAccount();
      _currentUser = null;
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      rethrow; // Let the UI handle requires-recent-login etc.
    }
  }
}

class VerifiedNeedsSetup extends AuthState {
  final AppUser user;
  VerifiedNeedsSetup(this.user);
}
