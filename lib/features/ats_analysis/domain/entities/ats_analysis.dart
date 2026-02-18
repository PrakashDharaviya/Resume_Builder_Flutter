// ATS Analysis Entity
class ATSAnalysis {
  final String id;
  final String resumeId;
  final int overallScore;
  final Map<String, int> scoreBreakdown;
  final List<KeywordMatch> matchedKeywords;
  final List<MissingKeyword> missingKeywords;
  final List<Suggestion> suggestions;
  final DateTime analyzedAt;

  const ATSAnalysis({
    required this.id,
    required this.resumeId,
    required this.overallScore,
    required this.scoreBreakdown,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.suggestions,
    required this.analyzedAt,
  });
}

class KeywordMatch {
  final String keyword;
  final int count;
  final String weight;

  const KeywordMatch({
    required this.keyword,
    required this.count,
    required this.weight,
  });
}

class MissingKeyword {
  final String keyword;
  final String importance;
  final String category;

  const MissingKeyword({
    required this.keyword,
    required this.importance,
    required this.category,
  });
}

class Suggestion {
  final String title;
  final String description;
  final String priority;
  final String category;

  const Suggestion({
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
  });
}
