import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/notifications_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  try {
    await NotificationsService.initialize();
  } catch (e) {
    debugPrint('Notifications initialization failed: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  final hasSelectedLanguage = prefs.getBool('hasSelectedLanguage') ?? false;
  final hasCompletedSurvey = prefs.getBool('hasCompletedSurvey') ?? false;
  final selectedLanguage = prefs.getString('selectedLanguage') ?? 'ar';

  const isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://aogfmteghpjhyccxrcjm.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_73k_x4_-z4u13pIq25-IWQ_1Nqw1ApQ',
  );

  final validUrl =
      _isValidHttpUrl(supabaseUrl) &&
      !supabaseUrl.toUpperCase().contains('YOUR_URL');
  final validKey =
      supabaseAnonKey.isNotEmpty &&
      !supabaseAnonKey.toUpperCase().contains('YOUR_');

  bool supabaseEnabled = !isFlutterTest && validUrl && validKey;
  if (supabaseEnabled) {
    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
      supabaseEnabled = false;
    }
  }

  runApp(
    SustainabilityHubApp(
      supabaseEnabled: supabaseEnabled,
      hasSeenOnboarding: hasSeenOnboarding,
      hasSelectedLanguage: hasSelectedLanguage,
      hasCompletedSurvey: hasCompletedSurvey,
      selectedLanguage: selectedLanguage,
    ),
  );
}

bool _isValidHttpUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  if (!(uri.scheme == 'http' || uri.scheme == 'https')) return false;
  if (uri.host.isEmpty) return false;
  return true;
}

const String legacyMainDart = r'''
class SustainabilityHubApp extends StatelessWidget {
  const SustainabilityHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Sustainable Home',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: const Color(0xFF16A34A),
          secondary: const Color(0xFFF59E0B), // برتقالي جذاب
          tertiary: const Color(0xFF3B82F6), // أزرق للمياه
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.cairoTextTheme(), // خط احترافي يدعم العربية
      ),
      home: const MainNavigation(),
    );
  }
}

// --- نظام الترجمة الاحترافي ---
class AppStrings {
  static Map<String, Map<String, String>> values = {
    'en': {
      'appName': 'My Sustainable Home',
      'home': 'Home',
      'learn': 'Learn',
      'quiz': 'Quiz',
      'challenges': 'Challenges',
      'profile': 'Profile',
      'learnSdgs': 'Learn SDGs',
      'interactiveQuiz': 'Interactive Quiz',
      'tipsChallenges': 'Tips & Challenges',
      'newsStories': 'News & Stories',
      'sdg11Title': 'SDG 11 Sustainable Cities',
      'sdg11Subtitle':
          'Make cities inclusive, safe, resilient, and sustainable.',
      'sdg12Title': 'SDG 12 Responsible Consumption',
      'sdg12Subtitle':
          'Ensure sustainable consumption and production patterns.',
      'learnMore': 'Learn More',
      'caseStudies': 'Case Studies',
      'watchVideo': 'Watch Video',
      'tipsTricks': 'Tips & Tricks',
      'quizMe': 'Quiz Me',
      'hint': 'Hint',
      'showAnswer': 'Show Answer',
      'nextQuestion': 'Next Question',
      'trackImpact': 'Track Your Impact',
      'co2Saved': 'CO₂ Saved',
      'wasteReduced': 'Waste Reduced',
      'challengesCompleted': 'Challenges Completed',
      'addAction': 'Add Action',
      'viewLeaderboard': 'View Leaderboard',
      'weeklyProgress': 'Weekly Progress',
      'tasks': 'tasks',
      'welcomeTitle': 'Welcome to your\nsustainability journey',
      'welcomeSubtitle': 'Learn, Act, Track Your Impact',
      'getStarted': 'Get Started / ابدأ',
    },
    'ar': {
      'appName': 'مركز الاستدامة',
      'home': 'الرئيسية',
      'learn': 'تعلّم',
      'quiz': 'اختبار',
      'challenges': 'تحديات',
      'profile': 'الملف',
      'learnSdgs': 'تعلّم أهداف التنمية',
      'interactiveQuiz': 'اختبار تفاعلي',
      'tipsChallenges': 'نصائح وتحديات',
      'newsStories': 'أخبار وقصص',
      'sdg11Title': 'الهدف 11: مدن ومجتمعات مستدامة',
      'sdg11Subtitle': 'اجعل المدن شاملة وآمنة وقادرة على الصمود ومستدامة.',
      'sdg12Title': 'الهدف 12: الاستهلاك والإنتاج المسؤولان',
      'sdg12Subtitle': 'ضمان أنماط استهلاك وإنتاج مستدامة.',
      'learnMore': 'اعرف أكثر',
      'caseStudies': 'دراسات حالة',
      'watchVideo': 'شاهد فيديو',
      'tipsTricks': 'نصائح وحيل',
      'quizMe': 'اختبرني',
      'hint': 'تلميح',
      'showAnswer': 'إظهار الإجابة',
      'nextQuestion': 'السؤال التالي',
      'trackImpact': 'تتبع تأثيرك',
      'co2Saved': 'CO₂ موفّر',
      'wasteReduced': 'نفايات أقل',
      'challengesCompleted': 'تحديات مكتملة',
      'addAction': 'إضافة إجراء',
      'viewLeaderboard': 'لوحة المتصدرين',
      'weeklyProgress': 'تقدّم الأسبوع',
      'tasks': 'مهمة',
      'welcomeTitle': 'مرحباً بك في رحلة\nالاستدامة',
      'welcomeSubtitle': 'Welcome to your sustainability\njourney',
      'getStarted': 'Get Started / ابدأ',
    },
  };

  static String get(String key, BuildContext context) {
    String lang = Localizations.localeOf(context).languageCode;
    return values[lang]?[key] ?? key;
  }
}

// --- التنقل الرئيسي (Bottom Navigation) ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Widget currentScreen = switch (_currentIndex) {
      0 => HubHomeScreen(
        onNavigateToTab: (index) => setState(() => _currentIndex = index),
      ),
      1 => const LearnScreen(),
      2 => const QuizScreen(),
      3 => const ChallengesScreen(),
      _ => const ProfileScreen(),
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: currentScreen,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppStrings.get('home', context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: AppStrings.get('learn', context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.quiz_outlined),
            selectedIcon: const Icon(Icons.quiz),
            label: AppStrings.get('quiz', context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: AppStrings.get('challenges', context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: AppStrings.get('profile', context),
          ),
        ],
      ),
    );
  }
}

class HubHomeScreen extends StatelessWidget {
  const HubHomeScreen({super.key, required this.onNavigateToTab});

  final ValueChanged<int> onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WelcomeCard(
                  title: AppStrings.get('welcomeTitle', context),
                  subtitle: AppStrings.get('welcomeSubtitle', context),
                  buttonText: AppStrings.get('getStarted', context),
                  onPressed: () => onNavigateToTab(1),
                ),
                const SizedBox(height: 16),
                _HubHeader(title: AppStrings.get('appName', context)),
                const SizedBox(height: 16),
                _ImpactStrip(
                  items: [
                    _ImpactItemData(
                      icon: Icons.co2,
                      value: '12.5 kg',
                      label: AppStrings.get('co2Saved', context),
                      color: colorScheme.secondary,
                    ),
                    _ImpactItemData(
                      icon: Icons.delete_outline,
                      value: '8.2 kg',
                      label: AppStrings.get('wasteReduced', context),
                      color: colorScheme.tertiary,
                    ),
                    _ImpactItemData(
                      icon: Icons.verified_outlined,
                      value: '15',
                      label: AppStrings.get('challengesCompleted', context),
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ProgressCard(
                  title: AppStrings.get('weeklyProgress', context),
                  progress: 15 / 24,
                  leadingText: '15/24 ${AppStrings.get('tasks', context)}',
                ),
                const SizedBox(height: 18),
                _HubTile(
                  icon: Icons.menu_book,
                  title: AppStrings.get('learnSdgs', context),
                  subtitle: 'تعلم، طبّق، وتابع أثرَك',
                  color: colorScheme.primary,
                  onTap: () => onNavigateToTab(1),
                ),
                const SizedBox(height: 12),
                _HubTile(
                  icon: Icons.quiz,
                  title: AppStrings.get('interactiveQuiz', context),
                  subtitle: 'اختبر معلوماتك بخطوات قصيرة',
                  color: colorScheme.secondary,
                  onTap: () => onNavigateToTab(2),
                ),
                const SizedBox(height: 12),
                _HubTile(
                  icon: Icons.flag,
                  title: AppStrings.get('tipsChallenges', context),
                  subtitle: 'مهام يومية بسيطة وواقعية',
                  color: const Color(0xFF0EA5E9),
                  onTap: () => onNavigateToTab(3),
                ),
                const SizedBox(height: 12),
                _HubTile(
                  icon: Icons.newspaper,
                  title: AppStrings.get('newsStories', context),
                  subtitle: 'قصص قصيرة وأفكار قابلة للتطبيق',
                  color: const Color(0xFF22C55E),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NewsStoriesScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('learnSdgs', context))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SdgCard(
            title: AppStrings.get('sdg11Title', context),
            subtitle: AppStrings.get('sdg11Subtitle', context),
            imageUrl: 'https://picsum.photos/seed/sdg11/1200/600',
            accent: colorScheme.primary,
            actions: [
              _SdgAction(
                label: AppStrings.get('learnMore', context),
                icon: Icons.info_outline,
                onTap: () {},
              ),
              _SdgAction(
                label: AppStrings.get('caseStudies', context),
                icon: Icons.article_outlined,
                onTap: () {},
              ),
              _SdgAction(
                label: AppStrings.get('watchVideo', context),
                icon: Icons.play_circle_outline,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SdgCard(
            title: AppStrings.get('sdg12Title', context),
            subtitle: AppStrings.get('sdg12Subtitle', context),
            imageUrl: 'https://picsum.photos/seed/sdg12/1200/600',
            accent: colorScheme.secondary,
            actions: [
              _SdgAction(
                label: AppStrings.get('learnMore', context),
                icon: Icons.info_outline,
                onTap: () {},
              ),
              _SdgAction(
                label: AppStrings.get('tipsTricks', context),
                icon: Icons.lightbulb_outline,
                onTap: () {},
              ),
              _SdgAction(
                label: AppStrings.get('quizMe', context),
                icon: Icons.quiz_outlined,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<_QuizQuestion> _questions = const [
    _QuizQuestion(
      question: 'ما فائدة استخدام المواصلات العامة؟',
      options: [
        'تقلل تلوث الهواء',
        'تستخدم طاقة أكثر',
        'تأخذ مساحة أكبر',
        'تنتج نفايات أكثر',
      ],
      correctIndex: 0,
      hint: 'فكر في عدد السيارات التي يتم الاستغناء عنها.',
    ),
    _QuizQuestion(
      question: 'أي خيار يقلل النفايات المنزلية؟',
      options: [
        'شراء عبوات أحادية الاستخدام',
        'إعادة استخدام العلب والمرطبانات',
        'رمي بقايا الطعام',
        'زيادة التغليف',
      ],
      correctIndex: 1,
      hint: 'الهدف هو تقليل ما تشتريه وتعيد استخدامه.',
    ),
  ];

  int _index = 0;
  int? _selected;
  bool _showAnswer = false;
  bool _showHint = false;

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('quiz', context))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    q.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(q.options.length, (i) {
                    final isSelected = _selected == i;
                    final isCorrect = i == q.correctIndex;
                    final bool showCorrect =
                        _showAnswer || (isSelected && _selected != null);

                    Color border = Colors.grey.shade200;
                    Color? fill;
                    IconData? icon;
                    Color? iconColor;

                    if (showCorrect && isCorrect) {
                      border = colorScheme.primary;
                      fill = colorScheme.primary.withAlpha(20);
                      icon = Icons.check_circle;
                      iconColor = colorScheme.primary;
                    } else if (showCorrect && isSelected && !isCorrect) {
                      border = Colors.red.shade400;
                      fill = Colors.red.withAlpha(15);
                      icon = Icons.cancel;
                      iconColor = Colors.red.shade400;
                    } else if (isSelected) {
                      border = colorScheme.secondary;
                      fill = colorScheme.secondary.withAlpha(20);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap:
                            () => setState(() {
                              _selected = i;
                              _showAnswer = false;
                              _showHint = false;
                            }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: fill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  q.options[i],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (icon != null) Icon(icon, color: iconColor),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_showHint) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary.withAlpha(20),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.tertiary.withAlpha(89),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              q.hint,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed:
                              () => setState(() => _showHint = !_showHint),
                          child: Text(AppStrings.get('hint', context)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              () => setState(() {
                                _showAnswer = true;
                                _showHint = false;
                              }),
                          child: Text(AppStrings.get('showAnswer', context)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: _next,
                          child: Text(AppStrings.get('nextQuestion', context)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ImpactPanel(
            title: AppStrings.get('trackImpact', context),
            rows: const [
              _ImpactRow(
                icon: Icons.recycling,
                label: 'CO₂ Saved',
                value: '12.5 kg',
              ),
              _ImpactRow(
                icon: Icons.delete_outline,
                label: 'Waste Reduced',
                value: '8.2 kg',
              ),
              _ImpactRow(
                icon: Icons.verified_outlined,
                label: 'Challenges Completed',
                value: '15',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: Text(AppStrings.get('addAction', context)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: Text(AppStrings.get('viewLeaderboard', context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _next() {
    setState(() {
      _index = (_index + 1) % _questions.length;
      _selected = null;
      _showAnswer = false;
      _showHint = false;
    });
  }
}

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  final List<_ChallengeItem> _items = [
    _ChallengeItem(
      title: 'تجنب الأكياس البلاستيكية',
      subtitle: 'استخدم حقيبة قماشية عند التسوق اليوم.',
    ),
    _ChallengeItem(
      title: 'قلّل استهلاك الماء',
      subtitle: 'أغلق الصنبور أثناء تنظيف الأسنان.',
    ),
    _ChallengeItem(
      title: 'إعادة التدوير',
      subtitle: 'افصل الورق والبلاستيك في المنزل.',
    ),
    _ChallengeItem(
      title: 'نقل أخضر',
      subtitle: 'جرّب المشي أو الدراجة لمسافة قصيرة.',
    ),
  ];

  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('challenges', context)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppStrings.get('tipsChallenges', context)),
            Tab(text: AppStrings.get('newsStories', context)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = _items[i];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: CheckboxListTile(
                  value: item.done,
                  onChanged: (v) => setState(() => item.done = v ?? false),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item.subtitle),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            },
          ),
          const NewsStoriesBody(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NewsStoriesScreen extends StatelessWidget {
  const NewsStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('newsStories', context))),
      body: const NewsStoriesBody(),
    );
  }
}

class NewsStoriesBody extends StatelessWidget {
  const NewsStoriesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Image.network(
                'https://picsum.photos/seed/story_${index + 1}/1200/600',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              ListTile(
                title: Text(
                  index.isEven
                      ? 'قصة قصيرة: عادة تغيّر يومك'
                      : 'خبر أخضر: مبادرة جديدة',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'أفكار سريعة وعملية لتقليل الأثر البيئي خطوة بخطوة.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('profile', context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://api.dicebear.com/7.x/avataaars/svg?seed=Ahmed',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'أحمد علي',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'بطل بيئي - مستوى 12',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildStatGrid(),
            const SizedBox(height: 32),
            _ImpactPanel(
              title: AppStrings.get('trackImpact', context),
              rows: [
                _ImpactRow(
                  icon: Icons.co2,
                  label: AppStrings.get('co2Saved', context),
                  value: '12.5 kg',
                ),
                _ImpactRow(
                  icon: Icons.delete_outline,
                  label: AppStrings.get('wasteReduced', context),
                  value: '8.2 kg',
                ),
                _ImpactRow(
                  icon: Icons.verified_outlined,
                  label: AppStrings.get('challengesCompleted', context),
                  value: '15',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLeaderboardPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _statCard('الأوسمة', '15', Icons.emoji_events, Colors.orange),
        _statCard('التحديات', '42', Icons.task_alt, Colors.green),
        _statCard('المساهمة', 'Top 5%', Icons.trending_up, Colors.blue),
        _statCard('الأشجار', '3', Icons.park, Colors.brown),
      ],
    );
  }

  Widget _statCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Text(
            val,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'لوحة المتصدرين',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (index) => ListTile(
            leading: Text(
              '#${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            title: Text(index == 0 ? 'محمد خالد' : 'سارة منصور'),
            trailing: Text(
              '${2500 - (index * 200)} نقطة',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6F1),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -22,
            child: Icon(
              Icons.eco,
              size: 140,
              color: colorScheme.primary.withAlpha(26),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 190,
                height: 44,
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(31),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.eco, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Learn, Act, Track Your Impact',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withAlpha(64), color.withAlpha(20)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withAlpha(64)),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactItemData {
  const _ImpactItemData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
}

class _ImpactStrip extends StatelessWidget {
  const _ImpactStrip({required this.items});

  final List<_ImpactItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children:
            items
                .map(
                  (item) => Expanded(
                    child: Column(
                      children: [
                        Icon(item.icon, color: item.color),
                        const SizedBox(height: 6),
                        Text(
                          item.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.progress,
    required this.leadingText,
  });

  final String title;
  final double progress;
  final String leadingText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clamped = progress.clamp(0.0, 1.0);
    final percent = (clamped * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 650),
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            leadingText,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SdgAction {
  const _SdgAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _SdgCard extends StatelessWidget {
  const _SdgCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.accent,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final Color accent;
  final List<_SdgAction> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(235),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: accent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'SDG',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      actions
                          .map(
                            (a) => FilledButton.tonalIcon(
                              onPressed: a.onTap,
                              icon: Icon(a.icon, size: 18),
                              label: Text(a.label),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactRow {
  const _ImpactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _ImpactPanel extends StatelessWidget {
  const _ImpactPanel({required this.title, required this.rows});

  final String title;
  final List<_ImpactRow> rows;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...rows.map((r) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.primary.withAlpha(31)),
              ),
              child: Row(
                children: [
                  Icon(r.icon, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      r.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    r.value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChallengeItem {
  _ChallengeItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
  bool done = false;
}

class _QuizQuestion {
  const _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.hint,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String hint;
}
''';
