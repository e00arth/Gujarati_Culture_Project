import '../models/kehvat.dart';

/// The app's own wording in one reading language.
class Strings {
  const Strings({
    required this.title,
    required this.search,
    required this.noMatch,
    required this.favourites,
    required this.allCategories,
    required this.readIn,
    required this.literal,
    required this.folkStory,
    required this.story,
    required this.noMeaningYet,
    required this.study,
    required this.reveal,
    required this.knew,
    required this.again,
    required this.readMore,
    required this.sessionDone,
    required this.nothingDue,
    required this.more,
    required this.knownOf,
    required this.learned,
    required this.quiz,
    required this.completeIt,
    required this.whichKehvat,
    required this.next,
    required this.playAgain,
    required this.rightOf,
    required this.daily,
    required this.dailySend,
    required this.dailyTime,
    required this.dailyBlocked,
    required this.todays,
    required this.sections,
  });

  final String title;
  final String search;
  final String noMatch;
  final String favourites;
  final String allCategories;
  final String readIn;
  final String literal;

  /// Heading for a traditional tale, and for one written as an example.
  final String folkStory;
  final String story;

  /// Shown for an entry listed with its wording only.
  final String noMeaningYet;

  /// Flashcard practice.
  final String study;
  final String reveal;
  final String knew;
  final String again;
  final String readMore;
  final String sessionDone;
  final String nothingDue;
  final String more;

  /// How many of this sitting's cards were known first time.
  final String Function(int known, int total) knownOf;

  /// How many kehvto have been learned in all.
  final String Function(int count) learned;

  /// The quiz.
  final String quiz;
  final String completeIt;
  final String whichKehvat;
  final String next;
  final String playAgain;
  final String Function(int right, int total) rightOf;

  /// The kehvat sent each day as a notification.
  final String daily;
  final String dailySend;
  final String dailyTime;
  final String dailyBlocked;
  final String todays;
  final Map<Section, String> sections;

  static Strings of(String language) => _all[language]!;

  static String _knownGu(int known, int total) => '$total માંથી $known આવડી';
  static String _knownHi(int known, int total) =>
      '$total में से $known आती थीं';
  static String _knownEn(int known, int total) => 'You knew $known of $total';
  static String _rightGu(int right, int total) => '$total માંથી $right સાચા';
  static String _rightHi(int right, int total) => '$total में से $right सही';
  static String _rightEn(int right, int total) => '$right of $total correct';
  static String _learnedGu(int count) => 'કુલ $count કહેવતો પાકી થઈ';
  static String _learnedHi(int count) => 'कुल $count कहावतें पक्की हुईं';
  static String _learnedEn(int count) => '$count kehvto learned in all';

  static const _all = {
    'gu': Strings(
      title: 'કહેવતો',
      search: 'કહેવત કે અર્થ શોધો',
      noMatch: 'કોઈ કહેવત મળી નથી.',
      favourites: 'મનપસંદ',
      allCategories: 'બધા વિષયો',
      readIn: 'વાંચવાની ભાષા',
      literal: 'શબ્દાર્થ',
      folkStory: 'લોકકથા',
      story: 'દૃષ્ટાંત કથા',
      noMeaningYet: 'આનો અર્થ અને કથા હજી ઉમેરવાનાં બાકી છે.',
      study: 'અભ્યાસ',
      reveal: 'બાકીની કહેવત બતાવો',
      knew: 'આવડી',
      again: 'ન આવડી',
      readMore: 'અર્થ અને કથા વાંચો',
      sessionDone: 'આજનો અભ્યાસ પૂરો',
      nothingDue: 'અત્યારે કોઈ કહેવત બાકી નથી',
      more: 'વધુ કહેવતો',
      knownOf: _knownGu,
      learned: _learnedGu,
      quiz: 'કસોટી',
      completeIt: 'કહેવત પૂરી કરો',
      whichKehvat: 'આ અર્થ કઈ કહેવતનો છે?',
      next: 'આગળ',
      playAgain: 'ફરી રમો',
      rightOf: _rightGu,
      daily: 'રોજની કહેવત',
      dailySend: 'રોજ એક કહેવત મોકલો',
      dailyTime: 'સમય',
      dailyBlocked: 'ફોનના સેટિંગમાં આ ઍપની સૂચનાઓ બંધ છે.',
      todays: 'આજની કહેવત',
      sections: {
        Section.backstory: 'પૃષ્ઠભૂમિ',
        Section.simple: 'સરળ',
        Section.normal: 'સામાન્ય',
        Section.advanced: 'ઊંડાણ',
        Section.story: 'કથા',
      },
    ),
    'hi': Strings(
      title: 'कहावतें',
      search: 'कहावत या अर्थ खोजें',
      noMatch: 'कोई कहावत नहीं मिली।',
      favourites: 'पसंदीदा',
      allCategories: 'सभी विषय',
      readIn: 'पढ़ने की भाषा',
      literal: 'शब्दार्थ',
      folkStory: 'लोककथा',
      story: 'दृष्टांत कथा',
      noMeaningYet: 'इसका अर्थ और कथा अभी जोड़ना बाकी है।',
      study: 'अभ्यास',
      reveal: 'बाकी कहावत दिखाएँ',
      knew: 'आती थी',
      again: 'नहीं आती थी',
      readMore: 'अर्थ और कथा पढ़ें',
      sessionDone: 'आज का अभ्यास पूरा',
      nothingDue: 'अभी कोई कहावत बाकी नहीं है',
      more: 'और कहावतें',
      knownOf: _knownHi,
      learned: _learnedHi,
      quiz: 'प्रश्नोत्तरी',
      completeIt: 'कहावत पूरी करें',
      whichKehvat: 'यह अर्थ किस कहावत का है?',
      next: 'आगे',
      playAgain: 'फिर खेलें',
      rightOf: _rightHi,
      daily: 'रोज़ की कहावत',
      dailySend: 'रोज़ एक कहावत भेजें',
      dailyTime: 'समय',
      dailyBlocked: 'फ़ोन की सेटिंग में इस ऐप की सूचनाएँ बंद हैं।',
      todays: 'आज की कहावत',
      sections: {
        Section.backstory: 'पृष्ठभूमि',
        Section.simple: 'सरल',
        Section.normal: 'सामान्य',
        Section.advanced: 'गहन',
        Section.story: 'कथा',
      },
    ),
    'en': Strings(
      title: 'Kehvto',
      search: 'Search kehvto or meanings',
      noMatch: 'No kehvto match.',
      favourites: 'Favourites',
      allCategories: 'All categories',
      readIn: 'Reading language',
      literal: 'Word for word',
      folkStory: 'Folk tale',
      story: 'A story to show it',
      noMeaningYet: 'Its meaning and story have not been added yet.',
      study: 'Practice',
      reveal: 'Show the rest',
      knew: 'I knew it',
      again: 'I did not',
      readMore: 'Read the meaning and story',
      sessionDone: 'Done for now',
      nothingDue: 'No kehvto are due right now',
      more: 'More kehvto',
      knownOf: _knownEn,
      learned: _learnedEn,
      quiz: 'Quiz',
      completeIt: 'Complete the kehvat',
      whichKehvat: 'Which kehvat means this?',
      next: 'Next',
      playAgain: 'Play again',
      rightOf: _rightEn,
      daily: 'Kehvat of the day',
      dailySend: 'Send one kehvat a day',
      dailyTime: 'Time',
      dailyBlocked: 'Notifications are off for this app in the phone settings.',
      todays: "Today's kehvat",
      sections: {
        Section.backstory: 'Backstory',
        Section.simple: 'Simple',
        Section.normal: 'Normal',
        Section.advanced: 'Advanced',
        Section.story: 'Story',
      },
    ),
  };
}
