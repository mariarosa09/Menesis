import 'package:menesis_app/auth/entities/app_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menesis_app/auth/repo/auth_repo.dart';

abstract class AuthState {}

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

class AuthCubit extends Cubit<AuthState> {
  final AutoRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  AppUser? get currentUser => _currentUser;

  void checkAuth() async {
    emit(AuthLoading());

    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    }
  }


  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, password);
      if (user!=null) {
        _currentUser = user;
        emit(Authenticated(user));
      }
      else {
        emit(Unauthenticated());
      }
    }
    catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> register(String fname, String mi, String lname, String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(fname, mi, lname, email, password);
      if (user!=null) {
        _currentUser = user;
        emit(Authenticated(user));
      }
      else {
        emit(Unauthenticated());
      }
    }
    catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await authRepo.logout();
    emit(Unauthenticated());
  }

  Future<String> forgotPassword(String email) async {
    try {
      final message = await authRepo.sendPasswordResetEmail(email);
      return message;
    }
    catch (e) {
      return e.toString();
    }
  }

  Future<void> deleteAccount() async {
    try {
      emit(AuthLoading());
      await authRepo.deleteAccount();
      emit(Unauthenticated());
    }
    catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
}