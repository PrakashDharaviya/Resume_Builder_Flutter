import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/auth/domain/repositories/auth_repository.dart';

class ConfirmPasswordReset {
  final AuthRepository repository;

  ConfirmPasswordReset(this.repository);

  Future<Either<Failure, void>> call({
    required String oobCode,
    required String newPassword,
  }) async {
    return await repository.confirmPasswordReset(
      oobCode: oobCode,
      newPassword: newPassword,
    );
  }
}
