import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/resume/domain/repositories/resume_repository.dart';

class DeleteResume {
  final ResumeRepository repository;

  DeleteResume(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteResume(id);
  }
}
