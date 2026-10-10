/// Language codes, for the language a kehvat is in and the language its
/// meaning and story are read in. Each is labelled in its own script.
const languageLabels = {'gu': 'ગુજરાતી', 'hi': 'हिन्दी', 'en': 'English'};

/// How much detail a meaning goes into.
enum MeaningLevel { simple, normal, advanced }

/// What the detail screen shows for a kehvat: its backstory, its meaning at
/// one level, or its story.
enum Section {
  backstory(null),
  simple(MeaningLevel.simple),
  normal(MeaningLevel.normal),
  advanced(MeaningLevel.advanced),
  story(null);

  const Section(this.level);

  /// The meaning level shown, or null for the backstory and the story.
  final MeaningLevel? level;
}

/// A theme kehvto are grouped under, such as patience or speech.
class Category {
  const Category({required this.id, required this.names});

  final String id;

  /// The category's name, keyed by reading language.
  final Map<String, String> names;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    names: Map<String, String>.from(json['name'] as Map),
  );
}

/// A proverb with its meaning at three depths and a story, in each language.
///
/// A kehvat or idiom listed without a meaning yet has only [text], [roman]
/// and [categories]; see [hasMeaning].
class Kehvat {
  const Kehvat({
    required this.id,
    required this.language,
    required this.text,
    required this.roman,
    required this.categories,
    required this.literal,
    required this.backstory,
    required this.meaning,
    required this.story,
    this.folk = false,
  });

  final String id;

  /// The language the kehvat itself is in.
  final String language;
  final String text;

  /// [text] in Latin letters.
  final String roman;

  /// The [Category.id] of each category this kehvat belongs to.
  final List<String> categories;

  /// Word-for-word translation, keyed by every language except [language].
  final Map<String, String> literal;

  /// The everyday life the kehvat grew out of, keyed by reading language.
  final Map<String, String> backstory;

  /// The meaning, keyed by reading language and then by level.
  final Map<String, Map<MeaningLevel, String>> meaning;

  /// The story behind the kehvat, keyed by reading language.
  final Map<String, String> story;

  /// True when [story] is the traditional tale the kehvat comes from, false
  /// when it is a tale written to show the kehvat in use.
  final bool folk;

  factory Kehvat.fromJson(Map<String, dynamic> json) => Kehvat(
    id: json['id'] as String,
    language: json['lang'] as String,
    text: json['text'] as String,
    roman: json['roman'] as String,
    categories: List<String>.from(json['categories'] as List),
    literal: Map<String, String>.from(json['literal'] as Map? ?? {}),
    backstory: Map<String, String>.from(json['backstory'] as Map? ?? {}),
    meaning: (json['meaning'] as Map? ?? {}).map(
      (lang, levels) => MapEntry(lang as String, {
        for (final level in MeaningLevel.values)
          level: (levels as Map)[level.name] as String,
      }),
    ),
    story: Map<String, String>.from(json['story'] as Map? ?? {}),
    folk: json['folk'] as bool? ?? false,
  );

  /// False for an entry that is listed with its wording only.
  bool get hasMeaning => meaning.isNotEmpty;

  /// The kehvat cut in two for a flashcard, near the middle and at its own
  /// pause where it has one. Null when it is too short to cut.
  (String, String)? get halves {
    final words = text.split(' ');
    if (words.length < 3) return null;
    const joiners = {'ને', 'અને', 'તો', 'તે', 'પણ', 'કે'};
    final pauses = [
      for (var i = 1; i < words.length; i++)
        if (RegExp(r'[,;?]$').hasMatch(words[i - 1])) i,
    ];
    final joins = [
      for (var i = 1; i < words.length - 1; i++)
        if (joiners.contains(words[i])) i,
    ];
    final cuts = pauses.isNotEmpty ? pauses : joins;
    final middle = words.length / 2;
    final cut = cuts.isEmpty
        ? (words.length + 1) ~/ 2
        : cuts.reduce(
            (a, b) => (a - middle).abs() <= (b - middle).abs() ? a : b,
          );
    return (words.take(cut).join(' '), words.skip(cut).join(' '));
  }

  /// The kehvat put into Hindi, or null when it is a Hindi kehvat already.
  String? get hindi => literal['hi'];

  /// What [section] says in the reading [language].
  String read(String language, Section section) => switch (section) {
    Section.backstory => backstory[language]!,
    Section.story => story[language]!,
    _ => meaning[language]![section.level]!,
  };

  bool matches({String? language, String? category, String query = ''}) {
    if (language != null && this.language != language) return false;
    if (category != null && !categories.contains(category)) return false;
    final q = query.trim().toLowerCase();
    return q.isEmpty ||
        text.contains(q) ||
        roman.toLowerCase().contains(q) ||
        literal.values.any((t) => t.toLowerCase().contains(q)) ||
        meaning.values.any(
          (levels) => levels.values.any((t) => t.toLowerCase().contains(q)),
        );
  }
}
