import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore(this._prefs)
    : _ids = (_prefs.getStringList(_key) ?? []).toSet();

  static const _key = 'favorites';
  final SharedPreferences _prefs;
  final Set<String> _ids;

  bool contains(String id) => _ids.contains(id);

  void toggle(String id) {
    if (!_ids.remove(id)) _ids.add(id);
    _prefs.setStringList(_key, _ids.toList());
    notifyListeners();
  }
}
