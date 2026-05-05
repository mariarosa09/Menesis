import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController currentPass = TextEditingController();
  final TextEditingController newPass = TextEditingController();
  final TextEditingController confirmPass = TextEditingController();

  bool showNew = false;
  bool showConfirm = false;
  bool isValid = false;

  // Holds the inline error for the current password field (e.g. wrong password)
  String? _currentPasswordError;

  void validateForm() {
    setState(() {
      isValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> handleSubmit() async {
    if (!isValid) return;

    // Clear any previous inline error
    setState(() => _currentPasswordError = null);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return;

      // 1. Re-authenticate with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPass.text,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Update password
      await user.updatePassword(newPass.text);

      // 3. Save timestamp to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {'passwordLastSet': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        // Show error inline on the current password field
        setState(() => _currentPasswordError = "Current password is incorrect.");
      } else if (e.code == 'too-many-requests') {
        setState(
                () => _currentPasswordError = "Too many attempts. Try again later.");
      } else {
        setState(() => _currentPasswordError = "Failed to update password.");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred.")),
      );
    }
  }

  String? validateCurrentPassword(String? value) {
    // Only block submission when empty; no error shown for empty field
    if (value == null || value.isEmpty) return "required";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return null;

    final List<String> errors = [];

    if (value.length < 8 || value.length > 50) {
      errors.add("minimum of 8 characters");
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      errors.add("one uppercase letter");
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      errors.add("one lowercase letter");
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      errors.add("one digit");
    }
    if (!value.contains(
        RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/`~;]'))) {
      errors.add("one special character");
    }

    if (errors.isEmpty) return null;
    if (errors.length == 1) return "Password must contain ${errors[0]}.";
    return "Password must contain: ${errors.join(', ')}.";
  }

  String? validateConfirm(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value != newPass.text) return "Passwords do not match!";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool confirmHasText = confirmPass.text.isNotEmpty;
    final bool newHasText = newPass.text.isNotEmpty;
    final bool passwordsMatch =
        confirmHasText && newHasText && confirmPass.text == newPass.text;
    final bool passwordsMismatch =
        confirmHasText && newHasText && confirmPass.text != newPass.text;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F3F5), Color(0xFFF1E6EA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              onChanged: validateForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
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
                          "Change Password",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A1F3D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ── Current password (no eye, no empty-field error, inline wrong-password error) ──
                  _styledInput(
                    controller: currentPass,
                    label: "CURRENT PASSWORD",
                    validator: validateCurrentPassword,
                    isPassword: true,
                    isVisible: false,
                    showEye: false,
                    externalError: _currentPasswordError,
                    onChanged: (_) {
                      // Clear the inline error as soon as the user types again
                      if (_currentPasswordError != null) {
                        setState(() => _currentPasswordError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── New password (eye + match icon side by side) ──
                  _styledInput(
                    controller: newPass,
                    label: "NEW PASSWORD",
                    validator: validatePassword,
                    isPassword: true,
                    isVisible: showNew,
                    toggleVisibility: () =>
                        setState(() => showNew = !showNew),
                    matchIcon: newHasText
                        ? Icon(
                      passwordsMatch
                          ? Icons.check_circle
                          : Icons.cancel,
                      color:
                      passwordsMatch ? Colors.green : Colors.red,
                      size: 20,
                    )
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // ── Confirm password (eye + match icon side by side) ──
                  _styledInput(
                    controller: confirmPass,
                    label: "RE-ENTER NEW PASSWORD",
                    validator: validateConfirm,
                    isPassword: true,
                    isVisible: showConfirm,
                    toggleVisibility: () =>
                        setState(() => showConfirm = !showConfirm),
                    matchIcon: confirmHasText
                        ? Icon(
                      passwordsMatch
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: passwordsMatch ? Colors.green : Colors.red,
                      size: 20,
                    )
                        : null,
                  ),
                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isValid && passwordsMatch)
                            ? const Color(0xFFB56A7E)
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: (isValid && passwordsMatch)
                          ? () async => await handleSubmit()
                          : null,
                      child: const Text("Update Password"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledInput({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool isVisible = false,
    bool showEye = true,
    bool isReadOnly = false,
    VoidCallback? toggleVisibility,
    /// Optional match icon placed BESIDE the eye icon
    Widget? matchIcon,
    /// Externally-supplied error (e.g. wrong-password from Firebase)
    String? externalError,
    ValueChanged<String>? onChanged,
  }) {
    // Compute validation error (only for non-empty, non-readonly fields)
    String? validationError;
    if (validator != null && !isReadOnly && controller.text.isNotEmpty) {
      final result = validator(controller.text);
      // "required" is a sentinel used only to block isValid; don't render it
      if (result != null && result != "required") {
        validationError = result;
      }
    }

    // External error takes precedence when set
    final String? displayError = externalError ?? validationError;

    // Build suffix: eye button (optional) + match icon (optional), side by side
    Widget? suffix;
    if (isPassword) {
      final List<Widget> suffixWidgets = [];

      if (matchIcon != null) {
        suffixWidgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: matchIcon,
          ),
        );
      }

      if (showEye) {
        suffixWidgets.add(
          IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: toggleVisibility,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        );
      }

      if (suffixWidgets.isNotEmpty) {
        suffix = Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: suffixWidgets,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, letterSpacing: 1.5, color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isReadOnly
                ? Colors.grey.shade200
                : const Color(0xFFF8F3F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: displayError != null
                  ? Colors.red
                  : const Color(0xFFE6B7C2),
              width: displayError != null ? 1.5 : 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            obscureText: isPassword && !isVisible,
            onChanged: (v) {
              setState(() {});
              onChanged?.call(v);
            },
            // Return null always — we draw errors ourselves below
            validator: (v) {
              if (validator == null) return null;
              final result = validator(v);
              // Keep the sentinel so isValid reflects the empty-field state
              return result;
            },
            decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: suffix,
              suffixIconConstraints: const BoxConstraints(),
              border: InputBorder.none,
              // Suppress Flutter's own error rendering
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
          ),
        ),
        if (displayError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 5),
            child: Text(displayError,
                style: const TextStyle(color: Colors.red, fontSize: 11)),
          ),
      ],
    );
  }
}