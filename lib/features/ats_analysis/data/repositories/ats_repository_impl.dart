import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ats_analysis.dart';
import '../../domain/repositories/ats_repository.dart';
import '../datasources/ats_remote_data_source.dart';

class ATSRepositoryImpl implements ATSRepository {
  final ATSRemoteDataSource remoteDataSource;

  ATSRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ATSAnalysis>> analyzeResume(
    Map<String, dynamic> resumeData,
  ) async {
    try {
      final analysis = await remoteDataSource.analyzeResume(resumeData);
      return Right(analysis);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
