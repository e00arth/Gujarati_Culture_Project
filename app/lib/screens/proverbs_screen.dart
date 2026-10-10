import 'package:flutter/material.dart';

import '../data/kehvat_repository.dart';
import '../data/strings.dart';
import '../models/kehvat.dart';
import '../services/daily.dart';
import '../services/favorites_store.dart';
import '../services/settings_store.dart';
import '../services/study_store.dart';
import 'daily_dialog.dart';
import 'detail_screen.dart';
import 'quiz_screen.dart';
import 'study_screen.dart';

class ProverbsScreen extends StatefulWidget {
  const ProverbsScreen({
    super.key,
    required this.repository,
    required this.favorites,
    required this.settings,
    required this.study,
    required this.daily,
  });

  final KehvatRepository repository;
  final FavoritesStore favorites;
  final SettingsStore settings;
  final StudyStore study;
  final DailyKehvat daily;

  @override
  State<ProverbsScreen> createState() => _ProverbsScreenState();
}

class _ProverbsScreenState extends State<ProverbsScreen> {
  String? _category;
  String _query = '';
  bool _favoritesOnly = false;

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  void _open(Kehvat kehvat) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DetailScreen(
        kehvat: kehvat,
        categories: widget.repository.categories,
        favorites: widget.favorites,
        settings: widget.settings,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.favorites,
        widget.settings,
        widget.daily.store,
      ]),
      builder: (context, _) {
        final language = widget.settings.language;
        final strings = Strings.of(language);
        final kehvto = widget.repository
            .filter(
              category: _category,
              query: _query,
            )
            .where((k) => !_favoritesOnly || widget.favorites.contains(k.id))
            .toList();

        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: strings.search,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        icon: const Icon(Icons.school_outlined, size: 18),
                        label: Text(strings.study),
                        onPressed: () => _push(
                          StudyScreen(
                            deck: widget.repository.studyDeck,
                            categories: widget.repository.categories,
                            study: widget.study,
                            favorites: widget.favorites,
                            settings: widget.settings,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        icon: const Icon(Icons.quiz_outlined, size: 18),
                        label: Text(strings.quiz),
                        onPressed: () => _push(
                          QuizScreen(
                            deck: widget.repository.studyDeck,
                            settings: widget.settings,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: strings.daily,
                      icon: Icon(
                        widget.daily.store.on ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                        color: Colors.orange,
                      ),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => DailyDialog(
                          daily: widget.daily,
                          settings: widget.settings,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: strings.favourites,
                      icon: Icon(
                        _favoritesOnly ? Icons.favorite : Icons.favorite_border,
                        color: _favoritesOnly ? Colors.red : null,
                      ),
                      onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: DropdownButtonFormField<String?>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(child: Text(strings.allCategories)),
                    for (final category in widget.repository.categories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.names[language] ?? category.id),
                      ),
                  ],
                  onChanged: (id) => setState(() => _category = id),
                ),
              ),
              Expanded(
                child: kehvto.isEmpty
                    ? Center(child: Text(strings.noMatch))
                    : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: kehvto.length,
                  itemBuilder: (context, index) {
                    final item = kehvto[index];
                    final isFav = widget.favorites.contains(item.id);
                    return ListTile(
                      title: Text(item.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item.roman, style: const TextStyle(fontStyle: FontStyle.italic)),
                      trailing: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => widget.favorites.toggle(item.id),
                      ),
                      onTap: () => _open(item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
