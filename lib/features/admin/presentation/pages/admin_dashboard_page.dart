import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/app_preferences.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/stat_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadAdminDashboard());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
          'Admin Dashboard',
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
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
          ),
        ],
      ),
      drawer: _buildAdminDrawer(context, isDark),
      body: BlocBuilder<AdminBloc, AdminState>(
        buildWhen: (_, current) =>
            current is AdminDashboardLoaded ||
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
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AdminBloc>().add(
                      const LoadAdminDashboard(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminDashboardLoaded) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<AdminBloc>().add(const LoadAdminDashboard());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1E3A8A),
                                    Color(0xFF3B82F6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1E3A8A,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.admin_panel_settings_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Admin Panel',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Manage your ResumeIQ platform',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Stats Grid
                            Text(
                              'Overview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 14),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount =
                                    constraints.maxWidth >= 980
                                    ? 3
                                    : (constraints.maxWidth >= 620 ? 2 : 1);

                                return GridView.count(
                                  crossAxisCount: crossAxisCount,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: crossAxisCount == 1
                                      ? 2.9
                                      : 1.35,
                                  children: [
                                    StatCard(
                                      title: 'Total Users',
                                      value: '${state.stats.totalUsers}',
                                      icon: Icons.people_rounded,
                                      color: const Color(0xFF3B82F6),
                                      subtitle:
                                          '+${state.stats.todaySignups} today',
                                    ),
                                    StatCard(
                                      title: 'Total Resumes',
                                      value: '${state.stats.totalResumes}',
                                      icon: Icons.description_rounded,
                                      color: const Color(0xFF10B981),
                                    ),
                                    StatCard(
                                      title: 'Premium Users',
                                      value: '${state.stats.premiumUsers}',
                                      icon: Icons.star_rounded,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                    StatCard(
                                      title: 'Avg. ATS Score',
                                      value:
                                          '${state.stats.avgAtsScore.toStringAsFixed(1)}%',
                                      icon: Icons.analytics_rounded,
                                      color: const Color(0xFF8B5CF6),
                                    ),
                                    StatCard(
                                      title: 'Active Templates',
                                      value: '${state.stats.activeTemplates}',
                                      icon: Icons.style_rounded,
                                      color: const Color(0xFFEC4899),
                                    ),
                                    StatCard(
                                      title: 'Blocked Users',
                                      value: '${state.stats.blockedUsers}',
                                      icon: Icons.block_rounded,
                                      color: const Color(0xFFEF4444),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 28),

                            // Quick Actions
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _quickActionTile(
                              context,
                              icon: Icons.people_outlined,
                              title: 'Manage Users',
                              subtitle:
                                  '${state.stats.totalUsers} registered users',
                              color: const Color(0xFF3B82F6),
                              onTap: () =>
                                  _navigateAndReload(AppRoutes.manageUsers),
                              isDark: isDark,
                            ),
                            _quickActionTile(
                              context,
                              icon: Icons.style_outlined,
                              title: 'Manage Templates',
                              subtitle:
                                  '${state.stats.activeTemplates} active templates',
                              color: const Color(0xFF10B981),
                              onTap: () =>
                                  _navigateAndReload(AppRoutes.manageTemplates),
                              isDark: isDark,
                            ),
                            _quickActionTile(
                              context,
                              icon: Icons.tune_rounded,
                              title: 'ATS Settings',
                              subtitle: 'Configure scoring weights',
                              color: const Color(0xFF8B5CF6),
                              onTap: () =>
                                  _navigateAndReload(AppRoutes.atsSettings),
                              isDark: isDark,
                            ),
                            _quickActionTile(
                              context,
                              icon: Icons.bar_chart_rounded,
                              title: 'Analytics',
                              subtitle: 'Template usage and growth trends',
                              color: const Color(0xFF06B6D4),
                              onTap: () =>
                                  _navigateAndReload(AppRoutes.analytics),
                              isDark: isDark,
                            ),
                            _quickActionTile(
                              context,
                              icon: Icons.campaign_outlined,
                              title: 'Announcements',
                              subtitle: 'Manage platform announcements',
                              color: const Color(0xFFF59E0B),
                              onTap: () =>
                                  _navigateAndReload(AppRoutes.announcements),
                              isDark: isDark,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateAndReload(String route) {
    Navigator.pushNamed(context, route).then((_) {
      if (mounted) {
        context.read<AdminBloc>().add(const LoadAdminDashboard());
      }
    });
  }

  Widget _quickActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ResumeIQ Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'admin@resumeiq.com',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            isSelected: true,
            onTap: () => Navigator.pop(context),
            isDark: isDark,
          ),
          _drawerItem(
            context,
            icon: Icons.people_rounded,
            title: 'Users',
            onTap: () {
              Navigator.pop(context);
              _navigateAndReload(AppRoutes.manageUsers);
            },
            isDark: isDark,
          ),
          _drawerItem(
            context,
            icon: Icons.style_rounded,
            title: 'Templates',
            onTap: () {
              Navigator.pop(context);
              _navigateAndReload(AppRoutes.manageTemplates);
            },
            isDark: isDark,
          ),
          _drawerItem(
            context,
            icon: Icons.tune_rounded,
            title: 'ATS Settings',
            onTap: () {
              Navigator.pop(context);
              _navigateAndReload(AppRoutes.atsSettings);
            },
            isDark: isDark,
          ),
          _drawerItem(
            context,
            icon: Icons.bar_chart_rounded,
            title: 'Analytics',
            onTap: () {
              Navigator.pop(context);
              _navigateAndReload(AppRoutes.analytics);
            },
            isDark: isDark,
          ),
          _drawerItem(
            context,
            icon: Icons.campaign_rounded,
            title: 'Announcements',
            onTap: () {
              Navigator.pop(context);
              _navigateAndReload(AppRoutes.announcements);
            },
            isDark: isDark,
          ),
          const Divider(height: 32),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, _) {
              final isDarkMode =
                  themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return _drawerItem(
                context,
                icon: isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                title: isDarkMode ? 'Light Mode' : 'Dark Mode',
                onTap: () {
                  themeNotifier.value = isDarkMode
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
                isDark: isDark,
              );
            },
          ),
          _drawerItem(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            color: Colors.red,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    bool isSelected = false,
    Color? color,
  }) {
    final itemColor =
        color ??
        (isSelected
            ? const Color(0xFF1E3A8A)
            : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)));

    return ListTile(
      leading: Icon(icon, color: itemColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: itemColor,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
    );
  }
}
