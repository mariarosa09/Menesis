import 'dart:async';
import 'dart:math';
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
// PHASE DEFINITIONS
// Ring order (clockwise): Menstruation → Fertile → Ovulation → Luteal
// Total = 28 days.
//
// Follicular is rendered as a SEPARATE inner overlay arc
// that spans from day 1 through Fertile end (days 1–10).
// Follicular ends the day BEFORE ovulation (aligns with fertileEnd).
// ─────────────────────────────────────────────
class _CyclePhase {
  final String name;
  final int days;
  final Color color;
  const _CyclePhase(this.name, this.days, this.color);
}

// Primary outer ring segments (must sum to 28)
const List<_CyclePhase> _cyclePhases = [
  _CyclePhase('Menstruation', 5,  Color(0xFFE57373)), // days 1–5
  _CyclePhase('Fertile',      5,  Color(0xFFFFD54F)), // days 6–10
  _CyclePhase('Ovulation',    1,  Color(0xFF6ED6A5)), // day 11
  _CyclePhase('Luteal',       17, Color(0xFF9C7FBF)), // days 12–28
];

// Follicular overlay arc: day 1 → end of Fertile phase (10 days total)
// Menstruation(5) + Fertile(5) = 10  ← ends the day BEFORE ovulation,
// which aligns exactly with fertileEnd in Firestore.
const int _follicularDays = 10;
const Color _follicularColor = Color(0xFFEAEAEA); // soft grey-white

const int _totalDays = 28;

// ─────────────────────────────────────────────
// ROOT APP WIDGET
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
// ─────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {

  // ── Firestore subscriptions ──────────────────
  StreamSubscription<DocumentSnapshot>? _userSub;
  StreamSubscription<DocumentSnapshot>? _userStat;
  StreamSubscription<DocumentSnapshot>? _userNextCycle;
  StreamSubscription? _history;

  // ── Loading flag ─────────────────────────────
  bool _isLoading = true;

  // ── Bottom nav ───────────────────────────────
  int _selectedIndex = 1;

  // ── Live clock ───────────────────────────────
  late Timer _timer;
  DateTime _now = DateTime.now().toLocal();

  // ── Period log state ─────────────────────────
  // true  = period has NOT started yet (or just ended) → cat says "Period Starts?"
  // false = period is currently active              → cat says "Period Ends?"
  bool start = true;

  // ── Cycle data ───────────────────────────────
  int? daysUntilNextCycle;
  int? daysInCurrentCycle;
  String? name;
  String? cyclePhase;
  String? cyclePhase2; // secondary concurrent phase (e.g. Follicular)

  // ── Legacy display fields (kept for legend) ──
  Color colorCycle = Colors.white;
  double percent = 0.0;

  // ── Shimmer animation ────────────────────────
  late final AnimationController _shimmerAnim;

  // ── Page list ────────────────────────────────
  late final List<Widget> _pages;

  // ─────────────────────────────────────────────
  // INIT STATE
  // ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _pages = [
      const CalendarScreen(),
      const SizedBox(),
      const ManageProfileScreen(),
    ];

    // Shimmer controller — loops continuously for the ring's flowing dot
    _shimmerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Refresh time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now().toLocal());
    });

    _loadAllData();
  }

  // ─────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────
  @override
  void dispose() {
    _timer.cancel();
    _shimmerAnim.dispose();
    _userSub?.cancel();
    _userStat?.cancel();
    _userNextCycle?.cancel();
    _history?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // GREETING
  // ─────────────────────────────────────────────
  String get _greeting {
    final hour = _now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  // ─────────────────────────────────────────────
  // FORMATTED DATE
  // ─────────────────────────────────────────────
  String get _formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final day = _now.day;
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
  // WEEK STRIP
  // ─────────────────────────────────────────────
  List<Map<String, dynamic>> get _weekStrip {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final today = DateTime(_now.year, _now.month, _now.day);
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

  // ─────────────────────────────────────────────
  // PHASE INDEX
  // Maps primary cyclePhase string → index in _cyclePhases
  // Order: Menstruation(0) → Fertile(1) → Ovulation(2) → Luteal(3)
  // ─────────────────────────────────────────────
  int get _phaseIndex {
    switch (cyclePhase?.toLowerCase()) {
      case 'menstruation': return 0;
      case 'fertile':      return 1;
      case 'ovulation':    return 2;
      case 'luteal':       return 3;
      default:             return 0;
    }
  }

  // ─────────────────────────────────────────────
  // DAY IN PHASE
  // Converts cumulative daysInCurrentCycle into
  // days elapsed within the current primary phase only.
  // ─────────────────────────────────────────────
  int get _dayInPhase {
    int completed = 0;
    for (int i = 0; i < _phaseIndex; i++) {
      completed += _cyclePhases[i].days;
    }
    return ((daysInCurrentCycle ?? 1) - completed)
        .clamp(1, _cyclePhases[_phaseIndex].days)
        .toInt();
  }

  // ─────────────────────────────────────────────
  // NEXT PHASE INFO
  // ─────────────────────────────────────────────
  (String, int) _getNextPhaseInfo() {
    if (cyclePhase == null || daysUntilNextCycle == null) {
      return ("Next Phase", 0);
    }
    switch (cyclePhase) {
      case "Menstruation":
        return ("Fertile Phase", (daysUntilNextCycle! - 20).clamp(0, 999).toInt());
      case "Fertile":
        return ("Ovulation", 1);
      case "Ovulation":
        return ("Luteal Phase", (daysUntilNextCycle! - 7).clamp(0, 999).toInt());
      case "Luteal":
        return ("Next Period", daysUntilNextCycle ?? 0);
      default:
        return ("Next Phase", daysUntilNextCycle ?? 0);
    }
  }

  // ─────────────────────────────────────────────
  // DATA LOADING
  // ─────────────────────────────────────────────
  Future<void> _loadAllData() async {
    try {
      await Future.wait([
        getUserName(),
        nextCycleDays(),
        currentCycleDay(),
        modifyCycleDisplay(),
        getCycle(),
        getLogStatus(),
      ]);
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot userInfo) {
        final data = userInfo.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          final firstName = data['first name'] ?? "";
          final username = data['username'] ?? "User";
          setState(() {
            name = firstName.isEmpty ? username : firstName;
          });
        }
      });
    }
  }

  Future<void> nextCycleDays() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userNextCycle = FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot userInfo) {
        final data = userInfo.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          if (data['emptyRecord'] as bool) {
            setState(() => daysUntilNextCycle = 0);
          } else {
            _history = FirebaseFirestore.instance
                .collection('cycle')
                .doc(user.uid)
                .collection('cycle history')
                .orderBy('start date', descending: true)
                .limit(1)
                .snapshots()
                .listen((QuerySnapshot latest) {
              if (latest.docs.isNotEmpty && mounted) {
                final cycle =
                latest.docs.first.data() as Map<String, dynamic>;
                final cycleEnd =
                (cycle['end date'] as Timestamp).toDate();
                final daysLeft =
                    (cycleEnd.difference(_now)) + const Duration(days: 1);
                setState(() => daysUntilNextCycle = daysLeft.inDays);
              }
            });
          }
        }
      });
    }
  }

  Future<void> currentCycleDay() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userNextCycle = FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot userInfo) {
        final data = userInfo.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          if (data['emptyRecord'] as bool) {
            setState(() => daysInCurrentCycle = 0);
          } else {
            _history = FirebaseFirestore.instance
                .collection('cycle')
                .doc(user.uid)
                .collection('cycle history')
                .orderBy('start date', descending: true)
                .limit(1)
                .snapshots()
                .listen((QuerySnapshot latest) {
              if (latest.docs.isNotEmpty && mounted) {
                final cycle =
                latest.docs.first.data() as Map<String, dynamic>;
                final periodStart =
                (cycle['start date'] as Timestamp).toDate();
                // +1 so the first day of the period is Day 1 (not Day 0)
                final dayInCycle = (_now.difference(periodStart)) +
                    const Duration(days: 1);
                setState(() => daysInCurrentCycle = dayInCycle.inDays);
              }
            });
          }
        }
      });
    }
  }

  Future<void> modifyCycleDisplay() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userNextCycle = FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot userInfo) {
        final data = userInfo.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          if (data['emptyRecord'] as bool) {
            setState(() {
              percent = 0.0;
              colorCycle = const Color(0xFFFFFFFF);
            });
          } else {
            _history = FirebaseFirestore.instance
                .collection('cycle')
                .doc(user.uid)
                .collection('cycle history')
                .orderBy('start date', descending: true)
                .limit(1)
                .snapshots()
                .listen((QuerySnapshot latest) {
              if (latest.docs.isNotEmpty && mounted) {
                final cycle =
                latest.docs.first.data() as Map<String, dynamic>;
                final periodStart =
                (cycle['start date'] as Timestamp).toDate();
                final periodEnd =
                (cycle['period end'] as Timestamp).toDate();
                final fertileStart =
                (cycle['fertile start'] as Timestamp).toDate();
                final fertileEnd =
                (cycle['fertile end'] as Timestamp).toDate();
                final ovulation =
                (cycle['ovulation'] as Timestamp).toDate();

                final dayInCycle = (_now.difference(periodStart)) +
                    const Duration(days: 1);
                final percentage =
                    dayInCycle.inDays / data['cycle length'];

                Color cycleColoring;
                if ((_now.isAfter(periodStart) ||
                    DateUtils.isSameDay(_now, periodStart)) &&
                    (_now.isBefore(periodEnd) ||
                        DateUtils.isSameDay(_now, periodEnd))) {
                  cycleColoring = const Color(0xFFE57373);
                } else if (DateUtils.isSameDay(_now, ovulation)) {
                  cycleColoring = const Color(0xFF6ED6A5);
                } else if ((_now.isAfter(fertileStart) ||
                    DateUtils.isSameDay(_now, fertileStart)) &&
                    (_now.isBefore(fertileEnd) ||
                        DateUtils.isSameDay(_now, fertileEnd))) {
                  cycleColoring = const Color(0xFFFFD54F);
                } else {
                  cycleColoring = const Color(0xFF9C7FBF);
                }

                if (mounted) {
                  setState(() {
                    percent = percentage;
                    colorCycle = cycleColoring;
                  });
                }
              }
            });
          }
        }
      });
    }
  }

  // ─────────────────────────────────────────────
  // GET CYCLE
  // Determines both the primary phase and the
  // concurrent secondary phase (Follicular overlay).
  //
  // Primary phases (outer ring):
  //   Menstruation → Fertile → Ovulation → Luteal
  //
  // Follicular (inner overlay arc):
  //   Runs concurrently from period start → fertileEnd (inclusive).
  //   fertileEnd is the day BEFORE ovulation.
  //
  //   During Menstruation: Menstruation + Follicular
  //   During Fertile:      Fertile + Follicular
  //   During Ovulation:    Ovulation only (Follicular already ended)
  //   During Luteal:       Luteal only
  // ─────────────────────────────────────────────
  Future<void> getCycle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userNextCycle = FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot userInfo) {
        final data = userInfo.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          if (data['emptyRecord'] as bool) {
            setState(() {
              cyclePhase = "Empty Record";
              cyclePhase2 = null;
            });
          } else {
            _history = FirebaseFirestore.instance
                .collection('cycle')
                .doc(user.uid)
                .collection('cycle history')
                .orderBy('start date', descending: true)
                .limit(1)
                .snapshots()
                .listen((QuerySnapshot latest) {
              if (latest.docs.isNotEmpty && mounted) {
                final cycle =
                latest.docs.first.data() as Map<String, dynamic>;
                final periodStart =
                (cycle['start date'] as Timestamp).toDate();
                final periodEnd =
                (cycle['period end'] as Timestamp).toDate();
                final fertileStart =
                (cycle['fertile start'] as Timestamp).toDate();
                final fertileEnd =
                (cycle['fertile end'] as Timestamp).toDate();
                final ovulation =
                (cycle['ovulation'] as Timestamp).toDate();

                // ── Determine primary phase ─────────────
                String phase;
                if ((_now.isAfter(periodStart) ||
                    DateUtils.isSameDay(_now, periodStart)) &&
                    (_now.isBefore(periodEnd) ||
                        DateUtils.isSameDay(_now, periodEnd))) {
                  phase = "Menstruation";
                } else if (DateUtils.isSameDay(_now, ovulation)) {
                  phase = "Ovulation";
                } else if ((_now.isAfter(fertileStart) ||
                    DateUtils.isSameDay(_now, fertileStart)) &&
                    (_now.isBefore(fertileEnd) ||
                        DateUtils.isSameDay(_now, fertileEnd))) {
                  phase = "Fertile";
                } else {
                  phase = "Luteal";
                }

                // ── Determine secondary phase ───────────
                // Follicular runs from period start through fertileEnd
                // (the day BEFORE ovulation, inclusive on both ends).
                // This aligns follicular end with fertileEnd in Firestore.
                String? phase2;
                final isInFollicularWindow =
                    (_now.isAfter(periodStart) ||
                        DateUtils.isSameDay(_now, periodStart)) &&
                        (_now.isBefore(fertileEnd) ||
                            DateUtils.isSameDay(_now, fertileEnd));

                if (isInFollicularWindow) {
                  phase2 = "Follicular";
                }

                if (mounted) {
                  setState(() {
                    cyclePhase = phase;
                    cyclePhase2 = phase2;
                  });
                }
              }
            });
          }
        }
      });
    }
  }

  Future<void> getLogStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userStat = FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot userInfo) {
        final data = userInfo.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          setState(() => start = data['status'] ?? true);
        }
      });
    }
  }

  Future<void> addCycleHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .get();
      final bool first = userData['emptyRecord'];

      await FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .update({'status': false, 'emptyRecord': false});

      int cycleLength = userData['cycle length'];

      final userSetting = await FirebaseFirestore.instance
          .collection('settings')
          .doc(user.uid)
          .get();
      final bool smartPrediction = userSetting['smart prediction'];

      if (smartPrediction && !first) {
        final history = FirebaseFirestore.instance
            .collection('cycle')
            .doc(user.uid)
            .collection('cycle history');
        final latest =
        await history.orderBy('start date', descending: true).limit(1).get();
        final latestId = latest.docs.first.id;

        final userCycleHistory = await FirebaseFirestore.instance
            .collection('cycle')
            .doc(user.uid)
            .collection('cycle history')
            .doc(latestId)
            .get();
        final periodStart =
        (userCycleHistory['start date'] as Timestamp).toDate();
        final previousCycleLength = _now.difference(periodStart);

        await FirebaseFirestore.instance
            .collection('cycle')
            .doc(user.uid)
            .collection('cycle history')
            .doc(latestId)
            .update({'cycle length': previousCycleLength.inDays});

        final allData = await history.get();
        final cycleLengths = allData.docs
            .map((doc) =>
        (doc.data() as Map<String, dynamic>)['cycle length'] as int? ??
            cycleLength)
            .toList();
        int sumOfCycleLength = 0;
        for (int len in cycleLengths) {
          sumOfCycleLength += len;
        }
        final average = (sumOfCycleLength / cycleLengths.length).ceil();
        cycleLength = average;

        await FirebaseFirestore.instance
            .collection('cycle')
            .doc(user.uid)
            .update({'cycle length': average});

        final fertileStart = periodStart
            .add(Duration(days: previousCycleLength.inDays - 20));
        final fertileEnd = fertileStart.add(const Duration(days: 6));
        final ovulation = fertileEnd.subtract(const Duration(days: 1));

        await FirebaseFirestore.instance
            .collection('cycle')
            .doc(user.uid)
            .collection('cycle history')
            .doc(latestId)
            .update({
          'fertile start': fertileStart,
          'fertile end': fertileEnd,
          'ovulation': ovulation,
        });
      }

      final int periodLength = userData['period length'];
      final DateTime startDate = _now;
      final DateTime endDate =
      startDate.add(Duration(days: cycleLength - 1));
      final DateTime periodEnd =
      startDate.add(Duration(days: periodLength - 1));
      final DateTime fertileStart =
      startDate.add(Duration(days: cycleLength - 20));
      final DateTime fertileEnd =
      fertileStart.add(const Duration(days: 6));
      final DateTime ovulation =
      fertileEnd.subtract(const Duration(days: 1));

      await FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .collection('cycle history')
          .doc(_now.toString())
          .set({
        'start date': startDate,
        'period end': periodEnd,
        'end date': endDate,
        'fertile start': fertileStart,
        'fertile end': fertileEnd,
        'ovulation': ovulation,
        'cycle length': cycleLength,
        'period length': periodLength,
      });

      if (mounted) setState(() => start = false);
    }
  }

  Future<void> updateCycleHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    final DateTime date = DateTime(_now.year, _now.month, _now.day);

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .update({'status': true});

      final userSetting = await FirebaseFirestore.instance
          .collection('settings')
          .doc(user.uid)
          .get();
      final bool smartPrediction = userSetting['smart prediction'];

      final history = FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .collection('cycle history');
      final latest =
      await history.orderBy('start date', descending: true).limit(1).get();
      final latestId = latest.docs.first.id;
      final cycleHistoryData = await FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .collection('cycle history')
          .doc(latestId)
          .get();

      if (smartPrediction) {
        final DateTime periodStart =
        (cycleHistoryData['start date'] as Timestamp).toDate();
        final currentPeriodLength =
            (date.difference(periodStart)) + const Duration(days: 1);

        await FirebaseFirestore.instance
            .collection('cycle')
            .doc(user.uid)
            .collection('cycle history')
            .doc(latestId)
            .update({'period length': currentPeriodLength.inDays});

        final allData = await history.get();
        final periodLengths = allData.docs
            .map((doc) => doc.get('period length') as int)
            .toList();
        int sumOfPeriodLength = 0;
        for (int len in periodLengths) {
          sumOfPeriodLength += len;
        }
        final average = (sumOfPeriodLength / periodLengths.length).ceil();

        await FirebaseFirestore.instance
            .collection('cycle')
            .doc(user.uid)
            .update({'period length': average});
      }

      await history.doc(latestId).update({'period end': date});
      if (mounted) setState(() => start = true);
    }
  }

  // ─────────────────────────────────────────────
  // CONFIRMATION DIALOG
  // Shows before starting or ending a period log.
  // Only calls the actual action on confirm.
  // ─────────────────────────────────────────────
  Future<void> _showCycleConfirmation() async {
    final bool isStarting = start;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ───────────────────────────
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB56A7E).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isStarting
                        ? Icons.water_drop_outlined
                        : Icons.check_circle_outline,
                    color: const Color(0xFFB56A7E),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Title ──────────────────────────
                Text(
                  isStarting ? "Start Period?" : "End Period?",
                  style: const TextStyle(
                    fontFamily: "CormorantGaramond",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF44222B),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Subtitle ───────────────────────
                Text(
                  isStarting
                      ? "This will start a new cycle and reset the counter back to Day 1."
                      : "This will mark today as the last day of your period and move to the next phase.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: "DMSans",
                    fontSize: 13,
                    color: Color(0xFF7A5566),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Buttons ────────────────────────
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFB56A7E),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontFamily: "DMSans",
                            color: Color(0xFFB56A7E),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Confirm
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB56A7E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          isStarting ? "Start" : "End",
                          style: const TextStyle(
                            fontFamily: "DMSans",
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      if (isStarting) {
        await addCycleHistory();
      } else {
        await updateCycleHistory();
      }
    }
  }

  // ─────────────────────────────────────────────
  // BUILD HOME CONTENT
  // ─────────────────────────────────────────────
  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final strip = _weekStrip;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HEADER ROW ───────────────────────────────────
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
                    Text(
                      'Hello, ${name ?? "User"}',
                      style: const TextStyle(
                        fontFamily: "CormorantGaramond",
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF44222B),
                      ),
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
                  child: Image.asset('assets/images/logo.png', height: 70),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── WEEKLY DAY STRIP ─────────────────────────────
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

                  // ── PROPORTIONAL CYCLE RING ─────────────────
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: _CycleRingPainter(
                          phaseIndex: _phaseIndex,
                          dayInPhase: _dayInPhase,
                          daysInCurrentCycle: daysInCurrentCycle,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 110,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ── Phase label(s) above the day number ──
                                if (cyclePhase2 != null) ...[
                                  Text(
                                    cyclePhase ?? "—",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: "DMSans",
                                      color: Color(0xFFF7F3F5),
                                      fontSize: 10,
                                      height: 1.3,
                                    ),
                                  ),
                                  Text(
                                    "& ${cyclePhase2!}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: "DMSans",
                                      color: _follicularColor,
                                      fontSize: 10,
                                      height: 1.3,
                                    ),
                                  ),
                                ] else
                                  Text(
                                    cyclePhase ?? "—",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: "DMSans",
                                      color: Color(0xFFF7F3F5),
                                      fontSize: 11,
                                      height: 1.2,
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  "Day ${daysInCurrentCycle ?? 0}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: "DMSans",
                                    color: Color(0xFFF7F3F5),
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── PHASE LEGEND (5 phases, scrollable) ──────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _legendDot(const Color(0xFFE57373), "MENSTRUATION"),
                        const SizedBox(width: 8),
                        _legendDot(_follicularColor, "FOLLICULAR"),
                        const SizedBox(width: 8),
                        _legendDot(const Color(0xFFFFD54F), "FERTILE"),
                        const SizedBox(width: 8),
                        _legendDot(const Color(0xFF6ED6A5), "OVULATION"),
                        const SizedBox(width: 8),
                        _legendDot(const Color(0xFF9C7FBF), "LUTEAL"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── COUNTDOWN CARDS ROW ───────────────────────────
            Builder(builder: (context) {
              final (nextPhase, daysToNextPhase) = _getNextPhaseInfo();
              return Row(
                children: [
                  Expanded(
                    child: _countdownCard(
                      'NEXT PHASE',
                      daysToNextPhase.toString(),
                      subtitle: nextPhase,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _countdownCard(
                      'NEXT PERIOD',
                      daysUntilNextCycle.toString(),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MAIN BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F5),
      body: Stack(
        children: [
          _selectedIndex == 1
              ? _buildHomeContent()
              : _pages[_selectedIndex],
          // Cat button only shown on home tab; tapping opens the
          // confirmation dialog before performing any Firestore writes.
          if (_selectedIndex == 1)
            Positioned(
              right: 0,
              bottom: 0,
              child: PeriodCatButton(
                isPeriodStatus: start,
                onTap: _showCycleConfirmation,
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
  // ─────────────────────────────────────────────
  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
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
  // ─────────────────────────────────────────────
  Widget _countdownCard(String title, String days, {String? subtitle}) {
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
          Text(
            subtitle != null ? 'days until $subtitle' : 'more days to go',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CYCLE RING PAINTER
//
// OUTER RING — 4 proportional arcs (clockwise from 12 o'clock):
//   Menstruation (5d) → Fertile (5d) → Ovulation (1d) → Luteal (17d)
//   Each arc span = (phaseDays / 28) × 360°
//   A 2.5° gap separates each segment.
//
// INNER RING — Follicular overlay arc:
//   Thinner ring drawn at a slightly smaller radius.
//   Spans angular range of days 1–10 (Menstruation + Fertile only).
//   Ends at fertileEnd — the day BEFORE ovulation.
//   Progresses based on daysInCurrentCycle, capped at _follicularDays (10).
//
// Arc states:
//   Completed phases  → full arc at 0.85 opacity
//   Active phase      → partial fill based on dayInPhase/phase.days
//   Future phases     → faint background track only (0.13 opacity)
// ─────────────────────────────────────────────
class _CycleRingPainter extends CustomPainter {
  final int phaseIndex;
  final int dayInPhase;
  final int? daysInCurrentCycle;

  const _CycleRingPainter({
    required this.phaseIndex,
    required this.dayInPhase,
    this.daysInCurrentCycle,
  });

  // Gap between segments in radians (~2.5°)
  static const double _gapRad = 0.0436;
  // Stroke width of the outer primary ring arcs
  static const double _sw = 16.0;
  // Stroke width of the inner follicular overlay arc
  static const double _follicularSw = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Outer ring radius — shrunk by half stroke to stay within bounds
    final outerRadius = (size.width / 2) - _sw;
    // Inner ring radius — sits just inside the outer ring with a small gap
    final innerRadius = outerRadius - _sw - 4;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    // ── OUTER RING: 4 primary phase segments ─────────
    double startAngle = -pi / 2;

    for (int i = 0; i < _cyclePhases.length; i++) {
      final phase = _cyclePhases[i];
      final segAngle = (phase.days / _totalDays) * 2 * pi - _gapRad;
      final rect = Rect.fromCircle(center: center, radius: outerRadius);

      paint.strokeWidth = _sw;

      // Background track (always visible, very faint)
      paint.color = phase.color.withOpacity(0.13);
      canvas.drawArc(rect, startAngle, segAngle, false, paint);

      if (i < phaseIndex) {
        // Completed phase: fully filled
        paint.color = phase.color.withOpacity(0.85);
        canvas.drawArc(rect, startAngle, segAngle, false, paint);
      } else if (i == phaseIndex) {
        // Active phase: partial fill
        final progress = (dayInPhase / phase.days).clamp(0.0, 1.0);
        final fillAngle = segAngle * progress;
        if (fillAngle > 0) {
          paint.color = phase.color.withOpacity(0.85);
          canvas.drawArc(rect, startAngle, fillAngle, false, paint);
        }
      }
      // Future phases: only the faint background track above.

      startAngle += segAngle + _gapRad;
    }

    // ── INNER RING: Follicular overlay ───────────────
    // Angular span covers Menstruation (5d) + Fertile (5d) = 10 days.
    // This ends at fertileEnd, the day before ovulation.
    // We include only the 1 gap between segment 0→1.
    // The gap before Ovulation is NOT included (follicular ends at fertileEnd).
    final follicularTotalAngle =
        (_follicularDays / _totalDays) * 2 * pi - (_gapRad * 1);
    final follicularRect =
    Rect.fromCircle(center: center, radius: innerRadius);

    paint.strokeWidth = _follicularSw;

    // Background track for follicular
    paint.color = _follicularColor.withOpacity(0.18);
    canvas.drawArc(
        follicularRect, -pi / 2, follicularTotalAngle, false, paint);

    // Progress fill: how many follicular days have elapsed (max 10)
    final follicularDay =
    (daysInCurrentCycle ?? 0).clamp(0, _follicularDays);
    if (follicularDay > 0) {
      final progress = follicularDay / _follicularDays;
      final fillAngle = follicularTotalAngle * progress;
      paint.color = _follicularColor.withOpacity(0.85);
      canvas.drawArc(follicularRect, -pi / 2, fillAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(_CycleRingPainter old) =>
      phaseIndex != old.phaseIndex ||
          dayInPhase != old.dayInPhase ||
          daysInCurrentCycle != old.daysInCurrentCycle;
}

// ─────────────────────────────────────────────
// PERIOD CAT BUTTON
// Animated floating cat with cloud bubble.
// Tapping triggers the confirmation dialog in the parent.
// Position and layout are unchanged from original.
// ─────────────────────────────────────────────
class PeriodCatButton extends StatefulWidget {
  final bool isPeriodStatus;
  final VoidCallback onTap;

  const PeriodCatButton({
    super.key,
    required this.isPeriodStatus,
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
      setState(() => _eyeIndex = (_eyeIndex + 1) % _catFrames.length);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final frame in _catFrames) {
      precacheImage(AssetImage(frame), context);
    }
    precacheImage(
        const AssetImage('assets/images/period_cat/cloud.png'), context);
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
            // Cloud bubble with floating animation
            AnimatedBuilder(
              animation: _cloudController,
              builder: (context, child) {
                final moveY =
                    -14 * Curves.easeInOut.transform(_cloudController.value);
                return Positioned(
                  top: 35,
                  right: 5,
                  child: Transform.translate(
                    offset: Offset(0, moveY),
                    child: SizedBox(
                      height: 150,
                      width: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/period_cat/cloud.png',
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            top: 24,
                            left: 17,
                            right: 28,
                            child: Text(
                              widget.isPeriodStatus
                                  ? "Period Starts?\nTap Me"
                                  : "Period Ends?\nTap Me",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: "CormorantGaramond",
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Cat with blinking/looking eyes
            Positioned(
              bottom: 0,
              right: 0,
              child: IndexedStack(
                index: _eyeIndex,
                children: _catFrames.map((frame) {
                  return Image.asset(frame, width: 155, fit: BoxFit.contain);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}