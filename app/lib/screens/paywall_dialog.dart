import 'package:flutter/material.dart';

import '../models/cultural_models.dart';
import '../services/paywall_store.dart';

class PaywallDialog extends StatelessWidget {
  const PaywallDialog({
    super.key,
    required this.module,
    required this.paywall,
  });

  final CulturalModule module;
  final PaywallStore paywall;

  static Future<void> show(BuildContext context, CulturalModule module, PaywallStore paywall) {
    return showDialog<void>(
      context: context,
      builder: (_) => PaywallDialog(module: module, paywall: paywall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final highlights = switch (module) {
      CulturalModule.folklore => [
        'All Halarda (lullabies) & Rasdhar folk audio',
        'Traditional oral dayro couplets & wedding songs',
        'Offline audio playback for iPhone & Android',
      ],
      CulturalModule.spiritual => [
        'Complete Somnath, Dwarka & Girnar audio tours',
        'Interactive temple architecture guides & facts',
        'Sacred pilgrimage maps and stories',
      ],
      CulturalModule.library => [
        'All 7 Cultural Heritage E-Books',
        'In-app e-reader with Gujarati font scaling',
        'Offline reading support across devices',
      ],
      CulturalModule.lifestyle => [
        'Comprehensive Gujarati Ayurvedic nutrition guide',
        'Patan Patola & Bandhani textile traditions',
        'Ancient Stepwell (Vav) engineering and history',
      ],
      _ => ['Full lifetime module access'],
    };

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unlock ${module.titleEn}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get lifetime access to ${module.titleGu} with offline audio, full chapters, and interactive guides.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            for (final h in highlights) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(h, style: theme.textTheme.bodySmall)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Single module purchase
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(module.titleEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Lifetime Single Module', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      ],
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        paywall.unlock(module);
                        Navigator.of(context).pop();
                      },
                      child: Text(module.price),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // All-Access Heritage Pass
            Card(
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text('All-Access Pass', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Unlocks all 5 modules across the entire app forever.', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          paywall.unlockAllAccess();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Unlock All for ${CulturalModule.bundlePrice}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Instant Test Mode button
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.flash_on, size: 16, color: Colors.orange),
                label: const Text('[Test Mode] Instant Unlock for Testing', style: TextStyle(fontSize: 12, color: Colors.orange)),
                onPressed: () {
                  paywall.unlock(module);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
