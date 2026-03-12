import 'dart:convert';
import 'package:http/http.dart' as http;

// Replace with your actual Gemini API key
const String _geminiApiKey = 'AIzaSyCw1Sz5MjUzbX5umEtwYBKyCf-xuq52Rsc';
const String _geminiEndpoint =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

class AIService {
  Future<Map<String, dynamic>> analyzeResume({
    required Map<String, dynamic> resumeData,
  }) async {
    final prompt =
        '''
Analyze this resume for ATS (Applicant Tracking System) compatibility. Return a JSON object with these exact keys:
- overallScore (integer 0-100)
- scoreBreakdown: {formatting: int, keywordMatch: int, skills: int, experience: int, grammar: int}
- matchedKeywords: list of {keyword: string, count: int, weight: string (high/medium/low)}
- missingKeywords: list of {keyword: string, importance: string}
- suggestions: list of {category: string, suggestion: string, priority: string}
- analyzedAt: ISO date string

Resume data: ${jsonEncode(resumeData)}

Return ONLY valid JSON, no markdown, no explanation.''';

    try {
      final uri = Uri.parse('$_geminiEndpoint?key=$_geminiApiKey');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 2048},
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final text =
            body['candidates'][0]['content']['parts'][0]['text'] as String;
        final jsonStr = _extractJson(text);
        final result = jsonDecode(jsonStr) as Map<String, dynamic>;
        return result;
      } else {
        return _fallbackError(
          'Gemini API returned status ${response.statusCode}',
        );
      }
    } catch (e) {
      return _fallbackError(e.toString());
    }
  }

  /// Extracts a JSON object from text that may contain markdown fences.
  String _extractJson(String text) {
    var cleaned = text.trim();
    // Strip ```json ... ``` or ``` ... ```
    final fencePattern = RegExp(r'^```(?:json)?\s*', multiLine: true);
    cleaned = cleaned.replaceAll(fencePattern, '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*$', multiLine: true), '');
    return cleaned.trim();
  }

  Map<String, dynamic> _fallbackError(String error) {
    return {
      'overallScore': 0,
      'scoreBreakdown': {
        'formatting': 0,
        'keywordMatch': 0,
        'skills': 0,
        'experience': 0,
        'grammar': 0,
      },
      'matchedKeywords': <Map<String, dynamic>>[],
      'missingKeywords': <Map<String, dynamic>>[],
      'suggestions': [
        {
          'category': 'Error',
          'suggestion': 'ATS analysis failed: $error',
          'priority': 'high',
        },
      ],
      'analyzedAt': DateTime.now().toIso8601String(),
      'error': error,
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
