import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_settings/app_settings.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FlutterLocalNotificationsPlugin _notifPlugin =
  FlutterLocalNotificationsPlugin();

  bool period = true;
  bool ovulation = false;
  bool daily = true;

  static const _notifDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'cycle_channel',
      'Cycle Notifications',
      channelDescription: 'Reminders for your menstrual cycle events',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  static const _configs = {
    1: (
    title: 'Period Reminder',
    body: 'Your period is expected soon.',
    delay: Duration(seconds: 5),
    ),
    2: (
    title: 'Ovulation Window',
    body: "You're in your fertile window.",
    delay: Duration(seconds: 10),
    ),
    3: (
    title: 'Daily Log',
    body: "Don't forget to log today.",
    delay: Duration(seconds: 15),
    ),
  };

  @override
  void initState() {
    super.initState();
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    tzdata.initializeTimeZones();
    await _initNotifications();
    final granted = await _checkAndRequestPermissions();
    if (!granted && mounted) {
      _showPermissionDialog();
    }
    await _loadSettings();
  }

  Future<void> _initNotifications() async {
    await _notifPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  /// Returns true if permission is granted, false otherwise.
  Future<bool> _checkAndRequestPermissions() async {
    final androidImpl = _notifPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS / other platforms: assume granted if no Android impl
    return true;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.notifications_off_outlined, color: Color(0xFFB56A7E)),
            SizedBox(width: 10),
            Text(
              'Enable Notifications',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A1F3D),
              ),
            ),
          ],
        ),
        content: const Text(
          'To receive cycle reminders, please turn on notification '
              'permission for this app in your device Settings.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Not Now',
              style: TextStyle(color: Colors.black45),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB56A7E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        period = data['period'] ?? true;
        ovulation = data['ovulation'] ?? false;
        daily = data['daily'] ?? true;
      });
    }

    await _syncNotifications();
  }

  /// Auto-saves whenever a toggle changes.
  Future<void> _autoSave() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('notifications')
          .set({
        'period': period,
        'ovulation': ovulation,
        'daily': daily,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Silently fail — user can retry by toggling again.
    }
  }

  Future<void> _syncNotifications() async {
    await _cancelAll();
    final enabled = {1: period, 2: ovulation, 3: daily};
    for (final entry in enabled.entries) {
      if (entry.value) await _scheduleNotification(entry.key);
    }
  }

  Future<void> _scheduleNotification(int id) async {
    final cfg = _configs[id]!;
    await _notifPlugin.zonedSchedule(
      id: id,
      title: cfg.title,
      body: cfg.body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(cfg.delay),
      notificationDetails: _notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _cancelNotification(int id) async {
    await _notifPlugin.cancel(id: id);
  }

  Future<void> _cancelAll() async {
    await Future.wait(
      [for (final id in _configs.keys) _notifPlugin.cancel(id: id)],
    );
  }

  /// Called on every toggle — updates state, schedules/cancels, then auto-saves.
  Future<void> _onToggle(int id, bool val, void Function(bool) setter) async {
    // Check permission before enabling
    if (val) {
      final granted = await _checkAndRequestPermissions();
      if (!granted && mounted) {
        _showPermissionDialog();
        return; // Don't enable the toggle if permission denied
      }
    }

    setState(() => setter(val));
    val ? await _scheduleNotification(id) : await _cancelNotification(id);
    await _autoSave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7F3F5), Color(0xFFF1E6EA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  // Header
                  Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(-15, 0),
                        child: SizedBox(
                          width: 45,
                          height: 45,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(12),
                              splashColor:
                              const Color(0xFFB56A7E).withOpacity(0.2),
                              highlightColor:
                              const Color(0xFFB56A7E).withOpacity(0.3),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF3A1F3D),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-15, 0),
                        child: const Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A1F3D),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Manage reminder alerts for your cycle events.",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // Toggle tiles
                  _tile(
                    "Period approaching",
                    "2 days before predicted start",
                    period,
                        (val) => _onToggle(1, val, (v) => period = v),
                  ),
                  const Divider(),
                  _tile(
                    "Ovulation window",
                    "Remind during fertile days",
                    ovulation,
                        (val) => _onToggle(2, val, (v) => ovulation = v),
                  ),
                  const Divider(),
                  _tile(
                    "Daily log reminder",
                    "Remind me to log each day",
                    daily,
                        (val) => _onToggle(3, val, (v) => daily = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
      String title,
      String subtitle,
      bool value,
      Function(bool) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFB56A7E),
          ),
        ],
      ),
    );
  }
}