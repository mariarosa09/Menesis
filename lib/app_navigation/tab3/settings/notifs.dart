import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_settings/app_settings.dart';
import 'package:menesis_app/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService.instance;

  NotificationPrefs _prefs = const NotificationPrefs();

  bool get period => _prefs.periodApproaching;
  bool get ovulation => _prefs.fertileWindow;
  bool get daily => _prefs.dailyLog;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
    try {
      final prefs = await _service.loadPrefs(uid);
      if (mounted) setState(() => _prefs = prefs);
    } catch (e) {
      debugPrint('Failed to load notification settings: $e');
    }
  }

  /// Called on every toggle: saves the preference, then rebuilds the
  /// schedule from the user's actual cycle predictions.
  Future<void> _onToggle(NotificationPrefs updated, bool enabling) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (enabling) {
      final granted = await _service.requestPermission();
      if (!granted) {
        if (mounted) _showPermissionDialog();
        return; // keep the toggle off if permission is denied
      }
    }

    final previous = _prefs;
    setState(() => _prefs = updated);
    try {
      await _service.savePrefs(uid, updated);
      await _service.rescheduleAll(uid: uid, prefs: updated);
    } catch (e) {
      debugPrint('Failed to save notification settings: $e');
      if (!mounted) return;
      setState(() => _prefs = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't save. Please try again."),
          backgroundColor: Color(0xFFB56A7E),
        ),
      );
    }
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
                        (val) => _onToggle(_prefs.copyWith(periodApproaching: val), val),
                  ),
                  const Divider(),
                  _tile(
                    "Ovulation window",
                    "Remind during fertile days",
                    ovulation,
                        (val) => _onToggle(_prefs.copyWith(fertileWindow: val), val),
                  ),
                  const Divider(),
                  _tile(
                    "Daily log reminder",
                    "Remind me to log each day",
                    daily,
                        (val) => _onToggle(_prefs.copyWith(dailyLog: val), val),
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