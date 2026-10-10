import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cultural_models.dart';

class PaywallStore extends ChangeNotifier {
  PaywallStore(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;
  final Map<CulturalModule, bool> _unlocked = {};
  bool _isAllAccess = false;

  bool get isAllAccess => _isAllAccess;

  void _load() {
    _isAllAccess = _prefs.getBool(CulturalModule.bundleAllAccessId) ?? false;
    for (final module in CulturalModule.values) {
      if (module.isFree) {
        _unlocked[module] = true;
      } else {
        _unlocked[module] = _isAllAccess || (_prefs.getBool(module.productId) ?? false);
      }
    }
  }

  bool isUnlocked(CulturalModule module) {
    if (module.isFree || _isAllAccess) return true;
    return _unlocked[module] ?? false;
  }

  Future<void> unlock(CulturalModule module) async {
    _unlocked[module] = true;
    await _prefs.setBool(module.productId, true);
    notifyListeners();
  }

  Future<void> lock(CulturalModule module) async {
    if (module.isFree) return;
    _unlocked[module] = false;
    _isAllAccess = false;
    await _prefs.setBool(module.productId, false);
    await _prefs.setBool(CulturalModule.bundleAllAccessId, false);
    notifyListeners();
  }

  Future<void> unlockAllAccess() async {
    _isAllAccess = true;
    await _prefs.setBool(CulturalModule.bundleAllAccessId, true);
    for (final module in CulturalModule.values) {
      _unlocked[module] = true;
      await _prefs.setBool(module.productId, true);
    }
    notifyListeners();
  }

  Future<void> resetAll() async {
    _isAllAccess = false;
    for (final module in CulturalModule.values) {
      await _prefs.remove(module.productId);
    }
    await _prefs.remove(CulturalModule.bundleAllAccessId);
    _load();
    notifyListeners();
  }
}
