import 'package:flutter/material.dart';

class SdgAction {
  const SdgAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
}

class SdgCard extends StatelessWidget {
  const SdgCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.accent,
    required this.actions,
    this.badge,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final Color accent;
  final List<SdgAction> actions;
  final String? badge;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(110),
                        ],
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 12,
                  start: 12,
                  end: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withAlpha(235),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.eco, color: accent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'SDG',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withAlpha(35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: accent.withAlpha(80)),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                PositionedDirectional(
                  end: 12,
                  bottom: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(110),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(40)),
                    ),
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        actions
                            .map(
                              (a) => FilledButton.icon(
                                onPressed: a.onTap,
                                icon: Icon(a.icon, size: 18),
                                label: Text(a.label),
                                style: FilledButton.styleFrom(
                                  backgroundColor: a.backgroundColor ?? colorScheme.secondaryContainer,
                                  foregroundColor: a.foregroundColor ?? colorScheme.onSecondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            )
                            .toList(),
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
