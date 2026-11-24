import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' show DateUtils;

/// One predicted / logged cycle, parsed from a `periodLogs` document.
class CycleRecord {
  final String id;
  final DateTime cycleStart;
  final DateTime periodEnd;
  final DateTime cycleEnd;
  final DateTime fertileStart;
  final DateTime fertileEnd;
  final DateTime ovulation;
  final int? cycleLength;
  final int? periodLength;

  const CycleRecord({
    required this.id,
    required this.cycleStart,
    required this.periodEnd,
    required this.cycleEnd,
    required this.fertileStart,
    required this.fertileEnd,
    required this.ovulation,
    this.cycleLength,
    this.periodLength,
  });

  /// Returns null when a required date field is missing, so one malformed
  /// document can't crash a whole screen.
  static CycleRecord? fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) return null;
    DateTime? ts(String key) => (d[key] as Timestamp?)?.toDate();

    final start = ts('cycle start date');
    final periodEnd = ts('period end date');
    final fertileStart = ts('fertile start date');
    final fertileEnd = ts('fertile end date');
    final ovulation = ts('ovulation date');
    if (start == null ||
        periodEnd == null ||
        fertileStart == null ||
        fertileEnd == null ||
        ovulation == null) {
      return null;
    }
    final cycleLength = (d['cycle length'] as num?)?.toInt();
    return CycleRecord(
      id: doc.id,
      cycleStart: start,
      periodEnd: periodEnd,
      // Older records may lack 'cycle end date'; derive it when possible.
      cycleEnd: ts('cycle end date') ??
          start.add(Duration(days: (cycleLength ?? 28) - 1)),
      fertileStart: fertileStart,
      fertileEnd: fertileEnd,
      ovulation: ovulation,
      cycleLength: cycleLength,
      periodLength: (d['period length'] as num?)?.toInt(),
    );
  }
}

/// Snapshot of `users/{uid}/cycle/cycle info`.
class CycleInfo {
  final int cycleLength;
  final int periodLength;

  /// true  = no period in progress (button shows "Start Period")
  /// false = period in progress     (button shows "End Period")
  final bool status;
  final bool emptyRecord;
  final bool smartPrediction;

  const CycleInfo({
    required this.cycleLength,
    required this.periodLength,
    required this.status,
    required this.emptyRecord,
    required this.smartPrediction,
  });

  static CycleInfo? fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) return null;
    return CycleInfo(
      cycleLength: (d['cycle length'] as num?)?.toInt() ?? 28,
      periodLength: (d['period length'] as num?)?.toInt() ?? 5,
      status: d['status'] as bool? ?? true,
      emptyRecord: d['emptyRecord'] as bool? ?? true,
      smartPrediction: d['smart prediction'] as bool? ?? false,
    );
  }
}

/// Central place for all cycle-related Firestore reads and writes.
///
/// Every screen used to build its own `users/{uid}/cycle/cycle info/...`
/// references and re-read the same documents several times per action.
/// This class reads each document once per operation and commits all
/// writes of an operation in a single [WriteBatch].
class CycleRepository {
  CycleRepository._();
  static final CycleRepository instance = CycleRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── References ────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      _db.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> cycleInfoDoc(String uid) =>
      userDoc(uid).collection('cycle').doc('cycle info');

  CollectionReference<Map<String, dynamic>> periodLogs(String uid) =>
      cycleInfoDoc(uid).collection('periodLogs');

  DocumentReference<Map<String, dynamic>> symptomLogDoc(
          String uid, DateTime date) =>
      cycleInfoDoc(uid)
          .collection('symptomsLogs')
          .doc(DateUtils.dateOnly(date).toString());

  DocumentReference<Map<String, dynamic>> notificationSettingsDoc(
          String uid) =>
      userDoc(uid).collection('settings').doc('notifications');

  // ── Streams ───────────────────────────────────────────────

  Stream<CycleInfo?> cycleInfoStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return cycleInfoDoc(uid).snapshots().map(CycleInfo.fromDoc);
  }

  /// Emits the most recent cycle (or null if there is none).
  Stream<CycleRecord?> latestCycleStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return periodLogs(uid)
        .orderBy('cycle start date', descending: true)
        .limit(1)
        .snapshots()
        .map((q) => q.docs.isEmpty ? null : CycleRecord.fromDoc(q.docs.first));
  }

  /// Emits every cycle record; used by the calendar to colour days.
  Stream<List<CycleRecord>> allCyclesStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return periodLogs(uid).snapshots().map((q) => q.docs
        .map(CycleRecord.fromDoc)
        .whereType<CycleRecord>()
        .toList());
  }

  // ── One-off reads ─────────────────────────────────────────

  Future<CycleInfo?> getCycleInfo() async {
    final uid = _uid;
    if (uid == null) return null;
    return CycleInfo.fromDoc(await cycleInfoDoc(uid).get());
  }

  Future<CycleRecord?> getLatestCycle() async {
    final uid = _uid;
    if (uid == null) return null;
    final q = await periodLogs(uid)
        .orderBy('cycle start date', descending: true)
        .limit(1)
        .get();
    return q.docs.isEmpty ? null : CycleRecord.fromDoc(q.docs.first);
  }

  /// Returns the symptom-log map for [date], or null if nothing was logged.
  Future<Map<String, dynamic>?> getSymptomLog(DateTime date) async {
    final uid = _uid;
    if (uid == null) return null;
    final snap = await symptomLogDoc(uid, date).get();
    return snap.data();
  }

  // ── Writes ────────────────────────────────────────────────

  Future<void> saveSymptomLog(DateTime date, Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) return;
    await symptomLogDoc(uid, date).set(data, SetOptions(merge: true));
  }

  Future<void> saveNote(DateTime date, String note) =>
      saveSymptomLog(date, {'notes': note.trim()});

  /// Starts a new cycle on [startDate].
  ///
  /// Reads: `cycle info` once + `periodLogs` once.
  /// Writes: one batch (previous cycle update, averages, new cycle).
  Future<void> startPeriod(DateTime startDate) async {
    final uid = _uid;
    if (uid == null) return;
    final start = DateUtils.dateOnly(startDate);

    final infoSnap = await cycleInfoDoc(uid).get();
    final info = CycleInfo.fromDoc(infoSnap);
    if (info == null) return;

    final batch = _db.batch();
    batch.update(cycleInfoDoc(uid), {'status': false, 'emptyRecord': false});

    int cycleLength = info.cycleLength;

    if (info.smartPrediction && !info.emptyRecord) {
      final history = await periodLogs(uid)
          .orderBy('cycle start date', descending: true)
          .get();
      final records = history.docs
          .map(CycleRecord.fromDoc)
          .whereType<CycleRecord>()
          .toList();

      final previousLength = records.isEmpty
          ? 0
          : start.difference(DateUtils.dateOnly(records.first.cycleStart)).inDays;

      // Only recompute when the new start is after the previous cycle's start.
      if (previousLength > 0) {
        final previous = records.first;

        // Average over all cycles, using the freshly computed length for
        // the previous one (no need to re-read the collection after writing).
        final lengths = [
          previousLength,
          for (final r in records.skip(1)) r.cycleLength ?? info.cycleLength,
        ];
        cycleLength =
            (lengths.reduce((a, b) => a + b) / lengths.length).ceil();

        final prevFertileStart = previous.cycleStart
            .add(Duration(days: previousLength - 20));
        final prevFertileEnd = prevFertileStart.add(const Duration(days: 6));

        batch.update(periodLogs(uid).doc(previous.id), {
          'cycle length': previousLength,
          'fertile start date': prevFertileStart,
          'fertile end date': prevFertileEnd,
          'ovulation date': prevFertileEnd.subtract(const Duration(days: 1)),
        });
        batch.update(cycleInfoDoc(uid), {'cycle length': cycleLength});
      }
    }

    final fertileStart = start.add(Duration(days: cycleLength - 20));
    final fertileEnd = fertileStart.add(const Duration(days: 6));

    batch.set(periodLogs(uid).doc(start.toString()), {
      'cycle start date': start,
      'period end date': start.add(Duration(days: info.periodLength - 1)),
      'cycle end date': start.add(Duration(days: cycleLength - 1)),
      'fertile start date': fertileStart,
      'fertile end date': fertileEnd,
      'ovulation date': fertileEnd.subtract(const Duration(days: 1)),
      'cycle length': cycleLength,
      'period length': info.periodLength,
    });

    await batch.commit();
  }

  /// Ends the current period on [endDate].
  ///
  /// Reads: `cycle info` once + `periodLogs` once.
  /// Writes: one batch.
  Future<void> endPeriod(DateTime endDate) async {
    final uid = _uid;
    if (uid == null) return;
    final end = DateUtils.dateOnly(endDate);

    final info = await getCycleInfo();
    if (info == null) return;

    final history = await periodLogs(uid)
        .orderBy('cycle start date', descending: true)
        .get();
    final records = history.docs
        .map(CycleRecord.fromDoc)
        .whereType<CycleRecord>()
        .toList();

    final batch = _db.batch();
    batch.update(cycleInfoDoc(uid), {'status': true});

    if (records.isNotEmpty) {
      final latest = records.first;
      final update = <String, dynamic>{'period end date': end};

      if (info.smartPrediction) {
        final currentLength =
            end.difference(DateUtils.dateOnly(latest.cycleStart)).inDays + 1;
        update['period length'] = currentLength;

        final lengths = [
          currentLength,
          for (final r in records.skip(1)) r.periodLength ?? info.periodLength,
        ];
        final average =
            (lengths.reduce((a, b) => a + b) / lengths.length).ceil();
        batch.update(cycleInfoDoc(uid), {'period length': average});
      }
      batch.update(periodLogs(uid).doc(latest.id), update);
    }

    await batch.commit();
  }
}
