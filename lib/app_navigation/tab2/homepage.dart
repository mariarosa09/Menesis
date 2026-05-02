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
  StreamSubscription<DocumentSnapshot>? _userSub;
  StreamSubscription<DocumentSnapshot>? _userStat;
  StreamSubscription<DocumentSnapshot>? _userNextCycle;
  StreamSubscription? _history;
  // Check if the data is loading
  bool _isLoading = true;

  // Tracks which bottom nav tab is currently selected (default: Home = index 1)
  int _selectedIndex = 1;

  // Timer that ticks every minute to keep the greeting/date fresh
  late Timer _timer;

  // Check if the period log is start or end
  bool start = true;

  // Holds the current local time, updated by the timer
  DateTime _now = DateTime.now().toLocal();

  // Holds the days left until next cycle and period
  int? daysUntilNextCycle;
  int? daysInCurrentCycle;

  // The three screens mapped to each bottom nav tab
  late final List<Widget> _pages;

  // Holds the name of the user
  String? name;

  // For Current cycle status
  Color colorCycle = Colors.white;
  double percent = 0.0;

  //Cycle phase
  String? cyclePhase;

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
  const SizedBox(), // placeholder
  const ManageProfileScreen(),
];

    // Refresh time every minute so greeting and date stay accurate
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now().toLocal());
    });

    _loadAllData();
  }

  // ─────────────────────────────────────────────
  // DISPOSE
  // Cancels the timer when the widget is removed
  // from the tree to prevent memory leaks.
  // ─────────────────────────────────────────────
  @override
  void dispose() {
    _timer.cancel();
    _userSub?.cancel();
    _userStat?.cancel();
    _userNextCycle?.cancel();
    _history?.cancel();
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
    print("Error loading data: $e");
  }

  if (mounted) {
    setState(() {
      _isLoading = false;
    });
  }
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
  /*Future<String?> getUserName() async {
    String? authUid = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot user = await FirebaseFirestore.instance.collection('users').doc(authUid).get();
    if (user['first name'] == "") {
      return user['username'];
    }
    else {
      return user['first name'];
    }
  }*/

  /*Future<int?> nextCycleDays() async {
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
  }*/

  Future<void> nextCycleDays() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Empty record check
      _userNextCycle = FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot userInfo) {

        final data = userInfo.data() as Map<String, dynamic>?;
      
        if (data != null && mounted) {
          if (data['emptyRecord'] as bool) {
            setState(() {
              daysUntilNextCycle = 0;
            });
          }
          else {
            // Get latest record
            _history = FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history')
            .orderBy('start date', descending: true).limit(1).snapshots().listen((QuerySnapshot latest) {
              if(latest.docs.isNotEmpty && mounted) {
                final cycle = latest.docs.first.data() as Map<String, dynamic>;
                final cycleEnd = (cycle['end date'] as Timestamp).toDate();
                Duration daysLeft = (cycleEnd.difference(_now)) + Duration(days: 1);
                setState(() {
                  daysUntilNextCycle = daysLeft.inDays;
                });
              }
            });
          }
        }
        }
      );
    }
  }

  /*Future<int?> currentCycleDay() async {
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
      final periodStart = (userCycleHistory['start date'] as Timestamp).toDate();
      Duration dayInCycle = (_now.difference(periodStart)) + Duration(days: 1);

      return dayInCycle.inDays;
    }
  }*/

  Future<void> currentCycleDay() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Empty record check
      _userNextCycle = FirebaseFirestore.instance
          .collection('cycle')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot userInfo) {

        final data = userInfo.data() as Map<String, dynamic>?;
      
        if (data != null && mounted) {
          if (data['emptyRecord'] as bool) {
            setState(() {
              daysInCurrentCycle = 0;
            });
          }
          else {
            // Get latest record
            _history = FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history')
            .orderBy('start date', descending: true).limit(1).snapshots().listen((QuerySnapshot latest) {
              if(latest.docs.isNotEmpty && mounted) {
                final cycle = latest.docs.first.data() as Map<String, dynamic>;
                final periodStart = (cycle['start date'] as Timestamp).toDate();
                Duration dayInCycle = (_now.difference(periodStart)) + Duration(days: 1);
                setState(() {
                  daysInCurrentCycle = dayInCycle.inDays;
                });
              }
            });
          }
        }
        }
      );
    }
  }


 /* Future<List<dynamic>> modifyCycleDisplay() async {
    String? authUid = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot user = await FirebaseFirestore.instance.collection('cycle').doc(authUid).get();
    if (user['emptyRecord'] as bool) {
      return [0.0, Color(0xFFFFFFFF)];
    }
    else {
      double percent = 0.0;
      Color cycleColor = Color(0xFFFFFFFF);

      // Get latest record
      CollectionReference history = FirebaseFirestore.instance.collection('cycle').doc(authUid).collection('cycle history');
      final QuerySnapshot latest = await history.orderBy('start date', descending: true).limit(1).get();
      String latestId = latest.docs.first.id;

      // Get the previous cycle's length
      DocumentSnapshot userCycleHistory = await FirebaseFirestore.instance.collection('cycle').doc(authUid).collection('cycle history').doc(latestId).get();
      final periodStart = (userCycleHistory['start date'] as Timestamp).toDate();
      final periodEnd = (userCycleHistory['period end'] as Timestamp).toDate();
      final fertileStart = (userCycleHistory['fertile start'] as Timestamp).toDate();
      final fertileEnd = (userCycleHistory['fertile end'] as Timestamp).toDate();
      final ovulation = (userCycleHistory['ovulation'] as Timestamp).toDate();

      Duration dayInCycle = (_now.difference(periodStart)) + Duration(days: 1);
      percent = dayInCycle.inDays / user['cycle length'];

      if ((_now.isAfter(periodStart) || DateUtils.isSameDay(_now, periodStart)) &&
          (_now.isBefore(periodEnd) || DateUtils.isSameDay(_now, periodEnd))) {
        cycleColor = const Color(0xFFE57373);
      }
      else if (DateUtils.isSameDay(_now, ovulation)) {
        cycleColor = const Color(0xFF6ED6A5);
      }
      else if ((_now.isAfter(fertileStart) || DateUtils.isSameDay(_now, fertileStart)) &&
          (_now.isBefore(fertileEnd) || DateUtils.isSameDay(_now, fertileEnd))) {
        cycleColor = const Color(0xFFFFD54F);
      }
      else {
        cycleColor = const Color(0xFFFFFFFF);
      }

      return [percent, cycleColor];
    }
  }*/

  Future<void> modifyCycleDisplay() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Empty record check
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
              colorCycle = Color(0xFFFFFFFF);
            });
          }
          else {
            double percentage = 0.0;
            Color cycleColoring = Color(0xFFFFFFFF);
            // Get latest record
            _history = FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history')
            .orderBy('start date', descending: true).limit(1).snapshots().listen((QuerySnapshot latest) {
              if(latest.docs.isNotEmpty && mounted) {
                final cycle = latest.docs.first.data() as Map<String, dynamic>;
                final periodStart = (cycle['start date'] as Timestamp).toDate();
                final periodEnd = (cycle['period end'] as Timestamp).toDate();
                final fertileStart = (cycle['fertile start'] as Timestamp).toDate();
                final fertileEnd = (cycle['fertile end'] as Timestamp).toDate();
                final ovulation = (cycle['ovulation'] as Timestamp).toDate();

                Duration dayInCycle = (_now.difference(periodStart)) + Duration(days: 1);
                percentage = dayInCycle.inDays / data['cycle length'];

                if ((_now.isAfter(periodStart) || DateUtils.isSameDay(_now, periodStart)) &&
                    (_now.isBefore(periodEnd) || DateUtils.isSameDay(_now, periodEnd))) {
                  cycleColoring = const Color(0xFFE57373);
                }
                else if (DateUtils.isSameDay(_now, ovulation)) {
                  cycleColoring = const Color(0xFF6ED6A5);
                }
                else if ((_now.isAfter(fertileStart) || DateUtils.isSameDay(_now, fertileStart)) &&
                    (_now.isBefore(fertileEnd) || DateUtils.isSameDay(_now, fertileEnd))) {
                  cycleColoring = const Color(0xFFFFD54F);
                }
                else {
                  cycleColoring = const Color(0xFFFFFFFF);
                }

                if(mounted) {
                  setState(() {
                    percent = percentage;
                    colorCycle = cycleColoring;
                  });
                }
              }
            });
          }
        }
        }
      );
    }
  }

  /*Future<String?> getCycle() async {
    String? authUid = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot user = await FirebaseFirestore.instance.collection('cycle').doc(authUid).get();
    if (user['emptyRecord'] as bool) {
      return "Empty recod";
    }
    else {
      // Get latest record
      CollectionReference history = FirebaseFirestore.instance.collection('cycle').doc(authUid).collection('cycle history');
      final QuerySnapshot latest = await history.orderBy('start date', descending: true).limit(1).get();
      String latestId = latest.docs.first.id;

      // Get the previous cycle's length
      DocumentSnapshot userCycleHistory = await FirebaseFirestore.instance.collection('cycle').doc(authUid).collection('cycle history').doc(latestId).get();
      final periodStart = (userCycleHistory['start date'] as Timestamp).toDate();
      final periodEnd = (userCycleHistory['period end'] as Timestamp).toDate();
      final fertileStart = (userCycleHistory['fertile start'] as Timestamp).toDate();
      final fertileEnd = (userCycleHistory['fertile end'] as Timestamp).toDate();
      final ovulation = (userCycleHistory['ovulation'] as Timestamp).toDate();

      if ((_now.isAfter(periodStart) || DateUtils.isSameDay(_now, periodStart)) &&
          (_now.isBefore(periodEnd) || DateUtils.isSameDay(_now, periodEnd))) {
        return "Period";
      }
      if (DateUtils.isSameDay(_now, ovulation)) {
        return "Ovulation";
      }
      if ((_now.isAfter(fertileStart) || DateUtils.isSameDay(_now, fertileStart)) &&
          (_now.isBefore(fertileEnd) || DateUtils.isSameDay(_now, fertileEnd))) {
        return "Fertile";
      }
      else {
        return "Follicular/Luteal";
      }
    }
  }*/

  Future<void> getCycle() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Empty record check
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
            });
          }
          else {
            // Get latest record
            _history = FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history')
            .orderBy('start date', descending: true).limit(1).snapshots().listen((QuerySnapshot latest) {
              if(latest.docs.isNotEmpty && mounted) {
                final cycle = latest.docs.first.data() as Map<String, dynamic>;
                final periodStart = (cycle['start date'] as Timestamp).toDate();
                final periodEnd = (cycle['period end'] as Timestamp).toDate();
                final fertileStart = (cycle['fertile start'] as Timestamp).toDate();
                final fertileEnd = (cycle['fertile end'] as Timestamp).toDate();
                final ovulation = (cycle['ovulation'] as Timestamp).toDate();

                if ((_now.isAfter(periodStart) || DateUtils.isSameDay(_now, periodStart)) &&
                    (_now.isBefore(periodEnd) || DateUtils.isSameDay(_now, periodEnd))) {
                  if(mounted) {
                    setState(() {
                      cyclePhase = "Period";
                    });
                  }
                }
                else if (DateUtils.isSameDay(_now, ovulation)) {
                  if(mounted) {
                    setState(() {
                      cyclePhase = "Ovulation";
                    });
                  }
                }
                else if ((_now.isAfter(fertileStart) || DateUtils.isSameDay(_now, fertileStart)) &&
                    (_now.isBefore(fertileEnd) || DateUtils.isSameDay(_now, fertileEnd))) {
                  if(mounted) {
                    setState(() {
                      cyclePhase = "Fertile";
                    });
                  }
                }
                else {
                  if(mounted) {
                    setState(() {
                      cyclePhase = "Follicular/Luteal";
                    });
                  }
                }
              }
            });
          }
        }
        }
      );
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
          final status = data['status'] ?? "true";

          setState(() {
            start = status;
          });
        }
      });
    }
  }

  Future addCycleHistory() async {
    final user = FirebaseAuth.instance.currentUser;  

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('cycle').doc(user.uid).get();

      bool first = userData['emptyRecord'];

      await FirebaseFirestore.instance.collection('cycle').doc(user.uid).update({
          'status': false,
          'emptyRecord': false
      }); 

      int cycleLength = userData['cycle length'];
      
      // Get setting data for smart prediction
      DocumentSnapshot userSetting = await FirebaseFirestore.instance.collection('settings').doc(user.uid).get();
      bool smartPrediction = userSetting['smart prediction'];

      // If smart prediction is on recompute and update the cycle length 
      if (smartPrediction && !first) {
        // Get latest record
        CollectionReference history = FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history');
        final QuerySnapshot latest = await history.orderBy('start date', descending: true).limit(1).get();
        String latestId = latest.docs.first.id;

        // Get the previous cycle's length
        DocumentSnapshot userCycleHistory = await FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history').doc(latestId).get();
        final periodStart = (userCycleHistory['start date'] as Timestamp).toDate();
        Duration previousCycleLength = _now.difference(periodStart);

        // Update previous cycle's cycle length
        await FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history').doc(latestId).update({
          'cycle length': previousCycleLength.inDays
        });

        // Get all cycle lengths
        QuerySnapshot allData = await history.get();
        List<int> cycleLengths = allData.docs.map((doc) => (doc.get('cycle length') as int)).toList();
        int sumOfCycleLength = 0;
        int numOfCycleLength = cycleLengths.length;
        for (int len in cycleLengths) {
          sumOfCycleLength += len;
        }
        int average = (sumOfCycleLength / numOfCycleLength).ceil();
        cycleLength = average;

        // Update cycle length in the database
        await FirebaseFirestore.instance.collection('cycle').doc(user.uid).update({
          'cycle length': average
        });

        // Compute the previous fertile and ovulation based on the cycle length
        DateTime fertileStart = periodStart.add(Duration(days: previousCycleLength.inDays-20));
        DateTime fertileEnd = fertileStart.add(Duration(days: 6));
        DateTime ovulation = fertileEnd.subtract(Duration(days: 1));

        // Update the database
        await FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history').doc(latestId).update({
          'fertile start': fertileStart,
          'fertile end': fertileEnd,
          'ovulation': ovulation
        });
      }
      
      // Get the average periodLength and cycleLength (on and off)
      int periodLength = userData['period length'];
      

      // Compute predictions (on and off)
      DateTime startDate = _now;
      DateTime endDate = startDate.add(Duration(days: cycleLength-1));
      DateTime periodEnd = startDate.add(Duration(days: periodLength-1));
      DateTime fertileStart = startDate.add(Duration(days: cycleLength-20));
      DateTime fertileEnd = fertileStart.add(Duration(days: 6));
      DateTime ovulation = fertileEnd.subtract(Duration(days: 1));

      // Add predictions to the firebase (on and off smart prediction)
      await FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history').doc(_now.toString()).set({
        'start date': startDate,
        'period end': periodEnd,
        'end date': endDate,
        'fertile start': fertileStart,
        'fertile end': fertileEnd,
        'ovulation': ovulation
      });
      if(mounted) {
        setState(() {
          start = false;
        });
      }
    }
  }

  Future updateCycleHistory() async {
    final user = FirebaseAuth.instance.currentUser;  
    DateTime date = DateTime(_now.year, _now.month, _now.day);

    if (user != null) {
      // Update status for the add period log button and tracking of start and end date
      await FirebaseFirestore.instance.collection('cycle').doc(user.uid).update({
          'status': true
      });

      // Get setting data for smart prediction
      DocumentSnapshot userSetting = await FirebaseFirestore.instance.collection('settings').doc(user.uid).get();
      bool smartPrediction = userSetting['smart prediction'];
      
      // Get the uid of the latest cycle history
      final CollectionReference history = FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history');
      final QuerySnapshot latest = await history.orderBy('start date', descending: true).limit(1).get();
      String latestId = latest.docs.first.id;
      // Get the document of the latest cycle
      DocumentSnapshot cycleHistoryData = await FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history').doc(latestId).get();

      if(smartPrediction) {
        // Compute current period length
        DateTime periodStart = (cycleHistoryData['start date'] as Timestamp).toDate();
        DateTime periodEnd = date;
        Duration currentPeriodLength = (periodEnd.difference(periodStart)) + Duration(days: 1);

        // Update the current cycle period length
        await FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history').doc(latestId).update({
          'period length': currentPeriodLength.inDays
        });

        // Get the list of period lengths
        QuerySnapshot allData = await history.get();
        List<int> cycleLengths = allData.docs.map((doc) => (doc.get('period length') as int)).toList();
        int sumOfPeriodLength = 0;
        int numOfPeriodLength = cycleLengths.length;
        for (int len in cycleLengths) {
          sumOfPeriodLength += len;
        }
        int average = (sumOfPeriodLength / numOfPeriodLength).ceil();

        // Update period length in the database
        await FirebaseFirestore.instance.collection('cycle').doc(user.uid).update({
          'period length': average
        });
      }
      // Update end period date in the database
      await history.doc(latestId).update({
        'period end': date,
      });
      if (mounted) {
        setState(() {
          start = true;
        });
      }
    }
  }

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
    if (_isLoading) {
      return const Center (
        child: CircularProgressIndicator(),
      );
    }
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
                    Text(
                              'Hello, $name',
                              style: TextStyle(
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
                                  value: percent,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.white24,
                                  valueColor: AlwaysStoppedAnimation(
                                      colorCycle),
                                ),
                              ),
                    

                        // Text overlay in the center of the ring
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                    // TODO: (EDIT) Palitan ng dynamic na phase name
                                    // base sa computed cycle phase ng user.
                                    // The code should be placed here
                                    "$cyclePhase Phase",
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
                                    "Day $daysInCurrentCycle",
                                    style: TextStyle(
                                      fontFamily: "DMSans",
                                      color: Color(0xFFF7F3F5),
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )

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
                      _legendDot(const Color(0xFFFFFFFF), "FOLLICULAR/LUTEAL")
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

            Row(
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
                  ),

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
          _selectedIndex == 1
    ? _buildHomeContent()
    : _pages[_selectedIndex],

          if (_selectedIndex == 1)
            Positioned(
              right: 0,
              bottom: 0,
              child: PeriodCatButton(
                isPeriodStatus: start,
                onTap: start ? addCycleHistory : updateCycleHistory, // add logic
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

            // CATTTTT
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