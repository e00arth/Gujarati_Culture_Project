import 'dart:math';

import '../models/kehvat.dart';

/// One multiple-choice question about a kehvat.
class Question {
  const Question({
    required this.kehvat,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.byMeaning,
  });

  final Kehvat kehvat;

  /// The first half of the kehvat, or its meaning when [byMeaning].
  final String prompt;
  final List<String> options;

  /// The index in [options] of the right one.
  final int answer;

  /// True when the question gives a meaning and asks for the kehvat, false
  /// when it gives the first half and asks for the rest.
  final bool byMeaning;
}

/// A quiz of [count] questions drawn from [deck]. Half ask which kehvat a
/// meaning (in [language]) belongs to, as far as kehvto with meanings go; the
/// rest ask for the second half of a kehvat.
List<Question> buildQuiz(
  List<Kehvat> deck,
  String language,
  Random random, {
  int count = 10,
}) {
  const choices = 4;
  final shuffled = [...deck]..shuffle(random);
  final full = shuffled.where((k) => k.hasMeaning).toList();

  Question ask(
    Kehvat kehvat,
    String prompt,
    String right,
    Iterable<String> wrong,
  ) {
    final options = [
      right,
      ...wrong.where((o) => o != right).toSet().take(choices - 1),
    ]..shuffle(random);
    return Question(
      kehvat: kehvat,
      prompt: prompt,
      options: options,
      answer: options.indexOf(right),
      byMeaning: prompt != kehvat.halves!.$1,
    );
  }

  final byMeaning = full.length >= choices
      ? full.take(count ~/ 2).toList()
      : <Kehvat>[];
  final byHalf = shuffled
      .where((k) => !byMeaning.contains(k))
      .take(count - byMeaning.length);
  return [
    for (final k in byMeaning)
      ask(
        k,
        k.meaning[language]![MeaningLevel.simple]!,
        k.text,
        (full.where((o) => o != k).toList()..shuffle(random)).map(
          (o) => o.text,
        ),
      ),
    for (final k in byHalf)
      ask(k, k.halves!.$1, k.halves!.$2, () {
        // Wrong endings of about the same length, so length gives no hint.
        final words = k.halves!.$2.split(' ').length;
        final others = [
          for (final o in shuffled.take(400))
            if (o != k) o.halves!.$2,
        ]..shuffle(random);
        return [
          ...others.where((o) => (o.split(' ').length - words).abs() <= 1),
          ...others,
        ];
      }()),
  ]..shuffle(random);
}
