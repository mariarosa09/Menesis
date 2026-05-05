import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// DATA MODEL — Remedy
// ─────────────────────────────────────────────
class Remedy {
  final String title;
  final String description;
  const Remedy({required this.title, required this.description});
}

// ────────────────────────────────────────────
// ICON MAP
// Keys must match EXACTLY what dailyLog.dart saves to Firestore.
// Maps each symptom/discharge label to either:
//   - An emoji string (e.g., '🔄'), OR
//   - A local asset path (e.g., 'assets/images/pink.png')
// ─────────────────────────────────────────────
const Map<String, String> _iconMap = {
  // MOOD
  'Mood Swing' : '🔄',
  'Irritable'  : '😠',
  'Sad'        : '😢',
  'Anxious'    : '😰',
  'Confident'  : '😎',
  'Happy'      : '😊',
  'Impatient'  : '😤',
  'Inspired'   : '✨',

  // PHYSICAL SYMPTOMS
  'Cramps'            : '🤕',
  'Headaches'         : '🤯',
  'Nausea'            : '🤢',
  'Bloating'          : '😖',
  'Breast Tenderness' : '💢',
  'Breakouts'         : '😬',
  'Cravings'          : '🍫',
  'Stress'            : '😫',
  'Constipation'      : '🚫',
  'Diarrhea'          : '💩',

  // DISCHARGE — keys match dailyLog.dart labels exactly
  'Pink'              : 'assets/images/discharge_icon/pink.png',
  'Clear/Transparent' : 'assets/images/discharge_icon/clear.png',
  'Milky White'       : 'assets/images/discharge_icon/milky_white.png',
  'Gray'              : 'assets/images/discharge_icon/gray.png',
  'Bright Yellow'     : 'assets/images/discharge_icon/bright_yellow.png',
  'Green'             : 'assets/images/discharge_icon/green.png',
  'Red'               : 'assets/images/discharge_icon/red.png',
  'Brown'             : 'assets/images/discharge_icon/brown.png',
  'Watery'            : 'assets/images/discharge_icon/watery.png',
};

// ─────────────────────────────────────────────
// REMEDY ICON MAP
// Maps each remedy title to a local asset image.
// ─────────────────────────────────────────────
const Map<String, String> _remedyIconMap = {
  'Get Enough Rest and Sleep'                         : 'assets/images/remedy_icon/Get_Enough_Rest_And_Sleep.png',
  'Stay Physically Active with Light Exercise'        : 'assets/images/remedy_icon/Light_Exercise.png',
  'Practice Deep Breathing'                           : 'assets/images/remedy_icon/Practice_Deep_Breathing.png',
  'Stay Hydrated'                                     : 'assets/images/remedy_icon/Stay_Hydrated.png',
  'Eat Healthy, Balanced Meals'                       : 'assets/images/remedy_icon/Eat_Healthy_Balanced_Meals.png',
  'Limit Caffeine Intake'                             : 'assets/images/remedy_icon/Limit_Caffeine_Intake.png',
  'Communicate'                                       : 'assets/images/remedy_icon/Communicate.png',
  'Get Sunlight Exposure'                             : 'assets/images/remedy_icon/Get_Sunlight_Exposure.png',
  'Use Warm or Cold Compress'                         : 'assets/images/remedy_icon/Use_Warm_Or_Cold_Compress.png',
  'Take Mild Pain Relievers'                          : 'assets/images/remedy_icon/Pain_Reliever.png',
  'Wear a Comfortable Bra'                            : 'assets/images/remedy_icon/Wear_A_Comfortable_Bra.png',
  'Maintain Proper Skincare and Avoid Touching Your Face' : 'assets/images/remedy_icon/Maintain_Proper_Skincare.png',
  'Maintain Proper Hygiene'                           : 'assets/images/remedy_icon/Maintain_Proper_Hygiene.png',
  'Monitor Changes in Your Body'                      : 'assets/images/remedy_icon/Monitor_Changes_In_Your_Body.png',
  'Consult a Doctor or Seek Medical Attention'        : 'assets/images/remedy_icon/Consult_Doctor.png',
  'Eat High-Fiber Foods'                              : 'assets/images/remedy_icon/Eat_High_Fiber_Foods.png',
  'Reduce Salty, Sugary, and Greasy Foods'            : 'assets/images/remedy_icon/Reduce_Greasy_Foods.png',
  'No Action Needed'                                  : 'assets/images/remedy_icon/No_Action_Needed.png',
};

// ─────────────────────────────────────────────
// REMEDY DATABASE
// ─────────────────────────────────────────────
const Map<String, List<Remedy>> remedyDatabase = {

  // ── MOOD ──────────────────────────────────────────────────────
  'Mood Swing': [
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Sleep for at least 7–9 hours each night to help your body recover and reduce fatigue. '
          'Take breaks during the day and avoid overworking yourself when feeling tired.',
    ),
    Remedy(
      title: 'Practice Deep Breathing',
      description:
      'Take slow, deep breaths for a few minutes when feeling stressed or emotional. '
          'This can help calm your mind and reduce tension.',
    ),
    Remedy(
      title: 'Communicate',
      description:
      'Talk to someone you trust about how you feel if symptoms are affecting your mood. '
          'Emotional support can help reduce stress and make you feel better.',
    ),
  ],

  'Irritable': [
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Sleep for at least 7–9 hours each night to help your body recover and reduce fatigue. '
          'Take breaks during the day and avoid overworking yourself when feeling tired.',
    ),
    Remedy(
      title: 'Practice Deep Breathing',
      description:
      'Take slow, deep breaths for a few minutes when feeling stressed or emotional. '
          'This can help calm your mind and reduce tension.',
    ),
    Remedy(
      title: 'Stay Physically Active with Light Exercise',
      description:
      'Do light activities like walking, stretching, or yoga to improve blood flow and reduce discomfort. '
          'Avoid intense exercise if your body feels weak or sore.',
    ),
    Remedy(
      title: 'Communicate',
      description:
      'Talk to someone you trust about how you feel if symptoms are affecting your mood. '
          'Emotional support can help reduce stress and make you feel better.',
    ),
  ],

  'Sad': [
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Sleep for at least 7–9 hours each night to help your body recover and reduce fatigue. '
          'Take breaks during the day and avoid overworking yourself when feeling tired.',
    ),
    Remedy(
      title: 'Communicate',
      description:
      'Talk to someone you trust about how you feel if symptoms are affecting your mood. '
          'Emotional support can help reduce stress and make you feel better.',
    ),
    Remedy(
      title: 'Get Sunlight Exposure',
      description:
      'Spend a little time outside each day for natural sunlight. '
          'Sunlight can improve mood and support overall well-being.',
    ),
  ],

  'Anxious': [
    Remedy(
      title: 'Practice Deep Breathing',
      description:
      'Take slow, deep breaths for a few minutes when feeling stressed or emotional. '
          'This can help calm your mind and reduce tension.',
    ),
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Sleep for at least 7–9 hours each night to help your body recover and reduce fatigue. '
          'Take breaks during the day and avoid overworking yourself when feeling tired.',
    ),
    Remedy(
      title: 'Communicate',
      description:
      'Talk to someone you trust about how you feel if symptoms are affecting your mood. '
          'Emotional support can help reduce stress and make you feel better.',
    ),
  ],

  'Confident': [
    Remedy(
      title: 'No Action Needed',
      description:
      'Some symptoms are mild and normal, requiring only observation. '
          'Continue daily activities while monitoring your body.',
    ),
  ],

  'Happy': [
    Remedy(
      title: 'No Action Needed',
      description:
      'Some symptoms are mild and normal, requiring only observation. '
          'Continue daily activities while monitoring your body.',
    ),
  ],

  'Impatient': [
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Sleep for at least 7–9 hours each night to help your body recover and reduce fatigue. '
          'Take breaks during the day and avoid overworking yourself when feeling tired.',
    ),
    Remedy(
      title: 'Practice Deep Breathing',
      description:
      'Take slow, deep breaths for a few minutes when feeling stressed or emotional. '
          'This can help calm your mind and reduce tension.',
    ),
  ],

  'Inspired': [
    Remedy(
      title: 'No Action Needed',
      description:
      'Some symptoms are mild and normal, requiring only observation. '
          'Continue daily activities while monitoring your body.',
    ),
  ],

  // ── PHYSICAL SYMPTOMS ─────────────────────────────────────────
  'Cramps': [
    Remedy(
      title: 'Use Warm or Cold Compress',
      description:
      'Apply a heating pad or warm towel to ease cramps and muscle pain. '
          'A cold compress may also help reduce swelling or discomfort.',
    ),
    Remedy(
      title: 'Take Mild Pain Relievers',
      description:
      'Use over-the-counter pain medicine if needed and as directed. '
          'This can help manage cramps, headaches, or body pain.',
    ),
    Remedy(
      title: 'Stay Physically Active with Light Exercise',
      description:
      'Do light activities like walking, stretching, or yoga to improve blood flow and reduce discomfort. '
          'Avoid intense exercise if your body feels weak or sore.',
    ),
  ],

  'Breast Tenderness': [
    Remedy(
      title: 'Wear a Comfortable Bra',
      description:
      'Choose a supportive but non-tight bra to reduce breast discomfort. '
          'Soft fabrics may feel more comfortable during tenderness.',
    ),
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Drink plenty of water throughout the day to prevent dehydration and bloating. '
          'Keep a water bottle nearby as a reminder.',
    ),
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Sleep for at least 7–9 hours each night to help your body recover and reduce fatigue. '
          'Take breaks during the day and avoid overworking yourself when feeling tired.',
    ),
  ],

  'Stress': [
    Remedy(
      title: 'Practice Deep Breathing',
      description:
      'Take slow, deep breaths for a few minutes when feeling stressed or emotional. '
          'This can help calm your mind and reduce tension.',
    ),
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Sleep for at least 7–9 hours each night to help your body recover and reduce fatigue. '
          'Take breaks during the day and avoid overworking yourself when feeling tired.',
    ),
    Remedy(
      title: 'Stay Physically Active with Light Exercise',
      description:
      'Do light activities like walking, stretching, or yoga to improve blood flow and reduce discomfort. '
          'Avoid intense exercise if your body feels weak or sore.',
    ),
    Remedy(
      title: 'Communicate',
      description:
      'Talk to someone you trust about how you feel if symptoms are affecting your mood. '
          'Emotional support can help reduce stress and make you feel better.',
    ),
  ],

  'Nausea': [
    Remedy(
      title: 'Eat Healthy, Balanced Meals',
      description:
      'Choose nutritious foods like fruits, vegetables, whole grains, and lean proteins. '
          'Eat gentle, easy-to-digest meals if your stomach feels sensitive.',
    ),
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Drink plenty of water throughout the day to prevent dehydration and bloating. '
          'Keep a water bottle nearby as a reminder.',
    ),
    Remedy(
      title: 'Limit Caffeine Intake',
      description:
      'Reduce coffee, energy drinks, and sugary sodas to help prevent anxiety, bloating, or breast tenderness. '
          'Choose water or herbal tea instead.',
    ),
  ],

  'Bloating': [
    Remedy(
      title: 'Eat High-Fiber Foods',
      description:
      'Include fruits, vegetables, and whole grains in your meals to support digestion. '
          'Fiber can help reduce bloating and constipation.',
    ),
    Remedy(
      title: 'Reduce Salty, Sugary, and Greasy Foods',
      description:
      'Cut back on processed snacks and unhealthy foods to lessen bloating and discomfort. '
          'Choose healthier alternatives when possible.',
    ),
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Drink plenty of water throughout the day to prevent dehydration and bloating. '
          'Keep a water bottle nearby as a reminder.',
    ),
  ],

  'Cravings': [
    Remedy(
      title: 'Eat Healthy, Balanced Meals',
      description:
      'Choose nutritious foods like fruits, vegetables, whole grains, and lean proteins. '
          'Eat gentle, easy-to-digest meals if your stomach feels sensitive.',
    ),
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Drink plenty of water throughout the day to prevent dehydration and bloating. '
          'Keep a water bottle nearby as a reminder.',
    ),
  ],

  'Breakouts': [
    Remedy(
      title: 'Maintain Proper Skincare and Avoid Touching Your Face',
      description:
      'Wash your face regularly with gentle products to reduce oil buildup. '
          'Avoid touching or picking at your skin to prevent irritation.',
    ),
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Drink plenty of water throughout the day to prevent dehydration and bloating. '
          'Keep a water bottle nearby as a reminder.',
    ),
  ],

  'Headaches': [
    Remedy(
      title: 'Take Mild Pain Relievers',
      description:
      'Use over-the-counter pain medicine if needed and as directed. '
          'This can help manage cramps, headaches, or body pain.',
    ),
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Sleep for at least 7–9 hours each night to help your body recover and reduce fatigue. '
          'Take breaks during the day and avoid overworking yourself when feeling tired.',
    ),
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Drink plenty of water throughout the day to prevent dehydration and bloating. '
          'Keep a water bottle nearby as a reminder.',
    ),
  ],

  'Constipation': [
    Remedy(
      title: 'Eat High-Fiber Foods',
      description:
      'Include fruits, vegetables, and whole grains in your meals to support digestion. '
          'Fiber can help reduce bloating and constipation.',
    ),
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Drink plenty of water throughout the day to prevent dehydration and bloating. '
          'Keep a water bottle nearby as a reminder.',
    ),
  ],

  'Diarrhea': [
    Remedy(
      title: 'Eat High-Fiber Foods',
      description:
      'Include gentle, easy-to-digest fiber sources like bananas, rice, and plain toast to help firm up stools. '
          'Avoid high-fat or heavily spiced foods until symptoms subside.',
    ),
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Drink plenty of water throughout the day to prevent dehydration and bloating. '
          'Keep a water bottle nearby as a reminder.',
    ),
  ],

  // ── DISCHARGE ─────────────────────────────────────────────────
  'Clear/Transparent': [
    Remedy(
      title: 'No Action Needed',
      description:
      'Some symptoms are mild and normal, requiring only observation. '
          'Continue daily activities while monitoring your body.',
    ),
  ],

  'Milky White': [
    Remedy(
      title: 'Monitor Changes in Your Body',
      description:
      'Pay attention to unusual symptoms, pain, or changes in discharge. '
          'Tracking symptoms can help you better understand your cycle.',
    ),
  ],

  'Bright Yellow': [
    Remedy(
      title: 'Monitor Changes in Your Body',
      description:
      'Pay attention to unusual symptoms, pain, or changes in discharge. '
          'Tracking symptoms can help you better understand your cycle.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Change menstrual products regularly and keep your body clean to prevent irritation or infection. '
          'Wear clean, breathable clothing.',
    ),
  ],

  'Green': [
    Remedy(
      title: 'Consult a Doctor or Seek Medical Attention',
      description:
      'See a healthcare professional if symptoms are severe, unusual, or do not improve. '
          'Medical advice is important for persistent concerns.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Change menstrual products regularly and keep your body clean to prevent irritation or infection. '
          'Wear clean, breathable clothing.',
    ),
  ],

  'Gray': [
    Remedy(
      title: 'Consult a Doctor or Seek Medical Attention',
      description:
      'See a healthcare professional if symptoms are severe, unusual, or do not improve. '
          'Medical advice is important for persistent concerns.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Change menstrual products regularly and keep your body clean to prevent irritation or infection. '
          'Wear clean, breathable clothing.',
    ),
  ],

  'Pink': [
    Remedy(
      title: 'Monitor Changes in Your Body',
      description:
      'Pay attention to unusual symptoms, pain, or changes in discharge. '
          'Tracking symptoms can help you better understand your cycle.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Change menstrual products regularly and keep your body clean to prevent irritation or infection. '
          'Wear clean, breathable clothing.',
    ),
  ],

  'Red': [
    Remedy(
      title: 'Consult a Doctor or Seek Medical Attention',
      description:
      'See a healthcare professional if symptoms are severe, unusual, or do not improve. '
          'Medical advice is important for persistent concerns.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Change menstrual products regularly and keep your body clean to prevent irritation or infection. '
          'Wear clean, breathable clothing.',
    ),
  ],

  'Brown': [
    Remedy(
      title: 'Monitor Changes in Your Body',
      description:
      'Pay attention to unusual symptoms, pain, or changes in discharge. '
          'Tracking symptoms can help you better understand your cycle.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Change menstrual products regularly and keep your body clean to prevent irritation or infection. '
          'Wear clean, breathable clothing.',
    ),
  ],

  'Watery': [
    Remedy(
      title: 'Stay Hydrated',
      description:
      'Drink plenty of water throughout the day to prevent dehydration and bloating. '
          'Keep a water bottle nearby as a reminder.',
    ),
    Remedy(
      title: 'Maintain Proper Hygiene',
      description:
      'Change menstrual products regularly and keep your body clean to prevent irritation or infection. '
          'Wear clean, breathable clothing.',
    ),
    Remedy(
      title: 'Monitor Changes in Your Body',
      description:
      'Pay attention to unusual symptoms, pain, or changes in discharge. '
          'Tracking symptoms can help you better understand your cycle.',
    ),
    Remedy(
      title: 'Eat Healthy, Balanced Meals',
      description:
      'Choose nutritious foods like fruits, vegetables, whole grains, and lean proteins. '
          'Eat gentle, easy-to-digest meals if your stomach feels sensitive.',
    ),
    Remedy(
      title: 'Get Enough Rest and Sleep',
      description:
      'Sleep for at least 7–9 hours each night to help your body recover and reduce fatigue. '
          'Take breaks during the day and avoid overworking yourself when feeling tired.',
    ),
    Remedy(
      title: 'Stay Physically Active with Light Exercise',
      description:
      'Do light activities like walking, stretching, or yoga to improve blood flow and reduce discomfort. '
          'Avoid intense exercise if your body feels weak or sore.',
    ),
    Remedy(
      title: 'Limit Caffeine Intake',
      description:
      'Reduce coffee, energy drinks, and sugary sodas to help prevent anxiety, bloating, or breast tenderness. '
          'Choose water or herbal tea instead.',
    ),
    Remedy(
      title: 'Reduce Salty, Sugary, and Greasy Foods',
      description:
      'Cut back on processed snacks and unhealthy foods to lessen bloating and discomfort. '
          'Choose healthier alternatives when possible.',
    ),
    Remedy(
      title: 'Communicate',
      description:
      'Talk to someone you trust about how you feel if symptoms are affecting your mood. '
          'Emotional support can help reduce stress and make you feel better.',
    ),
    Remedy(
      title: 'No Action Needed',
      description:
      'Some symptoms are mild and normal, requiring only observation. '
          'Continue daily activities while monitoring your body.',
    ),
  ],
};

// ─────────────────────────────────────────────
// REMEDY CARD STYLE HELPER
// ─────────────────────────────────────────────
({Color bg, Color accent, String emoji}) _remedyStyle(String title) {
  final t = title.toLowerCase();
  if (t.contains('rest') || t.contains('sleep'))
    return (bg: const Color(0xFFF0EAF8), accent: const Color(0xFF7C5CBF), emoji: '🌙');
  if (t.contains('exercise') || t.contains('active') || t.contains('sunlight'))
    return (bg: const Color(0xFFE8F5E9), accent: const Color(0xFF2E7D32), emoji: '🏃');
  if (t.contains('breathing'))
    return (bg: const Color(0xFFE3F2FD), accent: const Color(0xFF1565C0), emoji: '🫁');
  if (t.contains('hydrat'))
    return (bg: const Color(0xFFE0F7FA), accent: const Color(0xFF006064), emoji: '💧');
  if (t.contains('meal') || t.contains('fiber') || t.contains('salty') || t.contains('caffeine'))
    return (bg: const Color(0xFFFFF8E1), accent: const Color(0xFFF57F17), emoji: '🥗');
  if (t.contains('communicate'))
    return (bg: const Color(0xFFFCE4EC), accent: const Color(0xFFAD1457), emoji: '💬');
  if (t.contains('compress') || t.contains('pain reliev'))
    return (bg: const Color(0xFFFFEBEE), accent: const Color(0xFFC62828), emoji: '🩹');
  if (t.contains('bra'))
    return (bg: const Color(0xFFFFF3E0), accent: const Color(0xFFE65100), emoji: '👙');
  if (t.contains('skincare') || t.contains('face'))
    return (bg: const Color(0xFFF3E5F5), accent: const Color(0xFF6A1B9A), emoji: '✨');
  if (t.contains('hygiene'))
    return (bg: const Color(0xFFE8F5E9), accent: const Color(0xFF1B5E20), emoji: '🚿');
  if (t.contains('monitor'))
    return (bg: const Color(0xFFFDE8F4), accent: const Color(0xFFB56A7E), emoji: '🔍');
  if (t.contains('doctor') || t.contains('medical'))
    return (bg: const Color(0xFFFFEBEB), accent: const Color(0xFFDC2626), emoji: '⚕️');
  if (t.contains('no action'))
    return (bg: const Color(0xFFE8FDF4), accent: const Color(0xFF059669), emoji: '✅');
  return (bg: const Color(0xFFF2EDF3), accent: const Color(0xFF6B5B73), emoji: '💊');
}

// ─────────────────────────────────────────────
// INTERNAL VIEW MODEL — _RemedyCard
// ─────────────────────────────────────────────
class _RemedyCard {
  final String remedyTitle;
  final String remedyDescription;
  final List<String> symptoms;
  _RemedyCard({
    required this.remedyTitle,
    required this.remedyDescription,
    required this.symptoms,
  });
}

// ─────────────────────────────────────────────
// HOW MANY CHIPS TO SHOW BEFORE COLLAPSING
// ─────────────────────────────────────────────
const int _kChipPreviewCount = 5;

// ─────────────────────────────────────────────
// MAIN SCREEN WIDGET
// ─────────────────────────────────────────────
class RemedySuggestionsScreen extends StatefulWidget {
  final List<String> loggedSymptoms;
  final List<String> loggedMoods;
  final List<String> loggedDischarge;

  const RemedySuggestionsScreen({
    super.key,
    this.loggedSymptoms  = const [],
    this.loggedMoods     = const [],
    this.loggedDischarge = const [],
  });

  @override
  State<RemedySuggestionsScreen> createState() => _RemedySuggestionsScreenState();
}

class _RemedySuggestionsScreenState extends State<RemedySuggestionsScreen>
    with SingleTickerProviderStateMixin {

  late final TabController _tabController;
  late final List<String> _tabs;
  final ScrollController _scrollController    = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  // ── NEW: tracks whether the chips section is expanded ──────────
  bool _chipsExpanded = false;

  List<String> get _allLogged => [
    ...widget.loggedMoods,
    ...widget.loggedSymptoms,
    ...widget.loggedDischarge,
  ];

  @override
  void initState() {
    super.initState();
    final validKeys = _allLogged
        .where((key) => remedyDatabase.containsKey(key))
        .toList();
    _tabs = ['All', ...validKeys];
    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  // ── FILTER LOGIC ──────────────────────────────────────────────
  List<_RemedyCard> get _filteredCards {
    final tab = _tabs[_tabController.index];
    if (tab == 'All') {
      final Map<String, _RemedyCard> grouped = {};
      for (final key in _tabs.skip(1)) {
        for (final remedy in remedyDatabase[key] ?? []) {
          if (grouped.containsKey(remedy.title)) {
            if (!grouped[remedy.title]!.symptoms.contains(key)) {
              grouped[remedy.title]!.symptoms.add(key);
            }
          } else {
            grouped[remedy.title] = _RemedyCard(
              remedyTitle: remedy.title,
              remedyDescription: remedy.description,
              symptoms: [key],
            );
          }
        }
      }
      return grouped.values.toList();
    }
    return [
      for (final r in remedyDatabase[tab] ?? [])
        _RemedyCard(
          remedyTitle: r.title,
          remedyDescription: r.description,
          symptoms: [tab],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F3F5), Color(0xFFF1E6EA)],
          ),
        ),
        child: SafeArea(
          child: _allLogged.isEmpty
              ? _buildEmptyState()
              : _buildScrollableContent(),
        ),
      ),
    );
  }

  // ── FULL-SCREEN SCROLLABLE CONTENT ────────────────────────────
  // Header + chips + tab bar + remedy cards all scroll together
  // as one unified page using CustomScrollView + SliverList.
  Widget _buildScrollableContent() {
    final cards = _filteredCards;

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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Header ──────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Logged chips (collapsible) ───────────────────────
            SliverToBoxAdapter(child: _buildLoggedChips()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Tab bar — sticks to top while scrolling ──────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(child: _buildTabBar()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // ── Remedy cards or empty placeholder ────────────────
            if (cards.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🌸', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 12),
                      Text(
                        'No remedies found for this selection',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          color: Color(0x73000000),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList.separated(
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (ctx, i) => _buildRemedyCard(
                    cards[i],
                    showTags: _tabs[_tabController.index] == 'All',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🌸', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              'No symptoms logged yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A1F3D),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your symptoms in Your Log to see remedy suggestions here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                color: Color(0x73000000),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  // ── LOGGED CHIPS (collapsible) ────────────────────────────────
  Widget _buildLoggedChips() {
    final all          = _allLogged;
    final hasMore      = all.length > _kChipPreviewCount;
    // When collapsed show only the first _kChipPreviewCount items;
    // when expanded show all of them.
    final visibleItems = (!hasMore || _chipsExpanded)
        ? all
        : all.sublist(0, _kChipPreviewCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // ── Visible symptom chips ──────────────────────────
              ...visibleItems.map((label) => _buildChip(label)),

              // ── "See All" / "See Less" toggle chip ────────────
              if (hasMore)
                GestureDetector(
                  onTap: () => setState(() => _chipsExpanded = !_chipsExpanded),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB56A7E),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB56A7E).withOpacity(0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _chipsExpanded
                              ? 'See Less'
                              : '+${all.length - _kChipPreviewCount} more',
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _chipsExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Single symptom chip ───────────────────────────────────────
  Widget _buildChip(String label) {
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
  }

  // ── TAB BAR ───────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFB56A7E) : const Color(0xFFF8EFF2),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected ? Colors.transparent : const Color(0xFFE8B7C3),
                        width: 1,
                      ),
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
                        if (icon != null && label != 'All') ...[
                          isAsset
                              ? Image.asset(icon, width: 16, height: 16)
                              : Text(icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                        ],
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 240),
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : const Color(0xFFB56A7E),
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

  // ── REMEDY CARD ───────────────────────────────────────────────
  Widget _buildRemedyCard(_RemedyCard card, {bool showTags = true}) {
    final style = _remedyStyle(card.remedyTitle);
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: () {
                  final assetPath = _remedyIconMap[card.remedyTitle];
                  if (assetPath != null) {
                    return Image.asset(assetPath, width: 55, height: 55);
                  }
                  return Text(style.emoji,
                      style: const TextStyle(fontSize: 30));
                }(),
              ),
            ),
            const SizedBox(width: 14),

            // ── Text content ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.remedyTitle,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF44222B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.remedyDescription,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      color: Color(0x73000000),
                      height: 1.5,
                    ),
                  ),
                  if (showTags) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: card.symptoms
                          .map((symptom) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB56A7E)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          symptom,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB56A7E),
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STICKY TAB BAR DELEGATE
// Keeps the filter tab bar pinned to the top while
// the rest of the screen scrolls beneath it.
// ─────────────────────────────────────────────
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _StickyTabBarDelegate({required this.child});

  // Measure the tab bar height: label row (10) + gap (10) + chips (42)
  // + gap (10) + divider (1) + bottom padding (10) = ~83
  static const double _height = 83.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      // Match the screen background so cards slide under cleanly
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F3F5), Color(0xFFF1E6EA)],
        ),
        boxShadow: overlapsContent
            ? [
          BoxShadow(
            color: const Color(0xFFB56A7E).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ]
            : [],
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate old) => old.child != child;
}