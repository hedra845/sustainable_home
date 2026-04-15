import 'package:flutter/material.dart';
import '../app/model.dart';
import '../app/strings.dart';

class SurveyScreen2 extends StatefulWidget {
  const SurveyScreen2({super.key});

  @override
  State<SurveyScreen2> createState() => _SurveyScreen2State();
}

class _SurveyScreen2State extends State<SurveyScreen2> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final model = SustainabilityProvider.of(context);
    final questions = model.surveyQuestions2;

    // Check if all required questions are answered
    for (final q in questions) {
      if (q.required &&
          (_answers[q.id] == null || _answers[q.id].toString().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'الرجاء الإجابة على جميع الأسئلة المطلوبة'
                  : 'Please answer all required questions',
            ),
          ),
        );
        return;
      }
    }

    model.submitSurvey2(_answers).then((_) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'شكراً لك! تم حفظ استطلاع رأيك بنجاح'
                  : 'Thank you! Your feedback has been saved successfully',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final questions = model.surveyQuestions2;
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            locale.languageCode == 'ar'
                ? 'استطلاع رأي إضافي'
                : 'Feedback Survey',
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.languageCode == 'ar' ? 'استطلاع رأي إضافي' : 'Feedback Survey',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              locale.languageCode == 'ar'
                  ? 'رأيك يهمنا لتحسين تجربة التطبيق'
                  : 'Your opinion matters to improve the app experience',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ...questions.map((q) => _buildQuestionWidget(q, context)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: Text(AppStrings.get('submit', context)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(SurveyQuestion q, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);

    Widget child;
    if (q.type == 'text') {
      final controller = _controllers.putIfAbsent(
        q.id,
        () => TextEditingController(),
      );
      child = TextFormField(
        controller: controller,
        onChanged: (v) => _answers[q.id] = v,
        decoration: InputDecoration(
          hintText:
              locale.languageCode == 'ar'
                  ? 'اكتب إجابتك هنا...'
                  : 'Type your answer here...',
        ),
        validator:
            (v) =>
                (q.required && (v == null || v.isEmpty))
                    ? AppStrings.get('requiredField', context)
                    : null,
      );
    } else {
      final options = q.optionsFor(locale);
      child = Column(
        children: List.generate(options.length, (index) {
          final optionLabel = options[index];
          final value = q.optionsEn[index];
          return RadioListTile<String>(
            title: Text(optionLabel),
            value: value,
            groupValue: _answers[q.id],
            onChanged: (v) => setState(() => _answers[q.id] = v),
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: colorScheme.primary,
          );
        }),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              q.questionFor(locale),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
