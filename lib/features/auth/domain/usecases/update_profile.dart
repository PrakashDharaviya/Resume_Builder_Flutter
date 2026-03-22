import 'package:dartz/dartz.dart';
import 'package:resumebuilder/core/errors/failures.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart';
import 'package:resumebuilder/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<Either<Failure, User>> call({
    required String displayName,
    required String email,
    String? currentPassword,
  }) async {
    return await repository.updateProfile(
      displayName: displayName,
      email: email,
      currentPassword: currentPassword,
    );
  }
}
