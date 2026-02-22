import 'package:flutter/material.dart';
import '../../admin_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/mock_database_service.dart';
import '../../../core/utils/app_preferences.dart';
import '../widgets/admin_drawer.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final db = MockDatabaseService.instance;
    final stats = db.getAdminStats();
    final templates = db.getTemplates();

    final totalUsage = templates.length * 10;
    final usage = <String, int>{
      for (var i = 0; i < templates.length; i++)
        templates[i].name: (i + 1) * 10,
    };

    final premiumPct = stats.totalUsers == 0
        ? 0.0
        : stats.premiumUsers / stats.totalUsers;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      drawer: const AdminDrawer(currentRoute: AdminRoutes.analytics),
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
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
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          final isTablet = constraints.maxWidth >= 700;
          final maxContentWidth = isDesktop ? 1200.0 : 900.0;

          final metricCards = [
            _metricCard(
              context,
              title: 'Average ATS Score',
              value: '${stats.avgAtsScore.toStringAsFixed(1)}%',
              icon: Icons.analytics_rounded,
              color: const Color(0xFF8B5CF6),
            ),
            _metricCard(
              context,
              title: 'Resume Growth',
              value: '+${stats.todaySignups} today',
              icon: Icons.trending_up_rounded,
              color: AppColors.accent,
            ),
          ];

          final usageCard = _sectionCard(
            context,
            title: 'Template Usage',
            child: Column(
              children: usage.entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                minHeight: 10,
                                value: totalUsage == 0
                                    ? 0
                                    : entry.value / totalUsage,
                                backgroundColor: isDark
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFE5E7EB),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1E3A8A),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${entry.value}', style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          );

          final premiumCard = _sectionCard(
            context,
            title: 'Premium Users Split',
            child: Row(
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: premiumPct,
                        strokeWidth: 9,
                        backgroundColor: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        '${(premiumPct * 100).toStringAsFixed(0)}%',
                        style: textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium: ${stats.premiumUsers}',
                        style: textTheme.bodyMedium,
                      ),
                      Text(
                        'Standard: ${stats.totalUsers - stats.premiumUsers}',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Most used template: ${stats.mostUsedTemplate}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (isTablet)
                    Row(
                      children: [
                        Expanded(child: metricCards[0]),
                        const SizedBox(width: 12),
                        Expanded(child: metricCards[1]),
                      ],
                    )
                  else ...[
                    metricCards[0],
                    const SizedBox(height: 12),
                    metricCards[1],
                  ],
                  const SizedBox(height: 16),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: usageCard),
                        const SizedBox(width: 12),
                        Expanded(child: premiumCard),
                      ],
                    )
                  else ...[
                    usageCard,
                    const SizedBox(height: 12),
                    premiumCard,
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
