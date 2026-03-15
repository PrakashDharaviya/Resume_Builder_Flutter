import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/features/resume/domain/repositories/resume_repository.dart';

class UpdateResume {
  final ResumeRepository repository;

  UpdateResume(this.repository);

  Future<Either<Failure, Resume>> call(Resume resume) async {
    return await repository.updateResume(resume);
  }
}
