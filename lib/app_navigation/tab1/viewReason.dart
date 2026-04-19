import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// ENTRY POINT
// Starts the app and sets up global theming.
// ─────────────────────────────────────────────
void main() {
  runApp(
    MaterialApp(
      title: 'Possible Reasons',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F3F5),
        fontFamily: 'DMSans',
      ),
      home: const PossibleReasonsScreen(),
    ),
  );
}

// ─────────────────────────────────────────────
// DATA MODEL — Reason
// Represents a single possible reason card with
// a title and a short description (2–3 sentences).
// ─────────────────────────────────────────────
class Reason {
  final String title;
  final String description;
  const Reason({required this.title, required this.description});
}

// ─────────────────────────────────────────────
// ICON MAP
// Maps each symptom/discharge label to either:
//   - An emoji string (e.g., '🔄'), OR
//   - A local asset path (e.g., 'assets/images/pink.png')
// Used in chips and tab bar for visual identification.
//
// TODO: Kunin na lang ang icon mapping mula sa database
// para hindi hard-coded dito sa code.
// The code should be placed here
// ─────────────────────────────────────────────
const Map<String, String> _iconMap = {
  'Mood Swing' : '🔄',
  'Irritable'  : '😠',
  'Sad'        : '😢',
  'Anxious'    : '😰',
  'Confident'  : '😎',
  'Happy'      : '😊',
  'Impatient'  : '😤',
  'Inspired'   : '✨',
  'Abdominal Cramps'  : '🤕',
  'Headaches'         : '🤯',
  'Nausea'            : '🤢',
  'Bloating'          : '😖',
  'Breast Tenderness' : '💢',
  'Breakouts'         : '😬',
  'Cravings'          : '🍫',
  'Stress'            : '😫',
  'Constipation'      : '🚫',
  'Diarrhea'          : '💩',
  'Pink Discharge'              : 'assets/images/pink.png',
  'Clear/Transparent Discharge' : 'assets/images/clear.png',
  'Milky White Discharge'       : 'assets/images/milky_white.png',
  'Gray Discharge'              : 'assets/images/gray.png',
  'Bright Yellow Discharge'     : 'assets/images/bright_yellow.png',
  'Green Discharge'             : 'assets/images/green.png',
  'Red Discharge'               : 'assets/images/red.png',
  'Brown Discharge'             : 'assets/images/brown.png',
};

// ─────────────────────────────────────────────
// REASONS DATABASE
// A local map of symptom labels to their list of
// possible reasons (title + description).
// Each description should be kept to 2–3 sentences only.
//
// TODO: I-replace ang buong `reasonsDatabase` na ito ng
// actual na fetch mula sa backend/database (e.g., Firestore,
// Supabase, REST API) para dynamic at maintainable.
// The code should be placed here
//
// TODO: Ilagay na lang dito ang logged symptoms ng user
// (manggaling sa database/session) at i-filter ang
// reasonsDatabase based doon — hindi hard-coded yung
// _sampleMoods, _sampleSymptoms, _sampleDischarge.
// The code should be placed here
// ─────────────────────────────────────────────
const Map<String, List<Reason>> reasonsDatabase = {
  'Mood Swing': [
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'Fluctuating levels of estrogen and progesterone throughout your cycle directly affect brain chemistry, making your emotions feel more unpredictable or intense at certain phases.'),
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'In the days before your period, falling hormone levels can trigger sudden shifts in mood — from irritability to sadness to calm — often without an obvious external cause.'),
  ],
  'Irritable': [
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'PMS commonly causes heightened irritability as progesterone drops in the late luteal phase, lowering the brain\'s tolerance for frustration and making small things feel overwhelming.'),
    Reason(title: 'Stress', description: 'High cortisol levels from ongoing stress keep your nervous system in a heightened state, making you more reactive and short-tempered even in situations that would normally feel manageable.'),
    Reason(title: 'Lack of Sleep', description: 'Even one or two nights of poor sleep reduces activity in the prefrontal cortex — the part of the brain that regulates emotional responses — leaving you with a shorter fuse.'),
    Reason(title: 'Caffeine Intake', description: 'Too much caffeine overstimulates the nervous system, increasing anxiety and irritability. This effect is stronger in the premenstrual phase when the body is already more sensitive to stimulants.'),
  ],
  'Sad': [
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'Estrogen plays a key role in regulating serotonin, your mood-stabilising neurotransmitter. When estrogen dips — especially before your period — serotonin drops too, often triggering feelings of sadness or low motivation.'),
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'PMS-related sadness is a recognised symptom caused by the sharp hormonal decline before menstruation. It typically resolves within the first few days of your period starting.'),
  ],
  'Anxious': [
    Reason(title: 'Stress', description: 'Chronic stress floods the body with cortisol and adrenaline, keeping your threat-response system activated and making anxiety feel constant rather than situational.'),
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'Progesterone has a calming, GABA-like effect on the brain. When it drops sharply before your period, that natural buffer disappears, leaving you more prone to anxious thoughts and restlessness.'),
    Reason(title: 'Caffeine Intake', description: 'Caffeine blocks adenosine receptors that promote calm and increases adrenaline output, which can directly trigger or worsen anxiety — particularly during hormonally sensitive phases of your cycle.'),
  ],
  'Confident': [
    Reason(title: 'Ovulation (Fertile Phase)', description: 'Around ovulation, estrogen and testosterone both peak, which has been linked to improved mood, social ease, and a stronger sense of self-assurance. Many people feel their most capable and outgoing during this window.'),
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'Rising estrogen in the follicular phase supports dopamine and serotonin activity, which can enhance motivation, clarity, and a general sense of competence and confidence.'),
  ],
  'Happy': [
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'Estrogen rising during the follicular phase boosts serotonin and dopamine production — the neurotransmitters most associated with happiness, pleasure, and positive outlook.'),
    Reason(title: 'Ovulation (Fertile Phase)', description: 'The hormonal peak at ovulation — particularly the surge in estrogen and luteinising hormone — is often accompanied by a natural lift in energy and mood, sometimes described as a mid-cycle "glow."'),
  ],
  'Impatient': [
    Reason(title: 'Stress', description: 'Stress shortens your emotional bandwidth. When your nervous system is already under pressure, waiting or dealing with delays feels disproportionately frustrating.'),
    Reason(title: 'Lack of Sleep', description: 'Sleep deprivation impairs impulse control and emotional regulation, making it harder to stay patient in situations that require it. Even mild fatigue can noticeably reduce your tolerance for waiting.'),
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'The hormonal shifts of PMS reduce emotional resilience, which can express itself as impatience or frustration — especially in situations that feel slow or out of your control.'),
  ],
  'Inspired': [
    Reason(title: 'Ovulation (Fertile Phase)', description: 'The hormonal peak at ovulation is associated with heightened cognitive clarity, creativity, and drive. Many people report their most inspired and productive days falling around this phase.'),
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'Estrogen\'s influence on dopamine pathways during the follicular and ovulatory phases can enhance creative thinking, curiosity, and the motivation to start new projects or ideas.'),
  ],
  'Abdominal Cramps': [
    Reason(title: 'Uterine Muscle Contractions', description: 'The uterus is a muscular organ that contracts to shed its lining during menstruation. These contractions — driven by hormone-like compounds called prostaglandins — are the direct physical cause of cramping pain.'),
    Reason(title: 'Period Pain (Menstrual Cramps)', description: 'Higher levels of prostaglandins cause stronger and more frequent uterine contractions, which can temporarily restrict blood flow to the uterus, intensifying the pain felt during your period.'),
  ],
  'Breast Tenderness': [
    Reason(title: 'Premenstrual Syndrome (PMS)', description: 'Breast tenderness before your period is one of the most common PMS symptoms. Rising and then falling progesterone causes fluid retention in breast tissue, leading to swelling and sensitivity.'),
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'Both estrogen and progesterone influence the glandular and connective tissue in the breasts. Their fluctuation throughout the cycle — particularly in the luteal phase — causes cyclic tenderness in many people.'),
  ],
  'Stress': [
    Reason(title: 'Daily Life Challenges', description: 'Work pressures, relationship dynamics, financial concerns, and the demands of daily responsibilities are among the most common sources of ongoing psychological stress.'),
    Reason(title: 'Lack of Sleep', description: 'Poor sleep and stress form a reinforcing cycle — stress disrupts sleep, and insufficient sleep raises cortisol levels, making stress harder to manage and recover from the next day.'),
  ],
  'Nausea': [
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'Fluctuating estrogen and progesterone can affect the gastrointestinal tract, slowing motility and increasing sensitivity in a way that produces nausea — especially in the premenstrual and early menstrual phases.'),
    Reason(title: 'Stress', description: 'The gut and brain are closely connected via the vagus nerve. High stress activates the body\'s fight-or-flight response, which can disrupt digestion and trigger nausea even without any gastrointestinal cause.'),
  ],
  'Bloating': [
    Reason(title: 'Water Retention Before Period', description: 'In the days before menstruation, hormonal shifts — particularly rising progesterone and a drop in aldosterone — cause the body to retain water, contributing to a bloated, heavy feeling in the abdomen.'),
    Reason(title: 'Slower Digestion', description: 'Progesterone relaxes smooth muscle, including in the digestive tract. This slows the movement of food through the gut, leading to gas build-up, fullness, and visible abdominal bloating.'),
  ],
  'Cravings': [
    Reason(title: 'Increased Energy Needs', description: 'In the luteal phase, the body\'s basal metabolic rate rises slightly as it prepares for a potential pregnancy. This increase in energy expenditure can trigger genuine hunger and cravings, particularly for calorie-dense foods.'),
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'Dropping serotonin levels before your period can drive cravings for carbohydrates and sugar, as the body attempts to boost serotonin production through food. Chocolate cravings in particular are linked to this mechanism.'),
  ],
  'Breakouts': [
    Reason(title: 'Increased Oil Production', description: 'Rising androgens — particularly testosterone — in the days before your period stimulate the sebaceous glands to produce more oil (sebum). Excess sebum clogs pores and creates the conditions for breakouts.'),
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'The hormonal fluctuations of the menstrual cycle affect skin behaviour throughout the month. The pre-menstrual drop in estrogen combined with relatively higher androgen levels is when skin tends to be most acne-prone.'),
  ],
  'Headaches': [
    Reason(title: 'Hormonal Changes (cycle-related rises and drops)', description: 'The sharp drop in estrogen just before menstruation is a well-documented trigger for hormonal headaches and migraines. Estrogen influences blood vessel dilation in the brain, and its sudden decline can provoke head pain.'),
    Reason(title: 'Stress', description: 'Tension headaches — the most common type — are often caused or worsened by stress. Muscle tension in the neck, shoulders, and scalp builds up during periods of psychological stress, leading to a dull, pressing head pain.'),
    Reason(title: 'Lack of Sleep', description: 'Sleep is when the brain clears metabolic waste and regulates pain sensitivity. Insufficient sleep lowers the pain threshold and is a recognised trigger for both tension headaches and migraines.'),
    Reason(title: 'Caffeine Intake', description: 'Caffeine constricts blood vessels in the brain. Regular caffeine use raises the baseline for this effect, so skipping your usual intake — or consuming too much — can trigger a rebound headache as vessels rapidly dilate or constrict.'),
  ],
  'Constipation': [
    Reason(title: 'Slower Digestion', description: 'Progesterone, which rises after ovulation, relaxes the smooth muscle of the digestive tract. This slows peristalsis — the wave-like contractions that move food through the intestines — resulting in constipation, particularly in the luteal phase.'),
  ],
  'Diarrhea': [
    Reason(title: 'Faster Digestion', description: 'Prostaglandins released at the start of menstruation stimulate uterine contractions but also affect nearby intestinal muscles, speeding up gut motility. This commonly causes loose stools or diarrhea in the first one to two days of your period.'),
  ],
  'Clear/Transparent Discharge': [
    Reason(title: 'Normal Vaginal Discharge', description: 'Clear, watery discharge is the vagina\'s natural self-cleaning mechanism. Glands in the cervix and vaginal walls produce fluid to maintain a healthy pH, remove dead cells, and protect against infection — this is completely normal.'),
    Reason(title: 'Ovulation (Fertile Phase)', description: 'Around ovulation, discharge becomes more abundant, clear, and stretchy — often compared to raw egg whites. This change is caused by the estrogen surge and helps sperm travel more easily through the cervix.'),
  ],
  'Milky White Discharge': [
    Reason(title: 'Normal Vaginal Discharge', description: 'Milky or creamy white discharge is typical in the follicular and luteal phases of the cycle. It has no strong odour and causes no irritation — it reflects the normal baseline activity of the cervical glands.'),
  ],
  'Bright Yellow Discharge': [
    Reason(title: 'Mild Irritation', description: 'A pale yellow tint can result from minor irritation caused by products like scented soaps, synthetic underwear, or new laundry detergents. If there is no odour or itching, it is usually not a cause for concern.'),
    Reason(title: 'Possible Infection', description: 'Vivid or deep yellow discharge — especially when accompanied by itching, burning, or an unusual smell — can indicate a bacterial or yeast infection and warrants attention from a healthcare provider.'),
  ],
  'Green Discharge': [
    Reason(title: 'Possible Infection', description: 'Green discharge is not a normal variation and is typically a sign of a bacterial infection or a sexually transmitted infection (STI) such as trichomoniasis or gonorrhoea. Consult a healthcare provider promptly for proper diagnosis and treatment.'),
  ],
  'Gray Discharge': [
    Reason(title: 'Possible Infection', description: 'Grey discharge, particularly when accompanied by a distinctive fishy odour, is a hallmark sign of bacterial vaginosis (BV) — an overgrowth of harmful bacteria that disrupts the vagina\'s natural balance. BV requires medical treatment to resolve.'),
  ],
  'Pink Discharge': [
    Reason(title: 'Light Spotting (Start or End of Period)', description: 'Pink discharge occurs when a small amount of blood mixes with normal vaginal discharge. It is common at the very beginning or end of your period when flow is light, and can also occur around ovulation or after implantation in early pregnancy.'),
  ],
  'Red Discharge': [
    Reason(title: 'Active Menstrual Bleeding', description: 'Bright red discharge during your expected period is simply active menstrual flow — the shedding of the uterine lining. If red bleeding occurs outside your expected period or is unusually heavy, it is worth discussing with a healthcare provider.'),
  ],
  'Brown Discharge': [
    Reason(title: 'Old Blood (End of Period)', description: 'Brown discharge is oxidised blood — blood that has taken longer to leave the body and has darkened in colour. It most commonly appears at the tail end of your period and is a normal part of the cycle.'),
  ],
};

// ─────────────────────────────────────────────
// REASON CARD STYLE HELPER
// Returns a background color, accent color, and emoji
// based on keywords in the reason title.
// Used to visually differentiate card categories.
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
  if (t.contains('digestion') || t.contains('retention') || t.contains('uterine') ||
      t.contains('energy') || t.contains('oil') || t.contains('period pain'))
    return (bg: const Color(0xFFE8F4FD), accent: const Color(0xFF2563EB), emoji: '🔬');
  if (t.contains('normal') || t.contains('bleeding') || t.contains('spotting') ||
      t.contains('old blood') || t.contains('menstrual bleeding'))
    return (bg: const Color(0xFFE8FDF4), accent: const Color(0xFF059669), emoji: '💧');
  return (bg: const Color(0xFFF2EDF3), accent: const Color(0xFF6B5B73), emoji: '🩺');
}

// ─────────────────────────────────────────────
// INTERNAL VIEW MODEL — _ReasonCard
// A grouped data object used for rendering cards.
// Combines a reason's title and description with
// the list of symptoms that triggered it (used for tags).
// ─────────────────────────────────────────────
class _ReasonCard {
  final String reasonTitle;
  final String reasonDescription;
  final List<String> symptoms;
  _ReasonCard({required this.reasonTitle, required this.reasonDescription, required this.symptoms});
}

// ─────────────────────────────────────────────
// SAMPLE LOGGED DATA (Placeholder)
// Simulates the logged symptoms from the user for today.
// These sets are split into moods, physical symptoms,
// and discharge types for organization.
//
// TODO: I-replace ang _sampleMoods, _sampleSymptoms, at
// _sampleDischarge ng actual na logged data ng user mula
// sa database (e.g., today's symptom log entry).
// The code should be placed here
//
// TODO: Ang "Your Symptoms Today" section ay dapat
// mag-show lang ng mga symptoms na talagang na-log ng user —
// hindi hard-coded. I-fetch ito from the user's daily log.
// The code should be placed here
//
// TODO: Ang filter tabs at reason cards ay dapat
// mag-reflect lang ng mga logged symptoms ng user.
// Kung walang logged, show empty state.
// The code should be placed here
// ─────────────────────────────────────────────
const Set<String> _sampleMoods     = {'Mood Swing', 'Anxious', 'Sad'};
const Set<String> _sampleSymptoms  = {'Abdominal Cramps', 'Headaches', 'Bloating'};
const Set<String> _sampleDischarge = {'Pink Discharge'};

// ─────────────────────────────────────────────
// MAIN SCREEN WIDGET
// The root StatefulWidget for the Possible Reasons screen.
// Manages the tab controller and scroll controllers.
// ─────────────────────────────────────────────
class PossibleReasonsScreen extends StatefulWidget {
  const PossibleReasonsScreen({super.key});
  @override
  State<PossibleReasonsScreen> createState() => _PossibleReasonsScreenState();
}

class _PossibleReasonsScreenState extends State<PossibleReasonsScreen>
    with SingleTickerProviderStateMixin {

  // ── CONTROLLERS ───────────────────────────────────────────────
  // TabController manages which tab is active.
  // ScrollControllers track scroll position for the
  // main list and the horizontal tab bar.
  late final TabController _tabController;
  late final List<String> _tabs;
  final ScrollController _scrollController    = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  // ─────────────────────────────────────────────
  // INIT STATE
  // Builds the tab list from logged symptoms.
  // The first tab is always 'All', followed by each
  // logged symptom that exists in the reasons database.
  // ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Combine all logged symptoms and filter to only those
    // that have matching entries in the reasons database.
    final allSelected = [..._sampleMoods, ..._sampleSymptoms, ..._sampleDischarge]
        .where((key) => reasonsDatabase.containsKey(key))
        .toList();

    _tabs = ['All', ...allSelected];

    // Rebuild the screen whenever the selected tab changes.
    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() => setState(() {}));
  }

  // ─────────────────────────────────────────────
  // DISPOSE
  // Releases all controllers from memory to prevent leaks.
  // Always required when using manual controllers in Flutter.
  // ─────────────────────────────────────────────
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // FILTERED CARDS GETTER
  // Returns the list of reason cards to display
  // based on the currently selected tab.
  //
  // - If "All" tab: groups reasons across all symptoms,
  //   merging duplicates and tagging which symptoms they apply to.
  // - If a specific symptom tab: returns reasons for that symptom only.
  // ─────────────────────────────────────────────
  List<_ReasonCard> get _filteredCards {
    final tab = _tabs[_tabController.index];

    if (tab == 'All') {
      // Group reasons by title across all logged symptoms.
      // If the same reason appears for multiple symptoms,
      // it's shown once with all related symptom tags.
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

    // For a specific tab, show only its reasons without symptom tags.
    return [
      for (final r in reasonsDatabase[tab] ?? [])
        _ReasonCard(reasonTitle: r.title, reasonDescription: r.description, symptoms: [tab]),
    ];
  }

  // ─────────────────────────────────────────────
  // BUILD
  // Main widget tree. Sets the status bar style and
  // lays out the screen in a vertical Column:
  //   Header → Symptom chips → Tab bar → Scrollable reason list
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        // Subtle gradient background from top to bottom.
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
              Expanded(child: _buildReasonList()),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER SECTION
  // Displays the screen title using a serif display font
  // and a subtitle describing the screen's purpose.
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // LOGGED CHIPS SECTION
  // Shows the user's logged symptoms as pill-shaped chips.
  // Each chip displays the symptom's icon (emoji or image asset)
  // alongside its label.
  //
  // TODO: I-replace ang hard-coded `all` list ng dynamic na
  // list mula sa logged symptoms ng user para today.
  // The code should be placed here
  // ─────────────────────────────────────────────
  Widget _buildLoggedChips() {
    final all = [..._sampleMoods, ..._sampleSymptoms, ..._sampleDischarge];

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
                    if (icon != null) ...[
                      // Render image asset or emoji based on the icon type.
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

  // ─────────────────────────────────────────────
  // TAB BAR SECTION
  // Horizontally scrollable tab bar that lets the user
  // filter reason cards by symptom. The "All" tab shows
  // all grouped reasons. Individual symptom tabs show
  // only reasons related to that symptom.
  //
  // TODO: I-update ang tab list dynamically kapag
  // nagbago ang logged symptoms ng user (e.g., real-time
  // update mula sa database o state management).
  // The code should be placed here
  // ─────────────────────────────────────────────
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

        // Horizontal scrollable row of filter tabs.
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
                      // Shadow only appears on the active/selected tab.
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
                        // Show icon only for symptom tabs, not for "All".
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

        // Divider below the tab bar for visual separation.
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

  // ─────────────────────────────────────────────
  // REASON LIST SECTION
  // Scrollable list of reason cards filtered by
  // the active tab. Shows an empty state with a
  // flower emoji if no reasons are found.
  //
  // Uses a styled Scrollbar with custom thumb and track colors.
  // ─────────────────────────────────────────────
  Widget _buildReasonList() {
    final cards = _filteredCards;

    // Empty state — shown when no reasons match the selected tab.
    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🌸', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text(
              'No reasons found for this selection',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 14, color: Color(0x73000000)),
            ),
          ],
        ),
      );
    }

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(const Color(0xFFB56A7E).withOpacity(0.55)),
        trackColor: WidgetStateProperty.all(const Color(0xFFE8B7C3).withOpacity(0.25)),
        trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.dragged) ? 6.0 : 4.0,
        ),
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
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          // Show symptom tags only in the "All" tab.
          itemBuilder: (ctx, i) => _buildReasonCard(
            cards[i],
            showTags: _tabs[_tabController.index] == 'All',
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // REASON CARD WIDGET
  // Renders a single reason card with:
  //   - A colored icon box (category-based style)
  //   - The reason title and description
  //   - Optional symptom tags (shown only in "All" tab)
  //
  // NOTE: No expand/collapse — descriptions are kept short
  // (2–3 sentences) so full text is always visible.
  //
  // TODO: I-update ang icon ng bawat reason card base sa
  // tamang icon mula sa database o design spec, hindi
  // lang emoji placeholder mula sa _reasonStyle helper.
  // The code should be placed here
  // ─────────────────────────────────────────────
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
          BoxShadow(color: Color(0x0F000000), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon box — color and emoji vary by reason type.
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(style.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),

            // Reason title, description, and optional symptom tags.
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

                  // Description is always fully visible — no expand/collapse needed
                  // since content is kept to 2–3 sentences.
                  Text(
                    card.reasonDescription,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      color: Color(0x73000000),
                      height: 1.5,
                    ),
                  ),

                  // Symptom tags are only shown in the "All" tab to indicate
                  // which logged symptoms this reason is related to.
                  if (showTags) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: card.symptoms
                          .map((symptom) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
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