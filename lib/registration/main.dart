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
import 'dart:async';

// ============================================================
// MAIN FUNCTION
// Purpose: Sinisiguro na naka-initialize ang Flutter bindings
//          at Firebase bago mag-run ang app.
// ============================================================
void main() async {
  // Ensures Flutter engine is ready before any async work
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// ============================================================
// MyApp WIDGET
// Purpose: Root widget ng app. Nagde-define ng title, theme,
//          at unang screen na ipapakita (SplashScreen).
// ============================================================
class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepo = FirebaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit> (
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mēnesis',
        home: const SplashScreen()
      )
    );
  }
}

// ============================================================
// LoginScreen WIDGET
// Purpose: Stateful screen para sa login. Hawak nito ang
//          email/password input, visibility toggle, at
//          navigation papunta sa ibang screens.
// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // --------------------------------------------------------
  // STATE VARIABLES
  // Purpose: Tracks kung visible ba ang password, at
  //          nag-iingat ng login attempt count + cooldown.
  // --------------------------------------------------------
  bool obscure = true;
  int _loginAttempts = 5;
  bool _isCoolingDown = false;
  String? _emailError;     // Inline error message for email/username field
  String? _passwordError;  // Inline error message for password field

  // --------------------------------------------------------
  // TEXT CONTROLLERS
  // Purpose: Kinukuha ang text input ng user mula sa
  //          email at password fields.
  // --------------------------------------------------------
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final authCubit = context.read<AuthCubit>();
  // --------------------------------------------------------
  // DISPOSE METHOD
  // Purpose: Ini-dispose ang mga controller para maiwasan
  //          ang memory leaks kapag nag-unmount ang widget.
  // --------------------------------------------------------
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------
  // LOGIN FUNCTION
  // Purpose: Pinoproseso ang login attempt. Nagche-check ng
  //          empty fields, cooldown status, at susunod na
  //          icoconnect sa Firebase authentication.
  // --------------------------------------------------------
  void login() async {
    // Clear previous inline errors before each attempt
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // Basic validation — show inline error if fields are empty
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) _emailError = "This field is required.";
        if (password.isEmpty) _passwordError = "This field is required.";
      });
      return;
    }

    // Block login if cooling down from too many failed attempts
    void coolDown () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Too many attempts. Please try again later."),
          backgroundColor: Color(0xFFB56A7E),
        ),
      );
      int totalSeconds = 300;
      Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          int minutes = totalSeconds ~/ 60; // Integer division for minutes
          int seconds = totalSeconds % 60;  // Remainder for seconds

          String m = minutes.toString().padLeft(2, '0');
          String s = seconds.toString().padLeft(2, '0');
          _passwordError = "Time remaining: $m:$s";
          totalSeconds--;

          if (totalSeconds < 0) {
            timer.cancel(); // Stops the timer
            _passwordError = "You can now try again";
            _isCoolingDown = false;
            _loginAttempts = 5;
          }
        });
      });
      return;
    }
    
    authCubit.login(email, password);
    final user = FirebaseAuth.instance.currentUser;
    User? previousUser = user;
    if (previousUser != user) {
      _isCoolingDown = false;
      _loginAttempts = 5;
    }
    if (user == null) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      }
      on FirebaseAuthException catch (e) {
        if (e.code == "invalid-email") {
          setState(() {
            _emailError = "Invalid email format";
          });
        }
        else if (e.code == "user-not-found") {
          setState(() {
            _emailError = "User not found";
          });
        }
        else if (e.code == "wrong-password") {
          _loginAttempts -= 1;
          if (_loginAttempts == -1) {
            _isCoolingDown = true;
          }
          if(_loginAttempts==-1) {
            coolDown();
          }
          else if (_loginAttempts <= 3) {
            setState(() {
              _passwordError = "Incorrect Password! $_loginAttempts attempts left.";
            });
          }
          else {
            setState(() {
              _passwordError = "Incorrect Password!";
            });
          }
          passwordController.clear();
        }
        else if (e.code == "too-many-requests") {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("We have blocked all requests from this device due to unusual activity. Try again later."),
            backgroundColor: Color(0xFFB56A7E),
          ),
        );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${e.message}"),
              backgroundColor: Color(0xFFB56A7E),
            ),
          );
        }
      }
    }

    
    

    // TODO: (EDIT) Ikonekta ang login sa Firebase Authentication
    //   at mag-send ng email notification sa user na may nag-try mag-access ng kanilang account
    //   (gamitin ang Firebase Email trigger o Cloud Function para dito)
    //- New user reset counter and cooldown
    // The code should be placed here

  }

  // --------------------------------------------------------
  // FORGOT PASSWORD HANDLER
  // Purpose: Inina-navigate ang user papunta sa OTP screen
  //          para sa password reset, with email validation.
  // --------------------------------------------------------
  void _handleForgotPassword() async {
    FocusScope.of(context).unfocus();

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first.")),
      );
      return;
    }
    
    String message = await authCubit.forgotPassword(emailController.text.trim());

    if (message == "success") {
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            backgroundColor: const Color(0xFFFFFBFC),
            title: const Text(
              "Forgot Password",
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A1F3D),
                ),
              ),
              content: Text(
                "Password reset email sent!\nPlease check your inbox.",
                style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  emailController.clear();
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        }
      );
    }
    else if (message == "invalid-email") {
      setState(() {
        _emailError = "Invalid email format";
      });
    }
    else if (message == "user-not-found") {
      setState(() {
        _emailError = "No existing account. Try again.";
      });
    }
    else {
      setState(() {
        _emailError = "Error occurred. Please try again.";
      });
    }
  }

    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(email: emailController.text.trim()),
      ),
    );*/

  // --------------------------------------------------------
  // BUILD METHOD
  // Purpose: Nagbu-build ng UI ng login screen. Kasama ang
  //          header texts, input fields, buttons, at logo.
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is NeedVerificationLogin) {
          showDialog(
            context: context, 
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                backgroundColor: const Color(0xFFFFFBFC),
                title: const Text(
                  "Login",
                  style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A1F3D),
                    ),
                  ),
                  content: Text(
                    "Account is not yet verified.\nAccount verification sent on your email!\nPlease check your inbox.",
                    style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); 
                      emailController.clear();
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await user.sendEmailVerification();
                          // Feedback is important!
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar( // Removed 'const'
                              content: Text("Verification email resent!"),
                              backgroundColor: const Color(0xFFB56A7E),
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar( // Removed 'const'
                              content: Text("${e.message}"),
                              backgroundColor: const Color(0xFFB56A7E),
                            ),
                        ); // This captures "too many requests" errors
                      }
                      catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar( // Removed 'const'
                              content: Text("Error: $e"),
                              backgroundColor: const Color(0xFFB56A7E),
                            ),
                        ); // This captures "too many requests" errors
                      }
                    },
                    child: const Text(
                      "Resend Email",
                      style: TextStyle(
                        color: Color(0xFFB56A7E),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              );
            }
          );
        }
        else if (state is Verified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PeriodSetupScreen())
          );
        }
        else if (state is Authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage())
          );
          emailController.clear();
          passwordController.clear();
        }
      },
    
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F3F5),
        resizeToAvoidBottomInset: true, // Prevents keyboard from covering fields

        body: SafeArea(
          child: Stack(
            children: [

              // ------------------------------------------------
              // SCROLLABLE MAIN CONTENT
              // Purpose: Nilalaman ang lahat ng visible fields at
              //          buttons. Scrollable para hindi mabawasan
              //          ng keyboard.
              // ------------------------------------------------
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),

                      // Header greeting text
                      const Text(
                        "Welcome!",
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'CormorantGaramond',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A1F3D),
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Subtitle / tagline
                      const Text(
                        "Sign in to continue your journey",
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),

                      const SizedBox(height: 30),

                      // --------------------------------------------
                      // EMAIL / USERNAME FIELD
                      // Purpose: Kunin ang email o username ng user.
                      //          May inline error display sa ibaba.
                      // --------------------------------------------
                      const Text(
                        "EMAIL",
                        style: TextStyle(fontSize: 10, letterSpacing: 2),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.mail_outline),
                          filled: true,
                          fillColor: const Color(0xFFFFFBFC),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          // Show inline error message under the field
                          errorText: _emailError,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFFE8B7C3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFFB56A7E), width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Colors.redAccent),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --------------------------------------------
                      // PASSWORD FIELD
                      // Purpose: Kunin ang password ng user.
                      //          May toggle para makita ang password,
                      //          at inline error display sa ibaba.
                      // --------------------------------------------
                      const Text(
                        "PASSWORD",
                        style: TextStyle(fontSize: 10, letterSpacing: 2),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          // Toggle password visibility icon
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => obscure = !obscure),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFFBFC),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          // Show inline error message under the field
                          errorText: _passwordError,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFFE8B7C3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFFB56A7E), width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Colors.redAccent),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // --------------------------------------------
                      // FORGOT PASSWORD BUTTON
                      // Purpose: Nagre-redirect ang user sa OTP
                      //          screen para mag-reset ng password.
                      //          Requires email input muna bago pumunta.
                      // --------------------------------------------
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Color(0xFFB4697D), fontSize: 13),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // --------------------------------------------
                      // SIGN IN BUTTON
                      // Purpose: Ini-trigger ang login() function
                      //          kapag pinindot ng user.
                      // --------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCoolingDown ?
                            Colors.grey.shade400
                            : Color(0xFFB56A7E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: !_isCoolingDown ? login : null,
                          child: const Text("Sign in"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------
                      // CREATE ACCOUNT LINK
                      // Purpose: Nagre-redirect ang bagong user
                      //          papunta sa CreateAccountScreen.
                      // --------------------------------------------
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                            );
                          },
                          child: const Text(
                            "New here? Create Account",
                            style: TextStyle(color: Color(0xFFB4697D)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------
              // BACK BUTTON (Top Left)
              // Purpose: Nagbibigay ng paraan para makabalik
              //          sa nakaraang screen (SplashScreen).
              // ------------------------------------------------
              Positioned(
                top: 15,
                left: 5,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // ------------------------------------------------
              // LOGO (Top Right)
              // Purpose: Nagpapakita ng app logo sa upper-right
              //          corner ng screen para sa branding.
              // ------------------------------------------------
              Positioned(
                top: 30,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB4697D).withOpacity(0.4),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Image.asset('assets/images/logo.png', height: 80),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}