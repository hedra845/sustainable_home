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
  int _index = 0;
  int? _selected;
  bool _showAnswer = false;
  bool _showHint = false;
  bool _awarded = false;
  int _correctCount = 0;
  bool _isFinished = false;
  bool _initialized = false;
  bool _isPreviouslyFinished = false;
  final List<Map<String, dynamic>> _userAnswers = [];

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
    final questions = model.quizQuestions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.get('quiz', context))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('quiz', context))),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child:
            _isFinished
                ? _buildResultScreen(context, colorScheme, questions.length)
                : _buildQuizContent(context, model, colorScheme, questions),
      ),
    );
  }

  Widget _buildQuizContent(
    BuildContext context,
    SustainabilityModel model,
    ColorScheme colorScheme,
    List<QuizQuestion> questions,
  ) {
    final q = questions[_index];
    final progress = (_index + 1) / questions.length;
    final locale = Localizations.localeOf(context);
    final options = q.optionsFor(locale);

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
                      '${_index + 1}/${questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  q.questionFor(locale),
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

                            final correct = i == q.correctIndex;

                            // تخزين الإجابة محلياً لإرسالها في النهاية
                            _userAnswers.add({
                              'question_id': q.id,
                              'selected_option_index': i,
                              'is_correct': correct,
                            });

                            if (correct) {
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
                if (_showHint && q.hintFor(locale) != null) ...[
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
                            q.hintFor(locale)!,
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
                          onPressed: () => _next(questions.length),
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            _index + 1 < questions.length
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

  Widget _buildResultScreen(
    BuildContext context,
    ColorScheme colorScheme,
    int totalQuestions,
  ) {
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
                '${AppStrings.get('yourScore', context)}: $_correctCount/$totalQuestions',
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
                  : (_correctCount == totalQuestions
                      ? AppStrings.get('wellDone', context)
                      : AppStrings.get('keepLearning', context)),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorSurfaceVariant(colorScheme),
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

  Color colorSurfaceVariant(ColorScheme colorScheme) =>
      colorScheme.onSurfaceVariant;

  void _next(int totalQuestions) {
    if (_index + 1 < totalQuestions) {
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

      // إرسال جميع الإجابات والنتيجة النهائية
      model.submitQuizAnswers(_userAnswers);
      model.submitQuizResult(
        score: _correctCount,
        totalQuestions: totalQuestions,
      );

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
      _userAnswers.clear();
    });
  }
}
