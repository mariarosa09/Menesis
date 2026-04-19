import 'package:flutter/material.dart';

/// ============================================================
/// [NotificationsScreen] - StatefulWidget
/// This is the main screen for managing notification settings.
/// It allows the user to toggle different types of reminders
/// related to their menstrual cycle tracking app.
/// ============================================================
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  /// ============================================================
  /// [State Variables] - Toggle States for Notification Settings
  /// These boolean variables track which notifications are enabled
  /// or disabled. Each corresponds to a specific reminder type.
  /// ============================================================
  bool period = true;
  bool ovulation = false;
  bool daily = true;
  bool monthly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// ============================================================
          /// [Background] - Gradient Container
          /// Fills the entire screen with a soft pink-to-lavender gradient
          /// to match the app's feminine health tracking aesthetic.
          /// ============================================================
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF7F3F5),
                  Color(0xFFF1E6EA),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// ============================================================
          /// [SafeArea + Main Content] - Full Screen Layout
          /// Wraps all content in a SafeArea to avoid system UI overlap.
          /// Uses a Column to stack the header, tiles, button, and info box.
          /// ============================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 15),

                  /// ============================================================
                  /// [Header Row] - Back Button + Screen Title
                  /// Displays a back navigation icon and the "Notifications" title
                  /// side by side. The negative offset aligns them visually to the left.
                  /// ============================================================
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

                  /// ============================================================
                  /// [Subtitle Text] - Screen Description
                  /// A short description below the title that tells the user
                  /// what this settings screen is for.
                  /// ============================================================
                  const Text(
                    "Manage reminder alerts for your cycle events.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ============================================================
                  /// [Notification Tiles] - Toggle List Items
                  /// Each _tile() represents one notification type the user can
                  /// enable or disable via a Switch toggle. Dividers visually
                  /// separate each setting item.
                  /// ============================================================

                  // TODO: EDIT - I-connect ang bawat toggle state sa actual
                  // notification scheduling (e.g., flutter_local_notifications).
                  // Kapag na-toggle ang switch, mag-schedule o mag-cancel ng
                  // notification base sa bagong value.
                  // The code should be placed here

                  _tile(
                    "Period approaching",
                    "2 days before predicted start",
                    period,
                        (val) => setState(() => period = val),
                  ),

                  const Divider(),

                  _tile(
                    "Ovulation window",
                    "Remind during fertile days",
                    ovulation,
                        (val) => setState(() => ovulation = val),
                  ),

                  const Divider(),

                  _tile(
                    "Daily log reminder",
                    "Remind me to log each day",
                    daily,
                        (val) => setState(() => daily = val),
                  ),

                  const Divider(),

                  _tile(
                    "Monthly cycle summary",
                    "End-of-cycle overview",
                    monthly,
                        (val) => setState(() => monthly = val),
                  ),

                  const SizedBox(height: 30),

                  /// ============================================================
                  /// [Save Button] - Primary CTA
                  /// A styled ElevatedButton with a pink shadow effect.
                  /// Triggers saving of the current notification preferences
                  /// when tapped by the user.
                  /// ============================================================
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB56A7E)
                                .withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB56A7E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),

                        // TODO: EDIT - I-implement ang actual na save logic dito.
                        // I-save ang mga toggle values (period, ovulation, daily,
                        // monthly) sa SharedPreferences o sa database ng app
                        // para ma-persist kahit mag-restart ang app.
                        // The code should be placed here

                        onPressed: () {},
                        child: const Text("Save Settings"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ============================================================
                  /// [Info Box] - Permissions Notice
                  /// A semi-transparent white card that informs the user about
                  /// device notification permission requirements. This is a
                  /// passive info display — no interaction needed.
                  /// ============================================================
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: const Text(
                      "Notifications require permission from your device. You can manage app permissions in your phone's settings at any time.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // TODO: ADD - Mag-add ng permission check button o logic dito.
                  // Kapag hindi pa granted ang notification permission ng device,
                  // magpakita ng prompt o "Open Settings" button para gabayan
                  // ang user na i-enable ito manually sa kanilang phone settings.
                  // The code should be placed here

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================================
  /// [_tile] - Reusable Notification Toggle Row
  /// Builds a single row that shows a title, subtitle description,
  /// and a Switch toggle. Used for each notification setting item.
  /// [title]     - The name of the notification type
  /// [subtitle]  - A short description of when it fires
  /// [value]     - Current toggle state (true = ON, false = OFF)
  /// [onChanged] - Callback triggered when the user flips the switch
  /// ============================================================
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

          /// [Left Side] - Title and Subtitle text column
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

          /// [Right Side] - Switch toggle with active pink color
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