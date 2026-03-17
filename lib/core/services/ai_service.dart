class AIService {
  Future<Map<String, dynamic>> analyzeResume({
    required Map<String, dynamic> resumeData,
  }) async {
    // Local, heuristic ATS scoring – no external API calls.
    // Expected input (from resume editor):
    //   {
    //     'firstName': String,
    //     'skills': List<String>,
    //     'experience': int (number of roles)
    //   }

    final firstName = (resumeData['firstName'] ?? '').toString();
    final skills =
        (resumeData['skills'] as List?)
            ?.whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .map((s) => s.trim())
            .toList() ??
        <String>[];
    final experienceCount = (resumeData['experience'] as num?)?.toInt() ?? 0;

    int scoreSkills(int count) {
      if (count >= 10) return 90;
      if (count >= 6) return 75;
      if (count >= 3) return 60;
      if (count >= 1) return 45;
      return 30;
    }

    int scoreExperience(int roles) {
      if (roles >= 4) return 90;
      if (roles >= 2) return 75;
      if (roles >= 1) return 60;
      return 40;
    }

    int scoreKeywordMatch(List<String> userSkills) {
      const coreKeywords = <String>{
        'communication',
        'teamwork',
        'leadership',
        'problem solving',
        'project management',
        'sql',
        'python',
        'java',
        'flutter',
        'dart',
        'react',
        'aws',
        'docker',
      };

      if (userSkills.isEmpty) return 30;

      final lowerSkills = userSkills.map((s) => s.toLowerCase()).toList();
      final matched = coreKeywords
          .where((kw) => lowerSkills.any((s) => s.contains(kw)))
          .length;
      final coverage = matched / coreKeywords.length;

      if (coverage >= 0.7) return 90;
      if (coverage >= 0.4) return 75;
      if (coverage >= 0.2) return 60;
      return 45;
    }

    int scoreFormatting(List<String> userSkills, int roles) {
      // Rough proxy: having both skills and experience suggests basic structure.
      if (userSkills.length >= 6 && roles >= 2) return 85;
      if (userSkills.length >= 3 && roles >= 1) return 75;
      if (userSkills.isNotEmpty) return 65;
      return 55;
    }

    int scoreGrammar(String name, List<String> userSkills) {
      // Very naive: presence of basic fields -> assume acceptable grammar.
      final hasName = name.trim().isNotEmpty;
      final hasSkillsText = userSkills.isNotEmpty;
      if (hasName && hasSkillsText) return 80;
      if (hasName || hasSkillsText) return 70;
      return 60;
    }

    final skillsScore = scoreSkills(skills.length);
    final experienceScore = scoreExperience(experienceCount);
    final keywordScore = scoreKeywordMatch(skills);
    final formattingScore = scoreFormatting(skills, experienceCount);
    final grammarScore = scoreGrammar(firstName, skills);

    final overallScore =
        ((skillsScore +
                    experienceScore +
                    keywordScore +
                    formattingScore +
                    grammarScore) /
                5)
            .round();

    // Matched keywords: treat each skill as a matched keyword.
    final matchedKeywords = skills
        .map((s) => {'keyword': s, 'count': 1, 'weight': 'medium'})
        .toList();

    // Missing keywords: suggest a few common ones that are not present.
    const recommendedTechnical = <String>{
      'git',
      'rest api',
      'unit testing',
      'oop',
      'clean architecture',
    };
    const recommendedSoft = <String>{'communication', 'teamwork', 'leadership'};

    final lowerSkills = skills.map((s) => s.toLowerCase()).toList();
    final missingKeywords = <Map<String, dynamic>>[];

    void addMissing(
      Iterable<String> source,
      String category, {
      String importance = 'medium',
    }) {
      for (final kw in source) {
        if (!lowerSkills.any((s) => s.contains(kw))) {
          missingKeywords.add({
            'keyword': kw,
            'importance': importance,
            'category': category,
          });
        }
      }
    }

    addMissing(recommendedTechnical, 'Technical');
    addMissing(recommendedSoft, 'Soft Skill', importance: 'high');

    // Suggestions based on simple rules.
    final suggestions = <Map<String, dynamic>>[];

    if (skills.length < 5) {
      suggestions.add({
        'title': 'Add more relevant skills',
        'description':
            'Include at least 5–10 hard and soft skills that match your target role.',
        'priority': 'high',
        'category': 'Skills',
      });
    }

    if (experienceCount == 0) {
      suggestions.add({
        'title': 'Add work experience',
        'description':
            'ATS systems expect at least one experience entry. Add internships, projects, or freelance work.',
        'priority': 'high',
        'category': 'Experience',
      });
    } else if (experienceCount < 2) {
      suggestions.add({
        'title': 'Expand experience section',
        'description':
            'Consider adding more roles or breaking down responsibilities with bullet points to highlight impact.',
        'priority': 'medium',
        'category': 'Experience',
      });
    }

    if (keywordScore < 60) {
      suggestions.add({
        'title': 'Improve keyword match',
        'description':
            'Use more role-specific keywords from the job description in your skills and experience sections.',
        'priority': 'high',
        'category': 'Keywords',
      });
    }

    if (formattingScore < 70) {
      suggestions.add({
        'title': 'Polish formatting',
        'description':
            'Use clear section headings and consistent bullet points so ATS parsers can easily read your resume.',
        'priority': 'medium',
        'category': 'Formatting',
      });
    }

    if (grammarScore < 75) {
      suggestions.add({
        'title': 'Review grammar and clarity',
        'description':
            'Read your resume aloud or use a spell-check tool to fix typos and awkward phrasing.',
        'priority': 'low',
        'category': 'Grammar',
      });
    }

    return {
      'overallScore': overallScore,
      'scoreBreakdown': {
        'formatting': formattingScore,
        'keywordMatch': keywordScore,
        'skills': skillsScore,
        'experience': experienceScore,
        'grammar': grammarScore,
      },
      'matchedKeywords': matchedKeywords,
      'missingKeywords': missingKeywords,
      'suggestions': suggestions,
      'analyzedAt': DateTime.now().toIso8601String(),
    };
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
