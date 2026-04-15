import 'package:flutter/material.dart';
import '../app/model.dart';
import '../app/strings.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final leaderboard = model.leaderboard;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('leaderboard', context)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (model.supabaseEnabled) {
            await model.refreshLeaderboard();
          }
        },
        child: leaderboard.isEmpty
            ? Center(
                child: Text(
                  locale.languageCode == 'ar'
                      ? 'لا يوجد متصدرين حالياً'
                      : 'No leaderboard entries yet',
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final entry = leaderboard[index];
                  final isFirst = index == 0;
                  final isSecond = index == 1;
                  final isThird = index == 2;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isFirst
                            ? Colors.amber.withAlpha(120)
                            : colorScheme.outlineVariant,
                        width: isFirst ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: _buildRankBadge(context, index + 1),
                      title: Text(
                        entry.name,
                        style: TextStyle(
                          fontWeight:
                              isFirst ? FontWeight.bold : FontWeight.w600,
                          fontSize: isFirst ? 18 : 16,
                        ),
                      ),
                      subtitle: Text(
                        '${entry.points.round()} ${AppStrings.get('points', context)}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          (entry.avatarUrl == null ||
                                  entry.avatarUrl!.trim().isEmpty)
                              ? 'https://api.dicebear.com/7.x/avataaars/svg?seed=${entry.name}'
                              : entry.avatarUrl!,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context, int rank) {
    final colorScheme = Theme.of(context).colorScheme;

    Color badgeColor;
    IconData? icon;

    if (rank == 1) {
      badgeColor = Colors.amber;
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      badgeColor = Colors.grey.shade400;
      icon = Icons.emoji_events;
    } else if (rank == 3) {
      badgeColor = Colors.brown.shade300;
      icon = Icons.emoji_events;
    } else {
      badgeColor = colorScheme.primary.withAlpha(40);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(rank <= 3 ? 255 : 40),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 20)
            : Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
      ),
    );
  }
}
