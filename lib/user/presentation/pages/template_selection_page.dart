import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/core/constants/app_colors.dart';
import 'package:resumebuilder/core/constants/app_routes.dart';
import 'package:resumebuilder/core/services/mock_database_service.dart';
import 'package:resumebuilder/core/utils/app_preferences.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_state.dart';
import 'package:resumebuilder/user/presentation/widgets/template_card.dart';

class TemplateSelectionPage extends StatelessWidget {
  const TemplateSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Choose Template',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search by Degree/Profession',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.templateSearch);
            },
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, _) {
              final isDarkMode =
                  themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return IconButton(
                icon: Icon(
                  isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
                onPressed: () {
                  themeNotifier.value = isDarkMode
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ResumeTemplate>>(
        future: MockDatabaseService.instance.getTemplates(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final templates = snapshot.data!.where((t) => t.isActive).toList();

          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.style_outlined,
                    size: 56,
                    color: isDark
                        ? const Color(0xFF4B5563)
                        : const Color(0xFFD1D5DB),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No templates available',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Templates will appear here once admin adds them',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            );
          }

          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isPremiumUser = authState is AuthAuthenticated
                  ? authState.user.isPremium
                  : false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Text(
                      'Pick a template that fits your style',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      '${templates.length} template${templates.length == 1 ? '' : 's'} available',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),

                  // Grid of template cards
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 900
                            ? 4
                            : constraints.maxWidth > 600
                            ? 3
                            : 2;
                        final hPad = constraints.maxWidth > 600 ? 24.0 : 16.0;

                        return GridView.builder(
                          padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 24),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.68,
                              ),
                          itemCount: templates.length,
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
                                      content: Text(
                                        'Premium template. Upgrade required.',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.resumeEditor,
                                  arguments: {
                                    'templateType': template.templateType,
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
