import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>> _getUserData(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      return {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': data['displayName'] ?? user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'role': data['role'] ?? 'user',
        'isBlocked': data['isBlocked'] ?? false,
        'isPremium': data['isPremium'] ?? false,
      };
    }
    return {
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'photoURL': user.photoURL ?? '',
      'role': 'user',
      'isBlocked': false,
      'isPremium': false,
    };
  }

  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getUserData(credential.user!);
  }

  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName);

    final userData = {
      'uid': user.uid,
      'email': email,
      'displayName': displayName,
      'role': 'user',
      'isBlocked': false,
      'isPremium': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('users').doc(user.uid).set(userData);

    return {
      'uid': user.uid,
      'email': email,
      'displayName': displayName,
      'photoURL': '',
      'role': 'user',
      'isBlocked': false,
      'isPremium': false,
    };
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      final userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'role': 'user',
        'isBlocked': false,
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('users').doc(user.uid).set(userData);
    }

    return _getUserData(user);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Map<String, dynamic>? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return {
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'photoURL': user.photoURL ?? '',
      'role': 'user',
      'isBlocked': false,
      'isPremium': false,
    };
  }

  bool isSignedIn() {
    return _auth.currentUser != null;
  }
}

class FirebaseAuthException implements Exception {
  final String code;
  final String message;
  FirebaseAuthException({required this.code, required this.message});

  @override
  String toString() => 'FirebaseAuthException($code): $message';
}
