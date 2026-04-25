// ============================================================
// FILE: main.dart
// DESCRIPTION: Entry point ng app. Contains the CalendarScreen
//              which shows the monthly calendar, selected date
//              info, daily log card, and navigation to other
//              bottom sheets (DailyLog, PossibleReasons, Remedy).
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/app_navigation/tab1/dailyLog.dart';
import '/app_navigation/tab1/viewReason.dart';
import '/app_navigation/tab1/viewRemedy.dart';

// ── App Entry Point ──────────────────────────────────────────
// Ito ang unang tumatakbo pagbukas ng app.
// Naglulunsad ng MyApp widget bilang root ng application.
/*void main() {
  runApp(const MyApp());
}*/

// ── Root Widget ──────────────────────────────────────────────
// Defines the overall MaterialApp configuration:
// app title, debug banner, at kung anong screen ang unang lalabas.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mēnesis',
      home: const CalendarScreen(),
    );
  }
}

// ── CalendarScreen (StatefulWidget) ─────────────────────────
// Main screen ng app. Ito ang nagmo-manage ng buong calendar view,
// selected date, at lahat ng log-related na widgets.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends State<CalendarScreen> {

  // ── State Variables ─────────────────────────────────────────
  // Tracks the current date, the currently viewed month,
  // and the currently selected date on the calendar.
  // _logText and _noteText store the user's log and personal note.
  final DateTime _today = DateTime.now();
  late DateTime _selectedMonth;
  late DateTime _selectedDate;

  bool start = true;

  List<DateTime>? startDate;
  List<DateTime>? endDate;
  List<DateTime>? startFertile;
  List<DateTime>? endFertile;
  List<DateTime>? ovulation;

  String _logText  = '';
  String _noteText = '';

  // TODO: (ADDING) I-store ang period log dates at predictions sa state o database.
  // Kapag nag-add ng period log, dapat may listahan ng mga petsa na naka-mark
  // bilang "period", "ovulation", o "fertile" para ma-display sa calendar.
  // Gamitin ang SharedPreferences o isang local database (tulad ng sqflite) para
  // ma-persist ang data kahit isara ang app.
  // Example structure:
  //   List<DateTime> periodDates = [];
  //   Map<DateTime, String> calendarMarkers = {}; // 'period', 'fertile', 'ovulation'
  //
  // The code should be placed here

  // TODO: (ADDING) I-store ang log data na galing sa DailyLog bottom sheet.
  // Kapag nag-save ang user sa dailyLog.dart, dapat ang piniling symptoms/flow/mood
  // ay mabalik dito sa _logText para ma-display sa "Your Log" card.
  // Pwedeng gumamit ng callback function o ValueNotifier para ma-pass ang data pabalik.
  //
  // The code should be placed here

  // ── Static Month Name List ───────────────────────────────────
  // Ginagamit para i-convert ang month number (1-12) sa text na pangalan.
  static const _months = [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];

  // ── Initialization ───────────────────────────────────────────
  // Tinatakda ang default na buwan at petsa pagkakarga ng screen.
  // Default: current month at current day.
  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(_today.year, _today.month);
    _selectedDate  = _today;
    getLogStatus();
    getNotes();
  }

  // ── Helper: Month Name & Date Formatter ─────────────────────
  // _monthName() → converts int month to its string equivalent (e.g., 4 → "April")
  // _formatDate() → formats a DateTime into readable text (e.g., "April 19, 2026")
  String _monthName(int m) => _months[m - 1];
  String _formatDate(DateTime d) => "${_months[d.month - 1]} ${d.day}, ${d.year}";

  // ── Bottom Sheet: Daily Log ──────────────────────────────────
  // Nagbubukas ng DailyLog screen bilang draggable bottom sheet.
  // Tinatanggap ang selected date para malaman kung anong araw ang lilo-log.
  void getLogStatus() async {
    final user = FirebaseAuth.instance.currentUser;  
    if (user != null) {
      DocumentSnapshot userCycleInfo = await FirebaseFirestore.instance.collection('cycle').doc(user.uid).get();
      setState(() {
        start = userCycleInfo['status'];
      });
    }
  }

  void getNotes() async {
    final user = FirebaseAuth.instance.currentUser;  
    if (user != null) {
      DocumentSnapshot log = await FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('logs').doc(_selectedDate.toString()).get();
      if (mounted) {
        setState(() {
          if (log.exists) {
            _noteText = log['notes'] ?? ""; 
          } 
          else {
            _noteText = "";           
          }
        });
      }
    }
  }

  void saveNotes() async {
    final user = FirebaseAuth.instance.currentUser;
    DateTime date = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (user != null) {
      await FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('logs').doc(date.toString()).set({
        'notes': _noteText.trim(),
      },
      SetOptions(merge: true));
    }
  }

  void _openDailyLog(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F3F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle — visual indicator na pwedeng i-drag pataas/pababa
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AABB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: dailyLog(selectedDate: date),

                  // TODO: (EDITING) Palitan ang simpleng 
                  //() call ng may callback.
                  // Para mabalik ang log data (symptoms, flow, mood, atbp.) sa parent widget,
                  // dapat may onSave callback ang dailyLog widget.
                  // Example: dailyLog(selectedDate: date, onSave: (logData) { ... })
                  // Kapag na-save, i-update ang _logText sa setState().
                  //
                  // The code should be placed here
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Sheet: Possible Reasons ──────────────────────────
  // Nagbubukas ng PossibleReasonsScreen bilang bottom sheet.
  // Ipinapakita ang mga posibleng dahilan ng symptoms ng user.
  void _openPossibleReasons() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F3F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AABB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Expanded(
                child: PossibleReasonsScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Sheet: Remedy Suggestions ────────────────────────
  // Nagbubukas ng RemedySuggestionsScreen bilang bottom sheet.
  // Ipinapakita ang mga remedyo base sa logs ng user.
  void _openRemedySuggestions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F3F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AABB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Expanded(
                child: RemedySuggestionsScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // When the user selects the start of the start period it predicts the period end date, fertile days and ovulation
  Future addCycleHistory(DateTime selectedDate) async {
    final user = FirebaseAuth.instance.currentUser;  

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('cycle').doc(user.uid).get();

      bool first = userData['emptyRecord'];

      await FirebaseFirestore.instance.collection('cycle').doc(user.uid).update({
          'status': false,
          'emptyRecord': false
      }); 
      
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
        Duration previousCycleLength = selectedDate.difference(periodStart);

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
      int cycleLength = userData['cycle length'];

      // Compute predictions (on and off)
      DateTime startDate = selectedDate;
      DateTime endDate = startDate.add(Duration(days: cycleLength-1));
      DateTime periodEnd = startDate.add(Duration(days: periodLength-1));
      DateTime fertileStart = startDate.add(Duration(days: cycleLength-20));
      DateTime fertileEnd = fertileStart.add(Duration(days: 6));
      DateTime ovulation = fertileEnd.subtract(Duration(days: 1));

      // Add predictions to the firebase (on and off smart prediction)
      await FirebaseFirestore.instance.collection('cycle').doc(user.uid).collection('cycle history').doc(selectedDate.toString()).set({
        'start date': startDate,
        'period end': periodEnd,
        'end date': endDate,
        'fertile start': fertileStart,
        'fertile end': fertileEnd,
        'ovulation': ovulation
      });
      setState(() {
        start = false;
      });
    }
  }

  Future updateCycleHistory(DateTime selectedDate) async {
    final user = FirebaseAuth.instance.currentUser;  

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
        DateTime periodEnd = selectedDate;
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
        'period end': selectedDate,
      });
      setState(() {
        start = true;
      });
    }
  }

  
  // ── Main Build Method ────────────────────────────────────────
  // Binubuo ang buong UI ng CalendarScreen:
  // calendar grid, date selector, log card, at FAB button.
  @override
  Widget build(BuildContext context) {

    // ── Calendar Grid Calculation ────────────────────────────
    // Kinakalkula ang bilang ng mga araw sa buwan, kung saan magsisimula
    // ang una sa week (offset), at kung ilan ang trailing ghost cells.
    final daysInMonth   = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final firstWeekday  = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;
    final totalCells    = firstWeekday + daysInMonth;
    final trailingCells = (7 - (totalCells % 7)) % 7;

    final prevMonth  = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final daysInPrev = DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

    // ── Day Cell Builder Loop ────────────────────────────────
    // Gumagawa ng listahan ng day cells:
    // - Ghost cells para sa nakaraang buwan (dimmed)
    // - Real day cells para sa kasalukuyang buwan
    // - Ghost cells para sa susunod na buwan (dimmed)
    final List<Widget> dayCells = [];
    for (int i = 0; i < firstWeekday; i++) {
      dayCells.add(_buildGhostCell(daysInPrev - firstWeekday + 1 + i));
    }
    for (int day = 1; day <= daysInMonth; day++) {
      dayCells.add(_buildDayCell(day));
    }
    for (int i = 1; i <= trailingCells; i++) {
      dayCells.add(_buildGhostCell(i));
    }

    // TODO: (ADDING) I-highlight ang mga araw na may period, fertile, o ovulation markers.
    // Sa _buildDayCell(), i-check kung ang petsa ay nasa loob ng period dates o prediction range.
    // Gumamit ng background color ayon sa legend:
    //   - Period     → Color(0xFFe2acb5)
    //   - Ovulation  → Color(0xFFaedbc8)
    //   - Fertile    → Color(0xFFddcb9c)
    // Para sa prediction, gamitin ang average cycle length (default: 28 days) bilang base.
    //
    // The code should be placed here 

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F5),

      // ── Floating Action Button ───────────────────────────────
      // Ang "Add Period Log" button sa ibaba ng screen.
      // Pagpindot nito, dapat magbukas ng period log input form.
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFAA556B),
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                backgroundColor: const Color(0xFFFFFBFC),
                title: Text(
                  start ? "Period starts" : "Period Ends",
                  style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A1F3D),
                    ),
                  ),
                  content: Text(
                    start ? "Are you sure your period starts on ${_formatDate(_selectedDate)}?" :
                    "Are you sure your period ends on ${_formatDate(_selectedDate)}?",
                    style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); 
                      _selectedDate = _today;
                    },
                    child: const Text(
                      "Select a date",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (start) {
                        addCycleHistory(_selectedDate);
                      }
                      else {
                        updateCycleHistory(_selectedDate);
                      }
                      _refreshData();
                      Navigator.of(context).pop();
                      // display the prediction in the calendar
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Color(0xFFB56A7E),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              );
            }
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          start ? "Start Period" : "End Period",
          style: TextStyle(fontFamily: "DMSans", color: Colors.white),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ── Month Navigation Header ──────────────────
                    // Nagpapakita ng pangalan ng buwan at taon sa gitna,
                    // at left/right arrows para mag-navigate sa iba't ibang buwan.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left arrow — pumunta sa nakaraang buwan
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(12),
                            child: IconButton(
                              splashColor: const Color(0xFFB56A7E).withOpacity(0.2),
                              highlightColor: const Color(0xFFB56A7E).withOpacity(0.3),
                              onPressed: () => setState(() => _selectedMonth =
                                  DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
                              icon: const Icon(Icons.chevron_left, color: Color(0xFF3A1F3D)),
                            ),
                          ),

                          // Month + Year pill display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9E6878), Color(0xFF7A4D5E)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "${_monthName(_selectedMonth.month)} ${_selectedMonth.year}",
                              style: const TextStyle(
                                fontFamily: "DMSans",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Right arrow — pumunta sa susunod na buwan
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(12),
                            child: IconButton(
                              splashColor: const Color(0xFFB56A7E).withOpacity(0.2),
                              highlightColor: const Color(0xFFB56A7E).withOpacity(0.3),
                              onPressed: () => setState(() => _selectedMonth =
                                  DateTime(_selectedMonth.year, _selectedMonth.month + 1)),
                              icon: const Icon(Icons.chevron_right, color: Color(0xFF3A1F3D)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Day Labels Row (Sun–Sat) ──────────────────
                    // Nagpapakita ng column headers ng calendar (araw ng linggo).
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                            .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: const TextStyle(
                                  fontFamily: "DMSans",
                                  fontSize: 11,
                                  color: Colors.black54,
                                )),
                          ),
                        ))
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ── Calendar Grid ────────────────────────────
                    // Ipinapakita ang grid ng mga araw para sa napiling buwan.
                    // Gumagamit ng 7-column GridView (Sun hanggang Sat).
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.count(
                        crossAxisCount: 7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 0.85,
                        children: dayCells,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Calendar Legend ──────────────────────────
                    // Nagpapakita ng color guide para sa mga marker sa calendar:
                    // Period, Ovulation, Fertile, at Today.
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _legendDot(const Color(0xFFe2acb5), "Period"),
                          _legendDot(const Color(0xFFaedbc8), "Ovulation"),
                          _legendDot(const Color(0xFFddcb9c), "Fertile"),
                          _legendDot(const Color(0xFF884456), "Today"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Selected Date Divider Pill ────────────────
                    // Nagpapakita ng divider line na may date pill sa gitna.
                    // Ipinapakita ang kasalukuyang napiling petsa sa calendar.
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Divider(
                          color: Color(0xFFEEDDE1),
                          thickness: 1.5,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9E6878), Color(0xFF7A4D5E)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _formatDate(_selectedDate),
                            style: const TextStyle(
                              fontFamily: "DMSans",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Your Log Card ────────────────────────────
                    // Ipinapakita ang log ng user para sa napiling petsa.
                    // May "Note" section at mga action buttons para sa View Reason/Remedy.
                    // IMPORTANT: Ang "View Reason" at "View Remedy" ay HINDI lalabas
                    // kapag wala pa ring laman ang _logText.
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _overlapSection(
                        label: "Your Log",
                        onAddLog: () => _openDailyLog(_selectedDate),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFF301C29), width: 0.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // ── Log Summary Text ────────────────
                                  // Ipinapakita ang buod ng log (symptoms, flow, etc.)
                                  // na galing sa dailyLog. Hidden kapag wala pang laman.
                                  if (_logText.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 14),
                                      child: Text(
                                        _logText,
                                        style: const TextStyle(
                                          fontFamily: "DMSans",
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),

                                  // ── Note Section ────────────────────
                                  // Nagpapakita ng personal note ng user.
                                  // May placeholder text kapag wala pang note.
                                  // Double tap anywhere on the note area to edit.
                                  GestureDetector(
                                    onDoubleTap: () => _showEditDialog(
                                      "Edit Note",
                                      _noteText,
                                          (val) => setState(() => _noteText = val),
                                    ),
                                    child: _overlapSectionNote(
                                      label: "Note",
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.fromLTRB(10, 22, 10, 12),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color(0xFF301C29), width: 0.5),
                                        ),
                                        child: Text(
                                          _noteText.isNotEmpty
                                              ? _noteText
                                              : "Double tap to add note...",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Georgia',
                                            fontStyle: _noteText.isEmpty
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                            color: _noteText.isNotEmpty
                                                ? const Color(0xFF4A2C3A)
                                                : Colors.black38,
                                            height: 1.55,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // TODO: (EDITING) I-save ang note sa database kapag nag-edit ang user.
                                  // Sa _showEditDialog onSave callback, dagdag ng database save call.
                                  // Gumamit ng sqflite o shared_preferences para ma-persist ang note
                                  // kahit isara ang app. I-associate ang note sa specific na petsa (_selectedDate).
                                  //
                                  // The code should be placed here

                                  const SizedBox(height: 14),

                                  // ── View Reason / View Remedy Buttons ──
                                  // Ipinapakita lamang kapag may laman na ang _logText.
                                  // Kapag walang log pa, nakatago ang mga button na ito.
                                  if (_logText.isNotEmpty)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _mauveButton("View Reason", _openPossibleReasons),
                                        const SizedBox(width: 12),
                                        _mauveButton("View Remedy", _openRemedySuggestions),
                                      ],
                                    ),

                                  // TODO: (ADDING) Kapag nag-click ng "View Reason" o "View Remedy",
                                  // dapat ang content ng bottom sheet ay based sa actual na log data.
                                  // I-pass ang _logText o structured log object sa PossibleReasonsScreen
                                  // at RemedySuggestionsScreen para ma-filter ang tamang content.
                                  //
                                  // The code should be placed here
                                ],
                              ),
                            ),

                            // ── Add/Edit Log Shortcut ─────────────
                            // Nagpapakita ng "Add Log" o "Edit Log" link sa kanang bahagi ng card.
                            // Nag-o-open ng DailyLog bottom sheet pagpindot.
                            Positioned(
                              top: 2,
                              right: 15,
                              child: GestureDetector(
                                onTap: () => _openDailyLog(_selectedDate),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add, size: 13, color: Colors.black),
                                    const SizedBox(width: 3),
                                    Text(
                                      _logText.isEmpty ? "Add Log" : "Edit Log",
                                      style: const TextStyle(
                                        fontFamily: "CormorantGaramond",
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        height: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom padding para hindi matakpan ng FAB ang laman
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit Dialog ──────────────────────────────────────────────
  // Nagpapakita ng AlertDialog na may TextField para mag-edit ng note.
  // Tinatanggap ang title, current value, at onSave callback.
  // Ginagamit para sa pag-edit ng "Note" section sa log card.
  void _showEditDialog(String title, String current, ValueChanged<String> onSave) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
              fontFamily: "DMSans",
              color: Color(0xFF3A1F3D),
              fontWeight: FontWeight.bold,
            )),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F3F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: const TextStyle(fontFamily: "DMSans", fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel",
                style: TextStyle(fontFamily: "DMSans", color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB56A7E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text("Save",
                style: TextStyle(fontFamily: "DMSans", color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Day Cell Widget (Current Month) ─────────────────────────
  // Gumagawa ng tappable day cell para sa bawat araw ng kasalukuyang buwan.
  // May espesyal na styling para sa:
  //   - Today (dark rose background, "Today" label)
  //   - Selected date (light gray background)
  //   - Regular days (transparent)
  // Single tap → piliin ang petsa
  // Double tap → piliin at agad buksan ang DailyLog

  Future<(List<DateTime>, List<DateTime>, List<DateTime>, List<DateTime>, List<DateTime>)> getCycleData() async {
    final user = FirebaseAuth.instance.currentUser;
    CollectionReference history = FirebaseFirestore.instance.collection('cycle').doc(user!.uid).collection('cycle history');
    QuerySnapshot allData = await history.get();

    List<DateTime> startDate = allData.docs.map((doc) => (doc.get('start date') as Timestamp).toDate()).toList();
    List<DateTime> endDate = allData.docs.map((doc) => (doc.get('period end') as Timestamp).toDate()).toList();
    List<DateTime> startFertile = allData.docs.map((doc) => (doc.get('fertile start') as Timestamp).toDate()).toList();
    List<DateTime> endFertile = allData.docs.map((doc) => (doc.get('fertile end') as Timestamp).toDate()).toList();
    List<DateTime> ovulation = allData.docs.map((doc) => (doc.get('ovulation') as Timestamp).toDate()).toList();
  
    return (startDate, endDate, startFertile, endFertile, ovulation);
  }

  void _refreshData() async {
    final data = await getCycleData();

    setState(() {
      startDate = data.$1;
      endDate = data.$2;
      startFertile = data.$3;
      endFertile = data.$4;
      ovulation = data.$5;
    });
  }

  /*Future<Color> getBgColor(int day) async {
    

  }*/

  Widget _buildDayCell(int day) {
    
    return FutureBuilder(
      future: getCycleData(),
      builder: (context, snapshot) {
        final isSelected = day == _selectedDate.day &&
        _selectedMonth.month == _selectedDate.month &&
        _selectedMonth.year  == _selectedDate.year;
    final thisDay = DateTime(_selectedMonth.year, _selectedMonth.month, day);

    final isToday = day == _today.day &&
        _selectedMonth.month == _today.month &&
        _selectedMonth.year  == _today.year;

    
    // TODO: (EDITING) Dagdag ng color override para sa period/fertile/ovulation markers.
    // Bago i-assign ang bgColor, i-check muna kung ang thisDay ay nasa calendarMarkers map.
    // Kung oo, gamitin ang kulay na nakatakda sa legend para sa marker type.
    // Priority order: Today > Selected > Marker > Transparent
    //
    // The code should be placed here

    Color textColor = isToday ? Colors.white : Colors.black87;
    Color bgColor = Colors.transparent;
    bool isPeriod = false;
    bool isFertile = false;
    bool isOvulation = false;

    if (snapshot.hasData) {
      final (startDate, endDate, startFertile, endFertile, ovulation) = snapshot.data!;

    for(int i = 0; i < startDate.length; i++) {
      DateTime date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      
      if ((date.isAfter(startDate[i]) || DateUtils.isSameDay(date, startDate[i])) && 
      (date.isBefore(endDate[i]) || DateUtils.isSameDay(date, endDate[i]))) {
        isPeriod = true;
      }
      if ((date.isAfter(startFertile[i]) || DateUtils.isSameDay(date, startFertile[i])) && 
      (date.isBefore(endFertile[i]) || DateUtils.isSameDay(date, endFertile[i]))) {
        isFertile = true;
      }
      if (DateUtils.isSameDay(date, ovulation[i])) {
        isOvulation = true;
      }
    }    
  }

  if (isToday) {
    bgColor = const Color(0xFF884456);
  } else if (isSelected) {
    bgColor = const Color(0xFFD6D6D6);
  } else if (isOvulation) {
    bgColor = const Color(0xFFaedbc8);
  } else if (isPeriod) {
    bgColor = const Color(0xFFe2acb5);
  } else if (isFertile) {
    bgColor = const Color(0xFFddcb9c);
  } else {
    bgColor = Colors.transparent;
  }

      return GestureDetector(
          onTap: () => setState(() => _selectedDate = thisDay),
          onDoubleTap: () {
            setState(() => _selectedDate = thisDay);
            _openDailyLog(thisDay);
          },
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
              width: 50,
              height: isToday ? 50 : 45,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
        
              // ── Cell Content ───────────────────────────────────
              // "Today" cell shows a "Today" label above the day number.
              // All other cells show only the day number.
              child: isToday
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Today",
                    style: TextStyle(
                      fontFamily: "CormorantGaramond",
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "$day",
                    style: const TextStyle(
                      fontFamily: "DMSans",
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
                  : Text(
                "$day",
                style: TextStyle(
                  fontFamily: "DMSans",
                  fontSize: 13,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  // ── Ghost Cell Widget (Prev / Next Month) ────────────────────
  // Nagpapakita ng dimmed day numbers para sa mga araw na hindi
  // kabilang sa kasalukuyang buwan (padding cells ng grid).
  Widget _buildGhostCell(int day) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        width: 34,
        height: 34,
        alignment: Alignment.center,
        child: Text(
          "$day",
          style: const TextStyle(
            fontFamily: "DMSans",
            fontSize: 13,
            color: Color(0xFFCCCCCC),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ── Overlap Section Widget ───────────────────────────────────
  // Gumagawa ng section container na may floating label sa taas na
  // sumasaklaw sa border ng loob na widget (CSS-style label overlap effect).
  // Ginagamit para sa "Your Log" section heading.
  Widget _overlapSection({
    required String label,
    required Widget child,
    VoidCallback? onAddLog,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(padding: const EdgeInsets.only(top: 19), child: child),
        Positioned(
          top: 0,
          left: 8,
          child: Container(
            color: const Color(0xFFF7F3F5),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: "DMSans",
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A1F3D),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Overlap Section Note Widget ──────────────────────────────
  // Katulad ng _overlapSection pero para sa mas maliit na "Note" label.
  // Ginagamit para sa note box sa loob ng Your Log card.
  Widget _overlapSectionNote({required String label, required Widget child}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(padding: const EdgeInsets.only(top: 14), child: child),
        Positioned(
          top: 0,
          left: 8,
          child: Container(
            color: const Color(0xFFF7F3F5),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: "CormorantGaramond",
                fontSize: 18,
                color: Color(0xFF3A1F3D),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Read-Only Area Card ──────────────────────────────────────
  // Nagpapakita ng read-only text container na may border.
  // NOTE: Hindi ginagamit sa kasalukuyang build() — pwedeng gamitin
  // sa hinaharap para sa non-editable log display sections.
  Widget _readOnlyAreaCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF301C29), width: 0.5),
      ),
      child: text.isNotEmpty
          ? Text(text,
          style: const TextStyle(
            fontFamily: "DMSans",
            fontSize: 13,
            color: Colors.black87,
          ))
          : const SizedBox.shrink(),
    );
  }

  // ── Mauve Button Widget ──────────────────────────────────────
  // Reusable styled button na may mauve/rose na background.
  // Ginagamit para sa "View Reason" at "View Remedy" buttons.
  Widget _mauveButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
            color: const Color(0xFFAA556B),
            borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: const TextStyle(
              fontFamily: "CormorantGaramond",
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.8,
            )),
      ),
    );
  }

  // ── Legend Dot Widget ────────────────────────────────────────
  // Gumagawa ng isang legend item: kulay na bilog + label.
  // Ginagamit sa legend row sa ibaba ng calendar grid.
  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
              fontFamily: "CormorantGaramond",
              fontSize: 12,
              color: Colors.black54,
            )),
      ],
    );
  }
}