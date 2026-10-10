import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gujarat_heritage_hub/models/cultural_models.dart';
import 'package:gujarat_heritage_hub/services/paywall_store.dart';
import 'package:gujarat_heritage_hub/data/strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cultural Modules & Paywall Tests', () {
    test('Proverbs module is free by default', () {
      expect(CulturalModule.proverbs.isFree, isTrue);
      expect(CulturalModule.folklore.isFree, isFalse);
      expect(CulturalModule.spiritual.isFree, isFalse);
      expect(CulturalModule.library.isFree, isFalse);
      expect(CulturalModule.lifestyle.isFree, isFalse);
    });

    test('PaywallStore locks paid modules by default', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final paywall = PaywallStore(prefs);

      expect(paywall.isUnlocked(CulturalModule.proverbs), isTrue);
      expect(paywall.isUnlocked(CulturalModule.folklore), isFalse);
      expect(paywall.isUnlocked(CulturalModule.spiritual), isFalse);
      expect(paywall.isUnlocked(CulturalModule.library), isFalse);
      expect(paywall.isUnlocked(CulturalModule.lifestyle), isFalse);
      expect(paywall.isAllAccess, isFalse);
    });

    test('PaywallStore unlocks individual module', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final paywall = PaywallStore(prefs);

      await paywall.unlock(CulturalModule.folklore);
      expect(paywall.isUnlocked(CulturalModule.folklore), isTrue);
      expect(paywall.isUnlocked(CulturalModule.spiritual), isFalse);
    });

    test('PaywallStore all-access pass unlocks all modules', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final paywall = PaywallStore(prefs);

      await paywall.unlockAllAccess();
      expect(paywall.isAllAccess, isTrue);
      for (final module in CulturalModule.values) {
        expect(paywall.isUnlocked(module), isTrue);
      }
    });

    test('PaywallStore reset restores locked state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final paywall = PaywallStore(prefs);

      await paywall.unlockAllAccess();
      await paywall.resetAll();
      expect(paywall.isAllAccess, isFalse);
      expect(paywall.isUnlocked(CulturalModule.folklore), isFalse);
      expect(paywall.isUnlocked(CulturalModule.proverbs), isTrue);
    });
  });

  group('Strings Localization Tests', () {
    test('Supports gu, hi, en with fallback', () {
      final gu = Strings.of('gu');
      final hi = Strings.of('hi');
      final en = Strings.of('en');

      expect(gu.title, equals('કહેવતો'));
      expect(gu.search, equals('કહેવત કે અર્થ શોધો'));
      expect(hi.title, equals('कहावतें'));
      expect(en.title, equals('Kehvto'));
    });
  });
}
