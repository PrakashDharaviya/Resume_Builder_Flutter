import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_theme.dart';
import 'core/utils/app_preferences.dart';
import 'features/ats_analysis/presentation/bloc/ats_bloc.dart';
import 'features/ats_analysis/presentation/pages/ats_analysis_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/profile/profile_page.dart';
import 'features/resume/domain/entities/resume.dart';
import 'features/resume/presentation/bloc/resume_bloc.dart';
import 'features/resume/presentation/pages/dashboard_page.dart';
import 'features/resume/presentation/pages/pdf_export_page.dart';
import 'features/resume/presentation/pages/resume_editor_page.dart';
import 'features/resume/presentation/pages/resume_preview_page.dart';
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
      builder: (_, themeMode, __) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
          BlocProvider<ResumeBloc>(create: (_) => di.sl<ResumeBloc>()),
          BlocProvider<ATSBloc>(create: (_) => di.sl<ATSBloc>()),
        ],
        child: MaterialApp(
          title: 'ResumeIQ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.splash:
                return MaterialPageRoute(builder: (_) => const SplashPage());

              case AppRoutes.login:
                return MaterialPageRoute(builder: (_) => const LoginPage());

              case AppRoutes.register:
                return MaterialPageRoute(builder: (_) => const RegisterPage());

              case AppRoutes.dashboard:
                return MaterialPageRoute(builder: (_) => const DashboardPage());

              case AppRoutes.profile:
                return MaterialPageRoute(builder: (_) => const ProfilePage());

              case AppRoutes.atsAnalysis:
                final resumeData = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (_) => ATSAnalysisPage(resumeData: resumeData ?? {}),
                );

              case AppRoutes.createResume:
                return MaterialPageRoute(
                  builder: (_) => const CreateResumePage(),
                );

              case AppRoutes.resumeEditor:
                return MaterialPageRoute(
                  builder: (_) => const ResumeEditorPage(),
                  settings: settings,
                );

              case AppRoutes.resumePreview:
                final resume = settings.arguments as Resume;
                return MaterialPageRoute(
                  builder: (_) => ResumePreviewPage(resume: resume),
                );

              case AppRoutes.exportPDF:
                final resume = settings.arguments as Resume;
                return MaterialPageRoute(
                  builder: (_) => PDFExportPage(resume: resume),
                );

              default:
                return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: Center(
                      child: Text('Route ${settings.name} not found'),
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

// Create Resume landing page
class CreateResumePage extends StatelessWidget {
  const CreateResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Resume')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 50,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Create New Resume',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Build your professional resume section by section.\nAdd education, experience, skills and more.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(
                  context,
                ).pushReplacementNamed(AppRoutes.resumeEditor),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Start Building'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
