import 'package:flutter/material.dart';
import '../../../core/services/mock_database_service.dart';
import '../widgets/live_score_meter.dart';

class ATSResultPage extends StatelessWidget {
  final double score;

  const ATSResultPage({super.key, this.score = 78});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = MockDatabaseService.instance.getAtsConfig();
    final suggestions = const [
      'Add more measurable impact in experience points',
      'Increase role-specific keywords in skills section',
      'Improve formatting consistency and heading hierarchy',
      'Expand project outcomes with clear business value',
    ];

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
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(child: LiveScoreMeter(score: score)),
                  const SizedBox(height: 16),
                  _card(
                    context,
                    title: 'Score Breakdown (Dynamic Weights)',
                    child: Column(
                      children: [
                        _row('Keyword', config.keywordWeight),
                        _row('Skill', config.skillWeight),
                        _row('Grammar', config.grammarWeight),
                        _row('Experience', config.experienceWeight),
                        _row('Formatting', config.formattingWeight),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Missing Keywords',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        Chip(label: Text('Scalable APIs')),
                        Chip(label: Text('Leadership')),
                        Chip(label: Text('CI/CD')),
                        Chip(label: Text('Testing')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Suggestions',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: suggestions
                          .map(
                            (suggestion) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(child: Text(suggestion)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    label: const Text('Improve Resume'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _card(
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

  Widget _row(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('${value.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}
