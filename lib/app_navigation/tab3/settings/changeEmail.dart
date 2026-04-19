import 'package:flutter/material.dart';
import '../../../otp.dart';

// ============================================================
// ENTRY POINT
// Only used for standalone testing/preview ng screen.
// Sa actual app, itong main() ay hindi na kailangan.
// ============================================================
void main() {
  runApp(const MyApp());
}

// ============================================================
// ROOT APP WIDGET (for standalone preview only)
// Wraps the ChangeEmailScreen inside a MaterialApp para
// marender ito nang maayos kapag pinapatakbo nang hiwalay.
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeEmailScreen(),
    );
  }
}

// ============================================================
// CHANGE EMAIL SCREEN (StatefulWidget)
// Ito ang pangunahing screen para sa pagpapalit ng email.
// Ginagamit ang StatefulWidget dahil may form validation
// at navigation logic na nangyayari dito.
// ============================================================
class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  // ----------------------------------------------------------
  // FORM KEY & CONTROLLERS
  // _formKey: ginagamit para i-validate ang form fields.
  // newEmail: controller para sa "New Email" text field.
  // ----------------------------------------------------------
  final _formKey = GlobalKey<FormState>();
  final TextEditingController newEmail = TextEditingController();

  // ----------------------------------------------------------
  // CURRENT EMAIL (Static/Display Only)
  // Ito ang kasalukuyang email ng user. Hindi ito editable.
  // TODO: (EDIT) - I-replace ang hardcoded na currentEmail ng
  // actual na email na galing sa user session o database.
  // Halimbawa, kunin sa SharedPreferences, Provider, o API call.
  // The code should be placed here
  // ----------------------------------------------------------
  final String currentEmail = "user@email.com";

  // ----------------------------------------------------------
  // EMAIL VALIDATOR
  // Sinisigurado nito na hindi blank ang input at valid
  // ang format ng email bago payagan ang user na mag-proceed.
  // ----------------------------------------------------------
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a valid email";
    }

    // Checks kung may tamang email format (may @, may domain, etc.)
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Please enter a valid email";
    }

    // TODO: (EDIT) - Pwedeng dagdagan ng check kung ang bagong email
    // ay hindi pareho sa currentEmail para maiwasan ang unnecessary update.
    // The code should be placed here

    return null;
  }

  // ----------------------------------------------------------
  // HANDLE VERIFY BUTTON
  // Pinipigilan muna ang keyboard, pagkatapos i-validate ang form.
  // Kung valid, mag-navigate papunta sa OTP screen.
  // TANDAAN: Ang handleVerify() method na ito ay hindi na ginagamit
  // sa build() — direkta na ang logic sa button. Pwedeng alisin
  // o gamitin para mas malinis ang code. Pinili naming panatilihin
  // para hindi masira ang original na structure.
  // ----------------------------------------------------------
  void handleVerify() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(email: newEmail.text),
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // DISPOSE
  // Linisin ang controller kapag wala na itong ginagamit
  // para maiwasan ang memory leak.
  // ----------------------------------------------------------
  @override
  void dispose() {
    newEmail.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD METHOD — Pangunahing UI ng screen
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --------------------------------------------------------
      // BACKGROUND GRADIENT CONTAINER
      // Nagbibigay ng magandang gradient background mula
      // sa itaas hanggang sa ibaba ng screen.
      // --------------------------------------------------------
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  // --------------------------------------------
                  // HEADER ROW — Back Button + Screen Title
                  // Naglalagay ng back arrow button at "Change Email"
                  // na pamagat sa tuktok ng screen.
                  // --------------------------------------------
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
                          "Change Email",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A1F3D),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --------------------------------------------
                  // CURRENT EMAIL DISPLAY (Read-Only)
                  // Ipinapakita ang kasalukuyang email ng user.
                  // Hindi ito editable — display only.
                  //
                  // TODO (User Input #1): (EDIT) - Palitan ang
                  // hardcoded na `currentEmail` ng actual na data
                  // mula sa user session, SharedPreferences, o API.
                  // The code should be placed here
                  // --------------------------------------------
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "EMAIL",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A4E5D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFE0C8D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 10),

                            // Ipinapakita ang currentEmail bilang plain text.
                            // Walang TextEditingController — di talaga ito editable.
                            Expanded(
                              child: Text(
                                currentEmail,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --------------------------------------------
                  // NEW EMAIL INPUT FIELD
                  // Dito nagta-type ang user ng bagong email.
                  // May validator na nagsisiguro ng tamang format.
                  //
                  // TODO (User Input #4): (EDIT) - Ang validator
                  // ay nagre-return na ng "Please enter a valid email"
                  // kapag mali ang format. Awtomatiko itong lumalabas
                  // sa ilalim ng field. Walang karagdagang widget
                  // na kailangan — ginagawa na ito ng TextFormField.
                  // The code should be placed here
                  // --------------------------------------------
                  _inputField(
                    controller: newEmail,
                    label: "NEW EMAIL",
                    hint: "new@email.com",
                    validator: validateEmail,
                  ),

                  const SizedBox(height: 30),

                  // --------------------------------------------
                  // VERIFY NEW EMAIL BUTTON
                  // Kapag pinindot ito:
                  //   1. Tinatanggal ang keyboard
                  //   2. Vina-validate ang form
                  //   3. Kung valid — pupunta sa OTP screen
                  //   4. Kung invalid — hindi pupunta, lalabas ang
                  //      warning message sa ilalim ng input field
                  //
                  // TODO (User Input #2 & #3): (EDIT) - Para sa OTP screen ito,
                  // ipadala ang verification code sa bagong email.
                  // Kapag tama ang code: mag-update ng email sa backend
                  // at magpakita ng success SnackBar o dialog.
                  // Kapag mali ang code: ipakita ang "Invalid code! Please Try Again".
                  // The code should be placed here
                  // --------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Itanggal ang keyboard bago i-validate
                        FocusScope.of(context).unfocus();

                        // Mag-navigate sa OTP screen kung valid ang email
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OtpVerificationScreen(email: newEmail.text),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB56A7E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Verify New Email",
                        style: TextStyle(color: Colors.white),
                      ),
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

  // ==========================================================
  // REUSABLE INPUT FIELD WIDGET
  // Helper method na gumagawa ng styled TextFormField
  // para hindi paulit-ulit ang code. May label at validator support.
  // ==========================================================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    String? label,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ipinapakita ang label kung may naibigay
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7A4E5D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Ang aktwal na text input field na may validation support
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}