import 'package:flutter/material.dart';

import '../data/cultural_repository.dart';
import '../models/cultural_models.dart';
import '../services/paywall_store.dart';
import 'paywall_dialog.dart';

class SpiritualScreen extends StatelessWidget {
  const SpiritualScreen({super.key, required this.paywall});

  final PaywallStore paywall;

  void _showSiteDetails(BuildContext context, SpiritualSite site) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(site.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(site.location, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(site.history, style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 12),
              const Text('મુખ્ય તથ્યો (Key Facts):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              for (final fact in site.keyFacts) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $fact', style: const TextStyle(fontSize: 13)),
                ),
              ],
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
    final isUnlocked = paywall.isUnlocked(CulturalModule.spiritual);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFE0F2F1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.place, size: 36, color: Color(0xFF00796B)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('તીર્થ દર્શન અને યાત્રા મેપ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF004D40))),
                        Text('Sacred Heritage Sites & Audio Walking Tours', style: TextStyle(fontSize: 13, color: Color(0xFF00796B))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final site in CulturalRepository.spiritualSites) ...[
            Builder(
              builder: (context) {
                final accessible = site.isSampleFree || isUnlocked;

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
                            Expanded(child: Text(site.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
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
                        Text('${site.location} · ${site.duration}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(site.significance, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FilledButton.tonalIcon(
                              icon: const Icon(Icons.volume_up, size: 18),
                              label: Text(accessible ? 'Audio Guide' : 'Unlock Guide'),
                              onPressed: () {
                                if (accessible) {
                                  _showSiteDetails(context, site);
                                } else {
                                  PaywallDialog.show(context, CulturalModule.spiritual, paywall);
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
