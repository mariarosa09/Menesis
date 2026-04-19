import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menesis_app/app_navigation/tab2/homepage.dart';
import 'package:menesis_app/auth/presentation/auth_cubit.dart';
import 'package:menesis_app/registration/initialLength.dart';

// ============================================================
// NOTE: Uncomment the block below ONLY if running this file
// as a standalone app (for testing purposes).
// Sa actual project, huwag i-uncomment ito — baka mag-conflict
// sa existing main.dart.
// ============================================================
/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mēnesis',
      home: const CreateAccountScreen(),
    );
  }
}
*/

// TODO: [ADDING] I-save ang bagong account sa database
// Pagka-register ng user, i-store ang kanilang info (name, email, hashed password, at auto-generated username)
// sa isang database (e.g., Firebase Firestore, Supabase, o SQLite).
// The code should be placed here

// TODO: [ADDING] Auto-generate username pagka-register
// Gumawa ng logic na mag-a-auto-generate ng unique username (e.g., @user_mēnesis_4821).
// Bibigyan ng pagpipilian ang user na baguhin ito later sa settings screen —
// similar sa TikTok/Twitter na may default username muna bago palitan.
// The code should be placed here

// TODO: [ADDING] After registration, i-navigate sa initialLength screen
// Kapag successful ang registration, i-redirect ang user sa initialLength.dart screen
// para itanong ang period at cycle length. Ang screen na ito ay mag-aappear ONCE lang
// para sa mga bagong users (first-time setup). Gumamit ng flag sa database o
// SharedPreferences para ma-track kung nagawa na ito ng user.
// The code should be placed here

// ============================================================
// CreateAccountScreen — StatefulWidget
// This is the main registration screen ng app. Dito naglalagay
// ng details ang user para gumawa ng account.
// ============================================================

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // ============================================================
  // Form Key & Text Controllers
  // Ginagamit ang _formKey para ma-validate ang buong form.
  // Bawat controller ay naka-assign sa isang specific text field.
  // ============================================================
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final middleInitialController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ============================================================
  // Password Visibility & Form Validity State
  // obscure1/2 — controls kung makikita o hindi ang password.
  // isValid — kung true, naka-enable ang Register button.
  // ============================================================
  bool obscure1 = true;
  bool obscure2 = true;
  bool isValid = false;

  // ============================================================
  // dispose() — Memory Cleanup
  // IMPORTANT: I-dispose ang lahat ng TextEditingControllers
  // para maiwasan ang memory leaks kapag nag-leave ng screen ang user.
  // ============================================================
  @override
  void dispose() {
    firstNameController.dispose();
    middleInitialController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // validateForm()
  // Tine-trigger ito sa bawat pagbabago sa form (onChanged).
  // Sinisigurado na:
  //   - Valid lahat ng fields na may validator
  //   - Hindi blank ang email
  //   - Magkatugma ang password at confirm password
  // Kapag valid lahat, nag-a-enable ang Register button.
  // ============================================================
  void validateForm() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final emailNotEmpty = emailController.text.isNotEmpty;
    final passwordsMatch =
        passwordController.text == confirmPasswordController.text &&
            passwordController.text.isNotEmpty &&
            confirmPasswordController.text.isNotEmpty;

    setState(() {
      isValid = formValid && emailNotEmpty && passwordsMatch;
    });
  }

  void register() {
    final String fname = firstNameController.text;
    final String mi = middleInitialController.text;
    final String lname = surnameController.text;
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    final authCubit = context.read<AuthCubit>();

    authCubit.register(fname, mi, lname, email, password);
  }

// ============================================================
  // build() — Main UI
  // Nagtatayo ng buong Create Account screen.
  // Gumagamit ng SafeArea para hindi matakpan ng notch/status bar,
  // at SingleChildScrollView para ma-scroll ang form kapag maliit ang screen.
  // Inalis ang Stack wrapper dahil wala itong ibang layers na ginagamit —
  // sapat na ang Padding directly.
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PeriodSetupScreen())
          );
        }
        else if (state is Unauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Register failed. Please try again!')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F3F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              onChanged: validateForm,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    // ============================================================
                    // Header Row — Back Button + Title
                    // Ang back arrow ay nagre-return sa previous screen.
                    // Ang title na "Create Account" ay nakalagay sa tabi nito.
                    // Ginamit ang Transform.translate para ma-align nang maayos
                    // ang icon at text nang hindi gumagamit ng dagdag na padding.
                    // ============================================================
                    Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(-15, 0),
                          child: SizedBox(
                            width: 45,
                            height: 45,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(12),
                                splashColor:
                                const Color(0xFFB56A7E).withOpacity(0.2),
                                highlightColor:
                                const Color(0xFFB56A7E).withOpacity(0.3),
                                child: const Center(
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF3A1F3D),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(-15, 0),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A1F3D),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ============================================================
                    // Subtitle Text
                    // Simpleng instructional text para ma-guide ang user.
                    // ============================================================
                    const SizedBox(height: 5),
                    const Text(
                      "Fill in your details to get started",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // ============================================================
                    // First Name + Middle Initial Row
                    // Dalawang fields na nakalagay side by side.
                    // Ang First Name ay may mas malaking flex (2) kumpara sa M.I. (1).
                    // ============================================================
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: buildField(
                            "First Name",
                            controller: firstNameController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: buildField(
                            "M.I.",
                            controller: middleInitialController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ============================================================
                    // Surname, Email, Password, Confirm Password Fields
                    // Bawat isa ay gumagamit ng buildField() helper widget.
                    // May validators ang email at password fields para sa
                    // format at length checking.
                    // ============================================================
                    buildField(
                      "Surname",
                      controller: surnameController,
                    ),
                    const SizedBox(height: 20),
                    buildField(
                      "Email Address *",
                      controller: emailController,
                      hint: "example@email.com",
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    buildField(
                      "Enter Password",
                      controller: passwordController,
                      isPassword: true,
                      obscure: obscure1,
                      toggle: () => setState(() => obscure1 = !obscure1),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (value.length < 8) return "8–50 characters required";
                        if (value.length > 50) return "Maximum 50 characters";
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    buildField(
                      "Re-enter Password",
                      controller: confirmPasswordController,
                      isPassword: true,
                      obscure: obscure2,
                      toggle: () => setState(() => obscure2 = !obscure2),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // ============================================================
                    // Register Button
                    // Naka-disable (grey) kapag hindi pa valid ang form.
                    // Nag-e-enable (pink) kapag valid na lahat ng fields.
                    // onPressed ay naka-null kapag hindi valid — Flutter convention
                    // para sa disabled button state.
                    // ============================================================
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isValid
                              ? const Color(0xFFB56A7E)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: isValid
                            ? () {
                              register();
                              final state = context.read<AuthCubit>().state;
                                if(state is Authenticated) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => HomePage()),
                                  );
                                }
                          // TODO: [EDIT] I-call dito ang registration logic
                          // Ilagay dito ang function na mag-sa-save ng user info
                          // sa database, mag-ge-generate ng username, at
                          // mag-na-navigate sa initialLength screen.
                          // The code should be placed here
                        }
                            : null,
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ============================================================
                    // Sign In Redirect
                    // Para sa mga user na mayroon nang account.
                    // Nagre-redirect pabalik sa previous screen (Login screen).
                    // ============================================================
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Already have an account? Sign in",
                          style: TextStyle(
                            color: Color(0xFFB4697D),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  // ============================================================
  // buildField() — Reusable Text Field Widget
  // Gumagawa ng labeled input field na may consistent styling.
  // Suportado ang:
  //   - Optional validator para sa format/length checking
  //   - Password mode (obscureText + visibility toggle icon)
  //   - Hint text para sa placeholder
  // Ginagamit ito para maiwasan ang paulit-ulit na code sa bawat field.
  // ============================================================
  Widget buildField(
      String label, {
        TextEditingController? controller,
        bool isPassword = false,
        bool obscure = false,
        VoidCallback? toggle,
        String? Function(String?)? validator,
        String? hint,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label — nakalagay sa itaas ng input box, all caps with letter spacing
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),

        // ============================================================
        // TextFormField — Actual Input Box
        // Naka-style para mag-match sa overall pink/mauve theme ng app.
        // Ang errorBorder at focusedErrorBorder ay idinagdag para
        // malinaw na makita ng user kung may validation error.
        // ============================================================
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: toggle,
            )
                : null,
            filled: true,
            fillColor: const Color(0xFFFFFBFC),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE8B7C3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFB56A7E),
                width: 2,
              ),
            ),
            // Added: error state borders para visible ang validation errors
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
              const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}