import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/resume.dart';
import '../repositories/resume_repository.dart';

class GetResumeById {
  final ResumeRepository repository;

  GetResumeById(this.repository);

  Future<Either<Failure, Resume>> call(String id) async {
    return await repository.getResumeById(id);
  }
}
