import '../../../../core/services/ai_service.dart';
import '../models/ats_analysis_model.dart';

abstract class ATSRemoteDataSource {
  Future<ATSAnalysisModel> analyzeResume(Map<String, dynamic> resumeData);
}

class ATSRemoteDataSourceImpl implements ATSRemoteDataSource {
  final AIService aiService;

  ATSRemoteDataSourceImpl({required this.aiService});

  @override
  Future<ATSAnalysisModel> analyzeResume(
    Map<String, dynamic> resumeData,
  ) async {
    final result = await aiService.analyzeResume(resumeData: resumeData);
    return ATSAnalysisModel.fromJson(result);
  }
}
