import 'package:flutter/material.dart';
import 'package:menesis_app/app_navigation/tab2/homepage.dart';

// ============================================================
// SCREEN: PeriodSetupScreen
// PURPOSE: Allows the user to set up their menstrual cycle
//          preferences during onboarding (first-time setup only).
//          Collects: cycle type, period length, and cycle length.
// ============================================================

// TODO: (ADDING) - I-check kung new user bago ipakita ang screen na ito.
// Dapat isang beses lang mag-appear ang PeriodSetupScreen (onboarding only).
// Gamitin ang SharedPreferences o database flag para malaman kung
// naka-setup na ang user. Kung naka-setup na, i-skip ang screen na ito
// at pumunta na sa main screen.
// The code should be placed here

class PeriodSetupScreen extends StatefulWidget {
  const PeriodSetupScreen({super.key});

  @override
  State<PeriodSetupScreen> createState() => _PeriodSetupScreenState();
}

class _PeriodSetupScreenState extends State<PeriodSetupScreen> {

  // ============================================================
  // STATE VARIABLES
  // PURPOSE: Stores the user's current selections for period
  //          length, cycle length, and cycle type.
  // ============================================================
  int periodLength = 3;
  int cycleLength = 28;
  String cycleType = "Regular";

  // ============================================================
  // INCREMENT / DECREMENT HANDLERS
  // PURPOSE: Controls the stepper logic for period and cycle
  //          length. Min is 1, max is 50 for both.
  // ============================================================
  void incrementPeriod() {
    if (periodLength < 50) setState(() => periodLength++);
  }

  void decrementPeriod() {
    if (periodLength > 1) setState(() => periodLength--);
  }

  void incrementCycle() {
    if (cycleLength < 50) setState(() => cycleLength++);
  }

  void decrementCycle() {
    if (cycleLength > 1) setState(() => cycleLength--);
  }

  // ============================================================
  // WIDGET BUILDER: buildStepperCard
  // PURPOSE: Reusable card widget that shows a labeled setting
  //          with a +/- stepper control. Used for Period Length
  //          and Cycle Length cards.
  // ============================================================
  Widget buildStepperCard({
    required String title,
    required String subtitle,
    required int value,
    required VoidCallback onAdd,
    required VoidCallback onMinus,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFF1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6DADF)),
      ),
      child: Row(
        children: [

          // Left section: accent bar + title and subtitle labels
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Vertical accent bar (decorative left border)
                Container(
                  width: 3,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C4F6B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title and subtitle text column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 3,
                        color: Color(0xFF7A4D5E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right section: stepper control (minus, value display, plus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9E1E4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [

                // Minus button — disabled when value is at minimum (1)
                IconButton(
                  onPressed: value > 1 ? onMinus : null,
                  icon: const Icon(Icons.remove, color: Color(0xFF7A4D5E)),
                ),

                // Current value display, zero-padded to 2 digits
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      value.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),

                // Plus button — disabled when value is at maximum (50)
                IconButton(
                  onPressed: value < 50 ? onAdd : null,
                  icon: const Icon(Icons.add, color: Color(0xFF7A4D5E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGET BUILDER: buildCycleTypeCard
  // PURPOSE: Card widget with a dropdown (PopupMenuButton) for
  //          selecting the user's menstruation regularity type.
  //          Options: Regular, Irregular, Not sure.
  // ============================================================
  Widget buildCycleTypeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFF1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6DADF)),
      ),
      child: Row(
        children: [

          // Left section: accent bar + label
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Vertical accent bar (decorative left border)
                Container(
                  width: 3,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C4F6B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Static label column for Cycle Type
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CYCLE TYPE",
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 3,
                        color: Color(0xFF7A4D5E),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Menstruation Regularity",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right section: dropdown popup menu for cycle type selection
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => cycleType = value),
            color: const Color(0xFFF4EFF1),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            // Menu options: Regular, Irregular, Not sure
            // Selected option is highlighted in brand color
            itemBuilder: (context) => ["Regular", "Irregular", "Not sure"]
                .map(
                  (option) => PopupMenuItem(
                value: option,
                child: Text(
                  option,
                  style: TextStyle(
                    color: cycleType == option
                        ? const Color(0xFF8C4F6B)
                        : Colors.black87,
                    fontWeight: cycleType == option
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            )
                .toList(),

            // Dropdown trigger button showing current selection
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E1E4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    cycleType,
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 30,
                    color: Color(0xFF7A4D5E),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD METHOD: Main screen layout
  // PURPOSE: Assembles the full screen with two sections:
  //          (1) Top gradient header with branding
  //          (2) Bottom form area with input cards and save button
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F5),
      body: Column(
        children: [

          // --------------------------------------------------------
          // TOP SECTION: Gradient header with logo and branding text
          // --------------------------------------------------------
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3E1F30),
                    Color(0xFF8C4F6B),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [

                  // Decorative background circle (top-left, subtle border)
                  Positioned(
                    top: 40,
                    left: -120,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),

                  // App logo with glow/shadow effect (top-right)
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
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 75,
                      ),
                    ),
                  ),

                  // App title, tagline, and "Personalized tracking" badge (bottom-left)
                  Positioned(
                    bottom: 35,
                    left: 25,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "YOUR PERSONAL",
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 3,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Cycle Companion",
                          style: TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 34,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Small pill badge indicating personalized tracking feature
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Personalized tracking",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --------------------------------------------------------
          // BOTTOM SECTION: User input cards and save button
          // --------------------------------------------------------
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Section heading and helper text
                  const Text(
                    "Tell us about you",
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 26,
                      color: Color(0xFF3A1F3D),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Help us personalize your cycle tracking experience",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Input cards: Cycle Type, Period Length, Cycle Length
                  buildCycleTypeCard(),
                  buildStepperCard(
                    title: "PERIOD LENGTH",
                    subtitle: "Usually 3 – 7 days",
                    value: periodLength,
                    onAdd: incrementPeriod,
                    onMinus: decrementPeriod,
                  ),
                  buildStepperCard(
                    title: "CYCLE LENGTH",
                    subtitle: "Average is 28 days",
                    value: cycleLength,
                    onAdd: incrementCycle,
                    onMinus: decrementCycle,
                  ),

                  // Pushes the save button to the bottom of the screen
                  const Spacer(),

                  // --------------------------------------------------------
                  // SAVE BUTTON
                  // PURPOSE: Submits the user's setup data.
                  //          Currently empty — database save logic goes here.
                  // --------------------------------------------------------

                  // TODO: (EDITING) - I-connect ang button na ito sa database save logic.
                  // I-save ang periodLength, cycleLength, at cycleType sa Firestore/SQLite/Supabase.
                  // Pagkatapos mag-save, i-mark ang user as "setup complete" para hindi na
                  // makita ulit ang screen na ito. Tapos, mag-navigate sa main/home screen.
                  // The code should be placed here

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: const Color(0xFFB56A7E),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (_) => const HomePage())
                        );
                      },
                      child: const Text(
                        "Save & Continue",
                        style: TextStyle(fontSize: 16, color: Colors.white),
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