import 'package:flutter/material.dart';
import '../../admin_routes.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/app_preferences.dart';

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
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
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
          _item(
            context,
            Icons.dashboard_rounded,
            'Dashboard',
            AdminRoutes.dashboard,
          ),
          _item(
            context,
            Icons.people_rounded,
            'Users',
            AdminRoutes.manageUsers,
          ),
          _item(
            context,
            Icons.style_rounded,
            'Templates',
            AdminRoutes.manageTemplates,
          ),
          _item(
            context,
            Icons.tune_rounded,
            'ATS Settings',
            AdminRoutes.atsSettings,
          ),
          _item(
            context,
            Icons.insights_rounded,
            'Analytics',
            AdminRoutes.analytics,
          ),
          _item(
            context,
            Icons.campaign_rounded,
            'Announcements',
            AdminRoutes.announcements,
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

  Widget _item(
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
