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
    int intFromDynamic(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    Map<String, int> parseScoreBreakdown(dynamic raw) {
      final result = <String, int>{};
      if (raw is Map) {
        raw.forEach((key, value) {
          final k = key.toString();
          result[k] = intFromDynamic(value);
        });
      }
      return result;
    }

    DateTime parseDate(dynamic value) {
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return DateTime.now();
    }

    List<KeywordMatch> parseMatchedKeywords(dynamic raw) {
      if (raw is! List) return const <KeywordMatch>[];

      final result = <KeywordMatch>[];
      for (final item in raw) {
        if (item is Map) {
          result.add(KeywordMatchModel.fromJson(item.cast<String, dynamic>()));
        } else if (item is String && item.trim().isNotEmpty) {
          result.add(
            KeywordMatchModel(keyword: item.trim(), count: 1, weight: 'medium'),
          );
        }
      }
      return result;
    }

    List<MissingKeyword> parseMissingKeywords(dynamic raw) {
      if (raw is! List) return const <MissingKeyword>[];

      final result = <MissingKeyword>[];
      for (final item in raw) {
        if (item is Map) {
          result.add(
            MissingKeywordModel.fromJson(item.cast<String, dynamic>()),
          );
        } else if (item is String && item.trim().isNotEmpty) {
          result.add(
            MissingKeywordModel(
              keyword: item.trim(),
              importance: 'medium',
              category: 'General',
            ),
          );
        }
      }
      return result;
    }

    List<Suggestion> parseSuggestions(dynamic raw) {
      if (raw is! List) return const <Suggestion>[];

      final result = <Suggestion>[];
      for (final item in raw) {
        if (item is Map) {
          result.add(SuggestionModel.fromJson(item.cast<String, dynamic>()));
        } else if (item is String && item.trim().isNotEmpty) {
          result.add(
            SuggestionModel(
              title: 'Suggestion',
              description: item.trim(),
              priority: 'medium',
              category: 'General',
            ),
          );
        }
      }
      return result;
    }

    return ATSAnalysisModel(
      id:
          (json['id'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      resumeId: (json['resumeId'] as String?) ?? '',
      overallScore: intFromDynamic(json['overallScore']),
      scoreBreakdown: parseScoreBreakdown(json['scoreBreakdown']),
      matchedKeywords: parseMatchedKeywords(json['matchedKeywords']),
      missingKeywords: parseMissingKeywords(json['missingKeywords']),
      suggestions: parseSuggestions(json['suggestions']),
      analyzedAt: parseDate(json['analyzedAt']),
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
    int intFromDynamic(dynamic value, {int fallback = 0}) {
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
      count: intFromDynamic(json['count']),
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
