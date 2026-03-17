import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/ats_analysis/data/datasources/ats_remote_data_source.dart';
import 'package:resumebuilder/features/ats_analysis/domain/entities/ats_analysis.dart';
import 'package:resumebuilder/features/ats_analysis/domain/repositories/ats_repository.dart';

class ATSRepositoryImpl implements ATSRepository {
  final ATSRemoteDataSource remoteDataSource;

  ATSRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ATSAnalysis>> analyzeResume(
    Map<String, dynamic> resumeData,
  ) async {
    try {
      // Impose a 30-second timeout for the heavy processing call
      final analysis = await remoteDataSource
          .analyzeResume(resumeData)
          .timeout(const Duration(seconds: 30));
      return Right(analysis);
    } on TimeoutException {
      return const Left(
        TimeoutFailure(
          'The analysis request timed out after 30 seconds. Please try again.',
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
