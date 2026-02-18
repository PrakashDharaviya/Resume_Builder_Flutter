import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_event.dart';
import '../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Not authenticated'));
          }

          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(
                                  user.displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Handle edit profile
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(AppStrings.editProfile),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Settings
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dark_mode_outlined),
                        title: const Text(AppStrings.darkMode),
                        trailing: Switch(
                          value: _isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              _isDarkMode = value;
                            });
                            // TODO: Implement dark mode toggle
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: const Text(AppStrings.notifications),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle notifications
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: const Text(AppStrings.language),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle language
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text(AppStrings.settings),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle settings
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Danger Zone
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color: AppColors.info,
                        ),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle help
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                        ),
                        title: const Text('About'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle about
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: AppColors.error,
                        ),
                        title: const Text(
                          AppStrings.logout,
                          style: TextStyle(color: AppColors.error),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(AppStrings.cancel),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                      const SignOutEvent(),
                                    );
                                    Navigator.of(context).pop();
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed(AppRoutes.login);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: const Text(AppStrings.logout),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // App Version
                Text(
                  'ResumeIQ v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
