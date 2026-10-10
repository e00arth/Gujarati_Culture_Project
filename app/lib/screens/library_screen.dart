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
  int _selectedChapterIndex = 0;
  double _fontSize = 16.0;
  String _readerTheme = 'sepia'; // light, sepia, dark

  Color _getBackgroundColor() {
    return switch (_readerTheme) {
      'dark' => const Color(0xFF1E1E1E),
      'sepia' => const Color(0xFFFBF0D9),
      _ => Colors.white,
    };
  }

  Color _getTextColor() {
    return switch (_readerTheme) {
      'dark' => const Color(0xFFE0E0E0),
      'sepia' => const Color(0xFF3E2723),
      _ => Colors.black87,
    };
  }

  void _showChapterSelector(EBook book) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('અનુક્રમણિકા (Chapters)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          for (int i = 0; i < book.chapters.length; i++)
            ListTile(
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: _selectedChapterIndex == i ? Colors.deepOrange : Colors.grey.shade300,
                child: Text('${book.chapters[i].number}', style: TextStyle(fontSize: 11, color: _selectedChapterIndex == i ? Colors.white : Colors.black)),
              ),
              title: Text(book.chapters[i].title, style: TextStyle(fontWeight: _selectedChapterIndex == i ? FontWeight.bold : FontWeight.normal)),
              selected: _selectedChapterIndex == i,
              onTap: () {
                setState(() => _selectedChapterIndex = i);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = widget.paywall.isUnlocked(CulturalModule.library);

    if (_selectedBookForReader != null) {
      final book = _selectedBookForReader!;
      final currentChapter = book.chapters.isNotEmpty
          ? book.chapters[_selectedChapterIndex.clamp(0, book.chapters.length - 1)]
          : BookChapter(number: 1, title: book.sampleChapterTitle, content: book.sampleChapterContent);

      final bgColor = _getBackgroundColor();
      final textColor = _getTextColor();

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          title: Text(book.titleGu, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              tooltip: 'Chapters',
              onPressed: () => _showChapterSelector(book),
            ),
            IconButton(
              icon: Icon(_readerTheme == 'dark' ? Icons.nightlight_round : _readerTheme == 'sepia' ? Icons.auto_awesome : Icons.wb_sunny_outlined),
              tooltip: 'Theme',
              onPressed: () {
                setState(() {
                  _readerTheme = switch (_readerTheme) {
                    'light' => 'sepia',
                    'sepia' => 'dark',
                    _ => 'light',
                  };
                });
              },
            ),
            IconButton(
              icon: const Text('A-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                if (_fontSize > 12) setState(() => _fontSize -= 2);
              },
            ),
            IconButton(
              icon: const Text('A+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                if (_fontSize < 28) setState(() => _fontSize += 2);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Text(
                    currentChapter.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: _fontSize + 4,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chapter ${currentChapter.number} of ${book.chapters.length} · ${book.author}',
                    style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6)),
                  ),
                  const Divider(height: 24),
                  SelectableText(
                    currentChapter.content,
                    style: TextStyle(fontSize: _fontSize, height: 1.7, color: textColor, fontFamily: 'serif'),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_selectedChapterIndex > 0)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          onPressed: () => setState(() => _selectedChapterIndex--),
                        )
                      else
                        const SizedBox.shrink(),
                      if (_selectedChapterIndex < book.chapters.length - 1)
                        FilledButton.icon(
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next Chapter'),
                          onPressed: () => setState(() => _selectedChapterIndex++),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
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
                        Text('The 7 Cultural Heritage E-Books & Reader', style: TextStyle(fontSize: 12, color: Color(0xFF5E35B1))),
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
                            Expanded(child: Text(book.titleGu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            if (!accessible)
                              Row(
                                children: [
                                  Icon(Icons.lock, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text('LOCKED', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                                ],
                              )
                            else
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text('FREE PREVIEW', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(book.titleEn, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                        Text('Author: ${book.author} · ${book.chaptersCount} Chapters', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(book.summary, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FilledButton.tonalIcon(
                              icon: Icon(accessible ? Icons.auto_stories : Icons.lock_open, size: 18),
                              label: Text(accessible ? 'Read Book' : 'Unlock Full Book'),
                              onPressed: () {
                                if (accessible) {
                                  setState(() {
                                    _selectedBookForReader = book;
                                    _selectedChapterIndex = 0;
                                  });
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
