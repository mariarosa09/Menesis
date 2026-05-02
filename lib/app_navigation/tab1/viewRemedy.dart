import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Remedy Suggestions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F3F5),
        fontFamily: 'DMSans',
      ),
      home: const RemedySuggestionsScreen(),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  DATA MODEL
//  Defines the structure of a single remedy entry.
//  Each remedy has a title and a short description (2–3 sentences).
// ══════════════════════════════════════════════════════════════════

class Remedy {
  final String title;
  final String description;
  const Remedy({required this.title, required this.description});
}

// ══════════════════════════════════════════════════════════════════
//  ICON MAP
//  Maps each symptom/mood/discharge label to its display icon.
//  Emoji strings are shown inline; asset paths starting with
//  'assets/' are loaded as images via Image.asset().
// ══════════════════════════════════════════════════════════════════

const Map<String, String> _iconMap = {
  // Mood icons
  'Mood Swing' : '🔄',
  'Irritable'  : '😠',
  'Sad'        : '😢',
  'Anxious'    : '😰',
  'Confident'  : '😎',
  'Happy'      : '😊',
  'Impatient'  : '😤',
  'Inspired'   : '✨',
  // Physical symptom icons
  'Cramps'           : '🤕',
  'Headaches'        : '🤯',
  'Nausea'           : '🤢',
  'Bloating'         : '😖',
  'Breast Tenderness': '💢',
  'Breakouts'        : '😬',
  'Cravings'         : '🍫',
  'Stress'           : '😫',
  'Constipation'     : '🚫',
  'Diarrhea'         : '💩',
  // Discharge icons — using local asset images
  'Pink Discharge'              : 'assets/images/pink.png',
  'Clear/Transparent Discharge' : 'assets/images/clear.png',
  'Milky White Discharge'       : 'assets/images/milky_white.png',
  'Gray Discharge'              : 'assets/images/gray.png',
  'Bright Yellow Discharge'     : 'assets/images/bright_yellow.png',
  'Green Discharge'             : 'assets/images/green.png',
  'Red Discharge'               : 'assets/images/red.png',
  'Brown Discharge'             : 'assets/images/brown.png',
  'Watery Discharge'            : 'assets/images/watery.png',
};

// ══════════════════════════════════════════════════════════════════
//  REMEDY DATABASE
//  Static local map of remedies keyed by symptom/mood/discharge.
//  Each entry holds a list of Remedy objects to display as cards.
//
//  TODO: Palitan ito ng real database fetch (e.g., Firestore o REST API)
//  para dynamic ang mga remedy na lalabas depende sa logged symptoms.
//  The code should be placed here
// ══════════════════════════════════════════════════════════════════

const Map<String, List<Remedy>> remedyDatabase = {

  // ── MOODS ──────────────────────────────────────────────────────
  'Mood Swing': [
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Aim for 7–9 hours of quality sleep. Hormonal fluctuations that cause mood swings are often worsened by fatigue — consistent rest helps stabilise your emotional responses.',
    ),
    Remedy(
      title: 'Practice Deep Breathing',
      description:
      'Try box breathing (inhale 4s, hold 4s, exhale 4s, hold 4s). Slow, controlled breathing activates the parasympathetic nervous system, helping to smooth out sudden emotional shifts.',
    ),
    Remedy(
      title: 'Communicate',
      description:
      'Let people around you know how you are feeling. Expressing your emotions openly reduces internal tension and helps others offer the right support during mood changes.',
    ),
  ],

  'Anxious': [
    Remedy(
      title: 'Practice Deep Breathing',
      description:
      'Box breathing or 4-7-8 breathing can calm an anxious mind within minutes by slowing your heart rate and signalling safety to your nervous system.',
    ),
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Anxiety and poor sleep feed each other. Prioritise a consistent sleep schedule and a wind-down routine to reduce the baseline level of anxiety throughout the day.',
    ),
    Remedy(
      title: 'Communicate',
      description:
      'Talking through your worries with someone you trust can help you gain perspective and feel less alone. Even journalling your thoughts can provide significant relief.',
    ),
  ],

  'Sad': [
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Low mood and sadness are often deepened by poor sleep. Create a calming bedtime routine — dim lights, no screens 30 minutes before bed — to improve sleep quality.',
    ),
    Remedy(
      title: 'Communicate',
      description:
      'Reach out to a trusted friend, family member, or counsellor. Sharing how you feel breaks the cycle of isolation that often makes sadness feel heavier than it is.',
    ),
    Remedy(
      title: 'Get Sunlight Exposure',
      description:
      'Spend at least 15–20 minutes outdoors in natural light each day. Sunlight boosts serotonin production, which is directly linked to mood regulation and a sense of wellbeing.',
    ),
  ],

  // ── PHYSICAL SYMPTOMS ──────────────────────────────────────────
  'Cramps': [
    Remedy(
      title: 'Use Warm or Cold Compress',
      description:
      'Apply a warm heating pad or hot water bottle to your lower abdomen for 15–20 minutes. Heat relaxes uterine muscles and increases blood flow, reducing cramping pain.',
    ),
    Remedy(
      title: 'Take Mild Pain Relievers',
      description:
      'Over-the-counter anti-inflammatories such as ibuprofen can reduce prostaglandins — the compounds responsible for uterine cramping. Always follow the recommended dosage.',
    ),
    Remedy(
      title: 'Stay Physically Active with Light Exercise',
      description:
      'Gentle movement like walking or yoga stimulates blood flow and releases endorphins that act as natural pain relievers, helping to ease the severity of cramps.',
    ),
  ],

  'Headaches': [
    Remedy(
      title: 'Take Mild Pain Relievers',
      description:
      'Ibuprofen or paracetamol can effectively relieve hormonal headaches when taken at the onset of symptoms. Follow the recommended dose and avoid overuse.',
    ),
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Fatigue is a major headache trigger. Resting in a quiet, dark room at the first sign of a headache can significantly reduce its severity and duration.',
    ),
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Dehydration is one of the most common causes of headaches. Aim for at least 8 glasses of water daily and increase intake during your period when the body loses more fluid.',
    ),
  ],

  'Bloating': [
    Remedy(
      title: 'Eat High-Fiber Foods',
      description:
      'Foods like oats, leafy greens, and legumes support digestive regularity and help reduce the gas build-up that causes bloating. Introduce fibre gradually to avoid discomfort.',
    ),
    Remedy(
      title: 'Reduce Salty, Sugary, and Greasy Foods',
      description:
      'Salt causes water retention, sugar feeds gas-producing gut bacteria, and greasy foods slow digestion — all of which worsen bloating. Cutting back provides noticeable relief.',
    ),
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Drinking plenty of water helps flush out excess sodium and supports healthy digestion, both of which directly reduce bloating and abdominal discomfort.',
    ),
  ],

  // ── DISCHARGE ──────────────────────────────────────────────────
  'Pink Discharge': [
    Remedy(
      title: 'Monitor Changes in Your Body',
      description:
      'Pink discharge can indicate light spotting, which may be normal around ovulation or implantation. Track when it occurs in your cycle and note any accompanying symptoms.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Keep the area clean and dry. Use unscented liners if needed and change them regularly. Avoid irritants like scented soaps or synthetic fabrics close to the skin.',
    ),
  ],

  'Milky White Discharge': [
    Remedy(
      title: 'Monitor Changes in Your Body',
      description:
      'Milky white discharge is usually normal, especially around ovulation. Take note of any changes in smell, texture, or volume, and track them over a few cycle days.',
    ),
  ],

  'Bright Yellow Discharge': [
    Remedy(
      title: 'Monitor Changes in Your Body',
      description:
      'Pale or light yellow discharge can be normal. However, if the colour is vivid or accompanied by itching or odour, keep a close record and consider seeking advice.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Keep the vaginal area clean using water or a mild, unscented wash. Wear breathable, cotton underwear and change them daily to reduce the risk of irritation or infection.',
    ),
  ],

  'Green Discharge': [
    Remedy(
      title: 'Consult a Doctor or Seek Medical Attention',
      description:
      'Green discharge is often a sign of bacterial or sexually transmitted infection. Do not delay — consult a healthcare provider as soon as possible for proper diagnosis and treatment.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'While awaiting medical care, maintain gentle hygiene practices. Avoid douching or using scented products, as these can disrupt the vaginal flora and worsen the condition.',
    ),
  ],

  'Gray Discharge': [
    Remedy(
      title: 'Consult a Doctor or Seek Medical Attention',
      description:
      'Grey discharge, particularly with a fishy odour, is a common sign of bacterial vaginosis. This requires medical treatment — see a healthcare provider promptly.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Use mild, fragrance-free hygiene products and wear breathable cotton underwear. Avoid tight clothing that traps moisture, which can worsen bacterial imbalance.',
    ),
  ],

  'Red Discharge': [
    Remedy(
      title: 'Consult a Doctor or Seek Medical Attention',
      description:
      'Red discharge outside of your expected period could indicate spotting, infection, or another condition requiring evaluation. Seek medical advice, especially if heavy or prolonged.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Change pads, tampons, or menstrual products regularly. Keep the area clean and dry, and avoid scented products that may cause further irritation.',
    ),
  ],

  'Brown Discharge': [
    Remedy(
      title: 'Monitor Changes in Your Body',
      description:
      'Brown discharge is usually old blood leaving the body and is often normal at the beginning or end of your period. Track its timing and consistency across cycles.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Change underwear and any sanitary products regularly. Keep the area clean with warm water, and consult a doctor if brown discharge occurs frequently outside your period.',
    ),
  ],
};

// ══════════════════════════════════════════════════════════════════
//  HARDCODED SAMPLE SELECTIONS
//  Temporary placeholder data simulating what was logged today.
//
//  TODO: Palitan ito ng actual na data na galing sa daily log ng user
//  (e.g., passed via constructor, provider, o retrieved from local DB).
//  Dapat ang displayed symptoms at filters ay yung logged lang talaga.
//  The code should be placed here
// ══════════════════════════════════════════════════════════════════

const Set<String> _sampleMoods     = {'Mood Swing', 'Anxious', 'Sad'};
const Set<String> _sampleSymptoms  = {'Cramps', 'Headaches', 'Bloating'};
const Set<String> _sampleDischarge = {'Pink Discharge'};

// ══════════════════════════════════════════════════════════════════
//  SCREEN WIDGET
//  Root stateful widget for the Remedy Suggestions screen.
//  Uses a TabController to manage the filter tabs and a separate
//  ScrollController for the remedy list and the tab row.
// ══════════════════════════════════════════════════════════════════

class RemedySuggestionsScreen extends StatefulWidget {
  const RemedySuggestionsScreen({super.key});

  @override
  State<RemedySuggestionsScreen> createState() =>
      _RemedySuggestionsScreenState();
}

class _RemedySuggestionsScreenState extends State<RemedySuggestionsScreen>
    with SingleTickerProviderStateMixin {

  // Controllers for tab switching, main list scroll, and horizontal tab scroll
  late final TabController _tabController;
  late final List<String> _tabs;
  final ScrollController _scrollController    = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  // ── INIT ─────────────────────────────────────────────────────
  // Builds the tab list from all logged symptoms that exist in
  // the remedy database. "All" is always the first tab.
  @override
  void initState() {
    super.initState();

    // Collect only keys that have remedies in the database
    final allSelected = [
      ..._sampleMoods,
      ..._sampleSymptoms,
      ..._sampleDischarge,
    ].where((key) => remedyDatabase.containsKey(key)).toList();

    // "All" tab + one tab per logged symptom that has remedies
    _tabs = ['All', ...allSelected];

    // Rebuild UI whenever the active tab changes
    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() => setState(() {}));
  }

  // ── DISPOSE ──────────────────────────────────────────────────
  // Always dispose controllers to prevent memory leaks.
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  FILTER LOGIC
  //  Returns the list of remedy items to display based on the
  //  currently selected tab. On "All", deduplicates remedies by
  //  title so the same remedy doesn't appear twice.
  // ══════════════════════════════════════════════════════════════
  List<({String symptom, Remedy remedy})> get _filtered {
    final tab = _tabs[_tabController.index];

    // "All" tab: gather every remedy across logged symptoms, skip duplicates
    if (tab == 'All') {
      final seen   = <String>{};
      final result = <({String symptom, Remedy remedy})>[];
      for (final key in _tabs.skip(1)) {
        for (final r in remedyDatabase[key] ?? []) {
          if (seen.add(r.title)) result.add((symptom: key, remedy: r));
        }
      }
      return result;
    }

    // Single-symptom tab: return all remedies for that symptom
    return [
      for (final r in remedyDatabase[tab] ?? [])
        (symptom: tab, remedy: r),
    ];
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  //  Sets status bar style and assembles the main screen layout:
  //  header → chips → tab bar → scrollable remedy list.
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // Make the status bar transparent with dark icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F5),
      body: Container(
        // Subtle gradient background from top to bottom
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F3F5), Color(0xFFF1E6EA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildLoggedChips(),
              const SizedBox(height: 20),
              _buildTabBar(),
              const SizedBox(height: 6),
              Expanded(child: _buildRemedyList()),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HEADER SECTION
  //  Displays the screen title and subtitle at the top.
  // ══════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen title using serif display font
          RichText(
            text: const TextSpan(
              text: 'Remedy Suggestions',
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A1F3D),
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Subtitle explaining the context of suggestions
          const Text(
            'Based on your logged symptoms',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              color: Color(0x73000000),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LOGGED SYMPTOM CHIPS
  //  Shows a horizontal Wrap of pill-shaped chips for each item
  //  the user logged today (moods + symptoms + discharge).
  //  Only logged items are shown here — no hardcoded extras.
  //
  //  TODO: I-connect ito sa actual na logged data ng user para
  //  dynamic ang chips na lalabas. Dapat same source ng data
  //  ang chips at ang filter tabs.
  //  The code should be placed here
  // ══════════════════════════════════════════════════════════════
  Widget _buildLoggedChips() {
    // Merge all logged categories into one flat list for display
    final all = [
      ..._sampleMoods,
      ..._sampleSymptoms,
      ..._sampleDischarge,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          const Text(
            'YOUR SYMPTOMS TODAY',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0x73000000),
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 10),

          // Wrapping chips — each chip shows an icon + label
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: all.map((label) {
              final icon    = _iconMap[label];
              final isAsset = icon != null && icon.startsWith('assets/');

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8FC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8B7C3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB56A7E).withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show icon if available — asset image or emoji
                    if (icon != null) ...[
                      isAsset
                          ? Image.asset(icon, width: 16, height: 16)
                          : Text(icon, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB56A7E),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  TAB BAR (FILTER ROW)
  //  Horizontally scrollable row of filter pills.
  //  Active tab is highlighted in rose; inactive tabs are outlined.
  //  Tapping a tab switches the remedy list content.
  //
  //  TODO: Kung magdadagdag ng bagong symptom categories sa database,
  //  i-update ang _iconMap para may tamang icon ang bawat tab.
  //  The code should be placed here
  // ══════════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "FILTER BY" label above the scrollable tabs
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'FILTER BY',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0x73000000),
              letterSpacing: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Horizontally scrollable list of filter tab pills
        SizedBox(
          height: 42,
          child: ListView.builder(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: _tabs.length,
            itemBuilder: (ctx, i) {
              final selected = _tabController.index == i;
              final label    = _tabs[i];
              final icon     = _iconMap[label];
              final isAsset  = icon != null && icon.startsWith('assets/');

              return GestureDetector(
                onTap: () => _tabController.animateTo(i),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      // Active tab uses solid rose; inactive uses light fill
                      color: selected
                          ? const Color(0xFFB56A7E)
                          : const Color(0xFFF8EFF2),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : const Color(0xFFE8B7C3),
                        width: 1,
                      ),
                      // Glow shadow only on selected tab
                      boxShadow: selected
                          ? [
                        BoxShadow(
                          color: const Color(0xFFB56A7E).withOpacity(0.40),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Show icon only for symptom-specific tabs (not "All")
                        if (icon != null && label != 'All') ...[
                          isAsset
                              ? Image.asset(icon, width: 16, height: 16)
                              : Text(icon,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                        ],
                        // Animated text color transition on selection
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 240),
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : const Color(0xFFB56A7E),
                          ),
                          child: Text(label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Thin divider below the tab row for visual separation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Divider(
            color: const Color(0xFFE8B7C3).withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  REMEDY LIST
  //  Scrollable list of remedy cards filtered by the active tab.
  //  Shows an empty state if no remedies match the current filter.
  //  Includes a themed scrollbar for visual polish.
  // ══════════════════════════════════════════════════════════════
  Widget _buildRemedyList() {
    final list = _filtered;

    // Empty state — shown when there are no remedies for the selected tab
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🌸', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text(
              'No remedies for this selection',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                color: Color(0x73000000),
              ),
            ),
          ],
        ),
      );
    }

    // Scrollbar styled to match the app's rose color palette
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
            const Color(0xFFB56A7E).withOpacity(0.55)),
        trackColor: WidgetStateProperty.all(
            const Color(0xFFE8B7C3).withOpacity(0.25)),
        trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.dragged) ? 6.0 : 4.0),
        radius: const Radius.circular(8),
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(true),
        interactive: true,
      ),
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (ctx, i) => _buildRemedyCard(list[i]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  REMEDY CARD
  //  Individual card widget showing a symptom icon, remedy title,
  //  short description (2–3 sentences, no expand/collapse needed),
  //  and a small symptom tag at the bottom.
  //
  //  TODO: Kung kailangan ng "Read More" feature in the future,
  //  dito sa card idagdag ang toggle logic para ma-expand ang
  //  description. Sa ngayon, 2–3 sentences lang ang nilalaman.
  //  The code should be placed here
  // ══════════════════════════════════════════════════════════════
  Widget _buildRemedyCard(({String symptom, Remedy remedy}) item) {
    final icon    = _iconMap[item.symptom];
    final isAsset = icon != null && icon.startsWith('assets/');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8B7C3).withOpacity(0.45),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Icon box ─────────────────────────────────────────
            // Rounded square with the symptom icon inside.
            // Falls back to remedy_icon.png if no icon is mapped.
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF8EFF2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: icon == null
                    ? Image.asset(
                  'assets/images/remedy_icon.png',
                  width: 32,
                  height: 32,
                )
                    : isAsset
                    ? Image.asset(icon, width: 32, height: 32)
                    : Text(icon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),

            // ── Text content ─────────────────────────────────────
            // Title, short description, and symptom tag.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Remedy title
                  Text(
                    item.remedy.title,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF44222B),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Short description — 2–3 sentences, no expand/collapse
                  Text(
                    item.remedy.description,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      color: Color(0x73000000),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Symptom tag pill at the bottom of the card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB56A7E).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.symptom,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB56A7E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}