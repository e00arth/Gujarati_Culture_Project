import 'package:flutter/material.dart';

import '../data/cultural_repository.dart';
import '../models/cultural_models.dart';
import '../services/paywall_store.dart';
import 'paywall_dialog.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.paywall});

  final PaywallStore paywall;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  EBook? _selectedBookForReader;
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = widget.paywall.isUnlocked(CulturalModule.library);

    if (_selectedBookForReader != null) {
      final book = _selectedBookForReader!;
      return Scaffold(
        appBar: AppBar(
          title: Text(book.titleGu),
          actions: [
            IconButton(
              icon: const Text('A-', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                if (_fontSize > 12) setState(() => _fontSize -= 2);
              },
            ),
            IconButton(
              icon: const Text('A+', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                if (_fontSize < 28) setState(() => _fontSize += 2);
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              book.sampleChapterTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: _fontSize + 2,
              ),
            ),
            const Divider(height: 24),
            Text(
              book.sampleChapterContent,
              style: TextStyle(fontSize: _fontSize, height: 1.6),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFEDE7F6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, size: 36, color: Color(0xFF5E35B1)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('અસ્મિતા ડિજિટલ ગ્રંથાલય', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4527A0))),
                        Text('The 7 Cultural Heritage E-Books & Reader', style: TextStyle(fontSize: 13, color: Color(0xFF5E35B1))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final book in CulturalRepository.libraryBooks) ...[
            Builder(
              builder: (context) {
                final accessible = book.isSampleFree || isUnlocked;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(book.titleGu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                            if (!accessible)
                              Row(
                                children: [
                                  Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text('LOCKED', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(book.titleEn, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                        Text('Author: ${book.author} · ${book.chaptersCount} Chapters', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(book.summary, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FilledButton.tonalIcon(
                              icon: const Icon(Icons.auto_stories, size: 18),
                              label: Text(accessible ? 'Read Book' : 'Unlock Full Book'),
                              onPressed: () {
                                if (accessible) {
                                  setState(() => _selectedBookForReader = book);
                                } else {
                                  PaywallDialog.show(context, CulturalModule.library, widget.paywall);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
