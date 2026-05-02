import 'package:flutter/material.dart';
import '/app_navigation/tab3/settings/changePass.dart';
import '/app_navigation/tab3/settings/changeEmail.dart';

/// ============================================================
/// DataAccountScreen
/// - Ito ang screen para sa "Data & Account" settings ng user.
/// - Naglalaman ng options: Change Password, Change Email,
///   Clear Data, at Delete Account.
/// ============================================================
class DataAccountScreen extends StatelessWidget {
  const DataAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// --- BACKGROUND GRADIENT ---
          /// Naglalagay ng gradient background mula top hanggang bottom.
          /// Ginagawa itong visual base ng buong screen.
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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// --- HEADER ROW (Back Button + Title) ---
                  /// Nagpapakita ng back arrow at ng title na "Data & Account".
                  /// Ang Transform.translate ay ginagamit para i-align nang maayos
                  /// ang icon at text sa loob ng row.
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

                  /// --- ACCOUNT OPTIONS LIST ---
                  /// Bawat _accountOption() ay isang tappable row na may icon at label.
                  /// Ang Divider() sa pagitan ay separator para sa bawat option.

                  // Change Password — dinidiretso sa ChangePasswordScreen
                  _accountOption(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // Change Email — dinidiretso sa ChangeEmailScreen
                  _accountOption(
                    icon: Icons.mail_outline,
                    title: "Change Email",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeEmailScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 5),
                  const Divider(),

                  // Clear Data — nagbubukas ng confirmation dialog
                  _accountOption(
                    icon: Icons.cleaning_services_outlined,
                    title: "Clear Data",
                    onTap: () => _showClearDataDialog(context),
                  ),

                  const Divider(),

                  // Delete Account — nagbubukas ng confirmation dialog (danger action)
                  _accountOption(
                    icon: Icons.delete_outline,
                    title: "Delete Account",
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

  /// ============================================================
  /// _accountOption()
  /// - Reusable widget para sa bawat row ng setting option.
  /// - May icon, label, at optional arrow sa kanan.
  /// - Ang isDanger flag ay nagbabago ng kulay ng icon at text sa pula
  ///   para sa destructive actions tulad ng Delete Account.
  /// ============================================================
  Widget _accountOption({
    required IconData icon,
    required String title,
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    // Tinatanggal ang arrow para sa Clear Data at Delete Account
    // dahil hindi sila nagdidiretso sa ibang screen.
    final bool showArrow =
        title != "Clear Data" && title != "Delete Account";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDanger ? Colors.red : const Color(0xFFB56A7E),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDanger ? Colors.red : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showArrow)
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  /// ============================================================
  /// _showClearDataDialog()
  /// - Nagpapakita ng confirmation dialog bago i-clear ang app data.
  /// - Ginagamit ang _customDialog() para sa consistent na UI.
  /// ============================================================
  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _customDialog(
          context,
          title: "Clear Data",
          message:
          "Are you sure you want to clear all app data?\n\nThis action cannot be undone.",
          confirmText: "Clear",
          onConfirm: () {
            // TODO: (EDIT) - I-implement ang actual na Clear Data logic dito.
            // Kapag pinindot ng user ang "Clear" button, dapat:
            // 1. I-reset ang lahat ng locally stored data ng user
            //    (e.g., SharedPreferences, Hive, local DB)
            //    PERO hindi dapat mabura ang account sa database —
            //    existing pa rin ang account, local data lang ang mawawala.
            // 2. Pagkatapos ma-clear ang data, i-refresh/restart ang app
            //    para magsimula ulit sa initial state (parang bagong install).
            // 3. I-navigate ang user pabalik sa homepage automatically
            //    (ilang seconds after ng successful clear — depende sa implementation).
            // 4. Magpakita ng SnackBar message na nagsasabi na
            //    successful ang pag-clear ng data.
            // Tip: Pwedeng gamitin ang Navigator.pushAndRemoveUntil()
            //      para i-reset ang navigation stack, at ang
            //      RestartWidget / Phoenix package para i-restart ang app.
            // The code should be placed here

          },
        );
      },
    );
  }

  /// ============================================================
  /// _showDeleteAccountDialog()
  /// - Nagpapakita ng confirmation dialog bago i-delete ang account.
  /// - May warning na ang account ay maaaring ma-recover within 30 days.
  /// ============================================================
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _customDialog(
          context,
          title: "Delete Account",
          message:
          "Are you sure you want to delete your account?\n\nAll your data will be permanently removed.\n\nYou can recover your account within 30 days. After that, it cannot be restored.",
          confirmText: "Delete",
          isDanger: true,
          onConfirm: () {
            // TODO: (EDIT) - I-implement ang actual na Delete Account logic dito.
            // Kapag pinindot ng user ang "Delete" button, dapat:
            // 1. Huwag agad na burahin ang account sa database.
            //    I-mark lang ang account bilang "deleted" o "pending_deletion"
            //    at i-store ang deletion timestamp sa database.
            // 2. Ang account ay mananatili sa database ng 30 days
            //    mula deletion date. Pwedeng gumamit ng scheduled job /
            //    cloud function para awtomatikong tanggalin ang account
            //    pagkatapos ng 30 days kung hindi na-retrieve ng owner.
            // 3. Kung gusto mong payagan ang user na ma-recover ang account
            //    within 30 days, gumawa ng separate recovery screen o flow.
            // 4. Pagkatapos ma-mark bilang deleted, i-log out ang user at
            //    i-navigate siya sa login/onboarding screen.
            // Tip: Sa Firestore, pwedeng mag-add ng field na:
            //      "isDeleted: true" at "deletedAt: Timestamp"
            //      Tapos gumawa ng Cloud Function na nag-check
            //      at nag-delete after 30 days.
            // The code should be placed here

          },
        );
      },
    );
  }

  /// ============================================================
  /// _customDialog()
  /// - Reusable custom dialog widget para sa Clear Data at Delete Account.
  /// - Naglalaman ng warning icon, title, message, Cancel, at Confirm buttons.
  /// - Ang isDanger flag ay dating nagbabago ng kulay pero pareho naman
  ///   ang dalawa, kaya na-simplify na ang logic dito.
  /// ============================================================
  Widget _customDialog(
      BuildContext context, {
        required String title,
        required String message,
        required String confirmText,
        bool isDanger = false,
        required VoidCallback onConfirm,
      }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// --- WARNING ICON ---
            /// Nagpapakita ng warning icon para alertin ang user
            /// na ang action na ito ay may epekto at hindi basta-basta.
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent[700],
              size: 40,
            ),

            const SizedBox(height: 15),

            /// --- DIALOG TITLE ---
            /// Ang title ay bold at may dark color para sa emphasis.
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF301C29),
              ),
            ),

            const SizedBox(height: 15),

            /// --- DIALOG MESSAGE ---
            /// Nagpapaliwanag ng consequences ng action sa user.
            /// Center-aligned para mas madaling mabasa.
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 1.5,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            /// --- ACTION BUTTONS (Cancel + Confirm) ---
            /// Dalawang buttons sa isang Row:
            /// - Cancel: nag-close ng dialog, walang nangyayari.
            /// - Confirm: nag-e-execute ng action (Clear o Delete).
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(color: Colors.white),
                    ),
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