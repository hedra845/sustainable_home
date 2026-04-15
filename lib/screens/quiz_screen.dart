import 'package:flutter/material.dart';

import '../app/model.dart';
import '../app/strings.dart';
import '../widgets/impact_panel.dart';
import '../widgets/evaluation_dialog.dart';
import 'leaderboard_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<_QuizQuestion> _questions = const [
    _QuizQuestion(
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
    _QuizQuestion(
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
  ];

  int _index = 0;
  int? _selected;
  bool _showAnswer = false;
  bool _showHint = false;
  bool _awarded = false;
  int _correctCount = 0;
  bool _isFinished = false;
  bool _initialized = false;
  bool _isPreviouslyFinished = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final model = SustainabilityProvider.of(context);
      // التحقق مما إذا كان الاختبار قد تم حله مسبقاً من جدول إكمال التحديات
      if (model.isChallengeCompleted('quiz_completed')) {
        _isFinished = true;
        _isPreviouslyFinished = true;
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('quiz', context))),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child:
            _isFinished
                ? _buildResultScreen(context, colorScheme)
                : _buildQuizContent(context, model, colorScheme),
      ),
    );
  }

  Widget _buildQuizContent(
    BuildContext context,
    SustainabilityModel model,
    ColorScheme colorScheme,
  ) {
    final q = _questions[_index];
    final progress = (_index + 1) / _questions.length;
    final locale = Localizations.localeOf(context);
    final options = q.options(locale);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_index + 1}/${_questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  q.question(locale),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(options.length, (i) {
                  final isSelected = _selected == i;
                  final isCorrect = i == q.correctIndex;
                  final bool showCorrect =
                      _showAnswer || (isSelected && _selected != null);

                  Color border = colorScheme.outlineVariant;
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
                    border = colorScheme.primary;
                    fill = colorScheme.primary.withAlpha(20);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap:
                          () => setState(() {
                            if (_selected != null) return;
                            _selected = i;
                            _showAnswer = false;
                            _showHint = false;
                            if (i == q.correctIndex) {
                              _correctCount++;
                              if (!_awarded) {
                                _awarded = true;
                                model.addImpact(
                                  actionType: 'quiz_correct',
                                  co2DeltaKg: 0.3,
                                  wasteDeltaKg: 0.2,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppStrings.get('actionAdded', context),
                                    ),
                                    duration: const Duration(milliseconds: 900),
                                  ),
                                );
                              }
                            }
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
                                options[i],
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
                      color: colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.primary.withAlpha(89),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            q.hint(locale),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            _index + 1 < _questions.length
                                ? AppStrings.get('nextQuestion', context)
                                : (Localizations.localeOf(
                                          context,
                                        ).languageCode ==
                                        'ar'
                                    ? 'إنهاء الاختبار'
                                    : 'Finish Quiz'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed:
                              () => setState(() {
                                _showAnswer = true;
                                _showHint = false;
                              }),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: BorderSide(color: colorScheme.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            AppStrings.get('showAnswer', context),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: FilledButton.tonal(
                          onPressed:
                              () => setState(() => _showHint = !_showHint),
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: colorScheme.primary.withAlpha(40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            AppStrings.get('hint', context),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                              height: 1.1,
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
        const SizedBox(height: 16),
        ImpactPanel(
          title: AppStrings.get('trackImpact', context),
          rows: [
            ImpactRow(
              icon: Icons.co2,
              label: AppStrings.get('co2Saved', context),
              value:
                  '${model.co2SavedKg.toStringAsFixed(1)} ${AppStrings.get('kg', context)}',
            ),
            ImpactRow(
              icon: Icons.delete_outline,
              label: AppStrings.get('wasteReduced', context),
              value:
                  '${model.wasteReducedKg.toStringAsFixed(1)} ${AppStrings.get('kg', context)}',
            ),
            ImpactRow(
              icon: Icons.verified_outlined,
              label: AppStrings.get('challengesCompleted', context),
              value: model.challengesCompleted.toString(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Expanded(
            //   child: FilledButton.tonalIcon(
            //     onPressed: () => _showQuickActions(context, model),
            //     icon: const Icon(Icons.add),
            //     label: Text(AppStrings.get('addAction', context)),
            //   ),
            // ),
            // const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LeaderboardScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.emoji_events_outlined),
                label: Text(AppStrings.get('viewLeaderboard', context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultScreen(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.get('quizFinished', context),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (!_isPreviouslyFinished || _correctCount > 0)
              Text(
                '${AppStrings.get('yourScore', context)}: $_correctCount/${_questions.length}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _isPreviouslyFinished && _correctCount == 0
                  ? (Localizations.localeOf(context).languageCode == 'ar'
                      ? 'لقد أتممت الاختبار مسبقاً بنجاح!'
                      : 'You have already completed the quiz successfully!')
                  : (_correctCount == _questions.length
                      ? AppStrings.get('wellDone', context)
                      : AppStrings.get('keepLearning', context)),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.refresh),
              label: Text(AppStrings.get('restartQuiz', context)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => EvaluationDialog.show(context),
              icon: const Icon(Icons.star_outline),
              label: Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? 'تقييم'
                    : 'Evaluate',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    if (_index + 1 < _questions.length) {
      setState(() {
        _index++;
        _selected = null;
        _showAnswer = false;
        _showHint = false;
        _awarded = false;
      });
    } else {
      // 1. تحديث الحالة المحلية للشاشة أولاً
      setState(() {
        _isFinished = true;
      });

      // 2. تحديث حالة النموذج وقاعدة البيانات
      final model = SustainabilityProvider.of(context);
      model.setQuizCompleted(true).then((_) {
        // 3. التأكد من ظهور التقييم بعد تحديث الحالة
        if (mounted) {
          Future.microtask(() {
            if (mounted) {
              EvaluationDialog.showIfNeeded(context);
            }
          });
        }
      });
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _selected = null;
      _showAnswer = false;
      _showHint = false;
      _awarded = false;
      _correctCount = 0;
      _isFinished = false;
    });
  }
}

void _showQuickActions(BuildContext context, SustainabilityModel model) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.get('quickActions', context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () {
                  model.addImpact(
                    actionType: 'quick_transport',
                    co2DeltaKg: 0.6,
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.directions_bus_outlined),
                label: Text(AppStrings.get('actionTransport', context)),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () {
                  model.addImpact(
                    actionType: 'quick_recycle',
                    wasteDeltaKg: 0.4,
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.recycling),
                label: Text(AppStrings.get('actionRecycle', context)),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () {
                  model.addImpact(
                    actionType: 'quick_tree',
                    co2DeltaKg: 0.3,
                    wasteDeltaKg: 0.2,
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.park_outlined),
                label: Text(AppStrings.get('actionTree', context)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _QuizQuestion {
  const _QuizQuestion({
    required this.questionAr,
    required this.questionEn,
    required this.optionsAr,
    required this.optionsEn,
    required this.correctIndex,
    required this.hintAr,
    required this.hintEn,
  });

  final String questionAr;
  final String questionEn;
  final List<String> optionsAr;
  final List<String> optionsEn;
  final int correctIndex;
  final String hintAr;
  final String hintEn;

  String question(Locale locale) =>
      locale.languageCode == 'ar' ? questionAr : questionEn;
  List<String> options(Locale locale) =>
      locale.languageCode == 'ar' ? optionsAr : optionsEn;
  String hint(Locale locale) => locale.languageCode == 'ar' ? hintAr : hintEn;
}
