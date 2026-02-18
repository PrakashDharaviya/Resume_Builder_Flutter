import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ats_analysis.dart';

abstract class ATSRepository {
  Future<Either<Failure, ATSAnalysis>> analyzeResume(
    Map<String, dynamic> resumeData,
  );
}
