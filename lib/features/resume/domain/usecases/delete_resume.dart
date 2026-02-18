import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/resume_repository.dart';

class DeleteResume {
  final ResumeRepository repository;

  DeleteResume(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteResume(id);
  }
}
