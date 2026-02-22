import 'package:flutter/material.dart';

class LiveScoreMeter extends StatelessWidget {
  final double score;

  const LiveScoreMeter({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final safeScore = score.clamp(0, 100);
    final progress = safeScore / 100;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Column(
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 12,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF1E3A8A),
                    ),
                  ),
                  Text(
                    (value * 100).toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ATS Score',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        );
      },
    );
  }
}
