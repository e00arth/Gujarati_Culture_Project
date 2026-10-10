import 'package:flutter/material.dart';

import '../data/cultural_repository.dart';
import '../models/cultural_models.dart';
import '../services/paywall_store.dart';
import 'paywall_dialog.dart';

class SpiritualScreen extends StatefulWidget {
  const SpiritualScreen({super.key, required this.paywall});

  final PaywallStore paywall;

  @override
  State<SpiritualScreen> createState() => _SpiritualScreenState();
}

class _SpiritualScreenState extends State<SpiritualScreen> {
  String _selectedCategory = 'બધા';

  void _showSiteDetails(BuildContext context, SpiritualSite site) {
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
                  Expanded(
                    child: Text(site.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(site.category, style: const TextStyle(fontSize: 11, color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('${site.location} · ${site.duration}', style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              Card(
                color: const Color(0xFFF1F8E9),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.headphones, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Audio Tour Active (ઓડિયો માર્ગદર્શિકા)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(site.duration, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('મહત્વ અને આધ્યાત્મિક દર્શન (Significance):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(site.significance, style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 14),
              const Text('ઈતિહાસ (Historical Background):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(site.history, style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 14),
              const Text('મુખ્ય તથ્યો (Key Facts):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              for (final fact in site.keyFacts) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold, fontSize: 16)),
                      Expanded(child: Text(fact, style: const TextStyle(fontSize: 13, height: 1.3))),
                    ],
                  ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = widget.paywall.isUnlocked(CulturalModule.spiritual);

    final categories = ['બધા', 'જ્યોતિર્લિંગ', 'ચાર ધામ', 'જૈન મહાતીર્થ', 'પવિત્ર પર્વત', 'શક્તિપીઠ', 'સ્થાપત્ય વારસો'];

    final filteredSites = _selectedCategory == 'બધા'
        ? CulturalRepository.spiritualSites
        : CulturalRepository.spiritualSites.where((s) => s.category.contains(_selectedCategory)).toList();

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
                        Text('Sacred Heritage Sites & Audio Walking Tours', style: TextStyle(fontSize: 12, color: Color(0xFF00796B))),
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
          for (final site in filteredSites) ...[
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
                            Expanded(child: Text(site.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(site.category, style: const TextStyle(fontSize: 10, color: Color(0xFF004D40), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${site.location} · ${site.duration}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(site.significance, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!accessible)
                              Row(
                                children: [
                                  Icon(Icons.lock, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text('LOCKED PREVIEW', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                                ],
                              )
                            else
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text('TOUR READY', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            FilledButton.tonalIcon(
                              icon: Icon(accessible ? Icons.volume_up : Icons.lock_open, size: 18),
                              label: Text(accessible ? 'Open Tour' : 'Unlock Guide'),
                              onPressed: () {
                                if (accessible) {
                                  _showSiteDetails(context, site);
                                } else {
                                  PaywallDialog.show(context, CulturalModule.spiritual, widget.paywall);
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
