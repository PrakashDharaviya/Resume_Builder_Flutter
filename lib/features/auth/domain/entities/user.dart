import 'package:equatable/equatable.dart';

// User Entity
class User extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String role; // 'admin' | 'user'
  final bool isBlocked;
  final bool isPremium;

  const User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.role = 'user',
    this.isBlocked = false,
    this.isPremium = false,
  });

  bool get isAdmin => role == 'admin';

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? role,
    bool? isBlocked,
    bool? isPremium,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoURL,
    role,
    isBlocked,
    isPremium,
  ];
}
