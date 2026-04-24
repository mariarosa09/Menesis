import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mēnesis',
      home: const EditProfileScreen(),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  // Reusable input decoration for text fields
  InputDecoration _inputDecoration(String hint) {
    return const InputDecoration().copyWith(
      hintText: hint,
      border: const UnderlineInputBorder(),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFB56A7E),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kinukuha screen width para ma-adjust layout dynamically
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if device is small (fara prevent overflow)
    final bool isSmallScreen = screenWidth < 380;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevent keyboard overflow
      body: Stack(
        children: [
          // Background gradient
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  // Ensures content fills screen height but still scrolls
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),

                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                        // HEADER & ARROW_BACK BUTTORN YAS
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
                                  "Edit Profile",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3A1F3D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // Main card container
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
                                // Profile avatar
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
                                        color: const Color(0xFFB56A7E)
                                            .withOpacity(0.5),
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

                                const SizedBox(height: 20),

                                // Full name section
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

                                    // Responsive layout:
                                    // Column for small screens, Row for larger screens
                                    isSmallScreen
                                        ? Column(
                                      children: [
                                        TextField(
                                          decoration:
                                          _inputDecoration(
                                            "First Name",
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          maxLength: 1,
                                          decoration:
                                          _inputDecoration(
                                            "M.I.",
                                          ).copyWith(
                                            counterText: "",
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          decoration:
                                          _inputDecoration(
                                            "Surname",
                                          ),
                                        ),
                                      ],
                                    )
                                        : Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: TextField(
                                            decoration:
                                            _inputDecoration(
                                              "First Name",
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          flex: 2,
                                          child: TextField(
                                            maxLength: 1,
                                            decoration:
                                            _inputDecoration(
                                              "M.I.",
                                            ).copyWith(
                                              counterText: "",
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          flex: 4,
                                          child: TextField(
                                            decoration:
                                            _inputDecoration(
                                              "Surname",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Update button
                                Container(
                                  width: double.infinity,
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
                                      backgroundColor:
                                      const Color(0xFFB56A7E),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(25),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      "Update My Profile",
                                      textAlign: TextAlign.center,
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

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Reusable labeled text field widget
  Widget _buildTextField({
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
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
      ],
    );
  }
}