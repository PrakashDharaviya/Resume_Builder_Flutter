import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/ats_analysis/domain/entities/ats_analysis.dart';

abstract class ATSRepository {
  Future<Either<Failure, ATSAnalysis>> analyzeResume(
    Map<String, dynamic> resumeData,
  );
}
