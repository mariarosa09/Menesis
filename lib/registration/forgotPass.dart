import 'package:flutter/material.dart';

/// ============================================================
/// ForgotPasswordScreen
/// - Displays the UI para sa password reset ng user.
/// - Stateless widget kasi walang state management dito sa ngayon.
///   (Magiging StatefulWidget na ito pag nalagyan ng logic.)
/// ============================================================

// TODO: (EDIT) — I-convert ang widget na ito mula StatelessWidget papuntang
// StatefulWidget para ma-manage ang mga state tulad ng:
// - Loading state habang nagse-send ng reset code
// - Visibility ng "Enter Code" section pagkatapos mag-send
// - Error/success messages
// The code should be placed here

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F5),
      body: SafeArea(
        child: Stack(
          children: [

            // ─────────────────────────────────────────────────
            // MAIN CONTENT
            // Lahat ng visible na content (icon, title, fields,
            // buttons) ay nakalagay dito sa isang scrollable column.
            // Ginagamit ang SingleChildScrollView para hindi mag-overflow
            // ang content sa maliliit na screen.
            // ─────────────────────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 70),

                  // ─────────────────────────────────────────────────
                  // KEY ICON CONTAINER
                  // Decorative icon na nagse-serve as visual cue
                  // na ito ay password-related na screen.
                  // ─────────────────────────────────────────────────
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E4E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.key,
                      color: Color(0xFFB56A7E),
                      size: 35,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─────────────────────────────────────────────────
                  // TITLE & DESCRIPTION
                  // Nagpapaliwanag sa user kung ano ang gagawin nila
                  // sa screen na ito.
                  // ─────────────────────────────────────────────────
                  const Text(
                    "Reset password",
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A1F3D),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "No worries! Enter the email address linked to your account and we'll send a reset code.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ─────────────────────────────────────────────────
                  // EMAIL INPUT FIELD
                  // Dito nagta-type ang user ng kanilang email address.
                  // May label sa itaas at styled na text field sa ibaba.
                  // ─────────────────────────────────────────────────
                  const Text(
                    "EMAIL ADDRESS",
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TODO: (EDIT) — Lagyan ng TextEditingController ang TextField na ito
                  // para ma-capture ang email input ng user at magamit sa pagpapadala ng reset code.
                  // Example: final _emailController = TextEditingController();
                  // The code should be placed here

                  // TODO: (EDIT) — Lagyan ng input validation para masiguro na valid
                  // ang format ng email bago mag-send (e.g., may "@" at ".com").
                  // The code should be placed here

                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.mail_outline),
                      filled: true,
                      fillColor: const Color(0xFFFFFBFC),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color(0xFFE8B7C3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color(0xFFB56A7E),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ─────────────────────────────────────────────────
                  // SEND RESET CODE BUTTON
                  // Kapag pinindot ito ng user, magpapadala ng
                  // reset code sa kanilang email.
                  // ─────────────────────────────────────────────────

                  // TODO: (EDIT) — I-update ang onPressed para:
                  // 1. I-validate muna ang email field (hindi dapat blank/invalid).
                  // 2. Mag-call ng backend/Firebase function na magpapadala ng
                  //    6-digit verification code sa email ng user.
                  // 3. Pagkatapos mag-send, ipakita ang "Enter Code" section
                  //    (i-toggle ang visibility ng code input field sa ibaba).
                  // 4. Magpakita ng loading indicator habang nagse-send.
                  // The code should be placed here

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB56A7E),
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        // TODO: (ADD) — Ilagay dito ang logic para mag-send ng reset code sa email.
                        // The code should be placed here
                      },
                      child: const Text("Send reset code"),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ─────────────────────────────────────────────────
                  // VERIFICATION CODE INPUT SECTION
                  // Lalabas lang ito PAGKATAPOS mag-send ng code sa email.
                  // Dito ilalagay ng user ang code na natanggap nila.
                  // (Nakatago muna ito — ipapakita pagkatapos mag-send)
                  // ─────────────────────────────────────────────────

                  // TODO: (ADD) — Gawin itong conditional widget na nagpapakita lang
                  // kung nag-send na ng code (e.g., gamit ang _codeSent boolean state).
                  // Dapat naglalaman ng:
                  // - Label na "VERIFICATION CODE"
                  // - TextField para ilagay ang 6-digit code mula sa email
                  // - "Verify Code" button na mag-che-check kung tama ang code:
                  //     • If TAMA: Mag-navigate sa "Enter New Password" screen
                  //     • If MALI: Magpakita ng error message na "Invalid code! Please Try Again"
                  // The code should be placed here

                  // TODO: (ADD) — Gumawa ng bagong screen o dialog para sa
                  // "Enter new password" at "Re-enter new password" fields.
                  // Ito ang lalabas kapag tama na ang na-verify na code.
                  // The code should be placed here

                  // ─────────────────────────────────────────────────
                  // BACK TO SIGN IN LINK
                  // Nagbibigay ng option sa user na bumalik sa login screen
                  // kung naalala na nila ang kanilang password.
                  // ─────────────────────────────────────────────────
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Remember it? Sign In",
                        style: TextStyle(
                          color: Color(0xFFB4697D),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─────────────────────────────────────────────────
                  // TIP BOX
                  // Nagbibigay ng helpful reminder sa user na
                  // tingnan ang spam folder kung hindi makita ang email.
                  // ─────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8EFF2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Check your spam folder if you don't see the email within a few minutes.",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),

            // ─────────────────────────────────────────────────
            // BACK ARROW BUTTON (Top Left)
            // Positioned button para sa navigation pabalik.
            // Ginagamit ang InkWell para may ripple effect
            // na may matching na brand color.
            // ─────────────────────────────────────────────────
            Positioned(
              top: 15,
              left: 5,
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
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}