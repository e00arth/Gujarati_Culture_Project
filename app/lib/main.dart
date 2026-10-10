import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/kehvat_repository.dart';
import 'screens/detail_screen.dart';
import 'screens/main_hub_screen.dart';
import 'services/daily.dart';
import 'services/favorites_store.dart';
import 'services/local_reminders.dart';
import 'services/paywall_store.dart';
import 'services/settings_store.dart';
import 'services/study_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repository = await KehvatRepository.load();
  final settings = SettingsStore(prefs);
  final reminders = LocalReminders();
  final paywall = PaywallStore(prefs);
  final favorites = FavoritesStore(prefs);
  final study = StudyStore(prefs);
  final daily = DailyKehvat(
    DailyStore(prefs),
    settings,
    reminders,
    repository.kehvto,
  );

  final app = GujaratHeritageApp(
    repository: repository,
    favorites: favorites,
    settings: settings,
    study: study,
    daily: daily,
    paywall: paywall,
  );

  runApp(app);
  await reminders.start(app.open);
  await app.daily.refresh();
}

class GujaratHeritageApp extends StatelessWidget {
  GujaratHeritageApp({
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
  final _navigator = GlobalKey<NavigatorState>();

  /// Shows the kehvat with this id, as when its notification is tapped.
  void open(String id) {
    final kehvat = repository.kehvto.where((k) => k.id == id).firstOrNull;
    if (kehvat == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigator.currentState?.push(
        MaterialPageRoute(
          builder: (_) => DetailScreen(
            kehvat: kehvat,
            categories: repository.categories,
            favorites: favorites,
            settings: settings,
          ),
        ),
      );
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gujarat Ni Asmita',
      navigatorKey: _navigator,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD9531E)),
      ),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(media.textScaler.scale(1) * 1.05),
          ),
          child: child!,
        );
      },
      home: MainHubScreen(
        repository: repository,
        favorites: favorites,
        settings: settings,
        study: study,
        daily: daily,
        paywall: paywall,
      ),
    );
  }
}
