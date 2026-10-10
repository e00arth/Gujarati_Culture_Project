import 'package:flutter/material.dart';

import '../data/cultural_repository.dart';
import '../models/cultural_models.dart';
import '../services/paywall_store.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key, required this.paywall});

  final PaywallStore paywall;

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  String _selectedCategory = 'બધા';

  void _showDetailedTopic(BuildContext context, LifestyleTopic topic) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(topic.category, style: const TextStyle(fontSize: 11, color: Color(0xFFAD1457), fontWeight: FontWeight.bold)),
                  ),
                  Text(topic.readTime, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text(topic.subtitle, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey)),
              const Divider(height: 24),
              Text(topic.content, style: const TextStyle(fontSize: 15, height: 1.5)),
              const SizedBox(height: 16),
              const Text('મુખ્ય વિશિષ્ટતાઓ (Key Highlights):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              for (final point in topic.bulletPoints) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFFAD1457), fontWeight: FontWeight.bold, fontSize: 16)),
                      Expanded(child: Text(point, style: const TextStyle(fontSize: 13, height: 1.3))),
                    ],
                  ),
                ),
              ],
              if (topic.detailedSection.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('વિગતવાર સાંસ્કૃતિક વિશ્લેષણ (Cultural Analysis):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                SelectableText(
                  topic.detailedSection,
                  style: const TextStyle(fontSize: 14, height: 1.5, fontFamily: 'serif'),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close Guide'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIapConsole(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return ListenableBuilder(
          listenable: widget.paywall,
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
                                value: widget.paywall.isUnlocked(module),
                                onChanged: (val) {
                                  if (val) {
                                    widget.paywall.unlock(module);
                                  } else {
                                    widget.paywall.lock(module);
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
                          value: widget.paywall.isAllAccess,
                          onChanged: (val) {
                            if (val) {
                              widget.paywall.unlockAllAccess();
                            } else {
                              widget.paywall.resetAll();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          widget.paywall.resetAll();
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
    final categories = ['બધા', 'આહાર અને વાનગી', 'આહાર અને આયુર્વેદ', 'કલા અને વસ્ત્રપરંપરા', 'કલા અને હસ્તશિલ્પ', 'સ્થાપત્ય', 'તહેવારો અને ઉત્સવો', 'પુરાતત્વ', 'વારસો', 'લોકનાટ્ય', 'ગ્રામ્ય જીવન'];

    final filteredTopics = _selectedCategory == 'બધા'
        ? CulturalRepository.lifestyleTopics
        : CulturalRepository.lifestyleTopics.where((t) => t.category.contains(_selectedCategory)).toList();

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
                        Text('Dietary Science, Textiles & Architecture', style: TextStyle(fontSize: 12, color: Color(0xFFAD1457))),
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
          for (final topic in filteredTopics) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE4EC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(topic.category, style: const TextStyle(fontSize: 11, color: Color(0xFF880E4F), fontWeight: FontWeight.bold)),
                        ),
                        Text(topic.readTime, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(topic.subtitle, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(topic.content, style: const TextStyle(fontSize: 13, height: 1.4)),
                    const SizedBox(height: 10),
                    for (final point in topic.bulletPoints.take(2)) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(point, style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Read In-Depth Guide'),
                        onPressed: () => _showDetailedTopic(context, topic),
                      ),
                    ),
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
