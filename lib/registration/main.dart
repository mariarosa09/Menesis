import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menesis_app/auth/presentation/auth_cubit.dart';
import 'package:menesis_app/auth/repo/auth_repo.dart';
import 'package:menesis_app/registration/initialLength.dart';
import 'splashscreen.dart';
import 'createAcc.dart';
import 'package:menesis_app/otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menesis_app/firebase_options.dart';
import 'package:menesis_app/app_navigation/tab2/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menesis_app/services/notification_service.dart';
import 'dart:async';

// ============================================================
// MAIN
// ============================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.init();
  runApp(MyApp());
}

// ============================================================
// MyApp
// ============================================================
class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepo = FirebaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) =>
          AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mēnesis',
        home: const SplashScreen(),
      ),
    );
  }
}

// ============================================================
// LoginScreen
// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscure = true;
  int _loginAttempts = 5;
  bool _isCoolingDown = false;
  String? _emailError;
  String? _passwordError;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final authCubit = context.read<AuthCubit>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // login()
  // ----------------------------------------------------------
  void login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) _emailError = "This field is required.";
        if (password.isEmpty) _passwordError = "This field is required.";
      });
      return;
    }

    void coolDown() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Too many attempts. Please try again later."),
          backgroundColor: Color(0xFFB56A7E),
        ),
      );
      int totalSeconds = 300;
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
          final s = (totalSeconds % 60).toString().padLeft(2, '0');
          _passwordError = "Time remaining: $m:$s";
          totalSeconds--;
          if (totalSeconds < 0) {
            timer.cancel();
            _passwordError = "You can now try again";
            _isCoolingDown = false;
            _loginAttempts = 5;
          }
        });
      });
    }

    authCubit.login(email, password);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          setState(() => _emailError = "Invalid email format");
        } else if (e.code == 'user-not-found') {
          setState(() => _emailError = "User not found");
        } else if (e.code == 'wrong-password') {
          _loginAttempts -= 1;
          if (_loginAttempts == -1) _isCoolingDown = true;
          if (_loginAttempts == -1) {
            coolDown();
          } else if (_loginAttempts <= 3) {
            setState(() => _passwordError =
            "Incorrect Password! $_loginAttempts attempts left.");
          } else {
            setState(() => _passwordError = "Incorrect Password!");
          }
          passwordController.clear();
        } else if (e.code == 'too-many-requests') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "We have blocked all requests from this device due to unusual activity. Try again later."),
              backgroundColor: Color(0xFFB56A7E),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${e.message}"),
              backgroundColor: const Color(0xFFB56A7E),
            ),
          );
        }
      }
    }
  }

  // ----------------------------------------------------------
  // _handleForgotPassword()
  // ----------------------------------------------------------
  void _handleForgotPassword() async {
    FocusScope.of(context).unfocus();
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first.")),
      );
      return;
    }

    final message =
    await authCubit.forgotPassword(emailController.text.trim());

    if (!mounted) return;

    if (message == 'success') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          backgroundColor: const Color(0xFFFFFBFC),
          title: const Text("Forgot Password",
              style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A1F3D))),
          content: const Text(
              "Password reset email sent!\nPlease check your inbox.",
              style: TextStyle(fontSize: 14, color: Colors.black54)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                emailController.clear();
              },
              child: const Text("OK",
                  style: TextStyle(color: Colors.black45, fontSize: 14)),
            ),
          ],
        ),
      );
    } else if (message == 'invalid-email') {
      setState(() => _emailError = "Invalid email format");
    } else if (message == 'user-not-found') {
      setState(() => _emailError = "No existing account. Try again.");
    } else {
      setState(() => _emailError = "Error occurred. Please try again.");
    }
  }

  // ----------------------------------------------------------
  // _showRecoveryDialog()
  //
  // Shown when a soft-deleted account logs in within the 30-day
  // window. Offers two choices:
  //   • Recover  → clears the deletion flag, continues to app.
  //   • Delete   → permanently deletes right now.
  // ----------------------------------------------------------
  void _showRecoveryDialog(int daysRemaining) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restore_rounded,
                  color: Color(0xFFB56A7E), size: 44),
              const SizedBox(height: 14),
              const Text(
                "Account Scheduled for Deletion",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF301C29)),
              ),
              const SizedBox(height: 12),
              Text(
                "This account is set to be permanently deleted in "
                    "$daysRemaining day${daysRemaining == 1 ? '' : 's'}.\n\n"
                    "Would you like to recover it?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    height: 1.5, fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              // Recover button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _recoverAccount();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB56A7E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Yes, Recover My Account",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
              // Permanently delete now
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _permanentlyDelete();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("No, Delete Permanently",
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // _recoverAccount()
  // Clears the soft-delete flag then navigates to the app.
  // ----------------------------------------------------------
  Future<void> _recoverAccount() async {
    try {
      await authCubit.recoverAccount();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to recover account. Please try again."),
          backgroundColor: Color(0xFFB56A7E),
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // _permanentlyDelete()
  // Called either when the 30-day window has expired, or when
  // the user chooses "Delete Permanently" in the recovery dialog.
  // ----------------------------------------------------------
  Future<void> _permanentlyDelete() async {
    try {
      await authCubit.permanentlyDeleteAccount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your account has been permanently deleted."),
          backgroundColor: Color(0xFFB56A7E),
        ),
      );
      // authCubit will emit Unauthenticated — BlocListener handles navigation.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Please log out and log back in before permanently deleting your account."),
            backgroundColor: Color(0xFFB56A7E),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete account. Please try again."),
          backgroundColor: Color(0xFFB56A7E),
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        // --- Unverified email ---
        if (state is NeedVerificationLogin) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              backgroundColor: const Color(0xFFFFFBFC),
              title: const Text("Login",
                  style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A1F3D))),
              content: const Text(
                  "Account is not yet verified.\nVerification sent to your email!\nPlease check your inbox.",
                  style:
                  TextStyle(fontSize: 14, color: Colors.black54)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    emailController.clear();
                  },
                  child: const Text("OK",
                      style:
                      TextStyle(color: Colors.black45, fontSize: 14)),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      final u = FirebaseAuth.instance.currentUser;
                      if (u != null) {
                        await u.sendEmailVerification();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                            Text("Verification email resent!"),
                            backgroundColor: Color(0xFFB56A7E),
                          ),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${e.message}"),
                          backgroundColor: const Color(0xFFB56A7E),
                        ),
                      );
                    }
                  },
                  child: const Text("Resend Email",
                      style: TextStyle(
                          color: Color(0xFFB56A7E),
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
              ],
            ),
          );

          // --- Newly verified (just registered) ---
        } else if (state is Verified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PeriodSetupScreen()),
          );

          // --- Authenticated ---
        } else if (state is Authenticated) {
          // Check if the account is scheduled for deletion.
          final days =
          await authCubit.getDaysUntilPermanentDeletion();

          if (!context.mounted) return;

          if (days == null) {
            // Normal active account → go to app.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
            emailController.clear();
            passwordController.clear();
          } else if (days > 0) {
            // In recovery window → show recovery dialog.
            _showRecoveryDialog(days);
          } else {
            // Window expired → permanently delete and stay on login.
            await _permanentlyDelete();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F3F5),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            children: [
              // --- Scrollable content ---
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),

                      const Text("Welcome!",
                          style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'CormorantGaramond',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3A1F3D))),
                      const SizedBox(height: 3),
                      const Text("Sign in to continue your journey",
                          style: TextStyle(
                              fontSize: 15, color: Colors.black54)),
                      const SizedBox(height: 30),

                      // Email field
                      const Text("EMAIL",
                          style: TextStyle(fontSize: 10, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.mail_outline),
                          filled: true,
                          fillColor: const Color(0xFFFFFBFC),
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 18),
                          errorText: _emailError,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE8B7C3))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                  color: Color(0xFFB56A7E), width: 1.5)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent, width: 1.5)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Password field
                      const Text("PASSWORD",
                          style: TextStyle(fontSize: 10, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(obscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => obscure = !obscure),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFFBFC),
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 18),
                          errorText: _passwordError,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE8B7C3))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                  color: Color(0xFFB56A7E), width: 1.5)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent, width: 1.5)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),

                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: const Text("Forgot Password?",
                              style: TextStyle(
                                  color: Color(0xFFB4697D),
                                  fontSize: 13)),
                        ),
                      ),

                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCoolingDown
                                ? Colors.grey.shade400
                                : const Color(0xFFB56A7E),
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 18),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: !_isCoolingDown ? login : null,
                          child: const Text("Sign in"),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const CreateAccountScreen()),
                          ),
                          child: const Text("New here? Create Account",
                              style:
                              TextStyle(color: Color(0xFFB4697D))),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // --- Back button ---
              Positioned(
                top: 15,
                left: 5,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // --- Logo ---
              Positioned(
                top: 30,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                        const Color(0xFFB4697D).withOpacity(0.4),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child:
                  Image.asset('assets/images/logo.png', height: 80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}