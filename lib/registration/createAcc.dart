import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menesis_app/auth/presentation/auth_cubit.dart';
import 'package:menesis_app/registration/initialLength.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final middleInitialController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;
  bool _registerTapped = false; // Only show errors after first tap
  bool _isCheckingEmail = false;

  // ── Granular password requirement flags ──────────────────────────────────
  bool _pwHasLength = false;
  bool _pwHasUpper = false;
  bool _pwHasLower = false;
  bool _pwHasNumber = false;
  bool _pwHasSymbol = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(() => setState(() {}));
  }

  void _onPasswordChanged() {
    final v = passwordController.text;
    setState(() {
      _pwHasLength = v.length >= 8 && v.length <= 50;
      _pwHasUpper = v.contains(RegExp(r'[A-Z]'));
      _pwHasLower = v.contains(RegExp(r'[a-z]'));
      _pwHasNumber = v.contains(RegExp(r'[0-9]'));
      _pwHasSymbol = v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/`~;]'));
    });
  }

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

  // ── Derived getters ──────────────────────────────────────────────────────

  bool get _passwordValid =>
      _pwHasLength && _pwHasUpper && _pwHasLower && _pwHasNumber && _pwHasSymbol;

  bool get _passwordsMatch =>
      passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          passwordController.text == confirmPasswordController.text;

  bool get _emailValid =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim());

  bool get _formComplete =>
      firstNameController.text.trim().isNotEmpty &&
          emailController.text.trim().isNotEmpty &&
          _emailValid &&
          _passwordValid &&
          _passwordsMatch;

  // ── Auto-capitalize first letter ─────────────────────────────────────────
  String _capitalizeFirst(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  // ============================================================
  // _isSoftDeleted()
  // ============================================================
  Future<bool> _isSoftDeleted(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .where('deleted', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final data = query.docs.first.data();
    final deletedAt = data['deletedAt'] as Timestamp?;
    if (deletedAt == null) return true;

    const kWindowDays = 30;
    final expiresAt =
    deletedAt.toDate().add(const Duration(days: kWindowDays));
    return DateTime.now().isBefore(expiresAt);
  }

  // ============================================================
  // register()
  // ============================================================
  Future<void> register() async {
    setState(() => _registerTapped = true);

    if (!_formComplete) return;

    final email = emailController.text.trim();

    setState(() => _isCheckingEmail = true);

    try {
      final softDeleted = await _isSoftDeleted(email);
      if (!mounted) return;
      if (softDeleted) {
        setState(() => _isCheckingEmail = false);
        _showSoftDeletedEmailDialog();
        return;
      }
    } catch (_) {
      // Fall through — let Firebase Auth surface duplicate-email errors.
    }

    setState(() => _isCheckingEmail = false);

    final fname = firstNameController.text.trim();
    final mi = middleInitialController.text.trim();
    final lname = surnameController.text.trim();
    final password = passwordController.text.trim();

    if (!mounted) return;
    context.read<AuthCubit>().register(fname, mi, lname, email, password);
  }

  // ============================================================
  // _showSoftDeletedEmailDialog()
  // ============================================================
  void _showSoftDeletedEmailDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: const Color(0xFFFFFBFC),
        title: const Text(
          "Account Pending Deletion",
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A1F3D),
          ),
        ),
        content: const Text(
          "This email belongs to an account that is scheduled for deletion.\n\n"
              "You can log in with that account to recover it within the 30-day "
              "window, or wait until the account is permanently removed before "
              "registering again.",
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.black45, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // _parseAuthError()
  // ============================================================
  String _parseAuthError(AuthError state) {
    final code = state.message;
    if (code.contains('email-already-in-use')) {
      return 'Email is already in use.';
    } else if (code.contains('invalid-email')) {
      return 'Invalid email format.';
    } else if (code.contains('weak-password')) {
      return 'Password is too weak.';
    } else {
      return code.isNotEmpty ? code : 'Registration failed. Please try again.';
    }
  }

  // ============================================================
  // addUserDetails()
  // ============================================================
  Future<void> addUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final existingDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (existingDoc.exists) {
      final data = existingDoc.data();
      final alreadyDeleted = data?['deleted'] as bool? ?? false;
      if (alreadyDeleted) return;
    }

    final fname = firstNameController.text.trim();
    final mi = middleInitialController.text.trim();
    final lname = surnameController.text.trim();
    final email = emailController.text.trim();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'first name': fname,
      'middle initial': mi,
      'last name': lname,
      'email': email,
      'username': email.substring(0, email.indexOf('@')),
      'created at': FieldValue.serverTimestamp(),
      'deleted': false,
    });
  }

  Future<void> _onRegistrationSuccess() async {
    await addUserDetails();
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final bool confirmNotEmpty = confirmPasswordController.text.isNotEmpty;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is NeedVerification) {
          await _onRegistrationSuccess();
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              backgroundColor: const Color(0xFFFFFBFC),
              title: const Text(
                "Register",
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A1F3D),
                ),
              ),
              content: const Text(
                "Account verification sent on your email!\nPlease check your inbox.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    emailController.clear();
                  },
                  child: const Text("OK",
                      style: TextStyle(color: Colors.black45, fontSize: 14)),
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
                            content: Text("Verification email resent!"),
                            backgroundColor: Color(0xFFB56A7E),
                          ),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.message ?? 'An error occurred.'),
                          backgroundColor: const Color(0xFFB56A7E),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: const Color(0xFFB56A7E),
                        ),
                      );
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
            ),
          );
        } else if (state is AuthError) {
          final message = _parseAuthError(state);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: const Color(0xFFB56A7E),
            ),
          );
        } else if (state is VerifiedNeedsSetup) {
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PeriodSetupScreen()),
                (route) => false,
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    // ── Header ──────────────────────────────────────────
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
                                  child: Icon(Icons.arrow_back,
                                      color: Color(0xFF3A1F3D)),
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
                    const SizedBox(height: 5),
                    const Text(
                      "Fill in your details to get started",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // ── First Name + M.I. ───────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildNameField(
                            label: "First Name *",
                            controller: firstNameController,
                            showError: _registerTapped &&
                                firstNameController.text.trim().isEmpty,
                            errorText: "First name is required.",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: _buildMiddleInitialField(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Surname ─────────────────────────────────────────
                    _buildNameField(
                      label: "Surname",
                      controller: surnameController,
                      showError: false,
                    ),
                    const SizedBox(height: 20),

                    // ── Email ───────────────────────────────────────────
                    _buildEmailField(),
                    const SizedBox(height: 20),

                    // ── Password ────────────────────────────────────────
                    _buildPasswordField(),
                    const SizedBox(height: 8),

                    // Password requirements (always visible once user starts typing)
                    _buildPasswordRequirements(),
                    const SizedBox(height: 20),

                    // ── Confirm Password ────────────────────────────────
                    _buildConfirmPasswordField(confirmNotEmpty),
                    const SizedBox(height: 30),

                    // ── Register button ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: _isCheckingEmail
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFB56A7E),
                        ),
                      )
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _formComplete
                              ? const Color(0xFFB56A7E)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding:
                          const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _formComplete
                            ? register
                            : () {
                          // Still allow tap to show errors
                          setState(() => _registerTapped = true);
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Already have an account? Sign in",
                          style: TextStyle(color: Color(0xFFB4697D)),
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
      ),
    );
  }

  // ============================================================
  // FIELD BUILDERS
  // ============================================================

  /// Generic name field with auto-capitalize and optional error.
  Widget _buildNameField({
    required String label,
    required TextEditingController controller,
    required bool showError,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) {
            if (v.isNotEmpty && v[0] != v[0].toUpperCase()) {
              final newVal = _capitalizeFirst(v);
              controller.value = controller.value.copyWith(
                text: newVal,
                selection: TextSelection.collapsed(offset: newVal.length),
              );
            }
            setState(() {});
          },
          decoration: _inputDecoration(
            errorText: showError ? errorText : null,
          ),
        ),
      ],
    );
  }

  /// Middle initial: max 1 char, auto-uppercase.
  Widget _buildMiddleInitialField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("M.I.",
            style: TextStyle(fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: middleInitialController,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
            _UpperCaseTextFormatter(),
          ],
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  /// Email field with inline info hint and post-tap error.
  Widget _buildEmailField() {
    final text = emailController.text.trim();
    final isEmpty = text.isEmpty;
    final isInvalid = text.isNotEmpty && !_emailValid;

    String? errorText;
    if (_registerTapped && isEmpty) {
      errorText = "Email is required.";
    } else if (_registerTapped && isInvalid) {
      errorText = "Enter a valid email address.";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("EMAIL ADDRESS *",
            style: TextStyle(fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            errorText: errorText,
            helperText: errorText == null
                ? "Use a valid email (e.g. user@email.com)"
                : null,
            helperStyle:
            const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ),
      ],
    );
  }

  /// Password field.
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PASSWORD *",
            style: TextStyle(fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: obscure1,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            suffixIcon: IconButton(
              icon: Icon(obscure1 ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => obscure1 = !obscure1),
            ),
          ),
        ),
      ],
    );
  }

  /// Password requirements widget — always visible when password is non-empty.
  Widget _buildPasswordRequirements() {
    final show = passwordController.text.isNotEmpty;
    if (!show) return const SizedBox(height: 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8B7C3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Password must contain:",
              style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 6),
          _reqRow(_pwHasLength, "8–50 characters"),
          _reqRow(_pwHasUpper, "At least one uppercase letter (A–Z)"),
          _reqRow(_pwHasLower, "At least one lowercase letter (a–z)"),
          _reqRow(_pwHasNumber, "At least one number (0–9)"),
          _reqRow(_pwHasSymbol, "At least one symbol (!@#\$%^&*…)"),
        ],
      ),
    );
  }

  Widget _reqRow(bool met, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: met ? const Color(0xFF4CAF50) : Colors.redAccent,
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: met ? const Color(0xFF4CAF50) : Colors.black54)),
        ],
      ),
    );
  }

  /// Confirm password field with ✓/✗ suffix icon.
  Widget _buildConfirmPasswordField(bool confirmNotEmpty) {
    Widget? suffixIcon;
    if (confirmNotEmpty) {
      suffixIcon = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _passwordsMatch ? Icons.check_circle : Icons.cancel,
            color: _passwordsMatch
                ? const Color(0xFF4CAF50)
                : Colors.redAccent,
            size: 20,
          ),
          IconButton(
            icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => obscure2 = !obscure2),
          ),
        ],
      );
    } else {
      suffixIcon = IconButton(
        icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => obscure2 = !obscure2),
      );
    }

    String? errorText;
    if (_registerTapped && confirmPasswordController.text.isEmpty) {
      errorText = "Please confirm your password.";
    } else if (confirmNotEmpty && !_passwordsMatch) {
      errorText = "Passwords do not match.";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("CONFIRM PASSWORD *",
            style: TextStyle(fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: obscure2,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            suffixIcon: suffixIcon,
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  // ── Shared InputDecoration ────────────────────────────────────────────────
  InputDecoration _inputDecoration({
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    String? helperText,
    TextStyle? helperStyle,
  }) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFFFBFC),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      errorText: errorText,
      helperText: helperText,
      helperStyle: helperStyle,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE8B7C3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFB56A7E), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

// ============================================================
// UpperCase text formatter for middle initial
// ============================================================
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}