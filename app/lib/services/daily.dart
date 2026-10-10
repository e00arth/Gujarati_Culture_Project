import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/strings.dart';
import '../models/kehvat.dart';
import 'settings_store.dart';

/// Whether the reader wants a kehvat each day, and at what time.
class DailyStore extends ChangeNotifier {
  DailyStore(this._prefs)
    : _on = _prefs.getBool(_onKey) ?? false,
      _minute = _prefs.getInt(_minuteKey) ?? 8 * 60;

  static const _onKey = 'dailyOn';
  static const _minuteKey = 'dailyMinute';
  final SharedPreferences _prefs;
  bool _on;
  int _minute;

  bool get on => _on;

  set on(bool value) {
    if (value == _on) return;
    _on = value;
    _prefs.setBool(_onKey, value);
    notifyListeners();
  }

  /// The time of day it is sent, in minutes after midnight.
  int get minute => _minute;

  set minute(int value) {
    if (value == _minute) return;
    _minute = value;
    _prefs.setInt(_minuteKey, value);
    notifyListeners();
  }
}

/// A notification to show at [when] that opens [kehvat].
typedef Reminder = ({DateTime when, Kehvat kehvat, String title, String body});

/// The phone's own scheduled notifications.
abstract class Reminders {
  /// Asks the reader to allow notifications; false if they are refused.
  Future<bool> allow();

  /// Drops everything scheduled and schedules [reminders] instead.
  Future<void> replace(List<Reminder> reminders);
}

/// The kehvat for each of the next [days] days at [minute] past midnight,
/// starting with the first that is still ahead of [now]. Each calendar day
/// has its own kehvat, so rescheduling never changes what a day shows.
List<(DateTime, Kehvat)> dailyPlan(
  List<Kehvat> pool,
  DateTime now,
  int minute, {
  int days = 30,
}) {
  final order = [...pool]
    ..sort((a, b) => a.id.compareTo(b.id))
    ..shuffle(Random(11));
  final times = [
    for (var d = 0; d <= days; d++)
      DateTime(now.year, now.month, now.day + d, minute ~/ 60, minute % 60),
  ].where((time) => time.isAfter(now)).take(days);
  return [
    for (final time in times)
      (
        time,
        order[DateTime.utc(
              time.year,
              time.month,
              time.day,
            ).millisecondsSinceEpoch ~/
            Duration.millisecondsPerDay %
            order.length],
      ),
  ];
}

/// Keeps the scheduled notifications in step with [store] and the reading
/// language. Only kehvto that have a meaning are sent.
class DailyKehvat {
  DailyKehvat(
    this.store,
    this._settings,
    this._reminders,
    List<Kehvat> kehvto, {
    DateTime Function() now = DateTime.now,
  }) : _now = now, // ignore: prefer_initializing_formals
       _pool = kehvto.where((k) => k.hasMeaning).toList() {
    store.addListener(refresh);
    _settings.addListener(refresh);
  }

  final DailyStore store;
  final SettingsStore _settings;
  final Reminders _reminders;
  final List<Kehvat> _pool;
  final DateTime Function() _now;
  String? _scheduled;

  /// Turns the daily kehvat on, asking for permission first. Returns false,
  /// and leaves it off, if the reader does not allow notifications.
  Future<bool> turnOn() async {
    if (!await _reminders.allow()) return false;
    store.on = true;
    return true;
  }

  /// Schedules the coming days again. Call at launch, so the plan never
  /// runs out while the app keeps being opened.
  Future<void> refresh() async {
    final language = _settings.language;
    final state = '${store.on} ${store.minute} $language';
    if (state == _scheduled && !store.on) return;
    _scheduled = state;
    await _reminders.replace([
      if (store.on && _pool.isNotEmpty)
        for (final (time, kehvat) in dailyPlan(_pool, _now(), store.minute))
          (
            when: time,
            kehvat: kehvat,
            title: Strings.of(language).todays,
            body:
                '${kehvat.text}\n'
                '${kehvat.meaning[language]![MeaningLevel.simple]}',
          ),
    ]);
  }
}
