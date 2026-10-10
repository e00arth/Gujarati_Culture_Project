import 'package:flutter/material.dart';

import '../data/cultural_repository.dart';
import '../models/cultural_models.dart';
import '../services/paywall_store.dart';

class LifestyleScreen extends StatelessWidget {
  const LifestyleScreen({super.key, required this.paywall});

  final PaywallStore paywall;

  void _showIapConsole(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return ListenableBuilder(
          listenable: paywall,
          builder: (context, _) {
            return AlertDialog(
              title: const Text('In-App Purchase Testing Console', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Toggle module entitlements for simulator testing:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    for (final module in CulturalModule.values) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(module.titleEn, style: const TextStyle(fontSize: 13))),
                            if (module.isFree)
                              const Text('FREE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
                            else
                              Switch(
                                value: paywall.isUnlocked(module),
                                onChanged: (val) {
                                  if (val) {
                                    paywall.unlock(module);
                                  } else {
                                    paywall.lock(module);
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('All-Access Pass:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Switch(
                          value: paywall.isAllAccess,
                          onChanged: (val) {
                            if (val) {
                              paywall.unlockAllAccess();
                            } else {
                              paywall.resetAll();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          paywall.resetAll();
                        },
                        child: const Text('Reset All to Default (Locked)', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFFCE4EC),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, size: 36, color: Color(0xFFD81B60)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('અસ્મિતા જીવનશૈલી અને સંસ્કૃતિ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF880E4F))),
                        Text('Dietary Science, Textiles & Architecture', style: TextStyle(fontSize: 13, color: Color(0xFFAD1457))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Color(0xFF880E4F)),
                    tooltip: 'IAP Test Settings',
                    onPressed: () => _showIapConsole(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final topic in CulturalRepository.lifestyleTopics) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.category, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    Text(topic.subtitle, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(topic.content, style: const TextStyle(fontSize: 14, height: 1.4)),
                    const SizedBox(height: 10),
                    for (final point in topic.bulletPoints) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(point, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Cross-Platform In-App Purchase Testing', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Simulate StoreKit / Google Play Billing states', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: const Text('Open IAP Test Console'),
                    onPressed: () => _showIapConsole(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OutlinedCard extends StatelessWidget {
  const OutlinedCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
