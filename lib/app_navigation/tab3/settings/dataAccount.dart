import 'package:flutter/material.dart';
import '/app_navigation/tab3/settings/changePass.dart';
import '/app_navigation/tab3/settings/changeEmail.dart';

// ============================================================
// DataAccountScreen
// Purpose: Settings screen para sa account-related actions ng user
// tulad ng change password, change email, clear data, at delete account.
// ============================================================
class DataAccountScreen extends StatelessWidget {
  const DataAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // ── BACKGROUND GRADIENT ──────────────────────────────────
          // Naglalagay ng gradient background mula itaas hanggang baba.
          // Purpose: Para magmukhang maayos at may visual depth ang screen.
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

          // ── MAIN CONTENT ─────────────────────────────────────────
          // SafeArea ensures hindi natatakpan ng status bar o notch ang content.
          // Purpose: Lahat ng visible na elements ay naka-wrap dito.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── HEADER: BACK BUTTON + TITLE ───────────────────
                  // Nagpapakita ng back arrow at screen title.
                  // Purpose: Para makabalik ang user sa nakaraang screen
                  // at malaman kung anong page siya ngayon.
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

                  // ── CYCLE INFO SECTION ────────────────────────────
                  // Nagpapakita ng cycle-related information ng user
                  // tulad ng Period Length at Cycle Length.
                  // Purpose: Para madaling makita ng user ang kanyang cycle data
                  // nang hindi na kailangang pumunta sa ibang screen.
                  _sectionLabel("Cycle Info"),

                  // TODO: [ADD] Kunin ang Period Length ng user mula sa database
                  // at i-display ito dito gamit ang isang display widget o Text.
                  // Dapat: mag-fetch ng value (e.g., "5 days") mula sa user record,
                  // at i-pass bilang subtitle sa _accountOption widget.
                  // The code should be placed here

                  _accountOption(
                    icon: Icons.water_drop_outlined,
                    title: "Period Length",
                    subtitle: null, // TODO: [EDIT] Palitan ng actual na value mula sa DB (e.g., "5 days")
                    showArrow: false,
                  ),

                  const Divider(),

                  // TODO: [ADD] Kunin ang Cycle Length ng user mula sa database
                  // at i-display ito dito. Dapat: mag-fetch ng value (e.g., "28 days")
                  // mula sa user record, at i-pass bilang subtitle sa _accountOption widget.
                  // The code should be placed here

                  _accountOption(
                    icon: Icons.loop_outlined,
                    title: "Cycle Length",
                    subtitle: null, // TODO: [EDIT] Palitan ng actual na value mula sa DB (e.g., "28 days")
                    showArrow: false,
                  ),

                  const SizedBox(height: 10),
                  const Divider(thickness: 1.5),
                  const SizedBox(height: 10),

                  // ── ACCOUNT ACTIONS SECTION ───────────────────────
                  // Nagpapakita ng mga action options na may kaugnayan sa account.
                  // Purpose: Para mapamahalaan ng user ang kanyang account settings.
                  _sectionLabel("Account"),

                  // ── OPTION: CHANGE PASSWORD ───────────────────────
                  // Pindutin para mapunta sa ChangePasswordScreen.
                  // Purpose: Para mapalitan ng user ang kanyang password.
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

                  // ── OPTION: CHANGE EMAIL ──────────────────────────
                  // Pindutin para mapunta sa ChangeEmailScreen.
                  // Purpose: Para mapalitan ng user ang kanyang email address.
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
                  const Divider(thickness: 1.5),
                  const SizedBox(height: 10),

                  // ── DANGER ZONE SECTION ───────────────────────────
                  // Nagpapakita ng mga mapanganib na options tulad ng
                  // Clear Data at Delete Account.
                  // Purpose: Malinaw na naka-hiwalay ang danger actions
                  // para hindi aksidenteng mapindot ng user.
                  _sectionLabel("Danger Zone", isDanger: true),

                  // ── OPTION: CLEAR DATA ────────────────────────────
                  // Nagpapakita ng confirmation dialog bago i-clear ang data.
                  // Purpose: Para maalis ng user ang lahat ng stored app data
                  // nang hindi natatanggal ang kanyang account.
                  _accountOption(
                    icon: Icons.cleaning_services_outlined,
                    title: "Clear Data",
                    isDanger: true,
                    showArrow: false,
                    onTap: () => _showClearDataDialog(context),
                  ),

                  const Divider(),

                  // ── OPTION: DELETE ACCOUNT ────────────────────────
                  // Nagpapakita ng confirmation dialog bago i-delete ang account.
                  // Purpose: Para permanenteng matanggal ng user ang kanyang account,
                  // na may 30-day recovery window.
                  _accountOption(
                    icon: Icons.delete_outline,
                    title: "Delete Account",
                    isDanger: true,
                    showArrow: false,
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

  // ── SECTION LABEL WIDGET ────────────────────────────────────────
  // Nagpapakita ng label/heading para sa bawat grupo ng options.
  // Purpose: Para malinaw na ma-grupo ang related na options
  // at mas madaling ma-navigate ng user ang screen.
  Widget _sectionLabel(String label, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDanger ? Colors.redAccent : const Color(0xFFB56A7E),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ── REUSABLE OPTION ITEM WIDGET ─────────────────────────────────
  // Isang row item na may icon, title, optional subtitle, at optional forward arrow.
  // Purpose: Para hindi paulit-ulit ang code sa bawat option item.
  // Ginagamit ang isDanger flag para gawing pula ang kulay kung mapanganib ang action.
  // Ginagamit ang showArrow flag para kontrolin kung kailan lalabas ang arrow icon.
  // Ginagamit ang subtitle para magpakita ng additional info (e.g., "5 days").
  Widget _accountOption({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDanger = false,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [

            // ── ICON ─────────────────────────────────────────────
            // Nagpapakita ng icon na nagsasaad ng uri ng option.
            // Pula kung isDanger, rosas kung normal.
            Icon(
              icon,
              color: isDanger ? Colors.red : const Color(0xFFB56A7E),
            ),
            const SizedBox(width: 12),

            // ── TITLE + SUBTITLE ──────────────────────────────────
            // Nagpapakita ng pangunahing label at optional na additional info.
            // Purpose: Para malaman ng user kung ano ang option at ang kasalukuyang value nito.
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
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),

            // ── FORWARD ARROW ─────────────────────────────────────
            // Ipinapakita lang kung ang showArrow ay true.
            // Purpose: Visual cue na may navigation ang option na ito.
            if (showArrow)
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  // ── CLEAR DATA DIALOG ───────────────────────────────────────────
  // Nagpapakita ng warning dialog bago i-clear ang data ng user.
  // Purpose: Para masigurado na sadya ng user ang aksyon bago ito isagawa.
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
            // TODO: [EDIT] I-implement ang actual na Clear Data logic dito.
            // Kapag pinindot ng user ang "Clear" button, dapat:
            // 1. I-reset ang lahat ng locally stored data ng user
            //    (hal. SharedPreferences.clear(), local Hive/SQLite data).
            // 2. Huwag tanggalin ang account sa database — existing pa rin ang account,
            //    i-clear lang ang mga ininput na data sa app locally.
            // 3. I-close muna ang dialog gamit ang Navigator.pop(context).
            // 4. Mag-trigger ng app refresh — i-navigate ang user pabalik sa homepage.
            //    (Gamitin ang Navigator.pushAndRemoveUntil para ma-clear ang nav stack.)
            // 5. Pagkatapos ng redirect, magpakita ng SnackBar na nagsasabing:
            //    "Data cleared successfully." o katulad na mensahe.
            // Note: Kung may loading/delay (e.g., async DB clear), pwedeng mag-show
            //    ng loading indicator muna bago mag-navigate.
            // The code should be placed here

          },
        );
      },
    );
  }

  // ── DELETE ACCOUNT DIALOG ───────────────────────────────────────
  // Nagpapakita ng warning dialog bago i-delete ang account ng user.
  // Purpose: Para masigurado na sadya ng user ang aksyon.
  // May 30-day recovery window bago permanenteng matanggal ang account.
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
            // TODO: [EDIT] I-implement ang actual na Delete Account logic dito.
            // Kapag pinindot ng user ang "Delete" button, dapat:
            // 1. I-mark ang account sa database bilang "deleted" — soft delete lang ito.
            //    Huwag agad permanenteng tanggalin. Mag-save ng deletion timestamp
            //    (hal. deletedAt: DateTime.now()) sa user record sa database.
            // 2. Mag-set ng 30-day recovery window:
            //    - Kung nag-login ulit ang user within 30 days → i-restore ang account
            //      (i-clear ang deletedAt field).
            //    - Kung hindi na-recover after 30 days → permanenteng tanggalin ang account.
            //      Ito ay dapat i-handle sa backend via scheduled job,
            //      Cloud Function (Firebase), o cron task.
            // 3. I-log out ang user at i-redirect sa login/splash screen.
            //    (Gamitin ang Navigator.pushAndRemoveUntil para ma-clear ang nav stack.)
            // 4. Optional: Magpakita ng final message o screen na nagsasabi na
            //    naka-delete na ang account at kailan maa-recover.
            // The code should be placed here

          },
        );
      },
    );
  }

  // ── REUSABLE CUSTOM DIALOG WIDGET ──────────────────────────────
  // Nagpapakita ng styled confirmation dialog na may icon, title, message, at buttons.
  // Purpose: Para magamit ng pareho ang dialog design sa Clear Data at Delete Account.
  // Ginagamit ang isDanger flag para mag-indicate kung mapanganib ang action.
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

            // ── WARNING ICON ────────────────────────────────────
            // Nagpapakita ng warning icon sa tuktok ng dialog.
            // Purpose: Visual cue para malaman ng user na seryoso ang aksyon.
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent[700],
              size: 40,
            ),

            const SizedBox(height: 15),

            // ── DIALOG TITLE ────────────────────────────────────
            // Nagpapakita ng pangalan ng aksyon (e.g., "Clear Data", "Delete Account").
            // Purpose: Para malaman agad ng user kung ano ang nangyayari.
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF301C29),
              ),
            ),

            const SizedBox(height: 15),

            // ── DIALOG MESSAGE ──────────────────────────────────
            // Nagpapakita ng detalyadong mensahe tungkol sa aksyon.
            // Purpose: Para malaman ng user ang consequences bago mag-confirm.
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

            // ── ACTION BUTTONS: CANCEL + CONFIRM ────────────────
            // Nagpapakita ng dalawang buttons: Cancel (dismiss) at Confirm (proceed).
            // Purpose: Binibigyan ng pagpipilian ang user na ituloy o kanselahin ang aksyon.
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