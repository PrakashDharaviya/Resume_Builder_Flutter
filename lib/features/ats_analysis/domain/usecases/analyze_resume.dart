import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ats_analysis.dart';
import '../repositories/ats_repository.dart';

class AnalyzeResume {
  final ATSRepository repository;

  AnalyzeResume(this.repository);

  Future<Either<Failure, ATSAnalysis>> call(
    Map<String, dynamic> resumeData,
  ) async {
    return await repository.analyzeResume(resumeData);
  }
}
