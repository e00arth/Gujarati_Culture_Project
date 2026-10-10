import 'package:flutter/material.dart';

import '../data/strings.dart';
import '../models/kehvat.dart';
import '../services/favorites_store.dart';
import '../services/settings_store.dart';
import 'language_menu.dart';

/// The symbol each section has on the switch. The three meaning levels show
/// as one, two and three bars.
const _sectionIcons = {
  Section.backstory: Icons.history_edu,
  Section.simple: Icons.signal_cellular_alt_1_bar,
  Section.normal: Icons.signal_cellular_alt_2_bar,
  Section.advanced: Icons.signal_cellular_alt,
  Section.story: Icons.auto_stories,
};

/// One kehvat with the chosen section: its backstory, its meaning at one
/// level, or its story.
class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.kehvat,
    required this.categories,
    required this.favorites,
    required this.settings,
  });

  final Kehvat kehvat;

  /// Every category, to name the ones [kehvat] belongs to.
  final List<Category> categories;
  final FavoritesStore favorites;
  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([favorites, settings]),
      builder: (context, _) {
        final language = settings.language;
        final strings = Strings.of(language);
        // The Hindi wording always sits under the kehvat, so reading in
        // Hindi needs no separate literal translation.
        final literal = language == 'hi' ? null : kehvat.literal[language];
        final heading = theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        );
        return Scaffold(
          appBar: AppBar(
            actions: [
              LanguageMenu(settings: settings),
              IconButton(
                tooltip: strings.favourites,
                icon: Icon(
                  favorites.contains(kehvat.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                onPressed: () => favorites.toggle(kehvat.id),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(kehvat.text, style: theme.textTheme.headlineSmall),
              if (kehvat.hindi != null) ...[
                const SizedBox(height: 4),
                Text(kehvat.hindi!, style: theme.textTheme.titleMedium),
              ],
              const SizedBox(height: 4),
              Text(
                kehvat.roman,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (literal != null) ...[
                const SizedBox(height: 20),
                Text(strings.literal, style: heading),
                const SizedBox(height: 4),
                Text(literal, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: 12),
              Text(
                [
                  for (final c in categories)
                    if (kehvat.categories.contains(c.id)) c.names[language]!,
                ].join('  ·  '),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (!kehvat.hasMeaning) ...[
                const SizedBox(height: 20),
                Text(strings.noMeaningYet, style: theme.textTheme.bodyLarge),
              ] else ...[
                const SizedBox(height: 20),
                SegmentedButton<Section>(
                  showSelectedIcon: false,
                  // The sections show as symbols; the heading below names the
                  // chosen one.
                  segments: [
                    for (final section in Section.values)
                      ButtonSegment(
                        value: section,
                        icon: Icon(_sectionIcons[section]),
                        tooltip: strings.sections[section],
                      ),
                  ],
                  selected: {settings.section},
                  onSelectionChanged: (picked) =>
                      settings.section = picked.single,
                ),
                const SizedBox(height: 16),
                // For the story, says whether it is the kehvat's own tale or an
                // example.
                Text(
                  settings.section != Section.story
                      ? strings.sections[settings.section]!
                      : kehvat.folk
                      ? strings.folkStory
                      : strings.story,
                  style: heading,
                ),
                const SizedBox(height: 4),
                Text(
                  kehvat.read(language, settings.section),
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
