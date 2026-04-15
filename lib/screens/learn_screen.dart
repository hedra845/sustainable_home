import 'package:flutter/material.dart';

import '../app/model.dart';
import '../app/strings.dart';
import '../widgets/sdg_card.dart';
import 'sdg_article_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final GlobalKey _sdg11Key = GlobalKey();
  final GlobalKey _sdg12Key = GlobalKey();
  final TextEditingController _search = TextEditingController();
  String _query = '';
  _LearnSort _sort = _LearnSort.id;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      alignment: 0.04,
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final locale = model.locale;

    final goals =
        model.supabaseEnabled && model.sdgGoals.isNotEmpty
            ? model.sdgGoals
            : [
              SdgGoal(
                id: 11,
                titleEn: 'SDG 11 Sustainable Cities',
                titleAr: 'الهدف 11: مدن ومجتمعات مستدامة',
                subtitleEn:
                    'Make cities inclusive, safe, resilient, and sustainable.',
                subtitleAr:
                    'اجعل المدن شاملة وآمنة وقادرة على الصمود ومستدامة.',
                imageUrl: 'https://picsum.photos/seed/sdg11/1200/600',
              ),
              SdgGoal(
                id: 12,
                titleEn: 'SDG 12 Responsible Consumption',
                titleAr: 'الهدف 12: الاستهلاك والإنتاج المسؤولان',
                subtitleEn:
                    'Ensure sustainable consumption and production patterns.',
                subtitleAr: 'ضمان أنماط استهلاك وإنتاج مستدامة.',
                imageUrl: 'https://picsum.photos/seed/sdg12/1200/600',
              ),
            ];
    final normalized = _query.trim().toLowerCase();
    final filteredGoals =
        goals.where((g) {
            if (normalized.isEmpty) return true;
            final text =
                '${g.titleFor(locale)} ${g.subtitleFor(locale)}'.toLowerCase();
            return text.contains(normalized);
          }).toList()
          ..sort((a, b) {
            if (_sort == _LearnSort.title) {
              return a
                  .titleFor(locale)
                  .toLowerCase()
                  .compareTo(b.titleFor(locale).toLowerCase());
            }
            return a.id.compareTo(b.id);
          });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('learnSdgs', context)),
        actions: [
          PopupMenuButton<_LearnSort>(
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            icon: const Icon(Icons.sort),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: _LearnSort.id,
                    child: Text(AppStrings.get('sortById', context)),
                  ),
                  PopupMenuItem(
                    value: _LearnSort.title,
                    child: Text(AppStrings.get('sortByTitle', context)),
                  ),
                ],
          ),
          IconButton(
            onPressed: () async {
              await model.refreshSdgGoals();
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await model.refreshSdgGoals();
          if (mounted) setState(() {});
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Material(
                    color: colorScheme.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(28),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.public,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.get('learnHeaderTitle', context),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.get(
                                    'learnHeaderSubtitle',
                                    context,
                                  ),
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: AppStrings.get('searchSdgs', context),
                      prefixIcon: const Icon(Icons.search),
                      fillColor: colorScheme.surfaceContainerHighest,
                      suffixIcon:
                          _query.trim().isEmpty
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
                        ActionChip(
                          onPressed: () => _scrollTo(_sdg11Key),
                          label: Text(AppStrings.get('sdg11Chip', context)),
                        ),
                        const SizedBox(width: 10),
                        ActionChip(
                          onPressed: () => _scrollTo(_sdg12Key),
                          label: Text(AppStrings.get('sdg12Chip', context)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (filteredGoals.isEmpty)
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
                  ...filteredGoals.map((g) {
                    final accent =
                        g.id == 11
                            ? colorScheme.primary
                            : (g.id == 12
                                ? colorScheme.secondary
                                : colorScheme.tertiary);
                    final key =
                        g.id == 11
                            ? _sdg11Key
                            : (g.id == 12 ? _sdg12Key : null);
                    void openArticle() {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SdgArticleScreen(goal: g),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SdgCard(
                        key: key,
                        badge: g.id == 0 ? null : g.id.toString(),
                        title: g.titleFor(locale),
                        subtitle: g.subtitleFor(locale),
                        imageUrl: g.imageUrl,
                        accent: accent,
                        onTap: openArticle,
                        actions: [
                          SdgAction(
                            label: AppStrings.get('learnMore', context),
                            icon: Icons.info_outline,
                            onTap: openArticle,
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ],
                      ),
                    );
                  }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _LearnSort { id, title }
