import 'package:resumebuilder/core/services/gemini_ai_service.dart';
import 'package:resumebuilder/features/ats_analysis/data/models/ats_analysis_model.dart';

abstract class ATSRemoteDataSource {
  Future<ATSAnalysisModel> analyzeResume(Map<String, dynamic> resumeData);
}

class ATSRemoteDataSourceImpl implements ATSRemoteDataSource {
  final GeminiAIService geminiAIService;

  ATSRemoteDataSourceImpl({required this.geminiAIService});

  @override
  Future<ATSAnalysisModel> analyzeResume(
    Map<String, dynamic> resumeData,
  ) async {
    final result =
        await geminiAIService.analyzeResume(resumeData: resumeData);
    return ATSAnalysisModel.fromJson(result);
  }
}
