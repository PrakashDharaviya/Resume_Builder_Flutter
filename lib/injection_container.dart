import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:resumebuilder/api_keys.dart';
import 'package:resumebuilder/core/network/network_info.dart';
import 'package:resumebuilder/core/services/ai_service.dart';
import 'package:resumebuilder/core/services/firebase_service.dart';
import 'package:resumebuilder/core/services/gemini_ai_service.dart';
import 'package:resumebuilder/core/services/groq_ai_service.dart';
import 'package:resumebuilder/core/theme/theme_cubit.dart';
// Admin
import 'package:resumebuilder/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:resumebuilder/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:resumebuilder/features/admin/domain/repositories/admin_repository.dart';
import 'package:resumebuilder/features/admin/presentation/bloc/admin_bloc.dart';
// ATS Analysis
import 'package:resumebuilder/features/ats_analysis/data/datasources/ats_remote_data_source.dart';
import 'package:resumebuilder/features/ats_analysis/data/repositories/ats_repository_impl.dart';
import 'package:resumebuilder/features/ats_analysis/domain/repositories/ats_repository.dart';
import 'package:resumebuilder/features/ats_analysis/domain/usecases/analyze_resume.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/bloc/ats_bloc.dart';
// Auth
import 'package:resumebuilder/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:resumebuilder/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:resumebuilder/features/auth/domain/repositories/auth_repository.dart';
import 'package:resumebuilder/features/auth/domain/usecases/change_password.dart';
import 'package:resumebuilder/features/auth/domain/usecases/check_email_exists.dart';
import 'package:resumebuilder/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:resumebuilder/features/auth/domain/usecases/get_current_user.dart';
import 'package:resumebuilder/features/auth/domain/usecases/reset_password.dart';
import 'package:resumebuilder/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:resumebuilder/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:resumebuilder/features/auth/domain/usecases/sign_out.dart';
import 'package:resumebuilder/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:resumebuilder/features/auth/domain/usecases/update_profile.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_bloc.dart';
// Resume
import 'package:resumebuilder/features/resume/data/datasources/resume_remote_data_source.dart';
import 'package:resumebuilder/features/resume/data/repositories/resume_repository_impl.dart';
import 'package:resumebuilder/features/resume/domain/repositories/resume_repository.dart';
import 'package:resumebuilder/features/resume/domain/usecases/create_resume.dart';
import 'package:resumebuilder/features/resume/domain/usecases/delete_resume.dart';
import 'package:resumebuilder/features/resume/domain/usecases/get_all_resumes.dart';
import 'package:resumebuilder/features/resume/domain/usecases/get_resume_by_id.dart';
import 'package:resumebuilder/features/resume/domain/usecases/update_resume.dart';
import 'package:resumebuilder/features/resume/presentation/bloc/resume_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features

  // ============ Auth ============
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithGoogle: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      updateProfile: sl(),
      changePassword: sl(),
      checkEmailExists: sl(),
      resetPassword: sl(),
      confirmPasswordReset: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => CheckEmailExists(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => ConfirmPasswordReset(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: FirebaseAuth.instance,
      firebaseFirestore: FirebaseFirestore.instance,
      googleSignIn: GoogleSignIn(
        clientId: (kIsWeb || defaultTargetPlatform == TargetPlatform.windows)
            ? '465329982315-bg09qe87n32c633q9ogubk32dhsrje82.apps.googleusercontent.com'
            : null,
      ),
    ),
  );

  // ============ Resume ============
  // Bloc
  sl.registerFactory(
    () => ResumeBloc(
      getAllResumes: sl(),
      getResumeById: sl(),
      createResume: sl(),
      updateResume: sl(),
      deleteResume: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllResumes(sl()));
  sl.registerLazySingleton(() => GetResumeById(sl()));
  sl.registerLazySingleton(() => CreateResume(sl()));
  sl.registerLazySingleton(() => UpdateResume(sl()));
  sl.registerLazySingleton(() => DeleteResume(sl()));

  // Repository
  sl.registerLazySingleton<ResumeRepository>(
    () => ResumeRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ResumeRemoteDataSource>(
    () => ResumeRemoteDataSourceImpl(
      firebaseFirestore: FirebaseFirestore.instance,
      firebaseAuth: FirebaseAuth.instance,
    ),
  );

  // ============ ATS Analysis ============
  // Bloc
  sl.registerFactory(() => ATSBloc(analyzeResume: sl()));

  // Use cases
  sl.registerLazySingleton(() => AnalyzeResume(sl()));

  // Repository
  sl.registerLazySingleton<ATSRepository>(
    () => ATSRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ATSRemoteDataSource>(
    () => ATSRemoteDataSourceImpl(
      geminiAIService: sl(),
      groqAIService: sl(),
      localAIService: sl(),
    ),
  );

  //! Core
  // Bloc / Cubit
  sl.registerFactory(() => ThemeCubit());

  // Services
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => FirebaseService());
  sl.registerLazySingleton(() => AIService());
  sl.registerLazySingleton(() => GeminiAIService(apiKey: geminiApiKey));
  sl.registerLazySingleton(() => GroqAIService(apiKey: groqApiKey));

  // ============ Admin ============
  // Bloc
  sl.registerFactory(() => AdminBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(dataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(firestore: FirebaseFirestore.instance),
  );
}
