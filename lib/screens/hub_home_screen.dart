import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/strings.dart';
import '../app/model.dart';
import '../widgets/hub_widgets.dart';
import 'news_stories_screen.dart';
import 'notifications_screen.dart';
import 'educational_videos_screen.dart';

class HubHomeScreen extends StatefulWidget {
  const HubHomeScreen({super.key, required this.onNavigateToTab});

  final ValueChanged<int> onNavigateToTab;

  @override
  State<HubHomeScreen> createState() => _HubHomeScreenState();
}

class _HubHomeScreenState extends State<HubHomeScreen> {
  bool _isLoadingBanner = true;
  List<Map<String, dynamic>> _banners = [];
  int _currentBannerPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchBanner();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchBanner() async {
    try {
      final response = await Supabase.instance.client
          .from('welcome_banner')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _banners = List<Map<String, dynamic>>.from(response);
          _isLoadingBanner = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBanner = false);
      }
    }
  }

  Future<void> _handleBannerAction(String? link) async {
    if (link == null || link.isEmpty) return;

    if (link == '1' || link == '2' || link == '3') {
      widget.onNavigateToTab(int.parse(link));
    } else {
      final uri = Uri.tryParse(link);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchBanner,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HubHeader(
                  title: AppStrings.get('appName', context),
                  subtitle: AppStrings.get('welcomeSubtitle', context),
                  unreadNotificationsCount: model.unreadNotificationsCount,
                  onNotifications: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  onToggleLanguage: () {
                    model.toggleLanguage();
                  },
                  isDarkMode: model.isDarkMode,
                  onToggleTheme: () {
                    model.toggleTheme();
                  },
                ),
                const SizedBox(height: 12),
                if (_isLoadingBanner)
                  const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_banners.isEmpty)
                  WelcomeCard(
                    title: AppStrings.get('welcomeTitle', context),
                    subtitle: AppStrings.get('welcomeSubtitle', context),
                    buttonText: AppStrings.get('getStarted', context),
                    onPressed: () => widget.onNavigateToTab(1),
                  )
                else
                  Column(
                    children: [
                      SizedBox(
                        height: 185,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentBannerPage = index);
                          },
                          itemCount: _banners.length,
                          itemBuilder: (context, index) {
                            final data = _banners[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: WelcomeCard(
                                title:
                                    locale.languageCode == 'ar'
                                        ? data['title_ar']
                                        : data['title_en'],
                                subtitle:
                                    locale.languageCode == 'ar'
                                        ? data['subtitle_ar']
                                        : data['subtitle_en'],
                                buttonText:
                                    locale.languageCode == 'ar'
                                        ? data['button_text_ar']
                                        : data['button_text_en'],
                                imageUrl: data['image_url'],
                                onPressed: () {
                                  _handleBannerAction(data['link']);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      if (_banners.length > 1) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_banners.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentBannerPage == index ? 20 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    _currentBannerPage == index
                                        ? colorScheme.primary
                                        : colorScheme.primary.withAlpha(60),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 16),
                ImpactStrip(
                  items: [
                    ImpactItemData(
                      icon: Icons.co2,
                      value:
                          '${model.co2SavedKg.toStringAsFixed(1)} ${AppStrings.get('kg', context)}',
                      label: AppStrings.get('co2Saved', context),
                      color: colorScheme.primary,
                    ),
                    ImpactItemData(
                      icon: Icons.delete_outline,
                      value:
                          '${model.wasteReducedKg.toStringAsFixed(1)} ${AppStrings.get('kg', context)}',
                      label: AppStrings.get('wasteReduced', context),
                      color: colorScheme.primary,
                    ),
                    ImpactItemData(
                      icon: Icons.verified_outlined,
                      value: model.challengesCompleted.toString(),
                      label: AppStrings.get('challengesCompleted', context),
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProgressCard(
                  title: AppStrings.get('weeklyProgress', context),
                  progress: model.weeklyProgress,
                  leadingText:
                      '${model.challengesCompleted}/${model.weeklyGoal} ${AppStrings.get('tasks', context)}',
                ),
                const SizedBox(height: 18),
                HubTile(
                  icon: Icons.menu_book,
                  title: AppStrings.get('learnSdgs', context),
                  subtitle: AppStrings.get('learnSdgsSubtitle', context),
                  color: colorScheme.primary,
                  onTap: () => widget.onNavigateToTab(1),
                ),
                const SizedBox(height: 12),
                HubTile(
                  icon: Icons.quiz,
                  title: AppStrings.get('interactiveQuiz', context),
                  subtitle: AppStrings.get('interactiveQuizSubtitle', context),
                  color: colorScheme.primary,
                  onTap: () => widget.onNavigateToTab(2),
                ),
                const SizedBox(height: 12),
                HubTile(
                  icon: Icons.flag,
                  title: AppStrings.get('tipsChallenges', context),
                  subtitle: AppStrings.get('tipsChallengesSubtitle', context),
                  color: colorScheme.primary,
                  onTap: () => widget.onNavigateToTab(3),
                ),
                const SizedBox(height: 12),
                HubTile(
                  icon: Icons.play_circle_outline,
                  title: AppStrings.get('watchLearn', context),
                  subtitle: AppStrings.get('videoSubtitle', context),
                  color: colorScheme.primary,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EducationalVideosScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                HubTile(
                  icon: Icons.newspaper,
                  title: AppStrings.get('newsStories', context),
                  subtitle: AppStrings.get('newsStoriesSubtitle', context),
                  color: colorScheme.primary,
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
