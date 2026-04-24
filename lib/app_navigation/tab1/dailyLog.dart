import 'package:flutter/material.dart';

class dailyLog extends StatefulWidget {
  final DateTime selectedDate;

  const dailyLog({super.key, required this.selectedDate});

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

  final List<Map<String, String>> dischargeTypes = [
    {"label": "Clear/Transparent", "icon": "assets/images/clear.png"},
    {"label": "Milky White", "icon": "assets/images/milky_white.png"},
    {"label": "Gray", "icon": "assets/images/gray.png"},
    {"label": "Bright Yellow", "icon": "assets/images/bright_yellow.png"},
    {"label": "Green", "icon": "assets/images/green.png"},
    {"label": "Pink", "icon": "assets/images/pink.png"},
    {"label": "Red", "icon": "assets/images/red.png"},
    {"label": "Brown", "icon": "assets/images/brown.png"},
    {"label": "Watery", "icon": "assets/images/watery.png"},
  ];

  final Set<String> selectedMoods = {};
  final Set<String> selectedSymptoms = {};
  final Set<String> selectedDischarge = {};

  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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

          TextField(
            controller: notesController,
            maxLines: 3,
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Log Saved!")),
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
    );
  }

  void toggleSelection(Set<String> set, String value) {
    set.contains(value) ? set.remove(value) : set.add(value);
  }

  String _formatDate(DateTime date) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
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