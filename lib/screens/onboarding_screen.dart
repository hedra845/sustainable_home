import 'package:flutter/material.dart';

import '../app/model.dart';
import '../app/strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isLast = _index == 2;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      model.toggleLanguage();
                    },
                    icon: const Icon(Icons.language),
                  ),
                  IconButton(
                    onPressed: () {
                      model.toggleTheme();
                    },
                    icon: Icon(
                      model.isDarkMode
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => model.completeOnboarding(),
                    child: Text(AppStrings.get('skip', context)),
                  ),
                ],
              ),
              Expanded(
                child: PageView(
                  key: const Key('onboarding'),
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: [
                    _OnboardingPage(
                      icon: Icons.lightbulb_outline,
                      title: AppStrings.get('onboarding1Title', context),
                      body: AppStrings.get('onboarding1Body', context),
                    ),
                    _OnboardingPage(
                      icon: Icons.track_changes,
                      title: AppStrings.get('onboarding2Title', context),
                      body: AppStrings.get('onboarding2Body', context),
                    ),
                    _OnboardingPage(
                      icon: Icons.flag_outlined,
                      title: AppStrings.get('onboarding3Title', context),
                      body: AppStrings.get('onboarding3Body', context),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final selected = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (isLast) {
                      model.completeOnboarding();
                      return;
                    }
                    await _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  icon: Icon(
                    isLast ? Icons.check_circle_outline : Icons.arrow_forward,
                  ),
                  label: Text(
                    AppStrings.get(isLast ? 'startNow' : 'next', context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(28),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 44),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
