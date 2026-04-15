import 'package:flutter/material.dart';

import '../app/strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(28),
                    image: const DecorationImage(
                      image: AssetImage('assets/logo_sustainable.jpg'),
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
            const SizedBox(height: 16),
            Text(
              AppStrings.get('appName', context),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get('welcomeSubtitle', context),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
