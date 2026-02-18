import '../../domain/entities/ats_analysis.dart';

class ATSAnalysisModel extends ATSAnalysis {
  const ATSAnalysisModel({
    required super.id,
    required super.resumeId,
    required super.overallScore,
    required super.scoreBreakdown,
    required super.matchedKeywords,
    required super.missingKeywords,
    required super.suggestions,
    required super.analyzedAt,
  });

  factory ATSAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ATSAnalysisModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      resumeId: json['resumeId'] ?? '',
      overallScore: json['overallScore'] as int,
      scoreBreakdown: Map<String, int>.from(json['scoreBreakdown']),
      matchedKeywords: (json['matchedKeywords'] as List)
          .map((e) => KeywordMatchModel.fromJson(e))
          .toList(),
      missingKeywords: (json['missingKeywords'] as List)
          .map((e) => MissingKeywordModel.fromJson(e))
          .toList(),
      suggestions: (json['suggestions'] as List)
          .map((e) => SuggestionModel.fromJson(e))
          .toList(),
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }
}

class KeywordMatchModel extends KeywordMatch {
  const KeywordMatchModel({
    required super.keyword,
    required super.count,
    required super.weight,
  });

  factory KeywordMatchModel.fromJson(Map<String, dynamic> json) {
    return KeywordMatchModel(
      keyword: json['keyword'] as String,
      count: json['count'] as int,
      weight: json['weight'] as String,
    );
  }
}

class MissingKeywordModel extends MissingKeyword {
  const MissingKeywordModel({
    required super.keyword,
    required super.importance,
    required super.category,
  });

  factory MissingKeywordModel.fromJson(Map<String, dynamic> json) {
    return MissingKeywordModel(
      keyword: json['keyword'] as String,
      importance: json['importance'] as String,
      category: json['category'] as String,
    );
  }
}

class SuggestionModel extends Suggestion {
  const SuggestionModel({
    required super.title,
    required super.description,
    required super.priority,
    required super.category,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      category: json['category'] as String,
    );
  }
}
