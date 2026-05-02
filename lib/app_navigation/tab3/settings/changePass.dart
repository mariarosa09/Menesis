import 'package:flutter/material.dart';

// ============================================================
// ChangePasswordScreen – StatefulWidget
// Purpose: Nagpapakita ng Change Password screen.
// Allows the user to view their current password (read-only),
// enter a new password, and confirm it before updating.
// ============================================================
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // -------------------------------------------------------
  // Form Key
  // Purpose: Ginagamit para ma-validate ang form globally.
  // -------------------------------------------------------
  final _formKey = GlobalKey<FormState>();

  // -------------------------------------------------------
  // Text Controllers
  // Purpose: Kinokontrol ang text input ng bawat password field.
  // - currentPass: Read-only, shows the user's current password.
  // - newPass: Where the user types their new password.
  // - confirmPass: Where the user re-enters the new password.
  // -------------------------------------------------------
  final TextEditingController currentPass =
  TextEditingController(text: "basta password");
  final TextEditingController newPass = TextEditingController();
  final TextEditingController confirmPass = TextEditingController();

  // TODO: (EDIT) – I-replace ang hardcoded na "basta password" ng actual
  // na password value na galing sa database o auth provider (e.g., Firebase).
  // I-fetch ito sa initState() or sa constructor ng screen.
  // The code should be placed here

  // TODO: (ADD) – I-add ang variable para sa last password set date.
  // Kunin ito mula sa database at i-display sa label ng currentPass field.
  // Example: String lastSetDate = "";
  // The code should be placed here

  // -------------------------------------------------------
  // Visibility Toggles
  // Purpose: Kinokontrol kung visible o nakatago ang bawat password field.
  // -------------------------------------------------------
  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;

  // -------------------------------------------------------
  // Form Validity State
  // Purpose: Tracks kung valid na ang form para ma-enable ang submit button.
  // -------------------------------------------------------
  bool isValid = false;

  // -------------------------------------------------------
  // validateForm()
  // Purpose: Tini-trigger tuwing may nagbabago sa form.
  // Ino-update ang `isValid` depende sa current validation state.
  // -------------------------------------------------------
  void validateForm() {
    setState(() {
      isValid = _formKey.currentState?.validate() ?? false;
    });
  }

  // -------------------------------------------------------
  // handleSubmit()
  // Purpose: Tinatawag kapag pinindot ang "Update Password" button.
  // Nagpapakita ng success snackbar at bumabalik sa nakaraang screen.
  // -------------------------------------------------------
  void handleSubmit() {
    if (isValid) {
      // TODO: (EDIT) – I-replace ang SnackBar lang ng actual na password
      // update logic. I-call ang API o auth service (e.g., Firebase) para
      // i-update ang password ng user sa database.
      // The code should be placed here

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );
      Navigator.pop(context);
    }
  }

  // -------------------------------------------------------
  // validatePassword()
  // Purpose: Validates the new password field.
  // Returns an error message kung wala pang laman o hindi valid ang length.
  // NOTE: Returns null (no error) if field is empty — para hindi agad mag-error
  // bago pa man mag-type ang user.
  // -------------------------------------------------------
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 8 || value.length > 50) {
      return "8–50 characters required";
    }
    return null;
  }

  // -------------------------------------------------------
  // validateConfirm()
  // Purpose: Checks kung nag-match ang re-entered password sa new password.
  // Returns error message kung hindi match.
  // -------------------------------------------------------
  String? validateConfirm(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value != newPass.text) {
      return "Passwords do not match!";
    }
    return null;
  }

  // ============================================================
  // build()
  // Purpose: Nagbu-build ng buong UI ng Change Password screen.
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------
    // Match State – Real-time check kung nag-match na ang passwords
    // Purpose: Ginagamit para ipakita ang check/ekis icon sa confirm field
    // at para ma-control ang enabled state ng Update Password button.
    // -------------------------------------------------------
    final bool confirmHasText = confirmPass.text.isNotEmpty;
    final bool passwordsMatch =
        confirmHasText && confirmPass.text == newPass.text;
    final bool passwordsDoNotMatch =
        confirmHasText && confirmPass.text != newPass.text;

    return Scaffold(
      // -------------------------------------------------------
      // Background Gradient Container
      // Purpose: Nagbibigay ng soft gradient background sa buong screen.
      // -------------------------------------------------------
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF7F3F5),
              Color(0xFFF1E6EA),
            ],
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

                  // -------------------------------------------------------
                  // Header Row – Back Button + Screen Title
                  // Purpose: Navigation back button at ang title ng screen.
                  // -------------------------------------------------------
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

                  // -------------------------------------------------------
                  // Current Password Field (Read-Only)
                  // Purpose: Nagpapakita ng current password ng user.
                  // Hindi ito pwedeng i-edit — read-only ito.
                  // TODO #1: Display Current Password. Di dapat editable.
                  // -------------------------------------------------------
                  _styledInput(
                    controller: currentPass,

                    // TODO: (EDIT) – Palitan ang "{setDate}" ng actual na date
                    // value na kinuha sa database. Format example: "JAN 1, 2025".
                    // The code should be placed here
                    label: "CURRENT PASSWORD (LAST SET: {setDate})",

                    isPassword: true,
                    isVisible: showCurrent,
                    toggleVisibility: () =>
                        setState(() => showCurrent = !showCurrent),
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 20),

                  // -------------------------------------------------------
                  // New Password Field
                  // Purpose: Pwede dito mag-type ng bagong password ang user.
                  // May validation para sa minimum at maximum na character count.
                  // -------------------------------------------------------
                  _styledInput(
                    controller: newPass,
                    label: "NEW PASSWORD",
                    validator: validatePassword,
                    isPassword: true,
                    isVisible: showNew,
                    toggleVisibility: () =>
                        setState(() => showNew = !showNew),
                  ),
                  const SizedBox(height: 20),

                  // -------------------------------------------------------
                  // Confirm Password Field + Match/Mismatch Icon
                  // Purpose: Para ma-confirm ng user na tama ang na-type nilang
                  // bagong password. May suffix icon na nagpapakita ng:
                  //   ✅ Green check  – kung nag-match ang passwords
                  //   ❌ Red close    – kung hindi match
                  // TODO #2: Match indicator + button enable/disable logic.
                  // -------------------------------------------------------
                  _styledInput(
                    controller: confirmPass,
                    label: "RE-ENTER NEW PASSWORD",
                    validator: validateConfirm,
                    isPassword: true,
                    isVisible: showConfirm,
                    toggleVisibility: () =>
                        setState(() => showConfirm = !showConfirm),

                    // Pass the match icons as a suffix override
                    matchSuffixIcon: confirmHasText
                        ? Icon(
                      passwordsMatch ? Icons.check_circle : Icons.cancel,
                      color: passwordsMatch
                          ? Colors.green
                          : Colors.red,
                    )
                        : null,
                  ),
                  const SizedBox(height: 35),

                  // -------------------------------------------------------
                  // Update Password Button
                  // Purpose: I-submit ang form para i-update ang password.
                  // - Enabled (pink) kapag valid ang form at nag-match ang passwords.
                  // - Disabled (grey) kapag hindi pa valid o hindi match.
                  // TODO #2: Pag match ung re-enter password, enabled na ang button.
                  // -------------------------------------------------------
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
                      onPressed: (isValid && passwordsMatch) ? handleSubmit : null,
                      child: const Text("Update Password"),
                    ),
                  ),

                  // TODO: (ADD) – Pwedeng mag-add ng "Forgot Password?" link dito
                  // para ma-redirect ang user sa password recovery screen.
                  // The code should be placed here
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _styledInput() – Custom Styled Text Field Widget
  // Purpose: Reusable input field na may custom styling, label,
  // password toggle, error display, at optional match icon.
  // ============================================================
  Widget _styledInput({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool isVisible = false,
    bool isReadOnly = false,
    VoidCallback? toggleVisibility,

    // -------------------------------------------------------
    // matchSuffixIcon (optional)
    // Purpose: Nagpapakita ng check o ekis icon sa may gilid ng
    // confirm password field kapag may laman na ito.
    // -------------------------------------------------------
    Widget? matchSuffixIcon,
  }) {
    // -------------------------------------------------------
    // Inline Validator Call
    // Purpose: Nakukuha ang error text para ipakita sa ibaba
    // ng input field kung may validation error.
    // -------------------------------------------------------
    String? errorText;
    if (validator != null && !isReadOnly) {
      errorText = validator(controller.text);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------------------------------------------------------
        // Field Label
        // Purpose: Uppercase label na nagde-describe ng field.
        // -------------------------------------------------------
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.5,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),

        // -------------------------------------------------------
        // Input Container
        // Purpose: Custom na border at background ng text field.
        // - Grey background kapag read-only (current password).
        // - Red border kapag may validation error.
        // -------------------------------------------------------
        Container(
          decoration: BoxDecoration(
            color: isReadOnly
                ? Colors.grey.shade200
                : const Color(0xFFF8F3F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: errorText != null
                  ? Colors.red
                  : const Color(0xFFE6B7C2),
              width: errorText != null ? 1.5 : 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            obscureText: isPassword && !isVisible,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

              // -------------------------------------------------------
              // Suffix Icon Logic
              // Purpose: Nagpapakita ng tamang icon sa kanan ng field:
              // - Match/mismatch icon (check/ekis) para sa confirm field.
              // - Visibility toggle (eye icon) para sa password fields.
              // Priority: matchSuffixIcon > visibility toggle.
              // -------------------------------------------------------
              suffixIcon: matchSuffixIcon ??
                  (isPassword
                      ? IconButton(
                    icon: Icon(
                      isVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: toggleVisibility,
                  )
                      : null),
              border: InputBorder.none,
            ),
          ),
        ),

        // -------------------------------------------------------
        // Error Text Display
        // Purpose: Nagpapakita ng red error message sa ibaba ng field
        // kapag hindi valid ang input (e.g., "Passwords do not match!").
        // TODO #2: "Passwords do not match" message – nandito na ito.
        // -------------------------------------------------------
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 5),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}