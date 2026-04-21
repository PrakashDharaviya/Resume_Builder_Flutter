import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:resumebuilder/core/errors/exceptions.dart';

/// Service that calls the Google Gemini REST API to perform
/// AI-powered ATS resume analysis.
class GeminiAIService {
  final String apiKey;
  final http.Client _httpClient;

  /// The Gemini model to use. Defaults to `gemini-2.0-flash`.
  final String model;

  GeminiAIService({
    required this.apiKey,
    http.Client? httpClient,
    this.model = 'gemini-2.0-flash',
  }) : _httpClient = httpClient ?? http.Client();

  // ── Public API ──────────────────────────────────────────────────────────

  /// Sends the resume text and (optional) job description to Gemini and
  /// returns a structured map that is compatible with [ATSAnalysisModel.fromJson].
  ///
  /// Expected keys in [resumeData]:
  ///   `firstName`, `lastName`, `email`, `skills` (`List<String>`),
  ///   `experience` (int), `education` (int), `title`, and optionally
  ///   `jobDescription` (String).
  Future<Map<String, dynamic>> analyzeResume({
    required Map<String, dynamic> resumeData,
  }) async {
    final resumeText = _buildResumeText(resumeData);
    final jobDescription =
        (resumeData['jobDescription'] as String?)?.trim() ?? '';

    final prompt = _buildPrompt(resumeText, jobDescription);

    final responseText = await _callGemini(prompt);
    return _parseResponse(responseText);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Converts the structured resume data map into a human-readable text
  /// representation so the LLM can understand it.
  String _buildResumeText(Map<String, dynamic> data) {
    final explicitResumeText = (data['resumeText'] as String?)?.trim() ?? '';
    if (explicitResumeText.isNotEmpty) {
      return explicitResumeText;
    }

    final buffer = StringBuffer();

    final firstName = (data['firstName'] ?? '').toString();
    final lastName = (data['lastName'] ?? '').toString();
    final email = (data['email'] ?? '').toString();
    final title = (data['title'] ?? '').toString();
    final skills =
        (data['skills'] as List?)?.whereType<String>().toList() ?? <String>[];
    final experienceCount = (data['experience'] as num?)?.toInt() ?? 0;
    final educationCount = (data['education'] as num?)?.toInt() ?? 0;
    final summary = (data['summary'] as String?)?.trim() ?? '';
    final experienceDetails =
        (data['experienceDetails'] as List?)
            ?.whereType<String>()
            .where((e) => e.trim().isNotEmpty)
            .toList() ??
        <String>[];
    final projectDetails =
        (data['projectDetails'] as List?)
            ?.whereType<String>()
            .where((p) => p.trim().isNotEmpty)
            .toList() ??
        <String>[];

    buffer.writeln('Resume Title: $title');
    buffer.writeln('Name: $firstName $lastName');
    buffer.writeln('Email: $email');
    buffer.writeln('Skills: ${skills.join(', ')}');
    buffer.writeln('Number of Experience Entries: $experienceCount');
    buffer.writeln('Number of Education Entries: $educationCount');
    if (summary.isNotEmpty) buffer.writeln('Summary: $summary');
    if (experienceDetails.isNotEmpty) {
      buffer.writeln('Experience Details: ${experienceDetails.join(' | ')}');
    }
    if (projectDetails.isNotEmpty) {
      buffer.writeln('Project Details: ${projectDetails.join(' | ')}');
    }

    return buffer.toString();
  }

  /// Builds the Gemini prompt that instructs the model to return a strict
  /// JSON structure matching [ATSAnalysisModel.fromJson].
  String _buildPrompt(String resumeText, String jobDescription) {
    final jdSection = jobDescription.isNotEmpty
        ? '''

--- JOB DESCRIPTION ---
$jobDescription
--- END JOB DESCRIPTION ---
'''
        : '''

(No specific job description was provided. Evaluate against general industry best practices.)
''';

    return '''
You are an expert ATS (Applicant Tracking System) resume analyst.

Analyze the following resume data against the provided job description (if any) and return a JSON object with EXACTLY this structure — no markdown, no explanation, ONLY valid JSON:

{
  "overallScore": <int 0–100>,
  "scoreBreakdown": {
    "formatting": <int 0–100>,
    "keywordMatch": <int 0–100>,
    "skills": <int 0–100>,
    "experience": <int 0–100>,
    "grammar": <int 0–100>
  },
  "matchedKeywords": [
    { "keyword": "<string>", "count": <int>, "weight": "high" | "medium" | "low" }
  ],
  "missingKeywords": [
    { "keyword": "<string>", "importance": "high" | "medium" | "low", "category": "<Technical | Soft Skill | Industry>" }
  ],
  "suggestions": [
    { "title": "<short title>", "description": "<actionable advice>", "priority": "high" | "medium" | "low", "category": "<Skills | Experience | Formatting | Keywords | Grammar | General>" }
  ],
  "analyzedAt": "<ISO 8601 timestamp>"
}

Rules:
- overallScore MUST be an integer between 0 and 100.
- scoreBreakdown values MUST each be integers between 0 and 100.
- Provide at least 3 missingKeywords and at least 3 suggestions.
- matchedKeywords should list skills/keywords that ARE present in the resume.
- missingKeywords should list important skills/keywords MISSING from the resume.
- suggestions should be specific, actionable improvement advice.
- Return ONLY the JSON object, no surrounding text or markdown fences.

--- RESUME ---
$resumeText
--- END RESUME ---
$jdSection
Return ONLY the JSON object now:
''';
  }

  /// Calls the Gemini REST API and returns the raw text response.
  Future<String> _callGemini(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 2048,
        'responseMimeType': 'application/json',
      },
    });

    final http.Response response;
    try {
      response = await _httpClient
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 25));
    } catch (e) {
      throw ServerException('Failed to connect to Gemini API: ${e.toString()}');
    }

    if (response.statusCode != 200) {
      final errorBody = response.body;
      throw ServerException(
        'Gemini API error (${response.statusCode}): $errorBody',
        response.statusCode,
      );
    }

    // Extract the text from the Gemini response envelope.
    final Map<String, dynamic> envelope;
    try {
      envelope = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ServerException('Invalid response from Gemini API.');
    }

    final candidates = envelope['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw const ServerException('Gemini returned no candidates.');
    }

    final content =
        (candidates[0] as Map<String, dynamic>)['content']
            as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw const ServerException('Gemini returned empty content.');
    }

    final text = (parts[0] as Map<String, dynamic>)['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      throw const ServerException('Gemini returned empty text.');
    }

    return text;
  }

  /// Parses the raw Gemini text response into a structured map.
  /// Handles cases where the model wraps the JSON in markdown fences.
  Map<String, dynamic> _parseResponse(String rawText) {
    var cleaned = rawText.trim();

    // Strip leading/trailing markdown code fences if present.
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\s*```$'), '');
    }

    try {
      dynamic parsed;
      try {
        parsed = jsonDecode(cleaned);
      } catch (_) {
        final start = cleaned.indexOf('{');
        final end = cleaned.lastIndexOf('}');
        if (start >= 0 && end > start) {
          parsed = jsonDecode(cleaned.substring(start, end + 1));
        } else {
          rethrow;
        }
      }

      if (parsed is Map<String, dynamic>) {
        // Ensure analyzedAt is present.
        parsed['analyzedAt'] ??= DateTime.now().toIso8601String();
        return parsed;
      }
      throw const ServerException(
        'Gemini response is not a valid JSON object.',
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        'Failed to parse Gemini response as JSON: ${e.toString()}',
      );
    }
  }

  // ── Template Search & Tagging API ──────────────────────────────────────

  /// Auto-generates tags, category, and target profession for a template
  /// based on its name and type. Used by admin when saving a template.
  Future<Map<String, dynamic>> generateTemplateTags({
    required String templateName,
    required String templateType,
  }) async {
    final prompt = '''
You are a resume template classification expert.

Given the following resume template details, generate relevant search metadata so users can find this template by searching for their degree or profession.

Template Name: $templateName
Template Style: $templateType

Return a JSON object with EXACTLY this structure — no markdown, no explanation, ONLY valid JSON:

{
  "tags": ["<list of 8-12 relevant search tags like degree names, fields, job roles — e.g. BCA, MCA, BCom, MBA, IT, Software Developer, fresher, experienced, Computer Science, Data Analyst>"],
  "category": "<one of: engineering, commerce, arts, medical, management, science, law, design, education, general>",
  "targetProfession": "<primary target profession — e.g. Software Developer, Accountant, Graphic Designer, Teacher>"
}

Rules:
- Tags must include common Indian degree abbreviations (BCA, MCA, BBA, BCom, BTech, MTech, MBA, BSc, MSc, BA, MA, etc.) that would suit this template style.
- Tags should also include relevant job roles and fields.
- Keep tags lowercase except for degree abbreviations.
- Return ONLY the JSON object, no surrounding text.
''';

    final responseText = await _callGemini(prompt);
    return _parseResponse(responseText);
  }

  /// Provides AI-powered search recommendations when a user searches by
  /// degree or profession. Returns best template type, skills, and summary.
  Future<Map<String, dynamic>> searchRecommendation({
    required String query,
  }) async {
    final prompt = '''
You are a career counselor and resume expert.

A user is searching for resume templates related to: "$query"

Return a JSON object with EXACTLY this structure — no markdown, no explanation, ONLY valid JSON:

{
  "recommendedTemplateType": "<one of: professional, modern, minimal, creative, classic>",
  "recommendedCategory": "<one of: engineering, commerce, arts, medical, management, science, law, design, education, general>",
  "relevantTags": ["<list of 5-8 tags that match this search — degree names, fields, roles>"],
  "suggestedSkills": ["<list of 8-10 key skills a person with this degree/profession should have on their resume>"],
  "suggestedSummary": "<a 2-3 sentence professional summary template that someone with this degree/profession could use>",
  "fieldDescription": "<a brief 1-sentence description of this field/degree for UI display>"
}

Rules:
- recommendedTemplateType should be the best template style for this profession/degree.
- suggestedSkills should be specific and relevant (e.g. for BCA: Flutter, Java, Python, SQL, HTML/CSS, Data Structures, Git, Problem Solving).
- suggestedSummary should be a reusable template with placeholders like [X years] where appropriate.
- Return ONLY the JSON object, no surrounding text.
''';

    final responseText = await _callGemini(prompt);
    return _parseResponse(responseText);
  }

  // Keep backward-compatible static helpers from the old AIService.

  /// Get score level string based on value.
  static String getScoreLevel(int score) {
    if (score >= 80) return 'excellent';
    if (score >= 60) return 'good';
    if (score >= 40) return 'average';
    return 'poor';
  }

  /// Get human-readable score message.
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
