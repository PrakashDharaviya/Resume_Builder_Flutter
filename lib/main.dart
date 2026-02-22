import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_router.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_theme.dart';
import 'core/utils/app_preferences.dart';
import 'features/ats_analysis/presentation/bloc/ats_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/resume/presentation/bloc/resume_bloc.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const ResumeIQApp());
}

class ResumeIQApp extends StatelessWidget {
  const ResumeIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
          BlocProvider<ResumeBloc>(create: (_) => di.sl<ResumeBloc>()),
          BlocProvider<ATSBloc>(create: (_) => di.sl<ATSBloc>()),
          BlocProvider<AdminBloc>(create: (_) => di.sl<AdminBloc>()),
        ],
        child: MaterialApp(
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
