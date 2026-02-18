import 'dart:math';

// Mock AI Service for ATS scoring
// Generates fake but realistic ATS scores and analysis

class AIService {
  final Random _random = Random();

  // Generate mock ATS score
  Future<Map<String, dynamic>> analyzeResume({
    required Map<String, dynamic> resumeData,
  }) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate mock scores
    final overallScore = 65 + _random.nextInt(30); // 65-95
    final formattingScore = 70 + _random.nextInt(30);
    final keywordScore = 60 + _random.nextInt(35);
    final skillScore = 65 + _random.nextInt(30);
    final experienceScore = 70 + _random.nextInt(25);
    final grammarScore = 80 + _random.nextInt(20);

    return {
      'overallScore': overallScore,
      'scoreBreakdown': {
        'formatting': formattingScore,
        'keywordMatch': keywordScore,
        'skills': skillScore,
        'experience': experienceScore,
        'grammar': grammarScore,
      },
      'matchedKeywords': _generateMatchedKeywords(),
      'missingKeywords': _generateMissingKeywords(),
      'suggestions': _generateSuggestions(overallScore),
      'analyzedAt': DateTime.now().toIso8601String(),
    };
  }

  // Generate matched keywords
  List<Map<String, dynamic>> _generateMatchedKeywords() {
    final keywords = [
      {'keyword': 'Flutter', 'count': 8, 'weight': 'high'},
      {'keyword': 'Dart', 'count': 6, 'weight': 'high'},
      {'keyword': 'Mobile Development', 'count': 5, 'weight': 'high'},
      {'keyword': 'UI/UX', 'count': 4, 'weight': 'medium'},
      {'keyword': 'Git', 'count': 3, 'weight': 'medium'},
      {'keyword': 'REST API', 'count': 4, 'weight': 'medium'},
      {'keyword': 'Firebase', 'count': 3, 'weight': 'low'},
      {'keyword': 'Agile', 'count': 2, 'weight': 'low'},
    ];

    return keywords;
  }

  // Generate missing keywords
  List<Map<String, dynamic>> _generateMissingKeywords() {
    final keywords = [
      {
        'keyword': 'State Management',
        'importance': 'high',
        'category': 'Technical',
      },
      {'keyword': 'CI/CD', 'importance': 'high', 'category': 'Technical'},
      {'keyword': 'Testing', 'importance': 'high', 'category': 'Technical'},
      {
        'keyword': 'Team Leadership',
        'importance': 'medium',
        'category': 'Soft Skills',
      },
      {
        'keyword': 'Cloud Services',
        'importance': 'medium',
        'category': 'Technical',
      },
      {
        'keyword': 'Problem Solving',
        'importance': 'medium',
        'category': 'Soft Skills',
      },
      {'keyword': 'Docker', 'importance': 'low', 'category': 'Technical'},
    ];

    return keywords;
  }

  // Generate improvement suggestions
  List<Map<String, dynamic>> _generateSuggestions(int score) {
    final allSuggestions = [
      {
        'title': 'Add More Quantifiable Achievements',
        'description':
            'Include specific metrics and numbers to demonstrate your impact (e.g., "Increased app performance by 40%")',
        'priority': 'high',
        'category': 'Content',
      },
      {
        'title': 'Include State Management Experience',
        'description':
            'Add experience with popular state management solutions like Bloc, Provider, or Riverpod',
        'priority': 'high',
        'category': 'Skills',
      },
      {
        'title': 'Add Testing Experience',
        'description':
            'Mention unit testing, widget testing, and integration testing experience',
        'priority': 'high',
        'category': 'Skills',
      },
      {
        'title': 'Improve Action Verbs',
        'description':
            'Start bullet points with strong action verbs like "Developed", "Implemented", "Optimized"',
        'priority': 'medium',
        'category': 'Writing',
      },
      {
        'title': 'Add CI/CD Experience',
        'description':
            'Include experience with continuous integration and deployment tools',
        'priority': 'medium',
        'category': 'Skills',
      },
      {
        'title': 'Highlight Team Collaboration',
        'description':
            'Emphasize teamwork and collaboration experiences in your descriptions',
        'priority': 'medium',
        'category': 'Content',
      },
      {
        'title': 'Optimize Formatting',
        'description':
            'Ensure consistent spacing, bullet points, and section headers throughout',
        'priority': 'low',
        'category': 'Format',
      },
      {
        'title': 'Add Certifications',
        'description':
            'Include relevant certifications or online courses completed',
        'priority': 'low',
        'category': 'Content',
      },
    ];

    // Return more suggestions for lower scores
    final suggestionCount = score < 70 ? 6 : (score < 85 ? 4 : 3);
    return allSuggestions.take(suggestionCount).toList();
  }

  // Mock keyword extraction from job description
  Future<List<String>> extractKeywordsFromJobDescription(
    String jobDescription,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      'Flutter',
      'Dart',
      'Mobile Development',
      'State Management',
      'REST API',
      'Firebase',
      'Git',
      'Agile',
      'Unit Testing',
      'CI/CD',
    ];
  }

  // Mock resume improvement suggestions
  Future<List<String>> generateImprovementSuggestions(
    Map<String, dynamic> resumeData,
  ) async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      'Add more specific quantifiable achievements',
      'Include keywords from the job description',
      'Improve formatting consistency',
      'Add more technical skills',
      'Enhance project descriptions',
    ];
  }

  // Get score color based on value
  static String getScoreLevel(int score) {
    if (score >= 80) return 'excellent';
    if (score >= 60) return 'good';
    if (score >= 40) return 'average';
    return 'poor';
  }

  // Get score message
  static String getScoreMessage(int score) {
    if (score >= 80) {
      return 'Excellent! Your resume is highly optimized for ATS systems.';
    } else if (score >= 60) {
      return 'Good job! Your resume should pass most ATS systems with some improvements.';
    } else if (score >= 40) {
      return 'Your resume needs improvement to better match ATS requirements.';
    } else {
      return 'Your resume needs significant improvements for ATS optimization.';
    }
  }
}
