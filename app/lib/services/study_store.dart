import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kehvat.dart';

/// Where each kehvat stands in flashcard practice.
///
/// This is a Leitner system: a card starts in box 1 and moves up a box each
/// time it is known, coming back after a longer wait each time. A card that
/// is missed goes back to box 1.
class StudyStore extends ChangeNotifier {
  StudyStore(this._prefs, {this._now = DateTime.now}) {
    final saved = jsonDecode(_prefs.getString(_key) ?? '{}') as Map;
    for (final MapEntry(:key, :value) in saved.entries) {
      _cards[key as String] = (box: value[0] as int, due: value[1] as int);
    }
  }

  static const _key = 'study';

  /// Days until a card in box 1, 2, ... is shown again.
  static const waits = [1, 2, 4, 8, 16];

  /// The box from which a kehvat counts as learned.
  static const learnedBox = 4;

  final SharedPreferences _prefs;
  final DateTime Function() _now;

  /// Box and the day it is next due, by [Kehvat.id].
  final Map<String, ({int box, int due})> _cards = {};

  /// Today as a day number, in the reader's own time zone.
  int get _today {
    final now = _now();
    return DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  /// How many kehvto have reached [learnedBox].
  int get learned => _cards.values.where((c) => c.box >= learnedBox).length;

  /// The box [id] is in, or 0 if it has never been shown.
  int boxOf(String id) => _cards[id]?.box ?? 0;

  void answer(String id, {required bool knew}) {
    final box = knew ? (boxOf(id) + 1).clamp(1, waits.length) : 1;
    _cards[id] = (box: box, due: _today + waits[box - 1]);
    _prefs.setString(
      _key,
      jsonEncode({
        for (final MapEntry(:key, :value) in _cards.entries)
          key: [value.box, value.due],
      }),
    );
    notifyListeners();
  }

  /// The cards for one sitting: those due for review, longest overdue first,
  /// then up to [fresh] from [deck] that have not been shown yet.
  List<Kehvat> session(List<Kehvat> deck, {int size = 15, int fresh = 10}) {
    final today = _today;
    final due = [
      for (final k in deck)
        if (_cards[k.id] case final card? when card.due <= today) k,
    ]..sort((a, b) => _cards[a.id]!.due.compareTo(_cards[b.id]!.due));
    return [
      ...due,
      ...deck.where((k) => !_cards.containsKey(k.id)).take(fresh),
    ].take(size).toList();
  }
}
