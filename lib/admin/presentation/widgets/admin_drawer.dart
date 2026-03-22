import 'package:flutter/material.dart';
import 'package:resumebuilder/core/constants/app_routes.dart';
import 'package:resumebuilder/core/utils/app_preferences.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'ResumeIQ Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          item(
            context,
            Icons.dashboard_rounded,
            'Dashboard',
            AppRoutes.adminDashboard,
          ),
          item(
            context,
            Icons.people_rounded,
            'Users',
            AppRoutes.manageUsers,
          ),
          item(
            context,
            Icons.style_rounded,
            'Templates',
            AppRoutes.manageTemplates,
          ),
          item(
            context,
            Icons.tune_rounded,
            'ATS Settings',
            AppRoutes.atsSettings,
          ),
          item(
            context,
            Icons.insights_rounded,
            'Analytics',
            AppRoutes.analytics,
          ),
          item(
            context,
            Icons.campaign_rounded,
            'Announcements',
            AppRoutes.announcements,
          ),
          const Divider(height: 24),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, _) {
              final isDark =
                  themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return ListTile(
                leading: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
                onTap: () {
                  themeNotifier.value = isDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget item(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    final selected = currentRoute == route;
    return ListTile(
      selected: selected,
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        if (!selected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
