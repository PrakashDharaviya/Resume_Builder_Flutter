import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_theme.dart';
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
    return MultiBlocProvider(
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
        themeMode: ThemeMode.light,
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
                  body: Center(child: Text('Route ${settings.name} not found')),
                ),
              );
          }
        },
      ),
    );
  }
}

// Placeholder pages for routes
class CreateResumePage extends StatelessWidget {
  const CreateResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Resume')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Create New Resume',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Start building your professional resume with our easy-to-use editor.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushReplacementNamed(AppRoutes.resumeEditor);
              },
              child: const Text('Start Creating'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResumeEditorPage extends StatelessWidget {
  const ResumeEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Resume saved!')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const TextField(
                      decoration: InputDecoration(labelText: 'First Name'),
                    ),
                    const SizedBox(height: 12),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Last Name'),
                    ),
                    const SizedBox(height: 12),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Phone'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('Education'),
                subtitle: const Text('Add your educational background'),
                trailing: const Icon(Icons.add),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.work_outline),
                title: const Text('Experience'),
                subtitle: const Text('Add your work experience'),
                trailing: const Icon(Icons.add),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.psychology_outlined),
                title: const Text('Skills'),
                subtitle: const Text('Add your skills'),
                trailing: const Icon(Icons.add),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('Projects'),
                subtitle: const Text('Add your projects'),
                trailing: const Icon(Icons.add),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final resumeData = <String, dynamic>{};
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.atsAnalysis, arguments: resumeData);
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Analyze ATS Score'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
