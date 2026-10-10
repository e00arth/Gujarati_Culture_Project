import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/strings.dart';
import '../models/kehvat.dart';
import '../services/favorites_store.dart';
import '../services/settings_store.dart';
import '../services/study_store.dart';
import 'detail_screen.dart';

/// Flashcards: the first half of a kehvat is shown, and the reader recalls
/// the rest before turning the card.
class StudyScreen extends StatefulWidget {
  const StudyScreen({
    super.key,
    required this.deck,
    required this.categories,
    required this.study,
    required this.favorites,
    required this.settings,
  });

  /// The kehvto that can be practised, in the order new ones are introduced.
  final List<Kehvat> deck;
  final List<Category> categories;
  final StudyStore study;
  final FavoritesStore favorites;
  final SettingsStore settings;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late List<Kehvat> _queue;

  /// How many cards this sitting started with, and how many were known the
  /// first time they came up.
  late int _total;
  int _known = 0;
  int _done = 0;

  /// The cards already answered once; a missed card comes round again but
  /// only its first answer moves it between boxes.
  final _answered = <String>{};
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _queue = widget.study.session(widget.deck);
    _total = _queue.length;
    _known = _done = 0;
    _answered.clear();
    _revealed = false;
  }

  void _answer(bool knew) {
    final kehvat = _queue.removeAt(0);
    if (_answered.add(kehvat.id)) {
      widget.study.answer(kehvat.id, knew: knew);
      _done++;
      if (knew) _known++;
      if (!knew) _queue.add(kehvat);
    }
    knew ? HapticFeedback.lightImpact() : HapticFeedback.mediumImpact();
    setState(() => _revealed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = widget.settings.language;
    final strings = Strings.of(language);
    return Scaffold(
      appBar: AppBar(title: Text(strings.study)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: _queue.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _total == 0 ? strings.nothingDue : strings.sessionDone,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (_total > 0)
                      Text(
                        strings.knownOf(_known, _total),
                        style: theme.textTheme.titleMedium,
                      ),
                    const SizedBox(height: 4),
                    Text(strings.learned(widget.study.learned)),
                    const SizedBox(height: 24),
                    if (widget.study.session(widget.deck).isNotEmpty)
                      FilledButton(
                        onPressed: () => setState(_start),
                        child: Text(strings.more),
                      ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: _done / _total),
                  const SizedBox(height: 16),
                  Expanded(child: _card(context, _queue.first, strings)),
                  const SizedBox(height: 16),
                  if (!_revealed)
                    FilledButton(
                      onPressed: () => setState(() => _revealed = true),
                      child: Text(strings.reveal),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.replay),
                            label: Text(strings.again),
                            onPressed: () => _answer(false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.check),
                            label: Text(strings.knew),
                            onPressed: () => _answer(true),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
      ),
    );
  }

  Widget _card(BuildContext context, Kehvat kehvat, Strings strings) {
    final theme = Theme.of(context);
    final (first, rest) = kehvat.halves!;
    final language = widget.settings.language;
    final card = Card(
      child: InkWell(
        onTap: _revealed ? null : () => setState(() => _revealed = true),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '$first ',
                      children: [
                        TextSpan(
                          text: _revealed ? rest : '…',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  if (_revealed) ...[
                    const SizedBox(height: 12),
                    Text(
                      kehvat.roman,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    // The kehvat in the other two languages, where written.
                    for (final code in languageLabels.keys)
                      if (kehvat.literal[code] case final wording?) ...[
                        const SizedBox(height: 8),
                        Text(
                          wording,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    if (kehvat.hasMeaning) ...[
                      const SizedBox(height: 16),
                      Text(
                        kehvat.meaning[language]![MeaningLevel.simple]!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              kehvat: kehvat,
                              categories: widget.categories,
                              favorites: widget.favorites,
                              settings: widget.settings,
                            ),
                          ),
                        ),
                        child: Text(strings.readMore),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!_revealed) return card;
    // Once turned, the card can be swiped: right if known, left if not.
    return Dismissible(
      key: ValueKey('${kehvat.id}-${_answered.length}-${_queue.length}'),
      onDismissed: (direction) =>
          _answer(direction == DismissDirection.startToEnd),
      child: card,
    );
  }
}
