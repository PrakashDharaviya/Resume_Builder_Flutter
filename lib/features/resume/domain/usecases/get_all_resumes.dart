import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/resume.dart';
import '../repositories/resume_repository.dart';

class GetAllResumes {
  final ResumeRepository repository;

  GetAllResumes(this.repository);

  Future<Either<Failure, List<Resume>>> call() async {
    return await repository.getAllResumes();
  }
}
