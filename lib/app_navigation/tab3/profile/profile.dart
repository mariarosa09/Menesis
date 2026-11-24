import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menesis_app/auth/presentation/auth_cubit.dart';
import 'package:menesis_app/services/cycle_repository.dart';
import 'editProfile.dart';
import '/app_navigation/tab3/settings/dataAccount.dart';
import '/app_navigation/tab3/settings/notifs.dart';
import '/registration/main.dart';
import '/app_navigation/tab3/profile/periodLength.dart';
import '/app_navigation/tab3/profile/cycleLength.dart';

/// ============================================================
/// FILE: manageProfile.dart
/// SCREEN: ManageProfileScreen
/// PURPOSE: Ipinapakita ang profile ng user kasama ang kanyang
///          avatar, pangalan, email, menstrual summary, at
///          general settings (Data & Account, Notifications).
/// ============================================================

/// =============================================
/// COMMENTED OUT: Standalone runner para sa testing lang
/// Pwedeng i-uncomment kung gusto i-run separately
/// =============================================
/*void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ManageProfileScreen(),
    );
  }
}*/

/// =============================================
/// MAIN SCREEN WIDGET: ManageProfileScreen
/// Stateless kasi hindi nagbabago ang UI based sa user interaction
/// dito mismo — ang data ay galing sa ibang source (database).
/// =============================================
class ManageProfileScreen extends StatefulWidget {
  const ManageProfileScreen({super.key});

  @override
  State<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  StreamSubscription<CycleInfo?>? _cycleSub;

  @override
  void initState() {
    _subscribeToProfile();
    super.initState();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _cycleSub?.cancel();
    super.dispose();
  }

  String? name;
  String? email;
  String? periodLength;
  String? cycleLength;

  /// One listener for the user document (name + email) and one for the
  /// cycle settings, instead of two listeners on the same document plus two
  /// separate reads of `cycle info`. The cycle listener also keeps the
  /// lengths in sync after editing them, so no manual re-fetch is needed.
  void _subscribeToProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final repo = CycleRepository.instance;

    _userSub = repo.userDoc(user.uid).snapshots().listen((snap) {
      final data = snap.data();
      if (data == null || !mounted) return;
      final String first  = data['first name'] ?? '';
      final String middle = data['middle initial'] ?? '';
      final String last   = data['last name'] ?? '';
      String display;
      if (first.isEmpty && middle.isEmpty && last.isEmpty) {
        display = data['username'] ?? '';
      } else if (middle.isEmpty) {
        display = "$first $last";
      } else {
        display = "$first $middle. $last";
      }
      setState(() {
        name  = display;
        email = data['email'];
      });
    }, onError: (e) => debugPrint('Profile listener error: $e'));

    _cycleSub = repo.cycleInfoStream().listen((info) {
      if (info == null || !mounted) return;
      setState(() {
        periodLength = info.periodLength.toString();
        cycleLength  = info.cycleLength.toString();
      });
    }, onError: (e) => debugPrint('Cycle info listener error: $e'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// -----------------------------------------------
      /// BODY: Gumagamit ng Stack para malagyan ng
      /// gradient background at ang content sa ibabaw nito.
      /// Ginawang SingleChildScrollView para scrollable ang
      /// buong screen lalo na sa maliliit na device.
      /// -----------------------------------------------
      body: Stack(
        children: [

          /// -----------------------------------------------
          /// BACKGROUND GRADIENT
          /// Nagbibigay ng malambot na pink-to-light gradient
          /// na background para sa buong screen.
          /// -----------------------------------------------
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

          /// -----------------------------------------------
          /// SAFE AREA + SCROLLABLE CONTENT
          /// SafeArea para hindi matakpan ng status bar ang content.
          /// SingleChildScrollView para scrollable ang lahat ng content
          /// kahit maliit ang screen ng device.
          /// -----------------------------------------------
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// -----------------------------------------------
                  /// HEADER SECTION
                  /// Ipinapakita ang "My Profile" na pamagat sa itaas.
                  /// -----------------------------------------------
                  const SizedBox(height: 15),
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A1F3D),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// -----------------------------------------------
                  /// PROFILE CARD SECTION
                  /// Ipinapakita ang avatar ng user, pangalan, email,
                  /// at isang "Edit Profile" button.
                  /// -----------------------------------------------
                  _sectionCard(
                    child: Center(
                      child: Column(
                        children: [

                          const SizedBox(height: 10),

                          /// -----------------------------------------------
                          /// AVATAR / PROFILE PICTURE
                          /// Circular container na may gradient at glow shadow.
                          /// Gumagamit ng default person icon bilang placeholder.
                          /// -----------------------------------------------
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFB56A7E),
                                  Color(0xFF7B3F61),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFB56A7E)
                                      .withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// -----------------------------------------------
                          /// USER FULL NAME DISPLAY
                          /// Dapat ipakita ang buong pangalan ng user:
                          /// First Name + M.I. + Surname (mula sa registration).
                          /// -----------------------------------------------

                          Text(name ?? "User",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3A1F3D),
                            ),
                          ),

                          const SizedBox(height: 5),

                          /// -----------------------------------------------
                          /// USER EMAIL DISPLAY
                          /// Ipinapakita ang email ng user sa ilalim ng pangalan.
                          /// -----------------------------------------------

                          Text(email ?? "user@email.com",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black45,
                            ),
                          ),

                          const SizedBox(height: 18),

                          /// -----------------------------------------------
                          /// EDIT PROFILE BUTTON
                          /// Nag-navigate papunta sa EditProfileScreen
                          /// para i-edit ang profile ng user.
                          /// -----------------------------------------------
                          Container(
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
                                    horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    EditProfileScreen(),
                                  ),
                                );
                              },
                              child: const Text("Edit Profile"),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// -----------------------------------------------
                  /// MENSTRUAL SUMMARY CARD
                  /// Ipinapakita ang Period Length at Cycle Length ng user.
                  /// Kasalukuyan ay "--" ang values — placeholder pa lang ito
                  /// hanggang ma-connect sa database.
                  /// -----------------------------------------------

                  // TODO: (EDIT) - Kunin ang Period Length at Cycle Length
                  // ng user mula sa database at palitan ang "--" na placeholder values.
                  // EDIT: I-fetch ang menstrual data ng user (period length at cycle length)
                  // at i-pass ang mga values sa _infoRow widgets bilang dynamic strings.
                  // The code should be placed here

                  _sectionCard(
                    title: "Menstrual Summary",
                    child: Column(
                      children: [
                        _tappableInfoRow(
                          label: "Period Length",
                          value: periodLength != null ? "$periodLength days" : "--",
                          onTap: () async {
                            if (periodLength == null) return;
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PeriodLengthSettingsScreen(
                                  currentLength: int.tryParse(periodLength!) ?? 5,
                                ),
                              ),
                            );
                          },
                        ),

                        AppDivider(),

                        _tappableInfoRow(
                          label: "Cycle Length",
                          value: cycleLength != null ? "$cycleLength days" : "--",
                          onTap: () async {
                            if (cycleLength == null) return;
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CycleLengthSettingsScreen(
                                  currentLength: int.tryParse(cycleLength!) ?? 28,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// -----------------------------------------------
                  /// GENERAL SETTINGS CARD
                  /// Naglalaman ng mga navigation items para sa
                  /// Data & Account at Notifications screens.
                  /// -----------------------------------------------
                  _sectionCard(
                    title: "General Settings",
                    child: Column(
                      children: [

                        /// -----------------------------------------------
                        /// SETTINGS ITEM: Data & Account
                        /// Nag-navigate papunta sa DataAccountScreen.
                        /// -----------------------------------------------
                        _settingsItem(
                          Icons.person_outline,
                          "Data & Account",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const DataAccountScreen(),
                              ),
                            );
                          },
                        ),

                        const AppDivider(),

                        /// -----------------------------------------------
                        /// SETTINGS ITEM: Notifications
                        /// Nag-navigate papunta sa NotificationsScreen.
                        /// -----------------------------------------------
                        _settingsItem(
                          Icons.notifications_none,
                          "Notifications",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const NotificationsScreen(),
                              ),
                            );
                          },
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// -----------------------------------------------
                  /// LOGOUT CARD
                  /// Nagbibigay ng logout option para sa user.
                  /// Nag-navigate pabalik sa LoginScreen at
                  /// inaalis ang lahat ng previous routes sa stack.
                  /// -----------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFFBFC),
                          Color(0xFFF9F1F4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _settingsItem(
                      Icons.logout,
                      "Log Out",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              backgroundColor: const Color(0xFFFFFBFC),
                              title: const Text(
                                "Log Out",
                                style: TextStyle(
                                  fontFamily: 'CormorantGaramond',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3A1F3D),
                                ),
                              ),
                              content: const Text(
                                "Are you sure you want to log out?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final authCubit = context.read<AuthCubit>();
                                    authCubit.logout();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginScreen(),
                                      ),
                                          (route) => false,
                                    );
                                  },
                                  child: const Text(
                                    "Log Out",
                                    style: TextStyle(
                                      color: Color(0xFFB56A7E),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),


                  /// -----------------------------------------------
                  /// APP VERSION TEXT
                  /// Ipinapakita sa pinaka-ibaba ng screen ang
                  /// kasalukuyang version ng app.
                  /// -----------------------------------------------
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// REUSABLE WIDGET: _sectionCard
/// PURPOSE: Nagse-serve bilang styled card container na may
///          optional title at custom child content.
///          Ginagamit sa iba't ibang section ng profile screen.
/// ============================================================
class _sectionCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const _sectionCard({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

      /// -----------------------------------------------
      /// CARD DECORATION
      /// Rounded corners, soft gradient background,
      /// at banayad na box shadow para sa depth effect.
      /// -----------------------------------------------
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFBFC),
            Color(0xFFF9F1F4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      /// -----------------------------------------------
      /// CARD CONTENT LAYOUT
      /// Ipinapakita ang optional title sa itaas,
      /// at ang child widget sa ibaba nito.
      /// -----------------------------------------------
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 1,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

/// ============================================================
/// REUSABLE WIDGET: _infoRow
/// PURPOSE: Nagdidisplay ng label-value pair sa isang row.
///          Ginagamit sa Menstrual Summary section para
///          ipakita ang Period at Cycle Length ng user.
/// ============================================================
class _infoRow extends StatelessWidget {
  final String label;
  final String value;

  const _infoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),

      /// -----------------------------------------------
      /// ROW LAYOUT
      /// Label sa kaliwa, value sa kanan na may pink color.
      /// -----------------------------------------------
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFB56A7E),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _tappableInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _tappableInfoRow({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFB56A7E),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: Color(0xFFB56A7E),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// REUSABLE WIDGET: _settingsItem
/// PURPOSE: Nagdidisplay ng isang settings row na may icon,
///          label text, at forward arrow. Tappable ito para
///          mag-navigate sa kani-kanilang settings screens.
/// ============================================================
class _settingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _settingsItem(this.icon, this.title, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,

      /// -----------------------------------------------
      /// SETTINGS ROW LAYOUT
      /// Icon sa kaliwa, title sa gitna (nag-eexpand),
      /// at forward arrow icon sa kanan.
      /// -----------------------------------------------
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB56A7E)),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// REUSABLE WIDGET: AppDivider
/// PURPOSE: Nagse-serve bilang visual separator (manipis na linya)
///          sa pagitan ng mga items sa loob ng cards.
/// ============================================================
class AppDivider extends StatelessWidget {
  const AppDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.grey.shade300,
      height: 1,
    );
  }
}