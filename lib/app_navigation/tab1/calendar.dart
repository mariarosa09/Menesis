import 'dart:async';
import 'package:flutter/material.dart';
import '/services/cycle_repository.dart';
import '/app_navigation/tab1/dailyLog.dart';
import '/app_navigation/tab1/viewReason.dart';
import '/app_navigation/tab1/viewRemedy.dart';

// ═════════════════════════════════════════════════════════════
// CALENDAR SCREEN WIDGET
// ═════════════════════════════════════════════════════════════

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  // ── State Variables ─────────────────────────────────────────
  final DateTime _today = DateTime.now();
  late DateTime _selectedMonth;
  late DateTime _selectedDate;

  final _repo = CycleRepository.instance;

  /// true = "Start Period", false = "End Period" (live from `cycle info`).
  bool start = true;

  /// All cycle records, kept up to date by a single Firestore listener,
  /// so the grid refreshes automatically after starting/ending a period.
  List<CycleRecord> _cycles = const [];
  StreamSubscription<List<CycleRecord>>? _cyclesSub;
  StreamSubscription<CycleInfo?>? _infoSub;

  /// Symptom log of the selected date (fetched once per selection and
  /// reused by "View Reason" / "View Remedy").
  Map<String, dynamic>? _selectedLog;

  String _logText  = '';
  String _noteText = '';
  bool   _isValidDay = true;

  bool _loading = true;

  static const List<String> _months = [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December",
  ];

  static const _symptomIcon = {
    "Cramps": "🤕", "Headaches": "🤯", "Nausea": "🤢", "Bloating": "😖",
    "Breast Tenderness": "💢", "Breakouts": "😬", "Cravings": "🍫",
    "Stress": "😫", "Constipation": "🚫", "Diarrhea": "💩",
  };
  static const _moodIcon = {
    "Mood Swing": "🔄", "Irritable": "😠", "Sad": "😢", "Anxious": "😰",
    "Confident": "😎", "Happy": "😊", "Impatient": "😤", "Inspired": "✨",
  };

  // ──────────────────────────────────────────────────────────
  // LIFECYCLE
  // ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(_today.year, _today.month);
    _selectedDate  = _today;

    _infoSub = _repo.cycleInfoStream().listen((info) {
      if (info != null && mounted) setState(() => start = info.status);
    }, onError: (e) => debugPrint('Cycle info listener error: $e'));

    _cyclesSub = _repo.allCyclesStream().listen((cycles) {
      if (mounted) {
        setState(() {
          _cycles  = cycles;
          _loading = false;
        });
      }
    }, onError: (e) {
      debugPrint('Cycle history listener error: $e');
      if (mounted) setState(() => _loading = false);
    });

    _loadLogForDate(_selectedDate);
  }

  @override
  void dispose() {
    _infoSub?.cancel();
    _cyclesSub?.cancel();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────
  // DATA
  // ──────────────────────────────────────────────────────────

  static List<String> _list(Map<String, dynamic>? log, String key) =>
      (log?[key] as List?)?.cast<String>() ?? const [];

  /// One read per selected date: fills the note, the log summary and the
  /// cached log used by the Reason/Remedy sheets.
  Future<void> _loadLogForDate(DateTime date) async {
    Map<String, dynamic>? log;
    try {
      log = await _repo.getSymptomLog(date);
    } catch (e) {
      debugPrint('Failed to load log: $e');
    }
    // Ignore stale responses if the user already tapped another day.
    if (!mounted || !DateUtils.isSameDay(date, _selectedDate)) return;
    setState(() {
      _selectedLog = log;
      _noteText    = (log?['notes'] as String?) ?? '';
      _logText     = _buildLogText(log);
    });
  }

  String _buildLogText(Map<String, dynamic>? log) {
    final symptoms  = _list(log, 'physical symptoms');
    final moods     = _list(log, 'mood');
    final discharge = _list(log, 'discharge');

    final parts = <String>[];
    if (symptoms.isNotEmpty) {
      parts.add(
        'Symptoms\n${symptoms.map((s) => '${_symptomIcon[s] ?? ''} $s').join('  ·  ')}',
      );
    }
    if (moods.isNotEmpty) {
      parts.add(
        'Mood\n${moods.map((m) => '${_moodIcon[m] ?? ''} $m').join('  ·  ')}',
      );
    }
    if (discharge.isNotEmpty) {
      parts.add('Discharge\n${discharge.join('  ·  ')}');
    }
    return parts.join('\n\n');
  }

  Future<void> saveNotes(DateTime selectedDate) async {
    try {
      await _repo.saveNote(selectedDate, _noteText);
      _selectedLog = {...?_selectedLog, 'notes': _noteText.trim()};
    } catch (e) {
      debugPrint('Failed to save note: $e');
    }
  }

  Future<void> addCycleHistory(DateTime selectedDate) =>
      _repo.startPeriod(selectedDate);

  Future<void> updateCycleHistory(DateTime selectedDate) =>
      _repo.endPeriod(selectedDate);

  // ──────────────────────────────────────────────────────────
  // ──────────────────────────────────────────────────────────
  // BOTTOM SHEETS
  // ──────────────────────────────────────────────────────────

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
                width: 40, height: 4,
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
                    onSaved: (_) => _loadLogForDate(date),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPossibleReasons() {
    final symptoms  = _list(_selectedLog, 'physical symptoms');
    final moods     = _list(_selectedLog, 'mood');
    final discharge = _list(_selectedLog, 'discharge');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F3F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFD4AABB),
                  borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(child: PossibleReasonsScreen(
                loggedSymptoms: symptoms,
                loggedMoods: moods,
                loggedDischarge: discharge)),
          ]),
        ),
      ),
    );
  }

  void _openRemedySuggestions() {
    final symptoms  = _list(_selectedLog, 'physical symptoms');
    final moods     = _list(_selectedLog, 'mood');
    final discharge = _list(_selectedLog, 'discharge');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F3F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFD4AABB),
                  borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(child: RemedySuggestionsScreen(
                loggedSymptoms: symptoms,
                loggedMoods: moods,
                loggedDischarge: discharge)),
          ]),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // UTILITY HELPERS
  // ──────────────────────────────────────────────────────────

  String _monthName(int m) => _months[m - 1];

  String _formatDate(DateTime d) =>
      "${_months[d.month - 1]} ${d.day}, ${d.year}";

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
    Color confirmColor = const Color(0xFFB56A7E),
    IconData icon = Icons.water_drop_outlined,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: confirmColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: confirmColor, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: "CormorantGaramond",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF44222B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "DMSans",
                  fontSize: 13,
                  color: Color(0xFF7A5566),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: confirmColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("Cancel",
                          style: TextStyle(
                              fontFamily: "DMSans",
                              color: confirmColor,
                              fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(confirmLabel,
                          style: const TextStyle(
                            fontFamily: "DMSans",
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // FAB ACTION
  // ──────────────────────────────────────────────────────────

  Future<void> _onPeriodButtonPressed() async {
    final confirm = await _showConfirmDialog(
      title:        start ? "Period starts" : "Period Ends",
      content:      start
          ? "Are you sure your period starts on ${_formatDate(_selectedDate)}?"
          : "Are you sure your period ends on ${_formatDate(_selectedDate)}?",
      confirmLabel: "Save",
      confirmColor: const Color(0xFFB56A7E),
      icon:         Icons.water_drop_outlined,
    );

    if (confirm == true) {
      try {
        if (start) {
          await addCycleHistory(_selectedDate);
          if (mounted) setState(() => start = false);
        } else {
          await updateCycleHistory(_selectedDate);
          if (mounted) setState(() => start = true);
        }
        // No manual refresh needed: the periodLogs listener updates the grid.
      } catch (e) {
        debugPrint('Failed to save cycle: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Couldn't save. Please check your connection."),
              backgroundColor: Color(0xFFB56A7E),
            ),
          );
        }
      }
    }
  }

  // ──────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final daysInMonth  = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final firstWeekday = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;
    final totalCells   = firstWeekday + daysInMonth;
    final trailing     = (7 - (totalCells % 7)) % 7;

    final prevMonth  = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final daysInPrev = DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

    final List<Widget> dayCells = [];
    for (int i = 0; i < firstWeekday; i++) {
      dayCells.add(_buildGhostCell(daysInPrev - firstWeekday + 1 + i));
    }
    for (int day = 1; day <= daysInMonth; day++) {
      dayCells.add(_buildDayCell(day));
    }
    for (int i = 1; i <= trailing; i++) {
      dayCells.add(_buildGhostCell(i));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F5),

      floatingActionButton: _isValidDay
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFFAA556B),
        onPressed: _onPeriodButtonPressed,
        icon: const Icon(Icons.water_drop_outlined, color: Colors.white),
        label: Text(
          start ? "Start Period" : "End Period",
          style: const TextStyle(fontFamily: "DMSans", color: Colors.white),
        ),
      )
          : FloatingActionButton.extended(
        backgroundColor: Colors.grey.shade400,
        onPressed: null,
        icon: const Icon(Icons.water_drop_outlined, color: Colors.black54),
        label: Text(
          start ? "Start Period" : "End Period",
          style: const TextStyle(fontFamily: "DMSans", color: Colors.black54),
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

                    // ── Month navigation ──────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            splashColor:    const Color(0xFFB56A7E).withOpacity(0.2),
                            highlightColor: const Color(0xFFB56A7E).withOpacity(0.3),
                            onPressed: () => setState(() => _selectedMonth =
                                DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
                            icon: const Icon(Icons.chevron_left, color: Color(0xFF3A1F3D)),
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
                          IconButton(
                            splashColor:    const Color(0xFFB56A7E).withOpacity(0.2),
                            highlightColor: const Color(0xFFB56A7E).withOpacity(0.3),
                            onPressed: () => setState(() => _selectedMonth =
                                DateTime(_selectedMonth.year, _selectedMonth.month + 1)),
                            icon: const Icon(Icons.chevron_right, color: Color(0xFF3A1F3D)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Day-of-week headers ───────────────────
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

                    // ── Calendar grid ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _loading
                          ? const SizedBox(
                        height: 220,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFB56A7E),
                            strokeWidth: 2,
                          ),
                        ),
                      )
                          : GridView.count(
                        crossAxisCount: 7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 0.85,
                        children: dayCells,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Legend ────────────────────────────────
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

                    // ── Selected-date label ───────────────────
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

                    // ── Your Log section ──────────────────────
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
                                              color: const Color(0xFF301C29), width: 0.5),
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
                              top: 2, right: 15,
                              child: GestureDetector(
                                onTap: _isValidDay
                                    ? () => _openDailyLog(_selectedDate)
                                    : null,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 13,
                                        color: _isValidDay
                                            ? const Color(0xFFB56A7E)
                                            : Colors.black),
                                    const SizedBox(width: 3),
                                    Text(
                                      _logText.isEmpty ? "Add Log" : "Edit Log",
                                      style: TextStyle(
                                        fontFamily: "CormorantGaramond",
                                        color: _isValidDay
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

  // ──────────────────────────────────────────────────────────
  // CALENDAR DAY CELL
  // ──────────────────────────────────────────────────────────

  Widget _buildDayCell(int day) {
    final thisDay    = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    final isSelected = DateUtils.isSameDay(thisDay, _selectedDate);
    final isToday    = DateUtils.isSameDay(thisDay, _today);

    bool isPeriod    = false;
    bool isFertile   = false;
    bool isOvulation = false;

    bool within(DateTime from, DateTime to) =>
        (thisDay.isAfter(from) || DateUtils.isSameDay(thisDay, from)) &&
        (thisDay.isBefore(to)  || DateUtils.isSameDay(thisDay, to));

    for (final c in _cycles) {
      if (within(c.cycleStart, c.periodEnd))     isPeriod = true;
      if (within(c.fertileStart, c.fertileEnd))  isFertile = true;
      if (DateUtils.isSameDay(thisDay, c.ovulation)) isOvulation = true;
    }

    Color bgColor;
    if (isToday) {
      bgColor = Colors.transparent;
    } else if (isOvulation) {
      bgColor = const Color(0xFFaedbc8);
    } else if (isPeriod) {
      bgColor = const Color(0xFFe2acb5);
    } else if (isFertile) {
      bgColor = const Color(0xFFddcb9c);
    } else {
      bgColor = Colors.transparent;
    }

    final textColor = isToday ? const Color(0xFF884456) : Colors.black87;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = thisDay;
          _isValidDay   = !thisDay.isAfter(_today);
        });
        _loadLogForDate(thisDay);
      },
      onDoubleTap: () {
        setState(() => _selectedDate = thisDay);
        _loadLogForDate(thisDay);
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
  }

  // ──────────────────────────────────────────────────────────
  // HELPER WIDGETS
  // ──────────────────────────────────────────────────────────

  Widget _buildGhostCell(int day) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        width: 34, height: 34,
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
                  fontFamily: "DMSans", fontSize: 10,
                  fontWeight: FontWeight.w600, color: Colors.black45,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: rawItems.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB56A7E).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFB56A7E).withOpacity(0.35)),
                    ),
                    child: Text(item,
                        style: const TextStyle(
                          fontFamily: "DMSans",
                          fontSize: 11.5,
                          color: Color(0xFF7A3B50),
                        )),
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
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.only(
          left: 24, right: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                fontFamily: "DMSans", fontSize: 16,
                color: Color(0xFF3A1F3D), fontWeight: FontWeight.bold,
              )),
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
                      borderSide: BorderSide.none),
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
                    child: const Text("Cancel",
                        style: TextStyle(fontFamily: "DMSans", color: Colors.black54)),
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
                    child: const Text("Save",
                        style: TextStyle(fontFamily: "DMSans", color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          top: 0, left: 8,
          child: Container(
            color: const Color(0xFFF7F3F5),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label,
                style: const TextStyle(
                  fontFamily: "DMSans", fontSize: 25,
                  fontWeight: FontWeight.bold, color: Color(0xFF3A1F3D),
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
          top: 0, left: 8,
          child: Container(
            color: const Color(0xFFF7F3F5),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label,
                style: const TextStyle(
                  fontFamily: "CormorantGaramond", fontSize: 18,
                  color: Color(0xFF3A1F3D), letterSpacing: 0.3,
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
              fontFamily: "CormorantGaramond", color: Colors.white,
              fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.8,
            )),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
              fontFamily: "CormorantGaramond", fontSize: 12, color: Colors.black54,
            )),
      ],
    );
  }
}