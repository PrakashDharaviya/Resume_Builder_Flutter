import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/mock_database_service.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../widgets/template_card.dart';

class TemplateSelectionPage extends StatelessWidget {
  const TemplateSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = MockDatabaseService.instance
        .getTemplates()
        .where((t) => t.isActive)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Template')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isPremiumUser = authState is AuthAuthenticated
              ? authState.user.isPremium
              : false;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final template = templates[index];
              final locked = template.isPremium && !isPremiumUser;

              return TemplateCard(
                template: template,
                locked: locked,
                onTap: () {
                  if (locked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Premium template. Upgrade required.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  Navigator.pushNamed(context, AppRoutes.resumeEditor);
                },
              );
            },
          );
        },
      ),
    );
  }
}
