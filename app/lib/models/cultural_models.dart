enum CulturalModule {
  proverbs('module_proverbs', 'કહેવતો', 'Proverbs & Wisdom', 'Free', true),
  folklore('module_folklore_audio', 'લોકસાહિત્ય', 'Folklore Audio', r'$2.99 / ₹199', false),
  spiritual('module_spiritual_map', 'તીર્થ દર્શન', 'Spiritual Map', r'$2.99 / ₹199', false),
  library('module_digital_library', 'અસ્મિતા ગ્રંથાલય', 'Digital Library', r'$3.99 / ₹299', false),
  lifestyle('module_culture_lifestyle', 'જીવનશૈલી', 'Culture & Lifestyle', r'$2.99 / ₹199', false);

  const CulturalModule(this.productId, this.titleGu, this.titleEn, this.price, this.isFree);

  final String productId;
  final String titleGu;
  final String titleEn;
  final String price;
  final bool isFree;

  static const String bundleAllAccessId = 'bundle_all_access';
  static const String bundlePrice = r'$7.99 / ₹599';
}

class FolkloreTrack {
  const FolkloreTrack({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.description,
    required this.lyricsOrText,
    this.isSampleFree = false,
  });

  final String id;
  final String title;
  final String category;
  final String duration;
  final String description;
  final String lyricsOrText;
  final bool isSampleFree;
}

class SpiritualSite {
  const SpiritualSite({
    required this.id,
    required this.name,
    required this.location,
    required this.duration,
    required this.significance,
    required this.history,
    required this.keyFacts,
    this.isSampleFree = false,
  });

  final String id;
  final String name;
  final String location;
  final String duration;
  final String significance;
  final String history;
  final List<String> keyFacts;
  final bool isSampleFree;
}

class EBook {
  const EBook({
    required this.id,
    required this.titleGu,
    required this.titleEn,
    required this.author,
    required this.summary,
    required this.sampleChapterTitle,
    required this.sampleChapterContent,
    required this.chaptersCount,
    this.isSampleFree = false,
  });

  final String id;
  final String titleGu;
  final String titleEn;
  final String author;
  final String summary;
  final String sampleChapterTitle;
  final String sampleChapterContent;
  final int chaptersCount;
  final bool isSampleFree;
}

class LifestyleTopic {
  const LifestyleTopic({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.bulletPoints,
  });

  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String content;
  final List<String> bulletPoints;
}
