import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// DailyLog StatefulWidget
// This is the main widget for the Daily Log screen.
// It accepts a [selectedDate] so it knows which day the user is logging for.
// Follows Dart's PascalCase naming convention for classes.
// ─────────────────────────────────────────────
class DailyLog extends StatefulWidget {
  final DateTime selectedDate;

  const DailyLog({super.key, required this.selectedDate});

  @override
  State<DailyLog> createState() => _DailyLogState();
}

class _DailyLogState extends State<DailyLog> {

  // ─────────────────────────────────────────────
  // Static Data Lists
  // These are the fixed options shown to the user for moods, symptoms, and discharge types.
  // Each item is a Map with a "label" (display text) and an "icon" (emoji or image asset path).
  // Declared as `final` because they never change at runtime.
  // ─────────────────────────────────────────────
  final List<Map<String, String>> moods = [
    {"label": "Mood Swing", "icon": "🔄"},
    {"label": "Irritable",  "icon": "😠"},
    {"label": "Sad",        "icon": "😢"},
    {"label": "Anxious",    "icon": "😰"},
    {"label": "Confident",  "icon": "😎"},
    {"label": "Happy",      "icon": "😊"},
    {"label": "Impatient",  "icon": "😤"},
    {"label": "Inspired",   "icon": "✨"},
  ];

  final List<Map<String, String>> symptoms = [
    {"label": "Cramps",            "icon": "🤕"},
    {"label": "Headaches",         "icon": "🤯"},
    {"label": "Nausea",            "icon": "🤢"},
    {"label": "Bloating",          "icon": "😖"},
    {"label": "Breast Tenderness", "icon": "💢"},
    {"label": "Breakouts",         "icon": "😬"},
    {"label": "Cravings",          "icon": "🍫"},
    {"label": "Stress",            "icon": "😫"},
    {"label": "Constipation",      "icon": "🚫"},
    {"label": "Diarrhea",          "icon": "💩"},
  ];

  final List<Map<String, String>> dischargeTypes = [
    {"label": "Clear/Transparent", "icon": "assets/images/clear.png"},
    {"label": "Milky White",       "icon": "assets/images/milky_white.png"},
    {"label": "Gray",              "icon": "assets/images/gray.png"},
    {"label": "Bright Yellow",     "icon": "assets/images/bright_yellow.png"},
    {"label": "Green",             "icon": "assets/images/green.png"},
    {"label": "Pink",              "icon": "assets/images/pink.png"},
    {"label": "Red",               "icon": "assets/images/red.png"},
    {"label": "Brown",             "icon": "assets/images/brown.png"},
    {"label": "Watery",            "icon": "assets/images/watery.png"},
  ];

  // ─────────────────────────────────────────────
  // Selection State Sets
  // These Sets track which items the user has tapped/selected.
  // A Set is used here so duplicate selections are automatically prevented.
  // Each section (moods, symptoms, discharge) has its own Set.
  // ─────────────────────────────────────────────
  final Set<String> selectedMoods     = {};
  final Set<String> selectedSymptoms  = {};
  final Set<String> selectedDischarge = {};

  // ─────────────────────────────────────────────
  // Notes Text Controller
  // Controls the optional free-text notes field at the bottom of the screen.
  // Must be disposed in [dispose()] to prevent memory leaks.
  // ─────────────────────────────────────────────
  final TextEditingController notesController = TextEditingController();

  // ─────────────────────────────────────────────
  // dispose()
  // Called automatically when this widget is removed from the widget tree.
  // Cleans up the TextEditingController to free memory properly.
  // ─────────────────────────────────────────────
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

          // ─────────────────────────────────────────────
          // Header Section
          // Displays the screen title "Daily Log" and the selected date below it.
          // The date is formatted using [_formatDate()] for readability.
          // ─────────────────────────────────────────────
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

          // ─────────────────────────────────────────────
          // Physical Symptoms Section
          // The first 2 symptoms are shown as wide, prominent tiles in a Row.
          // The remaining symptoms (index 2 onward) are shown in a compact 4-column grid.
          // This layout highlights the most common symptoms and keeps the rest organized.
          // ─────────────────────────────────────────────
          const Text(
            "PHYSICAL SYMPTOMS",
            style: TextStyle(fontFamily: "DMSans", fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),

          Column(
            children: [
              // First 2 symptoms as wide, full-row tiles
              Row(
                children: symptoms.take(2).map((symptom) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: _SelectableBox(
                        label: symptom["label"]!,
                        icon: symptom["icon"]!,
                        isSelected: selectedSymptoms.contains(symptom["label"]),
                        onTap: () => setState(() =>
                            _toggleSelection(selectedSymptoms, symptom["label"]!)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Remaining symptoms (index 2+) in a 4-column grid
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: symptoms.skip(2).map((symptom) {
                  return _SelectableBox(
                    label: symptom["label"]!,
                    icon: symptom["icon"]!,
                    isSelected: selectedSymptoms.contains(symptom["label"]),
                    onTap: () => setState(() =>
                        _toggleSelection(selectedSymptoms, symptom["label"]!)),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─────────────────────────────────────────────
          // Mood Section
          // Displays all mood options in a uniform 4-column grid.
          // Tapping a mood toggles its selection state.
          // ─────────────────────────────────────────────
          const Text(
            "MOOD",
            style: TextStyle(fontFamily: "DMSans", fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: moods.map((mood) {
              return _SelectableBox(
                label: mood["label"]!,
                icon: mood["icon"]!,
                isSelected: selectedMoods.contains(mood["label"]),
                onTap: () => setState(() =>
                    _toggleSelection(selectedMoods, mood["label"]!)),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ─────────────────────────────────────────────
          // Discharge Section
          // Displays all discharge type options in a 3-column grid.
          // Uses image assets (not emojis) as icons for more accurate visual representation.
          // ─────────────────────────────────────────────
          const Text(
            "DISCHARGE",
            style: TextStyle(fontFamily: "DMSans", fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: dischargeTypes.map((type) {
              return _SelectableBox(
                label: type["label"]!,
                icon: type["icon"]!,
                isSelected: selectedDischarge.contains(type["label"]),
                onTap: () => setState(() =>
                    _toggleSelection(selectedDischarge, type["label"]!)),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ─────────────────────────────────────────────
          // Notes Section
          // An optional multi-line text field for any extra details the user wants to add.
          // Controlled by [notesController] so the input value can be read on save.
          // ─────────────────────────────────────────────
          const Text(
            "NOTES (OPTIONAL)",
            style: TextStyle(fontFamily: "DMSans", fontSize: 12, color: Colors.black54),
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
            ),
            style: const TextStyle(fontFamily: "DMSans", fontSize: 13),
          ),

          const SizedBox(height: 30),

          // ─────────────────────────────────────────────
          // Save Button
          // Full-width button that triggers [_saveLog()] when tapped.
          // Styled with the app's primary pink color and rounded corners.
          // ─────────────────────────────────────────────
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
              onPressed: _saveLog,
              child: const Text(
                "Save Log",
                style: TextStyle(fontFamily: "DMSans", color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // _saveLog()
  // Handles all logic when the user taps the "Save Log" button.
  // Currently navigates back and shows a confirmation snackbar.
  // Database saving logic for the log entry and notes should be added here via the TODOs below.
  // ─────────────────────────────────────────────
  void _saveLog() {
    // TODO: ADDING — I-save ang log entry sa database bago mag-navigate pabalik.
    // Gamitin ang `selectedMoods`, `selectedSymptoms`, `selectedDischarge`,
    // at `widget.selectedDate` bilang data na ise-save.
    // The code should be placed here

    // TODO: ADDING — Kung may laman ang `notesController.text` (hindi blank/empty),
    // i-save din ito sa database kasama ng log entry para sa tamang date.
    // The code should be placed here

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Log Saved!")),
    );
  }

  // ─────────────────────────────────────────────
  // _toggleSelection()
  // A helper method that adds or removes a value from a given Set.
  // If the value is already in the Set, it gets removed (deselected).
  // If it's not yet there, it gets added (selected).
  // Renamed with underscore prefix (_) to follow Dart's private method convention.
  // ─────────────────────────────────────────────
  void _toggleSelection(Set<String> set, String value) {
    set.contains(value) ? set.remove(value) : set.add(value);
  }

  // ─────────────────────────────────────────────
  // _formatDate()
  // Converts a DateTime object into a human-readable string like "April 19, 2026".
  // Used in the header section to display the currently selected log date.
  // ─────────────────────────────────────────────
  String _formatDate(DateTime date) {
    const months = [
      "January", "February", "March",     "April",
      "May",      "June",     "July",      "August",
      "September","October",  "November",  "December"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}


// ─────────────────────────────────────────────
// _SelectableBox (Private Reusable Widget)
// A tappable card that displays an icon (emoji or image) and a label below it.
// Changes its appearance based on whether it is selected or not:
//   - Selected  → pink background (#B56A7E), white label
//   - Unselected → light pink background (#F8EFF2), black label
// Used across all three sections: Symptoms, Mood, and Discharge.
// ─────────────────────────────────────────────
class _SelectableBox extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableBox({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB56A7E) : const Color(0xFFF8EFF2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE8B7C3)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ─────────────────────────────────────────────
            // Icon Display
            // Checks if the icon string points to an asset file (starts with "assets/").
            // If yes → renders it as an Image widget.
            // If no  → renders it as an emoji Text widget.
            // This makes the widget flexible for both emoji and image-based icons.
            // ─────────────────────────────────────────────
            icon.startsWith("assets/")
                ? Image.asset(icon, width: 35, height: 35)
                : Text(icon, style: const TextStyle(fontSize: 20)),

            const SizedBox(height: 5),

            // ─────────────────────────────────────────────
            // Label Text
            // Displays the item name below the icon.
            // Color switches to white when selected, black when not.
            // Text is centered and sized small to fit within compact grid tiles.
            // ─────────────────────────────────────────────
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "DMSans",
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}