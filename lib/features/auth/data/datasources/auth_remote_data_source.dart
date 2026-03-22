import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:resumebuilder/core/errors/exceptions.dart';
import 'package:resumebuilder/features/auth/data/models/user_model.dart';

// ---------------------------------------------------------------------------
// Abstract contract – remains unchanged so the rest of the app is unaffected.
// ---------------------------------------------------------------------------
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

  Future<UserModel> updateProfile({
    required String displayName,
    required String email,
    String? currentPassword,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  UserModel? getCurrentUser();

  bool isSignedIn();
}

// ---------------------------------------------------------------------------
// Implementation – talks to FirebaseAuth & Firestore DIRECTLY.
// ---------------------------------------------------------------------------
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.googleSignIn,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Fetches role / isBlocked / isPremium from the `users` collection.
  /// Falls back to sensible defaults if the document does not exist yet.
  Future<UserModel> _userModelFromFirebaseUser(
    firebase_auth.User user,
  ) async {
    final doc =
        await firebaseFirestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: (data['displayName'] as String?) ?? user.displayName ?? '',
        photoURL: user.photoURL,
        role: (data['role'] as String?) ?? 'user',
        isBlocked: (data['isBlocked'] as bool?) ?? false,
        isPremium: (data['isPremium'] as bool?) ?? false,
      );
    }

    // Document doesn't exist – return defaults.
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      role: 'user',
      isBlocked: false,
      isPremium: false,
    );
  }

  /// Maps Firebase error codes to human‑readable messages and throws
  /// the project's own [AuthException].
  Never _handleFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    final String friendlyMessage;

    switch (e.code) {
      case 'invalid-email':
        friendlyMessage = 'The email address is not valid.';
        break;
      case 'user-disabled':
        friendlyMessage =
            'This account has been disabled. Contact support.';
        break;
      case 'user-not-found':
        friendlyMessage = 'No account found with this email.';
        break;
      case 'wrong-password':
        friendlyMessage = 'Incorrect password. Please try again.';
        break;
      case 'invalid-credential':
        friendlyMessage = 'Invalid credentials. Please check and try again.';
        break;
      case 'email-already-in-use':
        friendlyMessage =
            'An account already exists with this email address.';
        break;
      case 'weak-password':
        friendlyMessage =
            'Password is too weak. Use at least 6 characters.';
        break;
      case 'operation-not-allowed':
        friendlyMessage =
            'This sign‑in method is not enabled. Contact support.';
        break;
      case 'too-many-requests':
        friendlyMessage =
            'Too many attempts. Please wait a moment and try again.';
        break;
      case 'network-request-failed':
        friendlyMessage =
            'Network error. Please check your connection and try again.';
        break;
      default:
        friendlyMessage = e.message ?? 'Authentication failed. Please try again.';
    }

    throw AuthException(friendlyMessage);
  }

  // ── Sign In with Email & Password ───────────────────────────────────────

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userModelFromFirebaseUser(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  // ── Create User with Email & Password ───────────────────────────────────

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // 1. Create the Firebase Auth account.
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      // 2. Set the display name on the Auth profile.
      await user.updateDisplayName(displayName);

      // 3. Create the user profile document in Firestore.
      final userData = <String, dynamic>{
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'photoURL': '',
        'role': 'user',
        'isBlocked': false,
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .set(userData);

      // 4. Return the freshly created user model.
      return UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        photoURL: '',
        role: 'user',
        isBlocked: false,
        isPremium: false,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  // ── Sign In with Google ─────────────────────────────────────────────────

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign‑in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final oAuthCredential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(oAuthCredential);
      final user = userCredential.user!;

      // Create a Firestore profile if this is the user's first sign‑in.
      final doc =
          await firebaseFirestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        final userData = <String, dynamic>{
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'role': 'user',
          'isBlocked': false,
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .set(userData);
      }

      return _userModelFromFirebaseUser(user);
    } on AuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      throw AuthException('Google sign‑in failed: ${e.toString()}');
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  // ── Reset Password ─────────────────────────────────────────────────────

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  // ── Update Profile ──────────────────────────────────────────────────────

  @override
  Future<UserModel> updateProfile({
    required String displayName,
    required String email,
    String? currentPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user found.');
      }

      // Update display name in Firebase Auth
      await user.updateDisplayName(displayName);

      // If email changed, re-authenticate first then update
      if (email != user.email) {
        if (currentPassword == null || currentPassword.isEmpty) {
          throw const AuthException(
            'Current password is required to change email.',
          );
        }
        // Re-authenticate
        final credential = firebase_auth.EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.verifyBeforeUpdateEmail(email);
      }

      // Update Firestore document
      await firebaseFirestore.collection('users').doc(user.uid).set({
        'displayName': displayName,
        'email': email,
      }, SetOptions(merge: true));

      return _userModelFromFirebaseUser(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Profile update failed: ${e.toString()}');
    }
  }

  // ── Change Password ─────────────────────────────────────────────────────

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user found.');
      }

      // Re-authenticate with current password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update to new password
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Password change failed: ${e.toString()}');
    }
  }

  // ── Get Current User (synchronous) ──────────────────────────────────────

  @override
  UserModel? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      role: 'user',
      isBlocked: false,
      isPremium: false,
    );
  }

  // ── Is Signed In ───────────────────────────────────────────────────────

  @override
  bool isSignedIn() {
    return firebaseAuth.currentUser != null;
  }
}
