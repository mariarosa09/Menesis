import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:menesis_app/app_navigation/tab2/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PeriodSetupScreen(),
    );
  }
}

// TODO: i-save ung data rito sa database

class PeriodSetupScreen extends StatefulWidget {
  const PeriodSetupScreen({super.key});

  @override
  State<PeriodSetupScreen> createState() => _PeriodSetupScreenState();
}

class _PeriodSetupScreenState extends State<PeriodSetupScreen> {
  int periodLength = 3;
  int cycleLength = 28;
  String cycleType = "Regular";
  bool smartPrediction = true;

  void incrementPeriod() {
    if (periodLength < 50) {
      setState(() => periodLength++);
    }
  }

  void decrementPeriod() {
    if (periodLength > 1) {
      setState(() => periodLength--);
    }
  }

  void incrementCycle() {
    if (cycleLength < 50) {
      setState(() => cycleLength++);
    }
  }

  void decrementCycle() {
    if (cycleLength > 1) {
      setState(() => cycleLength--);
    }
  }

  Future addUserPeriodDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
        await FirebaseFirestore.instance.collection('periods').doc(user.uid).set({
          'cycle type': cycleType,
          'cycle length': cycleLength,
          'period length': periodLength,
          'smart prediction': smartPrediction
        });
      }
    } 

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C4F6B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.2,
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
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9E1E4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: value > 1 ? onMinus : null,
                  icon: const Icon(
                    Icons.remove,
                    color: Color(0xFF7A4D5E),
                  ),
                ),
                SizedBox(
                  width: 34,
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
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: value < 50 ? onAdd : null,
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xFF7A4D5E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C4F6B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "CYCLE TYPE",
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.2,
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
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => cycleType = value);
            },
            color: const Color(0xFFF4EFF1),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "Regular",
                child: Text(
                  "Regular",
                  style: TextStyle(
                    color: cycleType == "Regular"
                        ? const Color(0xFF8C4F6B)
                        : Colors.black87,
                    fontWeight: cycleType == "Regular"
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem(
                value: "Irregular",
                child: Text(
                  "Irregular",
                  style: TextStyle(
                    color: cycleType == "Irregular"
                        ? const Color(0xFF8C4F6B)
                        : Colors.black87,
                    fontWeight: cycleType == "Irregular"
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem(
                value: "Not sure",
                child: Text(
                  "Not sure",
                  style: TextStyle(
                    color: cycleType == "Not sure"
                        ? const Color(0xFF8C4F6B)
                        : Colors.black87,
                    fontWeight: cycleType == "Not sure"
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E1E4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text(
                      cycleType,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 26,
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

  Widget buildSmartPredictionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFF1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6DADF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C4F6B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SMART PREDICTION",
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.2,
                          color: Color(0xFF7A4D5E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        smartPrediction
                            ? "Auto-calculation" // di ako kuntento sa description nento
                            : "Use manual tracking only",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: smartPrediction,
            activeColor: const Color(0xFF8C4F6B),
            onChanged: (value) {
              setState(() => smartPrediction = value);
            },
          ),
        ],
      ),
    );
  }

  Widget buildHeader(double height) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: height,
      ),
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
          Positioned(
            top: 24,
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
                height: 72,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 52,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 120, 25, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(
                        radius: 3,
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Personalized tracking",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
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
    );
  }

  Widget buildFormSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          buildSmartPredictionCard(),
          const SizedBox(height: 12),
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
                // TODO: Save periodLength, cycleLength, cycleType, smartPrediction
                addUserPeriodDetails();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const HomePage(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Save & Continue",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmallHeight = constraints.maxHeight < 750;
            final double headerHeight = isSmallHeight ? 280 : 330;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    buildHeader(headerHeight),
                    buildFormSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}