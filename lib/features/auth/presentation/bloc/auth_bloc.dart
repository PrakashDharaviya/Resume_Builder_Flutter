import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(const AuthInitial()) {
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onSignInWithEmail(
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

  Future<void> _onSignUpWithEmail(
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

  Future<void> _onSignInWithGoogle(
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

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await signOut();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  void _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) {
    final result = getCurrentUser();

    result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }
}
