import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:menesis_app/app_navigation/tab1/calendar.dart';
import 'package:menesis_app/app_navigation/tab3/profile/profile.dart';

void main() {
  runApp(const MyApp());
}

// ─────────────────────────────────────────────
// ROOT APP WIDGET
// Sets up the MaterialApp with no debug banner
// and loads the HomePage as the starting screen.
// ─────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// ─────────────────────────────────────────────
// HOME PAGE – STATEFUL WIDGET
// This is the main screen of the app.
// It manages:
//   - Which bottom nav tab is active
//   - A live clock (updated every minute) used
//     for the greeting and date display
// ─────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Tracks which bottom nav tab is currently selected (default: Home = index 1)
  int _selectedIndex = 1;

  // Timer that ticks every minute to keep the greeting/date fresh
  late Timer _timer;

  // Holds the current local time, updated by the timer
  DateTime _now = DateTime.now().toLocal();

  // Holds the days left until next cycle and period
  int? daysUntilNextCycle;

  // The three screens mapped to each bottom nav tab
  late final List<Widget> _pages;

  // Holds the name of the user
  String? name;

  // ─────────────────────────────────────────────
  // INIT STATE
  // Called once when the widget is first created.
  // Builds the page list and starts the live clock timer.
  // ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _pages = [
      const CalendarScreen(),
      _buildHomeContent(),
      const ManageProfileScreen(),
    ];

    // Refresh time every minute so greeting and date stay accurate
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now().toLocal());
    });

    nextCycleDays();
    getUserName();
  }

  // ─────────────────────────────────────────────
  // DISPOSE
  // Cancels the timer when the widget is removed
  // from the tree to prevent memory leaks.
  // ─────────────────────────────────────────────
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // GREETING GETTER
  // Returns a time-appropriate greeting based on the hour.
  // Morning  → 12:00 AM to 11:59 AM
  // Afternoon → 12:00 PM to 5:59 PM
  // Evening  → 6:00 PM onwards
  //
  // FIX: Corrected the afternoon range — previously 12–18
  // caused "Good afternoon" to show until 6PM (18:00).
  // Now "Good evening" starts correctly at 18:00.
  // ─────────────────────────────────────────────
  String get _greeting {
    final hour = _now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';

    // TODO: (EDIT) Kung gusto mong i-customize pa ang greeting,
    // halimbawa mag-add ng "Good night" pagkatapos ng 9PM (hour >= 21),
    // palitan ang logic dito.
    // The code should be placed here

  }

  // ─────────────────────────────────────────────
  // FORMATTED DATE GETTER
  // Builds a human-readable date string like "15th April, 2025".
  // Handles special suffixes: st, nd, rd, th (with 11th–13th exception).
  // ─────────────────────────────────────────────
  String get _formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final day = _now.day;

    // Handles 11th, 12th, 13th as exceptions to the usual suffix rules
    final suffix = (day >= 11 && day <= 13)
        ? 'th'
        : switch (day % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };

    return '$day$suffix ${months[_now.month - 1]}, ${_now.year}';
  }

  // ─────────────────────────────────────────────
  // WEEK STRIP GETTER
  // Builds the 7-day strip shown below the greeting.
  // Always starts from Sunday of the current week.
  // Marks today so it can be highlighted in the UI.
  // ─────────────────────────────────────────────
  List<Map<String, dynamic>> get _weekStrip {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final today = DateTime(_now.year, _now.month, _now.day);

    // weekday % 7 converts Mon=1…Sun=7 → Sun=0…Sat=6
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));

    return List.generate(7, (i) {
      final date = startOfWeek.add(Duration(days: i));
      return {
        'label': labels[i],
        'date': date.day.toString().padLeft(2, '0'),
        'isToday': date == today,
      };
    });
  }

  /*void getUserName() async {
    final user = FirebaseAuth.instance.currentUser; 
    if (user != null) {
      DocumentSnapshot userInfo = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        if (userInfo['first name'] == "") {
          setState(() {
            name = userInfo['username'];
          });
        }
        else {
          setState(() {
            name = userInfo['first name'];
          });
        }
      }
    }
  }*/
  Future<String?> getUserName() async {
    String? authUid = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot user = await FirebaseFirestore.instance.collection('users').doc(authUid).get();
    if (user['first name'] == "") {
      return user['username'];
    }
    else {
      return user['first name'];
    }
  }

  Future<int?> nextCycleDays() async {
    String? authUid = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot user = await FirebaseFirestore.instance.collection('cycle').doc(authUid).get();
    if (user['emptyRecord'] as bool) {
      return 0;
    }
    else {
      // Get latest record
      CollectionReference history = FirebaseFirestore.instance.collection('cycle').doc(authUid).collection('cycle history');
      final QuerySnapshot latest = await history.orderBy('start date', descending: true).limit(1).get();
      String latestId = latest.docs.first.id;

      // Get the previous cycle's length
      DocumentSnapshot userCycleHistory = await FirebaseFirestore.instance.collection('cycle').doc(authUid).collection('cycle history').doc(latestId).get();
      final periodEnd = (userCycleHistory['end date'] as Timestamp).toDate();
      Duration daysLeft = (periodEnd.difference(_now)) + Duration(days: 1);
      return daysLeft.inDays;
    }
  }

  /*void nextCycleDays() async {
    final user = FirebaseAuth.instance.currentUser;  

    if (user != null) {
      // Empty record check
      DocumentSnapshot userRecord = await FirebaseFirestore.instance.collection('cycle').doc(user.uid).get();
      if (mounted) {
        if (userRecord['emptyRecord'] as bool) {
          setState(() {
            daysUntilNextCycle = 0;
          });
        }
        else {
          // Get latest record
          CollectionReference history = FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history');
          final QuerySnapshot latest = await history.orderBy('start date', descending: true).limit(1).get();
          String latestId = latest.docs.first.id;

          // Get the previous cycle's length
          DocumentSnapshot userCycleHistory = await FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history').doc(latestId).get();
          final periodEnd = (userCycleHistory['end date'] as Timestamp).toDate();
          Duration daysLeft = (_now.difference(periodEnd)) + Duration(days: 1);
          setState(() {
            daysUntilNextCycle = daysLeft.inDays;
          });
        }
      }
    }
  }*/

  // ─────────────────────────────────────────────
  // BUILD HOME CONTENT
  // Constructs the entire scrollable home tab layout:
  //   - Greeting header + logo
  //   - Weekly day strip
  //   - Cycle status card (circular progress)
  //   - Countdown cards (Next Cycle / Next Period)
  //   - Today's Suggestion section
  // ─────────────────────────────────────────────

  Widget _buildHomeContent() {
    final strip = _weekStrip;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HEADER ROW: Greeting + Logo ──────────────────
            // Left side shows time-based greeting, user name, and date.
            // Right side shows the app logo with a soft glow effect.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: const TextStyle(
                        fontFamily: "DMSans",
                        fontSize: 11,
                        color: Color(0xFF44222B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    /*Text(
                      'Hello, ${name ?? "User"}',
                      style: TextStyle(
                        fontFamily: "CormorantGaramond",
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF44222B),
                      )
                    ),*/
                    FutureBuilder(future: getUserName(),
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.done) {
                            return Text(
                              'Hello, ${snapshot.data}',
                              style: TextStyle(
                                fontFamily: "CormorantGaramond",
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF44222B),
                              ),
                            );
                          }
                          else {
                            return CircularProgressIndicator();
                          }
                        }
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formattedDate,
                      style: const TextStyle(
                        fontFamily: "DMSans",
                        fontSize: 13,
                        color: Color(0xFF44222B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                // Logo with pink glow shadow
                // NOTE: Removed incorrect `Positioned` wrapper — it has no
                // effect inside a Row and was a leftover from an older Stack layout.
                Container(
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
                    height: 70,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── WEEKLY DAY STRIP ──────────────────────────────
            // Shows all 7 days of the current week (Sun–Sat).
            // Today's date gets a filled pink circle highlight.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: strip.map((day) {
                final isSelected = day['isToday'] as bool;
                return Column(
                  children: [
                    Text(
                      day['label'] as String,
                      style: TextStyle(
                        fontFamily: "DMSans",
                        fontSize: 14,
                        color: const Color(0xFF44222B),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFB56A7E)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          day['date'] as String,
                          style: TextStyle(
                            fontFamily: "DMSans",
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF44222B),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── CYCLE STATUS CARD ─────────────────────────────
            // Dark gradient card showing the current cycle phase.
            // Contains a circular progress indicator and phase legend.
            //
            // TODO: (EDIT) Palitan ang hardcoded na `value: 0.65` at
            // "Ovulation Phase" / "Day 15" ng DYNAMIC na data.
            // Dapat galing ito sa cycle tracking logic o database ng user.
            // Kunin ang: currentDay, totalCycleDays, phaseName
            // Para ma-compute: value = currentDay / totalCycleDays
            // The code should be placed here

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF301C29),
                    Color(0xFF45243B),
                    Color(0xFF552E46),
                    Color(0xFF6B3A55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CURRENT CYCLE STATUS",
                    style: TextStyle(
                      fontFamily: "DMSans",
                      color: Color(0xFFF7F3F5),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Circular progress ring centered in the card
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            // TODO: (EDIT) Palitan ang `value: 0.65` ng
                            // computed value mula sa cycle data.
                            // Formula: currentDay / totalCycleDays
                            // The code should be placed here
                            value: 0.65,
                            strokeWidth: 12,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF6ED6A5)),
                          ),
                        ),

                        // Text overlay in the center of the ring
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              // TODO: (EDIT) Palitan ng dynamic na phase name
                              // base sa computed cycle phase ng user.
                              // The code should be placed here
                              "Ovulation Phase",
                              style: TextStyle(
                                fontFamily: "DMSans",
                                color: Color(0xFFF7F3F5),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              // TODO: (EDIT) Palitan ng "Day $currentDay"
                              // na galing sa actual cycle tracker ng user.
                              // The code should be placed here
                              "Day 15",
                              style: TextStyle(
                                fontFamily: "DMSans",
                                color: Color(0xFFF7F3F5),
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Color legend: Period / Ovulation / Fertile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _legendDot(const Color(0xFFE57373), "PERIOD"),
                      _legendDot(const Color(0xFF6ED6A5), "OVULATION"),
                      _legendDot(const Color(0xFFFFD54F), "FERTILE"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── COUNTDOWN CARDS ROW ───────────────────────────
            // Two side-by-side cards showing days until:
            //   - Next Cycle start
            //   - Next Period
            //
            // TODO: (EDIT) Palitan ang hardcoded na '05' ng computed
            // countdown values mula sa cycle prediction logic.
            // Kunin ang: daysUntilNextCycle, daysUntilNextPeriod
            // The code should be placed here

            FutureBuilder(
              future: nextCycleDays(), 
              builder: (builder, snapshot) {
                if(snapshot.connectionState == ConnectionState.done) {
                  daysUntilNextCycle = snapshot.data;
                }
                else {
                  daysUntilNextCycle = 0;
                }
                return Row(
                  children: [
                    Expanded(
                      child: _countdownCard(
                        'NEXT CYCLE',
                        // TODO: (EDIT) Palitan ng '$daysUntilNextCycle'
                        // The code should be placed here
                        daysUntilNextCycle.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _countdownCard(
                        'NEXT PERIOD',
                        // TODO: (EDIT) Palitan ng '$daysUntilNextPeriod'
                        // The code should be placed here
                        daysUntilNextCycle.toString(),
                      ),
                    ),
                  ],
                );
              }),

            const SizedBox(height: 20),

            // ── TODAY'S SUGGESTION SECTION ────────────────────
            // Shows a suggestion card relevant to the user's current phase.
            // Should also show logged symptoms if any exist for today.
            //
            // TODO: (ADD) I-implement ang dynamic suggestion content.
            // Dapat ang content dito ay:
            //   1. Depende sa current cycle phase ng user
            //      (hal. Menstrual → rest tips, Ovulation → fertility info)
            //   2. Kung may naka-log na symptoms para sa today's date,
            //      ipakita rin ang summary ng symptoms na yun
            // Kunin ang: currentPhase, todaySymptomLog
            // The code should be placed here

            const Text(
              "Today's Suggestion",
              style: TextStyle(
                fontFamily: "CormorantGaramond",
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 12),

            // Placeholder container — replace with dynamic suggestion widget
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              // TODO: (ADD) Lagyan ng content ang suggestion card.
              // Pwedeng mag-show ng:
              //   - Phase-based tip (Text/Image)
              //   - Logged symptoms summary para sa today
              // The code should be placed here

            ),

            // Extra bottom padding so content isn't hidden behind the nav bar
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MAIN SCAFFOLD BUILD
  // Builds the overall page structure:
  //   - Background color
  //   - Current tab's page body
  //   - Convex bottom nav bar
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F5),
      body: Stack(
        children: [
          _pages[_selectedIndex],

          if (_selectedIndex == 1)
            Positioned(
              right: 0,
              bottom: 0,
              child: PeriodCatButton(
                isPeriodStarted: false, // temporary la pa logic
                onTap: () {},
              ),
            ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        backgroundColor: const Color(0xFF45243B),
        activeColor: Colors.white,
        color: Colors.white54,
        height: 50,
        curveSize: 90,
        top: -24,
        elevation: 10,
        initialActiveIndex: _selectedIndex,
        items: const [
          TabItem(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month),
          TabItem(icon: Icons.home_outlined, activeIcon: Icons.home),
          TabItem(icon: Icons.person_outline, activeIcon: Icons.person),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LEGEND DOT WIDGET
  // A small colored square with a label beside it.
  // Used in the cycle status card to identify phases.
  // ─────────────────────────────────────────────
  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: "CormorantGaramond",
            color: Color(0xFFF7F3F5),
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // COUNTDOWN CARD WIDGET
  // A gradient card that shows how many days
  // until a specific cycle event (Next Cycle or Next Period).
  // Accepts a title string and a days-remaining string.
  // ─────────────────────────────────────────────
  Widget _countdownCard(String title, String days) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF301C29),
            Color(0xFF45243B),
            Color(0xFF552E46),
            Color(0xFF6B3A55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            days,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'more days to go',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }
}


class PeriodCatButton extends StatefulWidget {
  final bool isPeriodStarted;
  final VoidCallback onTap;

  const PeriodCatButton({
    super.key,
    required this.isPeriodStarted,
    required this.onTap,
  });

  @override
  State<PeriodCatButton> createState() => _PeriodCatButtonState();
}

class _PeriodCatButtonState extends State<PeriodCatButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cloudController;
  late final Timer _eyeTimer;

  int _eyeIndex = 0;

  final List<String> _catFrames = [
    'assets/images/period_cat/default.png',
    'assets/images/period_cat/left.png',
    'assets/images/period_cat/default.png',
    'assets/images/period_cat/up.png',
    'assets/images/period_cat/default.png',
    'assets/images/period_cat/right.png',
    'assets/images/period_cat/default.png',
    'assets/images/period_cat/down.png',
  ];

  @override
  void initState() {
    super.initState();

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _eyeTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!mounted) return;
      setState(() {
        _eyeIndex = (_eyeIndex + 1) % _catFrames.length;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // preload images to prevent flicker
    for (final frame in _catFrames) {
      precacheImage(AssetImage(frame), context);
    }

    precacheImage(
      const AssetImage('assets/images/period_cat/cloud.png'),
      context,
    );
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _eyeTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: 170,
        height: 190,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // CLOUD FLOAT
            AnimatedBuilder(
              animation: _cloudController,
              builder: (context, child) {
                final moveY =
                    -14 * Curves.easeInOut.transform(_cloudController.value);

                return Positioned(
                  top: moveY,
                  right: 5,
                  bottom: -25,
                  child: Image.asset(
                    'assets/images/period_cat/cloud.png',
                    height: 150,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),

            // CAT
            Positioned(
              bottom: 0,
              right: 0,
              child: IndexedStack(
                index: _eyeIndex,
                children: _catFrames.map((frame) {
                  return Image.asset(
                    frame,
                    width: 155,
                    fit: BoxFit.contain,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}