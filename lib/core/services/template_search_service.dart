import 'package:flutter/foundation.dart';
import 'package:resumebuilder/core/services/groq_ai_service.dart';
import 'package:resumebuilder/core/services/mock_database_service.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';

/// Combined search service that uses Firestore tags + Groq AI
/// to find and recommend templates based on degree/profession.
class TemplateSearchService {
  final GroqAIService groqAIService;

  TemplateSearchService({required this.groqAIService});

  /// Searches templates by matching query against tags, category,
  /// targetProfession, and template name. Returns filtered + sorted results.
  Future<List<ResumeTemplate>> searchTemplates(String query) async {
    final allTemplates = await MockDatabaseService.instance.getTemplates();
    final activeTemplates = allTemplates.where((t) => t.isActive).toList();

    if (query.trim().isEmpty) return activeTemplates;

    final queryLower = query.trim().toLowerCase();
    final queryWords = queryLower.split(RegExp(r'\s+'));

    // Score each template based on how well it matches
    final scored = <_ScoredTemplate>[];
    for (final template in activeTemplates) {
      int score = 0;

      // Check tags (highest weight)
      for (final tag in template.tags) {
        final tagLower = tag.toLowerCase();
        if (tagLower == queryLower) {
          score += 10; // exact match
        } else if (tagLower.contains(queryLower) ||
            queryLower.contains(tagLower)) {
          score += 5;
        } else {
          for (final word in queryWords) {
            if (tagLower.contains(word) || word.contains(tagLower)) {
              score += 3;
            }
          }
        }
      }

      // Check category
      final catLower = template.category.toLowerCase();
      if (catLower.contains(queryLower) || queryLower.contains(catLower)) {
        score += 6;
      }

      // Check target profession
      final profLower = template.targetProfession.toLowerCase();
      if (profLower.contains(queryLower) || queryLower.contains(profLower)) {
        score += 8;
      } else {
        for (final word in queryWords) {
          if (profLower.contains(word)) score += 3;
        }
      }

      // Check template name
      final nameLower = template.name.toLowerCase();
      if (nameLower.contains(queryLower)) {
        score += 4;
      }

      // Check template type
      if (template.templateType.toLowerCase().contains(queryLower)) {
        score += 2;
      }

      if (score > 0) {
        scored.add(_ScoredTemplate(template: template, score: score));
      }
    }

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((s) => s.template).toList();
  }

  /// Gets AI-powered recommendations for a search query.
  /// Returns skills, summary, and recommended template type.
  Future<SearchRecommendation?> getAIRecommendation(String query) async {
    if (query.trim().isEmpty) return null;

    try {
      final result = await groqAIService.searchRecommendation(query: query);
      return SearchRecommendation.fromJson(result);
    } catch (e) {
      debugPrint('AI recommendation failed: $e');
      return null;
    }
  }

  /// Auto-generates tags for a template using Gemini AI.
  /// Called when admin saves a new template.
  Future<TemplateTagResult?> generateTags({
    required String templateName,
    required String templateType,
  }) async {
    try {
      final result = await groqAIService.generateTemplateTags(
        templateName: templateName,
        templateType: templateType,
      );
      return TemplateTagResult.fromJson(result);
    } catch (e) {
      debugPrint('Tag generation failed: $e');
      return null;
    }
  }
}

class _ScoredTemplate {
  final ResumeTemplate template;
  final int score;

  const _ScoredTemplate({required this.template, required this.score});
}

/// AI-generated search recommendation result
class SearchRecommendation {
  final String recommendedTemplateType;
  final String recommendedCategory;
  final List<String> relevantTags;
  final List<String> suggestedSkills;
  final String suggestedSummary;
  final String fieldDescription;

  const SearchRecommendation({
    required this.recommendedTemplateType,
    required this.recommendedCategory,
    required this.relevantTags,
    required this.suggestedSkills,
    required this.suggestedSummary,
    required this.fieldDescription,
  });

  factory SearchRecommendation.fromJson(Map<String, dynamic> json) {
    return SearchRecommendation(
      recommendedTemplateType:
          (json['recommendedTemplateType'] as String?) ?? 'professional',
      recommendedCategory:
          (json['recommendedCategory'] as String?) ?? 'general',
      relevantTags:
          (json['relevantTags'] as List?)?.cast<String>() ?? const [],
      suggestedSkills:
          (json['suggestedSkills'] as List?)?.cast<String>() ?? const [],
      suggestedSummary: (json['suggestedSummary'] as String?) ?? '',
      fieldDescription: (json['fieldDescription'] as String?) ?? '',
    );
  }
}

/// AI-generated template tag result
class TemplateTagResult {
  final List<String> tags;
  final String category;
  final String targetProfession;

  const TemplateTagResult({
    required this.tags,
    required this.category,
    required this.targetProfession,
  });

  factory TemplateTagResult.fromJson(Map<String, dynamic> json) {
    return TemplateTagResult(
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      category: (json['category'] as String?) ?? 'general',
      targetProfession: (json['targetProfession'] as String?) ?? '',
    );
  }
}
