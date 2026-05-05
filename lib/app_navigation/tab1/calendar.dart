// ============================================================
// FILE: main.dart
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/app_navigation/tab1/dailyLog.dart';
import '/app_navigation/tab1/viewReason.dart';
import '/app_navigation/tab1/viewRemedy.dart';

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

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends State<CalendarScreen> {

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

  bool _isvalidDay = true;

  static const _months = [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(_today.year, _today.month);
    _selectedDate  = _today;
    getLogStatus();
    getNotes(_selectedDate);
    getLogText(_selectedDate);
  }

  String _monthName(int m) => _months[m - 1];
  String _formatDate(DateTime d) => "${_months[d.month - 1]} ${d.day}, ${d.year}";

  void getLogText(DateTime selectedDate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final log = await FirebaseFirestore.instance
        .collection('cycle')
        .doc(user.uid)
        .collection('logs')
        .doc(date.toString())
        .get();

    if (!mounted) return;

    if (!log.exists) {
      setState(() => _logText = '');
      return;
    }

    final symptoms  = (log['physical symptoms'] as List?)?.cast<String>() ?? [];
    final moods     = (log['mood'] as List?)?.cast<String>() ?? [];
    final discharge = (log['discharge'] as List?)?.cast<String>() ?? [];

    const symptomIcon = {
      "Cramps": "🤕", "Headaches": "🤯", "Nausea": "🤢", "Bloating": "😖",
      "Breast Tenderness": "💢", "Breakouts": "😬", "Cravings": "🍫",
      "Stress": "😫", "Constipation": "🚫", "Diarrhea": "💩",
    };
    const moodIcon = {
      "Mood Swing": "🔄", "Irritable": "😠", "Sad": "😢", "Anxious": "😰",
      "Confident": "😎", "Happy": "😊", "Impatient": "😤", "Inspired": "✨",
    };

    // FIX 2: updated keys to match new " Discharge" labels in dailyLog.dart
    const dischargeIcon = {
      'Pink Discharge'               : 'assets/images/discharge_icon/pink.png',
      'Clear/Transparent Discharge'  : 'assets/images/discharge_icon/clear.png',
      'Milky White Discharge'        : 'assets/images/discharge_icon/milky_white.png',
      'Gray Discharge'               : 'assets/images/discharge_icon/gray.png',
      'Bright Yellow Discharge'      : 'assets/images/discharge_icon/bright_yellow.png',
      'Green Discharge'              : 'assets/images/discharge_icon/green.png',
      'Red Discharge'                : 'assets/images/discharge_icon/red.png',
      'Brown Discharge'              : 'assets/images/discharge_icon/brown.png',
      'Watery Discharge'             : 'assets/images/discharge_icon/watery.png',
    };

    final parts = <String>[];

    if (symptoms.isNotEmpty) {
      final icons = symptoms.map((s) => '${symptomIcon[s] ?? ''} $s').join('  ·  ');
      parts.add('Symptoms\n$icons');
    }
    if (moods.isNotEmpty) {
      final icons = moods.map((m) => '${moodIcon[m] ?? ''} $m').join('  ·  ');
      parts.add('Mood\n$icons');
    }
    if (discharge.isNotEmpty) {
      // FIX 2: encode as "assetPath|label" — the widget will render Image.asset
      final icons = discharge.map((label) {
        final path = dischargeIcon[label] ?? '';
        return path.isNotEmpty ? '$path|$label' : label;
      }).join('  ·  ');
      parts.add('Discharge\n$icons');
    }

    setState(() => _logText = parts.join('\n\n'));
  }

  void getLogStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userCycleInfo = await FirebaseFirestore.instance
          .collection('cycle').doc(user.uid).get();
      setState(() {
        start = userCycleInfo['status'];
      });
    }
  }

  void getNotes(DateTime selectedDate) async {
    final user = FirebaseAuth.instance.currentUser;
    final date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (user != null) {
      final log = await FirebaseFirestore.instance
          .collection('cycle').doc(user.uid).collection('logs')
          .doc(date.toString()).get();
      if (mounted) {
        setState(() {
          _noteText = log.exists ? (log['notes'] ?? '') : '';
        });
      }
    }
  }

  void saveNotes(DateTime selectedDate) async {
    final user = FirebaseAuth.instance.currentUser;
    final date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('cycle').doc(user.uid).collection('logs')
          .doc(date.toString())
          .set({'notes': _noteText.trim()}, SetOptions(merge: true));
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
                  child: dailyLog(
                    selectedDate: date,
                    onSaved: (summary) {
                      if (mounted) setState(() => _logText = summary);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPossibleReasons() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final doc = await FirebaseFirestore.instance
        .collection('cycle')
        .doc(user.uid)
        .collection('logs')
        .doc(date.toString())
        .get();

    final symptoms  = (doc['physical symptoms'] as List?)?.cast<String>() ?? [];
    final moods     = (doc['mood'] as List?)?.cast<String>() ?? [];
    final discharge = (doc['discharge'] as List?)?.cast<String>() ?? [];

    if (!mounted) return;

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
                child: PossibleReasonsScreen(
                  loggedSymptoms:  symptoms,
                  loggedMoods:     moods,
                  loggedDischarge: discharge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openRemedySuggestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final doc = await FirebaseFirestore.instance
        .collection('cycle')
        .doc(user.uid)
        .collection('logs')
        .doc(date.toString())
        .get();

    final symptoms  = (doc['physical symptoms'] as List?)?.cast<String>() ?? [];
    final moods     = (doc['mood'] as List?)?.cast<String>() ?? [];
    final discharge = (doc['discharge'] as List?)?.cast<String>() ?? [];

    if (!mounted) return;

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
                child: RemedySuggestionsScreen(
                  loggedSymptoms:  symptoms,
                  loggedMoods:     moods,
                  loggedDischarge: discharge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future addCycleHistory(DateTime selectedDate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userData = await FirebaseFirestore.instance
        .collection('cycle').doc(user.uid).get();
    bool first = userData['emptyRecord'];

    await FirebaseFirestore.instance.collection('cycle').doc(user.uid).update({
      'status': false,
      'emptyRecord': false
    });

    int cycleLength = userData['cycle length'];

    final userSetting = await FirebaseFirestore.instance
        .collection('settings').doc(user.uid).get();
    bool smartPrediction = userSetting['smart prediction'];

    if (smartPrediction && !first) {
      final history = FirebaseFirestore.instance
          .collection('cycle').doc(user.uid).collection('cycle history');
      final latest =
      await history.orderBy('start date', descending: true).limit(1).get();
      String latestId = latest.docs.first.id;

      final userCycleHistory = await FirebaseFirestore.instance
          .collection('cycle').doc(user.uid)
          .collection('cycle history').doc(latestId).get();
      final periodStart = (userCycleHistory['start date'] as Timestamp).toDate();
      Duration previousCycleLength = selectedDate.difference(periodStart);

      await FirebaseFirestore.instance
          .collection('cycle').doc(user.uid)
          .collection('cycle history').doc(latestId)
          .update({'cycle length': previousCycleLength.inDays});

      final allData = await history.get();
      List<int> cycleLengths =
      allData.docs.map((doc) => (doc.get('cycle length') as int)).toList();
      int sum = 0;
      for (int len in cycleLengths) sum += len;
      int average = (sum / cycleLengths.length).ceil();
      cycleLength = average;

      await FirebaseFirestore.instance.collection('cycle').doc(user.uid)
          .update({'cycle length': average});

      DateTime fertileStart =
      periodStart.add(Duration(days: previousCycleLength.inDays - 20));
      DateTime fertileEnd = fertileStart.add(const Duration(days: 6));
      DateTime ovulation = fertileEnd.subtract(const Duration(days: 1));

      await FirebaseFirestore.instance
          .collection('cycle').doc(user.uid)
          .collection('cycle history').doc(latestId).update({
        'fertile start': fertileStart,
        'fertile end': fertileEnd,
        'ovulation': ovulation
      });
    }

    int periodLength = userData['period length'];
    DateTime startDate   = selectedDate;
    DateTime endDate     = startDate.add(Duration(days: cycleLength - 1));
    DateTime periodEnd   = startDate.add(Duration(days: periodLength - 1));
    DateTime fertileStart = startDate.add(Duration(days: cycleLength - 20));
    DateTime fertileEnd  = fertileStart.add(const Duration(days: 6));
    DateTime ovulation   = fertileEnd.subtract(const Duration(days: 1));

    await FirebaseFirestore.instance
        .collection('cycle').doc(user.uid)
        .collection('cycle history').doc(selectedDate.toString()).set({
      'start date': startDate,
      'period end': periodEnd,
      'end date': endDate,
      'fertile start': fertileStart,
      'fertile end': fertileEnd,
      'ovulation': ovulation
    });

    if (mounted) setState(() => start = false);
  }

  Future updateCycleHistory(DateTime selectedDate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('cycle').doc(user.uid)
        .update({'status': true});

    final userSetting = await FirebaseFirestore.instance
        .collection('settings').doc(user.uid).get();
    bool smartPrediction = userSetting['smart prediction'];

    final history = FirebaseFirestore.instance
        .collection('cycle').doc(user.uid).collection('cycle history');
    final latest =
    await history.orderBy('start date', descending: true).limit(1).get();
    String latestId = latest.docs.first.id;
    final cycleHistoryData = await FirebaseFirestore.instance
        .collection('cycle').doc(user.uid)
        .collection('cycle history').doc(latestId).get();

    if (smartPrediction) {
      final periodStart =
      (cycleHistoryData['start date'] as Timestamp).toDate();
      final periodEnd = selectedDate;
      final currentPeriodLength =
          (periodEnd.difference(periodStart)) + const Duration(days: 1);

      await FirebaseFirestore.instance
          .collection('cycle').doc(user.uid)
          .collection('cycle history').doc(latestId)
          .update({'period length': currentPeriodLength.inDays});

      final allData = await history.get();
      List<int> cycleLengths =
      allData.docs.map((doc) => (doc.get('period length') as int)).toList();
      int sum = 0;
      for (int len in cycleLengths) sum += len;
      int average = (sum / cycleLengths.length).ceil();

      await FirebaseFirestore.instance.collection('cycle').doc(user.uid)
          .update({'period length': average});
    }

    await history.doc(latestId).update({'period end': selectedDate});
    if (mounted) setState(() => start = true);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth  = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final firstWeekday = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;
    final totalCells   = firstWeekday + daysInMonth;
    final trailingCells = (7 - (totalCells % 7)) % 7;

    final prevMonth  = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final daysInPrev = DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F5),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _isvalidDay ? const Color(0xFFAA556B) : Colors.grey.shade400,
        onPressed: _isvalidDay ? () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                backgroundColor: const Color(0xFFFFFBFC),
                title: Text(
                  start ? "Period starts" : "Period Ends",
                  style: const TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A1F3D),
                  ),
                ),
                content: Text(
                  start
                      ? "Are you sure your period starts on ${_formatDate(_selectedDate)}?"
                      : "Are you sure your period ends on ${_formatDate(_selectedDate)}?",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _selectedDate = _today;
                    },
                    child: const Text("Select a date",
                        style: TextStyle(color: Colors.black45, fontSize: 14)),
                  ),
                  TextButton(
                    onPressed: () {
                      if (start) {
                        addCycleHistory(_selectedDate);
                      } else {
                        updateCycleHistory(_selectedDate);
                      }
                      _refreshData();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save",
                        style: TextStyle(
                          color: Color(0xFFB56A7E),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
                  ),
                ],
              );
            },
          );
        } : null,
        icon: Icon(Icons.add, color: _isvalidDay ? Colors.white : Colors.black54),
        label: Text(
          start ? "Start Period" : "End Period",
          style: TextStyle(
              fontFamily: "DMSans",
              color: _isvalidDay ? Colors.white : Colors.black54),
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

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Divider(color: Color(0xFFEEDDE1), thickness: 1.5),
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

                                  if (_logText.isNotEmpty) ...[
                                    _buildLogSummaryWidget(_logText),
                                    const SizedBox(height: 14),
                                  ],

                                  GestureDetector(
                                    onTap: () => _showEditDialog(
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
                                              color: const Color(0xFF301C29),
                                              width: 0.5),
                                        ),
                                        child: Text(
                                          _noteText.isNotEmpty
                                              ? _noteText
                                              : "Tap to add note...",
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

                                  const SizedBox(height: 14),

                                  if (_logText.isNotEmpty)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _mauveButton("View Reason", _openPossibleReasons),
                                        const SizedBox(width: 12),
                                        _mauveButton("View Remedy", _openRemedySuggestions),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            Positioned(
                              top: 2,
                              right: 15,
                              child: GestureDetector(
                                onTap: _isvalidDay ? () => _openDailyLog(_selectedDate) : null,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add,
                                        size: 13,
                                        color: _isvalidDay
                                            ? const Color(0xFFB56A7E)
                                            : Colors.black),
                                    const SizedBox(width: 3),
                                    Text(
                                      _logText.isEmpty ? "Add Log" : "Edit Log",
                                      style: TextStyle(
                                        fontFamily: "CormorantGaramond",
                                        color: _isvalidDay
                                            ? const Color(0xFFB56A7E)
                                            : Colors.black54,
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

  // ── Log Summary Widget ────────────────────────────────────────
  // FIX 2: discharge items are encoded as "assetPath|label".
  // This parser splits them and renders Image.asset for the icon.
  Widget _buildLogSummaryWidget(String summary) {
    final sections = summary.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        final lines = section.split('\n');
        if (lines.isEmpty) return const SizedBox.shrink();

        final categoryLabel = lines.first;
        final rawItems = lines.length > 1
            ? lines[1].split('  ·  ').map((s) => s.trim()).toList()
            : <String>[];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryLabel.toUpperCase(),
                style: const TextStyle(
                  fontFamily: "DMSans",
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: rawItems.map((item) {
                  // Detect discharge items encoded as "assetPath|label"
                  final isImageItem = item.contains('|');
                  final displayLabel = isImageItem ? item.split('|').last : item;
                  final assetPath   = isImageItem ? item.split('|').first : null;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB56A7E).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFB56A7E).withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (assetPath != null) ...[
                          Image.asset(
                            assetPath,
                            width: 16,
                            height: 16,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          displayLabel,
                          style: const TextStyle(
                            fontFamily: "DMSans",
                            fontSize: 11.5,
                            color: Color(0xFF7A3B50),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showEditDialog(String title, String current, ValueChanged<String> onSave) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          // Allows dialog to reposition when keyboard appears
          insetPadding: const EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: 24,
            top: 24,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "DMSans",
                      fontSize: 16,
                      color: Color(0xFF3A1F3D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    autofocus: true,
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontFamily: "DMSans", color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB56A7E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          onSave(controller.text);
                          saveNotes(_selectedDate);
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(fontFamily: "DMSans", color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<(List<DateTime>, List<DateTime>, List<DateTime>, List<DateTime>, List<DateTime>)>
  getCycleData() async {
    final user = FirebaseAuth.instance.currentUser;
    final history = FirebaseFirestore.instance
        .collection('cycle').doc(user!.uid).collection('cycle history');
    final allData = await history.get();

    List<DateTime> startDate = allData.docs
        .map((doc) => (doc.get('start date') as Timestamp).toDate()).toList();
    List<DateTime> endDate = allData.docs
        .map((doc) => (doc.get('period end') as Timestamp).toDate()).toList();
    List<DateTime> startFertile = allData.docs
        .map((doc) => (doc.get('fertile start') as Timestamp).toDate()).toList();
    List<DateTime> endFertile = allData.docs
        .map((doc) => (doc.get('fertile end') as Timestamp).toDate()).toList();
    List<DateTime> ovulation = allData.docs
        .map((doc) => (doc.get('ovulation') as Timestamp).toDate()).toList();

    return (startDate, endDate, startFertile, endFertile, ovulation);
  }

  void _refreshData() async {
    final data = await getCycleData();
    setState(() {
      startDate    = data.$1;
      endDate      = data.$2;
      startFertile = data.$3;
      endFertile   = data.$4;
      ovulation    = data.$5;
    });
  }

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

        Color bgColor = Colors.transparent;
        Color textColor = isToday ? const Color(0xFF884456) : Colors.black87;
        bool isPeriod = false;
        bool isFertile = false;
        bool isOvulation = false;

        if (snapshot.hasData) {
          final (startDate, endDate, startFertile, endFertile, ovulation) = snapshot.data!;
          for (int i = 0; i < startDate.length; i++) {
            final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
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

        if (isOvulation) {
          bgColor = const Color(0xFFaedbc8);
        } else if (isPeriod) {
          bgColor = const Color(0xFFe2acb5);
        } else if (isFertile) {
          bgColor = const Color(0xFFddcb9c);
        }

        return GestureDetector(
          onTap: () {
            getNotes(thisDay);
            getLogText(thisDay);
            setState(() {
              _selectedDate = thisDay;
              _isvalidDay = !_selectedDate.isAfter(_today);
            });
          },
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
                border: isToday
                    ? Border.all(color: const Color(0xFF884456), width: 1.8)
                    : isSelected
                    ? Border.all(color: Colors.black54, width: 1.5)
                    : null,
              ),
              alignment: Alignment.center,
              child: isToday
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Today",
                      style: TextStyle(
                        fontFamily: "CormorantGaramond",
                        fontSize: 9,
                        color: Color(0xFF884456),
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 1),
                  Text("$day",
                      style: const TextStyle(
                        fontFamily: "DMSans",
                        fontSize: 13,
                        color: Color(0xFF884456),
                        fontWeight: FontWeight.w500,
                      )),
                ],
              )
                  : Text("$day",
                  style: TextStyle(
                    fontFamily: "DMSans",
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGhostCell(int day) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        width: 34,
        height: 34,
        alignment: Alignment.center,
        child: Text("$day",
            style: const TextStyle(
              fontFamily: "DMSans",
              fontSize: 13,
              color: Color(0xFFCCCCCC),
              fontWeight: FontWeight.w400,
            )),
      ),
    );
  }

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
            child: Text(label,
                style: const TextStyle(
                  fontFamily: "DMSans",
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A1F3D),
                )),
          ),
        ),
      ],
    );
  }

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
            child: Text(label,
                style: const TextStyle(
                  fontFamily: "CormorantGaramond",
                  fontSize: 18,
                  color: Color(0xFF3A1F3D),
                  letterSpacing: 0.3,
                )),
          ),
        ),
      ],
    );
  }

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