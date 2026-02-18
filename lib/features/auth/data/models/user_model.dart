import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoURL,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }

  User toEntity() {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }
}
