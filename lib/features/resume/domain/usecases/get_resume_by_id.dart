import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/features/resume/domain/repositories/resume_repository.dart';

class GetResumeById {
  final ResumeRepository repository;

  GetResumeById(this.repository);

  Future<Either<Failure, Resume>> call(String id) async {
    return await repository.getResumeById(id);
  }
}
