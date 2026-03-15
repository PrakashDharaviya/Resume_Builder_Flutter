import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/ats_analysis/domain/entities/ats_analysis.dart';
import 'package:resumebuilder/features/ats_analysis/domain/repositories/ats_repository.dart';

class AnalyzeResume {
  final ATSRepository repository;

  AnalyzeResume(this.repository);

  Future<Either<Failure, ATSAnalysis>> call(
    Map<String, dynamic> resumeData,
  ) async {
    return await repository.analyzeResume(resumeData);
  }
}
