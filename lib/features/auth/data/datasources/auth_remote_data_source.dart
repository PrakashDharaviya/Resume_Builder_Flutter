import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  Future<bool> checkEmailExists(String email);

  Future<void> resetPassword(String email);

  Future<void> confirmPasswordReset({
    required String email,
    required String oobCode,
    required String newPassword,
  });

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
  final FirebaseFunctions firebaseFunctions;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.firebaseFunctions,
    required this.googleSignIn,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Fetches role / isBlocked / isPremium from the `users` collection.
  /// Falls back to sensible defaults if the document does not exist yet.
  Future<UserModel> _userModelFromFirebaseUser(firebase_auth.User user) async {
    final doc = await firebaseFirestore.collection('users').doc(user.uid).get();

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
      case 'missing-email':
        friendlyMessage = 'Please enter your email address.';
        break;
      case 'user-disabled':
        friendlyMessage = 'This account has been disabled. Contact support.';
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
        friendlyMessage = 'An account already exists with this email address.';
        break;
      case 'weak-password':
        friendlyMessage = 'Password is too weak. Use at least 6 characters.';
        break;
      case 'expired-action-code':
        friendlyMessage =
            'This reset link has expired. Request a new password reset email.';
        break;
      case 'invalid-action-code':
        friendlyMessage =
            'Invalid reset link or code. Please request a new one.';
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
        friendlyMessage =
            e.message ?? 'Authentication failed. Please try again.';
    }

    throw AuthException(friendlyMessage);
  }

  Never _handleFunctionsError(FirebaseFunctionsException e) {
    final String friendlyMessage;
    switch (e.code) {
      case 'not-found':
        friendlyMessage = 'No account found with this email address.';
        break;
      case 'resource-exhausted':
        friendlyMessage =
            e.message ?? 'Please wait before requesting a new code.';
        break;
      case 'deadline-exceeded':
        friendlyMessage =
            e.message ?? 'Verification code has expired. Request a new one.';
        break;
      case 'permission-denied':
        friendlyMessage =
            e.message ?? 'Too many attempts or invalid verification request.';
        break;
      case 'failed-precondition':
        friendlyMessage =
            e.message ?? 'Please request a new verification code first.';
        break;
      case 'invalid-argument':
        friendlyMessage = e.message ?? 'Invalid input. Please check and retry.';
        break;
      case 'internal':
        if (e.message != null && e.message != 'internal') {
          friendlyMessage = e.message!;
        } else {
          friendlyMessage = 'Server error. Ensure backend is running and mailer configured.';
        }
        break;
      default:
        if (e.message == 'internal') {
          friendlyMessage = 'Unexpected server error occurred. Please try again.';
        } else {
          friendlyMessage = e.message ?? 'Password reset request failed. Please try again.';
        }
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

      await firebaseFirestore.collection('users').doc(user.uid).set(userData);

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

      final userCredential = await firebaseAuth.signInWithCredential(
        oAuthCredential,
      );
      final user = userCredential.user!;

      // Create a Firestore profile if this is the user's first sign‑in.
      final doc = await firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .get();
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
        await firebaseFirestore.collection('users').doc(user.uid).set(userData);
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

  // ── Check Email Exists ────────────────────────────────────────────────

  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final rawEmail = email.trim();
      final normalizedEmail = email.trim().toLowerCase();
      final exactQuery = await firebaseFirestore
          .collection('users')
          .where('email', isEqualTo: rawEmail)
          .limit(1)
          .get();

      if (exactQuery.docs.isNotEmpty) {
        return true;
      }

      if (rawEmail != normalizedEmail) {
        final normalizedQuery = await firebaseFirestore
            .collection('users')
            .where('email', isEqualTo: normalizedEmail)
            .limit(1)
            .get();

        return normalizedQuery.docs.isNotEmpty;
      }

      return false;
    } catch (e) {
      throw const AuthException('Could not verify email. Please try again.');
    }
  }

  // ── Reset Password ─────────────────────────────────────────────────────

  @override
  Future<void> resetPassword(String email) async {
    try {
      final callable = firebaseFunctions.httpsCallable(
        'requestPasswordResetOtp',
      );
      await callable.call<dynamic>(<String, dynamic>{'email': email.trim()});
    } on FirebaseFunctionsException catch (e) {
      _handleFunctionsError(e);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  // ── Confirm Password Reset ─────────────────────────────────────────────

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String oobCode,
    required String newPassword,
  }) async {
    try {
      final callable = firebaseFunctions.httpsCallable(
        'confirmPasswordResetWithOtp',
      );
      await callable.call<dynamic>(<String, dynamic>{
        'email': email.trim(),
        'otpCode': oobCode.trim(),
        'newPassword': newPassword,
      });
    } on FirebaseFunctionsException catch (e) {
      _handleFunctionsError(e);
    } catch (e) {
      throw const AuthException('Could not reset password. Please try again.');
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
