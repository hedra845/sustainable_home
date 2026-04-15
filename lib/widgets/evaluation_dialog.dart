import 'package:flutter/material.dart';
import '../app/model.dart';
import '../app/strings.dart';
import '../screens/survey_screen2.dart';

class EvaluationDialog extends StatefulWidget {
  const EvaluationDialog({super.key});

  @override
  State<EvaluationDialog> createState() => _EvaluationDialogState();

  static Future<void> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const EvaluationDialog(),
    );

    if (result == true && context.mounted) {
      // Then navigate to Survey Screen 2 (Independent Page)
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SurveyScreen2()));
    }
  }

  static Future<void> showIfNeeded(BuildContext context) async {
    final model = SustainabilityProvider.of(context);
    if (model.canShowSurveyAndEvaluation) {
      await show(context);
    }
  }
}

class _EvaluationDialogState extends State<EvaluationDialog> {
  double _rating = 5;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        isAr ? 'تقييم التطبيق' : 'App Evaluation',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isAr
                  ? 'شكراً لإكمالك التحديات والاختبار! كيف تقيم تجربتك مع التطبيق؟'
                  : 'Thanks for completing the challenges and quiz! How do you rate your experience?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => _rating = index + 1.0),
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    isAr ? 'ملاحظاتك (اختياري)...' : 'Feedback (optional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppStrings.get('cancel', context)),
        ),
        FilledButton(
          onPressed: () async {
            final model = SustainabilityProvider.of(context);
            await model.submitEvaluation(
              rating: _rating,
              feedback: _feedbackController.text,
            );
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isAr ? 'إرسال والبدء بالاستبيان' : 'Submit & Start Survey',
            ),
          ),
        ),
      ],
    );
  }
}
