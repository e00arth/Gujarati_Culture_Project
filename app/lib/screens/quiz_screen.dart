import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/quiz.dart';
import '../data/strings.dart';
import '../models/kehvat.dart';
import '../services/settings_store.dart';

/// A round of multiple-choice questions: finish the kehvat, or pick the
/// kehvat that a meaning belongs to.
class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.deck,
    required this.settings,
    Random? random,
  }) : _random = random; // ignore: prefer_initializing_formals

  final List<Kehvat> deck;
  final SettingsStore settings;
  final Random? _random;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final _random = widget._random ?? Random();
  late List<Question> _questions;
  int _index = 0;
  int _right = 0;

  /// The option picked for the current question, or null before answering.
  int? _picked;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _questions = buildQuiz(widget.deck, widget.settings.language, _random);
    _index = _right = 0;
    _picked = null;
  }

  void _pick(int option) {
    final right = option == _questions[_index].answer;
    right ? HapticFeedback.lightImpact() : HapticFeedback.heavyImpact();
    setState(() {
      _picked = option;
      if (right) _right++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = Strings.of(widget.settings.language);
    final done = _index == _questions.length;
    return Scaffold(
      appBar: AppBar(title: Text(strings.quiz)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: done
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.rightOf(_right, _questions.length),
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => setState(_start),
                      child: Text(strings.playAgain),
                    ),
                  ],
                ),
              )
            : _question(context, _questions[_index], strings),
      ),
    );
  }

  Widget _question(BuildContext context, Question question, Strings strings) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: _index / _questions.length),
        const SizedBox(height: 16),
        Text(
          question.byMeaning ? strings.whichKehvat : strings.completeIt,
          style: theme.textTheme.titleSmall?.copyWith(color: scheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          question.byMeaning ? question.prompt : '${question.prompt} …',
          style: question.byMeaning
              ? theme.textTheme.titleLarge
              : theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              for (final (i, option) in question.options.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      // Once answered, the right option is marked, and the
                      // one picked if it was wrong.
                      backgroundColor: _picked == null
                          ? null
                          : i == question.answer
                          ? Colors.green.shade100
                          : i == _picked
                          ? scheme.errorContainer
                          : null,
                      foregroundColor: scheme.onSurface,
                    ),
                    onPressed: _picked == null ? () => _pick(i) : () {},
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (_picked != null && i == question.answer)
                          Icon(Icons.check_circle, color: Colors.green.shade800)
                        else if (i == _picked)
                          Icon(Icons.cancel, color: scheme.error),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_picked != null)
          FilledButton(
            onPressed: () => setState(() {
              _index++;
              _picked = null;
            }),
            child: Text(strings.next),
          ),
      ],
    );
  }
}
