import '../core/services/firebase_service.dart';
import '../features/auth/data/models/user_model.dart';
import '../features/auth/domain/entities/user.dart';

class AuthService {
  final FirebaseService _firebaseService;

  AuthService({FirebaseService? firebaseService})
    : _firebaseService = firebaseService ?? FirebaseService();

  Future<User> signInWithEmail(String email, String password) {
    return _firebaseService
        .signInWithEmail(email: email, password: password)
        .then((json) => UserModel.fromJson(json));
  }

  Future<User> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) {
    return _firebaseService
        .signUpWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        )
        .then((json) => UserModel.fromJson(json));
  }

  Future<User> signInWithGoogle() {
    return _firebaseService.signInWithGoogle().then(
      (json) => UserModel.fromJson(json),
    );
  }

  Future<void> signOut() {
    return _firebaseService.signOut();
  }

  Future<User?> getCurrentUser() {
    final userJson = _firebaseService.getCurrentUser();
    return Future.value(userJson == null ? null : UserModel.fromJson(userJson));
  }
}
