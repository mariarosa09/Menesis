import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      home: EditProfileScreen(),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController miController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  /// Fetch the current user's name from Firestore and pre-fill the fields
  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          fnameController.text = data['first name'] ?? '';
          miController.text   = data['middle initial'] ?? '';
          lnameController.text = data['last name'] ?? '';
        });
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'first name': fnameController.text.trim(),
        'middle initial': miController.text.trim(),
        'last name': lnameController.text.trim(),
      });
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return const InputDecoration().copyWith(
      hintText: hint,
      border: const UnderlineInputBorder(),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFB56A7E), width: 2),
      ),
    );
  }

  /// A field that clears on focus and shows a label beneath it
  Widget _labeledField({
    required TextEditingController controller,
    required String hint,
    required String label,
    int flex = 1,
    int maxLength = 100,
  }) {
    return Expanded(
      flex: flex,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus) controller.clear();
        },
        // Replace the Focus widget wrapping with this instead:
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              maxLength: maxLength,
              textCapitalization: TextCapitalization.words,
              textAlign: TextAlign.center,
              decoration: _inputDecoration(hint).copyWith(counterText: ""),
              onTap: () => controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    fnameController.dispose();
    miController.dispose();
    lnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 380;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB56A7E),
              ),
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
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
                                      splashColor: const Color(0xFFB56A7E).withOpacity(0.2),
                                      highlightColor: const Color(0xFFB56A7E).withOpacity(0.3),
                                      child: const Center(
                                        child: Icon(Icons.arrow_back, color: Color(0xFF3A1F3D)),
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
                          // Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFFBFC), Color(0xFFF9F1F4)],
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
                                // Avatar
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFB56A7E), Color(0xFF7B3F61)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFB56A7E).withOpacity(0.5),
                                        blurRadius: 25,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white, size: 45),
                                ),
                                const SizedBox(height: 20),
                                // Name fields
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Full Name",
                                      style: TextStyle(fontSize: 13, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 10),
                                    isSmallScreen
                                        ? Column(
                                      children: [
                                        _labeledField(controller: fnameController, hint: "First Name", label: "First Name"),
                                        const SizedBox(height: 12),
                                        _labeledField(controller: miController, hint: "M.I.", label: "M.I.", maxLength: 1),  // ✅
                                        const SizedBox(height: 12),
                                        _labeledField(controller: lnameController, hint: "Surname", label: "Surname"),
                                      ],
                                    )
                                        : Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _labeledField(controller: fnameController, hint: "First Name", label: "First Name", flex: 4),
                                        const SizedBox(width: 10),
                                        _labeledField(controller: miController, hint: "M.I.", label: "M.I.", flex: 2, maxLength: 1),  // ✅
                                        const SizedBox(width: 10),
                                        _labeledField(controller: lnameController, hint: "Surname", label: "Surname", flex: 4),
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      elevation: 0,
                                    ),
                                    onPressed: () async {
                                      await _updateName(); // ← await the save
                                      if (!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (builderContext) {
                                          Future.delayed(const Duration(seconds: 1), () {
                                            if (Navigator.of(builderContext).canPop()) {
                                              Navigator.of(builderContext).pop();
                                              Navigator.of(context).pop();
                                            }
                                          });
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                            backgroundColor: const Color(0xFFFFFBFC),
                                            title: const Text(
                                              "Edit Profile",
                                              style: TextStyle(
                                                fontFamily: 'CormorantGaramond',
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF3A1F3D),
                                              ),
                                            ),
                                            content: const Text(
                                              "New Name Saved!",
                                              style: TextStyle(fontSize: 14, color: Colors.black54),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      "Update My Profile",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
}