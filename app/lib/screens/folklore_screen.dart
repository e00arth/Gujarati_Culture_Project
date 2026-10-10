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

  void _showLyrics(FolkloreTrack track) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(track.description, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              const Divider(height: 24),
              Text(track.lyricsOrText, style: const TextStyle(fontSize: 16, height: 1.5)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = widget.paywall.isUnlocked(CulturalModule.folklore);

    return Scaffold(
      body: ListView(
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
                        Text('Oral Folklore, Lullabies & Rasdhar Narrations', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final track in CulturalRepository.folkloreTracks) ...[
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
                            ? Icons.stop_circle
                            : Icons.play_circle_fill,
                        size: 36,
                        color: !accessible ? Colors.grey : theme.colorScheme.primary,
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
                    title: Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${track.category} · ${track.duration}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(track.description, maxLines: 2, overflow: TextOverflow.ellipsis),
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
    );
  }
}
