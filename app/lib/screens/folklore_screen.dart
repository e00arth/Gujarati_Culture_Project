import 'package:flutter/material.dart';

import '../data/cultural_repository.dart';
import '../models/cultural_models.dart';
import '../services/paywall_store.dart';
import 'paywall_dialog.dart';

class FolkloreScreen extends StatefulWidget {
  const FolkloreScreen({super.key, required this.paywall});

  final PaywallStore paywall;

  @override
  State<FolkloreScreen> createState() => _FolkloreScreenState();
}

class _FolkloreScreenState extends State<FolkloreScreen> {
  String? _currentlyPlayingId;
  String _selectedCategory = 'બધા';

  void _showLyrics(FolkloreTrack track) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 4),
              Text('${track.category} · ${track.artist}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13)),
              const SizedBox(height: 8),
              Text(track.description, style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 13)),
              const Divider(height: 24),
              const Text('સાહિત્ય અને શબ્દો (Lyrics / Narrative):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              SelectableText(
                track.lyricsOrText,
                style: const TextStyle(fontSize: 16, height: 1.6, fontFamily: 'serif'),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = widget.paywall.isUnlocked(CulturalModule.folklore);

    final categories = ['બધા', 'હાલરડું', 'લોકગીત', 'દુહા-છંદ & વીરગાથા', 'લોકવાર્તા', 'ભજન', 'રાસ', 'દાયરો'];

    final filteredTracks = _selectedCategory == 'બધા'
        ? CulturalRepository.folkloreTracks
        : CulturalRepository.folkloreTracks.where((t) => t.category.contains(_selectedCategory)).toList();

    final activeTrack = CulturalRepository.folkloreTracks.where((t) => t.id == _currentlyPlayingId).firstOrNull;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.headphones, size: 36, color: theme.colorScheme.secondary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('લોકસાહિત્ય અને હાલરડાં', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('Oral Folklore, Lullabies & Rasdhar Narrations', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final cat in categories)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: _selectedCategory == cat,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedCategory = cat);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (final track in filteredTracks) ...[
                  Builder(
                    builder: (context) {
                      final accessible = track.isSampleFree || isUnlocked;
                      final isPlaying = _currentlyPlayingId == track.id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: IconButton(
                            icon: Icon(
                              !accessible
                                  ? Icons.lock
                                  : isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              size: 38,
                              color: !accessible
                                  ? Colors.grey
                                  : isPlaying
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                            ),
                            onPressed: () {
                              if (!accessible) {
                                PaywallDialog.show(context, CulturalModule.folklore, widget.paywall);
                              } else {
                                setState(() {
                                  _currentlyPlayingId = isPlaying ? null : track.id;
                                });
                              }
                            },
                          ),
                          title: Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${track.category} · ${track.duration}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('Artist: ${track.artist}', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary)),
                              const SizedBox(height: 4),
                              Text(track.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: accessible
                              ? IconButton(
                            icon: const Icon(Icons.lyrics_outlined),
                            tooltip: 'Lyrics / Story',
                            onPressed: () => _showLyrics(track),
                          )
                              : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('LOCKED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          onTap: () {
                            if (!accessible) {
                              PaywallDialog.show(context, CulturalModule.folklore, widget.paywall);
                            } else {
                              _showLyrics(track);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          if (activeTrack != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(activeTrack.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${activeTrack.artist} · ${activeTrack.duration}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.lyrics_outlined),
                    tooltip: 'View Lyrics',
                    onPressed: () => _showLyrics(activeTrack),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    tooltip: 'Stop',
                    onPressed: () => setState(() => _currentlyPlayingId = null),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
