import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:menesis_app/app_navigation/tab2/homepage.dart';
import 'intro.dart';

// ─────────────────────────────────────────────
// SplashScreen
// Displays the app logo, name, tagline, and an
// animated progress bar for 5 seconds before
// navigating to the Introduction screen.
// ─────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  // Animation controller and its child animations
  late AnimationController controller;
  late Animation<double> fade;
  late Animation<double> progress;

  @override
  void initState() {
    super.initState();

    // Set up a 5-second animation controller
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Fade-in animation: opacity 0 → 1
    fade = Tween<double>(begin: 0, end: 1).animate(controller);

    // Progress bar animation: 0% → 100%
    progress = Tween<double>(begin: 0, end: 1).animate(controller);

    // Start both animations immediately
    controller.forward();

    // Navigate to Introduction after the splash duration ends
    Future.delayed(const Duration(seconds: 5), () {
      // Guard against navigating after the widget has been disposed
      if (!mounted) return;


      Widget nextScreen;
      /*if (FirebaseAuth.instance.currentUser != null) {
        nextScreen = const HomePage();
      }
      else {
        nextScreen = const Introduction();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),

      );*/
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          user.reload(); 
          if (FirebaseAuth.instance.currentUser != null) {
            nextScreen = const HomePage();
          }
          else {
            nextScreen = const Introduction();
          }
        }
        catch (e) {
          FirebaseAuth.instance.signOut();
          nextScreen = const Introduction();
        }
      }
      else {
        nextScreen = const Introduction();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),

      );
    });
  }

  @override
  void dispose() {
    // Always dispose AnimationController to free resources
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // ── Background gradient layer ──────────────────
          // Full-screen dark-to-pink vertical gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF301C29),
                  Color(0xFF45243B),
                  Color(0xFF552E46),
                  Color(0xFF6B3A55),
                ],
                stops: [
                  0.0,
                  0.55, // longer dark section at the top
                  0.85, // pink tone delayed toward the bottom
                  1.0,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Foreground content layer ───────────────────
          // Fades in as the animation plays
          FadeTransition(
            opacity: fade,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // TODO: Replace logo asset path if it changes in the future

                  // App logo inside a frosted-glass-style rounded container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // App name in elegant serif font
                  const Text(
                    "Mēnesis",
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 60,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // App tagline / subtitle
                  const Text(
                    "TRACK YOUR CYCLE, KNOW YOUR BODY",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ── Animated progress bar ──────────────
                  // Fills from 0 to 100% over the 5-second splash duration
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150),
                    child: AnimatedBuilder(
                      animation: progress,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: progress.value,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFD1A34E),
                          ),
                          backgroundColor: Colors.white24,
                        );
                      },
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

// ─────────────────────────────────────────────
// AppBackground
// A reusable wrapper widget that applies the
// app's standard gradient background and
// decorative circular overlays to any child.
// ─────────────────────────────────────────────
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  // TODO: Consider extracting gradient colors and stops into a shared
  //       theme/constants file to keep them in sync with SplashScreen

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        // Same gradient palette used across the app
        gradient: LinearGradient(
          colors: [
            Color(0xFF301C29),
            Color(0xFF45243B),
            Color(0xFF552E46),
            Color(0xFF6B3A55),
          ],
          stops: [0.0, 0.55, 0.85, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),

      child: Stack(
        children: [

          // ── Decorative circle: top-right ───────────────
          // Soft filled circle peeking from the upper-right corner
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),

          // ── Decorative circle: top-left ────────────────
          // Outlined circle partially visible at the upper-left corner
          Positioned(
            top: 40,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),

          // ── Page content ───────────────────────────────
          // The actual screen content is rendered on top of the decoration
          child,

        ],
      ),
    );
  }
}