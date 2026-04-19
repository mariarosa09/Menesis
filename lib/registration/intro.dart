import 'package:flutter/material.dart';
import 'main.dart';

// Introduction Screen - The first screen users see when they open the app.
// It shows the app branding, a short description, feature highlights,
// and a button to proceed to the Login Screen.

// TODO: Siguraduhing ang screen na ito ay isang beses lang ipapakita —
// sa unang pagbubukas ng app pagkatapos i-download. Gamitin ang shared_preferences
// o katulad na paraan para suriin kung bagong user o hindi bago ipakita ang screen na ito.

class Introduction extends StatelessWidget {
  const Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // ── UPPER SECTION ──────────────────────────────────────────────
          // Shows the gradient background, decorative circle,
          // the app logo, and the app tagline.
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                // Gradient background going from dark to lighter purple-pink
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3E1F30),
                    Color(0xFF6B3A55),
                    Color(0xFF8C4F6B),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),

              child: Stack(
                children: [

                  // Decorative outline circle on the left side (background detail)
                  Positioned(
                    top: 40,
                    left: -120,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                    ),
                  ),

                  // App logo with a soft glow effect, placed at the top right
                  Positioned(
                    top: 50,
                    right: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEAD7B7).withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 75,
                      ),
                    ),
                  ),

                  // App tagline text placed at the bottom left of the upper section
                  const Positioned(
                    bottom: 35,
                    left: 25,
                    right: 25,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Small label above the main title
                        Text(
                          "YOUR PERSONAL",
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 3,
                            color: Colors.white70,
                          ),
                        ),

                        SizedBox(height: 8),

                        // Main title of the app
                        Text(
                          "Cycle Companion",
                          style: TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 34,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── BOTTOM SECTION ─────────────────────────────────────────────
          // Shows the app description, feature icons, and the Continue button.
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 22),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F3F5),
                // Rounded top corners to overlap the upper gradient section
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Section headline
                  const Text(
                    "Track your cycle with confidence",
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A1F3D),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Short description of what the app does
                  const Text(
                    "Understand your body, predict your phases, and get personalized care — all in one safe space.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Feature highlights shown as icon + label pairs
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FeatureItem(icon: Icons.calendar_month, label: "Track"),
                      _FeatureItem(icon: Icons.insights, label: "Predict"),
                      _FeatureItem(icon: Icons.favorite, label: "Care"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Continue button — navigates the user to the Login Screen
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB56A7E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to the Login Screen when the button is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ── FEATURE ITEM WIDGET ────────────────────────────────────────────────────
// A reusable widget that shows a single feature as an icon inside a
// rounded box with a label below it. Used in the feature highlights row.
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Icon container with a soft pink background
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFEADFE5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            size: 30,
            color: const Color(0xFF7B3F61),
          ),
        ),

        const SizedBox(height: 8),

        // Feature label below the icon
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}