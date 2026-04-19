import 'package:flutter/material.dart';

// ============================================================
// EditProfileScreen
// - Ito ang screen para i-edit ng user ang kanyang profile.
// - StatelessWidget lang muna ito; later, gagawing StatefulWidget
//   para ma-handle ang live validation ng username at form inputs.
// ============================================================

// TODO: (EDIT) Palitan ang `StatelessWidget` ng `StatefulWidget`
// para ma-manage ang state ng form fields (e.g., username validation,
// full name display, at cooldown timer ng username change).
// The code should be placed here

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ============================================================
      // Scaffold Body — Main layout wrapper ng buong screen.
      // Ginagamit ang Stack para ma-layer ang background gradient
      // at ang actual content ng screen.
      // ============================================================
      body: Stack(
        children: [

          // ============================================================
          // Background Gradient
          // - Nag-aapply ng soft pink-to-light gradient sa buong screen
          //   para sa aesthetic ng app.
          // ============================================================
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

          // ============================================================
          // SafeArea + Main Content
          // - SafeArea para hindi macover ng notch o system UI ang content.
          // - Column ang ginamit para i-stack vertically ang header at card.
          // ============================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ============================================================
                  // Header Row — Back button + Screen title
                  // - Nagbibigay ng navigation back sa previous screen.
                  // ============================================================
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFF3A1F3D)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A1F3D),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ============================================================
                  // Main Card Container
                  // - Naka-wrap ang lahat ng form fields sa isang card
                  //   na may rounded corners, gradient background, at drop shadow.
                  // ============================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFFBFC),
                          Color(0xFFF9F1F4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        // ============================================================
                        // Profile Avatar
                        // - Circular gradient avatar with a person icon.
                        // - Placeholder lang ito; later pwedeng palitan ng actual
                        //   profile picture ng user mula sa storage/database.
                        // ============================================================
                        Container(
                          width: 100,
                          height: 100,
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
                                color: const Color(0xFFB56A7E).withOpacity(0.5),
                                blurRadius: 25,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),

                        // TODO: (EDIT) Palitan ang static Icon ng actual profile picture.
                        // Pwedeng gumamit ng `CircleAvatar` with `NetworkImage` o
                        // `FileImage` para ma-display ang profile photo ng user
                        // na nakastore sa database o local storage.
                        // The code should be placed here

                        const SizedBox(height: 20),

                        // ============================================================
                        // Full Name Fields — First Name, M.I., Surname
                        // - Tatlong TextField na naka-layout sa isang Row.
                        // - Flex ratios: First Name (4), M.I. (2), Surname (4)
                        //   para proportional ang sizing ng bawat field.
                        // ============================================================
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Full Name",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [

                                // First Name Field
                                Expanded(
                                  flex: 4,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "First Name",
                                      border: const UnderlineInputBorder(),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFB56A7E),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // Middle Initial Field (1 character only)
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    maxLength: 1,
                                    decoration: InputDecoration(
                                      hintText: "M.I.",
                                      counterText: "",
                                      border: const UnderlineInputBorder(),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFB56A7E),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // Surname Field
                                Expanded(
                                  flex: 4,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Surname",
                                      border: const UnderlineInputBorder(),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFB56A7E),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // TODO: (ADD) I-pre-populate ang First Name, M.I., at Surname fields
                            // gamit ang data ng user na nakastore sa database (e.g., Firestore/Supabase).
                            // Gamitin ang `TextEditingController` para ma-load ang existing values.
                            // The code should be placed here

                            // TODO: (ADD) DISPLAY FULL NAME sa profile view:
                            // Pagdating sa ibang screen (e.g., ProfileScreen), i-combine
                            // ang First Name + M.I. + Surname para mag-display bilang isang
                            // full name string (e.g., "Juan D. dela Cruz").
                            // The code should be placed here

                          ],
                        ),

                        const SizedBox(height: 15),

                        // ============================================================
                        // Username Field
                        // - Gumagamit ng reusable `_buildTextField` widget.
                        // - Dinisplay ang current username ng user.
                        // ============================================================
                        _buildTextField(
                          label: "Username",
                          hint: "username",
                        ),

                        // TODO: (EDIT) Palitan ang static `_buildTextField` ng isang
                        // StatefulWidget o custom widget na may built-in validation logic para sa username:
                        // - Pre-populate ang field gamit ang current username mula sa database.
                        // - Mag-check kung unique ang bagong username (real-time o on button press).
                        // - Mag-display ng error message sa baba ng field kung "This username already exists!"
                        // - I-disable ang "Change Username" button kung may duplicate.
                        // The code should be placed here

                        // TODO: (ADD) RE-CHANGE USERNAME COOLDOWN:
                        // Mag-store ng `lastUsernameChangeDate` sa database.
                        // Pag nag-attempt mag-change ang user, i-check kung ilang days na
                        // ang lumipas mula last change. Kung hindi pa sapat ang days,
                        // mag-display ng message: "You can change your username again after (?) days."
                        // Ikaw ang magdedecide kung ilang days ang cooldown period.
                        // The code should be placed here

                        // TODO: (ADD) USERNAME UNIQUENESS CHECK:
                        // Bago payagan mag-change ng username, i-query ang database
                        // para tingnan kung may existing na user na may same username.
                        // - Kung may existing na: i-disable ang button + show error sa baba ng field:
                        //   "This username already exists!"
                        // - Kung unique: i-enable ang button at payagan ang update.
                        // The code should be placed here

                        // TODO: (ADD) USERNAME DATABASE UPDATE:
                        // Kapag na-confirm na unique at valid ang bagong username,
                        // i-update ang username sa database (pwedeng gumamit ng
                        // database archive/history para ma-track ang mga previous usernames).
                        // The code should be placed here

                        const SizedBox(height: 15),

                        // ============================================================
                        // Update Profile Button
                        // - Styled ElevatedButton na may pink gradient shadow effect.
                        // - Mag-trigger ng profile update logic kapag pinindot.
                        // ============================================================
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB56A7E).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB56A7E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              // TODO: (ADD) I-call ang update profile function dito.
                              // I-save ang bagong First Name, M.I., Surname, at Username
                              // sa database. Mag-show ng success/error feedback (e.g., SnackBar).
                              // The code should be placed here
                            },
                            child: const Text(
                              "Update My Profile",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  // ============================================================
  // _buildTextField — Reusable Text Field Widget
  // - Helper method na nag-ge-generate ng labeled text field
  //   na may consistent styling (underline + pink focus border).
  // - Ginagamit para sa mga field na hindi kailangan ng special logic
  //   (e.g., simple single-line inputs).
  // ============================================================
  Widget _buildTextField({
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Field Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 5),

        // Text Input Field
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: const UnderlineInputBorder(),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFFB56A7E),
                width: 2,
              ),
            ),
          ),
        ),

        // TODO: (EDIT) Dagdagan ang `_buildTextField` ng optional `controller`,
        // `errorText`, at `onChanged` parameters para maging mas flexible at
        // reusable sa iba pang fields na kailangan ng validation o pre-population.
        // The code should be placed here

      ],
    );
  }
}