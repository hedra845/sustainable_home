import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/model.dart';
import '../app/strings.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final about = model.aboutUs;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.languageCode == 'ar' ? 'معلومات عنا' : 'About Us'),
      ),
      body:
          about == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (about.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            about.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: colorScheme.primary,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      about.titleFor(locale),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(20),
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/logo_sustainable.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(20),
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/ras_al_khaimah_university.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      about.contentFor(locale),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (about.email != null || about.website != null) ...[
                      Text(
                        locale.languageCode == 'ar'
                            ? 'تواصل معنا'
                            : 'Contact Us',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (about.email != null)
                        _buildContactTile(
                          context,
                          icon: Icons.email_outlined,
                          label: about.email!,
                          onTap:
                              () =>
                                  launchUrl(Uri.parse('mailto:${about.email}')),
                        ),
                      if (about.website != null)
                        _buildContactTile(
                          context,
                          icon: Icons.language_outlined,
                          label: about.website!,
                          onTap: () => launchUrl(Uri.parse(about.website!)),
                        ),
                    ],
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            AppStrings.get('appName', context),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Version 1.0.0',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
