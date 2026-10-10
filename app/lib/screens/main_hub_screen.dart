import 'package:flutter/material.dart';

import '../data/kehvat_repository.dart';
import '../services/daily.dart';
import '../services/favorites_store.dart';
import '../services/paywall_store.dart';
import '../services/settings_store.dart';
import '../services/study_store.dart';
import 'folklore_screen.dart';
import 'language_menu.dart';
import 'library_screen.dart';
import 'lifestyle_screen.dart';
import 'proverbs_screen.dart';
import 'spiritual_screen.dart';

class MainHubScreen extends StatefulWidget {
  const MainHubScreen({
    super.key,
    required this.repository,
    required this.favorites,
    required this.settings,
    required this.study,
    required this.daily,
    required this.paywall,
  });

  final KehvatRepository repository;
  final FavoritesStore favorites;
  final SettingsStore settings;
  final StudyStore study;
  final DailyKehvat daily;
  final PaywallStore paywall;

  @override
  State<MainHubScreen> createState() => _MainHubScreenState();
}

class _MainHubScreenState extends State<MainHubScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.settings, widget.paywall]),
      builder: (context, _) {
        final language = widget.settings.language;

        final tabTitles = switch (language) {
          'hi' => ['कहावतें', 'लोकसाहित्य', 'तीर्थ दर्शन', 'ग्रंथालय', 'जीवनशैली'],
          'en' => ['Proverbs', 'Folklore', 'Spiritual', 'Library', 'Lifestyle'],
          _ => ['કહેવતો', 'લોકસાહિત્ય', 'તીર્થ દર્શન', 'ગ્રંથાલય', 'જીવનશૈલી'],
        };

        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ગુજરાત ની અસ્મિતા', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Gujarat Ni Asmita: Heritage Hub', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            actions: [
              LanguageMenu(settings: widget.settings),
            ],
          ),
          body: IndexedStack(
            index: _selectedTabIndex,
            children: [
              ProverbsScreen(
                repository: widget.repository,
                favorites: widget.favorites,
                settings: widget.settings,
                study: widget.study,
                daily: widget.daily,
              ),
              FolkloreScreen(paywall: widget.paywall),
              SpiritualScreen(paywall: widget.paywall),
              LibraryScreen(paywall: widget.paywall),
              LifestyleScreen(paywall: widget.paywall),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedTabIndex,
            onDestinationSelected: (index) => setState(() => _selectedTabIndex = index),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline),
                selectedIcon: const Icon(Icons.chat_bubble),
                label: tabTitles[0],
              ),
              NavigationDestination(
                icon: const Icon(Icons.headphones_outlined),
                selectedIcon: const Icon(Icons.headphones),
                label: tabTitles[1],
              ),
              NavigationDestination(
                icon: const Icon(Icons.place_outlined),
                selectedIcon: const Icon(Icons.place),
                label: tabTitles[2],
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: tabTitles[3],
              ),
              NavigationDestination(
                icon: const Icon(Icons.restaurant_outlined),
                selectedIcon: const Icon(Icons.restaurant),
                label: tabTitles[4],
              ),
            ],
          ),
        );
      },
    );
  }
}
