import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

import '../app/model.dart';
import '../app/strings.dart';
import '../widgets/impact_panel.dart';
import 'support_chat_screen.dart';
import 'about_us_screen.dart';
import 'leaderboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final locale = Localizations.localeOf(context);

    Future<void> pickAndUploadAvatar() async {
      if (!model.supabaseEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('supabaseNotConfigured', context)),
          ),
        );
        return;
      }
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;
      final error = await model.uploadAvatar(
        bytes: Uint8List.fromList(bytes),
        fileName: file.name,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error == null
                ? (locale.languageCode == 'ar'
                    ? 'تم تحديث الصورة'
                    : 'Photo updated')
                : (locale.languageCode == 'ar'
                    ? 'تعذّر رفع الصورة: $error'
                    : 'Failed to upload: $error'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('profile', context)),
        actions: [
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
          IconButton(
            onPressed: () {
              model.toggleLanguage();
            },
            icon: const Icon(Icons.language),
          ),
          IconButton(
            onPressed: () {
              model.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (model.supabaseEnabled) {
            await model.refreshProfile();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(
                name:
                    model.fullName ??
                    (locale.languageCode == 'ar' ? 'مستخدم جديد' : 'New User'),
                subtitle:
                    '${AppStrings.get('ecoHero', context)} - ${AppStrings.get('level', context)} 1',
                weeklyProgress: model.weeklyProgress,
                avatarUrl: model.avatarUrl,
                onChangeAvatar: pickAndUploadAvatar,
              ),
              const SizedBox(height: 18),
              _buildStatGrid(context, model),
              const SizedBox(height: 18),
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
              const SizedBox(height: 18),
              _buildLeaderboardPreview(context, model),
              const SizedBox(height: 18),
              _buildAboutUsButton(context),
              const SizedBox(height: 12),
              _buildSupportButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutUsButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AboutUsScreen()));
        },
        leading: Icon(Icons.info_outline, color: colorScheme.primary),
        title: Text(
          locale.languageCode == 'ar' ? 'معلومات عنا' : 'About Us',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildSupportButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SupportChatScreen()));
        },
        leading: Icon(Icons.support_agent, color: colorScheme.primary),
        title: Text(
          AppStrings.get('supportChat', context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(AppStrings.get('supportChatSubtitle', context)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, SustainabilityModel model) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard(
          context,
          AppStrings.get('badges', context),
          '0',
          Icons.emoji_events,
          Colors.orange,
        ),
        _statCard(
          context,
          AppStrings.get('challenges', context),
          model.challengesCompleted.toString(),
          Icons.task_alt,
          Colors.green,
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String val,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(28),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withAlpha(60)),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    val,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardPreview(
    BuildContext context,
    SustainabilityModel model,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final leaderboard = model.leaderboard;

    if (leaderboard.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('leaderboard', context),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: List.generate(leaderboard.length, (index) {
                final isLast = index == leaderboard.length - 1;
                final entry = leaderboard[index];

                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Center(
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      title: Text(entry.name),
                      trailing: Text(
                        '${entry.points.round()} ${AppStrings.get('points', context)}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(color: colorScheme.outlineVariant, height: 1),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.subtitle,
    required this.weeklyProgress,
    required this.avatarUrl,
    required this.onChangeAvatar,
  });

  final String name;
  final String subtitle;
  final double weeklyProgress;
  final String? avatarUrl;
  final VoidCallback onChangeAvatar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = weeklyProgress.clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 74,
                  height: 74,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
                InkWell(
                  onTap: onChangeAvatar,
                  borderRadius: BorderRadius.circular(40),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          (avatarUrl == null || avatarUrl!.trim().isEmpty)
                              ? 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ahmed'
                              : avatarUrl!,
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
