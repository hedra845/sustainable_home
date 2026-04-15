import 'package:flutter/material.dart';

import '../app/model.dart';
import '../app/strings.dart';

class NewsStoriesScreen extends StatelessWidget {
  const NewsStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('newsStories', context))),
      body: const NewsStoriesBody(),
    );
  }
}

class NewsStoriesBody extends StatefulWidget {
  const NewsStoriesBody({super.key});

  @override
  State<NewsStoriesBody> createState() => _NewsStoriesBodyState();
}

class _NewsStoriesBodyState extends State<NewsStoriesBody> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  StoryKind _filter = StoryKind.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);

    final normalized = _query.trim().toLowerCase();
    final items = model.stories.where((s) {
      if (_filter != StoryKind.all && s.kind != _filter) return false;
      if (normalized.isEmpty) return true;
      final text = '${s.titleFor(locale)} ${s.subtitleFor(locale)}'.toLowerCase();
      return text.contains(normalized);
    }).toList();

    return RefreshIndicator(
      onRefresh: () => model.refreshStories(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: AppStrings.get('searchStories', context),
              prefixIcon: const Icon(Icons.search),
              fillColor: colorScheme.surfaceContainerHighest,
              suffixIcon: _query.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  selected: _filter == StoryKind.all,
                  onSelected: (_) => setState(() => _filter = StoryKind.all),
                  label: Text(AppStrings.get('all', context)),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  selected: _filter == StoryKind.news,
                  onSelected: (_) => setState(() => _filter = StoryKind.news),
                  label: Text(AppStrings.get('news', context)),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  selected: _filter == StoryKind.story,
                  onSelected: (_) => setState(() => _filter = StoryKind.story),
                  label: Text(AppStrings.get('stories', context)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Center(
                child: Text(
                  AppStrings.get('noResults', context),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ...items.map((s) => _StoryCard(story: s)),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final AppStory story;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final kindLabel = story.kind == StoryKind.news
        ? AppStrings.get('news', context)
        : AppStrings.get('stories', context);
    final accent = story.kind == StoryKind.news
        ? colorScheme.tertiary
        : colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _StoryDetailScreen(story: story)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(story.imageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withAlpha(24),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: accent.withAlpha(70)),
                        ),
                        child: Text(
                          kindLabel,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${story.minutesRead} ${AppStrings.get('min', context)}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    story.titleFor(locale),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    story.subtitleFor(locale),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        AppStrings.get('readMore', context),
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
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

class _StoryDetailScreen extends StatelessWidget {
  const _StoryDetailScreen({required this.story});

  final AppStory story;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final accent = story.kind == StoryKind.news
        ? colorScheme.tertiary
        : colorScheme.primary;
    final kindLabel = story.kind == StoryKind.news
        ? AppStrings.get('news', context)
        : AppStrings.get('stories', context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('newsStories', context))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(story.imageUrl, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withAlpha(24),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: accent.withAlpha(70)),
                            ),
                            child: Text(
                              kindLabel,
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${story.minutesRead} ${AppStrings.get('min', context)}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        story.titleFor(locale),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        story.subtitleFor(locale),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...story.contentFor(locale).map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            p,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
