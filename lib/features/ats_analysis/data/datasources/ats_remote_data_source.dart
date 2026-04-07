import 'dart:async';
import 'dart:convert';

import 'package:resumebuilder/core/errors/exceptions.dart';
import 'package:resumebuilder/core/services/ai_service.dart';
import 'package:resumebuilder/core/services/gemini_ai_service.dart';
import 'package:resumebuilder/core/services/groq_ai_service.dart';
import 'package:resumebuilder/features/ats_analysis/data/models/ats_analysis_model.dart';

abstract class ATSRemoteDataSource {
  Future<ATSAnalysisModel> analyzeResume(Map<String, dynamic> resumeData);
}

class ATSRemoteDataSourceImpl implements ATSRemoteDataSource {
  final GeminiAIService geminiAIService;
  final GroqAIService groqAIService;
  final AIService localAIService;

  static const int _maxRetries = 2;
  static const int _cacheLimit = 50;

  final Map<String, ATSAnalysisModel> _analysisCache = {};

  ATSRemoteDataSourceImpl({
    required this.geminiAIService,
    required this.groqAIService,
    required this.localAIService,
  });

  @override
  Future<ATSAnalysisModel> analyzeResume(
    Map<String, dynamic> resumeData,
  ) async {
    final cacheKey = _buildCacheKey(resumeData);
    final cachedResult = _analysisCache[cacheKey];
    if (cachedResult != null) return cachedResult;

    final model = await _analyzeWithProviderChain(resumeData);
    _saveToCache(cacheKey, model);
    return model;
  }

  Future<ATSAnalysisModel> _analyzeWithProviderChain(
    Map<String, dynamic> resumeData,
  ) async {
    final allowLocalFallback =
        (resumeData['useLocalFallback'] as bool?) ?? false;
    Object? geminiError;
    Object? groqError;

    try {
      final geminiResult = await _analyzeWithRetry(
        request: () => geminiAIService.analyzeResume(resumeData: resumeData),
      );
      return ATSAnalysisModel.fromJson(geminiResult);
    } catch (e) {
      geminiError = e;
      // Fall through to Groq provider.
    }

    try {
      final groqResult = await _analyzeWithRetry(
        request: () => groqAIService.analyzeResume(resumeData: resumeData),
      );
      return ATSAnalysisModel.fromJson(groqResult);
    } catch (e) {
      groqError = e;
    }

    if (!allowLocalFallback) {
      final details = 'Gemini failed: $geminiError | Groq failed: $groqError';
      throw ServerException(
        'ATS API analysis failed on all providers. $details',
      );
    }

    final fallbackResult = await localAIService.analyzeResume(
      resumeData: resumeData,
    );
    return ATSAnalysisModel.fromJson(fallbackResult);
  }

  Future<Map<String, dynamic>> _analyzeWithRetry({
    required Future<Map<String, dynamic>> Function() request,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await request();
      } on ServerException catch (e) {
        if (!_shouldRetry(e) || attempt >= _maxRetries) rethrow;
      } on TimeoutException {
        if (attempt >= _maxRetries) rethrow;
      }

      attempt++;
      final delayMs = 400 * (1 << (attempt - 1));
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
  }

  bool _shouldRetry(ServerException e) {
    final code = e.statusCode;
    if (code == null) return false;
    return code == 429 || code >= 500;
  }

  String _buildCacheKey(Map<String, dynamic> resumeData) {
    final normalized = Map<String, dynamic>.from(resumeData)
      ..remove('analyzedAt');
    return jsonEncode(normalized);
  }

  void _saveToCache(String key, ATSAnalysisModel value) {
    if (_analysisCache.length >= _cacheLimit) {
      _analysisCache.remove(_analysisCache.keys.first);
    }
    _analysisCache[key] = value;
  }
}
