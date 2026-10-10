import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kehvat.dart';

/// Remembers the reading language and the detail-screen section between launches.
class SettingsStore extends ChangeNotifier {
  SettingsStore(this._prefs)
    : _language = languageLabels.containsKey(_prefs.getString(_languageKey))
          ? _prefs.getString(_languageKey)!
          : 'gu',
      _section =
          Section.values.asNameMap()[_prefs.getString(_sectionKey)] ??
          Section.simple;

  static const _languageKey = 'language';
  static const _sectionKey = 'section';
  final SharedPreferences _prefs;
  String _language;
  Section _section;

  /// The language meanings and stories are read in.
  String get language => _language;

  set language(String value) {
    if (value == _language) return;
    _language = value;
    _prefs.setString(_languageKey, value);
    notifyListeners();
  }

  Section get section => _section;

  set section(Section value) {
    if (value == _section) return;
    _section = value;
    _prefs.setString(_sectionKey, value.name);
    notifyListeners();
  }
}
