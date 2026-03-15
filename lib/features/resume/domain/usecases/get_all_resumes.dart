import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/features/resume/domain/repositories/resume_repository.dart';

class GetAllResumes {
  final ResumeRepository repository;

  GetAllResumes(this.repository);

  Future<Either<Failure, List<Resume>>> call() async {
    return await repository.getAllResumes();
  }
}
