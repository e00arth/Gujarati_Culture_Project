import 'package:flutter/material.dart';

import '../data/strings.dart';
import '../models/kehvat.dart';
import '../services/settings_store.dart';

/// Top-bar button that picks the language meanings and stories are read in.
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key, required this.settings});

  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: Strings.of(settings.language).readIn,
      icon: const Icon(Icons.translate),
      initialValue: settings.language,
      onSelected: (code) => settings.language = code,
      itemBuilder: (context) => [
        for (final entry in languageLabels.entries)
          PopupMenuItem(value: entry.key, child: Text(entry.value)),
      ],
    );
  }
}
