import 'package:flutter/material.dart';

import '../app/model.dart';
import '../app/strings.dart';
import 'news_stories_screen.dart';
import '../widgets/evaluation_dialog.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
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
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final progress = model.weeklyProgress;
    final locale = model.locale;
    final items = model.challenges;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('challenges', context)),
        actions: [
          IconButton(
            onPressed: () async {
              await model.refreshChallengeCompletions();
            },
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(
                        locale.languageCode == 'ar'
                            ? 'إعادة تعيين الأسبوع'
                            : 'Reset Week',
                      ),
                      content: Text(
                        locale.languageCode == 'ar'
                            ? 'هل أنت متأكد من مسح جميع التحديات المكتملة لهذا الأسبوع؟'
                            : 'Are you sure you want to clear all completed challenges for this week?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppStrings.get('cancel', context)),
                        ),
                        TextButton(
                          onPressed: () {
                            model.resetWeek();
                            Navigator.pop(context);
                          },
                          child: Text(
                            locale.languageCode == 'ar'
                                ? 'إعادة تعيين'
                                : 'Reset',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
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
          RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                model.refreshChallenges(),
                model.refreshChallengeCompletions(),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.get('weeklyProgress', context),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${model.challengesCompleted}/${model.weeklyGoal}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...items.map((item) {
                  final done = model.isChallengeCompleted(item.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: CheckboxListTile(
                        value: done,
                        onChanged: (bool? _) {
                          model.toggleChallenge(item.id).then((_) {
                            if (context.mounted) {
                              EvaluationDialog.showIfNeeded(context);
                            }
                          });
                        },
                        title: Text(
                          item.titleFor(locale),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          item.bodyFor(locale),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          NewsStoriesBody(),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     model.addImpact(
      //       actionType: 'bonus',
      //       co2DeltaKg: 0.2,
      //       wasteDeltaKg: 0.1,
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
