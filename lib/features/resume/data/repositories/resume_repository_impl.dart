import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/resume.dart';
import '../../domain/repositories/resume_repository.dart';
import '../datasources/resume_local_data_source.dart';
import '../models/resume_model.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  final ResumeLocalDataSource localDataSource;

  ResumeRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Resume>>> getAllResumes() async {
    try {
      final resumes = await localDataSource.getAllResumes();
      return Right(resumes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Resume>> getResumeById(String id) async {
    try {
      final resume = await localDataSource.getResumeById(id);
      return Right(resume);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Resume>> createResume(Resume resume) async {
    try {
      final resumeModel = ResumeModel.fromEntity(resume);
      final createdResume = await localDataSource.createResume(resumeModel);
      return Right(createdResume);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Resume>> updateResume(Resume resume) async {
    try {
      final resumeModel = ResumeModel.fromEntity(resume);
      final updatedResume = await localDataSource.updateResume(resumeModel);
      return Right(updatedResume);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteResume(String id) async {
    try {
      await localDataSource.deleteResume(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
