import 'package:equatable/equatable.dart';
import 'package:resumebuilder/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateSuccess extends AuthState {
  final User user;
  final String message;

  const ProfileUpdateSuccess({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

class PasswordChangeSuccess extends AuthState {
  final String message;

  const PasswordChangeSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordLoading extends AuthState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends AuthState {
  final String message;

  const ForgotPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordError extends AuthState {
  final String message;

  const ForgotPasswordError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ConfirmPasswordResetLoading extends AuthState {
  const ConfirmPasswordResetLoading();
}

class ConfirmPasswordResetSuccess extends AuthState {
  final String message;

  const ConfirmPasswordResetSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ConfirmPasswordResetError extends AuthState {
  final String message;

  const ConfirmPasswordResetError({required this.message});

  @override
  List<Object?> get props => [message];
}
