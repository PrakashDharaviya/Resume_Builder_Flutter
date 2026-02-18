import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> resetPassword(String email);

  Either<Failure, User?> getCurrentUser();

  bool isSignedIn();
}
