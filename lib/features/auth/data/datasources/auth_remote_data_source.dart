import '../../../../core/services/firebase_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<void> resetPassword(String email);

  UserModel? getCurrentUser();

  bool isSignedIn();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseService firebaseService;

  AuthRemoteDataSourceImpl({required this.firebaseService});

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await firebaseService.signInWithEmail(
      email: email,
      password: password,
    );
    return UserModel.fromJson(result);
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final result = await firebaseService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
    return UserModel.fromJson(result);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final result = await firebaseService.signInWithGoogle();
    return UserModel.fromJson(result);
  }

  @override
  Future<void> signOut() async {
    await firebaseService.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await firebaseService.resetPassword(email);
  }

  @override
  UserModel? getCurrentUser() {
    final user = firebaseService.getCurrentUser();
    if (user == null) return null;
    return UserModel.fromJson(user);
  }

  @override
  bool isSignedIn() {
    return firebaseService.isSignedIn();
  }
}
