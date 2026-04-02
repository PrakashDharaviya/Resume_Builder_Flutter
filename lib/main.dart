import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:resumebuilder/app_router.dart';
import 'package:resumebuilder/core/constants/app_routes.dart';
import 'package:resumebuilder/core/constants/app_theme.dart';
import 'package:resumebuilder/core/services/notification_service.dart';
import 'package:resumebuilder/core/theme/theme_cubit.dart';
import 'package:resumebuilder/core/utils/app_preferences.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:resumebuilder/features/resume/presentation/bloc/resume_bloc.dart';
import 'package:resumebuilder/firebase_options.dart';
import 'package:resumebuilder/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // No emulator needed — OTP emails are sent directly via Gmail SMTP from Flutter.

  await NotificationService.initialize();
  await di.init();
  runApp(const ResumeIQApp());
}

class ResumeIQApp extends StatelessWidget {
  const ResumeIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<ResumeBloc>(create: (_) => di.sl<ResumeBloc>()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, themeMode, _) => MaterialApp(
          title: 'ResumeIQ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
  }
}
