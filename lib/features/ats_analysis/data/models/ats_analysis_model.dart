import 'package:resumebuilder/features/ats_analysis/domain/entities/ats_analysis.dart';

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
    int _intFromDynamic(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    Map<String, int> _parseScoreBreakdown(dynamic raw) {
      final result = <String, int>{};
      if (raw is Map) {
        raw.forEach((key, value) {
          final k = key.toString();
          result[k] = _intFromDynamic(value);
        });
      }
      return result;
    }

    DateTime _parseDate(dynamic value) {
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return DateTime.now();
    }

    return ATSAnalysisModel(
      id:
          (json['id'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      resumeId: (json['resumeId'] as String?) ?? '',
      overallScore: _intFromDynamic(json['overallScore']),
      scoreBreakdown: _parseScoreBreakdown(json['scoreBreakdown']),
      matchedKeywords: (json['matchedKeywords'] as List? ?? const [])
          .where((e) => e is Map)
          .map(
            (e) =>
                KeywordMatchModel.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      missingKeywords: (json['missingKeywords'] as List? ?? const [])
          .where((e) => e is Map)
          .map(
            (e) => MissingKeywordModel.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
      suggestions: (json['suggestions'] as List? ?? const [])
          .where((e) => e is Map)
          .map(
            (e) => SuggestionModel.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      analyzedAt: _parseDate(json['analyzedAt']),
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
    int _intFromDynamic(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    return KeywordMatchModel(
      keyword: (json['keyword'] ?? '').toString(),
      count: _intFromDynamic(json['count']),
      weight: (json['weight'] ?? 'medium').toString(),
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
      keyword: (json['keyword'] ?? '').toString(),
      importance: (json['importance'] ?? 'medium').toString(),
      category: (json['category'] ?? '').toString(),
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
    final dynamic rawTitle = json['title'] ?? json['category'] ?? 'Suggestion';
    final dynamic rawDescription =
        json['description'] ?? json['suggestion'] ?? '';
    final dynamic rawPriority = json['priority'] ?? 'medium';
    final dynamic rawCategory = json['category'] ?? json['title'] ?? 'General';

    return SuggestionModel(
      title: rawTitle?.toString() ?? 'Suggestion',
      description: rawDescription?.toString() ?? '',
      priority: rawPriority?.toString() ?? 'medium',
      category: rawCategory?.toString() ?? 'General',
    );
  }
}
