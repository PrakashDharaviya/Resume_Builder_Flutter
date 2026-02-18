import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const SignUpWithEmailEvent({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}
