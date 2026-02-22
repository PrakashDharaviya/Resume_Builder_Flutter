import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_preferences.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/user_tile.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
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
      body: LayoutBuilder(
        builder: (ctx, lc) => Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: lc.maxWidth >= 1024
                ? 1000
                : (lc.maxWidth >= 640 ? 780 : double.infinity),
            height: lc.maxHeight,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<AdminBloc>().add(SearchUsers(query: query));
                    },
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context.read<AdminBloc>().add(
                                  const SearchUsers(query: ''),
                                );
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1F2937)
                          : const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // User List
                Expanded(
                  child: BlocConsumer<AdminBloc, AdminState>(
                    listener: (context, state) {
                      if (state is AdminActionSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.accent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    buildWhen: (_, current) =>
                        current is UsersLoaded ||
                        current is AdminLoading ||
                        current is AdminError,
                    builder: (context, state) {
                      if (state is AdminLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is AdminError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(state.message),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context.read<AdminBloc>().add(
                                  const LoadUsers(),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is UsersLoaded) {
                        final users = state.displayUsers;

                        if (users.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_off_rounded,
                                  size: 56,
                                  color: isDark
                                      ? const Color(0xFF4B5563)
                                      : const Color(0xFFD1D5DB),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return UserTile(
                              user: user,
                              onToggleBlock: () {
                                _showConfirmDialog(
                                  context,
                                  title: user.isBlocked
                                      ? 'Unblock User'
                                      : 'Block User',
                                  message: user.isBlocked
                                      ? 'Are you sure you want to unblock ${user.displayName}?'
                                      : 'Are you sure you want to block ${user.displayName}? They will not be able to access the app.',
                                  confirmLabel: user.isBlocked
                                      ? 'Unblock'
                                      : 'Block',
                                  confirmColor: user.isBlocked
                                      ? AppColors.accent
                                      : Colors.red,
                                  onConfirm: () {
                                    context.read<AdminBloc>().add(
                                      ToggleBlockUser(uid: user.uid),
                                    );
                                  },
                                );
                              },
                              onTogglePremium: () {
                                context.read<AdminBloc>().add(
                                  TogglePremiumUser(uid: user.uid),
                                );
                              },
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
