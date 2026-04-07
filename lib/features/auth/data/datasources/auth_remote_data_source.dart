import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:resumebuilder/core/errors/exceptions.dart';
import 'package:resumebuilder/core/services/error_message_service.dart';
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

  /// Maps Firebase error codes to user-friendly and admin messages using ErrorMessageService
  Never _handleFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    final errorMessage = ErrorMessageService.mapFirebaseAuthError(
      e.code,
      originalMessage: e.message,
    );

    // Create a comprehensive error message that includes both user and admin info
    final userFacingMessage = ErrorMessageService.formatForUser(errorMessage);

    // For logging and debugging: log the admin message
    debugPrint(
      '🔐 Auth Error Log: ${ErrorMessageService.formatForLog(errorMessage)}',
    );

    throw AuthException(userFacingMessage);
  }

  // NOTE: _handleFunctionsError removed — Cloud Functions no longer used for password reset.

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
      final userModel = await _userModelFromFirebaseUser(credential.user!);

      // Check if user is blocked
      if (userModel.isBlocked) {
        await firebaseAuth.signOut();
        throw const AuthException(
          'Your account has been blocked. Please contact support.',
        );
      }

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      final errorMessage = ErrorMessageService.mapGenericError(
        e,
        errorType: 'sign_in',
      );
      debugPrint(
        '🔐 Sign-In Error: ${ErrorMessageService.formatForLog(errorMessage)}',
      );
      throw AuthException(ErrorMessageService.formatForUser(errorMessage));
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
      final errorMessage = ErrorMessageService.mapGenericError(
        e,
        errorType: 'sign_up',
      );
      debugPrint(
        '🔐 Sign-Up Error: ${ErrorMessageService.formatForLog(errorMessage)}',
      );
      throw AuthException(ErrorMessageService.formatForUser(errorMessage));
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

      final userModel = await _userModelFromFirebaseUser(user);

      // Check if user is blocked
      if (userModel.isBlocked) {
        await firebaseAuth.signOut();
        throw const AuthException(
          'Your account has been blocked. Please contact support.',
        );
      }

      return userModel;
    } on AuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      // Handle generic Google Sign-In errors
      final errorMessage = ErrorMessageService.mapGenericError(
        e,
        errorType: 'google_sign_in',
      );
      debugPrint(
        '🔐 Google Sign-In Error: ${ErrorMessageService.formatForLog(errorMessage)}',
      );
      throw AuthException(ErrorMessageService.formatForUser(errorMessage));
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

  // ── Reset Password (Firebase built-in — free, works on web + mobile) ────

  @override
  Future<void> resetPassword(String email) async {
    try {
      final trimmedEmail = email.trim();

      // 1. Check if email is registered (works when Email Enumeration
      //    Protection is disabled in Firebase Console → Auth → Settings)
      // ignore: deprecated_member_use
      final methods = await firebaseAuth.fetchSignInMethodsForEmail(
        trimmedEmail,
      );

      if (methods.isEmpty) {
        throw const AuthException(
          'This email is not registered. Please check and try again.',
        );
      }

      // 2. Check if user only has Google Sign-In (no password to reset)
      if (!methods.contains('password')) {
        throw const AuthException(
          'This account uses Google Sign-In. '
          'Please use the "Sign in with Google" button on the login page.',
        );
      }

      // 3. Email exists and has password provider — send reset link
      await firebaseAuth.sendPasswordResetEmail(email: trimmedEmail);
    } on AuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle user-not-found explicitly
      if (e.code == 'user-not-found') {
        throw const AuthException(
          'This email is not registered. Please check and try again.',
        );
      }
      _handleFirebaseAuthError(e);
    } catch (e) {
      final errorMessage = ErrorMessageService.mapGenericError(
        e,
        errorType: 'password_reset',
      );
      debugPrint(
        '🔐 Password Reset Error: ${ErrorMessageService.formatForLog(errorMessage)}',
      );
      throw AuthException(ErrorMessageService.formatForUser(errorMessage));
    }
  }

  // ── Confirm Password Reset ────────────────────────────────────────────────
  // Note: Password is actually reset when user clicks the Firebase link.
  // This method is kept for interface compatibility.

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String oobCode,
    required String newPassword,
  }) async {
    try {
      // Use Firebase Auth's confirmPasswordReset with the oobCode from the email link
      await firebaseAuth.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      final errorMessage = ErrorMessageService.mapGenericError(
        e,
        errorType: 'confirm_password_reset',
      );
      debugPrint(
        '🔐 Confirm Password Reset Error: ${ErrorMessageService.formatForLog(errorMessage)}',
      );
      throw AuthException(ErrorMessageService.formatForUser(errorMessage));
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
      final errorMessage = ErrorMessageService.mapGenericError(
        e,
        errorType: 'change_password',
      );
      debugPrint(
        '🔐 Change Password Error: ${ErrorMessageService.formatForLog(errorMessage)}',
      );
      throw AuthException(ErrorMessageService.formatForUser(errorMessage));
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
