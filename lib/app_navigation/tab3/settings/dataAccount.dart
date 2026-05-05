import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/app_navigation/tab3/settings/changePass.dart';
import '/app_navigation/tab3/settings/changeEmail.dart';
import '/registration/initialLength.dart';
import '/registration/main.dart';

/// ============================================================
/// DataAccountScreen
/// - Settings screen for "Data & Account".
/// - Options: Change Password, Change Email, Clear Data,
///   Delete Account (soft-delete — recoverable for 30 days).
/// ============================================================
class DataAccountScreen extends StatelessWidget {
  const DataAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- BACKGROUND GRADIENT ---
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
                  // --- HEADER ---
                  const SizedBox(height: 15),
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
                                child: Icon(Icons.arrow_back,
                                    color: Color(0xFF3A1F3D)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-15, 0),
                        child: const Text(
                          "Data & Account",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A1F3D),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Change Password
                  _accountOption(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChangePasswordScreen()),
                    ),
                  ),

                  const Divider(),

                  // Change Email
                  _accountOption(
                    icon: Icons.mail_outline,
                    title: "Change Email",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChangeEmailScreen()),
                    ),
                  ),

                  const SizedBox(height: 5),
                  const Divider(),

                  // Clear Data
                  _accountOption(
                    icon: Icons.cleaning_services_outlined,
                    title: "Clear Data",
                    subtitle: "This action cannot be undone.",
                    onTap: () => _showClearDataDialog(context),
                  ),

                  const Divider(),

                  // Delete Account (soft-delete)
                  _accountOption(
                    icon: Icons.delete_outline,
                    title: "Delete Account",
                    subtitle:
                    "Your account can be recovered within 30 days by logging in again. ",
                    isDanger: true,
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // _accountOption()
  // -----------------------------------------------------------
  Widget _accountOption({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    final bool showArrow =
        title != "Clear Data" && title != "Delete Account";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: subtitle == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: subtitle == null ? 0 : 2),
              child: Icon(icon,
                  color: isDanger ? Colors.red : const Color(0xFFB56A7E)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDanger ? Colors.red : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // _showClearDataDialog() — resets Firestore docs to defaults
  // -----------------------------------------------------------
  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _customDialog(
        context,
        title: "Clear Data",
        message: "Are you sure you want to clear all app data?",
        confirmText: "Clear",
        onConfirm: () async {
          Navigator.pop(context);
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            await FirebaseFirestore.instance
                .collection('cycle')
                .doc(user.uid)
                .set({
              'cycle type': 'Regular',
              'cycle length': 28,
              'period length': 3,
              'status': true,
              'emptyRecord': true,
              'setupComplete': false,
            });

            await FirebaseFirestore.instance
                .collection('settings')
                .doc(user.uid)
                .set({
              'smart prediction': true,
              'period notification': true,
              'ovulation notification': false,
              'log reminder': true,
              'summary': false,
              'setupComplete': false,
            });

            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const PeriodSetupScreen()),
                    (route) => false,
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to clear data. Please try again."),
                  backgroundColor: Color(0xFFB56A7E),
                ),
              );
            }
          }
        },
      ),
    );
  }

  // -----------------------------------------------------------
  // _showDeleteAccountDialog()
  //
  // SOFT DELETE — does NOT immediately erase data.
  //   1. Writes  users/{uid} → { deleted: true, deletedAt: now }
  //   2. Signs the user out and sends them to the Login screen.
  //
  // On the next login (see LoginScreen / AuthCubit), the app
  // checks this flag and offers a 30-day recovery window.
  // After 30 days, the account is permanently deleted.
  // -----------------------------------------------------------
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _customDialog(
        context,
        title: "Delete Account",
        message: "Are you sure you want to delete your account?",
        confirmText: "Delete",
        isDanger: true,
        onConfirm: () async {
          Navigator.pop(context);
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            // Mark as soft-deleted — do NOT call user.delete() here.
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'deleted': true,
              'deletedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            // Sign out so the user can't keep using the app.
            await FirebaseAuth.instance.signOut();

            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            }
          } on FirebaseAuthException catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.message ?? "An error occurred."),
                  backgroundColor: const Color(0xFFB56A7E),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to delete account. Please try again."),
                  backgroundColor: Color(0xFFB56A7E),
                ),
              );
            }
          }
        },
      ),
    );
  }

  // -----------------------------------------------------------
  // _customDialog()
  // -----------------------------------------------------------
  Widget _customDialog(
      BuildContext context, {
        required String title,
        required String message,
        required String confirmText,
        bool isDanger = false,
        required Future<void> Function() onConfirm,
      }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent[700], size: 40),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF301C29),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  height: 1.5, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF301C29),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(confirmText,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}