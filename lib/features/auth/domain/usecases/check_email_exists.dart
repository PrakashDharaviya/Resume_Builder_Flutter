import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/auth/domain/repositories/auth_repository.dart';

class CheckEmailExists {
  final AuthRepository repository;

  CheckEmailExists(this.repository);

  Future<Either<Failure, bool>> call(String email) async {
    return await repository.checkEmailExists(email);
  }
}
