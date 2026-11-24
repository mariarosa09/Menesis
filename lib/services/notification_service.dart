import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'cycle_repository.dart';

/// User-facing notification toggles, stored at
/// `users/{uid}/settings/notifications`.
class NotificationPrefs {
  final bool periodApproaching;
  final bool fertileWindow;
  final bool dailyLog;

  const NotificationPrefs({
    this.periodApproaching = true,
    this.fertileWindow = false,
    this.dailyLog = true,
  });

  // Firestore keys (same ones written during registration).
  static const kPeriod = 'period approaching';
  static const kFertile = 'fertile window';
  static const kDaily = 'daily log';

  factory NotificationPrefs.fromMap(Map<String, dynamic>? d) {
    if (d == null) return const NotificationPrefs();
    // Older builds of the settings screen saved 'period'/'ovulation'/'daily';
    // fall back to those so existing users keep their choices.
    return NotificationPrefs(
      periodApproaching: d[kPeriod] as bool? ?? d['period'] as bool? ?? true,
      fertileWindow: d[kFertile] as bool? ?? d['ovulation'] as bool? ?? false,
      dailyLog: d[kDaily] as bool? ?? d['daily'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        kPeriod: periodApproaching,
        kFertile: fertileWindow,
        kDaily: dailyLog,
      };

  NotificationPrefs copyWith({
    bool? periodApproaching,
    bool? fertileWindow,
    bool? dailyLog,
  }) =>
      NotificationPrefs(
        periodApproaching: periodApproaching ?? this.periodApproaching,
        fertileWindow: fertileWindow ?? this.fertileWindow,
        dailyLog: dailyLog ?? this.dailyLog,
      );
}

/// Schedules local reminders based on the user's predicted cycle.
///
/// * Period approaching – 2 days before the predicted next period, 9:00 AM.
/// * Fertile window     – on the first fertile day and on ovulation day, 9:00 AM.
/// * Daily log          – every day at 8:00 PM.
///
/// [rescheduleAll] is idempotent: it cancels and re-creates every reminder,
/// so it can be called whenever cycle data or preferences change.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _idPeriod = 1;
  static const _idFertile = 2;
  static const _idDaily = 3;
  static const _idOvulation = 4;
  static const _allIds = [_idPeriod, _idFertile, _idDaily, _idOvulation];

  static const _cycleReminderHour = 9;
  static const _dailyReminderHour = 20;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'cycle_channel',
      'Cycle Notifications',
      channelDescription: 'Reminders for your menstrual cycle events',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initFuture;

  /// Safe to call multiple times; work happens only once.
  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Don't prompt on launch; we ask explicitly via requestPermission().
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  /// Asks the OS for permission (Android 13+ / iOS). Returns true if granted.
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
              alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }

  // ── Preferences ───────────────────────────────────────────

  Future<NotificationPrefs> loadPrefs(String uid) async {
    final snap =
        await CycleRepository.instance.notificationSettingsDoc(uid).get();
    return NotificationPrefs.fromMap(snap.data());
  }

  Future<void> savePrefs(String uid, NotificationPrefs prefs) =>
      CycleRepository.instance.notificationSettingsDoc(uid).set(
            prefs.toMap(),
            // merge keeps any other fields; legacy keys are harmless.
            SetOptions(merge: true),
          );

  // ── Scheduling ────────────────────────────────────────────

  Future<void> cancelAll() async {
    await init();
    await Future.wait([for (final id in _allIds) _plugin.cancel(id: id)]);
  }

  /// Recomputes every reminder. Pass [prefs] / [info] / [latest] when the
  /// caller already has them to avoid extra Firestore reads.
  Future<void> rescheduleAll({
    required String uid,
    NotificationPrefs? prefs,
    CycleInfo? info,
    CycleRecord? latest,
    bool latestKnown = false,
  }) async {
    try {
      await init();
      final repo = CycleRepository.instance;
      final results = await Future.wait<Object?>([
        prefs != null ? Future.value(prefs) : loadPrefs(uid),
        info != null ? Future.value(info) : repo.getCycleInfo(),
        latestKnown || latest != null
            ? Future.value(latest)
            : repo.getLatestCycle(),
      ]);
      final p = results[0] as NotificationPrefs;
      final i = results[1] as CycleInfo?;
      final l = results[2] as CycleRecord?;

      await cancelAll();

      if (p.dailyLog) {
        await _scheduleDaily(
          _idDaily,
          'Daily Log',
          "Don't forget to log how you feel today.",
          _dailyReminderHour,
        );
      }

      final hasCycle = i != null && !i.emptyRecord && l != null;
      if (!hasCycle) return;

      if (p.periodApproaching) {
        final nextPeriod =
            DateUtils.dateOnly(l.cycleEnd).add(const Duration(days: 1));
        await _scheduleOnce(
          _idPeriod,
          'Period Reminder',
          'Your period is expected in 2 days.',
          nextPeriod.subtract(const Duration(days: 2)),
        );
      }

      if (p.fertileWindow) {
        await _scheduleOnce(
          _idFertile,
          'Fertile Window',
          'Your fertile window starts today.',
          l.fertileStart,
        );
        await _scheduleOnce(
          _idOvulation,
          'Ovulation Day',
          'Today is your predicted ovulation day.',
          l.ovulation,
        );
      }
    } catch (e, st) {
      // Reminders are best-effort; never crash a screen because of them.
      debugPrint('NotificationService.rescheduleAll failed: $e\n$st');
    }
  }

  /// Schedules a one-off reminder on [day] at the cycle reminder hour.
  /// Skipped if that moment is already in the past.
  Future<void> _scheduleOnce(
      int id, String title, String body, DateTime day) async {
    final d = DateUtils.dateOnly(day);
    final when = DateTime(d.year, d.month, d.day, _cycleReminderHour);
    if (!when.isAfter(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      // Converting the local instant to UTC keeps the exact moment without
      // needing to know the device's IANA time-zone name.
      scheduledDate: tz.TZDateTime.from(when, tz.UTC),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Schedules a reminder that repeats every day at [hour] local time.
  Future<void> _scheduleDaily(
      int id, String title, String body, int hour) async {
    final now = DateTime.now();
    var when = DateTime(now.year, now.month, now.day, hour);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.UTC),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Repeats at the same UTC time daily. The app reschedules on every
      // launch, so a daylight-saving shift is corrected on next open.
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
