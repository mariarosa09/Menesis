import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class dailyLog extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(String logSummary)? onSaved;

  const dailyLog({super.key, required this.selectedDate, this.onSaved});

  @override
  State<dailyLog> createState() => _dailyLogState();
}

class _dailyLogState extends State<dailyLog> {
  final List<Map<String, String>> moods = [
    {"label": "Mood Swing", "icon": "🔄"},
    {"label": "Irritable", "icon": "😠"},
    {"label": "Sad", "icon": "😢"},
    {"label": "Anxious", "icon": "😰"},
    {"label": "Confident", "icon": "😎"},
    {"label": "Happy", "icon": "😊"},
    {"label": "Impatient", "icon": "😤"},
    {"label": "Inspired", "icon": "✨"},
  ];

  final List<Map<String, String>> symptoms = [
    {"label": "Cramps", "icon": "🤕"},
    {"label": "Headaches", "icon": "🤯"},
    {"label": "Nausea", "icon": "🤢"},
    {"label": "Bloating", "icon": "😖"},
    {"label": "Breast Tenderness", "icon": "💢"},
    {"label": "Breakouts", "icon": "😬"},
    {"label": "Cravings", "icon": "🍫"},
    {"label": "Stress", "icon": "😫"},
    {"label": "Constipation", "icon": "🚫"},
    {"label": "Diarrhea", "icon": "💩"},
  ];

  // FIX 1: " Discharge" appended to every label
  final List<Map<String, String>> dischargeTypes = [
    {"label": "Clear/Transparent", "icon": "assets/images/discharge_icon/clear.png"},
    {"label": "Milky White",        "icon": "assets/images/discharge_icon/milky_white.png"},
    {"label": "Gray",               "icon": "assets/images/discharge_icon/gray.png"},
    {"label": "Bright Yellow",      "icon": "assets/images/discharge_icon/bright_yellow.png"},
    {"label": "Green",              "icon": "assets/images/discharge_icon/green.png"},
    {"label": "Pink",               "icon": "assets/images/discharge_icon/pink.png"},
    {"label": "Red",                "icon": "assets/images/discharge_icon/red.png"},
    {"label": "Brown",              "icon": "assets/images/discharge_icon/brown.png"},
    {"label": "Watery",             "icon": "assets/images/discharge_icon/watery.png"},
  ];

  Set<String> selectedMoods      = {};
  Set<String> selectedSymptoms   = {};
  Set<String> selectedDischarge  = {};

  final TextEditingController notesController = TextEditingController();
  // FIX 3: focus node so we can scroll the notes field into view
  final FocusNode _notesFocusNode = FocusNode();
  final GlobalKey _notesFieldKey = GlobalKey();

  Map<String, String> get _symptomEmoji => {
    for (final s in symptoms) s["label"]!: s["icon"]!
  };
  Map<String, String> get _moodEmoji => {
    for (final m in moods) m["label"]!: m["icon"]!
  };
  // FIX 2 (shared): map label → asset path for summary builder
  Map<String, String> get _dischargeIcon => {
    for (final d in dischargeTypes) d["label"]!: d["icon"]!
  };

  @override
  void initState() {
    super.initState();
    getSymptoms();
    getMood();
    getDischarge();
    getNotes();
  }

  @override
  void dispose() {
    notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  String _buildLogSummary() {
    final parts = <String>[];

    if (selectedSymptoms.isNotEmpty) {
      final icons = selectedSymptoms
          .map((s) => '${_symptomEmoji[s] ?? ''} $s')
          .join('  ·  ');
      parts.add('Symptoms\n$icons');
    }

    if (selectedMoods.isNotEmpty) {
      final icons = selectedMoods
          .map((m) => '${_moodEmoji[m] ?? ''} $m')
          .join('  ·  ');
      parts.add('Mood\n$icons');
    }

    if (selectedDischarge.isNotEmpty) {
      // FIX 2: encode as "assetPath|label" so the calendar can render the image
      final icons = selectedDischarge.map((label) {
        final path = _dischargeIcon[label] ?? '';
        return path.isNotEmpty ? '$path|$label' : label;
      }).join('  ·  ');
      parts.add('Discharge\n$icons');
    }

    return parts.join('\n\n');
  }

  void saveLog() async {
    final user = FirebaseAuth.instance.currentUser;
    final date = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cycle')
          .doc('cycle info')
          .collection('symptomsLogs')
          .doc(date.toString())
          .set({
        'log date':          date,
        'physical symptoms': selectedSymptoms.toList(),
        'mood':              selectedMoods.toList(),
        'discharge':         selectedDischarge.toList(),
        'notes':             notesController.text.trim(),
      }, SetOptions(merge: true));

      widget.onSaved?.call(_buildLogSummary());
    }
  }

  void getSymptoms() async {
    final user = FirebaseAuth.instance.currentUser;
    final date = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    if (user != null) {
      final log = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cycle')
          .doc('cycle info')
          .collection('symptomsLogs')
          .doc(date.toString())
          .get();
      if (mounted) {
        setState(() {
          selectedSymptoms = log.exists
              ? (log['physical symptoms'] as List?)?.cast<String>().toSet() ?? {}
              : {};
        });
      }
    }
  }

  void getMood() async {
    final user = FirebaseAuth.instance.currentUser;
    final date = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    if (user != null) {
      final log = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cycle')
          .doc('cycle info')
          .collection('symptomsLogs')
          .doc(date.toString())
          .get();
      if (mounted) {
        setState(() {
          selectedMoods = log.exists
              ? (log['mood'] as List?)?.cast<String>().toSet() ?? {}
              : {};
        });
      }
    }
  }

  void getDischarge() async {
    final user = FirebaseAuth.instance.currentUser;
    final date = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    if (user != null) {
      final log = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cycle')
          .doc('cycle info')
          .collection('symptomsLogs')
          .doc(date.toString())
          .get();
      if (mounted) {
        setState(() {
          selectedDischarge = log.exists
              ? (log['discharge'] as List?)?.cast<String>().toSet() ?? {}
              : {};
        });
      }
    }
  }

  void getNotes() async {
    final user = FirebaseAuth.instance.currentUser;
    final date = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    if (user != null) {
      final log = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cycle')
          .doc('cycle info')
          .collection('symptomsLogs')
          .doc(date.toString())
          .get();
      if (mounted) {
        setState(() {
          notesController.text = log.exists ? (log['notes'] ?? '') : '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        // FIX 3: push content up by the keyboard height when it's visible
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Daily Log",
                        style: TextStyle(
                          fontFamily: 'CormorantGaramond',
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A1F3D),
                        ),
                      ),
                      Text(
                        _formatDate(widget.selectedDate),
                        style: const TextStyle(
                          fontFamily: "DMSans",
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "PHYSICAL SYMPTOMS",
              style: TextStyle(
                fontFamily: "DMSans",
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),

            Column(
              children: [
                Row(
                  children: symptoms.take(2).map((symptom) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: SizedBox(
                          height: 66,
                          child: _SelectableBox(
                            label: symptom["label"]!,
                            icon: symptom["icon"]!,
                            isSelected: selectedSymptoms.contains(symptom["label"]),
                            onTap: () => setState(() {
                              toggleSelection(selectedSymptoms, symptom["label"]!);
                            }),
                            iconSize: 20,
                            imageSize: 30,
                            fontSize: 11,
                            borderRadius: 16,
                            verticalPadding: 6,
                            iconLabelSpacing: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  itemCount: symptoms.skip(2).length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 84,
                  ),
                  itemBuilder: (context, index) {
                    final symptom = symptoms.skip(2).toList()[index];
                    return _SelectableBox(
                      label: symptom["label"]!,
                      icon: symptom["icon"]!,
                      isSelected: selectedSymptoms.contains(symptom["label"]),
                      onTap: () => setState(() {
                        toggleSelection(selectedSymptoms, symptom["label"]!);
                      }),
                      iconSize: 20,
                      imageSize: 30,
                      fontSize: 10.5,
                      borderRadius: 16,
                      verticalPadding: 6,
                      iconLabelSpacing: 3,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              "MOOD",
              style: TextStyle(
                fontFamily: "DMSans",
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),

            GridView.builder(
              itemCount: moods.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 84,
              ),
              itemBuilder: (context, index) {
                final mood = moods[index];
                return _SelectableBox(
                  label: mood["label"]!,
                  icon: mood["icon"]!,
                  isSelected: selectedMoods.contains(mood["label"]),
                  onTap: () => setState(() {
                    toggleSelection(selectedMoods, mood["label"]!);
                  }),
                  iconSize: 20,
                  imageSize: 30,
                  fontSize: 10.5,
                  borderRadius: 16,
                  verticalPadding: 6,
                  iconLabelSpacing: 3,
                );
              },
            ),

            const SizedBox(height: 16),

            const Text(
              "DISCHARGE",
              style: TextStyle(
                fontFamily: "DMSans",
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),

            GridView.builder(
              itemCount: dischargeTypes.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 106,
              ),
              itemBuilder: (context, index) {
                final type = dischargeTypes[index];
                return _SelectableBox(
                  label: type["label"]!,
                  icon: type["icon"]!,
                  isSelected: selectedDischarge.contains(type["label"]),
                  onTap: () => setState(() {
                    toggleSelection(selectedDischarge, type["label"]!);
                  }),
                  iconSize: 20,
                  imageSize: 40,
                  fontSize: 10.5,
                  borderRadius: 16,
                  verticalPadding: 6,
                  iconLabelSpacing: 4,
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "NOTES (OPTIONAL)",
              style: TextStyle(
                fontFamily: "DMSans",
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),

            // FIX 3: ScrollIntoView so the keyboard never hides the notes field
            TextField(
              key: _notesFieldKey,
              controller: notesController,
              focusNode: _notesFocusNode,
              maxLines: 3,
              onTap: () {
                // Give the keyboard time to appear, then scroll to the field
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (!mounted) return;

                  final notesContext = _notesFieldKey.currentContext;
                  if (notesContext == null) return;

                  Scrollable.ensureVisible(
                    notesContext,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    alignment: 0.2,
                  );
                });
              },
              decoration: InputDecoration(
                hintText: "Any other details...",
                hintStyle: const TextStyle(fontFamily: "DMSans"),
                filled: true,
                fillColor: const Color(0xFFFFFBFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              style: const TextStyle(
                fontFamily: "DMSans",
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB56A7E),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  saveLog();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext builderContext) {
                      Future.delayed(const Duration(seconds: 1), () {
                        if (Navigator.of(builderContext).canPop()) {
                          Navigator.pop(context);
                          Navigator.of(builderContext).pop();
                        }
                      });
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        backgroundColor: const Color(0xFFFFFBFC),
                        title: const Text(
                          "Daily Log",
                          style: TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3A1F3D),
                          ),
                        ),
                        content: const Text(
                          "Log Saved!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text(
                  "Save Log",
                  style: TextStyle(
                    fontFamily: "DMSans",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleSelection(Set<String> set, String value) {
    set.contains(value) ? set.remove(value) : set.add(value);
  }

  String _formatDate(DateTime date) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}

class _SelectableBox extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;
  final double imageSize;
  final double fontSize;
  final double borderRadius;
  final double verticalPadding;
  final double iconLabelSpacing;

  const _SelectableBox({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.iconSize,
    required this.imageSize,
    required this.fontSize,
    required this.borderRadius,
    required this.verticalPadding,
    required this.iconLabelSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB56A7E) : const Color(0xFFF8EFF2),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: const Color(0xFFE8B7C3)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: verticalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon.startsWith("assets/")
                ? Image.asset(
              icon,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            )
                : Text(
              icon,
              style: TextStyle(fontSize: iconSize),
            ),
            SizedBox(height: iconLabelSpacing),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "DMSans",
                fontSize: fontSize,
                height: 1.1,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}