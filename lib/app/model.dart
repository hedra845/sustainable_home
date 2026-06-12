import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum NotificationKind { challenge, tip, news }

class AppNotification {
  AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromRow(Map<String, dynamic> row) {
    final kind = switch ((row['kind'] as String?)?.toLowerCase()) {
      'challenge' => NotificationKind.challenge,
      'tip' => NotificationKind.tip,
      _ => NotificationKind.news,
    };
    return AppNotification(
      id: row['id'].toString(),
      kind: kind,
      title: (row['title'] ?? '').toString(),
      body: (row['body'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((row['created_at'] ?? '').toString()) ??
          DateTime.now(),
      isRead: (row['is_read'] as bool?) ?? false,
    );
  }

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;
}

class SdgGoal {
  SdgGoal({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.imageUrl,
  });

  factory SdgGoal.fromRow(Map<String, dynamic> row) {
    return SdgGoal(
      id: (row['id'] as num?)?.toInt() ?? 0,
      titleEn: (row['title_en'] ?? '').toString(),
      titleAr: (row['title_ar'] ?? '').toString(),
      subtitleEn: (row['subtitle_en'] ?? '').toString(),
      subtitleAr: (row['subtitle_ar'] ?? '').toString(),
      imageUrl: (row['image_url'] ?? '').toString(),
    );
  }

  final int id;
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final String imageUrl;

  String titleFor(Locale locale) =>
      locale.languageCode == 'ar' ? titleAr : titleEn;
  String subtitleFor(Locale locale) =>
      locale.languageCode == 'ar' ? subtitleAr : subtitleEn;
}

class Challenge {
  Challenge({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.co2DeltaKg,
    required this.wasteDeltaKg,
    required this.sortOrder,
  });

  factory Challenge.fromRow(Map<String, dynamic> row) {
    return Challenge(
      id: row['id'].toString(),
      titleEn: (row['title_en'] ?? '').toString(),
      titleAr: (row['title_ar'] ?? '').toString(),
      bodyEn: (row['body_en'] ?? '').toString(),
      bodyAr: (row['body_ar'] ?? '').toString(),
      co2DeltaKg: (row['impact_co2_delta'] as num?)?.toDouble() ?? 0,
      wasteDeltaKg: (row['impact_waste_delta'] as num?)?.toDouble() ?? 0,
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final double co2DeltaKg;
  final double wasteDeltaKg;
  final int sortOrder;

  String titleFor(Locale locale) =>
      locale.languageCode == 'ar' ? titleAr : titleEn;
  String bodyFor(Locale locale) =>
      locale.languageCode == 'ar' ? bodyAr : bodyEn;
}

class EducationalVideo {
  EducationalVideo({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.category,
    this.sdgGoalId,
  });

  factory EducationalVideo.fromRow(Map<String, dynamic> row) {
    return EducationalVideo(
      id: row['id'].toString(),
      titleAr: (row['title_ar'] ?? '').toString(),
      titleEn: (row['title_en'] ?? '').toString(),
      descriptionAr: (row['description_ar'] ?? '').toString(),
      descriptionEn: (row['description_en'] ?? '').toString(),
      thumbnailUrl: (row['thumbnail_url'] ?? '').toString(),
      videoUrl: (row['video_url'] ?? '').toString(),
      category: (row['category'] ?? 'general').toString(),
      sdgGoalId: (row['sdg_goal_id'] as num?)?.toInt(),
    );
  }

  final String id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String thumbnailUrl;
  final String videoUrl;
  final String category;
  final int? sdgGoalId;

  String titleFor(Locale locale) =>
      locale.languageCode == 'ar' ? titleAr : titleEn;
  String descriptionFor(Locale locale) =>
      locale.languageCode == 'ar' ? descriptionAr : descriptionEn;
}

class SurveyQuestion {
  SurveyQuestion({
    required this.id,
    required this.questionAr,
    required this.questionEn,
    required this.type,
    required this.optionsAr,
    required this.optionsEn,
    required this.required,
    required this.sortOrder,
  });

  factory SurveyQuestion.fromRow(Map<String, dynamic> row) {
    return SurveyQuestion(
      id: row['id'].toString(),
      questionAr: (row['question_ar'] ?? '').toString(),
      questionEn: (row['question_en'] ?? '').toString(),
      type: (row['type'] ?? 'radio').toString(),
      optionsAr: List<String>.from(row['options_ar'] ?? []),
      optionsEn: List<String>.from(row['options_en'] ?? []),
      required: (row['required'] as bool?) ?? true,
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String questionAr;
  final String questionEn;
  final String type; // 'text', 'radio'
  final List<String> optionsAr;
  final List<String> optionsEn;
  final bool required;
  final int sortOrder;

  String questionFor(Locale locale) =>
      locale.languageCode == 'ar' ? questionAr : questionEn;
  List<String> optionsFor(Locale locale) =>
      locale.languageCode == 'ar' ? optionsAr : optionsEn;
}

enum StoryKind { all, news, story }

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.questionAr,
    required this.questionEn,
    required this.optionsAr,
    required this.optionsEn,
    required this.correctIndex,
    this.hintAr,
    this.hintEn,
  });

  factory QuizQuestion.fromRow(Map<String, dynamic> row) {
    return QuizQuestion(
      id: row['id'].toString(),
      questionAr: (row['question_ar'] ?? '').toString(),
      questionEn: (row['question_en'] ?? '').toString(),
      optionsAr: List<String>.from(row['options_ar'] ?? []),
      optionsEn: List<String>.from(row['options_en'] ?? []),
      correctIndex: (row['correct_index'] as num?)?.toInt() ?? 0,
      hintAr: row['hint_ar']?.toString(),
      hintEn: row['hint_en']?.toString(),
    );
  }

  final String id;
  final String questionAr;
  final String questionEn;
  final List<String> optionsAr;
  final List<String> optionsEn;
  final int correctIndex;
  final String? hintAr;
  final String? hintEn;

  String questionFor(Locale locale) =>
      locale.languageCode == 'ar' ? questionAr : questionEn;
  List<String> optionsFor(Locale locale) =>
      locale.languageCode == 'ar' ? optionsAr : optionsEn;
  String? hintFor(Locale locale) =>
      locale.languageCode == 'ar' ? hintAr : hintEn;
}

class AppStory {
  const AppStory({
    required this.id,
    required this.kind,
    required this.imageUrl,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.contentAr,
    required this.contentEn,
    required this.minutesRead,
  });

  final String id;
  final StoryKind kind;
  final String imageUrl;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final List<String> contentAr;
  final List<String> contentEn;
  final int minutesRead;

  factory AppStory.fromRow(Map<String, dynamic> map) {
    return AppStory(
      id: map['id'].toString(),
      kind: StoryKind.values.firstWhere(
        (e) => e.name == map['kind'],
        orElse: () => StoryKind.story,
      ),
      imageUrl: map['image_url'] ?? '',
      titleAr: map['title_ar'] ?? '',
      titleEn: map['title_en'] ?? '',
      subtitleAr: map['subtitle_ar'] ?? '',
      subtitleEn: map['subtitle_en'] ?? '',
      contentAr: List<String>.from(map['content_ar'] ?? []),
      contentEn: List<String>.from(map['content_en'] ?? []),
      minutesRead: map['minutes_read'] ?? 0,
    );
  }

  String titleFor(Locale locale) =>
      locale.languageCode == 'ar' ? titleAr : titleEn;
  String subtitleFor(Locale locale) =>
      locale.languageCode == 'ar' ? subtitleAr : subtitleEn;
  List<String> contentFor(Locale locale) =>
      locale.languageCode == 'ar' ? contentAr : contentEn;
}

class LeaderboardEntry {
  LeaderboardEntry({required this.name, required this.points, this.avatarUrl});

  final String name;
  final double points;
  final String? avatarUrl;
}

class AboutUs {
  AboutUs({
    required this.titleAr,
    required this.titleEn,
    required this.contentAr,
    required this.contentEn,
    this.imageUrl,
    this.email,
    this.website,
  });

  final String titleAr;
  final String titleEn;
  final String contentAr;
  final String contentEn;
  final String? imageUrl;
  final String? email;
  final String? website;

  String titleFor(Locale locale) =>
      locale.languageCode == 'ar' ? titleAr : titleEn;
  String contentFor(Locale locale) =>
      locale.languageCode == 'ar' ? contentAr : contentEn;

  factory AboutUs.fromRow(Map<String, dynamic> row) {
    return AboutUs(
      titleAr: row['title_ar'] ?? '',
      titleEn: row['title_en'] ?? '',
      contentAr: row['content_ar'] ?? '',
      contentEn: row['content_en'] ?? '',
      imageUrl: row['image_url'],
      email: row['email'],
      website: row['website'],
    );
  }
}

class SustainabilityModel extends ChangeNotifier {
  SustainabilityModel({
    required this.supabaseEnabled,
    Locale initialLocale = const Locale('ar'),
    ThemeMode initialThemeMode = ThemeMode.light,
    bool initialHasSeenOnboarding = false,
    bool initialHasSelectedLanguage = false,
    bool initialHasCompletedSurvey = false,
  }) : _locale = initialLocale,
       _themeMode = initialThemeMode,
       _hasSeenOnboarding = initialHasSeenOnboarding,
       _hasSelectedLanguage = initialHasSelectedLanguage,
       _hasCompletedSurvey = initialHasCompletedSurvey,
       _isAuthenticated = false {
    // Always seed local data first so we don't have empty screens
    _seedLocal();

    if (supabaseEnabled) {
      unawaited(_bootstrapSupabase());
    }
  }

  final bool supabaseEnabled;

  SupabaseClient? get _client {
    if (!supabaseEnabled) return null;
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('Error accessing Supabase client: $e');
      return null;
    }
  }

  StreamSubscription<AuthState>? _authSub;
  RealtimeChannel? _notificationsChannel;
  RealtimeChannel? _publicDataChannel;

  Locale _locale;
  ThemeMode _themeMode;

  String? _fullName;
  String? _avatarUrl;
  double _co2SavedKg = 0;
  double _wasteReducedKg = 0;
  int _weeklyGoal = 4;
  bool _hasSeenOnboarding;
  bool _hasSelectedLanguage;
  bool _hasCompletedSurvey = false;
  bool _hasCompletedSurvey2 = false;
  bool _hasCompletedQuiz = false;
  bool _hasCompletedEvaluation = false;
  bool _isAuthenticated;

  final List<SdgGoal> _sdgGoals = <SdgGoal>[];
  final List<Challenge> _challenges = <Challenge>[];
  final List<SurveyQuestion> _surveyQuestions = <SurveyQuestion>[];
  final List<SurveyQuestion> _surveyQuestions2 = <SurveyQuestion>[];
  final List<QuizQuestion> _quizQuestions = <QuizQuestion>[];
  final List<EducationalVideo> _educationalVideos = <EducationalVideo>[];
  final List<AppStory> _stories = <AppStory>[];
  final Set<String> _completedChallengeIds = <String>{};
  final List<AppNotification> _notifications = <AppNotification>[];
  final Set<int> _favoriteGoalIds = <int>{};
  final List<LeaderboardEntry> _leaderboard = <LeaderboardEntry>[];
  AboutUs? _aboutUs;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  String? get fullName => _fullName;
  String? get avatarUrl => _avatarUrl;

  double get co2SavedKg => _co2SavedKg;
  double get wasteReducedKg => _wasteReducedKg;
  int get weeklyGoal =>
      _challenges.isNotEmpty ? _challenges.length : _weeklyGoal;

  List<SdgGoal> get sdgGoals => List.unmodifiable(_sdgGoals);
  List<Challenge> get challenges => List.unmodifiable(_challenges);
  List<SurveyQuestion> get surveyQuestions =>
      List.unmodifiable(_surveyQuestions);
  List<SurveyQuestion> get surveyQuestions2 =>
      List.unmodifiable(_surveyQuestions2);
  List<QuizQuestion> get quizQuestions => List.unmodifiable(_quizQuestions);
  List<EducationalVideo> get educationalVideos =>
      List.unmodifiable(_educationalVideos);
  List<AppStory> get stories => List.unmodifiable(_stories);
  List<LeaderboardEntry> get leaderboard => List.unmodifiable(_leaderboard);
  AboutUs? get aboutUs => _aboutUs;

  int get challengesCompleted =>
      _completedChallengeIds.where((id) => id != 'quiz_completed').length;
  double get weeklyProgress =>
      weeklyGoal <= 0 ? 0 : (challengesCompleted / weeklyGoal).clamp(0.0, 1.0);

  bool isChallengeCompleted(String id) => _completedChallengeIds.contains(id);
  bool get hasCompletedSurvey => _hasCompletedSurvey;
  bool get hasCompletedSurvey2 => _hasCompletedSurvey2;
  bool get hasCompletedQuiz => _hasCompletedQuiz;
  bool get hasCompletedEvaluation => _hasCompletedEvaluation;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  bool get isAuthenticated => _isAuthenticated;

  bool get canShowSurveyAndEvaluation =>
      _hasCompletedQuiz &&
      challengesCompleted >= weeklyGoal &&
      !_hasCompletedEvaluation; // يظهر فوراً بعد إنهاء الاختبار والتحديات إذا لم يتم التقييم مسبقاً

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;
  Set<int> get favoriteGoalIds => Set.unmodifiable(_favoriteGoalIds);
  bool isGoalFavorited(int goalId) => _favoriteGoalIds.contains(goalId);

  String? get _userId => _client?.auth.currentUser?.id;

  @override
  void dispose() {
    _authSub?.cancel();
    _stopNotificationsRealtime();
    _stopPublicDataRealtime();
    super.dispose();
  }

  Future<void> _bootstrapSupabase() async {
    final client = _client;
    if (client == null) return;

    try {
      _isAuthenticated = client.auth.currentSession != null;
      if (_isAuthenticated) {
        _startNotificationsRealtime();
      }
      _startPublicDataRealtime();
      _authSub = client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        _isAuthenticated = session != null;
        if (_isAuthenticated) {
          _startNotificationsRealtime();
          unawaited(_refreshAllForUser());
        } else {
          _stopNotificationsRealtime();
          _completedChallengeIds.clear();
          _notifications.clear();
        }
        notifyListeners();
      });

      await refreshPublicData();
      if (_isAuthenticated) {
        await _refreshAllForUser();
      }
    } catch (e) {
      debugPrint('Supabase bootstrap failed: $e');
    }
    notifyListeners();
  }

  void _startPublicDataRealtime() {
    if (!supabaseEnabled) return;
    _stopPublicDataRealtime();

    final client = _client!;
    final channel = client.channel('public:data');
    _publicDataChannel = channel;

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'challenges',
          callback: (_) => refreshChallenges(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'sdg_goals',
          callback: (_) => refreshSdgGoals(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'educational_videos',
          callback: (_) => refreshEducationalVideos(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stories',
          callback: (_) => refreshStories(),
        )
        .subscribe();
  }

  void _stopPublicDataRealtime() {
    if (!supabaseEnabled) return;
    final channel = _publicDataChannel;
    if (channel == null) return;
    try {
      _client?.removeChannel(channel);
    } catch (_) {}
    _publicDataChannel = null;
  }

  void _startNotificationsRealtime() {
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;

    _stopNotificationsRealtime();

    final client = _client!;
    final channel = client.channel('public:notifications:user:$uid');
    _notificationsChannel = channel;

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            if (row.isEmpty) return;
            final n = AppNotification.fromRow(row);
            final existing = _notifications.indexWhere((x) => x.id == n.id);
            if (existing == -1) {
              _notifications.insert(0, n);
            } else {
              _notifications[existing] = n;
            }
            notifyListeners();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            if (row.isEmpty) return;
            final n = AppNotification.fromRow(row);
            final index = _notifications.indexWhere((x) => x.id == n.id);
            if (index == -1) {
              _notifications.insert(0, n);
            } else {
              _notifications[index] = n;
            }
            notifyListeners();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (payload) {
            final row = payload.oldRecord;
            final id = row['id']?.toString();
            if (id == null || id.isEmpty) return;
            final before = _notifications.length;
            _notifications.removeWhere((n) => n.id == id);
            if (_notifications.length != before) notifyListeners();
          },
        )
        .subscribe();
  }

  void _stopNotificationsRealtime() {
    if (!supabaseEnabled) return;
    final channel = _notificationsChannel;
    if (channel == null) return;
    try {
      _client?.removeChannel(channel);
    } catch (_) {}
    _notificationsChannel = null;
  }

  void _seedLocal() {
    final now = DateTime.now();
    _challenges
      ..clear()
      ..addAll([
        Challenge(
          id: 'bags',
          titleEn: 'Avoid plastic bags',
          titleAr: 'تجنب الأكياس البلاستيكية',
          bodyEn: 'Use a reusable bag when shopping.',
          bodyAr: 'استخدم حقيبة قماشية عند التسوق اليوم.',
          co2DeltaKg: 0.2,
          wasteDeltaKg: 0.15,
          sortOrder: 1,
        ),
        Challenge(
          id: 'water',
          titleEn: 'Save water',
          titleAr: 'قلّل استهلاك الماء',
          bodyEn: 'Turn off the tap while brushing.',
          bodyAr: 'أغلق الصنبور أثناء تنظيف الأسنان.',
          co2DeltaKg: 0.1,
          wasteDeltaKg: 0,
          sortOrder: 2,
        ),
        Challenge(
          id: 'recycle',
          titleEn: 'Recycle at home',
          titleAr: 'إعادة التدوير',
          bodyEn: 'Separate paper and plastic.',
          bodyAr: 'افصل الورق والبلاستيك في المنزل.',
          co2DeltaKg: 0.15,
          wasteDeltaKg: 0.25,
          sortOrder: 3,
        ),
        Challenge(
          id: 'transport',
          titleEn: 'Green transport',
          titleAr: 'نقل أخضر',
          bodyEn: 'Walk, bike, or use public transport.',
          bodyAr: 'جرّب المشي أو الدراجة لمسافة قصيرة.',
          co2DeltaKg: 0.3,
          wasteDeltaKg: 0,
          sortOrder: 4,
        ),
      ]);
    _surveyQuestions
      ..clear()
      ..addAll([
        SurveyQuestion(
          id: '1',
          questionAr: 'العمر (بالسنوات)',
          questionEn: 'Age (Years)',
          type: 'text',
          optionsAr: [],
          optionsEn: [],
          required: true,
          sortOrder: 1,
        ),
        SurveyQuestion(
          id: '2',
          questionAr: 'الجنس',
          questionEn: 'Gender',
          type: 'radio',
          optionsAr: ['ذكر', 'أنثى'],
          optionsEn: ['Male', 'Female'],
          required: true,
          sortOrder: 2,
        ),
        SurveyQuestion(
          id: '3',
          questionAr: 'أعلى مستوى تعليمي',
          questionEn: 'Highest Level of Education',
          type: 'radio',
          optionsAr: [
            'ثانوية عامة أو ما يعادلها',
            'تدريب مهني/تقني',
            'درجة البكالوريوس',
            'درجة الماجستير',
            'دكتوراه أو أعلى',
          ],
          optionsEn: [
            'High School or equivalent',
            'Vocational/Technical Training',
            'Bachelor\'s Degree',
            'Master\'s Degree',
            'Doctorate or higher',
          ],
          required: true,
          sortOrder: 3,
        ),
        SurveyQuestion(
          id: '4',
          questionAr: 'تكوين الأسرة الحالي',
          questionEn: 'Current Household Composition',
          type: 'radio',
          optionsAr: [
            'أعيش بمفردي',
            'أعيش مع شريك/زوج',
            'أعيش مع شريك/زوج وأطفال',
            'أعيش مع عائلة/أصدقاء آخرين',
            'أخرى',
          ],
          optionsEn: [
            'Live alone',
            'Live with partner/spouse',
            'Live with partner/spouse and child(ren)',
            'Live with other family/friends',
            'Other',
          ],
          required: true,
          sortOrder: 4,
        ),
        SurveyQuestion(
          id: '5',
          questionAr: 'نوع السكن',
          questionEn: 'Type of Residence',
          type: 'radio',
          optionsAr: ['شقة/كوندو', 'منزل لعائلة واحدة', 'أخرى'],
          optionsEn: ['Apartment/Condo', 'Single-family house', 'Other'],
          required: true,
          sortOrder: 5,
        ),
        SurveyQuestion(
          id: '6',
          questionAr: 'هل تملك أم تستأجر منزلك؟',
          questionEn: 'Do you own or rent your home?',
          type: 'radio',
          optionsAr: ['تملك', 'إيجار'],
          optionsEn: ['Own', 'Rent'],
          required: true,
          sortOrder: 6,
        ),
        SurveyQuestion(
          id: '7',
          questionAr: 'بشكل عام، كيف تصف المنطقة التي تعيش فيها؟',
          questionEn: 'How would you describe the area you live in?',
          type: 'radio',
          optionsAr: ['حضري (مدينة)', 'ضواحي', 'ريفي'],
          optionsEn: ['Urban', 'Suburban', 'Rural'],
          required: true,
          sortOrder: 7,
        ),
      ]);
    _surveyQuestions2
      ..clear()
      ..addAll([
        SurveyQuestion(
          id: 's2_1',
          questionAr: 'ما هو شعورك تجاه الاستدامة بعد استخدام التطبيق؟',
          questionEn:
              'How do you feel about sustainability after using the app?',
          type: 'radio',
          optionsAr: ['متحمس جداً', 'مهتم', 'محايد', 'غير مهتم'],
          optionsEn: [
            'Very Excited',
            'Interested',
            'Neutral',
            'Not Interested',
          ],
          required: true,
          sortOrder: 1,
        ),
        SurveyQuestion(
          id: 's2_2',
          questionAr: 'هل تنوي الاستمرار في التحديات الأسبوعية؟',
          questionEn: 'Do you intend to continue the weekly challenges?',
          type: 'radio',
          optionsAr: ['نعم بالتأكيد', 'ربما', 'لا'],
          optionsEn: ['Yes definitely', 'Maybe', 'No'],
          required: true,
          sortOrder: 2,
        ),
      ]);
    _notifications
      ..clear()
      ..addAll([
        AppNotification(
          id: 'n1',
          kind: NotificationKind.challenge,
          title: 'تحدّي أسبوعي جديد',
          body: 'أكمل 3 إجراءات صديقة للبيئة هذا الأسبوع لتتقدم.',
          createdAt: now.subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        AppNotification(
          id: 'n2',
          kind: NotificationKind.tip,
          title: 'نصيحة سريعة',
          body: 'استخدم زجاجة قابلة لإعادة الاستخدام لتقليل البلاستيك.',
          createdAt: now.subtract(const Duration(hours: 6)),
          isRead: true,
        ),
      ]);
    _leaderboard
      ..clear()
      ..addAll([
        LeaderboardEntry(name: 'محمد خالد', points: 2500),
        LeaderboardEntry(name: 'سارة منصور', points: 2300),
        LeaderboardEntry(name: 'يوسف أحمد', points: 2100),
      ]);
    _quizQuestions
      ..clear()
      ..addAll([
        QuizQuestion(
          id: '1',
          questionAr: 'ما فائدة استخدام المواصلات العامة؟',
          questionEn: 'What is the benefit of using public transport?',
          optionsAr: [
            'تقلل تلوث الهواء',
            'تستخدم طاقة أكثر',
            'تأخذ مساحة أكبر',
            'تنتج نفايات أكثر',
          ],
          optionsEn: [
            'Reduces air pollution',
            'Uses more energy',
            'Takes up more space',
            'Produces more waste',
          ],
          correctIndex: 0,
          hintAr: 'فكر في عدد السيارات التي يتم الاستغناء عنها.',
          hintEn: 'Think about the number of cars being replaced.',
        ),
        QuizQuestion(
          id: '2',
          questionAr: 'أي خيار يقلل النفايات المنزلية؟',
          questionEn: 'Which option reduces household waste?',
          optionsAr: [
            'شراء عبوات أحادية الاستخدام',
            'إعادة استخدام العلب والمرطبانات',
            'رمي بقايا الطعام',
            'زيادة التغليف',
          ],
          optionsEn: [
            'Buying single-use containers',
            'Reusing cans and jars',
            'Throwing away food scraps',
            'Increasing packaging',
          ],
          correctIndex: 1,
          hintAr: 'الهدف هو تقليل ما تشتريه وتعيد استخدامه.',
          hintEn: 'The goal is to reduce what you buy and reuse it.',
        ),
      ]);
    notifyListeners();
  }

  Future<void> refreshPublicData() async {
    if (!supabaseEnabled) return;
    await Future.wait([
      refreshSdgGoals(),
      refreshChallenges(),
      refreshQuizQuestions(),
      refreshSurveyQuestions(),
      refreshSurveyQuestions2(),
      refreshEducationalVideos(),
      refreshStories(),
      refreshLeaderboard(),
      refreshAboutUs(),
    ]);
  }

  Future<void> refreshQuizQuestions() async {
    if (!supabaseEnabled) {
      _quizQuestions
        ..clear()
        ..addAll([
          QuizQuestion(
            id: '1',
            questionAr: 'ما فائدة استخدام المواصلات العامة؟',
            questionEn: 'What is the benefit of using public transport?',
            optionsAr: [
              'تقلل تلوث الهواء',
              'تستخدم طاقة أكثر',
              'تأخذ مساحة أكبر',
              'تنتج نفايات أكثر',
            ],
            optionsEn: [
              'Reduces air pollution',
              'Uses more energy',
              'Takes up more space',
              'Produces more waste',
            ],
            correctIndex: 0,
            hintAr: 'فكر في عدد السيارات التي يتم الاستغناء عنها.',
            hintEn: 'Think about the number of cars being replaced.',
          ),
          QuizQuestion(
            id: '2',
            questionAr: 'أي خيار يقلل النفايات المنزلية؟',
            questionEn: 'Which option reduces household waste?',
            optionsAr: [
              'شراء عبوات أحادية الاستخدام',
              'إعادة استخدام العلب والمرطبانات',
              'رمي بقايا الطعام',
              'زيادة التغليف',
            ],
            optionsEn: [
              'Buying single-use containers',
              'Reusing cans and jars',
              'Throwing away food scraps',
              'Increasing packaging',
            ],
            correctIndex: 1,
            hintAr: 'الهدف هو تقليل ما تشتريه وتعيد استخدامه.',
            hintEn: 'The goal is to reduce what you buy and reuse it.',
          ),
        ]);
      notifyListeners();
      return;
    }
    try {
      final rows = await _client!.from('quiz_questions').select().order('id');
      _quizQuestions
        ..clear()
        ..addAll(
          (rows as List).cast<Map<String, dynamic>>().map(QuizQuestion.fromRow),
        );
      notifyListeners();
    } catch (_) {
      // fallback to seed
    }
  }

  Future<void> submitQuizAnswer({
    required String questionId,
    required int selectedOptionIndex,
    required bool isCorrect,
  }) async {
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client!.from('quiz_answers').upsert({
        'user_id': uid,
        'question_id': questionId,
        'selected_option_index': selectedOptionIndex,
        'is_correct': isCorrect,
      }, onConflict: 'user_id,question_id');
    } catch (e) {
      debugPrint('Error submitting quiz answer: $e');
    }
  }

  Future<void> submitQuizAnswers(List<Map<String, dynamic>> answers) async {
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    if (answers.isEmpty) return;

    try {
      final rows = answers.map((a) => {...a, 'user_id': uid}).toList();
      debugPrint('Submitting ${rows.length} quiz answers to Supabase...');
      final response = await _client!
          .from('quiz_answers')
          .upsert(rows, onConflict: 'user_id,question_id');
      debugPrint('Quiz answers submitted successfully');
    } catch (e) {
      debugPrint('Error submitting quiz answers: $e');
    }
  }

  Future<void> submitQuizResult({
    required int score,
    required int totalQuestions,
  }) async {
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client!.from('quiz_results').upsert({
        'user_id': uid,
        'score': score,
        'total_questions': totalQuestions,
        'completed_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Quiz result submitted successfully');
    } catch (e) {
      debugPrint('Error submitting quiz result: $e');
    }
  }

  Future<void> refreshSurveyQuestions2() async {
    if (!supabaseEnabled) return;
    try {
      final rows = await _client!
          .from('survey_questions2')
          .select()
          .order('sort_order');
      _surveyQuestions2
        ..clear()
        ..addAll(
          (rows as List).cast<Map<String, dynamic>>().map(
            SurveyQuestion.fromRow,
          ),
        );
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> refreshStories() async {
    if (!supabaseEnabled) return;
    try {
      final rows = await _client!
          .from('stories')
          .select()
          .order('created_at', ascending: false);
      _stories
        ..clear()
        ..addAll(
          (rows as List).cast<Map<String, dynamic>>().map(AppStory.fromRow),
        );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refreshAboutUs() async {
    if (!supabaseEnabled) return;
    try {
      final res = await _client!.from('about_us').select().maybeSingle();
      if (res != null) {
        _aboutUs = AboutUs.fromRow(res);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing About Us: $e');
    }
  }

  Future<void> refreshEducationalVideos() async {
    if (!supabaseEnabled) return;
    try {
      final rows = await _client!.from('educational_videos').select();
      _educationalVideos
        ..clear()
        ..addAll(
          (rows as List).cast<Map<String, dynamic>>().map(
            EducationalVideo.fromRow,
          ),
        );
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> refreshSurveyQuestions() async {
    if (!supabaseEnabled) return;
    try {
      final rows = await _client!
          .from('survey_questions')
          .select()
          .order('sort_order');
      _surveyQuestions
        ..clear()
        ..addAll(
          (rows as List).cast<Map<String, dynamic>>().map(
            SurveyQuestion.fromRow,
          ),
        );
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> refreshSdgGoals() async {
    if (!supabaseEnabled) return;
    final rows = await _client!.from('sdg_goals').select().order('id');
    _sdgGoals
      ..clear()
      ..addAll(
        (rows as List).cast<Map<String, dynamic>>().map(SdgGoal.fromRow),
      );
    notifyListeners();
  }

  Future<void> refreshChallenges() async {
    if (!supabaseEnabled) return;
    final rows = await _client!
        .from('challenges')
        .select()
        .eq('active', true)
        .order('sort_order');
    _challenges
      ..clear()
      ..addAll(
        (rows as List).cast<Map<String, dynamic>>().map(Challenge.fromRow),
      );
    notifyListeners();
  }

  Future<void> _refreshAllForUser() async {
    await Future.wait([
      refreshProfile(),
      refreshNotifications(),
      refreshChallengeCompletions(),
      refreshFavorites(),
      refreshLeaderboard(),
    ]);
  }

  Future<void> refreshLeaderboard() async {
    if (!supabaseEnabled) return;
    try {
      final rows = await _client!
          .from('profiles')
          .select('full_name, avatar_url, co2_saved_kg')
          .order('co2_saved_kg', ascending: false)
          .limit(10);

      _leaderboard
        ..clear()
        ..addAll(
          (rows as List).cast<Map<String, dynamic>>().map((row) {
            // Rank will be added based on list index in UI or model
            // For now just create entries
            return LeaderboardEntry(
              name: (row['full_name'] ?? 'Eco Hero').toString(),
              points: ((row['co2_saved_kg'] as num?)?.toDouble() ?? 0) * 10,
              avatarUrl: row['avatar_url']?.toString(),
            );
          }),
        );
      notifyListeners();
    } catch (e) {
      debugPrint('Leaderboard fetch error: $e');
    }
  }

  String? _authFullName() {
    final user = _client?.auth.currentUser;
    final meta = user?.userMetadata;
    final v = meta?['full_name'] ?? meta?['name'] ?? meta?['fullName'];
    final t = v?.toString().trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }

  Future<void> refreshProfile() async {
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;

    Map<String, dynamic>? row;
    try {
      row =
          await _client!.from('profiles').select().eq('id', uid).maybeSingle();
    } catch (_) {
      return;
    }

    if (row == null) return;

    final existing = (row['full_name'] ?? '').toString().trim();
    final authName = _authFullName();
    if (existing.isEmpty && authName != null) {
      try {
        await _client!
            .from('profiles')
            .update({'full_name': authName})
            .eq('id', uid);
        row['full_name'] = authName;
      } catch (_) {}
    }

    _fullName =
        (row['full_name'] ?? '').toString().trim().isEmpty
            ? null
            : (row['full_name'] ?? '').toString();
    _avatarUrl =
        (row['avatar_url'] ?? '').toString().trim().isEmpty
            ? null
            : (row['avatar_url'] ?? '').toString();

    final localeText = (row['locale'] ?? 'ar').toString();
    _locale = Locale(localeText == 'en' ? 'en' : 'ar');

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('selectedLanguage', _locale.languageCode);
    });

    final themeText = (row['theme_mode'] ?? 'light').toString();
    _themeMode = themeText == 'dark' ? ThemeMode.dark : ThemeMode.light;

    _weeklyGoal = (row['weekly_goal'] as num?)?.toInt() ?? _weeklyGoal;
    _co2SavedKg = (row['co2_saved_kg'] as num?)?.toDouble() ?? _co2SavedKg;
    _wasteReducedKg =
        (row['waste_reduced_kg'] as num?)?.toDouble() ?? _wasteReducedKg;
    _hasCompletedSurvey = (row['has_completed_survey'] as bool?) ?? false;
    _hasCompletedSurvey2 = (row['has_completed_survey2'] as bool?) ?? false;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('hasCompletedSurvey', _hasCompletedSurvey);
    });

    _hasCompletedQuiz = (row['has_completed_quiz'] as bool?) ?? false;
    _hasCompletedEvaluation =
        (row['has_completed_evaluation'] as bool?) ?? false;
    notifyListeners();
  }

  Future<void> refreshNotifications() async {
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;

    final rows = await _client!
        .from('notifications')
        .select('id, kind, title, body, is_read, created_at')
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    _notifications
      ..clear()
      ..addAll(
        (rows as List).cast<Map<String, dynamic>>().map(
          AppNotification.fromRow,
        ),
      );
    notifyListeners();
  }

  Future<void> refreshChallengeCompletions() async {
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;

    final weekStart = _weekStartString(DateTime.now());
    final rows = await _client!
        .from('user_challenge_completions')
        .select('challenge_id')
        .eq('user_id', uid)
        .eq('week_start', weekStart);

    _completedChallengeIds
      ..clear()
      ..addAll(
        (rows as List).map((r) => (r as Map)['challenge_id'].toString()),
      );
    notifyListeners();
  }

  Future<void> refreshFavorites() async {
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;

    try {
      final rows = await _client!
          .from('sdg_favorites')
          .select('goal_id')
          .eq('user_id', uid);
      _favoriteGoalIds
        ..clear()
        ..addAll(
          (rows as List).map((r) => ((r as Map)['goal_id'] as num).toInt()),
        );
      notifyListeners();
    } catch (_) {
      return;
    }
  }

  Future<void> toggleGoalFavorite(int goalId) async {
    if (!supabaseEnabled) {
      if (_favoriteGoalIds.contains(goalId)) {
        _favoriteGoalIds.remove(goalId);
      } else {
        _favoriteGoalIds.add(goalId);
      }
      notifyListeners();
      return;
    }

    final uid = _userId;
    if (uid == null) return;

    try {
      if (_favoriteGoalIds.contains(goalId)) {
        await _client!
            .from('sdg_favorites')
            .delete()
            .eq('user_id', uid)
            .eq('goal_id', goalId);
        _favoriteGoalIds.remove(goalId);
      } else {
        await _client!.from('sdg_favorites').insert({
          'user_id': uid,
          'goal_id': goalId,
        });
        _favoriteGoalIds.add(goalId);
      }
      notifyListeners();
    } catch (_) {
      return;
    }
  }

  Future<void> toggleLanguage() async {
    _locale =
        _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('selectedLanguage', _locale.languageCode);
    });

    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    await _client!
        .from('profiles')
        .update({'locale': _locale.languageCode})
        .eq('id', uid);
  }

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    await _client!
        .from('profiles')
        .update({'theme_mode': isDarkMode ? 'dark' : 'light'})
        .eq('id', uid);
  }

  Future<String?> uploadAvatar({
    required Uint8List bytes,
    String fileName = 'avatar.jpg',
  }) async {
    if (!supabaseEnabled) return 'Supabase not enabled';
    final uid = _userId;
    if (uid == null) return 'User not authenticated';
    try {
      final ext = fileName.split('.').last.toLowerCase();
      final contentType = switch (ext) {
        'png' => 'image/png',
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'webp' => 'image/webp',
        _ => 'application/octet-stream',
      };

      // Upload path: user_id/timestamp.ext
      final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';

      debugPrint('Uploading avatar to path: $path in bucket: images');

      // Upload to storage
      await _client!.storage
          .from('images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      final publicUrl = _client!.storage.from('images').getPublicUrl(path);

      // Update profile
      await _client!
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', uid);

      _avatarUrl = publicUrl;
      notifyListeners();
      return null; // Success
    } catch (e) {
      debugPrint('Upload avatar error: $e');
      if (e.toString().contains('Bucket not found')) {
        return 'Storage bucket "images" not found. Please create it in Supabase dashboard.';
      }
      return e.toString();
    }
  }

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('hasSeenOnboarding', true);
    });
  }

  void selectLanguage(Locale locale) {
    _locale = locale;
    _hasSelectedLanguage = true;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('hasSelectedLanguage', true);
      prefs.setString('selectedLanguage', _locale.languageCode);
    });

    if (supabaseEnabled) {
      final uid = _userId;
      if (uid != null) {
        _client!
            .from('profiles')
            .update({'locale': _locale.languageCode})
            .eq('id', uid);
      }
    }
  }

  Future<void> submitSurvey(Map<String, dynamic> answers) async {
    _hasCompletedSurvey = true;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('hasCompletedSurvey', true);
    });

    if (!supabaseEnabled) return;

    final uid = _userId;
    try {
      await _client!.from('user_surveys').insert({
        if (uid != null) 'user_id': uid,
        'answers': answers,
      });

      if (uid != null) {
        await _client!
            .from('profiles')
            .update({'has_completed_survey': true})
            .eq('id', uid);
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> submitSurvey2(Map<String, dynamic> answers) async {
    _hasCompletedSurvey2 = true;
    notifyListeners();

    if (!supabaseEnabled) return;

    final uid = _userId;
    try {
      await _client!.from('user_surveys2').insert({
        if (uid != null) 'user_id': uid,
        'answers': answers,
      });

      if (uid != null) {
        await _client!
            .from('profiles')
            .update({'has_completed_survey2': true})
            .eq('id', uid);
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> setQuizCompleted(bool completed) async {
    _hasCompletedQuiz = completed;
    if (completed) {
      _completedChallengeIds.add('quiz_completed');
    } else {
      _completedChallengeIds.remove('quiz_completed');
    }
    notifyListeners();

    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client!
          .from('profiles')
          .update({'has_completed_quiz': completed})
          .eq('id', uid);

      final weekStart = _weekStartString(DateTime.now());
      if (completed) {
        await _client!.from('user_challenge_completions').upsert({
          'user_id': uid,
          'challenge_id': 'quiz_completed',
          'week_start': weekStart,
        });
      } else {
        await _client!
            .from('user_challenge_completions')
            .delete()
            .eq('user_id', uid)
            .eq('challenge_id', 'quiz_completed')
            .eq('week_start', weekStart);
      }
    } catch (_) {}
  }

  Future<void> submitEvaluation({
    required double rating,
    String? feedback,
  }) async {
    _hasCompletedEvaluation = true;
    notifyListeners();

    if (!supabaseEnabled) return;

    final uid = _userId;
    try {
      await _client!.from('app_evaluations').insert({
        if (uid != null) 'user_id': uid,
        'rating': rating,
        'feedback': feedback,
      });

      if (uid != null) {
        await _client!
            .from('profiles')
            .update({'has_completed_evaluation': true})
            .eq('id', uid);
      }
    } catch (_) {}
  }

  Future<void> loginWithPassword({
    required String email,
    required String password,
  }) async {
    if (!supabaseEnabled) {
      _isAuthenticated = true;
      notifyListeners();
      return;
    }
    final res = await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
    _isAuthenticated = res.session != null;
    if (_isAuthenticated) {
      await _refreshAllForUser();
    }
    notifyListeners();
  }

  Future<void> signUpWithPassword({
    required String email,
    required String password,
    String? fullName,
  }) async {
    if (!supabaseEnabled) {
      _isAuthenticated = true;
      notifyListeners();
      return;
    }
    final res = await _client!.auth.signUp(
      email: email,
      password: password,
      data: fullName == null ? null : {'full_name': fullName},
    );
    _isAuthenticated = res.session != null;
    if (_isAuthenticated) {
      await _refreshAllForUser();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    if (!supabaseEnabled) {
      _isAuthenticated = false;
      notifyListeners();
      return;
    }
    await _client!.auth.signOut();
  }

  Future<void> addImpact({
    String actionType = 'manual',
    double co2DeltaKg = 0,
    double wasteDeltaKg = 0,
    Map<String, dynamic> meta = const {},
  }) async {
    // Optimistic update of local counters
    _co2SavedKg = (_co2SavedKg + co2DeltaKg).clamp(0, double.infinity);
    _wasteReducedKg = (_wasteReducedKg + wasteDeltaKg).clamp(
      0,
      double.infinity,
    );
    notifyListeners();

    if (!supabaseEnabled) return;

    final uid = _userId;
    if (uid == null) return;

    try {
      await _client!.from('user_actions').insert({
        'user_id': uid,
        'action_type': actionType,
        'co2_delta_kg': co2DeltaKg,
        'waste_delta_kg': wasteDeltaKg,
        'meta': meta,
      });
      await refreshProfile();
    } catch (_) {
      // If server update fails, local counters already changed optimistically
      // Re-syncing would happen on next profile refresh
    }
  }

  Future<void> toggleChallenge(String challengeId) async {
    final challenge =
        _challenges
            .where((c) => c.id == challengeId)
            .cast<Challenge?>()
            .firstOrNull;
    final co2 = challenge?.co2DeltaKg ?? 0;
    final waste = challenge?.wasteDeltaKg ?? 0;
    final weekStart = _weekStartString(DateTime.now());

    if (_completedChallengeIds.contains(challengeId)) {
      _completedChallengeIds.remove(challengeId);
      notifyListeners();

      // Local update is handled by addImpact
      await addImpact(
        actionType: 'challenge_uncomplete',
        co2DeltaKg: -co2,
        wasteDeltaKg: -waste,
        meta: {'challenge_id': challengeId, 'week_start': weekStart},
      );

      if (supabaseEnabled) {
        final uid = _userId;
        if (uid != null) {
          try {
            await _client!
                .from('user_challenge_completions')
                .delete()
                .eq('user_id', uid)
                .eq('challenge_id', challengeId)
                .eq('week_start', weekStart);
          } catch (_) {
            // Optimistic update failed on server
          }
        }
      }
    } else {
      _completedChallengeIds.add(challengeId);
      notifyListeners();

      // Local update is handled by addImpact
      await addImpact(
        actionType: 'challenge_complete',
        co2DeltaKg: co2,
        wasteDeltaKg: waste,
        meta: {'challenge_id': challengeId, 'week_start': weekStart},
      );

      if (supabaseEnabled) {
        final uid = _userId;
        if (uid != null) {
          try {
            await _client!.from('user_challenge_completions').insert({
              'user_id': uid,
              'challenge_id': challengeId,
              'week_start': weekStart,
            });
          } catch (_) {
            // Optimistic update failed
          }
        }
      }
    }
  }

  Future<void> resetWeek() async {
    _completedChallengeIds.clear();
    notifyListeners();
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    final weekStart = _weekStartString(DateTime.now());
    await _client!
        .from('user_challenge_completions')
        .delete()
        .eq('user_id', uid)
        .eq('week_start', weekStart);
    await refreshChallengeCompletions();
  }

  Future<void> setWeeklyGoal(int goal) async {
    _weeklyGoal = goal < 0 ? 0 : goal;
    notifyListeners();
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    await _client!
        .from('profiles')
        .update({'weekly_goal': _weeklyGoal})
        .eq('id', uid);
  }

  Future<void> markNotificationRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    if (_notifications[index].isRead) return;
    _notifications[index].isRead = true;
    notifyListeners();
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    await _client!
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id)
        .eq('user_id', uid);
  }

  Future<void> toggleNotificationRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notifications[index].isRead = !_notifications[index].isRead;
    final isRead = _notifications[index].isRead;
    notifyListeners();
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    await _client!
        .from('notifications')
        .update({'is_read': isRead})
        .eq('id', id)
        .eq('user_id', uid);
  }

  Future<void> markAllNotificationsRead() async {
    var changed = false;
    for (final n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
    if (!supabaseEnabled) return;
    final uid = _userId;
    if (uid == null) return;
    await _client!
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', uid)
        .eq('is_read', false);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    for (final v in this) {
      return v;
    }
    return null;
  }
}

String _weekStartString(DateTime now) {
  final dateOnly = DateTime(now.year, now.month, now.day);
  final start = dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
  return '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
}

class SustainabilityProvider extends InheritedNotifier<SustainabilityModel> {
  const SustainabilityProvider({
    super.key,
    required SustainabilityModel model,
    required super.child,
  }) : super(notifier: model);

  static SustainabilityModel of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<SustainabilityProvider>();
    final model = provider?.notifier;
    if (model == null) {
      throw StateError('SustainabilityProvider not found in context');
    }
    return model;
  }
}
