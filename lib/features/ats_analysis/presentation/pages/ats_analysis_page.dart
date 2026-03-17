import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/core/constants/app_colors.dart';
import 'package:resumebuilder/core/constants/app_strings.dart';
import 'package:resumebuilder/features/ats_analysis/domain/entities/ats_analysis.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/bloc/ats_bloc.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/bloc/ats_event.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/bloc/ats_state.dart';

class ATSAnalysisPage extends StatefulWidget {
  final Map<String, dynamic> resumeData;

  const ATSAnalysisPage({super.key, required this.resumeData});

  @override
  State<ATSAnalysisPage> createState() => ATSAnalysisPageState();
}

class ATSAnalysisPageState extends State<ATSAnalysisPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Start analysis
    context.read<ATSBloc>().add(AnalyzeResumeEvent(widget.resumeData));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.atsAnalysis)),
      body: BlocConsumer<ATSBloc, ATSState>(
        listener: (context, state) {
          if (state is ATSAnalysisComplete) {
            animationController.forward();
          }
        },
        builder: (context, state) {
          if (state is AtsAnalysisLoading) {
            return buildAnalyzingState();
          }

          if (state is ATSAnalysisComplete) {
            return buildAnalysisResults(state.analysis);
          }

          if (state is AtsAnalysisTimeout) {
            return buildErrorState(
              state.message,
            ); // or a custom buildTimeoutState(state.message)
          }

          if (state is AtsAnalysisError) {
            return buildErrorState(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget buildAnalyzingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Analyzing your resume...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: TextStyle(color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget buildAnalysisResults(ATSAnalysis analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score Circle
          buildScoreCircle(analysis.overallScore),
          const SizedBox(height: 32),

          // Score Breakdown
          buildScoreBreakdown(analysis.scoreBreakdown),
          const SizedBox(height: 24),

          // Matched Keywords
          buildMatchedKeywords(analysis.matchedKeywords),
          const SizedBox(height: 24),

          // Missing Keywords
          buildMissingKeywords(analysis.missingKeywords),
          const SizedBox(height: 24),

          // Improvement Suggestions
          if (analysis.suggestions.isNotEmpty) ...[
            buildSuggestions(analysis.suggestions),
            const SizedBox(height: 24),
          ],

          // Action Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Editor'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScoreCircle(int score) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Center(
          child: Column(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: ScoreCirclePainter(
                    score: score,
                    progress: animationController.value,
                    color: getScoreColor(score),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(score * animationController.value).toInt()}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'ATS Score',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                getScoreMessage(score),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildScoreBreakdown(Map<String, int> scoreBreakdown) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.scoreBreakdown,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...scoreBreakdown.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          '${entry.value}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / 100,
                      backgroundColor: AppColors.grey200,
                      valueColor: AlwaysStoppedAnimation(
                        getScoreColor(entry.value),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildMatchedKeywords(List<KeywordMatch> keywords) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matched Keywords',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: keywords.map((keyword) {
                return Chip(
                  label: Text('${keyword.keyword} (${keyword.count})'),
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  side: const BorderSide(color: AppColors.success),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMissingKeywords(List<MissingKeyword> keywords) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.missingKeywords,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...keywords.map((keyword) {
              return ListTile(
                leading: Icon(
                  Icons.error_outline,
                  color: getImportanceColor(keyword.importance),
                ),
                title: Text(keyword.keyword),
                subtitle: Text(keyword.category),
                trailing: Chip(
                  label: Text(keyword.importance),
                  backgroundColor: getImportanceColor(
                    keyword.importance,
                  ).withValues(alpha: 0.1),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildSuggestions(List<Suggestion> suggestions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.suggestions,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...suggestions.map((s) {
              final priority = s.priority.toLowerCase();
              Color chipColor;
              switch (priority) {
                case 'high':
                  chipColor = AppColors.error;
                  break;
                case 'medium':
                  chipColor = AppColors.warning;
                  break;
                default:
                  chipColor = AppColors.info;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  s.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(priority.toUpperCase()),
                                backgroundColor: chipColor.withValues(
                                  alpha: 0.08,
                                ),
                                side: BorderSide(color: chipColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (s.category.isNotEmpty)
                            Text(
                              s.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          if (s.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(s.description),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ATSBloc>().add(
                  AnalyzeResumeEvent(widget.resumeData),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Color getScoreColor(int score) {
    if (score >= 80) return AppColors.scoreExcellent;
    if (score >= 60) return AppColors.scoreGood;
    if (score >= 40) return AppColors.scoreAverage;
    return AppColors.scorePoor;
  }

  Color getImportanceColor(String importance) {
    switch (importance.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  String getScoreMessage(int score) {
    if (score >= 80) {
      return 'Excellent! Your resume is highly optimized for ATS systems.';
    } else if (score >= 60) {
      return 'Good job! Your resume should pass most ATS systems with improvements.';
    } else if (score >= 40) {
      return 'Your resume needs improvement to better match ATS requirements.';
    } else {
      return 'Your resume needs significant improvements for ATS optimization.';
    }
  }
}

// Custom painter for score circle
class ScoreCirclePainter extends CustomPainter {
  final int score;
  final double progress;
  final Color color;

  ScoreCirclePainter({
    required this.score,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.grey200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (score / 100) * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ScoreCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
