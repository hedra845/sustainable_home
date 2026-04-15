import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../app/model.dart';
import '../app/strings.dart';

class SdgArticleScreen extends StatelessWidget {
  const SdgArticleScreen({super.key, required this.goal});

  final SdgGoal goal;

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final locale = model.locale;
    final title = goal.titleFor(locale);

    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        final isFav = model.isGoalFavorited(goal.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            // actions: [
            //   IconButton(
            //     onPressed: () async {
            //       await model.toggleGoalFavorite(goal.id);
            //     },
            //     icon: Icon(isFav ? Icons.star : Icons.star_outline),
            //   ),
            // ],
          ),
          body: FutureBuilder<_GoalArticle>(
            future:
                model.supabaseEnabled
                    ? _fetchFromSupabase(goalId: goal.id, locale: model.locale)
                    : Future.value(
                      _articleFor(goalId: goal.id, locale: model.locale),
                    ),
            builder: (context, snapshot) {
              final article =
                  snapshot.data ??
                  _articleFor(goalId: goal.id, locale: model.locale);

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(goal.imageUrl, fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withAlpha(130),
                                ],
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            start: 16,
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(120),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withAlpha(40),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withAlpha(40),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        goal.id.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withAlpha(235),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 14),
                                  child: SizedBox(
                                    width: 34,
                                    height: 34,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(<Widget>[
                        Text(
                          article.summary,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...article.sections.expand<Widget>((s) {
                          return [
                            Text(
                              s.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 8),
                            if (s.body.isNotEmpty)
                              Text(
                                s.body,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  height: 1.45,
                                ),
                              ),
                            if (s.body.isNotEmpty) const SizedBox(height: 10),
                            if (s.bullets.isNotEmpty)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children:
                                        s.bullets.map((b) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 6,
                                                  ),
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    b,
                                                    style: TextStyle(
                                                      color:
                                                          colorScheme
                                                              .onSurfaceVariant,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 18),
                          ];
                        }),
                        _buildVideosSection(
                          context,
                          model,
                          colorScheme,
                          locale,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 46,
                          child: FilledButton.icon(
                            onPressed: () async {
                              await model.addImpact(
                                actionType: 'read_article',
                                co2DeltaKg: 0.1,
                                wasteDeltaKg: 0.05,
                                meta: {'goal_id': goal.id},
                              );
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(AppStrings.get('startNow', context)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVideosSection(
    BuildContext context,
    SustainabilityModel model,
    ColorScheme colorScheme,
    Locale locale,
  ) {
    final linkedVideos =
        model.educationalVideos.where((v) => v.sdgGoalId == goal.id).toList();

    if (linkedVideos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('watchLearn', context),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Column(
          children:
              linkedVideos.map((video) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => VideoPlayerDetailScreen(video: video),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (video.thumbnailUrl.isNotEmpty)
                                  Image.network(
                                    video.thumbnailUrl,
                                    fit: BoxFit.cover,
                                  )
                                else
                                  Container(
                                    color: colorScheme.surfaceContainerHighest,
                                  ),
                                Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(120),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withAlpha(60),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.titleFor(locale),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  video.descriptionFor(locale),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: FilledButton.tonalIcon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (_) => VideoPlayerDetailScreen(
                                                video: video,
                                              ),
                                        ),
                                      );
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.primary
                                          .withAlpha(35),
                                      foregroundColor: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.play_circle_outline,
                                      size: 22,
                                    ),
                                    label: Text(
                                      AppStrings.get('watchVideo', context),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class VideoPlayerDetailScreen extends StatefulWidget {
  const VideoPlayerDetailScreen({super.key, required this.video});

  final EducationalVideo video;

  @override
  State<VideoPlayerDetailScreen> createState() =>
      _VideoPlayerDetailScreenState();
}

class _VideoPlayerDetailScreenState extends State<VideoPlayerDetailScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.video.titleFor(locale))),
      body:
          _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ArticleSection {
  const _ArticleSection({
    required this.title,
    this.body = '',
    this.bullets = const [],
  });

  final String title;
  final String body;
  final List<String> bullets;
}

class _GoalArticle {
  const _GoalArticle({required this.summary, required this.sections});

  final String summary;
  final List<_ArticleSection> sections;
}

Future<_GoalArticle> _fetchFromSupabase({
  required int goalId,
  required Locale locale,
}) async {
  try {
    final lang = locale.languageCode == 'ar' ? 'ar' : 'en';
    final row =
        await Supabase.instance.client
            .from('sdg_articles')
            .select('summary, sections')
            .eq('goal_id', goalId)
            .eq('locale', lang)
            .maybeSingle();

    if (row == null) return _articleFor(goalId: goalId, locale: locale);

    final summary = (row['summary'] ?? '').toString();
    final rawSections = row['sections'];
    final sections = <_ArticleSection>[];

    if (rawSections is List) {
      for (final item in rawSections) {
        if (item is! Map) continue;
        final title = (item['title'] ?? '').toString();
        final body = (item['body'] ?? '').toString();
        final bullets = <String>[];
        final rawBullets = item['bullets'];
        if (rawBullets is List) {
          for (final b in rawBullets) {
            bullets.add(b.toString());
          }
        }
        if (title.isNotEmpty) {
          sections.add(
            _ArticleSection(title: title, body: body, bullets: bullets),
          );
        }
      }
    }

    if (summary.isEmpty && sections.isEmpty) {
      return _articleFor(goalId: goalId, locale: locale);
    }

    return _GoalArticle(summary: summary, sections: sections);
  } catch (_) {
    return _articleFor(goalId: goalId, locale: locale);
  }
}

_GoalArticle _articleFor({required int goalId, required Locale locale}) {
  final isAr = locale.languageCode == 'ar';

  if (goalId == 11) {
    return _GoalArticle(
      summary:
          isAr
              ? 'يركّز الهدف 11 على جعل المدن والمجتمعات أكثر شمولًا وأمانًا وقدرة على الصمود واستدامة. لأن معظم الناس يعيشون في المدن، أي تحسين صغير في النقل أو الطاقة أو إدارة النفايات يحدث فرقًا كبيرًا.'
              : 'SDG 11 focuses on making cities and communities inclusive, safe, resilient, and sustainable. Because most people live in cities, even small improvements in transport, energy, and waste systems create big impact.',
      sections: [
        _ArticleSection(
          title: isAr ? 'لماذا هذا الهدف مهم؟' : 'Why it matters',
          bullets:
              isAr
                  ? [
                    'تقليل التلوث وتحسين جودة الهواء.',
                    'نقل أفضل يعني وقت أقل في الزحام وانبعاثات أقل.',
                    'تخطيط حضري جيد يرفع جودة الحياة للجميع.',
                  ]
                  : [
                    'Lower air pollution and healthier cities.',
                    'Better transport reduces traffic and emissions.',
                    'Good urban planning improves quality of life for everyone.',
                  ],
        ),
        _ArticleSection(
          title:
              isAr ? 'أفكار بسيطة تستطيع فعلها' : 'Simple actions you can take',
          bullets:
              isAr
                  ? [
                    'استخدم المواصلات العامة أو المشي لمسافات قصيرة.',
                    'وفّر الطاقة في المنزل (إطفاء الأنوار، ضبط المكيف).',
                    'افصل النفايات قدر الإمكان وأعد التدوير.',
                  ]
                  : [
                    'Use public transport, walk, or bike for short trips.',
                    'Save energy at home (turn off lights, optimize AC).',
                    'Separate waste and recycle whenever possible.',
                  ],
        ),
        _ArticleSection(
          title: isAr ? 'كيف نقيس الأثر؟' : 'How to measure impact',
          body:
              isAr
                  ? 'تابع تأثيرك عبر تقليل CO₂ والنفايات، وعدد التحديات المكتملة أسبوعيًا. كل مهمة تُكملها تُضاف لنقاط تأثيرك.'
                  : 'Track your impact through CO₂ saved, waste reduced, and weekly challenges completed. Each completed mission adds to your impact score.',
        ),
      ],
    );
  }

  if (goalId == 12) {
    return _GoalArticle(
      summary:
          isAr
              ? 'يركّز الهدف 12 على الاستهلاك والإنتاج المسؤولين: شراء أقل، اختيار أفضل، وإعادة استخدام أكثر. الفكرة أن نقلّل الهدر ونحافظ على الموارد.'
              : 'SDG 12 focuses on responsible consumption and production: buy less, choose better, and reuse more. The goal is reducing waste and protecting resources.',
      sections: [
        _ArticleSection(
          title: isAr ? 'أين المشكلة؟' : 'What’s the problem',
          bullets:
              isAr
                  ? [
                    'هدر الطعام يزيد النفايات والانبعاثات.',
                    'المنتجات أحادية الاستخدام تملأ مكبات القمامة.',
                    'الإفراط في الشراء يرفع التلوث واستهلاك الموارد.',
                  ]
                  : [
                    'Food waste increases landfill and emissions.',
                    'Single-use items overload waste systems.',
                    'Overbuying increases pollution and resource use.',
                  ],
        ),
        _ArticleSection(
          title: isAr ? 'نصائح عملية' : 'Practical tips',
          bullets:
              isAr
                  ? [
                    'خطط للمشتريات لتقلل الهدر.',
                    'اختر منتجات قابلة لإعادة الاستخدام.',
                    'أعد تدوير العبوات وقلل التغليف.',
                  ]
                  : [
                    'Plan purchases to reduce waste.',
                    'Choose reusable products.',
                    'Recycle packaging and reduce extra wrapping.',
                  ],
        ),
        _ArticleSection(
          title: isAr ? 'ابدأ الآن' : 'Start today',
          body:
              isAr
                  ? 'جرّب تحديًا واحدًا اليوم: زجاجة قابلة لإعادة الاستخدام أو كيس قماش. الخطوات الصغيرة تتراكم.'
                  : 'Try one challenge today: a reusable bottle or a cloth bag. Small steps add up over time.',
        ),
      ],
    );
  }

  return _GoalArticle(
    summary:
        isAr
            ? 'هذه مقالة مختصرة عن الهدف. يمكنك إضافة محتوى كامل من Supabase لاحقًا.'
            : 'This is a short placeholder article for this goal. You can add full content from Supabase later.',
    sections: [
      _ArticleSection(
        title: isAr ? 'أفكار سريعة' : 'Quick ideas',
        bullets:
            isAr
                ? ['ابدأ بخطوة صغيرة اليوم.']
                : ['Start with one small step today.'],
      ),
    ],
  );
}
