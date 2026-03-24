import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/auth/domain/repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    return await repository.resetPassword(email);
  }
}
