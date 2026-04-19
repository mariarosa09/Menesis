import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menesis_app/auth/presentation/auth_cubit.dart';
import 'package:menesis_app/auth/repo/auth_repo.dart';
import 'splashscreen.dart';
import 'createAcc.dart';
import 'package:menesis_app/otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menesis_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menesis_app/app_navigation/tab2/homepage.dart';

//TODO: i-connect sa homepage.dart kapag registered ang acc or new acc
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
  int _loginAttempts = 0;
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
  void login() {
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
    if (_isCoolingDown) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Too many attempts. Please try again later."),
          backgroundColor: Color(0xFFB56A7E),
        ),
      );
      return;
    }

    final authCubit = context.read<AuthCubit>();
    authCubit.login(email, password);
    

    // TODO: (EDIT) Ikonekta ang login sa Firebase Authentication
    // - Gamitin ang FirebaseAuth.instance.signInWithEmailAndPassword()
    // - Kung successful: i-redirect sa HomePage
    // - Kung hindi existing ang account: mag-display ng inline error sa ibaba ng email field
    //   na "There's no existing account with that email/username! Please try again."
    //   → I-set ang _emailError para ma-display sa ibaba ng email field
    // - Kung mali ang password: dagdagan ang _loginAttempts counter,
    //   mag-display ng inline error "Incorrect Password!" sa ibaba ng password field
    //   → I-set ang _passwordError para ma-display sa ibaba ng password field
    // - Kung naabot na ang 5 attempts: i-set ang _isCoolingDown = true,
    //   mag-trigger ng 5-minute timer bago i-reset ang _loginAttempts at _isCoolingDown,
    //   at mag-send ng email notification sa user na may nag-try mag-access ng kanilang account
    //   (gamitin ang Firebase Email trigger o Cloud Function para dito)
    //
    // The code should be placed here

  }

  // --------------------------------------------------------
  // FORGOT PASSWORD HANDLER
  // Purpose: Inina-navigate ang user papunta sa OTP screen
  //          para sa password reset, with email validation.
  // --------------------------------------------------------
  void _handleForgotPassword() {
    FocusScope.of(context).unfocus();

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(email: emailController.text.trim()),
      ),
    );
  }

  // --------------------------------------------------------
  // BUILD METHOD
  // Purpose: Nagbu-build ng UI ng login screen. Kasama ang
  //          header texts, input fields, buttons, at logo.
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage())
          );
        }
        else if (state is Unauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Please try again!')),
          );
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
                        "EMAIL/USERNAME",
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
                            backgroundColor: const Color(0xFFB56A7E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: login,
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