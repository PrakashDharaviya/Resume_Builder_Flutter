import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/features/auth/domain/usecases/change_password.dart';
import 'package:resumebuilder/features/auth/domain/usecases/get_current_user.dart';
import 'package:resumebuilder/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:resumebuilder/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:resumebuilder/features/auth/domain/usecases/sign_out.dart';
import 'package:resumebuilder/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:resumebuilder/features/auth/domain/usecases/update_profile.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_event.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final UpdateProfile updateProfile;
  final ChangePassword changePassword;

  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
    required this.updateProfile,
    required this.changePassword,
  }) : super(const AuthInitial()) {
    on<SignInWithEmailEvent>(onSignInWithEmail);
    on<SignUpWithEmailEvent>(onSignUpWithEmail);
    on<SignInWithGoogleEvent>(onSignInWithGoogle);
    on<SignOutEvent>(onSignOut);
    on<CheckAuthStatusEvent>(onCheckAuthStatus);
    on<UpdateProfileEvent>(onUpdateProfile);
    on<ChangePasswordEvent>(onChangePassword);
  }

  Future<void> onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signInWithEmail(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signUpWithEmail(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signInWithGoogle();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await signOut();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  void onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) {
    final result = getCurrentUser();

    result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  Future<void> onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await updateProfile(
      displayName: event.displayName,
      email: event.email,
      currentPassword: event.currentPassword,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(ProfileUpdateSuccess(
        user: user,
        message: 'Profile updated successfully!',
      )),
    );
  }

  Future<void> onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const PasswordChangeSuccess(
        message: 'Password changed successfully!',
      )),
    );
  }
}
