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

class UpdateProfileEvent extends AuthEvent {
  final String displayName;
  final String email;
  final String? currentPassword;

  const UpdateProfileEvent({
    required this.displayName,
    required this.email,
    this.currentPassword,
  });

  @override
  List<Object?> get props => [displayName, email, currentPassword];
}

class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class ForgotPasswordRequestedEvent extends AuthEvent {
  final String email;

  const ForgotPasswordRequestedEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ConfirmPasswordResetEvent extends AuthEvent {
  final String oobCode;
  final String newPassword;

  const ConfirmPasswordResetEvent({
    required this.oobCode,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oobCode, newPassword];
}
