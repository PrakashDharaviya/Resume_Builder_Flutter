import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/core/services/mock_database_service.dart';
import 'package:resumebuilder/features/admin/domain/entities/ats_config.dart';
import 'package:resumebuilder/features/ats_analysis/domain/entities/ats_analysis.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/bloc/ats_bloc.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/bloc/ats_event.dart';
import 'package:resumebuilder/features/ats_analysis/presentation/bloc/ats_state.dart';
import 'package:resumebuilder/user/presentation/widgets/live_score_meter.dart';

class ATSResultPage extends StatefulWidget {
  final double score;
  final ATSAnalysis? analysis;
  final Map<String, dynamic>? resumeData;

  const ATSResultPage({
    super.key,
    this.score = 78,
    this.analysis,
    this.resumeData,
  });

  @override
  State<ATSResultPage> createState() => _ATSResultPageState();
}

class _ATSResultPageState extends State<ATSResultPage> {
  @override
  void initState() {
    super.initState();

    final data = widget.resumeData;
    if (widget.analysis == null && data != null && data.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ATSBloc>().add(AnalyzeResumeEvent(data));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<ATSConfig>(
      future: MockDatabaseService.instance.getAtsConfig(),
      builder: (context, snapshot) {
        final config = snapshot.data ?? const ATSConfig();

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF111827)
              : const Color(0xFFF9FAFB),
          appBar: AppBar(title: const Text('ATS Result')),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= 900 ? 960.0 : 680.0;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: _buildResultBody(context, config),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResultBody(BuildContext context, ATSConfig config) {
    final initialAnalysis = widget.analysis;
    if (initialAnalysis != null) {
      return _buildAnalysisList(context, config, initialAnalysis);
    }

    final hasResumeData =
        widget.resumeData != null && widget.resumeData!.isNotEmpty;
    if (!hasResumeData) {
      return _buildScoreOnlyList(context, config);
    }

    return BlocBuilder<ATSBloc, ATSState>(
      builder: (context, state) {
        if (state is AtsAnalysisLoading || state is ATSInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ATSAnalysisComplete) {
          return _buildAnalysisList(context, config, state.analysis);
        }

        if (state is AtsAnalysisError || state is AtsAnalysisTimeout) {
          final message = state is AtsAnalysisTimeout
              ? state.message
              : (state as AtsAnalysisError).message;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              card(
                context,
                title: 'Analysis Failed',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final data = widget.resumeData;
                        if (data != null && data.isNotEmpty) {
                          context.read<ATSBloc>().add(AnalyzeResumeEvent(data));
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry Analysis'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return _buildScoreOnlyList(context, config);
      },
    );
  }

  Widget _buildScoreOnlyList(BuildContext context, ATSConfig config) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: LiveScoreMeter(score: widget.score)),
        const SizedBox(height: 16),
        card(
          context,
          title: 'Score Breakdown (Configured Weights)',
          child: Column(
            children: [
              row('Keyword', config.keywordWeight),
              row('Skill', config.skillWeight),
              row('Grammar', config.grammarWeight),
              row('Experience', config.experienceWeight),
              row('Formatting', config.formattingWeight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisList(
    BuildContext context,
    ATSConfig config,
    ATSAnalysis analysis,
  ) {
    final keywordScore = _scoreOf(analysis.scoreBreakdown, const [
      'keywordMatch',
      'keyword',
    ]);
    final skillScore = _scoreOf(analysis.scoreBreakdown, const [
      'skills',
      'skill',
    ]);
    final grammarScore = _scoreOf(analysis.scoreBreakdown, const ['grammar']);
    final experienceScore = _scoreOf(analysis.scoreBreakdown, const [
      'experience',
    ]);
    final formattingScore = _scoreOf(analysis.scoreBreakdown, const [
      'formatting',
    ]);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: LiveScoreMeter(score: analysis.overallScore.toDouble())),
        const SizedBox(height: 16),
        card(
          context,
          title: 'Score Breakdown (Real Analysis)',
          child: Column(
            children: [
              row('Keyword Match', keywordScore.toDouble(), suffix: '/100'),
              row('Skills', skillScore.toDouble(), suffix: '/100'),
              row('Grammar', grammarScore.toDouble(), suffix: '/100'),
              row('Experience', experienceScore.toDouble(), suffix: '/100'),
              row('Formatting', formattingScore.toDouble(), suffix: '/100'),
              const Divider(height: 22),
              row('Configured Weight: Keyword', config.keywordWeight),
              row('Configured Weight: Skill', config.skillWeight),
              row('Configured Weight: Grammar', config.grammarWeight),
              row('Configured Weight: Experience', config.experienceWeight),
              row('Configured Weight: Formatting', config.formattingWeight),
            ],
          ),
        ),
        const SizedBox(height: 12),
        card(
          context,
          title: 'Matched Keywords',
          child: analysis.matchedKeywords.isEmpty
              ? const Text('No matched keywords detected yet.')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: analysis.matchedKeywords
                      .map(
                        (k) => Chip(label: Text('${k.keyword} (${k.count})')),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 12),
        card(
          context,
          title: 'Missing Keywords',
          child: analysis.missingKeywords.isEmpty
              ? const Text('No missing keywords found. Great job.')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: analysis.missingKeywords.map((keyword) {
                    final chipColor = _importanceColor(keyword.importance);
                    return Chip(
                      label: Text('${keyword.keyword} (${keyword.importance})'),
                      backgroundColor: chipColor.withValues(alpha: 0.12),
                      side: BorderSide(
                        color: chipColor.withValues(alpha: 0.45),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 12),
        card(
          context,
          title: 'Suggestions',
          child: analysis.suggestions.isEmpty
              ? const Text('No suggestions available.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: analysis.suggestions.map((s) {
                    final color = _importanceColor(s.priority);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: color)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(s.description),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.auto_fix_high_rounded),
          label: const Text('Improve Resume'),
        ),
      ],
    );
  }

  int _scoreOf(Map<String, int> breakdown, List<String> keys) {
    for (final key in keys) {
      if (breakdown.containsKey(key)) {
        return breakdown[key]!.clamp(0, 100);
      }
    }
    return 0;
  }

  Color _importanceColor(String importance) {
    final lower = importance.toLowerCase();
    if (lower == 'high') return const Color(0xFFDC2626);
    if (lower == 'medium') return const Color(0xFFD97706);
    return const Color(0xFF2563EB);
  }

  Widget card(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget row(String label, double value, {String suffix = '%'}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('${value.toStringAsFixed(0)}$suffix'),
        ],
      ),
    );
  }
}
