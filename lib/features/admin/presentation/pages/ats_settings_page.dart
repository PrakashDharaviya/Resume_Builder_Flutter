import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_preferences.dart';
import '../../domain/entities/ats_config.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class ATSSettingsPage extends StatefulWidget {
  const ATSSettingsPage({super.key});

  @override
  State<ATSSettingsPage> createState() => _ATSSettingsPageState();
}

class _ATSSettingsPageState extends State<ATSSettingsPage> {
  double _keywordWeight = 30;
  double _skillWeight = 25;
  double _grammarWeight = 15;
  double _experienceWeight = 20;
  double _formattingWeight = 10;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadATSConfig());
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
          'ATS Settings',
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
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is ATSConfigLoaded) {
            setState(() {
              _keywordWeight = state.config.keywordWeight;
              _skillWeight = state.config.skillWeight;
              _grammarWeight = state.config.grammarWeight;
              _experienceWeight = state.config.experienceWeight;
              _formattingWeight = state.config.formattingWeight;
            });
          }
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
            current is ATSConfigLoaded ||
            current is AdminLoading ||
            current is AdminError,
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalWeight =
              _keywordWeight +
              _skillWeight +
              _grammarWeight +
              _experienceWeight +
              _formattingWeight;

          return SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF8B5CF6,
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
                                  Icons.tune_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'ATS Scoring Weights',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Configure how each category contributes to the overall ATS score. Total must equal 100%.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: totalWeight == 100
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Total: ${totalWeight.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Sliders
                      _weightSlider(
                        context,
                        label: 'Keyword Matching',
                        icon: Icons.key_rounded,
                        value: _keywordWeight,
                        color: const Color(0xFF3B82F6),
                        onChanged: (v) => setState(() => _keywordWeight = v),
                        isDark: isDark,
                      ),
                      _weightSlider(
                        context,
                        label: 'Skills Assessment',
                        icon: Icons.psychology_rounded,
                        value: _skillWeight,
                        color: const Color(0xFF10B981),
                        onChanged: (v) => setState(() => _skillWeight = v),
                        isDark: isDark,
                      ),
                      _weightSlider(
                        context,
                        label: 'Grammar & Language',
                        icon: Icons.spellcheck_rounded,
                        value: _grammarWeight,
                        color: const Color(0xFFF59E0B),
                        onChanged: (v) => setState(() => _grammarWeight = v),
                        isDark: isDark,
                      ),
                      _weightSlider(
                        context,
                        label: 'Experience Relevance',
                        icon: Icons.work_outline_rounded,
                        value: _experienceWeight,
                        color: const Color(0xFFEF4444),
                        onChanged: (v) => setState(() => _experienceWeight = v),
                        isDark: isDark,
                      ),
                      _weightSlider(
                        context,
                        label: 'Formatting & Layout',
                        icon: Icons.format_align_left_rounded,
                        value: _formattingWeight,
                        color: const Color(0xFF8B5CF6),
                        onChanged: (v) => setState(() => _formattingWeight = v),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 28),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: totalWeight == 100
                              ? () {
                                  context.read<AdminBloc>().add(
                                    UpdateATSConfig(
                                      config: ATSConfig(
                                        keywordWeight: _keywordWeight,
                                        skillWeight: _skillWeight,
                                        grammarWeight: _grammarWeight,
                                        experienceWeight: _experienceWeight,
                                        formattingWeight: _formattingWeight,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text(
                            'Save Configuration',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFE5E7EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      if (totalWeight != 100)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Center(
                            child: Text(
                              'Weights must total 100% (currently ${totalWeight.toStringAsFixed(0)}%)',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _weightSlider(
    BuildContext context, {
    required String label,
    required IconData icon,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.round()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 50,
              divisions: 50,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
