import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/resume.dart';

abstract class ResumeRepository {
  Future<Either<Failure, List<Resume>>> getAllResumes();
  Future<Either<Failure, Resume>> getResumeById(String id);
  Future<Either<Failure, Resume>> createResume(Resume resume);
  Future<Either<Failure, Resume>> updateResume(Resume resume);
  Future<Either<Failure, void>> deleteResume(String id);
}
