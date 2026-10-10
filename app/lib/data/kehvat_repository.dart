import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/kehvat.dart';

class KehvatRepository {
  KehvatRepository(List<Kehvat> kehvto, {this.categories = const []})
    : kehvto = List.of(kehvto)
        ..sort(
          (a, b) => a.hasMeaning != b.hasMeaning
              ? (a.hasMeaning ? -1 : 1)
              : a.roman.compareTo(b.roman),
        );

  /// Parses the bundled asset, which tool/build_assets.py writes.
  factory KehvatRepository.parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    List<T> list<T>(String key, T Function(Map<String, dynamic>) fromJson) =>
        (json[key] as List)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
    return KehvatRepository(
      list('kehvto', Kehvat.fromJson),
      categories: list('categories', Category.fromJson),
    );
  }

  /// All kehvto, those with a meaning first, each group sorted by its Latin
  /// spelling.
  final List<Kehvat> kehvto;

  /// The categories that have kehvto, in display order.
  final List<Category> categories;

  /// The kehvto that flashcards draw on, in the order new ones come up:
  /// those with a meaning first, then the rest in a fixed shuffle. Idioms and
  /// kehvto too short to cut in two are left out.
  late final List<Kehvat> studyDeck = () {
    final deck = [
      for (final k in kehvto)
        if (k.halves != null && !k.categories.contains('idiom')) k,
    ];
    final full = deck.where((k) => k.hasMeaning).length;
    return [
      ...deck.take(full),
      ...deck.skip(full).toList()..shuffle(Random(7)),
    ];
  }();

  /// The languages that have kehvto, in [languageLabels] order.
  late final List<String> languages = [
    for (final code in languageLabels.keys)
      if (kehvto.any((k) => k.language == code)) code,
  ];

  static Future<KehvatRepository> load() async =>
      KehvatRepository.parse(await rootBundle.loadString('assets/kehvto.json'));

  List<Kehvat> filter({
    String? language,
    String? category,
    String query = '',
  }) => kehvto
      .where(
        (k) => k.matches(language: language, category: category, query: query),
      )
      .toList();
}
