import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// DATA MODEL — Reason
// ─────────────────────────────────────────────
class Reason {
  final String title;
  final String description;
  const Reason({required this.title, required this.description});
}

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

  // DISCHARGE
  'Pink Discharge'              : 'assets/images/discharge_icon/pink.png',
  'Clear/Transparent Discharge' : 'assets/images/discharge_icon/clear.png',
  'Milky White Discharge'       : 'assets/images/discharge_icon/milky_white.png',
  'Gray Discharge'              : 'assets/images/discharge_icon/gray.png',
  'Bright Yellow Discharge'     : 'assets/images/discharge_icon/bright_yellow.png',
  'Green Discharge'             : 'assets/images/discharge_icon/green.png',
  'Red Discharge'               : 'assets/images/discharge_icon/red.png',
  'Brown Discharge'             : 'assets/images/discharge_icon/brown.png',
  'Watery Discharge'            : 'assets/images/discharge_icon/watery.png',
};

const Map<String, String> _reasonIconMap = {
  'Hormonal Changes'           : 'assets/images/reasons_icon/Hormonal_Changes.png',
  'Premenstrual Syndrome (PMS)': 'assets/images/reasons_icon/PMS.png',
  'Stress'                     : 'assets/images/reasons_icon/Stress.png',
  'Lack of Sleep'              : 'assets/images/reasons_icon/Lack_Of_Sleep.png',
  'Caffeine Intake'            : 'assets/images/reasons_icon/Caffeine_Intake.png',
  'Ovulation'                  : 'assets/images/reasons_icon/Ovulation.png',
  'Uterine Muscle Contractions': 'assets/images/reasons_icon/Uterine_Muscle_Contraction.png',
  'Daily Life Challenges'      : 'assets/images/reasons_icon/Daily_Life_Challenges.png',
  'Menstrual Cramps'           : 'assets/images/reasons_icon/Menstrual_Cramps.png',
  'Water Retention'            : 'assets/images/reasons_icon/Water_Retention.png',
  'Increased Energy Needs'     : 'assets/images/reasons_icon/Increased_Energy_Needs.png',
  'Increased Oil Production'   : 'assets/images/reasons_icon/Increased_Oil_Production.png',
  'Slower Digestion'           : 'assets/images/reasons_icon/Slower_Digestion.png',
  'Faster Digestion'           : 'assets/images/reasons_icon/Faster_Digestion.png',
  'Normal Vaginal Discharge'   : 'assets/images/reasons_icon/Normal_Vaginal_Discharge.png',
  'Possible Infection'         : 'assets/images/reasons_icon/Possible_Infection.png',
  'Light Spotting'             : 'assets/images/reasons_icon/Light_Spotting.png',
  'Active Menstrual Bleeding'  : 'assets/images/reasons_icon/Active_Menstrual_Bleeding.png',
  'Old Blood'                  : 'assets/images/reasons_icon/Old_Blood.png',
  'Mild Irritation'            : 'assets/images/reasons_icon/Mild_Irritation.png',
};

const Map<String, List<Reason>> reasonsDatabase = {

  'Mood Swing': [
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'PMS occurs before menstruation due to hormonal fluctuations, especially changes in progesterone and serotonin levels. It may cause mood swings, bloating, fatigue, irritability, and mild physical discomfort.'),
  ],

  'Irritable': [
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'PMS occurs before menstruation due to hormonal fluctuations, especially changes in progesterone and serotonin levels. It may cause mood swings, bloating, fatigue, irritability, and mild physical discomfort.'),
    Reason(title: 'Stress', description: 'Stress triggers the release of cortisol, which can interfere with hormone balance and menstrual regularity. High stress levels may worsen cramps, fatigue, headaches, or emotional symptoms.'),
    Reason(title: 'Lack of Sleep', description: 'Insufficient sleep disrupts hormone regulation, energy restoration, and mood stability. This can increase fatigue, irritability, and worsen menstrual symptoms.'),
    Reason(title: 'Caffeine Intake', description: 'Caffeine stimulates the nervous system and may temporarily increase heart rate, anxiety, or breast tenderness. It can also worsen bloating or cramps in some individuals.'),
  ],

  'Sad': [
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'PMS occurs before menstruation due to hormonal fluctuations, especially changes in progesterone and serotonin levels. It may cause mood swings, bloating, fatigue, irritability, and mild physical discomfort.'),
  ],

  'Anxious': [
    Reason(title: 'Stress', description: 'Stress triggers the release of cortisol, which can interfere with hormone balance and menstrual regularity. High stress levels may worsen cramps, fatigue, headaches, or emotional symptoms.'),
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
    Reason(title: 'Caffeine Intake', description: 'Caffeine stimulates the nervous system and may temporarily increase heart rate, anxiety, or breast tenderness. It can also worsen bloating or cramps in some individuals.'),
  ],

  'Confident': [
    Reason(title: 'Ovulation', description: 'Ovulation occurs when an ovary releases an egg, usually around the middle of the cycle. Hormonal changes during this phase can increase discharge, libido, mild pelvic pain, and energy levels.'),
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
  ],

  'Happy': [
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
    Reason(title: 'Ovulation', description: 'Ovulation occurs when an ovary releases an egg, usually around the middle of the cycle. Hormonal changes during this phase can increase discharge, libido, mild pelvic pain, and energy levels.'),
  ],

  'Impatient': [
    Reason(title: 'Stress', description: 'Stress triggers the release of cortisol, which can interfere with hormone balance and menstrual regularity. High stress levels may worsen cramps, fatigue, headaches, or emotional symptoms.'),
    Reason(title: 'Lack of Sleep', description: 'Insufficient sleep disrupts hormone regulation, energy restoration, and mood stability. This can increase fatigue, irritability, and worsen menstrual symptoms.'),
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'PMS occurs before menstruation due to hormonal fluctuations, especially changes in progesterone and serotonin levels. It may cause mood swings, bloating, fatigue, irritability, and mild physical discomfort.'),
  ],

  'Inspired': [
    Reason(title: 'Ovulation', description: 'Ovulation occurs when an ovary releases an egg, usually around the middle of the cycle. Hormonal changes during this phase can increase discharge, libido, mild pelvic pain, and energy levels.'),
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
  ],

  'Cramps': [
    Reason(title: 'Uterine Muscle Contractions', description: 'During menstruation, the uterus contracts to shed its lining through the release of prostaglandins. Stronger contractions may cause cramps or abdominal pain.'),
    Reason(title: 'Menstrual Cramps', description: 'Menstrual cramps are caused by uterine contractions that help expel the uterine lining. Higher prostaglandin levels can make these cramps more painful.'),
  ],

  'Breast Tenderness': [
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'PMS occurs before menstruation due to hormonal fluctuations, especially changes in progesterone and serotonin levels. It may cause mood swings, bloating, fatigue, irritability, and mild physical discomfort.'),
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
  ],

  'Stress': [
    Reason(title: 'Daily Life Challenges', description: 'Physical activity, work, school, or emotional demands can intensify menstrual discomfort or fatigue. Hormonal changes combined with daily responsibilities may affect concentration and energy.'),
    Reason(title: 'Lack of Sleep', description: 'Insufficient sleep disrupts hormone regulation, energy restoration, and mood stability. This can increase fatigue, irritability, and worsen menstrual symptoms.'),
  ],

  'Nausea': [
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
    Reason(title: 'Stress', description: 'Stress triggers the release of cortisol, which can interfere with hormone balance and menstrual regularity. High stress levels may worsen cramps, fatigue, headaches, or emotional symptoms.'),
  ],

  'Bloating': [
    Reason(title: 'Water Retention', description: 'Hormonal changes before menstruation can cause the body to retain extra fluid. This often leads to bloating, swelling, or temporary weight fluctuations.'),
    Reason(title: 'Slower Digestion', description: 'Progesterone can slow digestive movement, especially in the luteal phase. This may lead to bloating, constipation, or stomach discomfort.'),
  ],

  'Cravings': [
    Reason(title: 'Increased Energy Needs', description: 'Hormonal changes and bodily processes during certain cycle phases may slightly increase calorie or energy requirements. This can lead to stronger hunger or cravings.'),
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
  ],

  'Breakouts': [
    Reason(title: 'Increased Oil Production', description: 'Rising androgen levels during certain phases of the cycle can stimulate sebaceous glands. This may cause oily skin or acne breakouts.'),
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
  ],

  'Headaches': [
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
    Reason(title: 'Stress', description: 'Stress triggers the release of cortisol, which can interfere with hormone balance and menstrual regularity. High stress levels may worsen cramps, fatigue, headaches, or emotional symptoms.'),
    Reason(title: 'Lack of Sleep', description: 'Insufficient sleep disrupts hormone regulation, energy restoration, and mood stability. This can increase fatigue, irritability, and worsen menstrual symptoms.'),
    Reason(title: 'Caffeine Intake', description: 'Caffeine stimulates the nervous system and may temporarily increase heart rate, anxiety, or breast tenderness. It can also worsen bloating or cramps in some individuals.'),
  ],

  'Constipation': [
    Reason(title: 'Slower Digestion', description: 'Progesterone can slow digestive movement, especially in the luteal phase. This may lead to bloating, constipation, or stomach discomfort.'),
  ],

  'Diarrhea': [
    Reason(title: 'Faster Digestion', description: 'During menstruation, prostaglandins can stimulate bowel movements. This may result in diarrhea or more frequent digestion.'),
  ],

  'Clear/Transparent Discharge': [
    Reason(title: 'Normal Discharge', description: 'Vaginal discharge helps maintain vaginal health by cleaning and protecting against infection. Its texture and amount naturally change throughout the cycle due to hormonal shifts.'),
    Reason(title: 'Ovulation', description: 'Ovulation occurs when an ovary releases an egg, usually around the middle of the cycle. Hormonal changes during this phase can increase discharge, libido, mild pelvic pain, and energy levels.'),
  ],

  'Milky White Discharge': [
    Reason(title: 'Normal Discharge', description: 'Vaginal discharge helps maintain vaginal health by cleaning and protecting against infection. Its texture and amount naturally change throughout the cycle due to hormonal shifts.'),
  ],

  'Bright Yellow Discharge': [
    Reason(title: 'Mild Irritation', description: 'Mild irritation can result from friction, moisture, hormonal sensitivity, or hygiene products. Temporary irritation is common, but persistent symptoms may need attention.'),
    Reason(title: 'Possible Infection', description: 'Unusual discharge, strong odor, itching, or irritation may signal bacterial, fungal, or sexually transmitted infections. Medical evaluation may be needed for proper treatment.'),
  ],

  'Green Discharge': [
    Reason(title: 'Possible Infection', description: 'Unusual discharge, strong odor, itching, or irritation may signal bacterial, fungal, or sexually transmitted infections. Medical evaluation may be needed for proper treatment.'),
  ],

  'Gray Discharge': [
    Reason(title: 'Possible Infection', description: 'Unusual discharge, strong odor, itching, or irritation may signal bacterial, fungal, or sexually transmitted infections. Medical evaluation may be needed for proper treatment.'),
  ],

  'Pink Discharge': [
    Reason(title: 'Light Spotting', description: 'Light spotting may occur as hormone levels shift and the uterus begins or finishes shedding its lining. It is often normal if mild and temporary.'),
  ],

  'Red Discharge': [
    Reason(title: 'Active Menstrual Bleeding', description: 'This is the normal shedding of the uterine lining when pregnancy does not occur. Flow can vary in heaviness depending on the cycle day.'),
  ],

  'Brown Discharge': [
    Reason(title: 'Old Blood', description: 'Brown or dark-colored blood is usually older blood that took longer to exit the body. It is common near the beginning or end of menstruation.'),
  ],

  'Watery Discharge': [
    Reason(title: 'Hormonal Changes', description: 'Throughout the menstrual cycle, estrogen and progesterone naturally rise and fall to regulate ovulation and menstruation. These hormonal shifts can affect mood, energy, appetite, skin, and physical comfort.'),
    Reason(title: 'Normal Discharge', description: 'Vaginal discharge helps maintain vaginal health by cleaning and protecting against infection. Its texture and amount naturally change throughout the cycle due to hormonal shifts.'),
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'PMS occurs before menstruation due to hormonal fluctuations, especially changes in progesterone and serotonin levels. It may cause mood swings, bloating, fatigue, irritability, and mild physical discomfort.'),
    Reason(title: 'Stress', description: 'Stress triggers the release of cortisol, which can interfere with hormone balance and menstrual regularity. High stress levels may worsen cramps, fatigue, headaches, or emotional symptoms.'),
    Reason(title: 'Lack of Sleep', description: 'Insufficient sleep disrupts hormone regulation, energy restoration, and mood stability. This can increase fatigue, irritability, and worsen menstrual symptoms.'),
    Reason(title: 'Daily Life Challenges', description: 'Physical activity, work, school, or emotional demands can intensify menstrual discomfort or fatigue. Hormonal changes combined with daily responsibilities may affect concentration and energy.'),
  ],
};

// ─────────────────────────────────────────────
// REASON CARD STYLE HELPER
// ─────────────────────────────────────────────
({Color bg, Color accent, String emoji}) _reasonStyle(String title) {
  final t = title.toLowerCase();
  if (t.contains('hormonal') || t.contains('ovulation'))
    return (bg: const Color(0xFFFDE8F4), accent: const Color(0xFFB56A7E), emoji: '🌸');
  if (t.contains('pms') || t.contains('premenstrual'))
    return (bg: const Color(0xFFF5E6FF), accent: const Color(0xFF8B5CF6), emoji: '🔁');
  if (t.contains('stress') || t.contains('lack of sleep') || t.contains('daily life'))
    return (bg: const Color(0xFFFFF3E0), accent: const Color(0xFFE07B2A), emoji: '⚡');
  if (t.contains('caffeine'))
    return (bg: const Color(0xFFF3EAD9), accent: const Color(0xFF8B6914), emoji: '☕');
  if (t.contains('infection') || t.contains('irritation'))
    return (bg: const Color(0xFFFFEBEB), accent: const Color(0xFFDC2626), emoji: '⚠️');
  if (t.contains('digestion') || t.contains('retention') ||
      t.contains('energy') || t.contains('oil') || t.contains('menstrual cramps'))
    return (bg: const Color(0xFFE8F4FD), accent: const Color(0xFF2563EB), emoji: '🔬');
  if (t.contains('uterine') || t.contains('cramps'))
    return (bg: const Color(0xFFE8F4FD), accent: const Color(0xFF2563EB), emoji: '🫀');
  if (t.contains('normal') || t.contains('bleeding') || t.contains('spotting') ||
      t.contains('old blood') || t.contains('menstrual bleeding'))
    return (bg: const Color(0xFFE8FDF4), accent: const Color(0xFF059669), emoji: '💧');
  return (bg: const Color(0xFFF2EDF3), accent: const Color(0xFF6B5B73), emoji: '🩺');
}

// ─────────────────────────────────────────────
// INTERNAL VIEW MODEL — _ReasonCard
// ─────────────────────────────────────────────
class _ReasonCard {
  final String reasonTitle;
  final String reasonDescription;
  final List<String> symptoms;
  _ReasonCard({
    required this.reasonTitle,
    required this.reasonDescription,
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
class PossibleReasonsScreen extends StatefulWidget {
  final List<String> loggedSymptoms;
  final List<String> loggedMoods;
  final List<String> loggedDischarge;

  const PossibleReasonsScreen({
    super.key,
    this.loggedSymptoms  = const [],
    this.loggedMoods     = const [],
    this.loggedDischarge = const [],
  });

  @override
  State<PossibleReasonsScreen> createState() => _PossibleReasonsScreenState();
}

class _PossibleReasonsScreenState extends State<PossibleReasonsScreen>
    with SingleTickerProviderStateMixin {

  late final TabController _tabController;
  late final List<String> _tabs;
  final ScrollController _scrollController    = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  // Tracks whether the chips section is expanded
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
        .where((key) => reasonsDatabase.containsKey(key))
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
  List<_ReasonCard> get _filteredCards {
    final tab = _tabs[_tabController.index];
    if (tab == 'All') {
      final Map<String, _ReasonCard> grouped = {};
      for (final key in _tabs.skip(1)) {
        for (final reason in reasonsDatabase[key] ?? []) {
          if (grouped.containsKey(reason.title)) {
            if (!grouped[reason.title]!.symptoms.contains(key)) {
              grouped[reason.title]!.symptoms.add(key);
            }
          } else {
            grouped[reason.title] = _ReasonCard(
              reasonTitle: reason.title,
              reasonDescription: reason.description,
              symptoms: [key],
            );
          }
        }
      }
      return grouped.values.toList();
    }
    return [
      for (final r in reasonsDatabase[tab] ?? [])
        _ReasonCard(
          reasonTitle: r.title,
          reasonDescription: r.description,
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
  // Header + chips + tab bar + reason cards all scroll together
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

            // ── Reason cards or empty placeholder ────────────────
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
                        'No reasons found for this selection',
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
                  itemBuilder: (ctx, i) => _buildReasonCard(
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
              'Add your symptoms in Your Log to see possible reasons here.',
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
              text: 'Possible Reasons',
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
    final all     = _allLogged;
    final hasMore = all.length > _kChipPreviewCount;
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
                ? Image.asset(
              icon,
              width: 16,
              height: 16,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                size: 16,
                color: Colors.red,
              ),
            )
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
                              ? Image.asset(
                            icon,
                            width: 16,
                            height: 16,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 16,
                              color: Colors.red,
                            ),
                          )
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

  // ── REASON CARD ───────────────────────────────────────────────
  Widget _buildReasonCard(_ReasonCard card, {bool showTags = true}) {
    final style = _reasonStyle(card.reasonTitle);
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
                  final assetPath = _reasonIconMap[card.reasonTitle];
                  if (assetPath != null) {
                    return Image.asset(
                      assetPath,
                      width: 55,
                      height: 55,
                      errorBuilder: (_, __, ___) =>
                          Text(style.emoji, style: const TextStyle(fontSize: 30)),
                    );
                  }
                  return Text(style.emoji, style: const TextStyle(fontSize: 30));
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
                    card.reasonTitle,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF44222B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.reasonDescription,
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
                          color: const Color(0xFFB56A7E).withOpacity(0.12),
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