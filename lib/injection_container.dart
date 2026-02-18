import 'package:get_it/get_it.dart';
import 'core/network/network_info.dart';
import 'core/services/ai_service.dart';
import 'core/services/firebase_service.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in_with_email.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up_with_email.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Resume
import 'features/resume/data/datasources/resume_local_data_source.dart';
import 'features/resume/data/repositories/resume_repository_impl.dart';
import 'features/resume/domain/repositories/resume_repository.dart';
import 'features/resume/domain/usecases/create_resume.dart';
import 'features/resume/domain/usecases/delete_resume.dart';
import 'features/resume/domain/usecases/get_all_resumes.dart';
import 'features/resume/domain/usecases/get_resume_by_id.dart';
import 'features/resume/domain/usecases/update_resume.dart';
import 'features/resume/presentation/bloc/resume_bloc.dart';

// ATS Analysis
import 'features/ats_analysis/data/datasources/ats_remote_data_source.dart';
import 'features/ats_analysis/data/repositories/ats_repository_impl.dart';
import 'features/ats_analysis/domain/repositories/ats_repository.dart';
import 'features/ats_analysis/domain/usecases/analyze_resume.dart';
import 'features/ats_analysis/presentation/bloc/ats_bloc.dart';

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
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseService: sl()),
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
    () => ResumeRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ResumeLocalDataSource>(
    () => ResumeLocalDataSourceImpl(),
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
    () => ATSRemoteDataSourceImpl(aiService: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => FirebaseService());
  sl.registerLazySingleton(() => AIService());
}
