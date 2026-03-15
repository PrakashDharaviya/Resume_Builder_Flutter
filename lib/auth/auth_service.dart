import 'package:resumebuilder/core/services/firebase_service.dart';
import 'package:resumebuilder/features/auth/data/models/user_model.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart';

class AuthService {
  final FirebaseService firebaseService;

  AuthService({FirebaseService? firebaseService})
    : firebaseService = firebaseService ?? FirebaseService();

  Future<User> signInWithEmail(String email, String password) {
    return firebaseService
        .signInWithEmail(email: email, password: password)
        .then((json) => UserModel.fromJson(json));
  }

  Future<User> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) {
    return firebaseService
        .signUpWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        )
        .then((json) => UserModel.fromJson(json));
  }

  Future<User> signInWithGoogle() {
    return firebaseService.signInWithGoogle().then(
      (json) => UserModel.fromJson(json),
    );
  }

  Future<void> signOut() {
    return firebaseService.signOut();
  }

  Future<User?> getCurrentUser() {
    final userJson = firebaseService.getCurrentUser();
    return Future.value(userJson == null ? null : UserModel.fromJson(userJson));
  }
}
