import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoURL,
    super.role,
    super.isBlocked,
    super.isPremium,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      role: (json['role'] as String?) ?? 'user',
      isBlocked: (json['isBlocked'] as bool?) ?? false,
      isPremium: (json['isPremium'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'isBlocked': isBlocked,
      'isPremium': isPremium,
    };
  }

  User toEntity() {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      role: role,
      isBlocked: isBlocked,
      isPremium: isPremium,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      role: user.role,
      isBlocked: user.isBlocked,
      isPremium: user.isPremium,
    );
  }
}
