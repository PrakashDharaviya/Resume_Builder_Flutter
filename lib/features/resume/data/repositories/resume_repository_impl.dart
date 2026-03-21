import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/exceptions.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/resume/data/datasources/resume_remote_data_source.dart';
import 'package:resumebuilder/features/resume/data/models/resume_model.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/features/resume/domain/repositories/resume_repository.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  final ResumeRemoteDataSource remoteDataSource;

  ResumeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Resume>>> getAllResumes() async {
    try {
      final resumes = await remoteDataSource.getUserResumes();
      return Right(resumes);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Resume>> getResumeById(String id) async {
    try {
      final resume = await remoteDataSource.getResumeById(id);
      return Right(resume);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Resume>> createResume(Resume resume) async {
    try {
      final resumeModel = ResumeModel.fromEntity(resume);
      final createdResume = await remoteDataSource.createResume(resumeModel);
      return Right(createdResume);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
      final updatedResume = await remoteDataSource.updateResume(resumeModel);
      return Right(updatedResume);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteResume(String id) async {
    try {
      await remoteDataSource.deleteResume(id);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
