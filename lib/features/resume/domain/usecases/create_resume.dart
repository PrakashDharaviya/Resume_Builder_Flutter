import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/resume.dart';
import '../repositories/resume_repository.dart';

class CreateResume {
  final ResumeRepository repository;

  CreateResume(this.repository);

  Future<Either<Failure, Resume>> call(Resume resume) async {
    return await repository.createResume(resume);
  }
}
